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
