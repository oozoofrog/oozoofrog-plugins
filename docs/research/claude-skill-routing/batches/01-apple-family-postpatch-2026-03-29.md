# Batch 1 — apple-craft Family Post-patch Run (2026-03-29)

> 상태: **측정 전 초안**
>
> 이 파일은 Batch 1 wording 패치 이후의 **post-patch** 결과를 기록하기 위한 실행본입니다.
> 현재 브랜치 `codex/research-claude-code-natural-language-skill-routing` 기준으로 측정합니다.

---

## 실행 메타데이터

| 항목 | 값 |
|---|---|
| Run name | `batch-1-apple-family-postpatch` |
| Date | `2026-03-29` |
| Branch | `codex/research-claude-code-natural-language-skill-routing` |
| Evaluator | `Codex / Claude Code manual routing check` |
| Claude Code version/context | `TBD` |
| Notes | `Batch 1 wording patch applied` |

---

## 패치 범위 요약

- `apple-craft`를 일반 구현/수정/디버깅 중심으로 정리
- `apple-review`를 리뷰 전용 스킬로 더 선명하게 정리
- `apple-harness`를 scope-driven 장기 구현 하네스로 정리
- plugin/README/marketplace 설명도 family 구조에 맞게 정렬

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

---

## baseline 대비 비교 메모

### 기대 개선

- 리뷰 요청의 `apple-review` 유입 증가
- 일반 리팩토링/수정 요청의 `apple-craft` 유지
- from-scratch / 전체 / 전면 요청의 `apple-harness` 유입 증가

### 꼭 확인할 항목

- `AP-B1-04`, `AP-B1-05`, `AP-B1-06`, `AP-B1-10`, `AP-B1-15`
- `AP-B1-07`, `AP-B1-08`, `AP-B1-09`, `AP-B1-14`
- `AP-B1-13`는 여전히 clarification이 필요한 모호 케이스인지 확인
