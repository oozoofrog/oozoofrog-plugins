# Batch 1 — apple-craft Family 라우팅 개선 초안

## 대상

- `plugins/apple-craft/skills/apple-craft/SKILL.md`
- `plugins/apple-craft/skills/apple-harness/SKILL.md`
- `plugins/apple-craft/skills/apple-review/SKILL.md`
- 보조 정렬 대상:
  - `plugins/apple-craft/.claude-plugin/plugin.json`
  - `plugins/apple-craft/README.md`

## 왜 이 배치부터 시작하나

이 family는 실제 사용 빈도가 높고, 동시에 세 sibling이 모두 그럴듯하게 보일 가능성이 크다.

- `apple-craft`: 일반 Apple 개발 작업의 기본 스킬
- `apple-review`: 리뷰 전용 스킬
- `apple-harness`: 장기/대규모 구현 스킬

특히 자연어 관점에서 아래 표현들이 자주 충돌한다.

- “코드 봐줘”
- “리팩토링해줘”
- “전체적으로 손봐줘”
- “앱 만들어줘”
- “PR 리뷰해줘”

## 현재 상태 진단

## 1. `apple-craft`가 너무 많은 신호를 흡수하고 있음

현재 `apple-craft`는 frontmatter description에 아래를 모두 포함한다.

- 코드 작성
- 리뷰
- 리팩토링
- 디버깅
- Xcode MCP
- 최신 API

또한 example에 **리뷰 요청 예시**가 직접 들어 있다.

문제:
- 자연어 라우팅에서는 broad generalist가 sibling specialist를 잡아먹기 쉽다.
- `apple-review`가 따로 있는데도 `apple-craft`가 리뷰까지 적극적으로 주장하면 sibling collision이 발생할 수 있다.

## 2. `apple-harness`의 범위 신호가 아직 넓다

현재 description에는 다음 표현이 포함된다.

- “리팩토링”
- “대규모 변경”
- “전체 구현”
- “처음부터”

문제:
- “리팩토링”은 일반적인 요청에서도 자주 등장한다.
- scope를 나타내지 않는 단독 “리팩토링”은 `apple-craft`와 강하게 충돌한다.

## 3. `apple-review`는 포지셔닝이 좋지만 boundary 문장이 부족하다

현재 `apple-review`는 리뷰 용도를 잘 설명하지만,

- “구현/수정 요청은 이 스킬이 아니다”
- “처음부터/전체 구현은 harness다”

같은 **배제 경계**가 약하다.

## 4. plugin 레벨 wording도 generalist bias를 강화한다

`plugin.json`과 `README.md`가 family 전체 소개를 하면서도 사실상 `apple-craft` 메인 스킬의 broadness를 강화할 수 있다.

특히 plugin 설명에서 “코드 작성·리뷰·디버깅”을 한 줄에 모두 넣으면, 자연어 활성화에서 대표 스킬이 모든 하위 작업을 먹는 인상을 줄 수 있다.

## Batch 1 설계 원칙

## 원칙 A — `apple-craft`는 “기본 개발 스킬”, 그러나 “리뷰 전용”과 “장기 구현”은 양보한다

의도:
- 구현
- 수정
- 디버깅
- 설명
- 작은~중간 규모 리팩토링

양보:
- 리뷰/검토/감사 → `apple-review`
- 처음부터/전체/대규모 다단계 구현 → `apple-harness`

## 원칙 B — `apple-review`는 행동보다 판단 중심 스킬로 고정한다

의도:
- 봐줘
- 검토해줘
- 점검해줘
- PR 리뷰
- blocking issue 찾아줘

배제:
- “고쳐줘”, “구현해줘”, “작성해줘”, “만들어줘”가 핵심 동사면 `apple-craft`

## 원칙 C — `apple-harness`는 scope 중심 스킬로 고정한다

의도:
- 처음부터
- 새 앱
- 전체 기능
- 앱 전체 구조 개편
- 장기 루프가 필요한 멀티스텝 작업

배제:
- 단일 파일 수정
- 특정 화면 하나 손보기
- 코드 리뷰

## 권장 수정안

## 1. `apple-craft` frontmatter description 조정

### 현재 문제

- “코드 리뷰”가 description에 직접 포함됨
- review example이 직접 포함되어 있음

### 권장 방향

- `apple-craft` description은 **개발/수정/디버깅/설명** 중심으로 줄인다.
- 리뷰는 “필요 시 `apple-review`로 전환”으로만 언급한다.
- harness도 “큰 작업은 `apple-harness`” 정도로만 언급한다.

### 초안 문장

```yaml
description: Apple 플랫폼 개발 어시스턴트 — Swift, SwiftUI, UIKit, AppKit, Xcode 빌드/프리뷰/디버깅, 코드 작성/수정/리팩토링/마이그레이션, API 설명, 성능 문제 해결. 일반 Apple 개발 작업의 기본 진입점입니다. 코드 리뷰/PR 검토는 apple-review, 처음부터/전체 구현이나 장기 대규모 작업은 apple-harness를 사용합니다.
```

### 추가 권고

- `apple-craft`의 example에서 아래 항목은 제거 또는 축소 검토:
  - `이 코드 리뷰해줘`
  - `PR #42 리뷰 부탁해`

대신 아래 같은 일반 개발 예시를 강화:

- `이 크래시 원인 찾아서 고쳐줘`
- `WKWebView를 SwiftUI에 붙여줘`
- `이 ViewModel async/await로 바꿔줘`
- `성능 병목 찾아서 개선해줘`

## 2. `apple-craft` 본문에 sibling handoff 문장 강화

현재도 review/harness 모드 전환이 있지만, 더 직설적인 경계 문장이 있으면 좋다.

권장 추가 문장:

```markdown
### Family Boundary

- 구현/수정/디버깅/설명은 이 스킬의 기본 범위다.
- 리뷰/검토/감사 요청이 핵심이면 `apple-review`로 보낸다.
- 처음부터 새 기능/새 앱/앱 전체 구조를 다루는 장기 작업이면 `apple-harness`로 보낸다.
```

## 3. `apple-harness` description 축소 및 scope 명시 강화

### 현재 문제

- `리팩토링` 단독 키워드가 너무 넓다.

### 권장 방향

- bare `리팩토링`은 줄이고
- `앱 전체`, `처음부터`, `전면`, `장기`, `멀티스텝`, `전체 기능`, `새 앱`
  같은 **범위 신호**를 강조한다.

### 초안 문장

```yaml
description: apple-craft 장기 구현 하네스 — 처음부터 새 앱/새 기능을 만들거나, 앱 전체 구조를 바꾸는 대규모 Apple 개발 작업을 Plan→Design→Build→Evaluate 루프로 진행합니다. "처음부터", "새 앱", "전체 구현", "앱 전체", "전면 리팩토링", "대규모 기능 개발", "멀티스텝 장기 작업" 요청에 사용합니다. 단일 파일 수정, 작은 리팩토링, 코드 리뷰는 apple-craft 또는 apple-review가 더 적합합니다.
```

### example 보강 제안

추가하면 좋은 예시:

- `설정/온보딩/결제까지 포함한 iOS 앱 MVP 처음부터 만들어줘`
- `이 앱 아키텍처를 전체적으로 TCA로 전환해줘`
- `디자인부터 구현까지 장기적으로 끝까지 진행해줘`

## 4. `apple-review`에 배제 경계 추가

### 권장 방향

- review/inspection intent는 더 선명하게 유지
- 구현/수정/작성 요청은 이 스킬이 아님을 명시

### 초안 문장

```yaml
description: apple-craft 리뷰 전용 스킬 — Swift/SwiftUI/UIKit/AppKit 코드, 파일, 디렉토리, PR의 문제점·위험·개선점을 점검합니다. "리뷰", "검토", "점검", "PR 리뷰", "코드 봐줘", "문제 있는지 확인해줘", "blocking issue 찾아줘" 같은 요청에 사용합니다. 실제 구현/수정/작성 요청은 apple-craft, 처음부터/전체 구현은 apple-harness가 더 적합합니다.
```

### example 보강 제안

- `이 PR에서 blocking issue만 골라줘`
- `이 SwiftUI 파일 코드 냄새 있는지 봐줘`
- `성능/동시성 관점에서 리뷰해줘`

피해야 할 예시:

- `고쳐줘`
- `작성해줘`
- `구현해줘`

## 5. plugin 설명도 family 구조를 반영

### plugin.json

family-level 소개는 유지하되, 한 스킬이 다 먹는 인상을 줄이지 않도록 조정한다.

예시:

```json
{
  "description": "Apple 플랫폼 개발 스킬 모음 — 일반 구현/디버깅(apple-craft), 코드 리뷰(apple-review), 장기 대규모 구현 하네스(apple-harness), Xcode MCP 연동, 최신 Apple API 참조 문서 내장"
}
```

### README.md

핵심 기능 표 아래에 family boundary를 짧게 추가:

```markdown
## 어떤 스킬이 언제 쓰이나

- 일반 구현/수정/디버깅/설명 → `apple-craft`
- 코드/PR 점검과 리뷰 → `apple-review`
- 처음부터/앱 전체/대규모 장기 구현 → `apple-harness`
```

## Batch 1 평가용 코퍼스

| ID | Prompt | Expected |
|---|---|---|
| AP-B1-01 | `SwiftUI 뷰 크래시 원인 찾아서 고쳐줘` | `apple-craft` |
| AP-B1-02 | `이 ViewModel async/await로 리팩토링해줘` | `apple-craft` |
| AP-B1-03 | `WKWebView를 SwiftUI에 붙여줘` | `apple-craft` |
| AP-B1-04 | `이 코드 리뷰해줘` | `apple-review` |
| AP-B1-05 | `PR #42 blocking issue 위주로 검토해줘` | `apple-review` |
| AP-B1-06 | `이 SwiftUI 파일 문제 있는지 한번 봐줘` | `apple-review` |
| AP-B1-07 | `새 iOS 앱 처음부터 만들어줘` | `apple-harness` |
| AP-B1-08 | `설정/온보딩/결제까지 포함한 앱 MVP 전체 구현해줘` | `apple-harness` |
| AP-B1-09 | `이 앱 전체 구조를 TCA로 전면 리팩토링해줘` | `apple-harness` |
| AP-B1-10 | `성능 문제만 리뷰해줘` | `apple-review` |
| AP-B1-11 | `성능 문제를 고쳐줘` | `apple-craft` |
| AP-B1-12 | `이 화면 하나만 손봐줘` | `apple-craft` |
| AP-B1-13 | `전체적으로 손봐줘` | `Ambiguous → clarification or harness/craft based on scope follow-up` |
| AP-B1-14 | `처음부터 끝까지 다 만들어줘` | `apple-harness` |
| AP-B1-15 | `이 코드 스타일 위주로 점검해줘` | `apple-review` |

## 예상 실패 패턴

### F1. `apple-craft`가 review 요청을 계속 흡수

원인 후보:
- broad description
- review example 존재
- plugin-level wording alignment 부족

### F2. `apple-harness`가 일반 리팩토링까지 가져감

원인 후보:
- `리팩토링` 단독 키워드가 너무 강함
- “대규모/전면/전체” scope gate 부족

### F3. `apple-review`가 “고쳐줘” 요청을 과도하게 잡음

원인 후보:
- “분석”, “inspect”, “check”가 구현 요청과 섞일 수 있음
- 실제 수정 intent에 대한 negative boundary 부족

## 적용 순서 제안

1. `apple-craft` description과 examples 정리
2. `apple-harness` description에서 bare `리팩토링` 축소
3. `apple-review` description에 negative boundary 추가
4. `plugin.json` / `README.md` 정렬
5. Batch 1 코퍼스로 베이스라인 vs 수정안 비교

## 메모

이번 배치는 **스킬 내부 실행 로직 변경 없이 wording만 조정하는 실험**으로 시작하는 것이 좋다.

이유:
- 어떤 wording이 실제 활성화에 영향을 주는지 분리해서 보기 쉽고
- 실패 시 롤백이 간단하며
- 다른 family에도 재사용 가능한 패턴을 뽑아낼 수 있다.
