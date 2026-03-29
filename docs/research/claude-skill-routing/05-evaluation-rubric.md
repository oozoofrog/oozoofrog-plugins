# Evaluation Rubric

## 평가 목적

각 자연어 프롬프트에 대해 Claude Code가 선택한 스킬이 얼마나 적절한지 일관되게 판정한다.

## 판정 등급

### 1) Exact Match

- 기대 스킬과 동일한 스킬을 선택함
- 가장 이상적인 결과

### 2) Acceptable Fallback

- 기대 스킬은 아니지만, 같은 family 안에서 사용자가 크게 어색함을 느끼지 않을 차선 선택
- 예: 설명 요청인데 `apple-craft`가 잡힌 경우, 결과가 실질적으로 충분하면 제한적으로 허용

### 3) Ambiguous / Needs Clarification

- 프롬프트 자체가 모호해서 확인 질문이 합리적인 경우
- 단, 너무 많은 확인 질문은 recall 저하로 본다

### 4) Wrong Skill

- 다른 sibling이나 전혀 다른 스킬로 잘못 라우팅됨
- 사용자가 체감상 “왜 이 스킬이 나왔지?”라고 느낄 가능성이 큼

### 5) No Useful Activation

- 적절한 스킬을 쓰지 않고 일반 답변으로 흘러감
- 자연어 활성화 개선 연구에서 중요한 실패 유형

## 점수 기준

| 등급 | 점수 |
|---|---|
| Exact Match | 1.0 |
| Acceptable Fallback | 0.5 |
| Ambiguous / Needs Clarification | 0.25 |
| Wrong Skill | 0.0 |
| No Useful Activation | 0.0 |

## 오류 분류

### E1. Over-broad activation

- 특정 스킬이 지나치게 넓게 잡히는 경우
- 예: `apple-craft`가 리뷰/하네스까지 삼켜버림

### E2. Under-activation

- 적절한 스킬이 있는데도 활성화되지 않음

### E3. Sibling collision

- 같은 family 내부에서 잘못된 스킬이 선택됨

### E4. Vocabulary gap

- 실제 사용자 표현이 description/examples에 없어서 놓침

### E5. Scope confusion

- 작은 작업 vs 전체 작업 구분 실패

### E6. Action confusion

- 설계 / 생성 / 검증 / 감사 같은 동사 구분 실패

## 리포트 형식

각 실험은 아래 형식으로 요약한다.

```markdown
## Batch X 결과

- 대상 스킬:
- 변경 내용:
- 코퍼스 범위:
- Exact:
- Acceptable:
- Ambiguous:
- Wrong:
- No useful activation:

### 주요 실패 패턴
- ...

### 해석
- ...

### 다음 액션
- ...
```

## 채점 원칙

- “실행 결과가 좋아 보인다”보다 **선택된 스킬의 적합성**을 우선 본다.
- sibling skill이 명확히 있는 경우에는 관대하게 넘기지 않는다.
- 설명형 프롬프트에 구현형 스킬이 잡히는 것은 기본적으로 감점한다.
- 다만 family 대표 스킬이 의도적으로 broad하게 설계된 경우는 `Acceptable Fallback` 가능성을 열어 둔다.
