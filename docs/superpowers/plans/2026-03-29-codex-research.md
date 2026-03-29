# codex-research Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** hey-codex 플러그인에 Codex CLI 반복 연구 루프 스킬(codex-research)을 추가한다. 기존 codex-skills-project의 goal-research-loop 스크립트를 포팅·간소화한다.

**Architecture:** Python runner(codex-research.py)가 Codex CLI를 반복 호출하며, SKILL.md가 3개 모드(design/guided-loop/autonomous-loop)를 라우팅한다. Claude는 계약 설계에만 참여하고 실행은 스크립트에 위임한다.

**Tech Stack:** Python 3, Bash, Codex CLI, JSON Schema

---

### Task 1: 템플릿 파일 생성

**Files:**
- Create: `plugins/hey-codex/templates/codex-research/program.md`
- Create: `plugins/hey-codex/templates/codex-research/contract.md`
- Create: `plugins/hey-codex/templates/codex-research/state_snapshot.md`
- Create: `plugins/hey-codex/templates/codex-research/round-result.schema.json`

- [ ] **Step 1: program.md 템플릿 작성**

기존 goal-research-loop의 program.md를 기반으로 포팅:

```markdown
# Codex Research Program

이 파일은 사람이 유지하는 연구 운영 메모입니다.

- created_at: ${created_at}
- workspace: ${workspace}
- state_dir: ${state_dir}

## Objective

${objective}

## In-scope files / mutable surface

- TODO

## Out-of-scope files / immutable constraints

- TODO

## Research questions

- TODO

## Operator notes

- 한 라운드에 가설 하나만 실행
- state_snapshot.md와 ledger.tsv를 기준으로 다음 라운드를 이어감
- keep/discard/crash 와 control action을 분리
```

- [ ] **Step 2: contract.md 템플릿 작성**

```markdown
## Research Contract

- objective: ${objective}
- mode: guided-loop
- mutable surface: TODO
- immutable constraints: TODO
- hard gates: TODO
- primary metric: TODO
- tie-breakers: TODO
- decision layers: hard gates=pass/fail, experiment status=keep/discard/crash, control action=pass/refine/pivot/rescope/escalate/stop
- baseline: TODO
- evidence sources: TODO
- budget: TODO
- stop condition: TODO
- ledger: ${state_dir}/ledger.tsv
```

- [ ] **Step 3: state_snapshot.md 템플릿 작성**

```markdown
## State Snapshot

- objective: ${objective}
- baseline: TODO
- best-known state: TODO
- current active hypothesis: TODO
- most recent experiment status: TODO
- most recent control action: TODO
- open risks: TODO
- next candidate hypotheses:
  - TODO
- handoff notes: initialized at ${created_at}
```

- [ ] **Step 4: round-result.schema.json 복사**

기존 codex-skills-project의 schema를 그대로 복사 (14개 필드, 이미 간소화됨):
`/Users/oozoofrog/develop/oozoofrog/codex-skills-project/.agents/skills/goal-research-loop/schemas/round-result.schema.json`
→ `plugins/hey-codex/templates/codex-research/round-result.schema.json`

- [ ] **Step 5: 커밋**

```bash
git add plugins/hey-codex/templates/codex-research/
git commit -m "feat(hey-codex): codex-research 템플릿 파일 추가"
```

---

### Task 2: codex-research.sh shell wrapper

**Files:**
- Create: `plugins/hey-codex/scripts/codex-research.sh`

- [ ] **Step 1: shell wrapper 작성**

기존 goal-research-loop.sh를 기반으로, 경로와 이름만 변경:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPT_DIR/codex-research.py"
PYTHON_BIN="${PYTHON_BIN:-python3}"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "오류: $PYTHON_BIN 를 찾을 수 없습니다." >&2
  exit 1
fi

if [[ ! -f "$RUNNER" ]]; then
  echo "오류: runner 스크립트를 찾을 수 없습니다: $RUNNER" >&2
  exit 1
fi

usage() {
  cat <<'EOF'
codex-research shell wrapper

Usage:
  codex-research.sh init [workspace] [objective...]
  codex-research.sh status [workspace]
  codex-research.sh run [workspace] [runner args...]
  codex-research.sh help

Examples:
  codex-research.sh init . "스킬 프롬프트 품질을 개선한다"
  codex-research.sh status .
  codex-research.sh run . --max-rounds 5 --search --full-auto
EOF
}

subcommand="${1:-help}"

case "$subcommand" in
  help|-h|--help)
    usage
    ;;
  init)
    shift
    workspace="${1:-$PWD}"
    if [[ $# -gt 0 ]]; then shift; fi
    objective="${*:-}"
    cmd=("$PYTHON_BIN" "$RUNNER" init --workspace "$workspace")
    if [[ -n "$objective" ]]; then
      cmd+=(--objective "$objective")
    fi
    exec "${cmd[@]}"
    ;;
  status)
    shift
    workspace="${1:-$PWD}"
    exec "$PYTHON_BIN" "$RUNNER" status --workspace "$workspace"
    ;;
  run)
    shift
    workspace="${1:-$PWD}"
    if [[ $# -gt 0 && "$1" != --* ]]; then
      shift
    else
      workspace="$PWD"
    fi
    exec "$PYTHON_BIN" "$RUNNER" run --workspace "$workspace" "$@"
    ;;
  *)
    echo "알 수 없는 명령: $subcommand" >&2
    usage >&2
    exit 1
    ;;
esac
```

- [ ] **Step 2: 실행 권한 부여 및 커밋**

```bash
chmod +x plugins/hey-codex/scripts/codex-research.sh
git add plugins/hey-codex/scripts/codex-research.sh
git commit -m "feat(hey-codex): codex-research.sh shell wrapper 추가"
```

---

### Task 3: codex-research.py Python runner

**Files:**
- Create: `plugins/hey-codex/scripts/codex-research.py`

기존 842줄의 codex_goal_research_loop.py를 포팅하면서 간소화한다.

**제거 항목:**
- `--prompt-profile` (lightweight 제거, standard만)
- `--extra-instruction`
- `--dangerously-bypass-approvals-and-sandbox`
- `compact_for_prompt()` 함수
- `build_prompt_profile_section()` 함수
- `sanitize_status_lines()` → 간소화

**변경 항목:**
- `DEFAULT_STATE_DIR_NAME` = `.codex-research`
- `ROOT` = `Path(__file__).resolve().parents[1]` → 템플릿 위치: `ROOT / "templates" / "codex-research"`
- 프롬프트에서 reference 파일 목록 → SKILL.md + loop-contract.md 2개만
- commit 메시지: `codex-research round 001: [hypothesis]`

- [ ] **Step 1: 유틸리티 함수 + init/status 명령 작성**

기존 코드의 다음 함수를 그대로 포팅:
- `now_iso`, `resolve_workspace`, `resolve_state_dir`, `read_text`, `write_text`, `render_template`
- `ensure_codex_exists`, `collapse_ws`, `tsv_escape`
- `read_ledger_rows`, `recent_ledger_excerpt`, `next_round_number`, `append_ledger_row`
- `maybe_bootstrap_files`, `ensure_runtime_files`
- `cmd_init`, `cmd_status`

변경: `TEMPLATES_DIR = ROOT / "templates" / "codex-research"`, `SCHEMA_PATH = TEMPLATES_DIR / "round-result.schema.json"`, `DEFAULT_STATE_DIR_NAME = ".codex-research"`

- [ ] **Step 2: git 관리 함수 작성**

포팅:
- `git`, `detect_git_root`, `current_head`
- `workspace_has_tracked_files`, `workspace_changes_exist`
- `restore_workspace`, `stage_workspace`, `commit_keep_result`

변경: commit 메시지를 `codex-research round {N:03d}: {hypothesis}`로 변경

- [ ] **Step 3: 프롬프트 생성 함수 작성**

기존 `build_round_prompt`를 간소화:
- `build_prompt_profile_section` 제거 → 직접 reference 목록 작성 (SKILL.md + loop-contract.md)
- `compact_for_prompt` 제거 → 항상 전문 포함
- `extra_instructions` 제거

```python
def build_round_prompt(
    *,
    workspace: Path,
    skill_dir: Path,
    state_dir: Path,
    program_path: Path,
    contract_path: Path,
    snapshot_path: Path,
    ledger_path: Path,
    round_dir: Path,
    round_num: int,
    head_ref: str | None,
) -> str:
    # SKILL.md + references/loop-contract.md 2개만 참조
    # 그 외는 기존 build_round_prompt와 동일한 텍스트 구조
```

- [ ] **Step 4: Codex 명령 생성 함수 작성**

기존 `build_codex_command`를 간소화:
- `bypass_sandbox` 제거
- `prompt_profile` 제거

```python
def build_codex_command(
    *,
    codex_bin: str,
    workspace: Path,
    skill_dir: Path,
    state_dir: Path,
    last_message_path: Path,
    model: str | None,
    sandbox: str | None,
    full_auto: bool,
    search: bool,
    extra_dirs: list[str],
    skip_git_repo_check: bool,
) -> list[str]:
```

- [ ] **Step 5: run 루프 + fallback + argparse 작성**

포팅:
- `fallback_response`, `summarize_response`, `should_stop`
- `cmd_run` (메인 루프)
- `build_parser`, `main`

간소화:
- `--prompt-profile`, `--extra-instruction`, `--dangerously-bypass-approvals-and-sandbox` 제거
- `--profile` 제거 (codex profile 대신 `--model`만 유지)

- [ ] **Step 6: 테스트 실행**

```bash
# Python 구문 검증
python3 -c "import plugins.hey_codex.scripts.codex_research" 2>&1 || python3 plugins/hey-codex/scripts/codex-research.py --help

# init 테스트
bash plugins/hey-codex/scripts/codex-research.sh init /tmp/test-codex-research "테스트 objective"
ls /tmp/test-codex-research/.codex-research/

# status 테스트
bash plugins/hey-codex/scripts/codex-research.sh status /tmp/test-codex-research
```

- [ ] **Step 7: 커밋**

```bash
git add plugins/hey-codex/scripts/codex-research.py
git commit -m "feat(hey-codex): codex-research.py Python runner 추가"
```

---

### Task 4: SKILL.md 작성

**Files:**
- Create: `plugins/hey-codex/skills/codex-research/SKILL.md`
- Create: `plugins/hey-codex/skills/codex-research/references/loop-contract.md`

- [ ] **Step 1: loop-contract.md 참조 문서 작성**

기존 goal-research-loop의 loop-contract.md를 간소화하여 포팅. 핵심 13개 필드 설명 + 예시.

- [ ] **Step 2: SKILL.md 작성**

핵심 구조:
- frontmatter: name, description (트리거 키워드), argument-hint
- 4개 example
- 모드 판별 테이블 (design / guided-loop / autonomous-loop)
- 실행 흐름 (preflight → init/design → run → 결과 보고)
- 3-Layer 판단 설명
- hey-codex와의 경계 명시
- 규칙 체크리스트

- [ ] **Step 3: 커밋**

```bash
git add plugins/hey-codex/skills/codex-research/
git commit -m "feat(hey-codex): codex-research SKILL.md + loop-contract.md 추가"
```

---

### Task 5: 버전 범프 + CLAUDE.md 업데이트

**Files:**
- Modify: `plugins/hey-codex/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `CLAUDE.md`

- [ ] **Step 1: plugin.json 버전 범프**

`"version": "1.1.1"` → `"version": "1.2.0"`

- [ ] **Step 2: marketplace.json 버전 범프**

hey-codex entry: `"version": "1.1.1"` → `"version": "1.2.0"`
root: version bump

- [ ] **Step 3: CLAUDE.md 플러그인 테이블 업데이트**

```
| hey-codex | hey-codex, codex-research | — | — |
```

- [ ] **Step 4: 커밋**

```bash
git add plugins/hey-codex/.claude-plugin/plugin.json .claude-plugin/marketplace.json CLAUDE.md
git commit -m "feat(hey-codex): codex-research 스킬 추가 + 버전 범프 1.1.1 → 1.2.0"
```

---

### Task 6: End-to-end 검증

**Files:** (no new files)

- [ ] **Step 1: preflight 검증**

```bash
bash plugins/hey-codex/scripts/preflight.sh
# Expected: "ok" (codex CLI 설치됨)
```

- [ ] **Step 2: init 검증**

```bash
bash plugins/hey-codex/scripts/codex-research.sh init /tmp/e2e-test "E2E 테스트"
ls /tmp/e2e-test/.codex-research/
# Expected: program.md, contract.md, state_snapshot.md, ledger.tsv
```

- [ ] **Step 3: status 검증**

```bash
bash plugins/hey-codex/scripts/codex-research.sh status /tmp/e2e-test
# Expected: workspace, state dir, ledger rows: 0, snapshot 내용 표시
```

- [ ] **Step 4: run 검증 (codex 설치되어 있을 때)**

```bash
bash plugins/hey-codex/scripts/codex-research.sh run /tmp/e2e-test --max-rounds 1 --full-auto
# Expected: round 000 실행, ledger 1행 추가, response.json 생성
```

- [ ] **Step 5: 정리 및 최종 커밋**

```bash
rm -rf /tmp/e2e-test /tmp/test-codex-research
git status  # 작업 트리 깨끗한지 확인
```

---

### Task 7: 셀프 개선 루프

**Files:** (codex가 수정하는 파일은 라운드마다 다름)

- [ ] **Step 1: 셀프 개선 계약 작성**

```bash
cd /Volumes/eyedisk/develop/oozoofrog/oozoofrog-plugins
bash plugins/hey-codex/scripts/codex-research.sh init . "codex-research 스킬의 프롬프트 품질과 라운드 완주율을 개선한다"
```

contract.md를 편집:
- mutable surface: `plugins/hey-codex/scripts/codex-research.py`, `plugins/hey-codex/skills/codex-research/SKILL.md`
- hard gates: `codex-research.sh run이 1라운드 이상 정상 완주 (response.json 생성)`
- primary metric: `라운드 완주 시 evidence.md 생성 여부 + JSON schema 준수`
- budget: 3 라운드
- stop condition: `hard gate pass + control_action=pass 또는 budget 소진`

- [ ] **Step 2: 셀프 루프 실행**

```bash
bash plugins/hey-codex/scripts/codex-research.sh run . --max-rounds 3 --search --full-auto
```

- [ ] **Step 3: 결과 확인 및 유용한 변경 반영**

```bash
bash plugins/hey-codex/scripts/codex-research.sh status .
# ledger.tsv와 state_snapshot.md 확인
# keep된 라운드의 변경사항이 이미 커밋되어 있음
```

- [ ] **Step 4: .codex-research/ 정리 및 최종 커밋**

```bash
rm -rf .codex-research/
git add -A
git commit -m "feat(hey-codex): codex-research 셀프 개선 루프 결과 반영"
```
