# Loop Contract

연구 루프는 시작 전에 반드시 **채점 가능한 계약**을 가져야 합니다.

## 필드 설명

### 1. objective
한 문장 목표 + 성공 기준 1~3개.
- Good: "테스트 커버리지를 60%에서 80%로 올린다"
- Bad: "코드 품질을 개선한다" (측정 불가)

### 2. mode
`design` / `guided-loop` / `autonomous-loop` 중 하나.
- Good: `guided-loop`
- Bad: 미지정 (어떤 실행 방식인지 불명확)

### 3. mutable surface
바꿀 수 있는 파일, 문서, 프롬프트, 실험 변수.
- Good: `src/utils/*.ts`, `tests/` 디렉토리
- Bad: "프로젝트 전체" (범위 무제한)

### 4. immutable constraints
바꾸면 안 되는 파일, 정책, 의존성, 외부 조건.
- Good: `package.json의 dependencies`, `public API 시그니처`
- Bad: 미기재 (무엇이 보호되는지 불명확)

### 5. hard gates
반드시 통과해야 하는 결정적 검사. fail이면 metric 개선과 무관하게 reject.
- Good: `npm test 전체 통과`, `tsc --noEmit 에러 0`
- Bad: "코드가 깨끗해야 한다" (자동 검증 불가)

### 6. primary metric
최우선 숫자/판정 기준. 가능한 한 **하나**로 유지.
- Good: `jest --coverage의 branch coverage %`
- Bad: "전반적 품질 점수" (측정 방법 미정의)

### 7. tie-breakers
primary metric이 동점일 때 보는 2차 기준.
- Good: `코드 줄 수가 적은 쪽`, `복잡도(cyclomatic) 낮은 쪽`
- Bad: "더 나은 쪽" (판정 기준 없음)

### 8. decision layers
hard gate / experiment status / control action을 어떻게 기록할지.
- Good: `hard gates=pass/fail, experiment status=keep/discard/crash, control action=pass/refine/pivot/rescope/escalate/stop`
- Bad: 세 층위를 한 칸에 혼합

### 9. baseline
현재 기준 상태. 비교의 출발점.
- Good: `branch coverage 62.3% (commit abc1234)`
- Bad: "현재 상태" (수치 없음)

### 10. evidence sources
어떤 로그, 비교표, 링크, 테스트로 판정할지.
- Good: `jest --coverage 출력`, `git diff --stat`
- Bad: "적절한 근거" (구체성 없음)

### 11. budget
최대 반복 수, 시간, 비용, 토큰, 컴퓨트 한도.
- Good: `max 5 rounds, 30분 이내`
- Bad: 미지정 (무한 루프 위험)

### 12. stop condition
종료 조건과 사람에게 넘길 조건.
- Good: `coverage >= 80% 또는 3라운드 연속 개선 < 1%p`
- Bad: "충분히 좋아지면" (판정 불가)

### 13. ledger
실험 기록 위치 또는 표 형식.
- Good: `.codex-research/ledger.tsv`
- Bad: 미지정 (기록 누락 위험)

## Markdown Template

```md
## Research Contract
- objective: ...
- mode: design | guided-loop | autonomous-loop
- mutable surface: ...
- immutable constraints: ...
- hard gates: ...
- primary metric: ...
- tie-breakers: ...
- decision layers: hard gates=pass/fail, experiment status=keep/discard/crash, control action=pass/refine/pivot/rescope/escalate/stop
- baseline: ...
- evidence sources: ...
- budget: ...
- stop condition: ...
- ledger: .codex-research/ledger.tsv
```

## Design Notes

- hard gate가 없다면, "실패하면 즉시 reject" 되는 최소 규칙을 먼저 만듭니다.
- primary metric은 하나로 유지합니다. subjective quality만 있으면 rubric을 먼저 수치화합니다.
- autonomous-loop에서는 contract가 비어 있거나 모호하면 시작하지 않습니다.
- `pass`라는 단어는 bare word로 쓰지 말고, `hard gates: pass` 또는 `control action: pass`처럼 층위를 드러냅니다.
