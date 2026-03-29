# Batch 1 — apple-craft Family Baseline Run (2026-03-29)

> 상태: **측정 전 초안**
>
> 이 파일은 Batch 1의 **pre-patch baseline** 결과를 기록하기 위한 실행본입니다.
> 현재 브랜치에는 이미 wording 패치가 적용되어 있으므로, 실제 baseline 측정은 **패치 이전 기준**(예: `main` 또는 patch 전 커밋)에서 수행해야 합니다.

---

## 실행 메타데이터

| 항목 | 값 |
|---|---|
| Run name | `batch-1-apple-family-baseline` |
| Date | `2026-03-29` |
| Branch | `main` 또는 patch 이전 기준 브랜치 |
| Evaluator | `Codex / Claude Code manual routing check` |
| Claude Code version/context | `TBD` |
| Notes | `patch 이전 상태에서 fresh session 기준으로 다시 측정 필요` |

---

## 실행 프로토콜

1. 각 프롬프트를 **fresh session**에서 실행
2. 슬래시 커맨드 없이 **자연어만** 사용
3. 이전 응답 문맥이 다음 프롬프트에 영향을 주지 않게 분리
4. `05-evaluation-rubric.md` 기준으로 score/failure type 기록

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

## 집계

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

### 메모

- 예상 핵심 체크:
  - `apple-craft`가 review 요청을 얼마나 흡수하는가
  - `apple-harness`가 일반 리팩토링까지 얼마나 가져가는가
  - `봐줘/점검해줘`가 review로 안정적으로 가는가
