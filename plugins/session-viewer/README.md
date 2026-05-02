# session-viewer

Claude Code 세션 로그(`~/.claude/projects/*/*.jsonl`)를 인터랙티브 TUI로 탐색하는 플러그인.

## 무엇을 하나

Claude Code는 모든 대화 세션을 작업 디렉토리별로 인코딩된 디렉토리 아래 JSONL 파일로 저장한다. 이 플러그인은 그 로그를 다양한 형태로 탐색할 수 있게 한다:

- **TUI** (ratatui) — 세션 목록 + 도구별 맥락 표시 상세 뷰
- **CLI 쿼리** (`query`) — 시간/cwd/도구/regex 필터, JSON/JSONL 출력
- **Web 모드** (`web`) — 단일 세션 static HTML export 또는 `--serve`로 라이브 HTTP 서버

### v0.4.0 — 맥락 우선 UI

raw JSON 대신 **도구 이름별 전용 렌더러**로 표시:

- `Bash` → `$ command` 셸 카드 + description
- `Read` → `📄 path L120-180`
- `Edit`/`Write` → ± diff
- `Grep` → file 그룹 + `path:line │ text`
- `TodoWrite` → ☐ ▣ ☑ 체크리스트
- `Agent` → 🤖 subagent 배지
- `mcp__server__tool` → 🔌 server / tool 분리
- tool_use ↔ tool_result 시각 페어링, 에러는 빨간 막대
- web 모드: per-tool 동적 chip 필터 + regex 검색 토글

## 빠른 시작

스킬 디렉토리의 launcher를 직접 실행한다:

```bash
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh
```

또는 Claude Code 내에서 "세션 로그 보고 싶다" / "session viewer" / "이전 대화 보기" 등으로 요청하면 스킬이 발화되어 launcher 경로를 안내한다.

> **주의:** TUI는 alternate screen + raw mode를 사용하므로 Claude Code의 Bash 도구 안에서는 정상 동작하지 않는다. 별도 터미널에서 실행해야 한다.

## 키 바인딩

### List view
| 키 | 동작 |
|---|---|
| `↑` `↓` (`k` `j`) | 이동 |
| `Enter` | 선택 세션 상세 보기 |
| `t` | ALL ↔ CWD 토글 |
| `g` `G` | 처음/끝 |
| `q` `Ctrl-C` | 종료 |

### Detail view
| 키 | 동작 |
|---|---|
| `↑` `↓` (`k` `j`) | 한 줄 스크롤 |
| `PgUp` `PgDn` | 페이지 |
| `g` `G` | 맨 위/맨 아래 |
| `Esc` `q` `Backspace` | 목록으로 |

## 구조

```
session-viewer/
├── .claude-plugin/plugin.json
└── skills/session-viewer/
    ├── SKILL.md
    ├── bin/{launch.sh, session-viewer-darwin-arm64}
    ├── references/jsonl-schema.md
    └── src/{Cargo.toml, src/main.rs}    # Rust + ratatui + crossterm
```

## 의존성

- 사전 빌드: macOS arm64 (Apple Silicon)
- 다른 플랫폼: `launch.sh`가 호스트에서 cargo로 자동 빌드 (Rust ≥ 1.74 필요)

## 설치

`~/.claude/settings.json`의 `enabledPlugins`에 등록:

```json
"session-viewer@oozoofrog-plugins": true
```

또는 Claude Code에서 `/plugin install session-viewer@oozoofrog-plugins`.

## 라이선스

MIT (oozoofrog).
