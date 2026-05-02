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
    env,
    io::{self, Stdout},
    path::PathBuf,
};

use crate::data::{
    encode_path, load_messages, load_sessions, projects_root, truncate, Message, Session,
};

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
        push_message_lines(m, &mut lines);
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

fn role_color(role: &str) -> Color {
    match role {
        "user" => Color::Green,
        "assistant" => Color::White,
        "tool_use" => Color::Magenta,
        "tool_result" => Color::DarkGray,
        "thinking" => Color::Yellow,
        "hook" => Color::Blue,
        _ => Color::DarkGray,
    }
}

fn push_message_lines(m: &Message, out: &mut Vec<Line<'static>>) {
    let color = role_color(m.role);
    match m.role {
        "tool_use" => push_tool_use(m, color, out),
        "tool_result" => push_tool_result(m, color, out),
        "thinking" => {
            let est = m.body.len() / 4;
            out.push(Line::from(Span::styled(
                format!("── 🧠 Thinking (~{} tokens) ──", est),
                Style::default().fg(color).add_modifier(Modifier::BOLD),
            )));
            for ln in m.body.lines().take(20) {
                out.push(Line::from(Span::styled(
                    ln.to_string(),
                    Style::default().fg(color).add_modifier(Modifier::ITALIC),
                )));
            }
            if m.body.lines().count() > 20 {
                out.push(Line::from(Span::styled(
                    "… (truncated, expand in web view)".to_string(),
                    Style::default().fg(Color::DarkGray),
                )));
            }
        }
        "hook" => {
            let summary = truncate(&m.body, 140);
            out.push(Line::from(vec![
                Span::styled(
                    format!("🔗 {}", m.title),
                    Style::default().fg(color).add_modifier(Modifier::BOLD),
                ),
                Span::raw("  "),
                Span::styled(summary, Style::default().fg(Color::DarkGray)),
            ]));
        }
        "system" => {
            out.push(Line::from(Span::styled(
                format!("── 🔒 mode: {} ──", m.body),
                Style::default().fg(Color::DarkGray),
            )));
        }
        _ => {
            out.push(Line::from(Span::styled(
                format!("── {} ──", m.title),
                Style::default().fg(color).add_modifier(Modifier::BOLD),
            )));
            for ln in m.body.lines() {
                out.push(Line::from(ln.to_string()));
            }
        }
    }
}

fn push_tool_use(m: &Message, color: Color, out: &mut Vec<Line<'static>>) {
    let name = m.tool_name.as_deref().unwrap_or("?");
    let id_short: String = m
        .tool_use_id
        .as_deref()
        .unwrap_or("")
        .chars()
        .take(8)
        .collect();
    let header = Line::from(vec![
        Span::styled(
            format!("→ {}", name),
            Style::default().fg(color).add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
        Span::styled(format!("[{}]", id_short), Style::default().fg(Color::DarkGray)),
    ]);
    out.push(header);
    let input = m.input.as_ref();
    match name {
        "Bash" => render_bash_input(input, out),
        "Read" => render_read_input(input, out),
        "Edit" | "Write" => render_edit_input(name, input, out),
        "Grep" | "Glob" => render_grep_glob_input(name, input, out),
        "TodoWrite" => render_todo_input(input, out),
        "Agent" | "Task" => render_agent_input(input, out),
        "WebFetch" => render_webfetch_input(input, out),
        "WebSearch" => render_websearch_input(input, out),
        n if n.starts_with("mcp__") => render_mcp_input(n, input, out),
        _ => {
            // generic: pretty-print first 8 lines
            for ln in m.body.lines().take(8) {
                out.push(Line::from(ln.to_string()));
            }
            if m.body.lines().count() > 8 {
                out.push(Line::from(Span::styled(
                    "… (truncated)",
                    Style::default().fg(Color::DarkGray),
                )));
            }
        }
    }
}

fn render_bash_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    if let Some(d) = v.get("description").and_then(|s| s.as_str()) {
        out.push(Line::from(Span::styled(
            format!("  # {}", d),
            Style::default().fg(Color::DarkGray).add_modifier(Modifier::ITALIC),
        )));
    }
    if let Some(c) = v.get("command").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  $ ", Style::default().fg(Color::Green)),
            Span::raw(c.to_string()),
        ]));
    }
    if v.get("run_in_background").and_then(|b| b.as_bool()) == Some(true) {
        out.push(Line::from(Span::styled(
            "  [background]",
            Style::default().fg(Color::Yellow),
        )));
    }
}

fn render_read_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    let path = v
        .get("file_path")
        .and_then(|s| s.as_str())
        .unwrap_or("(no path)");
    let off = v.get("offset").and_then(|n| n.as_i64());
    let lim = v.get("limit").and_then(|n| n.as_i64());
    let line_ref = match (off, lim) {
        (Some(o), Some(l)) => format!("L{}–{}", o, o + l - 1),
        (Some(o), None) => format!("L{}–", o),
        (None, Some(l)) => format!("first {} lines", l),
        _ => String::new(),
    };
    out.push(Line::from(vec![
        Span::styled("  📄 ", Style::default().fg(Color::Cyan)),
        Span::styled(path.to_string(), Style::default().fg(Color::Blue)),
        Span::raw("  "),
        Span::styled(line_ref, Style::default().fg(Color::DarkGray)),
    ]));
}

fn render_edit_input(name: &str, input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    let path = v
        .get("file_path")
        .and_then(|s| s.as_str())
        .unwrap_or("(no path)");
    out.push(Line::from(vec![
        Span::styled("  ✎ ", Style::default().fg(Color::Magenta)),
        Span::styled(path.to_string(), Style::default().fg(Color::Blue)),
        Span::raw("  "),
        Span::styled(
            if name == "Write" { "[new]" } else { "[edit]" },
            Style::default().fg(Color::DarkGray),
        ),
    ]));
    if name == "Edit" {
        if let Some(s) = v.get("old_string").and_then(|s| s.as_str()) {
            for ln in s.lines().take(5) {
                out.push(Line::from(Span::styled(
                    format!("  - {}", ln),
                    Style::default().fg(Color::Red),
                )));
            }
            if s.lines().count() > 5 {
                out.push(Line::from(Span::styled(
                    "  - … (truncated)",
                    Style::default().fg(Color::DarkGray),
                )));
            }
        }
        if let Some(s) = v.get("new_string").and_then(|s| s.as_str()) {
            for ln in s.lines().take(5) {
                out.push(Line::from(Span::styled(
                    format!("  + {}", ln),
                    Style::default().fg(Color::Green),
                )));
            }
            if s.lines().count() > 5 {
                out.push(Line::from(Span::styled(
                    "  + … (truncated)",
                    Style::default().fg(Color::DarkGray),
                )));
            }
        }
    }
}

fn render_grep_glob_input(_name: &str, input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    if let Some(p) = v.get("pattern").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  pattern  ", Style::default().fg(Color::DarkGray)),
            Span::styled(p.to_string(), Style::default().fg(Color::Yellow)),
        ]));
    }
    if let Some(p) = v.get("path").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  path     ", Style::default().fg(Color::DarkGray)),
            Span::styled(p.to_string(), Style::default().fg(Color::Blue)),
        ]));
    }
    if let Some(p) = v.get("glob").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  glob     ", Style::default().fg(Color::DarkGray)),
            Span::styled(p.to_string(), Style::default().fg(Color::Yellow)),
        ]));
    }
    if let Some(p) = v.get("type").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  type     ", Style::default().fg(Color::DarkGray)),
            Span::styled(p.to_string(), Style::default().fg(Color::Yellow)),
        ]));
    }
}

fn render_todo_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    let todos = match v.get("todos").and_then(|t| t.as_array()) {
        Some(a) => a,
        None => return,
    };
    for t in todos {
        let status = t.get("status").and_then(|s| s.as_str()).unwrap_or("pending");
        let content = t.get("content").and_then(|s| s.as_str()).unwrap_or("");
        let active = t.get("activeForm").and_then(|s| s.as_str()).unwrap_or("");
        let mark = match status {
            "completed" => "☑",
            "in_progress" => "▣",
            _ => "☐",
        };
        let color = match status {
            "completed" => Color::DarkGray,
            "in_progress" => Color::Green,
            _ => Color::Gray,
        };
        let label = if status == "in_progress" && !active.is_empty() {
            active
        } else {
            content
        };
        out.push(Line::from(vec![
            Span::styled(format!("  {} ", mark), Style::default().fg(color)),
            Span::styled(label.to_string(), Style::default().fg(color)),
        ]));
    }
}

fn render_agent_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    let st = v
        .get("subagent_type")
        .and_then(|s| s.as_str())
        .unwrap_or("general-purpose");
    let desc = v.get("description").and_then(|s| s.as_str()).unwrap_or("");
    out.push(Line::from(vec![
        Span::styled("  🤖 ", Style::default().fg(Color::Cyan)),
        Span::styled(
            st.to_string(),
            Style::default().fg(Color::Magenta).add_modifier(Modifier::BOLD),
        ),
        Span::raw("  "),
        Span::styled(desc.to_string(), Style::default().fg(Color::White)),
    ]));
}

fn render_webfetch_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    if let Some(u) = v.get("url").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  🌐 ", Style::default().fg(Color::Cyan)),
            Span::styled(u.to_string(), Style::default().fg(Color::Blue)),
        ]));
    }
    if let Some(p) = v.get("prompt").and_then(|s| s.as_str()) {
        out.push(Line::from(Span::styled(
            format!("  prompt: {}", truncate(p, 100)),
            Style::default().fg(Color::DarkGray),
        )));
    }
}

fn render_websearch_input(input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let v = match input {
        Some(v) => v,
        None => return,
    };
    if let Some(q) = v.get("query").and_then(|s| s.as_str()) {
        out.push(Line::from(vec![
            Span::styled("  🔎 ", Style::default().fg(Color::Cyan)),
            Span::styled(q.to_string(), Style::default().fg(Color::Yellow)),
        ]));
    }
}

fn render_mcp_input(name: &str, input: Option<&Value>, out: &mut Vec<Line<'static>>) {
    let stripped = name.strip_prefix("mcp__").unwrap_or(name);
    let (server, tool) = match stripped.rfind("__") {
        Some(idx) => (&stripped[..idx], &stripped[idx + 2..]),
        None => (stripped, ""),
    };
    out.push(Line::from(vec![
        Span::styled("  🔌 ", Style::default().fg(Color::Cyan)),
        Span::styled(
            server.to_string(),
            Style::default().fg(Color::Magenta).add_modifier(Modifier::BOLD),
        ),
        Span::raw(" / "),
        Span::styled(tool.to_string(), Style::default().fg(Color::Yellow)),
    ]));
    if let Some(v) = input.and_then(|i| i.as_object()) {
        for (k, val) in v.iter().take(6) {
            let val_str = match val {
                Value::String(s) => s.clone(),
                _ => val.to_string(),
            };
            out.push(Line::from(vec![
                Span::styled(format!("    {}: ", k), Style::default().fg(Color::DarkGray)),
                Span::raw(truncate(&val_str, 100)),
            ]));
        }
    }
}

fn push_tool_result(m: &Message, color: Color, out: &mut Vec<Line<'static>>) {
    let tn = m.tool_name.as_deref().unwrap_or("?");
    let id_short: String = m
        .tool_use_id
        .as_deref()
        .unwrap_or("")
        .chars()
        .take(8)
        .collect();
    let mut header_spans = vec![
        Span::styled(
            "↳ result ",
            Style::default().fg(color).add_modifier(Modifier::BOLD),
        ),
        Span::styled(format!("[{}]", tn), Style::default().fg(Color::Magenta)),
        Span::raw("  "),
        Span::styled(format!("[{}]", id_short), Style::default().fg(Color::DarkGray)),
    ];
    if m.is_error {
        header_spans.insert(
            0,
            Span::styled(
                "⚠ ",
                Style::default()
                    .fg(Color::Red)
                    .add_modifier(Modifier::BOLD),
            ),
        );
    }
    out.push(Line::from(header_spans));

    let body_color = if m.is_error { Color::Red } else { Color::Gray };
    // For Grep result, group by file path
    if tn == "Grep" {
        for ln in m.body.lines().take(20) {
            if let Some((file, rest)) = ln.split_once(':') {
                if let Some((line_no, text)) = rest.split_once(':') {
                    out.push(Line::from(vec![
                        Span::styled(file.to_string(), Style::default().fg(Color::Blue)),
                        Span::raw(":"),
                        Span::styled(line_no.to_string(), Style::default().fg(Color::Yellow)),
                        Span::raw(" │ "),
                        Span::styled(text.to_string(), Style::default().fg(body_color)),
                    ]));
                    continue;
                }
            }
            out.push(Line::from(Span::styled(
                ln.to_string(),
                Style::default().fg(body_color),
            )));
        }
    } else {
        for ln in m.body.lines().take(20) {
            out.push(Line::from(Span::styled(
                ln.to_string(),
                Style::default().fg(body_color),
            )));
        }
    }
    if m.body.lines().count() > 20 {
        out.push(Line::from(Span::styled(
            "… (truncated, view full in web mode)",
            Style::default().fg(Color::DarkGray),
        )));
    }
}

fn shorten(s: &str, max: usize) -> String {
    let n = s.chars().count();
    if n <= max {
        return s.to_string();
    }
    let tail: String = s.chars().skip(n.saturating_sub(max - 1)).collect();
    format!("…{}", tail)
}

pub fn run() -> Result<()> {
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
