---
name: session-viewer
description: Claude Code 세션 로그를 TUI로 탐색합니다. "세션 로그 보기", "session viewer", "세션 뷰어", "claude code 로그 TUI", "이전 대화 보기", "내 세션 목록", "지난 세션 검토", "로그 인터랙티브 보기" 등의 요청 시 사용하세요. 모든 프로젝트 세션과 현재 작업 디렉토리에 매칭되는 세션을 토글로 전환할 수 있습니다.
argument-hint: "[--rebuild: 바이너리 재빌드]"
allowed-tools:
  - Bash
---

# Session Viewer

Claude Code가 `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl`에 기록하는 세션 로그를 ratatui 기반 인터랙티브 TUI로 탐색한다. 세션 목록 → 세션 상세(메시지 + tool 호출) 두 단계 뷰를 제공하며, 전체 프로젝트 세션과 현재 cwd 매칭 세션을 토글로 전환한다.

## 언제 사용하는가

다음 요청을 받으면 이 스킬을 사용한다:

- "내가 했던 세션들 좀 보여줘" / "이전 세션 열어줘"
- "Claude Code 로그를 TUI로 보고 싶다"
- "오늘 작업한 세션 다시 보고 싶다"
- "tool 호출 흐름이 어땠는지 검토하고 싶다"
- "이 프로젝트에서만 했던 대화들 골라서 보자"

## 빠른 시작

TUI는 alternate screen + raw mode를 사용하므로 **반드시 별도 터미널 앱(Terminal.app / iTerm2 / WezTerm 등)에서 직접 실행**해야 한다. Claude Code의 Bash 도구는 물론 `!` 프리픽스 셸 모드도 raw mode TTY를 제공하지 않아 `Error: Device not configured (os error 6)`로 종료된다.

다음 중 환경에 맞는 경로를 사용한다:

```bash
# 1. Claude Code 스킬 컨텍스트 (SKILL.md 안에서 변수 확장)
${CLAUDE_PLUGIN_ROOT}/skills/session-viewer/bin/launch.sh

# 2. 마켓플레이스 source (개발/테스트 시, plugin sync 전에도 사용 가능)
~/.claude/plugins/marketplaces/oozoofrog-plugins/plugins/session-viewer/skills/session-viewer/bin/launch.sh

# 3. 설치 후 cache 경로 (plugin enable + sync 이후)
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh
```

`launch.sh`는 host의 OS/arch를 감지해 다음 순서로 동작한다:

1. `bin/session-viewer-<os>-<arch>` 사전 빌드 바이너리가 있으면 그대로 실행
2. 없으면 `src/`에서 `cargo build --release`로 즉석 빌드하고 캐시
3. cargo가 없으면 종료 코드 127로 에러 출력

현재 번들된 바이너리: `bin/session-viewer-darwin-arm64` (Mach-O 64-bit, ~1.6MB; clap + regex + 3개 서브커맨드 포함).

## 키 바인딩

### List view (세션 목록)

| 키 | 동작 |
|---|---|
| `↑` / `↓` (또는 `k` / `j`) | 한 줄 이동 |
| `PgUp` / `PgDn` | 10줄 페이지 이동 |
| `g` / `G` | 처음 / 끝으로 |
| `Enter` | 선택 세션 상세 보기 |
| `t` | **토글: ALL ↔ CWD** (현재 cwd 매칭 세션만 보기) |
| `q` 또는 `Ctrl-C` | 종료 |

각 행 표시 형식:

```
[●] MM-DD HH:MM   <msg수>   <project label>   <첫 user prompt 미리보기>
```

`●` 마크는 그 세션이 현재 cwd에서 시작된 세션임을 의미한다 (ALL 모드에서도 표시).

### Detail view (세션 상세)

| 키 | 동작 |
|---|---|
| `↑` / `↓` (또는 `k` / `j`) | 한 줄 스크롤 |
| `PgUp` / `PgDn` | 20줄 스크롤 |
| `g` / `G` | 맨 위 / 맨 아래 |
| `Esc` / `q` / `Backspace` | 목록으로 돌아가기 |

상세 뷰는 JSONL의 시간 순서대로 다음 이벤트들을 색상 구분하여 표시한다:

- 🟢 **User** (녹색) — 사용자 프롬프트 (system-reminder 등 노이즈는 자동 필터)
- ⚪ **Assistant** (흰색) — 어시스턴트 응답 텍스트
- 🟣 **Tool use** (자홍) — 도구 호출 (이름 + input JSON)
- ⚫ **Tool result** (어두운 회색) — 도구 결과
- 🟡 **Thinking** (노랑) — extended thinking 블록
- 🔵 **Hook** (파랑) — SessionStart/UserPromptSubmit 등 hook 이벤트
- 회색 **system** — permission-mode 변경

## 데이터 소스

### 디렉토리 구조

```
~/.claude/projects/
├── -Users-oozoofrog/                    # cwd: /Users/oozoofrog
│   ├── <session-uuid-1>.jsonl
│   └── <session-uuid-2>.jsonl
└── -Volumes-eyedisk-develop-kakao-talk/ # cwd: /Volumes/eyedisk/develop/kakao-talk
    └── <session-uuid-3>.jsonl
```

디렉토리 이름은 cwd의 `/`와 `.`을 모두 `-`로 치환한 것이다 (자세한 규칙은 `references/jsonl-schema.md` 참조).

### JSONL 라인 종류

각 줄은 단일 JSON 오브젝트이며 주요 `type`:

- `user` — `message.content`가 string 또는 `[{type:"text"|"tool_result", ...}]`
- `assistant` — `message.content`가 `[{type:"text"|"tool_use"|"thinking", ...}]`
- `permission-mode` — `permissionMode` 값 변경
- 그 외 hook 이벤트는 `attachment` 필드로 표시

전체 스키마는 `references/jsonl-schema.md`에 정리되어 있다.

## CWD 매칭 규칙

`t`로 ALL/CWD 토글 시, 현재 작업 디렉토리를 다음 규칙으로 인코딩하여 디렉토리 이름과 비교한다:

```
encode(p) = p.replace('/', '-').replace('.', '-')
```

예: `/Users/oozoofrog` → `-Users-oozoofrog`. `/Users/foo/blog/site.io/.claude/x` → `-Users-foo-blog-site-io--claude-x` (경계의 `/.`이 `--`가 됨).

이 인코딩은 lossy하므로 (예: `kakao-talk` 디렉토리와 `kakao.talk` 디렉토리 구분 불가) edge case가 있을 수 있다. 일반적인 케이스는 정확히 매칭된다.

## 사용자 흐름

1. 사용자가 "세션 로그 보고 싶다" 류 요청을 함
2. Claude는 다음을 안내:
   - **별도 터미널 앱**(Terminal.app / iTerm2 / WezTerm 등)을 열라고 명시
   - 그 터미널에 붙여넣을 launcher의 절대 경로 제공 (예: `~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh`)
3. 사용자가 별도 터미널에서 TUI 실행 → 탐색 → 종료
4. 종료 후 사용자가 본 내용 바탕으로 Claude Code 세션에서 후속 작업 (예: "그 세션의 X 부분을 다시 분석해줘") 진행

**왜 별도 터미널이어야 하는가**: TUI는 alternate screen + raw mode + non-blocking event loop를 사용한다. Claude Code 안에서는 Bash 도구도, `!` 프리픽스 셸 모드도 모두 stdout 캡처/파이프 모델이라 raw mode TTY를 제공하지 못하고 `enable_raw_mode()`가 즉시 ENXIO(`Error: Device not configured`, os error 6)로 실패한다. 이는 우회 가능한 제약이 아니라 Claude Code의 모든 셸 실행 경로의 공통 한계다.

## 재빌드가 필요한 경우

다음 상황에서 `src/`를 다시 빌드한다:

- 사용자가 darwin-arm64가 아닌 환경 (Linux, Intel Mac)에서 사용
- `src/main.rs`를 수정한 후
- 사전 빌드 바이너리가 손상된 경우

수동 재빌드:

```bash
cd ${CLAUDE_PLUGIN_ROOT}/skills/session-viewer/src
cargo build --release
cp target/release/session-viewer ../bin/session-viewer-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)
```

또는 `launch.sh`가 자동으로 빌드 후 캐시한다 (cargo만 PATH에 있으면 됨).

## 디렉토리 레이아웃

```
session-viewer/
├── SKILL.md                      # 이 파일 (lean: 트리거 + 사용법 + 키 바인딩)
├── bin/
│   ├── launch.sh                 # OS/arch 감지 + 자동 빌드 폴백
│   └── session-viewer-darwin-arm64
├── references/
│   └── jsonl-schema.md           # JSONL 라인 타입 상세 스키마
└── src/
    ├── Cargo.toml
    ├── Cargo.lock
    └── src/
        ├── main.rs               # clap dispatcher
        ├── data.rs               # JSONL 파싱 + Session/Message 타입 (공통)
        ├── tui.rs                # ratatui + crossterm TUI
        ├── query.rs              # 필터 + 텍스트/JSON/JSONL 출력
        └── web.rs                # 단일 self-contained HTML export
```

## 서브커맨드 (v0.2.0+)

`session-viewer`는 3개 서브커맨드를 가진 단일 바이너리다:

| 서브커맨드 | 용도 | TTY 필요? |
|---|---|---|
| `tui` (default) | 인터랙티브 TUI 탐색 | 예 (별도 터미널) |
| `query` | 필터 기반 CLI 조회 | 아니오 |
| `web <id>` | 단일 세션을 self-contained HTML로 export | 아니오 |

`query`와 `web`은 raw mode를 쓰지 않으므로 **Claude Code 안의 Bash 도구로도 실행 가능**하다. TUI만 별도 터미널이 필요.

### `query` — 필터 기반 조회

```bash
session-viewer query [OPTIONS]

# 필터
--since <WHEN>      # "2d", "1h", "1w", "2026-05-01" (RFC3339도 OK)
--until <WHEN>
--cwd               # 현재 작업 디렉토리에서 시작된 세션만
--project <PATTERN> # project label/encoded dir 이름 substring
--tool <REGEX>      # 호출된 도구 이름 정규식 (예: 'Bash|Read')
--text <STRING>     # user/assistant/tool_result 본문 substring
--regex <REGEX>     # 같은 본문에서 정규식 매칭

# 출력 형식
--format summary    # 사람이 읽는 한 줄 요약 (default)
--format json       # 매칭된 세션 메타데이터 배열
--format jsonl      # 매칭된 raw JSONL 라인 (또는 메타데이터 한 줄/세션)
```

**예시:**

```bash
# 최근 1일 동안, Bash나 Read를 호출한 세션의 raw 라인을 jq로 처리
session-viewer query --since 1d --tool 'Bash|Read' --format jsonl | jq .

# 현재 프로젝트에서 "ratatui"가 언급된 세션만 요약
session-viewer query --cwd --text ratatui

# 6시간 이내 모든 세션을 JSON으로 → 스크립트에서 사용
session-viewer query --since 6h --format json
```

### `web <session-id>` — Static HTML export

```bash
session-viewer web <SESSION_ID> [-o OUTPUT]
```

- `<SESSION_ID>`: 전체 UUID 또는 unique prefix (예: `0532f5f4`). 중복되면 후보 출력 후 종료.
- `-o, --output <PATH>`: 출력 파일. 생략 시 stdout.

**예시:**

```bash
# 세션을 single self-contained HTML로 export 후 브라우저로 열기
session-viewer web 0532f5f4 -o /tmp/session.html
open /tmp/session.html

# 또는 stdout 파이프
session-viewer web 0532f5f4 > out.html
```

**HTML 뷰어 기능:**
- 채팅 모방 UI (user/assistant 말풍선, tool 호출은 collapsible 카드)
- `/` 키로 검색 포커스, 입력 시 본문 substring 매칭 + 하이라이트
- 상단 chip 필터 (All / User / Assistant / Tool / Result)
- 다크모드 자동 감지 (`prefers-color-scheme`)
- 모바일 레이아웃 자연스러움
- Zero runtime — 인터넷 없이도 동작, 이메일/Slack 공유 가능

### 빠른 시작 (TUI 외 명령)

```bash
# query/web도 launch.sh로 실행 가능 (인자만 추가)
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh query --since 1d
~/.claude/plugins/cache/oozoofrog-plugins/session-viewer/<version>/skills/session-viewer/bin/launch.sh web 0532f5f4 -o /tmp/x.html
```

## 의존성

- **Rust** ≥ 1.74 (재빌드 시) — `rustup`으로 설치
- **macOS arm64** (사전 빌드 바이너리) — Apple Silicon
- **터미널** — alternate screen + 256색 + UTF-8 지원 (Terminal.app, iTerm2, WezTerm 모두 OK)

런타임 의존성 없음 (정적 바이너리).

## 알려진 제약

- 매우 큰 세션 파일(>100MB)은 첫 화면 로딩이 느릴 수 있다 — 첫 user prompt 추출을 위해 전체 파일을 한 번 스캔하기 때문
- 매우 긴 단일 메시지는 detail view에서 렌더링 폭 안에서만 wrap되며 외부 스크롤이 적용된다 (`Wrap { trim: false }`)
- CWD 매칭은 lossy 인코딩 기반이므로 dot이 포함된 경로에 false positive 가능 (실제로는 거의 안 일어남)

## 추가 자료

상세 JSONL 스키마와 이벤트 종류는 `references/jsonl-schema.md` 참조.
