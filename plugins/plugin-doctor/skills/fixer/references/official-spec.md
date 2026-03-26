# Claude Code Plugin Official Specification

> Last updated: 2026-03-27
> Source: https://docs.anthropic.com/en/docs/claude-code/plugins, skills, agents, hooks

이 문서는 plugin-doctor 스킬이 검증 기준으로 사용하는 공식 스펙 참조이다. Stage 0 (Self-Update)에서 자동 갱신된다.

---

## 1. Marketplace (marketplace.json)

### 위치
`.claude-plugin/marketplace.json`

### 필수 필드
- `name` (string, kebab-case): 마켓플레이스 식별자
- `owner` (object): `{ name: string (required), email?: string }`

### 선택 필드
- `metadata.description`, `metadata.version`, `metadata.pluginRoot`

### 플러그인 엔트리 (plugins[])
| 필드 | 필수 | 타입 | 설명 |
|------|------|------|------|
| `name` | ✅ | string (kebab-case) | 플러그인 식별자 |
| `source` | ✅ | string\|object | 소스 경로/URL |
| `description` | | string | 설명 |
| `version` | | string (SemVer) | 버전 |
| `author` | | object | `{ name, email? }` |
| `category` | | string | 카테고리 |
| `keywords` | | array | 검색 태그 |
| `homepage` | | string | 문서 URL |
| `repository` | | string | 소스 URL |
| `license` | | string | SPDX 식별자 |

### Source 형식
- 상대 경로: `"./plugins/my-plugin"` (반드시 `./`로 시작)
- GitHub: `{ source: "github", repo: "owner/repo", ref?, sha? }`
- Git URL: `{ source: "url", url: "...", ref?, sha? }`
- Git 하위디렉토리: `{ source: "git-subdir", url: "...", path: "...", ref?, sha? }`
- npm: `{ source: "npm", package: "...", version?, registry? }`

---

## 2. Plugin (plugin.json)

### 위치
`.claude-plugin/plugin.json` (선택 — 없어도 플러그인 동작)

### 필수 필드 (매니페스트가 존재하는 경우)
- `name` (string, kebab-case): 고유 식별자

### 선택 필드
| 필드 | 타입 | 설명 |
|------|------|------|
| `version` | string (SemVer) | 버전 (marketplace와 충돌 시 plugin.json 우선) |
| `description` | string | 설명 |
| `author` | object | `{ name, email?, url? }` |
| `homepage` | string | 문서 URL |
| `repository` | string | 소스 URL |
| `license` | string | SPDX 식별자 |
| `keywords` | array | 검색 태그 |
| `commands` | string\|array | 커스텀 명령 경로 (기본: `./commands/`) |
| `agents` | string\|array | 커스텀 에이전트 경로 (기본: `./agents/`) |
| `skills` | string\|array | 커스텀 스킬 경로 (기본: `./skills/`) |
| `hooks` | string\|array\|object | 훅 설정 |
| `mcpServers` | string\|array\|object | MCP 서버 설정 |
| `lspServers` | string\|array\|object | LSP 서버 설정 |
| `outputStyles` | string\|array | 출력 스타일 경로 |
| `userConfig` | object | 사용자 설정 스키마 |

### 디렉토리 구조 (기본)
```
plugin-root/
├── .claude-plugin/plugin.json
├── commands/          (deprecated, skills/ 권장)
├── agents/
├── skills/
├── output-styles/
├── hooks/
│   ├── hooks.json
│   └── scripts/
├── .mcp.json
├── .lsp.json
└── settings.json
```

### 환경 변수
- `${CLAUDE_PLUGIN_ROOT}`: 플러그인 설치 절대 경로
- `${CLAUDE_PLUGIN_DATA}`: 플러그인 영구 데이터 디렉토리

---

## 3. Skills (SKILL.md)

### 구조
```
skills/{skill-name}/
├── SKILL.md         (필수)
├── references/      (선택)
└── scripts/         (선택)
```

### Frontmatter 전체 필드
| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `name` | string | 아니오 | 디렉토리명 | 식별자 (kebab-case, max 64자) |
| `description` | string | 권장 | 첫 단락 | 스킬 설명 + 트리거 키워드 |
| `argument-hint` | string | 아니오 | N/A | 자동완성 힌트 |
| `allowed-tools` | string\|list | 아니오 | 상속 | 허용 도구 (YAML 리스트 권장) |
| `disallowed-tools` | string\|list | 아니오 | 없음 | 거부 도구 |
| `disable-model-invocation` | boolean | 아니오 | false | Claude 자동 호출 차단 |
| `user-invocable` | boolean | 아니오 | true | `/` 메뉴 표시 여부 |
| `model` | string | 아니오 | 상속 | sonnet, haiku, opus, 또는 전체 ID |
| `effort` | string | 아니오 | 상속 | low, medium, high, max |
| `context` | string | 아니오 | inline | `fork` = 서브에이전트 컨텍스트 |
| `agent` | string | 아니오 | general-purpose | context: fork 시 에이전트 타입 |
| `paths` | string | 아니오 | N/A | glob 패턴 (콤마 구분) |
| `shell` | string | 아니오 | bash | bash 또는 powershell |
| `hooks` | object | 아니오 | N/A | 스킬 범위 훅 |
| `version` | string | 아니오 | N/A | 문서용 버전 |

### 문자열 치환
- `$ARGUMENTS`: 전체 인자
- `$ARGUMENTS[N]` 또는 `$N`: N번째 인자
- `${CLAUDE_SESSION_ID}`: 세션 ID
- `${CLAUDE_SKILL_DIR}`: SKILL.md 디렉토리

### Commands (deprecated)
- `commands/` 디렉토리는 레거시. `skills/` 권장
- 동일 이름 충돌 시 skill이 우선
- 마이그레이션: `commands/file.md` → `skills/file/SKILL.md`

---

## 4. Agents (agents/*.md)

### Frontmatter 전체 필드
| 필드 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `name` | string | ✅ | N/A | 고유 식별자 (kebab-case) |
| `description` | string | ✅ | N/A | 에이전트 설명 + 위임 조건 |
| `tools` | string | 아니오 | 전체 상속 | 허용 도구 (콤마 구분) |
| `disallowedTools` | string | 아니오 | 없음 | 거부 도구 |
| `model` | string | 아니오 | inherit | sonnet, haiku, opus, inherit |
| `effort` | string | 아니오 | 상속 | low, medium, high, max |
| `maxTurns` | number | 아니오 | 무제한 | 최대 턴 수 |
| `permissionMode` | string | 아니오 | default | default, acceptEdits, dontAsk, bypassPermissions, plan |
| `skills` | string\|array | 아니오 | 없음 | 사전 로드 스킬 |
| `mcpServers` | object\|array | 아니오 | 상속 | MCP 서버 설정 |
| `hooks` | object | 아니오 | 없음 | 라이프사이클 훅 |
| `memory` | string | 아니오 | 없음 | user, project, local |
| `background` | boolean | 아니오 | false | 백그라운드 실행 |
| `isolation` | string | 아니오 | 없음 | worktree (git 워크트리 격리) |
| `color` | string | 아니오 | 없음 | 에이전트 색상 |
| `whenToUse` | string | 아니오 | 없음 | 사용 시나리오 + 예시 |
| `initialPrompt` | string | 아니오 | 없음 | 자동 제출 첫 턴 |

### 플러그인 에이전트 제한
플러그인 내 에이전트는 다음 필드 사용 불가 (무시됨):
- `hooks`
- `mcpServers`
- `permissionMode`

---

## 5. Hooks (hooks.json)

### 위치
- `hooks/hooks.json` (플러그인)
- `plugin.json` 내 `hooks` 필드 (인라인)
- SKILL.md/Agent frontmatter `hooks` 필드

### 공식 이벤트 목록 (25개)
1. SessionStart
2. InstructionsLoaded
3. UserPromptSubmit
4. PreToolUse
5. PermissionRequest
6. PostToolUse
7. PostToolUseFailure
8. Notification
9. SubagentStart
10. SubagentStop
11. TaskCreated
12. TaskCompleted
13. TeammateIdle
14. Stop
15. StopFailure
16. ConfigChange
17. CwdChanged
18. FileChanged
19. WorktreeCreate
20. WorktreeRemove
21. PreCompact
22. PostCompact
23. Elicitation
24. ElicitationResult
25. SessionEnd

### 훅 타입
| 타입 | 기본 타임아웃 | 설명 |
|------|-------------|------|
| `command` | 600s | 셸 스크립트 실행 |
| `http` | 30s | POST 웹훅 |
| `prompt` | 30s | LLM 평가 |
| `agent` | 60s | 서브에이전트 검증 |

### Command 훅 종료 코드
- `0`: 성공, stdout에서 JSON 파싱
- `2`: 차단, stderr를 에러 메시지로 사용
- 기타: 비차단 에러

---

## 6. 검증 규칙

### Kebab-case 규칙
- 소문자, 숫자, 하이픈만 허용
- 정규식: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`
- 최대 64자 (스킬 이름)

### SemVer 규칙
- 형식: `MAJOR.MINOR.PATCH`
- 정규식: `^\d+\.\d+\.\d+$`

### 유효한 기본 도구 이름
Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch, NotebookEdit, NotebookRead

### MCP 도구 이름 패턴
`mcp__{server}__{tool}` (예: `mcp__xcode__BuildProject`)

### 경로 규칙
- 상대 경로 필수, `./`로 시작
- `../` 금지 (경로 탈출)
- 절대 경로 금지
- Windows 경로 금지
