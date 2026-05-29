---
name: ctx-verify
description: Runs 3-stage verification of a hierarchical context architecture — reference integrity, code reference validity, and content accuracy checked in sequence to produce a report. Triggers — 계층적 컨텍스트 검증, 참조 무결성, 코드 참조 검증, 내용 정확성, 컨텍스트 아키텍처 검증, ctx-verify.
argument-hint: "[stage number: 1|2|3|all (default: all)]"
---

# Context Architecture Verify

Performs 3-stage verification of a hierarchical context architecture. For the detailed verification procedure, see `references/verification-guide.md` in the `guide` skill.

Respond to the user in Korean.

## Execution Steps

### Step 0: Collect context files

Collect the following files across the project:
- `CLAUDE.md` (project root)
- `**/CLAUDE.md` (subdirectories — Claude Code on-demand auto-loading)
- `.claude/rules/*.md` (path-scoped rules)
- `AGENTS.md` (project root — not auto-loaded by Claude Code)
- `**/CONTEXT.md` (all directories — not auto-loaded by Claude Code)

If no files exist, output "컨텍스트 아키텍처가 아직 초기화되지 않았습니다. `/agent-context:init`을 먼저 실행하세요." and exit.

If a stage number is given as an argument, run only that stage. The default is `all` (run everything).

### Stage 1: Reference Integrity

1. Extract markdown links `[텍스트](경로)` and `@path/to/file` imports from all context files.
2. Check whether each link/import target file exists (use Glob).
3. Check that every context file is referenced by at least one parent file.
4. Check whether the root CLAUDE.md exists.
5. Output the results as a markdown table:

```markdown
## Stage 1: 참조 무결성 ✅/❌

| 상태 | 파일 | 항목 | 설명 |
|------|------|------|------|
| ❌ | src/CONTEXT.md | ./old/CONTEXT.md 링크 | 파일 존재하지 않음 |
| ⚠️ | tests/CONTEXT.md | (고립) | 상위에서 참조 없음 |
| ✅ | 전체 | 순환 참조 | 없음 |
```

### Stage 2: Code Reference Validation

1. Extract code references from all context files (CLAUDE.md, subdirectory CLAUDE.md, .claude/rules/, CONTEXT.md):
   - File paths in backticks: `` `src/handler.ts` ``
   - Key Files list items
   - import/require statements inside code blocks
2. Check whether each reference exists in the actual filesystem via Glob.
3. For references that do not exist, search for similar filenames (infer moves).
4. Check whether the build/test commands in CLAUDE.md are valid (cross-check against package.json scripts, etc.).
5. Output the results as a markdown table:

```markdown
## Stage 2: 코드 참조 검증 ✅/❌

| 상태 | 컨텍스트 파일 | 참조 | 비고 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | `npm run lint:fix` | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | `utils.ts` | src/shared/utils.ts로 이동 추정 |
| ✅ | src/api/CONTEXT.md | `handler.ts` | 존재 확인 |
```

### Stage 3: Content Accuracy

1. Extract technical claims from context documents:
   - "uses library X" → verify against package.json/Cargo.toml, etc.
   - "follows pattern Y" → attempt to verify from code structure
   - "build with command Z" → check actual runnability
2. Verify only the items that can be verified automatically.
3. Classify items needing manual verification as Info.
4. Output the results as a markdown table:

```markdown
## Stage 3: 내용 정확성 ✅/❌

| 상태 | 컨텍스트 파일 | 주장 | 실제 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | "Zustand 사용" | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | "RORO 패턴 준수" | 12/15 엔드포인트만 준수 |
| ℹ️ | src/api/CONTEXT.md | "P99 < 100ms" | 자동 검증 불가 |
```

### Stage 3.5: Codex Second-Pass Validation (optional)

After Stage 2/3 findings are complete, if the Codex skill is available, bring in `/codex:review` as a second-pass validator.

1. Run `/codex:review --wait` — target the context files verified in Stages 1–3.
2. Collect structured findings with `/codex:result`.
3. Cross-check the Codex findings:
   - Critical/Warning items missed in Stages 1–3 → add to the consolidated report with `source: "codex-second-pass"`
   - Items found by both → keep the existing finding (deduplicate)
   - Codex-only Info items → ignore

> **Guardrail**: The PASS/PARTIAL/FAIL verdict, anti-pattern deductions, and CLEAN criteria are owned by ctx-verify as the source of truth. Codex only supplements coverage.
> Skip this stage if the Codex skill is not installed.

### Final: Consolidated report

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

## Skeptical Re-verification Loop

> Principle: Generator-Evaluator **role separation** + **skeptical evaluation** (Anthropic Harness Design blog)
> "tuning a standalone evaluator to be skeptical turns out to be far more tractable
> than making a generator critical of its own work"

### Step 1: Define the Sprint Contract

**Before** starting automated fixes, agree on the completion criteria:

```markdown
## Sprint Contract
- 자동 수정 대상: [아래 표의 자동 수정 가능 항목]
- CLEAN 기준: Critical + Warning findings = 0
- 수동 조치 항목: [고립 파일 구조 변경, 수동 검증 필요 기술적 주장]
- 수정이 아닌 것: findings 삭제, 심각도 하향, 검증 기준 완화
```

### Step 2: Auto-fixable items

| Type | Stage | Fix method |
|------|-------|----------|
| Broken link (target file moved) | 1 | Update path to the similar filename |
| Code reference path mismatch | 2 | Locate current position via Glob → update path |
| Build/test command mismatch | 2 | Extract the exact command from package.json/Makefile → update |
| Library description mismatch | 3 | Extract the actual list from the dependency file → update |

Items requiring manual fixes are shown in the report only.

### Step 3: Skeptical re-verification

After fixing, switch to a **separate skeptical evaluator role** and re-verify.

**Skeptical evaluation perspective** (avoiding the self-evaluation trap):
1. Do the fixed paths/commands actually exist? — re-confirm with Glob/Read.
2. Did the fix break references in other context files? — trace the impact scope.
3. Compare before/after files to check for unintended content changes.
4. **If in doubt, fail** — at boundary scores (6-7), rule fail.
5. **Do not self-praise** — re-read the file before judging that "the fix was done well".

**3-axis multidimensional evaluation:**

| Axis | Weight | Description |
|----|--------|------|
| Reference Integrity | 40% | Link/import targets exist, no orphaned files |
| Code Sync | 35% | Code reference paths valid, build/test commands valid |
| Content Accuracy | 25% | Technical claims match reality |

Score calibration:

| Range | Reference Integrity | Code Sync | Content Accuracy |
|------|-----------|-----------|-----------|
| 9-10 | Links 100% valid + 0 orphans | All paths/commands valid | Technical claims 100% verified |
| 7-8 | Links valid, 1 orphan | 1-2 paths incomplete | Mostly accurate |
| 5-6 | 1-2 broken links | Build command mismatch | Major library mismatch |
| 3-4 | Many broken links | Core paths missing | Major technical claims inaccurate |
| 1-2 | Root CLAUDE.md missing | Most code references invalid | Content unrelated to reality |

Verdict: weighted average ≥7 PASS / 4-6 PARTIAL / <4 FAIL

**ctx-verify domain anti-patterns (automatic deductions):**

| Anti-pattern | Axis | Deduction |
|----------|-----|------|
| Circular reference | Reference Integrity | -3 |
| Link to a nonexistent file | Reference Integrity | -2 |
| Description of a removed library | Content Accuracy | -2 |
| Orphaned context file | Reference Integrity | -1 |
| Reference to a moved file not updated | Code Sync | -1 |
| Non-runnable build command | Code Sync | -1 |

**Artifact generation (required for 2+ rounds):**

At the end of each round, record into the `.claude/ctx-verify/` directory:

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

### Loop control

```
Round 1: Sprint Contract 정의 → Stage 1~3 검증 → 자동 수정 (사용자 승인)
Round 2: 회의적 재검증 (수정한 Stage만)
  → CLEAN → 완료
  → 잔여 findings → 추가 수정 + Round 3
Round 3: 회의적 재검증 (최종)
  → CLEAN → 완료
  → 잔여 → "수동 조치 필요" 리포트 출력 후 종료
```

**Termination conditions (any one met):**
1. The Sprint Contract's CLEAN criteria are met → **CLEAN**
2. This round's findings ≥ the previous round's → **CONVERGED** (the fix introduced new problems)
3. Round 3 complete → **MAX_ROUNDS**

**Add the loop history to the final report:**
```markdown
## 검증 루프 이력
| 라운드 | Sprint Contract | findings | 수정 | 잔여 | 가중평균 | 판정 |
|--------|----------------|----------|------|------|---------|------|
| 1 | Critical+Warning=0 | 4 | 3 | 1 | 5.8 | CONTINUE |
| 2 | Critical+Warning=0 | 1 | 0 | 1 | 6.2 | CONVERGED (수동 조치 필요) |
```
