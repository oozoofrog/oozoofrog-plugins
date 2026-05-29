---
name: codex-research
description: Run an iterative research loop with Codex CLI — automatically repeats goal-directed experiments and records results. Use for requests like "codex 연구", "codex research", "반복 연구", "연구 루프", "research loop", "자율 연구", "codex로 연구", "깊이 연구", "반복 실험", "autoresearch", "codex 루프", "계속 연구", "overnight research", "연구 상태 확인", "연구 이어줘", "연구 재개", "research status", "resume research". For one-off task delegation, hey-codex is a better fit.
argument-hint: "[objective or workspace path]"
---

<example>
user: "codex로 이 스킬의 프롬프트 품질을 연구해줘"
assistant: "guided-loop 모드로 연구 루프를 시작하겠습니다. 먼저 .codex-research/ 상태를 확인합니다."
</example>

<example>
user: "codex 연구 루프 설계만 해줘"
assistant: "design 모드로 연구 계약을 작성하겠습니다. objective와 hard gate부터 정합니다."
</example>

<example>
user: "codex로 밤새 성능 개선 연구 돌려줘"
assistant: "autonomous-loop 모드입니다. --loop-forever는 중단 없이 실행됩니다. contract와 stop condition을 확인한 뒤 명령을 발행합니다."
</example>

<example>
user: "연구 상태 확인해줘"
assistant: "status 서브커맨드로 현재 연구 상태를 조회합니다."
</example>

<example>
user: "/codex-research 테스트 커버리지를 자동으로 개선해줘"
assistant: "guided-loop 모드로 테스트 커버리지 개선 연구를 시작합니다. .codex-research/가 없으면 init부터 진행합니다."
</example>

<example>
user: "codex 연구 계속 이어줘"
assistant: "기존 .codex-research/의 contract와 state_snapshot을 읽어 guided-loop를 재개합니다."
</example>

# Codex Research

Run a **goal-directed research loop** by repeatedly invoking the Codex CLI. Based on the karpathy/autoresearch pattern.

Each round, Codex selects a hypothesis -> makes a change -> verifies -> returns structured JSON, and the host script handles the 3-Layer decision -> git management -> ledger recording.

Respond to the user in Korean.

## Execution Flow

### Step 1: Preflight check

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```
- exit 0: pass
- exit 1: codex not installed -> show install guidance, then exit

### Step 2: Mode detection

Analyze the user request to determine the mode.

| Mode | Keywords | Claude role | Script role |
|------|--------|------------|-------------|
| **design** | 설계, 계약, contract, 루프 설계 | Write the contract | init only |
| **guided-loop** (default) | 연구 시작, 루프 시작, N라운드, 연구해줘 | Run script -> report results | run --max-rounds N |
| **autonomous-loop** | 계속 돌려, overnight, 자율, loop-forever | Issue command + warnings | run --loop-forever |

When the keywords are unclear, default to **guided-loop**.

### Step 3: Check the state directory

Check whether a `.codex-research/` directory exists in the workspace.

- **Absent** -> run `init` + switch to design mode (write the contract first)
- **Present** -> read `contract.md`, confirm the hard gate/metric, then proceed

### Step 4: Execute per mode

**design mode:**
1. Compress the user's objective into a single sentence
2. Run `codex-research.sh init`
3. Write `contract.md` together with the user (see references/loop-contract.md)
4. After the contract is complete, confirm the switch to guided-loop

**guided-loop mode:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --max-rounds N --search --full-auto
```
After running, read `ledger.tsv` + `state_snapshot.md` and report the results.

**autonomous-loop mode:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --loop-forever --search --full-auto
```
This runs without interruption. Always show the warning, re-confirm the contract's stop condition and budget, and only then issue the command.

### Step 5: Report results

Report the following after a round completes:
- Current best state and metric change
- The latest round's hard gate / experiment status / control action
- Remaining budget and next experiment candidates
- On termination: final delta summary + remaining risks

## 3-Layer decision

Keep hard gate result, experiment status, and control action **in separate columns** — never merged into one.

| Layer | Value | Meaning |
|------|-----|------|
| **hard gate result** | pass / fail | Minimum passing line. On fail, reject regardless of metric improvement |
| **experiment status** | keep / discard / crash | Whether to retain this round's result relative to the best-known state |
| **control action** | pass / refine / pivot / rescope / escalate / stop | Controls the whole loop. Decides the next round's direction |

Loop termination: control_action is pass/stop/rescope/escalate, or max_rounds is reached.

## Boundary with hey-codex

| Criterion | hey-codex | codex-research |
|------|-----------|----------------|
| Purpose | One-off task delegation | Iterative research loop |
| Rounds | 1 | N |
| State retention | None | program + contract + snapshot + ledger |
| Keywords | "codex한테 시켜" | "codex로 연구해" |

**Routing:** includes "연구/루프/반복/research/loop" -> codex-research. Otherwise -> hey-codex.

## CLI usage

> **Note**: `init` requires the workspace directory to **already exist**. For a new project, run `mkdir -p <workspace>` before init.

```bash
# Initialize (the workspace directory must already exist)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" init <workspace> "objective"

# Check status
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" status <workspace>

# Run research
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --max-rounds N --search --full-auto
```

> The shell wrapper converts the `<workspace>` positional argument internally to `--workspace <path>`. If needed, call the Python runner directly to specify options like `--workspace` and `--state-dir` explicitly.

### run options

| Option | Default | Description |
|------|--------|------|
| --workspace | `.` | Workspace directory where research runs (same as the positional argument in the shell wrapper) |
| --state-dir | `<workspace>/.codex-research` | Override the state file directory |
| --codex-bin | `codex` | Codex CLI executable to use |
| --sandbox | - | `read-only` / `workspace-write` / `danger-full-access` |
| --max-rounds | 3 | Maximum number of rounds |
| --loop-forever | false | Run infinitely (autonomous-loop only) |
| --search | false | Codex --search (web search) |
| --full-auto | false | Codex --full-auto |
| --model | - | Specify the Codex model |
| --timeout-seconds | 1800 | Per-round timeout (seconds) |
| --skip-git-repo-check | false | Skip Codex's git repo check (for non-git workspaces) |
| --commit-on-keep | auto | Force auto-commit of keep results |
| --no-commit-on-keep | false | Disable auto-commit on keep |
| --allow-dirty | false | Allow running even on a git dirty tree |
| --add-dir | - | Additional reference directory for Codex (repeatable) |

### Commit behavior on keep (tri-state)

- **Option omitted**: auto-commit if a git repo, proceed without commit on a non-git workspace
- **`--commit-on-keep`**: always attempt to auto-commit keep results
- **`--no-commit-on-keep`**: do not auto-commit keep results. Without `--allow-dirty` in this case, automatic progression to the next round may be halted

## State directory (.codex-research/)

```
.codex-research/
├── program.md            # objective + research scope
├── contract.md           # evaluation contract (loop-contract.md format)
├── state_snapshot.md     # baseline, best state, next candidates
├── ledger.tsv            # per-round result record
├── runtime/              # temporary files during Codex execution
└── rounds/
    ├── round-000/
    │   ├── prompt.md
    │   ├── last-message.json
    │   ├── response.json
    │   ├── codex-events.jsonl
    │   └── evidence.md
    └── round-001/...
```

## Rules

- **Minimize Claude usage**: engage actively only in design. In guided-loop, just run the script and report results. In autonomous-loop, only warn and issue the command.
- **한국어 응답**: 사용자에게 보여주는 메시지는 한국어, 코드와 기술 용어는 원문 유지.
- **Keep Codex prompts verbatim**: pass them to Codex in the user's input language as-is.
- **Bounded by default**: 3-5 rounds by default unless explicitly requested. Infinite loops require explicit user consent, since they run without stopping.
- **When the same failure repeats twice**, prefer `pivot`, `rescope`, or `escalate` over `refine`.
- **Git management**: keep -> auto-commit, discard/crash -> git restore (excluding .codex-research/).
- **Do not chain `sleep N && <cmd>`**: the Claude Code Bash tool blocks a leading sleep chain. To check round progress on a running `run`, call `codex-research.sh status <workspace>` on its own; when you actually need to wait, use the `Monitor` tool's `until <check>; do sleep 2; done` pattern. Keep log checks like `tail -f` as separate, standalone Bash calls too.

## References

- `references/loop-contract.md` -- guide for writing the research contract
