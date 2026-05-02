use anyhow::Result;
use clap::{Parser, Subcommand};

mod data;
mod query;
mod tui;
mod web;

#[derive(Parser, Debug)]
#[command(
    name = "session-viewer",
    version,
    about = "Inspect Claude Code session logs (~/.claude/projects/*/*.jsonl) — interactive TUI, query, web export."
)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Interactive TUI (default when no subcommand is given)
    Tui,
    /// Query sessions with filters; prints summary, JSON, or raw JSONL
    Query(query::QueryArgs),
    /// Export a session as a self-contained chat-style HTML page
    Web(web::WebArgs),
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    match cli.command.unwrap_or(Commands::Tui) {
        Commands::Tui => tui::run(),
        Commands::Query(args) => query::run(args),
        Commands::Web(args) => web::run(args),
    }
}
