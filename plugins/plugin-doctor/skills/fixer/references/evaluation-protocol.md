# Skeptical Re-verification Protocol

> Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) 블로그에서 영감.
> GAN의 "적대성"이 아닌 **Generator-Evaluator 역할 분리**와 **회의적 평가**가 핵심.

## 설계 원칙

### 왜 역할을 분리하는가

> "tuning a standalone evaluator to be skeptical turns out to be far more tractable
> than making a generator critical of its own work"

자기평가의 한계: 생성한 결과물을 스스로 평가하면 "자신의 작업을 칭찬하는" 경향이 있다.
별도의 **회의적 평가자** 역할을 설정하면 이 문제를 우회할 수 있다.

### Sprint Contract — 사전 합의된 "done" 기준

> "the generator and evaluator negotiated a sprint contract: agreeing on what 'done'
> looked like for that chunk of work before any code was written"

수정을 시작하기 **전에** 완료 기준을 명확히 정의한다:
- 어떤 findings가 자동 수정 대상인지
- 수정 후 어떤 상태가 "CLEAN"인지
- 어떤 항목은 수동 조치로 남기는지

이 사전 합의가 있어야 평가자가 일관된 기준으로 재검증할 수 있다.

### 회의적 평가자 튜닝

재검증 시 다음 관점을 유지한다:
1. **수정이 실제로 적용되었는가?** — 파일을 다시 읽어서 변경 확인
2. **수정이 새로운 문제를 유발하지 않았는가?** — 수정 영향 범위의 연쇄 검증
3. **수정이 기준을 완화한 것은 아닌가?** — findings를 삭제하거나 심각도를 낮춘 것은 수정이 아님

## Core Loop

```
Phase 0: SPRINT CONTRACT — "done" 기준 정의
Phase 1: DIAGNOSE → REPORT → FIX (사용자 승인)
Phase 2: RE-VERIFY (수정 항목만, 회의적 관점) → REPORT
  ↓ (잔여 findings 있으면)
Phase 3: FIX → RE-VERIFY → REPORT
  ↓
종료 조건 충족 시 DONE
```

## 종료 조건 (하나라도 충족 시 루프 종료)

1. **CLEAN**: Sprint Contract에 정의된 "done" 기준 충족
2. **CONVERGED**: 이번 라운드 findings 수 ≥ 이전 라운드 (수정이 새 문제를 유발)
3. **MAX_ROUNDS**: 최대 3 라운드 도달
4. **USER_STOP**: 사용자가 중단 요청

## 재검증 범위

전체 재검증은 비용이 크다. **수정한 항목 + 수정에 의해 영향받을 수 있는 항목**만 재검증한다.

예시:
- `plugin.json` version 수정 → Stage 2 (plugin.json) + Stage 1 (marketplace 동기화) 재검증
- 컨텍스트 파일 경로 수정 → Stage 1 (참조 무결성) + Stage 2 (코드 참조) 재검증

## 라운드 리포트 형식

```markdown
## Round {N} 결과

| 지표 | 값 |
|------|-----|
| Sprint Contract | {기준 요약} |
| 이전 findings | {prev_count} |
| 수정 시도 | {fix_count} |
| 잔여 findings | {remaining_count} |
| 신규 findings (수정 유발) | {new_count} |
| 판정 | CLEAN / CONTINUE / CONVERGED |
```

## 스킬별 커스터마이징

각 스킬은 이 프로토콜을 채택하되, 다음을 커스터마이징한다:
- **Sprint Contract 기준**: 스킬 도메인에 맞는 "done" 정의
- **회의적 평가 관점**: 해당 도메인에서 자기평가가 실패하는 패턴
- **자동 수정 범위**: 어떤 findings를 자동 수정할 수 있는지
- **재검증 전략**: 어떤 Stage를 다시 실행할지

## 하네스 간소화 원칙

> "every component in a harness encodes an assumption about what the model can't do on its own,
> and those assumptions are worth stress testing"

모델이 개선되면 이 프로토콜의 구성요소도 재검토해야 한다.
재검증 루프가 항상 1라운드에 CLEAN으로 종료된다면, 루프 자체가 불필요해진 것이다.
