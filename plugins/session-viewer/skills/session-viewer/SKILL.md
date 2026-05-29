---
name: session-viewer
description: Browse Claude Code session logs in a TUI. Use on requests like "세션 로그 보기", "session viewer", "세션 뷰어", "claude code 로그 TUI", "이전 대화 보기", "내 세션 목록", "지난 세션 검토", "로그 인터랙티브 보기". Toggles between all-project sessions and sessions matching the current working directory.
argument-hint: "[--rebuild: rebuild the binary]"
allowed-tools:
  - Bash
---

# Session Viewer

Browse the session logs Claude Code writes to `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl` in a ratatui-based interactive TUI. Provides a two-stage view (session list → session detail with messages + tool calls), and toggles between all-project sessions and sessions matching the current cwd.

## When to use

Use this skill for requests like:

- "Show me the sessions I worked on" / "Open a previous session"
- "I want to view Claude Code logs in a TUI"
- "I want to revisit the sessions I worked on today"
- "I want to review how the tool-call flow went"
- "Let me pick out only the conversations from this project"

## Quick start

The TUI uses alternate screen + raw mode, so it must be run directly in a separate terminal app (Terminal.app / iTerm2 / WezTerm, etc.). Neither Claude Code's Bash tool nor the `!`-prefix shell mode provides a raw-mode TTY, so it exits with `Error: Device not configured (os error 6)`.

Use the path that matches your environment:

```bash
# 1. Claude Code skill context (variable expanded inside SKILL.md)
${CLAUDE_PLUGIN_ROOT}/skills/session-viewer/bin/launch.sh

# 2. Marketplace source (for dev/test; usable even before plugin sync)
~/.claude/plugins/marketplaces/oozoofrog-plugins/plugins/session-viewer/skills/session-viewer/bin/launch.sh

# 3. Installed cache path (after plugin enable + sync)
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh
```

`launch.sh` detects the host OS/arch and works in this order:

1. Run the prebuilt `bin/session-viewer-<os>-<arch>` binary if present
2. Otherwise build it on the fly from `src/` with `cargo build --release` and cache it
3. If cargo is missing, print an error and exit with code 127

Currently bundled binary: `bin/session-viewer-darwin-arm64` (Mach-O 64-bit, ~1.8MB; clap + regex + tiny_http + 3 subcommands + context-first UI renderer).

## Key bindings

### List view (session list)

| Key | Action |
|---|---|
| `↑` / `↓` (or `k` / `j`) | Move one line |
| `PgUp` / `PgDn` | Page by 10 lines |
| `g` / `G` | To start / end |
| `Enter` | View detail of selected session |
| `t` | **Toggle: ALL ↔ CWD** (show only sessions matching the current cwd) |
| `q` or `Ctrl-C` | Quit |

Each row format:

```
[●] MM-DD HH:MM   <msg count>   <project label>   <first user prompt preview>
```

The `●` mark means the session was started in the current cwd (also shown in ALL mode).

### Detail view (session detail)

| Key | Action |
|---|---|
| `↑` / `↓` (or `k` / `j`) | Scroll one line |
| `PgUp` / `PgDn` | Scroll 20 lines |
| `g` / `G` | To top / bottom |
| `Esc` / `q` / `Backspace` | Return to the list |

The detail view renders the following events in JSONL time order in a per-tool context format (v0.4.0+):

- 🟢 **User** (green) — user prompt (noise such as system-reminders is auto-filtered)
- ⚪ **Assistant** (white) — assistant response text
- 🟣 **Tool use** (magenta) — dedicated rendering per tool name:
  - `Bash` → `$ command` + description comment
  - `Read` → `📄 path L120-180` (line range)
  - `Edit`/`Write` → ± diff
  - `Grep`/`Glob` → pattern + path/glob/type keys
  - `TodoWrite` → ☐ ▣ ☑ checklist
  - `Agent`/`Task` → 🤖 subagent name badge
  - `WebFetch` → 🌐 URL · `WebSearch` → 🔎 query
  - `mcp__server__tool` → 🔌 server / tool shown separately
  - others → generic key-value
- ⚫ **Tool result** (dark gray) — shown with the paired tool name:
  - `Grep` results grouped as `path:line │ text`
  - `Bash` results get an exit code badge (red if ≠ 0)
  - errors get a red bar + badge
- 🟡 **Thinking** (yellow) — `🧠 ~N tokens` header, long body collapsed
- 🔵 **Hook** (blue) — single-line strip (event name badge + body preview)
- gray **system** — `🔒 mode: ...` line (separated by a thin dotted rule)

## Data source

### Directory structure

```
~/.claude/projects/
├── -Users-oozoofrog/                    # cwd: /Users/oozoofrog
│   ├── <session-uuid-1>.jsonl
│   └── <session-uuid-2>.jsonl
└── -Volumes-eyedisk-develop-kakao-talk/ # cwd: /Volumes/eyedisk/develop/kakao-talk
    └── <session-uuid-3>.jsonl
```

The directory name is the cwd with both `/` and `.` replaced by `-` (see `references/jsonl-schema.md` for the exact rules).

### JSONL line types

Each line is a single JSON object; the main `type` values:

- `user` — `message.content` is a string or `[{type:"text"|"tool_result", ...}]`
- `assistant` — `message.content` is `[{type:"text"|"tool_use"|"thinking", ...}]`
- `permission-mode` — `permissionMode` value change
- other hook events appear in the `attachment` field

The full schema is documented in `references/jsonl-schema.md`.

## CWD matching rules

When toggling ALL/CWD with `t`, the current working directory is encoded with the following rule and compared against directory names:

```
encode(p) = p.replace('/', '-').replace('.', '-')
```

Example: `/Users/oozoofrog` → `-Users-oozoofrog`. `/Users/foo/blog/site.io/.claude/x` → `-Users-foo-blog-site-io--claude-x` (the boundary `/.` becomes `--`).

This encoding is lossy (e.g. a `kakao-talk` directory and a `kakao.talk` directory are indistinguishable), so edge cases exist. Common cases match exactly.

## User flow

1. The user asks something like "I want to view session logs"
2. Claude guides the user to:
   - explicitly open a separate terminal app (Terminal.app / iTerm2 / WezTerm, etc.)
   - provide the absolute path of the launcher to paste into that terminal (e.g. `~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh`)
3. The user runs the TUI in the separate terminal → browses → exits
4. After exiting, the user does follow-up work in the Claude Code session based on what they saw (e.g. "re-analyze the X part of that session")

Respond to the user in Korean.

**Why it must be a separate terminal**: the TUI uses alternate screen + raw mode + a non-blocking event loop. Inside Claude Code, both the Bash tool and the `!`-prefix shell mode use a stdout capture/pipe model that cannot provide a raw-mode TTY, so `enable_raw_mode()` fails immediately with ENXIO (`Error: Device not configured`, os error 6). This is not a workaround-able constraint but a shared limitation of all shell-execution paths in Claude Code.

## When a rebuild is needed

Rebuild from `src/` in these situations:

- the user is on a non-darwin-arm64 environment (Linux, Intel Mac)
- after editing `src/main.rs`
- the prebuilt binary is corrupted

Manual rebuild:

```bash
cd ${CLAUDE_PLUGIN_ROOT}/skills/session-viewer/src
cargo build --release
cp target/release/session-viewer ../bin/session-viewer-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
```

Or `launch.sh` builds and caches automatically (just needs cargo on PATH).

## Directory layout

```
session-viewer/
├── SKILL.md                      # this file (lean: triggers + usage + key bindings)
├── bin/
│   ├── launch.sh                 # OS/arch detection + auto-build fallback
│   └── session-viewer-darwin-arm64
├── references/
│   └── jsonl-schema.md           # detailed schema of JSONL line types
└── src/
    ├── Cargo.toml
    ├── Cargo.lock
    └── src/
        ├── main.rs               # clap dispatcher
        ├── data.rs               # JSONL parsing + Session/Message types (shared)
        ├── tui.rs                # ratatui + crossterm TUI
        ├── query.rs              # filter + text/JSON/JSONL output
        └── web.rs                # single self-contained HTML export
```

## Subcommands (v0.2.0+)

`session-viewer` is a single binary with 3 subcommands:

| Subcommand | Purpose | TTY needed? |
|---|---|---|
| `tui` (default) | Interactive TUI browsing | Yes (separate terminal) |
| `query` | Filter-based CLI lookup | No |
| `web <id>` | Export a single session to self-contained HTML | No |

`query` and `web` do not use raw mode, so they can run via the Bash tool inside Claude Code. Only the TUI needs a separate terminal.

### `query` — filter-based lookup

```bash
session-viewer query [OPTIONS]

# Filters
--since <WHEN>      # "2d", "1h", "1w", "2026-05-01" (RFC3339 also OK)
--until <WHEN>
--cwd               # only sessions started in the current working directory
--project <PATTERN> # substring of project label / encoded dir name
--tool <REGEX>      # regex on called tool names (e.g. 'Bash|Read')
--text <STRING>     # substring in user/assistant/tool_result body
--regex <REGEX>     # regex match in the same body

# Output format
--format summary    # human-readable one-line summary (default)
--format json       # array of matched session metadata
--format jsonl      # matched raw JSONL lines (or one metadata line per session)
```

**Examples:**

```bash
# Pipe raw lines of sessions that called Bash or Read in the last 1 day into jq
session-viewer query --since 1d --tool 'Bash|Read' --format jsonl | jq .

# Summarize only sessions in the current project that mention "ratatui"
session-viewer query --cwd --text ratatui

# All sessions within 6 hours as JSON → for use in scripts
session-viewer query --since 6h --format json
```

### `web` — static HTML export or live HTTP server

```bash
# Mode 1: static HTML export of a single session
session-viewer web <SESSION_ID> [-o OUTPUT]

# Mode 2: live browsing of all sessions (v0.3.0+)
session-viewer web --serve [--port 7878] [--host 127.0.0.1] [--no-open]
```

**Mode 1 — Static HTML export:**

- `<SESSION_ID>`: full UUID or a unique prefix (e.g. `0532f5f4`). If ambiguous, candidates are printed and it exits.
- `-o, --output <PATH>`: output file. Defaults to stdout if omitted.

```bash
# Export a session to a single self-contained HTML, then open it in the browser
session-viewer web 0532f5f4 -o /tmp/session.html
open /tmp/session.html
```

**Mode 2 — Local HTTP server (v0.3.0):**

- `--serve`: start a tiny_http-based single-threaded server. Default `127.0.0.1:7878`.
- `--port N`, `--host ADDR`: change the bind
- `--no-open`: disable auto-opening the browser (default calls macOS `open` / Linux `xdg-open`)
- Exit: `Ctrl+C`

Routes:

| Route | Response |
|---|---|
| `GET /` | Index page of all sessions (reverse chronological, click to go to detail) |
| `GET /session/<id>` | Single-session chat view (UUID or prefix) — "← back to index" link at top |
| `GET /api/sessions.json` | JSON array of session metadata (id, project_label, modified, msg_count, first_user_text) |
| `GET /api/session/<id>.json` | Full data of a single session ({meta, messages}) |
| Other | 404 plain text |

```bash
# Live mode — browse all sessions
session-viewer web --serve
# → listening on http://127.0.0.1:7878
# → browser auto-opens, index → click a session → chat view
```

The session list is rescanned on every request, so a newly created session shows up immediately on refresh (live browsing while working in Claude Code).

**HTML viewer features (common to both modes, v0.4.0+ context-first UI):**
- chat-style UI (user/assistant bubbles)
- **per-tool dedicated renderers**: Bash shell card, Read file link, Edit diff, Grep file-grouped, TodoWrite checklist, Agent badge, MCP `server / tool` split, etc.
- **tool_use ↔ tool_result visual pairing**: same-color left bar + reduced margin
- **error highlight**: `is_error: true` results get a red bar + `error` badge
- `/` key focuses search, with a **regex toggle button** (`.*`)
- **role chip filter** (All/User/Assistant/Tool/Result/Thinking/Hook)
- **per-tool dynamic chip filter**: only the tools called in that session, auto-shown ordered by usage frequency
- auto dark-mode detection (`prefers-color-scheme`)
- long tool input/result/thinking are collapsed (`▶ click to expand`)
- raw JSON is accessible via `<details>` (for reconstruction/debugging)
- clean mobile layout
- Static mode: zero runtime, works offline, shareable via email/Slack
- Serve mode: browse all sessions + live refresh (only while the server runs)

### Quick start (non-TUI commands)

```bash
# query/web can also be run via launch.sh (just append the arguments)
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh query --since 1d
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh web 0532f5f4 -o /tmp/x.html
```

## Dependencies

- **Rust** ≥ 1.74 (for rebuilds) — install via `rustup`
- **macOS arm64** (prebuilt binary) — Apple Silicon
- **Terminal** — alternate screen + 256 colors + UTF-8 support (Terminal.app, iTerm2, WezTerm all OK)

No runtime dependencies (static binary).

## Known limitations

- Very large session files (>100MB) may be slow on the first screen load — the whole file is scanned once to extract the first user prompt
- A very long single message wraps only within the render width in the detail view, with outer scrolling applied (`Wrap { trim: false }`)
- CWD matching is based on lossy encoding, so false positives are possible for paths containing a dot (rarely happens in practice)

## Further reading

See `references/jsonl-schema.md` for the detailed JSONL schema and event types.
