# Skeptical Re-verification Protocol

> Inspired by Anthropic's [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) blog.
> The core is **Generator-Evaluator role separation** and **skeptical evaluation** — not the "adversariality" of a GAN.

## Design Principles

### Why separate the roles

> "tuning a standalone evaluator to be skeptical turns out to be far more tractable
> than making a generator critical of its own work"

The limit of self-evaluation: evaluating your own output tends to "praise your own work."
Setting up a separate **skeptical evaluator** role sidesteps this problem.

### Sprint Contract — a pre-agreed "done" criterion

> "the generator and evaluator negotiated a sprint contract: agreeing on what 'done'
> looked like for that chunk of work before any code was written"

Define the completion criteria clearly **before** starting the fix:
- Which findings are targets for automatic fixing
- What state counts as "CLEAN" after the fix
- Which items are left for manual action

This prior agreement is what lets the evaluator re-verify against consistent criteria.

### Tuning the skeptical evaluator

When re-verifying, hold these perspectives:
1. **Was the fix actually applied?** — Re-read the file to confirm the change
2. **Did the fix introduce new problems?** — Chain-verify the blast radius of the fix
3. **Did the fix merely relax the criteria?** — Deleting findings or lowering severity is not a fix
4. **When in doubt, do not pass** — When evaluation is ambiguous, the default is FAIL. At borderline scores (6-7), judge as not-passing
5. **No self-praise** — Before judging "well fixed," always Read the file again to secure evidence

## Core Loop

```
Phase 0: SPRINT CONTRACT — define "done" criterion
Phase 1: DIAGNOSE → REPORT → FIX (user approval)
Phase 2: RE-VERIFY (fixed items only, skeptical perspective) → REPORT
  ↓ (if residual findings remain)
Phase 3: FIX → RE-VERIFY → REPORT
  ↓
DONE when an exit condition is met
```

## Exit Conditions (loop ends if any one is met)

1. **CLEAN**: the "done" criterion defined in the Sprint Contract is met
2. **CONVERGED**: this round's findings count ≥ previous round (the fix introduced new problems)
3. **MAX_ROUNDS**: reached the maximum of 3 rounds
4. **USER_STOP**: the user requested a stop

## Re-verification Scope

Full re-verification is costly. Re-verify only **the fixed items + items that could be affected by the fix**.

Examples:
- `plugin.json` version fix → re-verify Stage 2 (plugin.json) + Stage 1 (marketplace sync)
- Context file path fix → re-verify Stage 1 (reference integrity) + Stage 2 (code references)

## Round Report Format

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

## Domain-Specific Multidimensional Evaluation Axes

Each skill defines evaluation axes suited to its own domain.
Limit axes to a minimum of 2 and a maximum of 5, and assign a weight to each axis.

### Axis Design Principles
1. Each axis must be **independently measurable** (no overlap)
2. **Always** define 1-10 calibration criteria per axis
3. Judge via weighted average: PASS(≥7) / PARTIAL(4-6) / FAIL(<4)

### Score Calibration Guide

| Range | Meaning |
|------|------|
| 9-10 | 100% of criteria met, even edge cases handled |
| 7-8  | Core criteria met, minor shortcomings |
| 5-6  | Basically works but has clear shortcomings |
| 3-4  | Only partially met |
| 1-2  | Incomplete or core behavior non-functional |

### Antipattern Penalty Rules

Each skill defines a domain-specific list of antipatterns:
- Critical antipattern: -3 points on that axis
- Warning antipattern: -1 point on that axis
- Minimum value after penalties is 1 point (prevents 0 or below)

## Artifact Generation Rules

Record each round's verification result to a file to ensure traceability:

- Fix round → `fix-round-{N}.md`: fixed items, changed files, before/after comparison
- Verify round → `verify-round-{N}.md`: per-axis scores, antipattern detection, judgment, fix instructions

Each skill defines the artifact paths. Artifact generation is optional, but required when proceeding to 2 or more rounds.

### verify-round-{N}.md Template

```markdown
# Verify Round {N}

## 평가 축 점수
| 축 | 가중치 | 점수 | 근거 |
|----|--------|------|------|
| {축1} | {W}% | {N}/10 | {구체적 근거} |

## 가중 평균: {N.N} → {PASS/PARTIAL/FAIL}

## 안티패턴 탐지
| 안티패턴 | 축 | 감점 | 상세 |
|----------|-----|------|------|

## 수정 지침 (PARTIAL/FAIL 시)
1. {파일}:{위치} — {구체적 수정 방법}
```

## Per-Skill Customization

Each skill adopts this protocol but customizes the following:
- **Sprint Contract criteria**: a "done" definition suited to the skill domain
- **Skeptical evaluation perspective**: the patterns where self-evaluation fails in that domain
- **Auto-fix scope**: which findings can be fixed automatically
- **Re-verification strategy**: which Stages to re-run

## Harness Simplification Principle

> "every component in a harness encodes an assumption about what the model can't do on its own,
> and those assumptions are worth stress testing"

As the model improves, the components of this protocol must be re-examined.
If the re-verification loop always ends CLEAN on round 1, the loop itself has become unnecessary.
