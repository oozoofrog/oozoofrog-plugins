---
name: fixer
description: Audits, fixes, and improves every plugin in the marketplace against Claude Code official standards. plugin-doctor itself is included in the audit scope. Use on requests like "플러그인 점검", "plugin doctor", "플러그인 검증", "plugin validate", "플러그인 수정", "plugin fix", "마켓플레이스 검증", "플러그인 건강 검진".
argument-hint: "[plugin name (audit all if omitted)] [--update-spec: refresh official docs]"
---

# Plugin Doctor

Diagnose every plugin in the marketplace against Claude Code official standards, and fix auto-fixable issues immediately. plugin-doctor itself is included in the audit scope.

Respond to the user in Korean.

## Official Spec Reference

Validation criteria live in `references/official-spec.md`. It is refreshed automatically in Stage 0.

## Arguments

- No `$ARGUMENTS` → audit the whole marketplace
- Plugin name in `$ARGUMENTS` → audit only that plugin
- `--update-spec` → force-run Stage 0

## Diagnostic Process

### Stage 0: Official Spec Self-Update

Run only when the `--update-spec` argument is present, or when the `Last updated` date in `references/official-spec.md` is more than 30 days old.

1. Read `references/official-spec.md` and check the `Last updated` date
2. If a refresh is needed, fetch the official docs with WebFetch:
   - `https://docs.anthropic.com/en/docs/claude-code/plugins`
   - `https://docs.anthropic.com/en/docs/claude-code/skills`
   - `https://docs.anthropic.com/en/docs/claude-code/agents`
   - `https://docs.anthropic.com/en/docs/claude-code/hooks`
3. Detect new fields, changed rules, added events, etc.
4. If there are changes, update `references/official-spec.md` and refresh `Last updated`
5. If there are no changes, update only the date

### Stage 1: Marketplace Validation

Validate `.claude-plugin/marketplace.json`.

**Checks:**
1. Valid JSON parsing
2. Required fields present: `name`, `owner.name`
3. `version` field in SemVer format (regex: `^\d+\.\d+\.\d+$`)
4. For each entry in the `plugins[]` array:
   - `name` field present + kebab-case (regex: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`)
   - `source` field present
   - For relative-path sources, check it starts with `./`
   - Check the source path exists as a real directory via Glob
5. Detect duplicate plugin names

### Stage 2: plugin.json Validation

Validate each plugin's `.claude-plugin/plugin.json`.

**Checks:**
1. File existence (Warning if missing)
2. Valid JSON parsing
3. `name` field: present + kebab-case
4. `version` field: present (Warning if missing) + SemVer format
5. `description` field: present (Info if missing)
6. `author` field: present (Info if missing)
7. **Version sync**: check it matches the version in marketplace.json (Critical on mismatch)
8. If custom paths (commands, agents, skills, hooks, etc.) are configured, check those paths exist

### Stage 3: Skill Validation

Validate each plugin's `skills/*/SKILL.md`.

**Checks:**
1. Valid YAML frontmatter parsing
2. `name` field: kebab-case, max 64 chars
3. `description` field: presence (Warning if missing)
   - Check it contains trigger keywords (Korean/English mix recommended)
4. `allowed-tools` field:
   - Presence (Warning if missing)
   - Check it is in YAML list format (comma-separated string → Warning + auto-fix suggestion)
   - Each tool name valid: built-in tools (Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch, NotebookEdit, NotebookRead) or the `mcp__*` pattern
5. `model` field: valid value (sonnet, haiku, opus, or full model ID)
6. `effort` field: valid value (low, medium, high, max)
7. `context` field: when using `fork`, check the `agent` field is also set
8. **Deprecated commands/ detection**: if a `commands/` directory exists → Critical + provide a skills-migration guide

### Stage 4: Agent Validation

Validate each plugin's `agents/*.md`.

**Checks:**
1. Valid YAML frontmatter parsing
2. Required fields: `name` (kebab-case), `description`
3. `tools` field: tool-name validity (same criteria as Stage 3)
4. `model` field: valid value (sonnet, haiku, opus, inherit)
5. `maxTurns` field: check it is a positive integer
6. **Plugin agent restrictions**: Warning if `hooks`, `mcpServers`, or `permissionMode` fields are present (ignored in plugin agents)
7. `whenToUse` field: check it contains an `<example>` tag (Info if missing)
8. `color` field: presence (Info if missing)

### Stage 5: Hook Validation

Validate each plugin's `hooks/hooks.json` or the `hooks` field inside `plugin.json`.

**Checks:**
1. Valid JSON parsing
2. Check the event name is one of the 25 official events:
   `SessionStart, InstructionsLoaded, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, TeammateIdle, Stop, StopFailure, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd`
3. Check the matcher pattern is a valid regex
4. Hook type: check it is one of `command`, `http`, `prompt`, `agent`
5. `command`-type hooks:
   - Check the script file path exists
   - Check it has execute permission (+x)
   - Check `$CLAUDE_PLUGIN_ROOT` is used correctly
6. `timeout` field: check it is a positive integer

### Stage 6: Structure Validation

Validate each plugin's overall directory structure.

**Checks:**
1. `README.md` presence (Warning if missing)
2. Detect empty directories: `commands/`, `agents/`, `skills/`, etc. with no content (Warning)
3. Naming consistency: Warning if `reference/` and `references/` directories coexist within the same skill
4. Critical if components other than `plugin.json` (commands, agents, etc.) live inside the `.claude-plugin/` directory (wrong location)
5. Whether file paths contain `../` (path-escape detection)

### Stage 7: Self-Diagnosis

Validate plugin-doctor itself against the same criteria as Stage 1–6.

**Additional checks:**
1. Check `references/official-spec.md` exists and is not empty
2. Check this SKILL.md's frontmatter matches the latest official spec
3. Check `allowed-tools` includes WebFetch and WebSearch (needed to run Stage 0)
4. Check the event list referenced in the validation logic matches `official-spec.md`
5. On finding issues, output auto-fix suggestions

### Stage 8: Auto-Fix & Report

Combine all diagnostic results into a report.

**Severity classification:**
- **Critical**: issues that can affect plugin operation (e.g., missing required field, wrong path)
- **Warning**: non-compliance with official standards but no operational impact (e.g., version mismatch, missing README)
- **Info**: recommended improvements (e.g., insufficient description keywords, unset color)

**Auto-fixable items** (run after user confirmation):
- Delete empty deprecated `commands/` directories
- Add a missing `version` field (taken from marketplace.json)
- Convert `allowed-tools` comma-separated string → YAML list
- Sync marketplace.json ↔ plugin.json versions
- Fix plugin-doctor's own spec mismatches

**Report output format:**

```markdown
# Plugin Doctor Report

## 스펙 상태
- official-spec.md: [날짜] ([갱신 여부])

## 요약
| 플러그인 | Critical | Warning | Info | 상태 |
|----------|----------|---------|------|------|
| plugin-a | 0 | 1 | 2 | 🟡 |
| plugin-b | 1 | 0 | 0 | 🔴 |
| plugin-doctor (self) | 0 | 0 | 0 | 🟢 |

## 상세 진단

### plugin-a
| 심각도 | Stage | 항목 | 현재 상태 | 권장 조치 |
|--------|-------|------|----------|----------|
| ⚠️ | 6 | README.md | 누락 | 생성 필요 |
| ℹ️ | 4 | agent color | 미설정 | color 필드 추가 권장 |

## 자동 수정 제안
다음 항목을 자동 수정할까요?
- [ ] plugin-a/commands/ 빈 디렉토리 삭제
- [ ] plugin-b/.claude-plugin/plugin.json에 version: "1.0.0" 추가

## 수동 조치 필요
1. [Critical] plugin-b: ...
```

Once the user approves an auto-fix, apply that item immediately.

### Stage 8.5: Codex Parallel Fix (optional)

If the Codex skill is available and there are 3 or more approved auto-fixable items, you can delegate some to `/codex:rescue` in parallel to speed up fixing.

1. Split approved auto-fixable items into two groups:
   - **Claude fixes directly**: Critical items + items where spec consistency matters
   - **Delegable to Codex**: mechanical fixes among Warnings (version sync, empty-directory deletion, YAML-list conversion, etc.)
2. If there is a Codex delegation group, dispatch the `codex:codex-rescue` subagent (`--write`):
   - Task: "다음 plugin-doctor findings를 수정하라: [항목 목록]. 각 수정 후 변경된 파일 경로를 보고하라."
3. Run Claude's direct fixes and Codex delegation **in parallel**
4. Collect Codex fix results with `/codex:result`
5. In Stage 9 revalidation, verify both Claude and Codex fixes

> **Guardrail**: `official-spec.md`, the severity rubric, and the revalidation score are owned by fixer as the source of truth. If Codex relaxes criteria or deletes a finding, reject that fix.
> If the Codex skill is not installed, or there are fewer than 3 auto-fixable items, fix directly using the existing approach.

### Stage 9: Skeptical Re-verification Loop

> Protocol reference: `references/evaluation-protocol.md`
> Principle: Generator-Evaluator **role separation** + **skeptical evaluation** (Anthropic Harness Design blog)

#### Step 1: Define the Sprint Contract

**Before** starting any auto-fix, define the completion criteria clearly:

```markdown
## Sprint Contract
- 자동 수정 대상: [Critical/Warning 중 자동 수정 가능한 항목 목록]
- CLEAN 기준: Critical + Warning findings = 0
- 수동 조치 항목: [자동 수정 불가능한 항목 → 리포트에만 표시]
- 수정이 아닌 것: findings 삭제, 심각도 하향, 기준 완화
```

This prior agreement is what keeps revalidation criteria consistent.

#### Step 2: Run Auto-Fixes

After user approval, run the auto-fix items.

#### Step 3: Skeptical Re-verification

After fixing, switch into a **separate skeptical evaluator role** and re-verify.

**Skeptical evaluation perspective** (avoid the self-evaluation trap):
1. Was the fix actually applied to the file? — re-Read the file to confirm
2. Did the fix introduce a new problem? — chain-verify the impact scope
3. Deleting findings or lowering severity is NOT a fix
4. **If in doubt, fail** — at boundary scores (6-7), judge as fail
5. **Do not self-praise** — before judging "fixed well", re-Read the file first

**2-axis multi-dimensional evaluation:**

| Axis | Weight | Description |
|------|--------|-------------|
| Standard Compliance | 60% | Field/value-format compliance against official-spec.md |
| Structural Health | 40% | File paths, naming, reference integrity |

Score calibration:

| Band | Standard Compliance | Structural Health |
|------|---------------------|-------------------|
| 9-10 | 100% official-spec compliance | paths/naming OK + README present |
| 7-8 | 1-2 minor mismatches | 1 minor structural issue |
| 5-6 | many Warning-level mismatches | empty directory, naming mismatch |
| 3-4 | Critical present | files placed in wrong location |
| 1-2 | many required fields missing | basic structure absent |

Verdict: weighted average ≥7 PASS / 4-6 PARTIAL / <4 FAIL

**fixer domain anti-patterns (automatic deductions):**

| Anti-pattern | Axis | Deduction |
|--------------|------|-----------|
| commands/ directory remains | Structural Health | -3 (Critical) |
| plugin.json ↔ marketplace.json version mismatch | Standard Compliance | -3 (Critical) |
| SKILL.md frontmatter parse failure | Standard Compliance | -3 (Critical) |
| README.md missing | Structural Health | -1 (Warning) |
| empty skills/ or agents/ directory | Structural Health | -1 (Warning) |
| allowed-tools comma-separated string | Standard Compliance | -1 (Warning) |

**Revalidation scope:**
Re-run only the Stage of the items you fixed:
- plugin.json fix → re-run Stage 2
- version sync → re-run Stage 1 + Stage 2
- SKILL.md fix → re-run Stage 3
- agent fix → re-run Stage 4
- directory deletion → re-run Stage 6

#### Loop Control

```
Round 1: Sprint Contract 정의 → Stage 1~8 (진단) → 자동 수정
Round 2: 회의적 재검증 (수정 항목 관련 Stage만)
  → CLEAN → 완료
  → 잔여 findings → 추가 수정 + Round 3
Round 3: 회의적 재검증 (최종)
  → CLEAN → 완료
  → 잔여 → "수동 조치 필요" 리포트 출력 후 종료
```

**Termination conditions (any one met):**
1. Sprint Contract's CLEAN criterion met → **CLEAN**
2. This round's findings ≥ previous round → **CONVERGED** (fix introduced a new problem)
3. Round 3 complete → **MAX_ROUNDS**

**Artifact generation (required from round 2 onward):**

At the end of each round, record into the `.claude/doctor/` directory:
- `verify-round-{N}.md`: 2-axis scores, anti-pattern detection results, fix guidance

```markdown
# Verify Round {N} — Plugin Doctor

## 플러그인별 평가
### {plugin-name}
| 축 | 가중치 | 점수 | 근거 |
|----|--------|------|------|
| 표준 준수 | 60% | {N}/10 | {구체적 근거} |
| 구조 건전성 | 40% | {N}/10 | {구체적 근거} |
| **가중 평균** | | **{N.N}** | **{PASS/PARTIAL/FAIL}** |

## 안티패턴 탐지
| 플러그인 | 안티패턴 | 축 | 감점 |
|----------|----------|-----|------|

## 종합 판정: {CLEAN/CONTINUE/CONVERGED/MAX_ROUNDS}
```

**Add the loop history to the final report:**
```markdown
## 검증 루프 이력
| 라운드 | Sprint Contract | findings | 수정 | 잔여 | 가중평균 | 판정 |
|--------|----------------|----------|------|------|---------|------|
| 1 | Critical+Warning=0 | 5 | 4 | 1 | 6.2 | CONTINUE |
| 2 | Critical+Warning=0 | 1 | 1 | 0 | 8.4 | CLEAN |
```
