# Loop Contract

A research loop must have a **scorable contract** before it starts.

## Field Descriptions

### 1. objective
One-sentence goal + 1-3 success criteria.
- Good: "Raise test coverage from 60% to 80%"
- Bad: "Improve code quality" (not measurable)

### 2. mode
One of `design` / `guided-loop` / `autonomous-loop`.
- Good: `guided-loop`
- Bad: unspecified (execution mode unclear)

### 3. mutable surface
Files, docs, prompts, and experiment variables that may change.
- Good: `src/utils/*.ts`, `tests/` directory
- Bad: "the whole project" (unbounded scope)

### 4. immutable constraints
Files, policies, dependencies, and external conditions that must not change.
- Good: `dependencies in package.json`, `public API signatures`
- Bad: unstated (what is protected is unclear)

### 5. hard gates
Deterministic checks that must pass. A fail means reject regardless of metric improvement.
- Good: `all of npm test passes`, `tsc --noEmit with 0 errors`
- Bad: "code must be clean" (not automatically verifiable)

### 6. primary metric
Top-priority number/judgment criterion. Keep it to **one** when possible.
- Good: `branch coverage % from jest --coverage`
- Bad: "overall quality score" (measurement method undefined)

### 7. tie-breakers
Secondary criteria when the primary metric is tied.
- Good: `fewer lines of code`, `lower cyclomatic complexity`
- Bad: "the better one" (no judgment criterion)

### 8. decision layers
How to record hard gate / experiment status / control action.
- Good: `hard gates=pass/fail, experiment status=keep/discard/crash, control action=pass/refine/pivot/rescope/escalate/stop`
- Bad: mixing the three layers into one cell

### 9. baseline
Current reference state. The starting point for comparison.
- Good: `branch coverage 62.3% (commit abc1234)`
- Bad: "current state" (no number)

### 10. evidence sources
Which logs, comparison tables, links, or tests decide the verdict.
- Good: `jest --coverage output`, `git diff --stat`
- Bad: "appropriate evidence" (no specificity)

### 11. budget
Maximum iteration count, time, cost, tokens, compute limits.
- Good: `max 5 rounds, within 30 minutes`
- Bad: unspecified (infinite loop risk)

### 12. stop condition
Termination condition and the condition for handing off to a human.
- Good: `coverage >= 80% or 3 consecutive rounds with improvement < 1%p`
- Bad: "when it's good enough" (not judgeable)

### 13. ledger
Experiment record location or table format.
- Good: `.codex-research/ledger.tsv`
- Bad: unspecified (risk of missing records)

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

- If there is no hard gate, first create the minimal rule that triggers "reject immediately on failure".
- Keep the primary metric to one. If only subjective quality exists, quantify the rubric first.
- In autonomous-loop, do not start if the contract is empty or ambiguous.
- Do not use the word `pass` as a bare word; expose the layer, as in `hard gates: pass` or `control action: pass`.
