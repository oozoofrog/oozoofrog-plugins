---
name: hey-codex
description: Delegate tasks to the Codex CLI. Use for requests that hand off or delegate work to the Codex CLI, including "codex", "codex한테", "codex로", "코덱스", "codex 시켜", "codex에게", "codex delegate".
argument-hint: "[task description]"
---

<example>
user: "codex한테 이 코드 리뷰해달라고 해줘"
assistant: "read 모드로 Codex CLI에 코드 리뷰를 요청하겠습니다."
</example>

<example>
user: "codex로 테스트 작성해줘"
assistant: "write 모드로 Codex CLI에 테스트 작성을 위임하겠습니다. --full-auto 모드로 실행합니다."
</example>

<example>
user: "codex에게 리팩토링 방법 물어봐"
assistant: "suggest 모드로 Codex CLI에 리팩토링 제안을 요청하겠습니다."
</example>

<example>
user: "/hey-codex 이 함수의 성능 개선점 분석해줘"
assistant: "read 모드로 Codex CLI에 성능 분석을 요청하겠습니다."
</example>

# Hey Codex

Delegate tasks to the OpenAI Codex CLI and handle the results. Respond to the user in Korean.

## Execution Flow

### 1. Preflight

Check whether the codex CLI is installed using the helper script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```
- exit 0: passed, proceed to next step
- exit 1: codex not installed → show the script's output message to the user and stop

### 2. Prepare the Prompt

**Strip trigger phrases:**
For natural-language triggers, remove the following pattern from the prompt:
`codex(한테|에게|로|가)?\s*(시켜|해줘|해봐|부탁)?`

For slash commands (`/hey-codex`), use the argument as-is.

**Set the working directory:**
Set the working directory with the Codex CLI's `--cd` flag rather than injecting it as text into the prompt.

### 3. Determine Mode

Analyze the prompt to decide the execution mode.

| Mode | Codex command | Description |
|------|------------|------|
| **read** | `codex exec` | Analysis, review, explanation (read-only) |
| **review** | `codex review` | Code review only (when review keywords are detected) |
| **suggest** | `codex exec` | Suggestion/advice request (applied by Claude Code) |
| **write** | `codex exec --full-auto` | Create/modify/delete files (Codex modifies directly) |

**Priority:** write > suggest > read (default)

Full keyword table: `references/mode-detection.md`

### 4. Safety Check

```
Check whether .git exists (Bash: test -d .git)
├─ Yes → run without restriction
└─ No + write mode →
    Ask the user to confirm:
    "현재 디렉토리는 Git 저장소가 아닙니다.
     Codex가 파일을 직접 수정합니다. 롤백이 불가능할 수 있습니다.
     계속하시겠습니까? (y/N)"
    ├─ y → run
    └─ N or no response → cancel
└─ No + read/suggest → run as-is
```

### 5. Run Codex

Run via the `codex-run.sh` wrapper, invoked with `run_in_background: true`. The wrapper handles PID tracking, completion waiting, and `process-output.sh` post-processing automatically. Remember the `SESSION=<TOKEN>` on the first output line for status checks.

**read/suggest mode:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-run.sh" exec "$(pwd)" "프롬프트"
```
Bash tool: `run_in_background: true` (no timeout)

**review mode (when review keywords are detected):**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-run.sh" review "$(pwd)"
```
Bash tool: `run_in_background: true` (no timeout)

**write mode (git repo):**
```bash
# Step 1: check git status (plain Bash call)
git status --short

# Step 2: run codex (background)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-run.sh" exec-full-auto "$(pwd)" "프롬프트"
```
Step 2 Bash tool: `run_in_background: true` (no timeout)

**write mode (non-git):**
```bash
# Step 1: pre-snapshot (plain Bash call)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" pre .

# Step 2: run codex (background)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-run.sh" exec-full-auto "$(pwd)" "프롬프트" --skip-git-repo-check
```
Step 2 Bash tool: `run_in_background: true` (no timeout)

After the completion notification:
```bash
# Step 3: post-snapshot (plain Bash call)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" post .
```

**Status check (optional, for long runs):**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-status.sh" <SESSION_TOKEN>
```
Output: `RUNNING (PID=..., output=Nlines)` | `COMPLETED` | `FAILED (exit code: N)` | `CRASHED`

> **Do not use a leading sleep chain** such as `sleep 30 && tail -f <raw.txt>` — the Bash tool blocks it. Background completion is delivered via an automatic notification, so polling is not needed. If you must wait, call `codex-status.sh` once on its own, or use the `Monitor` tool with `until <check>; do sleep 2; done`. To peek at a log file, run `tail -N <path>` on its own rather than chaining it after `sleep`.

### 6. Handle Results

Per-mode post-processing strategy: `references/output-handling.md`

**read mode:** Show the Codex output to the user and stop (one-way).

**suggest mode:**
1. Summarize the Codex output for the user
2. Confirm: "이 제안을 적용할까요?"
3. On approval, apply the changes with Claude Code's Edit/Write tools
4. On rejection, stop

**write mode (git):**
1. Capture changes with `git diff`
2. Show a summary or `git diff --stat` depending on the number of changed files
3. If problems are found, offer a `git checkout .` rollback option

**write mode (non-git):**
1. Compare snapshots after the run:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" post .
   ```
2. The script classifies and prints added/deleted/modified files
3. Warn that rollback is not possible

### 7. Display Output

| Output size | Handling |
|----------|------|
| < 50 lines | Show verbatim |
| 50~200 lines | Summarize + offer to show full output |
| > 200 lines | Summarize + save to `/tmp/codex-output-$(date +%s).txt` |

## Error Handling

| Situation | Handling |
|------|------|
| Codex not installed | Guide with `npm install -g @openai/codex` |
| API auth failure (auth/key error in stderr) | Show "API 키를 확인해주세요" |
| Process failure (exit code ≠ 0) | Check status with `codex-status.sh`, show stderr, then decide whether to retry |
| Long-running execution | Check progress with `codex-status.sh <SESSION_TOKEN>` |
| Empty output | Show "Codex가 결과를 반환하지 않았습니다" |
| Large write-mode change (6+ files) | `git diff --stat` summary + rollback option |

## Key Rules

- **Korean responses**: write user-facing messages in Korean; keep code and technical terms in their original form.
- **Keep the Codex prompt verbatim**: pass the prompt to Codex in the same language the user typed it.
- **exec mode only**: use only the `codex exec` subcommand (interactive mode is not usable from the Bash tool).
- **Background execution**: run the Codex CLI via the `codex-run.sh` wrapper with `run_in_background: true`. There is no fixed timeout. To check status, run `codex-status.sh` as a separate Bash call.

## References

- `references/mode-detection.md` — 모드 판별 키워드 테이블 (LLM이 참조)
- `references/output-handling.md` — 결과 처리 전략

## Scripts

- `${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh` — codex CLI 설치 확인
- `${CLAUDE_PLUGIN_ROOT}/scripts/codex-run.sh` — codex 실행 래퍼 (PID 추적 + 완료 대기 + 후처리)
- `${CLAUDE_PLUGIN_ROOT}/scripts/codex-status.sh` — 프로세스 상태 확인 (RUNNING/COMPLETED/FAILED)
- `${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh` — ANSI 스트립 + 줄 수 측정 + 대용량 저장
- `${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh` — non-git 디렉토리 스냅샷 생성/비교
