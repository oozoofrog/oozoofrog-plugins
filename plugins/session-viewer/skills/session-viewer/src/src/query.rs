use anyhow::{anyhow, Context, Result};
use chrono::{DateTime, Local, NaiveDate, TimeZone, Utc};
use clap::{Args, ValueEnum};
use regex::Regex;
use serde_json::{json, Value};
use std::{
    env, fs,
    io::{BufRead, BufReader},
    path::PathBuf,
    time::{Duration, SystemTime},
};

use crate::data::{encode_path, load_sessions, projects_root, Session};

#[derive(Args, Debug)]
pub struct QueryArgs {
    /// Filter sessions modified at or after this time (e.g. "2d", "1h", "2026-05-01")
    #[arg(long, value_name = "WHEN")]
    pub since: Option<String>,

    /// Filter sessions modified at or before this time
    #[arg(long, value_name = "WHEN")]
    pub until: Option<String>,

    /// Only sessions started in the current working directory
    #[arg(long)]
    pub cwd: bool,

    /// Only sessions whose project label contains this substring
    #[arg(long, value_name = "PATTERN")]
    pub project: Option<String>,

    /// Only sessions/messages where a tool with this name was used (regex)
    #[arg(long, value_name = "REGEX")]
    pub tool: Option<String>,

    /// Plain substring match in user/assistant/tool_result body
    #[arg(long, value_name = "STRING")]
    pub text: Option<String>,

    /// Regex match in user/assistant/tool_result body
    #[arg(long, value_name = "REGEX")]
    pub regex: Option<String>,

    /// Output format
    #[arg(long, value_enum, default_value_t = OutputFormat::Summary)]
    pub format: OutputFormat,
}

#[derive(Copy, Clone, Debug, ValueEnum)]
pub enum OutputFormat {
    /// Human-readable summary, one session per line
    Summary,
    /// JSON array of session metadata objects
    Json,
    /// Matched JSONL lines passed through verbatim
    Jsonl,
}

/// Parse a time hint into an absolute SystemTime.
/// Accepts: "<N><unit>" (relative from now; units: s/m/h/d/w),
///          ISO date "YYYY-MM-DD" (interpreted as local 00:00),
///          ISO datetime "YYYY-MM-DDTHH:MM:SS".
fn parse_time(s: &str) -> Result<SystemTime> {
    let s = s.trim();

    // Relative: <N><unit>
    if let Some((num, unit)) = split_rel(s) {
        let secs: u64 = match unit {
            "s" => num,
            "m" => num * 60,
            "h" => num * 3600,
            "d" => num * 86_400,
            "w" => num * 7 * 86_400,
            _ => return Err(anyhow!("unknown time unit '{}'", unit)),
        };
        return Ok(SystemTime::now() - Duration::from_secs(secs));
    }

    // ISO date
    if let Ok(d) = NaiveDate::parse_from_str(s, "%Y-%m-%d") {
        let dt = d
            .and_hms_opt(0, 0, 0)
            .ok_or_else(|| anyhow!("invalid date"))?;
        let local: DateTime<Local> = Local.from_local_datetime(&dt).single()
            .ok_or_else(|| anyhow!("ambiguous local datetime"))?;
        return Ok(local.into());
    }

    // ISO datetime (UTC fallback)
    if let Ok(dt) = DateTime::parse_from_rfc3339(s) {
        return Ok(dt.with_timezone(&Utc).into());
    }

    Err(anyhow!(
        "could not parse time '{}'; use e.g. '2d', '1h', '2026-05-01', or RFC3339",
        s
    ))
}

fn split_rel(s: &str) -> Option<(u64, &str)> {
    let last = s.chars().last()?;
    if !last.is_ascii_alphabetic() {
        return None;
    }
    let num_part = &s[..s.len() - last.len_utf8()];
    let n: u64 = num_part.parse().ok()?;
    let unit = &s[s.len() - last.len_utf8()..];
    Some((n, unit))
}

#[derive(Clone)]
struct CompiledFilters {
    since: Option<SystemTime>,
    until: Option<SystemTime>,
    cwd_only: bool,
    project: Option<String>,
    tool_re: Option<Regex>,
    text: Option<String>,
    body_re: Option<Regex>,
}

impl CompiledFilters {
    fn from(args: &QueryArgs) -> Result<Self> {
        Ok(Self {
            since: args.since.as_deref().map(parse_time).transpose()?,
            until: args.until.as_deref().map(parse_time).transpose()?,
            cwd_only: args.cwd,
            project: args.project.clone(),
            tool_re: args.tool.as_deref()
                .map(Regex::new)
                .transpose()
                .context("invalid --tool regex")?,
            text: args.text.clone(),
            body_re: args.regex.as_deref()
                .map(Regex::new)
                .transpose()
                .context("invalid --regex")?,
        })
    }

    fn requires_body_scan(&self) -> bool {
        self.tool_re.is_some() || self.text.is_some() || self.body_re.is_some()
    }

    fn passes_metadata(&self, s: &Session) -> bool {
        if let Some(t) = self.since {
            if s.modified < t {
                return false;
            }
        }
        if let Some(t) = self.until {
            if s.modified > t {
                return false;
            }
        }
        if self.cwd_only && !s.matches_cwd {
            return false;
        }
        if let Some(p) = &self.project {
            if !s.project_label.contains(p) && !s.project_dir_name.contains(p) {
                return false;
            }
        }
        true
    }
}

pub fn run(args: QueryArgs) -> Result<()> {
    let filters = CompiledFilters::from(&args)?;

    let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let cwd_encoded = encode_path(&cwd);
    let root = projects_root().context("home directory not found")?;
    let sessions = load_sessions(&root, &cwd_encoded)?;

    // Stage 1: metadata filtering
    let mut candidates: Vec<&Session> = sessions
        .iter()
        .filter(|s| filters.passes_metadata(s))
        .collect();

    // Stage 2: body scan if needed
    let mut matched: Vec<MatchedSession> = Vec::new();
    if filters.requires_body_scan() {
        for s in candidates.drain(..) {
            if let Some(m) = scan_body(s, &filters)? {
                matched.push(m);
            }
        }
    } else {
        for s in candidates {
            matched.push(MatchedSession {
                session: s,
                matched_lines: Vec::new(),
                hits: 0,
            });
        }
    }

    // Output
    match args.format {
        OutputFormat::Summary => write_summary(&matched),
        OutputFormat::Json => write_json(&matched)?,
        OutputFormat::Jsonl => write_jsonl(&matched),
    }
    Ok(())
}

struct MatchedSession<'a> {
    session: &'a Session,
    /// Raw JSONL lines that matched (only populated when body scan ran)
    matched_lines: Vec<String>,
    /// Number of message-level hits (multiple per line possible for tool_use+text)
    hits: usize,
}

fn scan_body<'a>(s: &'a Session, f: &CompiledFilters) -> Result<Option<MatchedSession<'a>>> {
    let file = match fs::File::open(&s.file_path) {
        Ok(f) => f,
        Err(_) => return Ok(None),
    };
    let reader = BufReader::new(file);
    let mut matched_lines: Vec<String> = Vec::new();
    let mut hits = 0usize;

    for line in reader.lines() {
        let line = match line {
            Ok(l) if !l.is_empty() => l,
            _ => continue,
        };
        let v: Value = match serde_json::from_str(&line) {
            Ok(v) => v,
            Err(_) => continue,
        };
        let h = line_hits(&v, f);
        if h > 0 {
            hits += h;
            matched_lines.push(line);
        }
    }
    if hits > 0 {
        Ok(Some(MatchedSession { session: s, matched_lines, hits }))
    } else {
        Ok(None)
    }
}

fn line_hits(v: &Value, f: &CompiledFilters) -> usize {
    let mut hits = 0;

    // Tool name match: check assistant.content[*].type==tool_use
    if let Some(re) = &f.tool_re {
        if v.get("type").and_then(|t| t.as_str()) == Some("assistant") {
            if let Some(arr) = v.pointer("/message/content").and_then(|c| c.as_array()) {
                for blk in arr {
                    if blk.get("type").and_then(|t| t.as_str()) == Some("tool_use") {
                        if let Some(name) = blk.get("name").and_then(|n| n.as_str()) {
                            if re.is_match(name) {
                                hits += 1;
                            }
                        }
                    }
                }
            }
        }
    }

    // Text/regex match in body
    if f.text.is_some() || f.body_re.is_some() {
        let body = collect_body_text(v);
        if !body.is_empty() {
            if let Some(t) = &f.text {
                if body.contains(t) {
                    hits += 1;
                }
            }
            if let Some(re) = &f.body_re {
                if re.is_match(&body) {
                    hits += 1;
                }
            }
        }
    }
    hits
}

fn collect_body_text(v: &Value) -> String {
    let typ = v.get("type").and_then(|t| t.as_str()).unwrap_or("");
    if typ != "user" && typ != "assistant" {
        return String::new();
    }
    let content = match v.pointer("/message/content") {
        Some(c) => c,
        None => return String::new(),
    };
    if let Some(s) = content.as_str() {
        return s.to_string();
    }
    let mut buf = String::new();
    if let Some(arr) = content.as_array() {
        for blk in arr {
            let bt = blk.get("type").and_then(|t| t.as_str()).unwrap_or("");
            match bt {
                "text" => {
                    if let Some(t) = blk.get("text").and_then(|s| s.as_str()) {
                        buf.push_str(t);
                        buf.push('\n');
                    }
                }
                "tool_result" => {
                    if let Some(c) = blk.get("content") {
                        if let Some(s) = c.as_str() {
                            buf.push_str(s);
                            buf.push('\n');
                        } else if let Some(a) = c.as_array() {
                            for b in a {
                                if let Some(t) = b.get("text").and_then(|s| s.as_str()) {
                                    buf.push_str(t);
                                    buf.push('\n');
                                }
                            }
                        }
                    }
                }
                "tool_use" => {
                    if let Some(input) = blk.get("input") {
                        buf.push_str(&input.to_string());
                        buf.push('\n');
                    }
                }
                _ => {}
            }
        }
    }
    buf
}

fn write_summary(matched: &[MatchedSession]) {
    if matched.is_empty() {
        eprintln!("no sessions matched");
        return;
    }
    println!(
        "{:>2} {:<16} {:>6} {:<32} {:<8} {}",
        "", "MODIFIED", "MSGS", "PROJECT", "ID", "FIRST USER PROMPT"
    );
    for m in matched {
        let s = m.session;
        let dt: DateTime<Local> = s.modified.into();
        let when = dt.format("%Y-%m-%d %H:%M").to_string();
        let mark = if s.matches_cwd { "● " } else { "  " };
        let id8: String = s.id.chars().take(8).collect();
        let preview = if s.first_user_text.is_empty() {
            "(no user message)".to_string()
        } else {
            crate::data::truncate(&s.first_user_text, 60)
        };
        let proj = crate::data::truncate(&s.project_label, 32);
        let hits = if m.hits > 0 {
            format!(" [{} hits]", m.hits)
        } else {
            String::new()
        };
        println!(
            "{}{} {:>6} {:<32} {:<8} {}{}",
            mark, when, s.msg_count, proj, id8, preview, hits
        );
    }
    eprintln!("\n{} session(s) matched", matched.len());
}

fn write_json(matched: &[MatchedSession]) -> Result<()> {
    let arr: Vec<Value> = matched
        .iter()
        .map(|m| {
            let s = m.session;
            let dt: DateTime<Local> = s.modified.into();
            json!({
                "id": s.id,
                "file_path": s.file_path.to_string_lossy(),
                "project_label": s.project_label,
                "project_dir_name": s.project_dir_name,
                "matches_cwd": s.matches_cwd,
                "modified": dt.to_rfc3339(),
                "msg_count": s.msg_count,
                "first_user_text": s.first_user_text,
                "hits": m.hits,
            })
        })
        .collect();
    println!("{}", serde_json::to_string_pretty(&arr)?);
    Ok(())
}

fn write_jsonl(matched: &[MatchedSession]) {
    for m in matched {
        if m.matched_lines.is_empty() {
            // metadata-only filter: emit one synthetic line per session
            let s = m.session;
            let dt: DateTime<Local> = s.modified.into();
            let v = json!({
                "session_id": s.id,
                "file_path": s.file_path.to_string_lossy(),
                "modified": dt.to_rfc3339(),
                "msg_count": s.msg_count,
            });
            println!("{}", v);
        } else {
            for line in &m.matched_lines {
                println!("{}", line);
            }
        }
    }
}
