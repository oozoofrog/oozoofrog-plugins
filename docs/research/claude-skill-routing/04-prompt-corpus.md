# Prompt Corpus

이 문서는 라우팅 품질을 점검하기 위한 **자연어 테스트 세트** 초안입니다.

## 사용 규칙

- 각 프롬프트는 가능한 한 실제 사용자 말투를 반영한다.
- 한국어 우선, 필요 시 영어/혼합문도 포함한다.
- 평가 시에는 프롬프트를 그대로 넣고, 선택된 스킬과 기대 스킬을 비교한다.

## 필드 정의

| 필드 | 의미 |
|---|---|
| ID | 고유 식별자 |
| Prompt | 실제 입력 문장 |
| Expected | 기대 스킬 |
| Why | 기대 이유 |
| Notes | 충돌 가능성 / 변형 후보 |

## Seed Set v0.1

| ID | Prompt | Expected | Why | Notes |
|---|---|---|---|---|
| AC-01 | `CLAUDE.md가 너무 길어요. 구조 어떻게 나누면 좋을까요?` | `ctx-guide` | 구조 설계 요청 | `ctx-audit`와 충돌 가능 |
| AC-02 | `이 저장소에 AGENTS.md랑 CLAUDE.md 뼈대 좀 잡아줘` | `ctx-init` | 실제 초기화/생성 요청 | `ctx-guide`와 구분 필요 |
| AC-03 | `CONTEXT.md 링크 깨진 곳 있는지 검증해줘` | `ctx-verify` | 정합성 검증 요청 | `fixer`와 약한 충돌 |
| AC-04 | `컨텍스트 문서가 너무 무거운 것 같은데 토큰 낭비 감사해줘` | `ctx-audit` | 효율성 감사 요청 | `ctx-guide`와 충돌 가능 |
| UI-01 | `시뮬레이터에서 로그인 버튼 눌러보고 다음 화면까지 확인해줘` | `app-automation` | 실제 UI 조작/검증 | 로그 요구 없음 |
| UI-02 | `지금 실행 중인 앱 os_log 실시간으로 보여줘` | `os-log` | 로그 스트리밍 요청 | `app-automation`와 구분 |
| AP-01 | `SwiftUI 리스트 성능 개선해줘` | `apple-craft` | 일반 Apple 개발 작업 | `apple-review` 아님 |
| AP-02 | `이 PR 리뷰해줘. Swift concurrency 쪽 위주로` | `apple-review` | 리뷰 요청 | `apple-craft`와 충돌 가능 |
| AP-03 | `iOS 앱 하나 처음부터 만들어줘. 온보딩이랑 설정 화면까지 전체로` | `apple-harness` | from-scratch + 전체 구현 | `apple-craft`와 충돌 가능 |
| EX-01 | `이 모듈을 GPT한테 넘길 수 있게 리서치 프롬프트 만들어줘` | `gpt-research` | GPT용 프롬프트 생성 | `hey-codex`와 구분 |
| EX-02 | `codex로 이 함수 테스트 작성해줘` | `hey-codex` | Codex 명시 + 작업 위임 | 매우 강한 신호 |
| RL-01 | `새 버전 릴리스 준비해줘. DMG랑 Homebrew까지` | `macos-release` | 배포/릴리스 작업 | Apple 개발 일반 작업과 구분 |
| PD-01 | `플러그인 마켓플레이스 전체 점검하고 고칠 수 있는 건 고쳐줘` | `fixer` | 플러그인 진단/수정 | `ctx-verify`와 일부 겹침 |

## 확장 코퍼스 후보

### 한국어 구어체 변형

- `이거 전체적으로 한번 봐줘`
- `큰 틀부터 세팅해줘`
- `한번 검증 돌려봐`
- `GPT로 물어볼 수 있게 정리해줘`
- `codex한테 넘겨서 처리해줘`

### 영어/혼합문 변형

- `Can you scaffold AGENTS.md for this repo?`
- `Please audit context token efficiency`
- `codex에게 delegate해서 fix proposal 받아줘`
- `SwiftUI performance review 좀 해줘`

## 추가할 케이스

- 하나의 프롬프트에 두 의도가 섞인 경우
- sibling skill 모두 그럴듯한 경우
- 스킬 이름을 직접 말하지 않고 결과물만 말하는 경우
- 도메인은 같지만 행동이 다른 경우

예:
- `SwiftUI 코드 좀 봐주고 필요하면 전체적으로 리팩토링 방향도 잡아줘`
- `컨텍스트 구조 설계도 해주고 바로 파일도 만들어줘`
