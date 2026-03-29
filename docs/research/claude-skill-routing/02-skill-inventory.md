# Skill Inventory

## 전체 인벤토리

| Plugin | Skill | 주 역할 | 대표 자연어 의도 | 주요 충돌 후보 |
|---|---|---|---|---|
| agent-context | `ctx-guide` | 컨텍스트 구조 설계 가이드 | “CLAUDE.md 구조 어떻게 잡지?” | `ctx-init`, `ctx-audit` |
| agent-context | `ctx-init` | 컨텍스트 파일 스캐폴딩 | “AGENTS.md/CLAUDE.md 뼈대 만들어줘” | `ctx-guide`, `ctx-verify` |
| agent-context | `ctx-verify` | 컨텍스트 검증 | “링크 깨진 곳 검증해줘” | `ctx-audit`, `fixer` |
| agent-context | `ctx-audit` | 토큰 효율/밀도 감사 | “컨텍스트 너무 길어 보이는데 감사해줘” | `ctx-guide`, `ctx-verify` |
| app-automation | `app-automation` | UI 자동화/검증 | “시뮬레이터에서 버튼 눌러봐” | `os-log` |
| app-automation | `os-log` | 로그 조회/스트리밍 | “실시간 os_log 보여줘” | `app-automation` |
| apple-craft | `apple-craft` | Apple 개발 일반 작업 | “SwiftUI 코드 개선해줘” | `apple-review`, `apple-harness` |
| apple-craft | `apple-harness` | 큰 범위 Apple 구현 | “앱 처음부터 만들어줘” | `apple-craft` |
| apple-craft | `apple-review` | Apple 코드/PR 리뷰 | “이 PR 리뷰해줘” | `apple-craft` |
| gpt-research | `gpt-research` | 외부 GPT 리서치용 프롬프트 생성 | “GPT에 넘길 프롬프트 만들어줘” | `hey-codex` |
| hey-codex | `hey-codex` | Codex CLI 위임 | “codex로 이거 해줘” | `gpt-research` |
| macos-release | `macos-release` | macOS 릴리스 자동화 | “새 버전 릴리스해줘” | `apple-craft` |
| plugin-doctor | `fixer` | 플러그인 검증/수정 | “플러그인 전체 점검해줘” | `ctx-verify` |

## 충돌군 상세

### 1) agent-context 계열

핵심 분리축:
- `ctx-guide`: 설계/원칙/구조 조언
- `ctx-init`: 실제 초기 파일 생성
- `ctx-verify`: 정합성 검증
- `ctx-audit`: 효율성 감사

관찰 포인트:
- “구조 봐줘”는 `guide`/`audit`가 충돌할 수 있다.
- “세팅해줘”는 `init`로 가야 하지만 가이드성 문장과 섞이면 모호해진다.
- “검토해줘”는 `verify`와 `audit`가 충돌하기 쉽다.

### 2) apple-craft 계열

핵심 분리축:
- `apple-craft`: 일반 개발/수정/설명
- `apple-harness`: from-scratch, 대규모 기능, 전체 구현
- `apple-review`: 리뷰/점검/검토

관찰 포인트:
- “리팩토링해줘”는 `apple-craft`와 `apple-harness` 모두 가능성이 있다.
- “코드 봐줘”는 `apple-review`와 `apple-craft`가 겹친다.
- “전체적으로 손봐줘”는 범위 해석에 따라 둘로 갈릴 수 있다.

### 3) app-automation 계열

핵심 분리축:
- `app-automation`: UI를 실제로 조작/검증
- `os-log`: 로그만 읽기/스트리밍

관찰 포인트:
- “앱이 왜 안 되는지 확인해줘”는 UI 검증과 로그 분석이 동시에 필요할 수 있다.
- 로그를 요구하지 않았는데 자동화 스킬이 과도하게 잡히지 않는지 확인 필요.

### 4) external delegate 계열

핵심 분리축:
- `gpt-research`: GPT용 프롬프트/컨텍스트 추출
- `hey-codex`: Codex CLI에 실제 작업 위임

관찰 포인트:
- “외부 모델한테 물어보자” 같은 표현은 두 스킬 모두 자극할 수 있다.
- `hey-codex`는 “codex”가 명시되면 우세해야 한다.
- `gpt-research`는 “프롬프트”, “컨텍스트 뽑아”, “GPT에 넘겨”가 핵심이다.

## 초기 개선 우선순위

### P1 — 바로 충돌 가능성이 큰 곳

1. `apple-craft` / `apple-harness` / `apple-review`
2. `ctx-guide` / `ctx-init` / `ctx-verify` / `ctx-audit`

### P2 — 명시 키워드가 강하지만 경계 보강이 필요한 곳

1. `gpt-research` / `hey-codex`
2. `app-automation` / `os-log`

### P3 — 단일 목적이 비교적 선명한 곳

1. `macos-release`
2. `fixer`

## 인벤토리 점검 체크리스트

- 각 스킬 description에 **사용자 실제 표현**이 충분히 들어 있는가?
- sibling skill과의 차이가 example에서 드러나는가?
- “언제 이 스킬이 아닌가”가 암묵적이지 않고 명시적인가?
- 플러그인 description과 스킬 description이 같은 방향을 가리키는가?
