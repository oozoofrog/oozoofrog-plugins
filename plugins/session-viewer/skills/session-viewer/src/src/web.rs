use anyhow::{anyhow, Context, Result};
use chrono::{DateTime, Local};
use clap::Args;
use serde_json::{json, Value};
use std::{
    env, fs,
    io::{self, BufRead, BufReader, Write},
    path::PathBuf,
};

use crate::data::{encode_path, is_system_noise, load_sessions, projects_root, Session};

#[derive(Args, Debug)]
pub struct WebArgs {
    /// Session UUID or unique prefix
    #[arg(value_name = "SESSION_ID")]
    pub session: Option<String>,

    /// Output file (default: stdout)
    #[arg(short, long, value_name = "PATH")]
    pub output: Option<PathBuf>,

    /// Run as a local HTTP server instead of static export
    #[arg(long)]
    pub serve: bool,

    /// Server port (with --serve)
    #[arg(long, default_value_t = 7878)]
    pub port: u16,

    /// Server bind address (with --serve)
    #[arg(long, default_value = "127.0.0.1")]
    pub host: String,

    /// Do not auto-open the browser (with --serve)
    #[arg(long)]
    pub no_open: bool,
}

pub fn run(args: WebArgs) -> Result<()> {
    if args.serve {
        if args.session.is_some() {
            return Err(anyhow!("--serve does not take a session id"));
        }
        return start_server(args);
    }

    let session_id = args
        .session
        .as_deref()
        .ok_or_else(|| anyhow!("either provide a SESSION_ID or use --serve"))?;

    let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let cwd_encoded = encode_path(&cwd);
    let root = projects_root().context("home directory not found")?;
    let sessions = load_sessions(&root, &cwd_encoded)?;

    let target = find_session(&sessions, session_id)?;
    let html = render_html(target, "")?;

    match &args.output {
        Some(path) => {
            fs::write(path, html.as_bytes())
                .with_context(|| format!("failed to write {}", path.display()))?;
            eprintln!("wrote {} ({} bytes)", path.display(), html.len());
        }
        None => {
            let stdout = io::stdout();
            let mut h = stdout.lock();
            h.write_all(html.as_bytes())?;
        }
    }
    Ok(())
}

fn find_session<'a>(sessions: &'a [Session], needle: &str) -> Result<&'a Session> {
    let exact: Vec<_> = sessions.iter().filter(|s| s.id == needle).collect();
    if let Some(s) = exact.first() {
        return Ok(s);
    }
    let prefix: Vec<_> = sessions.iter().filter(|s| s.id.starts_with(needle)).collect();
    match prefix.len() {
        0 => Err(anyhow!("no session matches '{}'", needle)),
        1 => Ok(prefix[0]),
        n => {
            let listed: Vec<&str> = prefix.iter().take(5).map(|s| s.id.as_str()).collect();
            Err(anyhow!(
                "{} sessions match prefix '{}': {}{}",
                n,
                needle,
                listed.join(", "),
                if n > 5 { ", …" } else { "" }
            ))
        }
    }
}

fn render_html(s: &Session, nav_html: &str) -> Result<String> {
    let messages = collect_for_html(&s.file_path)?;
    let dt: DateTime<Local> = s.modified.into();

    let meta = json!({
        "id": s.id,
        "project_label": s.project_label,
        "project_dir_name": s.project_dir_name,
        "modified": dt.to_rfc3339(),
        "matches_cwd": s.matches_cwd,
        "msg_count": s.msg_count,
    });

    let data = json!({
        "meta": meta,
        "messages": messages,
    });

    let data_json = serde_json::to_string(&data)?;

    let id_short: String = s.id.chars().take(8).collect();
    let title = format!("Session {} — {}", id_short, s.project_label);

    Ok(build_html(&title, &data_json, nav_html))
}

fn collect_session_data(s: &Session) -> Result<Value> {
    let messages = collect_for_html(&s.file_path)?;
    let dt: DateTime<Local> = s.modified.into();
    let meta = json!({
        "id": s.id,
        "project_label": s.project_label,
        "project_dir_name": s.project_dir_name,
        "modified": dt.to_rfc3339(),
        "matches_cwd": s.matches_cwd,
        "msg_count": s.msg_count,
    });
    Ok(json!({ "meta": meta, "messages": messages }))
}

fn collect_for_html(path: &std::path::Path) -> Result<Vec<Value>> {
    let f = fs::File::open(path)?;
    let reader = BufReader::new(f);
    let mut out: Vec<Value> = Vec::new();
    let mut order: usize = 0;

    for line in reader.lines() {
        let line = match line {
            Ok(l) if !l.is_empty() => l,
            _ => continue,
        };
        let v: Value = match serde_json::from_str(&line) {
            Ok(v) => v,
            Err(_) => continue,
        };
        let typ = v.get("type").and_then(|t| t.as_str()).unwrap_or("");
        match typ {
            "user" => collect_user(&v, &mut out, &mut order),
            "assistant" => collect_assistant(&v, &mut out, &mut order),
            "permission-mode" => {
                if let Some(m) = v.get("permissionMode").and_then(|m| m.as_str()) {
                    out.push(json!({
                        "order": order,
                        "role": "system",
                        "title": "permission-mode",
                        "body": m,
                    }));
                    order += 1;
                }
            }
            _ => {
                if v.get("attachment").is_some() {
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
                    let body = if !stdout.is_empty() { stdout } else { content };
                    out.push(json!({
                        "order": order,
                        "role": "hook",
                        "title": format!("{} ({})", hook, event),
                        "body": body,
                    }));
                    order += 1;
                }
            }
        }
    }
    Ok(out)
}

fn collect_user(v: &Value, out: &mut Vec<Value>, order: &mut usize) {
    let content = match v.pointer("/message/content") {
        Some(c) => c,
        None => return,
    };
    if let Some(s) = content.as_str() {
        if !is_system_noise(s) {
            out.push(json!({"order": *order, "role": "user", "title": "User", "body": s}));
            *order += 1;
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
                            out.push(json!({
                                "order": *order, "role": "user", "title": "User", "body": text
                            }));
                            *order += 1;
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
                    let id8: String = id.chars().take(8).collect();
                    out.push(json!({
                        "order": *order,
                        "role": "tool_result",
                        "title": format!("Tool result ({})", id8),
                        "body": body,
                        "tool_use_id": id,
                    }));
                    *order += 1;
                }
                _ => {}
            }
        }
    }
}

fn collect_assistant(v: &Value, out: &mut Vec<Value>, order: &mut usize) {
    let content = match v.pointer("/message/content") {
        Some(c) => c,
        None => return,
    };
    if let Some(s) = content.as_str() {
        out.push(json!({"order": *order, "role": "assistant", "title": "Assistant", "body": s}));
        *order += 1;
        return;
    }
    if let Some(arr) = content.as_array() {
        for blk in arr {
            let t = blk.get("type").and_then(|t| t.as_str()).unwrap_or("");
            match t {
                "text" => {
                    if let Some(text) = blk.get("text").and_then(|t| t.as_str()) {
                        out.push(json!({
                            "order": *order, "role": "assistant", "title": "Assistant", "body": text
                        }));
                        *order += 1;
                    }
                }
                "tool_use" => {
                    let name = blk.get("name").and_then(|n| n.as_str()).unwrap_or("?");
                    let id = blk.get("id").and_then(|s| s.as_str()).unwrap_or("");
                    let input_pretty = blk
                        .get("input")
                        .map(|i| serde_json::to_string_pretty(i).unwrap_or_default())
                        .unwrap_or_default();
                    out.push(json!({
                        "order": *order,
                        "role": "tool_use",
                        "title": format!("→ {}", name),
                        "body": input_pretty,
                        "tool_name": name,
                        "tool_use_id": id,
                    }));
                    *order += 1;
                }
                "thinking" => {
                    if let Some(text) = blk.get("thinking").and_then(|t| t.as_str()) {
                        out.push(json!({
                            "order": *order, "role": "thinking", "title": "Thinking", "body": text
                        }));
                        *order += 1;
                    }
                }
                _ => {}
            }
        }
    }
}

fn build_html(title: &str, data_json: &str, nav_html: &str) -> String {
    let template = HTML_TEMPLATE;
    template
        .replace("{{TITLE}}", &html_escape(title))
        .replace("{{NAV}}", nav_html)
        .replace("{{DATA_JSON}}", &escape_for_script(data_json))
}

fn html_escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

/// Escape a JSON string for embedding inside <script>: prevent `</script>` injection.
fn escape_for_script(s: &str) -> String {
    s.replace("</", "<\\/")
}

const HTML_TEMPLATE: &str = r##"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{{TITLE}}</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
  --bg: #fafafa;
  --fg: #1a1a1a;
  --muted: #6b6b6b;
  --border: #e0e0e0;
  --user: #d4f5d4;
  --user-fg: #0a4f0a;
  --assistant: #ffffff;
  --tool-use: #f3e8ff;
  --tool-use-fg: #6b21a8;
  --tool-result: #f3f4f6;
  --tool-result-fg: #4b5563;
  --thinking: #fef3c7;
  --thinking-fg: #92400e;
  --hook: #dbeafe;
  --hook-fg: #1e40af;
  --system: #f5f5f5;
  --system-fg: #6b6b6b;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #1a1a1a;
    --fg: #e5e5e5;
    --muted: #a0a0a0;
    --border: #333;
    --user: #1f4d1f;
    --user-fg: #b8e6b8;
    --assistant: #262626;
    --tool-use: #3b1f5c;
    --tool-use-fg: #d8b4fe;
    --tool-result: #2a2a2a;
    --tool-result-fg: #b0b0b0;
    --thinking: #4a3a0a;
    --thinking-fg: #fde68a;
    --hook: #1e3a5f;
    --hook-fg: #93c5fd;
    --system: #2a2a2a;
    --system-fg: #a0a0a0;
  }
}
* { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--fg);
  margin: 0;
  padding: 0;
  line-height: 1.5;
}
header {
  position: sticky;
  top: 0;
  background: var(--bg);
  border-bottom: 1px solid var(--border);
  padding: 12px 16px;
  z-index: 10;
}
.meta { display: flex; gap: 12px; flex-wrap: wrap; align-items: baseline; font-size: 13px; }
.meta strong { font-size: 15px; }
.meta span.muted { color: var(--muted); }
.search-row { margin-top: 8px; display: flex; gap: 8px; align-items: center; }
input[type=search] {
  flex: 1;
  padding: 6px 10px;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: var(--bg);
  color: var(--fg);
  font: inherit;
}
.filter-chip {
  font-size: 12px;
  padding: 3px 8px;
  border-radius: 12px;
  border: 1px solid var(--border);
  background: var(--bg);
  color: var(--muted);
  cursor: pointer;
  user-select: none;
}
.filter-chip.active { color: var(--fg); border-color: var(--fg); }
.count { color: var(--muted); font-size: 12px; }
main { max-width: 980px; margin: 0 auto; padding: 16px; }
.msg {
  margin: 10px 0;
  padding: 10px 14px;
  border-radius: 10px;
  border: 1px solid var(--border);
  background: var(--assistant);
}
.msg .who {
  font-weight: 600;
  font-size: 12px;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  margin-bottom: 4px;
}
.msg .body { white-space: pre-wrap; word-wrap: break-word; font-family: ui-monospace, 'SF Mono', Menlo, monospace; font-size: 13px; }
.msg.user { background: var(--user); border-color: var(--user); }
.msg.user .who { color: var(--user-fg); }
.msg.assistant { background: var(--assistant); }
.msg.assistant .who { color: var(--muted); }
.msg.tool_use { background: var(--tool-use); border-color: var(--tool-use); }
.msg.tool_use .who { color: var(--tool-use-fg); }
.msg.tool_result { background: var(--tool-result); border-color: var(--tool-result); }
.msg.tool_result .who { color: var(--tool-result-fg); }
.msg.thinking { background: var(--thinking); border-color: var(--thinking); font-style: italic; }
.msg.thinking .who { color: var(--thinking-fg); font-style: normal; }
.msg.hook { background: var(--hook); border-color: var(--hook); }
.msg.hook .who { color: var(--hook-fg); }
.msg.system { background: var(--system); border-color: var(--system); }
.msg.system .who { color: var(--system-fg); }
.collapsible .body { max-height: 7em; overflow: hidden; position: relative; }
.collapsible.open .body { max-height: none; }
.collapsible .body::after {
  content: "";
  position: absolute; left: 0; right: 0; bottom: 0; height: 2em;
  background: linear-gradient(transparent, var(--tool-use));
  pointer-events: none;
}
.collapsible.tool_result .body::after { background: linear-gradient(transparent, var(--tool-result)); }
.collapsible.open .body::after { display: none; }
.collapsible .toggle {
  margin-top: 6px;
  font-size: 12px;
  color: var(--muted);
  cursor: pointer;
  user-select: none;
}
.hidden { display: none !important; }
mark { background: #fef08a; color: #000; padding: 0 2px; border-radius: 2px; }
@media (prefers-color-scheme: dark) {
  mark { background: #854d0e; color: #fef08a; }
}
footer { text-align: center; padding: 24px; color: var(--muted); font-size: 12px; border-top: 1px solid var(--border); margin-top: 32px; }
.nav { font-size: 13px; margin-bottom: 6px; }
.nav a { color: var(--muted); text-decoration: none; }
.nav a:hover { color: var(--fg); text-decoration: underline; }
</style>
</head>
<body>
<header>
  {{NAV}}
  <div class="meta" id="meta"></div>
  <div class="search-row">
    <input type="search" id="search" placeholder="Search messages (substring, case-insensitive)…">
    <span class="filter-chip active" data-filter="all">All</span>
    <span class="filter-chip" data-filter="user">User</span>
    <span class="filter-chip" data-filter="assistant">Assistant</span>
    <span class="filter-chip" data-filter="tool_use">Tool</span>
    <span class="filter-chip" data-filter="tool_result">Result</span>
    <span class="count" id="count"></span>
  </div>
</header>
<main id="messages"></main>
<footer>generated by session-viewer · double-click any tool card to expand</footer>
<script>
const DATA = {{DATA_JSON}};

const ROLE_LABELS = {
  user: "You",
  assistant: "Claude",
  tool_use: "Tool call",
  tool_result: "Tool result",
  thinking: "Thinking",
  hook: "Hook",
  system: "System",
};

function el(tag, attrs, ...children) {
  const e = document.createElement(tag);
  for (const k in attrs) {
    if (k === "class") e.className = attrs[k];
    else if (k === "data") for (const dk in attrs.data) e.dataset[dk] = attrs.data[dk];
    else e.setAttribute(k, attrs[k]);
  }
  for (const c of children) {
    if (typeof c === "string") e.appendChild(document.createTextNode(c));
    else if (c) e.appendChild(c);
  }
  return e;
}

function renderMeta() {
  const m = DATA.meta;
  const head = document.getElementById("meta");
  head.replaceChildren();
  head.append(
    el("strong", {}, "Session " + m.id.slice(0, 8)),
    el("span", { class: "muted" }, m.project_label),
    el("span", { class: "muted" }, new Date(m.modified).toLocaleString()),
    el("span", { class: "muted" }, m.msg_count + " events"),
    el("span", { class: "muted" }, m.matches_cwd ? "● cwd-matched" : "")
  );
  document.title = "Session " + m.id.slice(0, 8) + " — " + m.project_label;
}

function renderMessages() {
  const main = document.getElementById("messages");
  main.replaceChildren();
  const collapsibleRoles = new Set(["tool_use", "tool_result", "hook", "thinking"]);
  for (const m of DATA.messages) {
    const isCollapsible = collapsibleRoles.has(m.role) && (m.body || "").length > 280;
    const cls = "msg " + m.role + (isCollapsible ? " collapsible " + m.role : "");
    const card = el("div", { class: cls, data: { role: m.role, order: m.order } });
    card.appendChild(el("div", { class: "who" }, (ROLE_LABELS[m.role] || m.role) + " · " + m.title));
    const body = el("div", { class: "body" }, m.body || "");
    card.appendChild(body);
    if (isCollapsible) {
      const t = el("div", { class: "toggle" }, "▶ click to expand");
      card.appendChild(t);
      const toggle = () => {
        card.classList.toggle("open");
        t.textContent = card.classList.contains("open") ? "▼ click to collapse" : "▶ click to expand";
      };
      t.addEventListener("click", toggle);
      card.addEventListener("dblclick", toggle);
    }
    main.appendChild(card);
  }
  updateCount();
}

let currentFilter = "all";
let currentSearch = "";

function applyFilters() {
  const cards = document.querySelectorAll("#messages .msg");
  const term = currentSearch.toLowerCase();
  let shown = 0;
  for (const card of cards) {
    const role = card.dataset.role;
    const text = card.textContent.toLowerCase();
    const roleOk = currentFilter === "all" || role === currentFilter;
    const textOk = !term || text.indexOf(term) !== -1;
    if (roleOk && textOk) {
      card.classList.remove("hidden");
      shown += 1;
      if (term) highlightTerm(card, term);
      else clearHighlight(card);
    } else {
      card.classList.add("hidden");
      clearHighlight(card);
    }
  }
  updateCount(shown);
}

function highlightTerm(card, term) {
  const body = card.querySelector(".body");
  if (!body) return;
  if (body.dataset.original === undefined) body.dataset.original = body.textContent;
  const text = body.dataset.original;
  body.replaceChildren();
  if (!term) { body.appendChild(document.createTextNode(text)); return; }
  const lower = text.toLowerCase();
  let idx = lower.indexOf(term), last = 0;
  if (idx < 0) { body.appendChild(document.createTextNode(text)); return; }
  while (idx >= 0) {
    body.appendChild(document.createTextNode(text.slice(last, idx)));
    const mark = document.createElement("mark");
    mark.textContent = text.slice(idx, idx + term.length);
    body.appendChild(mark);
    last = idx + term.length;
    idx = lower.indexOf(term, last);
  }
  body.appendChild(document.createTextNode(text.slice(last)));
}

function clearHighlight(card) {
  const body = card.querySelector(".body");
  if (!body) return;
  if (body.dataset.original !== undefined) {
    body.replaceChildren();
    body.appendChild(document.createTextNode(body.dataset.original));
  }
}

function updateCount(shown) {
  const total = DATA.messages.length;
  const c = document.getElementById("count");
  if (shown === undefined) c.textContent = total + " messages";
  else c.textContent = shown + " of " + total + " messages";
}

function init() {
  renderMeta();
  renderMessages();
  const search = document.getElementById("search");
  search.addEventListener("input", (e) => {
    currentSearch = e.target.value;
    applyFilters();
  });
  for (const chip of document.querySelectorAll(".filter-chip")) {
    chip.addEventListener("click", () => {
      for (const c of document.querySelectorAll(".filter-chip")) c.classList.remove("active");
      chip.classList.add("active");
      currentFilter = chip.dataset.filter;
      applyFilters();
    });
  }
  document.addEventListener("keydown", (e) => {
    if (e.key === "/" && document.activeElement !== search) {
      e.preventDefault();
      search.focus();
    } else if (e.key === "Escape" && document.activeElement === search) {
      search.value = "";
      currentSearch = "";
      applyFilters();
      search.blur();
    }
  });
}

init();
</script>
</body>
</html>
"##;

// ---------- server mode ----------

fn load_all_sessions() -> Result<Vec<Session>> {
    let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    let cwd_encoded = encode_path(&cwd);
    let root = projects_root().context("home directory not found")?;
    load_sessions(&root, &cwd_encoded)
}

fn start_server(args: WebArgs) -> Result<()> {
    let addr = format!("{}:{}", args.host, args.port);
    let server = tiny_http::Server::http(&addr)
        .map_err(|e| anyhow!("failed to bind {}: {}", addr, e))?;

    let url = format!("http://{}", addr);
    eprintln!("listening on {}", url);

    if !args.no_open {
        open_browser(&url);
    }

    for request in server.incoming_requests() {
        if let Err(e) = handle_request(request) {
            eprintln!("request error: {}", e);
        }
    }
    Ok(())
}

fn open_browser(url: &str) {
    let cmd = if cfg!(target_os = "macos") {
        Some("open")
    } else if cfg!(target_os = "linux") {
        Some("xdg-open")
    } else {
        None
    };
    if let Some(c) = cmd {
        let _ = std::process::Command::new(c).arg(url).spawn();
    }
}

fn handle_request(request: tiny_http::Request) -> Result<()> {
    let url = request.url().to_string();
    let path = url.split('?').next().unwrap_or("");

    if path == "/" {
        let body = render_index_html()?;
        return respond_html(request, 200, &body);
    }
    if path == "/api/sessions.json" {
        let body = render_sessions_json()?;
        return respond_json(request, 200, &body);
    }
    if let Some(rest) = path.strip_prefix("/api/session/") {
        let id = rest.trim_end_matches(".json");
        return handle_api_session(request, id);
    }
    if let Some(id) = path.strip_prefix("/session/") {
        return handle_session_html(request, id);
    }

    respond_text(request, 404, "404 not found")
}

fn handle_session_html(request: tiny_http::Request, id: &str) -> Result<()> {
    let sessions = load_all_sessions()?;
    match find_session_kind(&sessions, id) {
        SessionLookup::Found(s) => {
            let nav = r#"<div class="nav"><a href="/">← back to index</a></div>"#;
            let html = render_html(s, nav)?;
            respond_html(request, 200, &html)
        }
        SessionLookup::Ambiguous(ids) => {
            let body = format!(
                "300 multiple matches for '{}':\n{}",
                id,
                ids.join("\n")
            );
            respond_text(request, 300, &body)
        }
        SessionLookup::None => respond_text(request, 404, &format!("404 no session matches '{}'", id)),
    }
}

fn handle_api_session(request: tiny_http::Request, id: &str) -> Result<()> {
    let sessions = load_all_sessions()?;
    match find_session_kind(&sessions, id) {
        SessionLookup::Found(s) => {
            let data = collect_session_data(s)?;
            let body = serde_json::to_string(&data)?;
            respond_json(request, 200, &body)
        }
        SessionLookup::Ambiguous(ids) => {
            let body = format!(
                "300 multiple matches for '{}':\n{}",
                id,
                ids.join("\n")
            );
            respond_text(request, 300, &body)
        }
        SessionLookup::None => respond_text(request, 404, &format!("404 no session matches '{}'", id)),
    }
}

enum SessionLookup<'a> {
    Found(&'a Session),
    Ambiguous(Vec<String>),
    None,
}

fn find_session_kind<'a>(sessions: &'a [Session], needle: &str) -> SessionLookup<'a> {
    if let Some(s) = sessions.iter().find(|s| s.id == needle) {
        return SessionLookup::Found(s);
    }
    let prefix: Vec<&Session> = sessions.iter().filter(|s| s.id.starts_with(needle)).collect();
    match prefix.len() {
        0 => SessionLookup::None,
        1 => SessionLookup::Found(prefix[0]),
        _ => SessionLookup::Ambiguous(prefix.iter().map(|s| s.id.clone()).collect()),
    }
}

fn render_sessions_json() -> Result<String> {
    let sessions = load_all_sessions()?;
    let arr: Vec<Value> = sessions
        .iter()
        .map(|s| {
            let dt: DateTime<Local> = s.modified.into();
            json!({
                "id": s.id,
                "project_label": s.project_label,
                "modified": dt.to_rfc3339(),
                "msg_count": s.msg_count,
                "first_user_text": s.first_user_text,
                "matches_cwd": s.matches_cwd,
            })
        })
        .collect();
    Ok(serde_json::to_string(&arr)?)
}

fn render_index_html() -> Result<String> {
    let sessions = load_all_sessions()?;
    let mut rows = String::new();
    for s in &sessions {
        let dt: DateTime<Local> = s.modified.into();
        let modified = dt.format("%Y-%m-%d %H:%M").to_string();
        let cwd_marker = if s.matches_cwd { " ●" } else { "" };
        rows.push_str(&format!(
            r#"<a class="row" href="/session/{id}"><div class="row-head"><span class="row-id">{id_short}</span><span class="row-proj">{proj}{cwd}</span><span class="row-time">{when}</span><span class="row-count">{count} msgs</span></div><div class="row-preview">{preview}</div></a>"#,
            id = s.id,
            id_short = html_escape(&s.id.chars().take(8).collect::<String>()),
            proj = html_escape(&s.project_label),
            cwd = cwd_marker,
            when = html_escape(&modified),
            count = s.msg_count,
            preview = html_escape(&s.first_user_text),
        ));
    }
    let count_label = format!("{} sessions", sessions.len());
    Ok(INDEX_TEMPLATE
        .replace("{{COUNT}}", &html_escape(&count_label))
        .replace("{{ROWS}}", &rows))
}

fn respond_html(request: tiny_http::Request, status: u16, body: &str) -> Result<()> {
    let response = tiny_http::Response::from_string(body.to_string())
        .with_status_code(status)
        .with_header(
            "Content-Type: text/html; charset=utf-8"
                .parse::<tiny_http::Header>()
                .unwrap(),
        );
    request.respond(response).context("respond_html")?;
    Ok(())
}

fn respond_json(request: tiny_http::Request, status: u16, body: &str) -> Result<()> {
    let response = tiny_http::Response::from_string(body.to_string())
        .with_status_code(status)
        .with_header(
            "Content-Type: application/json"
                .parse::<tiny_http::Header>()
                .unwrap(),
        );
    request.respond(response).context("respond_json")?;
    Ok(())
}

fn respond_text(request: tiny_http::Request, status: u16, body: &str) -> Result<()> {
    let response = tiny_http::Response::from_string(body.to_string())
        .with_status_code(status)
        .with_header(
            "Content-Type: text/plain; charset=utf-8"
                .parse::<tiny_http::Header>()
                .unwrap(),
        );
    request.respond(response).context("respond_text")?;
    Ok(())
}

const INDEX_TEMPLATE: &str = r##"<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>session-viewer</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
:root {
  --bg: #fafafa;
  --fg: #1a1a1a;
  --muted: #6b6b6b;
  --border: #e0e0e0;
  --user: #d4f5d4;
  --user-fg: #0a4f0a;
  --row-bg: #ffffff;
  --row-hover: #f3f4f6;
}
@media (prefers-color-scheme: dark) {
  :root {
    --bg: #1a1a1a;
    --fg: #e5e5e5;
    --muted: #a0a0a0;
    --border: #333;
    --user: #1f4d1f;
    --user-fg: #b8e6b8;
    --row-bg: #262626;
    --row-hover: #2f2f2f;
  }
}
* { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--bg);
  color: var(--fg);
  margin: 0;
  padding: 0;
  line-height: 1.5;
}
header {
  position: sticky;
  top: 0;
  background: var(--bg);
  border-bottom: 1px solid var(--border);
  padding: 12px 16px;
  z-index: 10;
}
.meta { display: flex; gap: 12px; align-items: baseline; font-size: 13px; }
.meta strong { font-size: 15px; }
.meta span.muted { color: var(--muted); }
main { max-width: 980px; margin: 0 auto; padding: 16px; }
a.row {
  display: block;
  margin: 8px 0;
  padding: 10px 14px;
  border-radius: 10px;
  border: 1px solid var(--border);
  background: var(--row-bg);
  color: var(--fg);
  text-decoration: none;
}
a.row:hover { background: var(--row-hover); }
.row-head {
  display: flex; gap: 12px; flex-wrap: wrap; align-items: baseline;
  font-size: 13px; margin-bottom: 4px;
}
.row-id { font-family: ui-monospace, 'SF Mono', Menlo, monospace; font-weight: 600; }
.row-proj { color: var(--muted); }
.row-time { color: var(--muted); margin-left: auto; }
.row-count { color: var(--muted); }
.row-preview {
  color: var(--muted);
  font-family: ui-monospace, 'SF Mono', Menlo, monospace;
  font-size: 12px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
footer { text-align: center; padding: 24px; color: var(--muted); font-size: 12px; border-top: 1px solid var(--border); margin-top: 32px; }
</style>
</head>
<body>
<header>
  <div class="meta">
    <strong>session-viewer</strong>
    <span class="muted">{{COUNT}}</span>
  </div>
</header>
<main>
{{ROWS}}
</main>
<footer>generated by session-viewer · click a session to view</footer>
</body>
</html>
"##;
