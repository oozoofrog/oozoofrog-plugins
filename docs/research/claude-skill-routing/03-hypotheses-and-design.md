# Hypotheses and Research Design

## 핵심 가설

### H1. Description 폭보다 Boundary 선명도가 더 중요하다

가설:
- 단순히 키워드를 많이 넣는 것보다,
- “이 스킬은 이런 요청에 쓰고, 저런 요청에는 다른 sibling을 쓴다”는 문장이 더 큰 개선을 만든다.

검증:
- 충돌군 스킬의 description만 확장한 버전과
- boundary 문장 + examples를 함께 정리한 버전을 비교한다.

### H2. 한국어 구어체 예시가 활성화 recall을 높인다

가설:
- 정제된 문장보다 “봐줘”, “손봐줘”, “넘겨보자”, “한번 체크해줘” 같은 표현이 예시에 들어갈 때 자연어 활성화가 더 잘 된다.

검증:
- formal phrasing 중심 코퍼스와 colloquial phrasing 포함 코퍼스를 따로 돌린다.

### H3. apple-craft 계열은 scope wording이 핵심이다

가설:
- `apple-craft` vs `apple-harness`는 기술 키워드보다 **범위 키워드**가 승부를 가른다.
- 예: “처음부터”, “전체”, “대규모”, “앱 만들어”, “기능 전체 구현”

검증:
- 동일 작업을 small / medium / large scope 문장으로 바꾸어 기대 스킬이 유지되는지 본다.

### H4. agent-context 계열은 action verb가 핵심이다

가설:
- `guide/init/verify/audit`는 도메인 키워드보다 동사 차별화가 중요하다.
- 설계하다 / 초기화하다 / 검증하다 / 감사하다

검증:
- 동일 대상(예: `CLAUDE.md`)에 대해 동사만 바꾼 프롬프트 세트를 만든다.

### H5. 외부 위임 계열은 target model 명시성이 핵심이다

가설:
- `Codex`, `GPT`, `리서치`, `프롬프트`, `넘겨` 같은 explicit target 표현이 강하게 작동한다.

검증:
- 모델 명시 / 모델 암시 / 모델 미명시 3단계 문장을 비교한다.

## 실험 설계

## 1. Baseline 측정

변경 없이 현재 wording 기준으로 평가한다.

측정 항목:
- exact match
- acceptable sibling fallback
- wrong skill
- no activation / generic response

## 2. Intervention 단위

한 번에 하나씩 바꾼다.

우선순위:
1. `SKILL.md` description
2. example 추가/교체
3. boundary 문장 추가
4. plugin.json description 정렬
5. README wording 보조 정렬

## 3. 실험 묶음

### Batch A — apple-craft family

- `apple-craft`
- `apple-harness`
- `apple-review`

목표:
- 개발 / 리뷰 / 대규모 구현의 삼자 분리를 안정화

### Batch B — agent-context family

- `ctx-guide`
- `ctx-init`
- `ctx-verify`
- `ctx-audit`

목표:
- 같은 도메인 안에서 action 기반 분기 강화

### Batch C — delegation / automation family

- `gpt-research`
- `hey-codex`
- `app-automation`
- `os-log`

목표:
- 목적과 출력물 유형이 다른 스킬의 경계 정리

## 실험 결과로 남겨야 할 것

- 어떤 문장 수정이 어떤 프롬프트 군에서 개선을 만들었는지
- false positive를 줄였지만 recall도 같이 떨어졌는지
- 특정 스킬이 sibling보다 지나치게 broad한지
- 아예 별도 상위 라우팅 스킬이 필요한지

## 초안 권고

초기 연구는 다음 순서로 진행한다.

1. `apple-craft` family
2. `agent-context` family
3. `gpt-research` / `hey-codex`
4. `app-automation` / `os-log`

이 순서가 좋은 이유:
- 실제 충돌 비용이 큰 곳부터 정리할 수 있고,
- 이후 wording 패턴을 다른 플러그인에 재사용하기 쉽다.
