# oozoofrog-plugins

Claude Code 플러그인 마켓플레이스 리포지토리.

## 구조

- `.claude-plugin/marketplace.json` — 마켓플레이스 매니페스트 (버전, 플러그인 목록)
- `plugins/{name}/` — 각 플러그인 독립 디렉토리

## 플러그인 목록 (7개)

| 플러그인 | 스킬 | 에이전트 | 훅 |
|----------|------|---------|-----|
| macos-release | macos-release | — | — |
| agent-context | ctx-guide, ctx-init, ctx-verify, ctx-audit | context-validator | SessionStart |
| gpt-research | gpt-research | — | — |
| hey-codex | hey-codex | — | — |
| app-automation | app-automation | — | — (.mcp.json: baepsae) |
| apple-craft | apple-craft, apple-harness, apple-review | harness-planner, harness-builder, harness-designer, harness-evaluator, harness-reviewer | — |
| plugin-doctor | fixer | — | — |

## 플러그인 개발 규칙

### 필수 구조
```
plugins/{name}/
├── .claude-plugin/plugin.json   ← name, version, description, author
├── skills/{skill-name}/SKILL.md ← frontmatter + 마크다운
├── agents/{agent-name}.md       ← (선택)
├── hooks/hooks.json             ← (선택)
└── README.md
```

### 버전 관리
- plugin.json과 marketplace.json의 version 반드시 동기화
- 스킬/에이전트 변경 시 플러그인 버전 범프 필수
- marketplace.json 버전도 함께 범프

### 스킬 네이밍
- CLI 자동완성은 **스킬 short name**으로 동작 (`/fixer` → `plugin-doctor:fixer`)
- 빌트인 명령과 충돌 금지: `/doctor`, `/plugin`, `/help`, `/compact`, `/clear`, `/context`, `/config`, `/reload-plugins`
- SKILL.md frontmatter의 `allowed-tools`는 YAML 리스트 형식 사용

### commands/ 사용 금지
- commands는 deprecated. 반드시 skills/ 사용
- 기존 commands가 있으면 `skills/{name}/SKILL.md`로 마이그레이션

### 진단
- `/fixer` 실행으로 전체 마켓플레이스 검증 가능
