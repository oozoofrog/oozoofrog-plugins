use anyhow::{Context, Result};
use chrono::{DateTime, Local};
use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind, KeyModifiers},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style, Stylize},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap},
    Frame, Terminal,
};
use serde_json::Value;
use std::{
    env, fs,
    io::{self, BufRead, BufReader, Stdout},
    path::{Path, PathBuf},
    time::SystemTime,
};

// ---------------- data ----------------

#[derive(Clone)]
struct Session {
    id: String,
    file_path: PathBuf,
    project_label: String,
    modified: SystemTime,
    first_user_text: String,
    msg_count: usize,
    matches_cwd: bool,
}

struct Message {
    role: &'static str,
    title: String,
    body: String,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum Mode {
    All,
    Cwd,
}

enum View {
    List,
    Detail(DetailState),
}

struct DetailState {
    session_idx: usize,
    messages: Vec<Message>,
    scroll: u16,
}

struct App {
    sessions: Vec<Session>,
    visible: Vec<usize>,
    list_state: ListState,
    view: View,
    mode: Mode,
    cwd_encoded: String,
}

// ---------------- encoding ----------------

fn encode_path(p: &Path) -> String {
    p.to_string_lossy()
        .chars()
        .map(|c| if c == '/' || c == '.' { '-' } else { c })
        .collect()
}

fn projects_root() -> Option<PathBuf> {
    dirs::home_dir().map(|h| h.join(".claude/projects"))
}

fn pretty_project(encoded: &str) -> String {
    let trimmed = encoded.trim_start_matches('-');
    let parts: Vec<&str> = trimmed.split('-').filter(|s| !s.is_empty()).collect();
    if parts.len() <= 3 {
        return trimmed.replace('-', "/");
    }
    let tail: Vec<&str> = parts.iter().rev().take(3).rev().copied().collect();
    format!("…/{}", tail.join("/"))
}

fn truncate(s: &str, max: usize) -> String {
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

fn is_system_noise(s: &str) -> bool {
    let t = s.trim_start();
    t.starts_with("<system-reminder>")
        || t.starts_with("<command-message>")
        || t.starts_with("<command-name>")
        || t.starts_with("<command-args>")
        || t.starts_with("<local-command-stdout>")
}

// ---------------- session loading ----------------

fn load_sessions(root: &Path, cwd_encoded: &str) -> Result<Vec<Session>> {
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

fn quick_scan(path: &Path) -> Result<(String, usize)> {
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

fn extract_user_text(v: &Value) -> Option<String> {
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

// ---------------- detail loading ----------------

fn load_messages(path: &Path) -> Result<Vec<Message>> {
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

// ---------------- app ----------------

impl App {
    fn new() -> Result<Self> {
        let cwd = env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        let cwd_encoded = encode_path(&cwd);
        let root = projects_root().context("home directory not found")?;
        let sessions = load_sessions(&root, &cwd_encoded).unwrap_or_default();
        let mut app = Self {
            sessions,
            visible: Vec::new(),
            list_state: ListState::default(),
            view: View::List,
            mode: Mode::All,
            cwd_encoded,
        };
        app.refilter();
        Ok(app)
    }

    fn refilter(&mut self) {
        self.visible = self
            .sessions
            .iter()
            .enumerate()
            .filter(|(_, s)| matches!(self.mode, Mode::All) || s.matches_cwd)
            .map(|(i, _)| i)
            .collect();
        let pos = if self.visible.is_empty() { None } else { Some(0) };
        self.list_state.select(pos);
    }

    fn enter_detail(&mut self) -> Result<()> {
        let i = match self.list_state.selected() {
            Some(i) => i,
            None => return Ok(()),
        };
        if i >= self.visible.len() {
            return Ok(());
        }
        let sidx = self.visible[i];
        let msgs = load_messages(&self.sessions[sidx].file_path).unwrap_or_default();
        self.view = View::Detail(DetailState {
            session_idx: sidx,
            messages: msgs,
            scroll: 0,
        });
        Ok(())
    }
}

// ---------------- ui ----------------

fn ui(f: &mut Frame, app: &mut App) {
    match &app.view {
        View::List => render_list(f, app),
        View::Detail(_) => render_detail(f, app),
    }
}

fn render_list(f: &mut Frame, app: &mut App) {
    let area = f.area();
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2),
            Constraint::Min(1),
            Constraint::Length(1),
        ])
        .split(area);

    let mode_str = match app.mode {
        Mode::All => "ALL",
        Mode::Cwd => "CWD",
    };
    let header_line = Line::from(vec![
        Span::styled(
            "Claude Code Session Viewer",
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
        Span::styled(
            format!(
                "[mode: {}] [cwd: {}] [{} sessions]",
                mode_str,
                shorten(&app.cwd_encoded, 40),
                app.visible.len()
            ),
            Style::default().fg(Color::DarkGray),
        ),
    ]);
    let header = Paragraph::new(header_line).block(Block::default().borders(Borders::BOTTOM));
    f.render_widget(header, chunks[0]);

    if app.visible.is_empty() {
        let hint = match app.mode {
            Mode::All => {
                "No sessions found in ~/.claude/projects/.\nClaude Code may not have logged any session yet."
            }
            Mode::Cwd => {
                "No sessions match the current working directory.\nPress 't' to view ALL sessions across projects."
            }
        };
        let placeholder = Paragraph::new(hint)
            .block(Block::default().borders(Borders::ALL).title(" sessions "))
            .style(Style::default().fg(Color::DarkGray))
            .wrap(Wrap { trim: false });
        f.render_widget(placeholder, chunks[1]);
    } else {
        let items: Vec<ListItem> = app
            .visible
            .iter()
            .map(|&i| {
                let s = &app.sessions[i];
                let dt: DateTime<Local> = s.modified.into();
                let when = dt.format("%m-%d %H:%M").to_string();
                let preview = if s.first_user_text.is_empty() {
                    "(no user message)".to_string()
                } else {
                    s.first_user_text.clone()
                };
                let mark = if s.matches_cwd { "● " } else { "  " };
                let line = Line::from(vec![
                    Span::styled(mark, Style::default().fg(Color::Green)),
                    Span::styled(when, Style::default().fg(Color::Yellow)),
                    Span::raw("  "),
                    Span::styled(format!("{:>4}", s.msg_count), Style::default().fg(Color::Green)),
                    Span::raw("  "),
                    Span::styled(
                        truncate(&s.project_label, 32),
                        Style::default().fg(Color::Blue),
                    ),
                    Span::raw("  "),
                    Span::raw(truncate(&preview, 90)),
                ]);
                ListItem::new(line)
            })
            .collect();

        let list = List::new(items)
            .block(Block::default().borders(Borders::ALL).title(" sessions "))
            .highlight_style(Style::default().add_modifier(Modifier::REVERSED))
            .highlight_symbol("▸ ");
        f.render_stateful_widget(list, chunks[1], &mut app.list_state);
    }

    let help = Paragraph::new(Line::from(vec![
        "↑/↓ k/j".cyan(),
        Span::raw(" navigate  "),
        "Enter".cyan(),
        Span::raw(" open  "),
        "t".cyan(),
        Span::raw(" toggle ALL/CWD  "),
        "g/G".cyan(),
        Span::raw(" top/bottom  "),
        "q".cyan(),
        Span::raw(" quit"),
    ]));
    f.render_widget(help, chunks[2]);
}

fn render_detail(f: &mut Frame, app: &mut App) {
    let area = f.area();
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(2),
            Constraint::Min(1),
            Constraint::Length(1),
        ])
        .split(area);

    let detail = match &app.view {
        View::Detail(d) => d,
        _ => return,
    };
    let s = &app.sessions[detail.session_idx];

    let id_short: String = s.id.chars().take(8).collect();
    let header_line = Line::from(vec![
        Span::styled(
            format!("Session {}", id_short),
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
        Span::styled(s.project_label.clone(), Style::default().fg(Color::Blue)),
        Span::raw("  "),
        Span::styled(
            format!("({} events)", detail.messages.len()),
            Style::default().fg(Color::DarkGray),
        ),
    ]);
    let header = Paragraph::new(header_line).block(Block::default().borders(Borders::BOTTOM));
    f.render_widget(header, chunks[0]);

    let mut lines: Vec<Line> = Vec::new();
    for m in &detail.messages {
        let color = match m.role {
            "user" => Color::Green,
            "assistant" => Color::White,
            "tool_use" => Color::Magenta,
            "tool_result" => Color::DarkGray,
            "thinking" => Color::Yellow,
            "hook" => Color::Blue,
            _ => Color::DarkGray,
        };
        lines.push(Line::from(Span::styled(
            format!("── {} ──", m.title),
            Style::default().fg(color).add_modifier(Modifier::BOLD),
        )));
        for ln in m.body.lines() {
            lines.push(Line::from(ln.to_string()));
        }
        lines.push(Line::from(""));
    }

    let para = Paragraph::new(lines)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(format!(" detail [{}] ", s.id)),
        )
        .wrap(Wrap { trim: false })
        .scroll((detail.scroll, 0));
    f.render_widget(para, chunks[1]);

    let help = Paragraph::new(Line::from(vec![
        "↑/↓ j/k".cyan(),
        Span::raw(" scroll  "),
        "PgUp/PgDn".cyan(),
        Span::raw(" page  "),
        "g/G".cyan(),
        Span::raw(" top/bottom  "),
        "Esc/q".cyan(),
        Span::raw(" back"),
    ]));
    f.render_widget(help, chunks[2]);
}

fn shorten(s: &str, max: usize) -> String {
    let n = s.chars().count();
    if n <= max {
        return s.to_string();
    }
    let tail: String = s.chars().skip(n.saturating_sub(max - 1)).collect();
    format!("…{}", tail)
}

// ---------------- main loop ----------------

fn run() -> Result<()> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new()?;
    let result = event_loop(&mut terminal, &mut app);

    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;
    result
}

fn event_loop(
    terminal: &mut Terminal<CrosstermBackend<Stdout>>,
    app: &mut App,
) -> Result<()> {
    loop {
        terminal.draw(|f| ui(f, app))?;
        if let Event::Key(key) = event::read()? {
            if key.kind != KeyEventKind::Press {
                continue;
            }
            if key.code == KeyCode::Char('c') && key.modifiers.contains(KeyModifiers::CONTROL) {
                return Ok(());
            }
            match &mut app.view {
                View::List => match key.code {
                    KeyCode::Char('q') => return Ok(()),
                    KeyCode::Char('t') => {
                        app.mode = match app.mode {
                            Mode::All => Mode::Cwd,
                            Mode::Cwd => Mode::All,
                        };
                        app.refilter();
                    }
                    KeyCode::Down | KeyCode::Char('j') => {
                        move_list(&mut app.list_state, app.visible.len(), 1)
                    }
                    KeyCode::Up | KeyCode::Char('k') => {
                        move_list(&mut app.list_state, app.visible.len(), -1)
                    }
                    KeyCode::PageDown => move_list(&mut app.list_state, app.visible.len(), 10),
                    KeyCode::PageUp => move_list(&mut app.list_state, app.visible.len(), -10),
                    KeyCode::Char('g') => app.list_state.select(if app.visible.is_empty() {
                        None
                    } else {
                        Some(0)
                    }),
                    KeyCode::Char('G') => {
                        let last = if app.visible.is_empty() {
                            None
                        } else {
                            Some(app.visible.len() - 1)
                        };
                        app.list_state.select(last);
                    }
                    KeyCode::Enter => app.enter_detail()?,
                    _ => {}
                },
                View::Detail(d) => match key.code {
                    KeyCode::Esc | KeyCode::Char('q') | KeyCode::Backspace => {
                        app.view = View::List
                    }
                    KeyCode::Down | KeyCode::Char('j') => d.scroll = d.scroll.saturating_add(1),
                    KeyCode::Up | KeyCode::Char('k') => d.scroll = d.scroll.saturating_sub(1),
                    KeyCode::PageDown => d.scroll = d.scroll.saturating_add(20),
                    KeyCode::PageUp => d.scroll = d.scroll.saturating_sub(20),
                    KeyCode::Char('g') => d.scroll = 0,
                    KeyCode::Char('G') => d.scroll = u16::MAX / 2,
                    _ => {}
                },
            }
        }
    }
}

fn move_list(state: &mut ListState, len: usize, delta: i32) {
    if len == 0 {
        state.select(None);
        return;
    }
    let cur = state.selected().unwrap_or(0) as i32;
    let mut next = cur + delta;
    if next < 0 {
        next = 0;
    }
    if next >= len as i32 {
        next = len as i32 - 1;
    }
    state.select(Some(next as usize));
}

fn main() -> Result<()> {
    run()
}
