# oozoofrog-plugins

Claude Code 플러그인 마켓플레이스 리포지토리.

## 구조

- `.claude-plugin/marketplace.json` — 마켓플레이스 매니페스트 (버전, 플러그인 목록)
- `plugins/{name}/` — 각 플러그인 독립 디렉토리

## 플러그인 목록 (10개)

| 플러그인 | 스킬 | 에이전트 | 훅 |
|----------|------|---------|-----|
| macos-release | macos-release | — | — |
| agent-context | ctx-guide, ctx-init, ctx-verify, ctx-audit | context-validator | SessionStart |
| gpt-research | gpt-research | — | — |
| hey-codex | hey-codex, codex-research | — | — |
| app-automation | app-automation, os-log | ui-verifier | — (.mcp.json: baepsae) |
| apple-craft | apple-craft, apple-harness, apple-review, pen-craft, appstore-deploy | harness-planner, harness-builder, harness-design-architect, harness-design-implementer, harness-evaluator, harness-reviewer, design-coder | — |
| plugin-doctor | fixer | — | — |
| api-learn | api-learn, api-scan | — | — |
| git-workflow | add-git-issue | — | — |
| release-cycle | plan-release, release | — | — |

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

### 도구 접근
- 스킬/에이전트의 `tools`/`allowed-tools` 필드는 **생략** — 메인 대화의 모든 도구(MCP 포함) 자동 상속
- 특정 도구를 제한해야 할 때만 `disallowedTools`로 역방향 제어
- MCP 서버 버전업 시 도구명 변경에 대한 유지보수 부담 제거

### 평가 프로토콜 (Skeptical Re-verification)

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) 블로그 기반.

**핵심 원칙:**
- **Generator-Evaluator 역할 분리** — 자기평가의 "자기 칭찬" 함정을 별도 역할로 극복 (GAN의 "적대성"이 아닌 **협력적 회의**)
- **Sprint Contract** — 수정 시작 전에 "done" 기준을 사전 합의하여 평가 일관성 보장
- **회의적 평가** — 수정이 실제로 적용되었는가, 새 문제를 유발하지 않았는가, 기준을 완화한 것은 아닌가
- **하네스 간소화** — "every component in a harness encodes an assumption about what the model can't do on its own" → 모델 개선 시 불필요해진 구성요소는 제거

**적용 현황:**
- apple-craft/apple-harness: Builder↔Evaluator 자율 루프 (원본, 4축 다차원 평가)
- plugin-doctor/fixer: Stage 9 회의적 재검증 루프
- agent-context/ctx-verify: 수정-재검증 루프

### 진단
- `/fixer` 실행으로 전체 마켓플레이스 검증 가능
