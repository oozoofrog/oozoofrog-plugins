# Adversarial Evaluation Protocol

> GAN-inspired 적대적 평가 루프 프로토콜.
> Generator(진단+수정)와 Discriminator(재검증)를 단일 스킬 내에서 역할 분리하여 수렴까지 반복한다.

## Core Loop

```
Round 1: DIAGNOSE → REPORT → FIX (사용자 승인)
         ↓
Round 2: RE-VERIFY (수정 항목만) → REPORT
         ↓ (잔여 findings 있으면)
Round 3: FIX → RE-VERIFY → REPORT
         ↓
종료 조건 충족 시 DONE
```

## 종료 조건 (하나라도 충족 시 루프 종료)

1. **CLEAN**: Critical + Warning findings = 0
2. **CONVERGED**: 이번 라운드 findings 수 ≥ 이전 라운드 (수렴 실패 = 수정이 새 문제 유발)
3. **MAX_ROUNDS**: 최대 3 라운드 도달
4. **USER_STOP**: 사용자가 중단 요청

## 재검증 범위

전체 재검증은 비용이 크다. **이전 라운드에서 수정한 항목 + 수정에 의해 영향받을 수 있는 항목**만 재검증한다.

예시:
- `plugin.json` version 수정 → Stage 2 (plugin.json) + Stage 1 (marketplace 동기화) 재검증
- 컨텍스트 파일 경로 수정 → Stage 1 (참조 무결성) + Stage 2 (코드 참조) 재검증

## 라운드 리포트 형식

```markdown
## Round {N} 결과

| 지표 | 값 |
|------|-----|
| 이전 findings | {prev_count} |
| 수정 시도 | {fix_count} |
| 잔여 findings | {remaining_count} |
| 신규 findings | {new_count} |
| 판정 | CLEAN / CONTINUE / CONVERGED |

### 잔여 항목
| 심각도 | 항목 | 이유 |
|--------|------|------|
| ... | ... | ... |
```

## 스킬별 커스터마이징

각 스킬은 이 프로토콜을 채택하되, 다음을 커스터마이징한다:
- **평가 축**: 스킬의 도메인에 맞는 검증 기준
- **자동 수정 범위**: 어떤 findings를 자동 수정할 수 있는지
- **재검증 전략**: 어떤 Stage를 다시 실행할지
- **종료 임계값**: CLEAN 기준 (Critical만? Warning도?)
