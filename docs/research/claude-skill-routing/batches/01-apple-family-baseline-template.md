# Batch 1 — apple-craft Family 베이스라인 측정 템플릿

## 목적

`apple-craft` / `apple-review` / `apple-harness`의 **수정 전 라우팅 상태**를 동일한 기준으로 기록하기 위한 템플릿입니다.

이 문서는 실제 실험 실행 시 복사해서 사용합니다.

권장 파일명 예:

- `01-apple-family-baseline-2026-03-29.md`
- `01-apple-family-postpatch-2026-03-29.md`

---

## 실행 프로토콜

### 공통 규칙

1. **fresh session**에서 각 프롬프트를 테스트합니다.
2. 슬래시 커맨드 없이 **자연어만** 사용합니다.
3. 가능하면 이전 프롬프트의 문맥이 다음 판정에 영향을 주지 않게 합니다.
4. prompt wording은 corpus에 적힌 문장을 그대로 사용합니다.
5. 스킬이 명시적으로 응답에 드러나지 않으면, 응답 스타일과 제안된 다음 행동으로 판정합니다.

### 판정 우선순위

1. 응답에서 직접 언급한 skill/handoff
2. 응답의 주요 행동
   - 구현/수정/디버깅 중심 → `apple-craft`
   - 리뷰/검토/문제 식별 중심 → `apple-review`
   - 큰 범위 계획/전체 구현/장기 루프 중심 → `apple-harness`
3. 그래도 애매하면 `Ambiguous / Needs Clarification`

### 기록 규칙

- `Observed`에는 실제 선택된 스킬명을 적습니다.
- 확신이 낮으면 `Observed`에 `ambiguous`를 적고 Notes에 이유를 남깁니다.
- `Score`는 `05-evaluation-rubric.md` 기준을 따릅니다.

---

## 실행 메타데이터

| 항목 | 값 |
|---|---|
| Run name | |
| Date | |
| Branch | |
| Evaluator | |
| Claude Code version/context | |
| Notes | |

---

## 결과 기록표

| ID | Prompt | Expected | Observed | Score | Failure Type | Notes |
|---|---|---|---|---:|---|---|
| AP-B1-01 | `SwiftUI 뷰 크래시 원인 찾아서 고쳐줘` | `apple-craft` |  |  |  |  |
| AP-B1-02 | `이 ViewModel async/await로 리팩토링해줘` | `apple-craft` |  |  |  |  |
| AP-B1-03 | `WKWebView를 SwiftUI에 붙여줘` | `apple-craft` |  |  |  |  |
| AP-B1-04 | `이 코드 리뷰해줘` | `apple-review` |  |  |  |  |
| AP-B1-05 | `PR #42 blocking issue 위주로 검토해줘` | `apple-review` |  |  |  |  |
| AP-B1-06 | `이 SwiftUI 파일 문제 있는지 한번 봐줘` | `apple-review` |  |  |  |  |
| AP-B1-07 | `새 iOS 앱 처음부터 만들어줘` | `apple-harness` |  |  |  |  |
| AP-B1-08 | `설정/온보딩/결제까지 포함한 앱 MVP 전체 구현해줘` | `apple-harness` |  |  |  |  |
| AP-B1-09 | `이 앱 전체 구조를 TCA로 전면 리팩토링해줘` | `apple-harness` |  |  |  |  |
| AP-B1-10 | `성능 문제만 리뷰해줘` | `apple-review` |  |  |  |  |
| AP-B1-11 | `성능 문제를 고쳐줘` | `apple-craft` |  |  |  |  |
| AP-B1-12 | `이 화면 하나만 손봐줘` | `apple-craft` |  |  |  |  |
| AP-B1-13 | `전체적으로 손봐줘` | `ambiguous / clarification` |  |  |  |  |
| AP-B1-14 | `처음부터 끝까지 다 만들어줘` | `apple-harness` |  |  |  |  |
| AP-B1-15 | `이 코드 스타일 위주로 점검해줘` | `apple-review` |  |  |  |  |

---

## 요약 집계

| Metric | Count |
|---|---:|
| Exact Match | |
| Acceptable Fallback | |
| Ambiguous / Needs Clarification | |
| Wrong Skill | |
| No Useful Activation | |
| Total | 15 |

### 평균 점수

```text
Average Score = (모든 Score 합) / 15
```

### 실패 패턴 집계

| Failure Type | Count | Notes |
|---|---:|---|
| E1 Over-broad activation |  |  |
| E2 Under-activation |  |  |
| E3 Sibling collision |  |  |
| E4 Vocabulary gap |  |  |
| E5 Scope confusion |  |  |
| E6 Action confusion |  |  |

---

## 정성 메모

### 잘 된 점

- 

### 가장 자주 발생한 오판

- 

### boundary wording에서 특히 문제였던 표현

- 

### post-patch에서 꼭 다시 볼 프롬프트

- 

---

## Post-patch 비교용 체크포인트

수정 후 동일 코퍼스를 다시 돌릴 때 아래를 집중 비교합니다.

1. `이 코드 리뷰해줘`가 `apple-craft`로 잘못 가지 않는가
2. `리팩토링해줘`가 scope 없이도 `apple-harness`로 과도하게 가지 않는가
3. `처음부터`, `전체`, `전면`이 들어간 요청이 더 안정적으로 `apple-harness`로 가는가
4. `봐줘`, `점검해줘`, `검토해줘`가 `apple-review`로 더 잘 가는가
5. `고쳐줘`, `붙여줘`, `바꿔줘`가 `apple-review`로 잘못 가지 않는가
