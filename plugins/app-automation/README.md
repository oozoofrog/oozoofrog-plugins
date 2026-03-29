# app-automation

Apple 앱 자동화 플러그인 — iOS Simulator + macOS 앱 UI 인터랙션, 접근성 검증, 스크린샷/비디오, 워크플로우 자동화.

mcp-baepsae MCP 서버를 통해 시뮬레이터 및 macOS 앱을 제어합니다.

## 설치

```bash
/plugin install app-automation@oozoofrog-plugins
```

## 사용법

```bash
# 앱 자동화 가이드
/app-automation

# 시뮬레이터 조작, 접근성 검증, 스크린샷 등
```

## 컴포넌트

### Skill

| 스킬 | 설명 |
|------|------|
| `/app-automation` | Apple 앱 자동화 가이드 (시뮬레이터, UI 인터랙션, 접근성, 워크플로우) |

### Agent

| 에이전트 | 설명 |
|---------|------|
| `ui-verifier` | app-automation 실행 결과를 selector/UI tree/screenshot evidence로 재검증 |

### MCP Server

`baepsae` — mcp-baepsae를 통한 iOS Simulator + macOS 앱 자동화

## 검증 워크플로우

권장 패턴은 **실행(actor)** 과 **검증(observer)** 을 분리하는 것입니다.

1. `/app-automation` 또는 일반 대화로 자동화 플로우 실행
2. `ui-verifier` 에이전트가 `query_ui`, `analyze_ui`, `screenshot`로 결과 재검증
3. skill-scoped `Stop` agent hook가 종료 전 검증 누락을 한 번 더 점검

예시:

```text
Use the ui-verifier agent to verify the last simulator flow
Have the ui-verifier agent check whether the settings screen actually opened
```

## Claude Code CLI로 빠르게 검증하기

추가한 검증 스크립트:

```bash
bash plugins/app-automation/scripts/verify-claude-code.sh
```

이 스크립트는 다음을 확인합니다.

1. `claude` CLI 설치/버전
2. `claude auth status` 로그인 상태
3. `claude plugin validate ./plugins/app-automation`
4. `claude --plugin-dir ./plugins/app-automation agents` 에서 `app-automation:ui-verifier` 노출
5. `claude --plugin-dir ./plugins/app-automation plugin list` 에서 session-only plugin 로드
6. `claude --agent app-automation:ui-verifier -p "Say OK in one word."` 스모크 테스트

옵션:

```bash
# agent 스모크 테스트 생략
bash plugins/app-automation/scripts/verify-claude-code.sh --no-agent-smoke
```

## 파일 구조

```
app-automation/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── ui-verifier.md
├── .mcp.json
├── scripts/
│   └── verify-claude-code.sh
├── skills/
│   └── app-automation/
│       └── SKILL.md
└── README.md
```
