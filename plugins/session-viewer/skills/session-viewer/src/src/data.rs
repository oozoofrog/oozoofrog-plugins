use anyhow::Result;
use serde_json::Value;
use std::{
    fs,
    io::{BufRead, BufReader},
    path::{Path, PathBuf},
    time::SystemTime,
};

#[derive(Clone)]
pub struct Session {
    pub id: String,
    pub file_path: PathBuf,
    pub project_dir_name: String,
    pub project_label: String,
    pub modified: SystemTime,
    pub first_user_text: String,
    pub msg_count: usize,
    pub matches_cwd: bool,
}

pub struct Message {
    pub role: &'static str,
    pub title: String,
    pub body: String,
}

pub fn encode_path(p: &Path) -> String {
    p.to_string_lossy()
        .chars()
        .map(|c| if c == '/' || c == '.' { '-' } else { c })
        .collect()
}

pub fn projects_root() -> Option<PathBuf> {
    dirs::home_dir().map(|h| h.join(".claude/projects"))
}

pub fn pretty_project(encoded: &str) -> String {
    let trimmed = encoded.trim_start_matches('-');
    let parts: Vec<&str> = trimmed.split('-').filter(|s| !s.is_empty()).collect();
    if parts.len() <= 3 {
        return trimmed.replace('-', "/");
    }
    let tail: Vec<&str> = parts.iter().rev().take(3).rev().copied().collect();
    format!("…/{}", tail.join("/"))
}

pub fn truncate(s: &str, max: usize) -> String {
    let cleaned: String = s
        .chars()
        .map(|c| if c == '\n' || c == '\r' || c == '\t' { ' ' } else { c })
        .filter(|c| !c.is_control())
        .collect();
    if cleaned.chars().count() <= max {
        return cleaned;
    }
    let mut out: String = cleaned.chars().take(max).collect();
    out.push('…');
    out
}

pub fn is_system_noise(s: &str) -> bool {
    let t = s.trim_start();
    t.starts_with("<system-reminder>")
        || t.starts_with("<command-message>")
        || t.starts_with("<command-name>")
        || t.starts_with("<command-args>")
        || t.starts_with("<local-command-stdout>")
}

pub fn load_sessions(root: &Path, cwd_encoded: &str) -> Result<Vec<Session>> {
    let mut out = Vec::new();
    let entries = match fs::read_dir(root) {
        Ok(e) => e,
        Err(_) => return Ok(out),
    };
    for entry in entries.flatten() {
        let ft = match entry.file_type() {
            Ok(f) => f,
            Err(_) => continue,
        };
        if !ft.is_dir() {
            continue;
        }
        let dir_name = entry.file_name().to_string_lossy().into_owned();
        let dir_path = entry.path();
        let matches_cwd = dir_name == cwd_encoded;
        let files = match fs::read_dir(&dir_path) {
            Ok(f) => f,
            Err(_) => continue,
        };
        for f in files.flatten() {
            let path = f.path();
            if path.extension().and_then(|s| s.to_str()) != Some("jsonl") {
                continue;
            }
            let modified = f
                .metadata()
                .and_then(|m| m.modified())
                .unwrap_or(SystemTime::UNIX_EPOCH);
            let id = path
                .file_stem()
                .and_then(|s| s.to_str())
                .unwrap_or("?")
                .to_string();
            let (first_user, count) = quick_scan(&path).unwrap_or_default();
            out.push(Session {
                id,
                file_path: path,
                project_label: pretty_project(&dir_name),
                project_dir_name: dir_name.clone(),
                modified,
                first_user_text: first_user,
                msg_count: count,
                matches_cwd,
            });
        }
    }
    out.sort_by(|a, b| b.modified.cmp(&a.modified));
    Ok(out)
}

pub fn quick_scan(path: &Path) -> Result<(String, usize)> {
    let f = fs::File::open(path)?;
    let reader = BufReader::new(f);
    let mut count = 0usize;
    let mut first_user = String::new();
    for line in reader.lines() {
        let line = match line {
            Ok(l) if !l.is_empty() => l,
            _ => continue,
        };
        let v: Value = match serde_json::from_str(&line) {
            Ok(v) => v,
            Err(_) => continue,
        };
        count += 1;
        if first_user.is_empty() {
            if let Some(text) = extract_user_text(&v) {
                let t = text.trim();
                if !t.is_empty() && !is_system_noise(t) {
                    first_user = truncate(t, 200);
                }
            }
        }
    }
    Ok((first_user, count))
}

pub fn extract_user_text(v: &Value) -> Option<String> {
    let typ = v.get("type")?.as_str()?;
    if typ != "user" {
        return None;
    }
    let content = v.pointer("/message/content")?;
    if let Some(s) = content.as_str() {
        return Some(s.to_string());
    }
    if let Some(arr) = content.as_array() {
        let mut buf = String::new();
        for blk in arr {
            if blk.get("type").and_then(|t| t.as_str()) == Some("text") {
                if let Some(t) = blk.get("text").and_then(|t| t.as_str()) {
                    if !buf.is_empty() {
                        buf.push(' ');
                    }
                    buf.push_str(t);
                }
            }
        }
        if !buf.is_empty() {
            return Some(buf);
        }
    }
    None
}

pub fn load_messages(path: &Path) -> Result<Vec<Message>> {
    let f = fs::File::open(path)?;
    let reader = BufReader::new(f);
    let mut out = Vec::new();
    for line in reader.lines() {
        let line = match line {
            Ok(l) if !l.is_empty() => l,
            _ => continue,
        };
        let v: Value = match serde_json::from_str(&line) {
            Ok(v) => v,
            Err(_) => continue,
        };
        if let Some(typ) = v.get("type").and_then(|t| t.as_str()) {
            match typ {
                "user" => render_user(&v, &mut out),
                "assistant" => render_assistant(&v, &mut out),
                "permission-mode" => {
                    if let Some(m) = v.get("permissionMode").and_then(|m| m.as_str()) {
                        out.push(Message {
                            role: "system",
                            title: "permission-mode".into(),
                            body: m.to_string(),
                        });
                    }
                }
                _ => {}
            }
        } else if v.get("attachment").is_some() {
            let hook = v
                .pointer("/attachment/hookName")
                .and_then(|s| s.as_str())
                .unwrap_or("hook");
            let event = v
                .pointer("/attachment/hookEvent")
                .and_then(|s| s.as_str())
                .unwrap_or("");
            let stdout = v
                .pointer("/attachment/stdout")
                .and_then(|s| s.as_str())
                .unwrap_or("");
            let content = v
                .pointer("/attachment/content")
                .and_then(|s| s.as_str())
                .unwrap_or("");
            let body = if !stdout.is_empty() {
                stdout.to_string()
            } else {
                content.to_string()
            };
            out.push(Message {
                role: "hook",
                title: format!("{} ({})", hook, event),
                body,
            });
        }
    }
    Ok(out)
}

fn render_user(v: &Value, out: &mut Vec<Message>) {
    let content = match v.pointer("/message/content") {
        Some(c) => c,
        None => return,
    };
    if let Some(s) = content.as_str() {
        if !is_system_noise(s) {
            out.push(Message {
                role: "user",
                title: "User".into(),
                body: s.to_string(),
            });
        }
        return;
    }
    if let Some(arr) = content.as_array() {
        for blk in arr {
            let t = blk.get("type").and_then(|t| t.as_str()).unwrap_or("");
            match t {
                "text" => {
                    if let Some(text) = blk.get("text").and_then(|t| t.as_str()) {
                        if !is_system_noise(text) {
                            out.push(Message {
                                role: "user",
                                title: "User".into(),
                                body: text.to_string(),
                            });
                        }
                    }
                }
                "tool_result" => {
                    let id = blk
                        .get("tool_use_id")
                        .and_then(|s| s.as_str())
                        .unwrap_or("?");
                    let body = match blk.get("content") {
                        Some(c) if c.is_string() => c.as_str().unwrap_or("").to_string(),
                        Some(c) if c.is_array() => c
                            .as_array()
                            .unwrap()
                            .iter()
                            .filter_map(|b| b.get("text").and_then(|t| t.as_str()))
                            .collect::<Vec<_>>()
                            .join("\n"),
                        Some(c) => c.to_string(),
                        None => String::new(),
                    };
                    let short_id: String = id.chars().take(8).collect();
                    out.push(Message {
                        role: "tool_result",
                        title: format!("Tool result ({})", short_id),
                        body,
                    });
                }
                _ => {}
            }
        }
    }
}

fn render_assistant(v: &Value, out: &mut Vec<Message>) {
    let content = match v.pointer("/message/content") {
        Some(c) => c,
        None => return,
    };
    if let Some(s) = content.as_str() {
        out.push(Message {
            role: "assistant",
            title: "Assistant".into(),
            body: s.to_string(),
        });
        return;
    }
    if let Some(arr) = content.as_array() {
        for blk in arr {
            let t = blk.get("type").and_then(|t| t.as_str()).unwrap_or("");
            match t {
                "text" => {
                    if let Some(text) = blk.get("text").and_then(|t| t.as_str()) {
                        out.push(Message {
                            role: "assistant",
                            title: "Assistant".into(),
                            body: text.to_string(),
                        });
                    }
                }
                "tool_use" => {
                    let name = blk.get("name").and_then(|n| n.as_str()).unwrap_or("?");
                    let input = blk
                        .get("input")
                        .map(|i| serde_json::to_string_pretty(i).unwrap_or_default())
                        .unwrap_or_default();
                    out.push(Message {
                        role: "tool_use",
                        title: format!("→ {}", name),
                        body: input,
                    });
                }
                "thinking" => {
                    if let Some(text) = blk.get("thinking").and_then(|t| t.as_str()) {
                        out.push(Message {
                            role: "thinking",
                            title: "Thinking".into(),
                            body: text.to_string(),
                        });
                    }
                }
                _ => {}
            }
        }
    }
}
