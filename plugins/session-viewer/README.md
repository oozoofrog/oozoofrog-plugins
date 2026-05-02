# session-viewer

Claude Code 세션 로그(`~/.claude/projects/*/*.jsonl`)를 인터랙티브 TUI로 탐색하는 플러그인.

## 무엇을 하나

Claude Code는 모든 대화 세션을 작업 디렉토리별로 인코딩된 디렉토리 아래 JSONL 파일로 저장한다. 이 플러그인은 그 로그를 ratatui 기반 TUI로 보여준다:

- **세션 목록 뷰** — 시간 역순, 프로젝트 라벨 + 첫 사용자 프롬프트 미리보기
- **세션 상세 뷰** — 사용자 메시지 / 어시스턴트 응답 / tool 호출 / thinking / hook 이벤트를 색상 구분
- **CWD 토글** (`t` 키) — 전체 세션 ↔ 현재 작업 디렉토리에서 시작된 세션만

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
