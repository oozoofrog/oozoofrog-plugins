---
name: ctx-verify
description: 계층적 컨텍스트 아키텍처의 3단계 검증을 실행합니다 — 참조 무결성, 코드 참조 유효성, 내용 정확성을 순차적으로 검사하여 리포트를 생성합니다.
argument-hint: "[stage 번호: 1|2|3|all (기본: all)]"
---

# Context Architecture Verify

계층적 컨텍스트 아키텍처의 3단계 검증을 수행한다. 상세 검증 절차는 `guide` 스킬의 `references/verification-guide.md`를 참조한다.

## Execution Steps

### Step 0: 컨텍스트 파일 수집

프로젝트 전체에서 다음 파일을 수집한다:
- `CLAUDE.md` (프로젝트 루트)
- `**/CLAUDE.md` (서브디렉토리 — Claude Code on-demand 자동 로딩)
- `.claude/rules/*.md` (경로별 규칙)
- `AGENTS.md` (프로젝트 루트 — Claude Code 자동 로딩 안 됨)
- `**/CONTEXT.md` (전체 디렉토리 — Claude Code 자동 로딩 안 됨)

파일이 하나도 없으면 "컨텍스트 아키텍처가 아직 초기화되지 않았습니다. `/agent-context:init`을 먼저 실행하세요."를 출력하고 종료한다.

인자로 stage 번호가 지정된 경우 해당 단계만 실행한다. 기본값은 `all` (전체 실행).

### Stage 1: 참조 무결성 (Reference Integrity)

1. 모든 컨텍스트 파일에서 마크다운 링크 `[텍스트](경로)` 및 `@path/to/file` import 추출
2. 각 링크/import의 대상 파일 존재 여부 확인 (Glob 사용)
3. 모든 컨텍스트 파일이 최소 하나의 상위 파일에서 참조되는지 확인
4. 루트 CLAUDE.md 존재 여부 확인
5. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 1: 참조 무결성 ✅/❌

| 상태 | 파일 | 항목 | 설명 |
|------|------|------|------|
| ❌ | src/CONTEXT.md | ./old/CONTEXT.md 링크 | 파일 존재하지 않음 |
| ⚠️ | tests/CONTEXT.md | (고립) | 상위에서 참조 없음 |
| ✅ | 전체 | 순환 참조 | 없음 |
```

### Stage 2: 코드 참조 검증 (Code Reference Validation)

1. 모든 컨텍스트 파일(CLAUDE.md, 서브디렉토리 CLAUDE.md, .claude/rules/, CONTEXT.md)에서 코드 참조 추출:
   - 백틱 내 파일 경로: `` `src/handler.ts` ``
   - Key Files 리스트 항목
   - 코드 블록 내 import/require 구문
2. 각 참조가 실제 파일시스템에 존재하는지 Glob으로 확인
3. 존재하지 않는 참조에 대해 유사 파일명 탐색 (이동 추정)
4. CLAUDE.md의 빌드/테스트 명령이 유효한지 확인 (package.json scripts 등과 대조)
5. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 2: 코드 참조 검증 ✅/❌

| 상태 | 컨텍스트 파일 | 참조 | 비고 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | `npm run lint:fix` | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | `utils.ts` | src/shared/utils.ts로 이동 추정 |
| ✅ | src/api/CONTEXT.md | `handler.ts` | 존재 확인 |
```

### Stage 3: 내용 정확성 (Content Accuracy)

1. 컨텍스트 문서에서 기술적 주장(claims) 추출:
   - "X 라이브러리 사용" → package.json/Cargo.toml 등에서 검증
   - "Y 패턴 준수" → 코드 구조에서 검증 시도
   - "Z 명령으로 빌드" → 실제 실행 가능성 확인
2. 자동 검증 가능한 항목만 검증 수행
3. 수동 검증 필요 항목은 Info로 분류
4. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 3: 내용 정확성 ✅/❌

| 상태 | 컨텍스트 파일 | 주장 | 실제 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | "Zustand 사용" | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | "RORO 패턴 준수" | 12/15 엔드포인트만 준수 |
| ℹ️ | src/api/CONTEXT.md | "P99 < 100ms" | 자동 검증 불가 |
```

### Stage 3.5: Codex Second-Pass Validation (선택적)

Stage 2/3 findings 완료 후, Codex 스킬이 사용 가능하면 `/codex:review`를 second-pass validator로 투입합니다.

1. `/codex:review --wait` 실행 — Stage 1~3에서 검증한 컨텍스트 파일을 대상으로 실행
2. `/codex:result`로 structured findings 수집
3. Codex findings 교차 대조:
   - Stage 1~3에서 놓친 Critical/Warning 항목 → 종합 리포트에 `source: "codex-second-pass"` 추가
   - 양쪽 모두 발견한 항목 → 기존 finding 유지 (중복 제거)
   - Codex-only Info 항목 → 무시

> **가드레일**: PASS/PARTIAL/FAIL 판정, 안티패턴 감점, CLEAN 기준은 기존 ctx-verify가 source of truth입니다. Codex는 coverage 보완 역할만 합니다.
> Codex 스킬 미설치 시 이 단계를 건너뜁니다.

### Final: 종합 리포트

```markdown
# 컨텍스트 아키텍처 검증 종합 리포트

## 요약
| 단계 | Critical | Warning | Info | 상태 |
|------|----------|---------|------|------|
| 참조 무결성 | 0 | 1 | 0 | 🟢 |
| 코드 참조 | 2 | 1 | 0 | 🔴 |
| 내용 정확성 | 1 | 1 | 2 | 🟡 |

## 전체 건전성: 🟡 양호 (주의 필요)

## 우선 조치 항목
1. [Critical] ...
2. [Critical] ...
3. [Warning] ...
```

## 회의적 수정-재검증 루프 (Skeptical Re-verification)

> 원칙: Generator-Evaluator **역할 분리** + **회의적 평가** (Anthropic Harness Design 블로그)
> "tuning a standalone evaluator to be skeptical turns out to be far more tractable
> than making a generator critical of its own work"

### Step 1: Sprint Contract 정의

자동 수정을 시작하기 **전에** 완료 기준을 합의한다:

```markdown
## Sprint Contract
- 자동 수정 대상: [아래 표의 자동 수정 가능 항목]
- CLEAN 기준: Critical + Warning findings = 0
- 수동 조치 항목: [고립 파일 구조 변경, 수동 검증 필요 기술적 주장]
- 수정이 아닌 것: findings 삭제, 심각도 하향, 검증 기준 완화
```

### Step 2: 자동 수정 가능 항목

| 유형 | Stage | 수정 방식 |
|------|-------|----------|
| 깨진 링크 (대상 파일 이동됨) | 1 | 유사 파일명으로 경로 갱신 |
| 코드 참조 경로 불일치 | 2 | Glob으로 현재 위치 탐색 → 경로 갱신 |
| 빌드/테스트 명령 불일치 | 2 | package.json/Makefile에서 정확한 명령 추출 → 갱신 |
| 라이브러리 기술 불일치 | 3 | 의존성 파일에서 실제 목록 추출 → 갱신 |

수동 수정 필요 항목은 리포트에만 표시한다.

### Step 3: 회의적 재검증

수정 후, **별도의 회의적 평가자 역할**로 전환하여 재검증한다.

**회의적 평가 관점** (자기평가 함정 회피):
1. 수정된 경로/명령이 실제로 존재하는가? — Glob/Read로 재확인
2. 수정이 다른 컨텍스트 파일의 참조를 깨뜨리지 않았는가? — 영향 범위 추적
3. 수정 전후 파일을 비교하여 의도하지 않은 내용 변경이 없는가?
4. **의심스러우면 불통과** — 점수 경계값(6-7)에서는 불통과로 판정
5. **자기칭찬 금지** — "수정이 잘 되었다"는 판단 전에 반드시 파일을 다시 Read

**3축 다차원 평가:**

| 축 | 가중치 | 설명 |
|----|--------|------|
| 참조 무결성 (Reference Integrity) | 40% | 링크/import 대상 존재, 고립 파일 없음 |
| 코드 동기화 (Code Sync) | 35% | 코드 참조 경로 유효, 빌드/테스트 명령 유효 |
| 내용 정확성 (Content Accuracy) | 25% | 기술적 주장이 실제와 일치 |

점수 캘리브레이션:

| 구간 | 참조 무결성 | 코드 동기화 | 내용 정확성 |
|------|-----------|-----------|-----------|
| 9-10 | 링크 100% 유효 + 고립 0 | 모든 경로/명령 유효 | 기술 주장 100% 검증 |
| 7-8 | 링크 유효, 고립 1개 | 경로 1-2개 미비 | 대부분 정확 |
| 5-6 | 깨진 링크 1-2개 | 빌드 명령 불일치 | 주요 라이브러리 불일치 |
| 3-4 | 깨진 링크 다수 | 핵심 경로 부재 | 주요 기술 주장 부정확 |
| 1-2 | 루트 CLAUDE.md 부재 | 코드 참조 대부분 무효 | 실제와 무관한 내용 |

판정: 가중 평균 ≥7 PASS / 4-6 PARTIAL / <4 FAIL

**ctx-verify 도메인 안티패턴 (자동 감점):**

| 안티패턴 | 축 | 감점 |
|----------|-----|------|
| 순환 참조 | 참조 무결성 | -3 |
| 존재하지 않는 파일 링크 | 참조 무결성 | -2 |
| 삭제된 라이브러리 기술 | 내용 정확성 | -2 |
| 고립된 컨텍스트 파일 | 참조 무결성 | -1 |
| 이동된 파일의 참조 미갱신 | 코드 동기화 | -1 |
| 실행 불가능한 빌드 명령 | 코드 동기화 | -1 |

**산출물 생성 (2라운드 이상 시 필수):**

각 라운드 종료 시 `.claude/ctx-verify/` 디렉토리에 기록한다:

```markdown
# Verify Round {N} — Context Architecture

## 평가 축 점수
| 축 | 가중치 | 점수 | 근거 |
|----|--------|------|------|
| 참조 무결성 | 40% | {N}/10 | {구체적 근거} |
| 코드 동기화 | 35% | {N}/10 | {구체적 근거} |
| 내용 정확성 | 25% | {N}/10 | {구체적 근거} |
| **가중 평균** | | **{N.N}** | **{PASS/PARTIAL/FAIL}** |

## 안티패턴 탐지
| 안티패턴 | 축 | 감점 | 상세 |
|----------|-----|------|------|

## 수정 지침 (PARTIAL/FAIL 시)
1. {파일}:{위치} — {구체적 수정 방법}
```

### 루프 제어

```
Round 1: Sprint Contract 정의 → Stage 1~3 검증 → 자동 수정 (사용자 승인)
Round 2: 회의적 재검증 (수정한 Stage만)
  → CLEAN → 완료
  → 잔여 findings → 추가 수정 + Round 3
Round 3: 회의적 재검증 (최종)
  → CLEAN → 완료
  → 잔여 → "수동 조치 필요" 리포트 출력 후 종료
```

**종료 조건 (하나라도 충족 시):**
1. Sprint Contract의 CLEAN 기준 충족 → **CLEAN**
2. 이번 라운드 findings ≥ 이전 라운드 → **CONVERGED** (수정이 새 문제 유발)
3. 라운드 3 완료 → **MAX_ROUNDS**

**최종 리포트에 루프 이력 추가:**
```markdown
## 검증 루프 이력
| 라운드 | Sprint Contract | findings | 수정 | 잔여 | 가중평균 | 판정 |
|--------|----------------|----------|------|------|---------|------|
| 1 | Critical+Warning=0 | 4 | 3 | 1 | 5.8 | CONTINUE |
| 2 | Critical+Warning=0 | 1 | 0 | 1 | 6.2 | CONVERGED (수동 조치 필요) |
```
