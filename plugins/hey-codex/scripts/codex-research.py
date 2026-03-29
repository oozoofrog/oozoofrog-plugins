#!/usr/bin/env python3
"""Host-managed Codex CLI research loop runner for the codex-research skill."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import textwrap
from datetime import datetime
from pathlib import Path
from string import Template
from typing import Iterable

try:
    import fcntl
except ImportError:  # pragma: no cover - Windows fallback
    fcntl = None

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[1]  # hey-codex plugin root
TEMPLATES_DIR = ROOT / "templates" / "codex-research"
SCHEMA_PATH = TEMPLATES_DIR / "round-result.schema.json"
DEFAULT_STATE_DIR_NAME = ".codex-research"
VALID_EXPERIMENT_STATUSES = {"keep", "discard", "crash"}
VALID_CONTROL_ACTIONS = {"pass", "refine", "pivot", "rescope", "escalate", "stop"}
LEDGER_HEADER = (
    "round\thypothesis\tchange\thard_gates\tmetric\tevidence\t"
    "experiment_status\tcontrol_action\tnext_step\tnotes\n"
)


class JsonParseError(Exception):
    """JSON 응답 파일 해석 실패."""


# ---------------------------------------------------------------------------
# Utility helpers
# ---------------------------------------------------------------------------


def now_iso() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def resolve_workspace(path: str) -> Path:
    workspace = Path(path).expanduser().resolve()
    if not workspace.exists():
        raise SystemExit(f"workspace가 존재하지 않습니다: {workspace}")
    if not workspace.is_dir():
        raise SystemExit(f"workspace는 디렉터리여야 합니다: {workspace}")
    return workspace


def resolve_state_dir(workspace: Path, override: str | None) -> Path:
    if override:
        return Path(override).expanduser().resolve()
    return workspace / DEFAULT_STATE_DIR_NAME


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise SystemExit(f"파일을 찾을 수 없습니다: {path}") from exc
    except PermissionError as exc:
        raise SystemExit(f"파일을 읽을 권한이 없습니다: {path}") from exc
    except UnicodeDecodeError as exc:
        raise SystemExit(f"UTF-8로 파일을 읽을 수 없습니다: {path}\n{exc}") from exc
    except OSError as exc:
        raise SystemExit(f"파일을 읽는 중 오류가 발생했습니다: {path}\n{exc}") from exc


def write_text(path: Path, content: str) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        raise SystemExit(f"디렉터리를 생성할 수 없습니다: {path.parent}\n{exc}") from exc
    try:
        path.write_text(content, encoding="utf-8")
    except OSError as exc:
        raise SystemExit(f"파일을 쓸 수 없습니다: {path}\n{exc}") from exc


def render_template(name: str, context: dict[str, str]) -> str:
    template_path = TEMPLATES_DIR / name
    template = Template(read_text(template_path))
    try:
        return template.substitute(context)
    except KeyError as exc:
        missing_key = exc.args[0] if exc.args else "unknown"
        raise SystemExit(
            f"템플릿 치환 변수 `{missing_key}` 가 누락되었습니다: {template_path}"
        ) from exc
    except ValueError as exc:
        raise SystemExit(f"템플릿 형식이 잘못되었습니다: {template_path}\n{exc}") from exc


def ensure_codex_exists(codex_bin: str) -> None:
    if shutil.which(codex_bin) is None:
        raise SystemExit(
            f"codex CLI를 찾지 못했습니다: {codex_bin}\n"
            "먼저 Codex CLI를 설치하고 PATH에 추가해주세요."
        )


def collapse_ws(value: str) -> str:
    return " ".join(value.replace("\t", " ").split())


def tsv_escape(value: object) -> str:
    return collapse_ws(str(value)).replace("\n", " / ")


def warn(message: str) -> None:
    print(f"경고: {message}", file=sys.stderr)


# ---------------------------------------------------------------------------
# Ledger helpers
# ---------------------------------------------------------------------------


def read_ledger_rows(ledger_path: Path) -> list[list[str]]:
    if not ledger_path.exists():
        return []
    rows: list[list[str]] = []
    for idx, line in enumerate(read_text(ledger_path).splitlines()):
        if idx == 0 and line.startswith("round\t"):
            continue
        if not line.strip():
            continue
        rows.append(line.split("\t"))
    return rows


def recent_ledger_excerpt(ledger_path: Path, limit: int = 8) -> str:
    if not ledger_path.exists():
        return "(ledger 없음)"
    lines = [line for line in read_text(ledger_path).splitlines() if line.strip()]
    if not lines:
        return "(ledger 비어 있음)"
    if len(lines) <= limit + 1:
        excerpt = lines
    else:
        excerpt = lines[:1] + lines[-limit:]
    return "\n".join(excerpt)


def next_round_number(ledger_path: Path) -> int:
    return len(read_ledger_rows(ledger_path))


def append_ledger_row(
    ledger_path: Path,
    *,
    round_num: int,
    response: dict[str, object],
    evidence_ref: str,
    notes_suffix: str = "",
) -> None:
    if not ledger_path.exists():
        write_text(ledger_path, LEDGER_HEADER)

    hard_gates = response.get("hard_gates", {})
    if isinstance(hard_gates, dict):
        hard_gates_result = hard_gates.get("result", "")
    else:
        hard_gates_result = ""

    notes = tsv_escape(response.get("notes", ""))
    if notes_suffix:
        notes = collapse_ws(f"{notes} {notes_suffix}".strip())

    row = [
        str(round_num),
        tsv_escape(response.get("hypothesis", "")),
        tsv_escape(response.get("change_summary", "")),
        tsv_escape(hard_gates_result),
        tsv_escape(response.get("metric", "")),
        tsv_escape(evidence_ref),
        tsv_escape(response.get("experiment_status", "")),
        tsv_escape(response.get("control_action", "")),
        tsv_escape(response.get("next_step", "")),
        notes,
    ]
    try:
        with ledger_path.open("a+", encoding="utf-8") as handle:
            if fcntl is not None:
                fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            handle.seek(0, 2)
            if handle.tell() == 0:
                handle.write(LEDGER_HEADER)
            handle.write("\t".join(row) + "\n")
            handle.flush()
            # flock은 file handle close 시 자동 해제됨 (with 블록 종료)
    except OSError as exc:
        raise SystemExit(f"ledger.tsv에 결과를 기록할 수 없습니다: {ledger_path}\n{exc}") from exc


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------


def git(
    workspace: Path,
    *args: str,
    check: bool = True,
    capture_output: bool = True,
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=str(workspace),
        check=check,
        capture_output=capture_output,
        text=True,
    )


def detect_git_root(workspace: Path) -> Path | None:
    result = git(workspace, "rev-parse", "--show-toplevel", check=False)
    if result.returncode != 0:
        return None
    return Path(result.stdout.strip()).resolve()


def current_head(workspace: Path) -> str:
    result = git(workspace, "rev-parse", "--short", "HEAD", check=False)
    if result.returncode != 0:
        return "unknown"
    return result.stdout.strip() or "unknown"


def _is_relative_to(path: Path, base: Path) -> bool:
    try:
        path.relative_to(base)
        return True
    except ValueError:
        return False


def _relative_to_or_none(path: Path, base: Path) -> Path | None:
    try:
        return path.relative_to(base)
    except ValueError:
        return None


def _sanitize_status_lines(lines: Iterable[str], state_dir_rel: Path | None) -> list[str]:
    filtered: list[str] = []
    prefix = None if state_dir_rel is None else state_dir_rel.as_posix().rstrip("/") + "/"
    exact = None if state_dir_rel is None else state_dir_rel.as_posix().rstrip("/")
    for raw in lines:
        line = raw.rstrip("\n")
        if not line:
            continue
        if len(line) <= 3:
            filtered.append(line)
            continue
        path_text = line[3:]
        if " -> " in path_text:
            path_text = path_text.split(" -> ", 1)[1]
        path_text = path_text.strip()
        normalized = path_text.replace("\\", "/")
        if exact and (normalized == exact or (prefix and normalized.startswith(prefix))):
            continue
        filtered.append(line)
    return filtered


def workspace_has_tracked_files(workspace: Path) -> bool:
    tracked = git(workspace, "ls-files", "--cached", "--", ".")
    return bool(tracked.stdout.strip())


def workspace_changes_exist(workspace: Path, state_dir_rel: Path | None) -> bool:
    status = git(workspace, "status", "--porcelain", "--untracked-files=all", "--", ".")
    filtered = _sanitize_status_lines(status.stdout.splitlines(), state_dir_rel)
    return bool(filtered)


def restore_workspace(workspace: Path, state_dir_rel: Path | None) -> bool:
    """workspace를 HEAD로 복원. 성공 시 True, 실패 시 False."""
    try:
        if workspace_has_tracked_files(workspace):
            git(workspace, "restore", "--source=HEAD", "--staged", "--worktree", ".")
    except subprocess.CalledProcessError as exc:
        print(
            f"경고: git restore 실패 (exit {exc.returncode}). "
            "workspace가 불완전한 상태일 수 있습니다.",
            file=sys.stderr,
        )
        return False
    clean_cmd = ["git", "clean", "-fd"]
    if state_dir_rel is not None:
        clean_cmd.extend(["-e", state_dir_rel.as_posix().rstrip("/") + "/"])
    try:
        subprocess.run(clean_cmd, cwd=str(workspace), check=True, capture_output=True, text=True)
    except subprocess.CalledProcessError as exc:
        print(
            f"경고: git clean 실패 (exit {exc.returncode}). "
            "untracked 파일이 남아 있을 수 있습니다.",
            file=sys.stderr,
        )
        return False
    return True


def stage_workspace(workspace: Path, state_dir_rel: Path | None) -> None:
    git(workspace, "add", "-A", ".")
    if state_dir_rel is not None:
        git(workspace, "reset", "HEAD", "--", state_dir_rel.as_posix())


def commit_keep_result(
    workspace: Path,
    state_dir_rel: Path | None,
    round_num: int,
    hypothesis: str,
) -> str:
    if not workspace_changes_exist(workspace, state_dir_rel):
        return current_head(workspace)
    try:
        stage_workspace(workspace, state_dir_rel)
    except subprocess.CalledProcessError as exc:
        print(f"경고: git staging 실패 (exit {exc.returncode})", file=sys.stderr)
        return f"stage-failed(exit={exc.returncode})"
    if not workspace_changes_exist(workspace, state_dir_rel):
        return current_head(workspace)
    short_hypothesis = collapse_ws(hypothesis)[:72] or "keep"
    message = f"codex-research round {round_num:03d}: {short_hypothesis}"
    try:
        git(workspace, "commit", "-m", message, capture_output=True)
    except subprocess.CalledProcessError as exc:
        print(f"경고: git commit 실패 (exit {exc.returncode})", file=sys.stderr)
        return f"commit-failed(exit={exc.returncode})"
    return current_head(workspace)


def ensure_clean_git_tree(workspace: Path, state_dir_rel: Path | None) -> None:
    status = git(workspace, "status", "--porcelain", "--untracked-files=all", "--", ".")
    filtered = _sanitize_status_lines(status.stdout.splitlines(), state_dir_rel)
    if filtered:
        preview = "\n".join(filtered[:20])
        raise SystemExit(
            "git 작업 트리가 깨끗하지 않습니다.\n"
            "해결 방법:\n"
            "  1. 변경을 유지하려면: git add -A && git commit -m \"...\"\n"
            "  2. 변경을 버리려면: git restore --source=HEAD --staged --worktree . && git clean -fd\n"
            "  3. dirty tree에서도 실행하려면: --allow-dirty 사용\n"
            "감지된 변경:\n"
            f"{preview}"
        )


# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------


def ensure_runtime_files(state_dir: Path) -> None:
    state_dir.mkdir(parents=True, exist_ok=True)
    (state_dir / "rounds").mkdir(parents=True, exist_ok=True)
    (state_dir / "runtime").mkdir(parents=True, exist_ok=True)


def maybe_bootstrap_files(
    workspace: Path, state_dir: Path, objective: str | None, force: bool
) -> list[Path]:
    ensure_runtime_files(state_dir)
    created: list[Path] = []
    context = {
        "objective": objective or "TODO: objective를 한 문장으로 적으세요.",
        "workspace": str(workspace),
        "state_dir": str(state_dir),
        "created_at": now_iso(),
    }
    file_map = {
        "program.md": "program.md",
        "contract.md": "contract.md",
        "state_snapshot.md": "state_snapshot.md",
    }
    for template_name, output_name in file_map.items():
        dest = state_dir / output_name
        if dest.exists() and not force:
            continue
        content = render_template(template_name, context)
        write_text(dest, content)
        created.append(dest)
    return created


# ---------------------------------------------------------------------------
# Subcommands: init, status
# ---------------------------------------------------------------------------


def cmd_init(args: argparse.Namespace) -> int:
    workspace = resolve_workspace(args.workspace)
    state_dir = resolve_state_dir(workspace, args.state_dir)
    created = maybe_bootstrap_files(workspace, state_dir, args.objective, args.force)

    print(f"workspace: {workspace}")
    print(f"state dir: {state_dir}")
    if created:
        print("생성/갱신된 파일:")
        for path in created:
            print(f"  - {path}")
    else:
        print("이미 필요한 파일이 존재합니다. --force를 사용하면 다시 생성합니다.")
    print()
    print("다음 단계:")
    print(f"  1. {state_dir / 'program.md'} 를 목적과 범위에 맞게 수정하세요.")
    print(f"  2. {state_dir / 'contract.md'} 에 hard gates / metric / budget / stop rule을 채우세요.")
    print(
        "  3. 준비되면 다음 명령으로 루프를 시작하세요:\n"
        f"     python3 {Path(__file__).resolve()} run --workspace {workspace} --max-rounds 3"
    )
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    workspace = resolve_workspace(args.workspace)
    state_dir = resolve_state_dir(workspace, args.state_dir)
    ledger_path = state_dir / "ledger.tsv"
    snapshot_path = state_dir / "state_snapshot.md"

    print(f"workspace: {workspace}")
    print(f"state dir: {state_dir}")
    print(f"ledger rows: {len(read_ledger_rows(ledger_path))}")
    print()
    if snapshot_path.exists():
        print("state snapshot:")
        print(read_text(snapshot_path))
    else:
        print("state_snapshot.md 가 없습니다.")
    print()
    if ledger_path.exists():
        print("recent ledger:")
        print(recent_ledger_excerpt(ledger_path))
    else:
        print("ledger.tsv 가 없습니다.")
    return 0


# ---------------------------------------------------------------------------
# Prompt & command builders
# ---------------------------------------------------------------------------


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
    if not program_path.exists():
        raise SystemExit(
            f"program.md 파일이 없습니다: {program_path}\n"
            "먼저 init을 다시 실행하거나 program.md를 생성하세요."
        )
    if not program_path.is_file():
        raise SystemExit(f"program.md 경로가 파일이 아닙니다: {program_path}")
    if not contract_path.exists():
        raise SystemExit(
            f"contract.md 파일이 없습니다: {contract_path}\n"
            "먼저 init을 다시 실행하거나 contract.md를 생성하세요."
        )
    if not contract_path.is_file():
        raise SystemExit(f"contract.md 경로가 파일이 아닙니다: {contract_path}")

    program_text = read_text(program_path).strip()
    contract_text = read_text(contract_path).strip()
    snapshot_text = read_text(snapshot_path).strip() if snapshot_path.exists() else "(state snapshot 없음)"
    ledger_excerpt = recent_ledger_excerpt(ledger_path)
    evidence_path = round_dir / "evidence.md"

    # Reference files: SKILL.md + loop-contract.md only
    refs = [
        str(skill_dir / "skills" / "codex-research" / "SKILL.md"),
        str(skill_dir / "skills" / "codex-research" / "references" / "loop-contract.md"),
    ]
    refs_text = "\n".join(f"- {ref}" for ref in refs)

    baseline_note = (
        "현재 ledger에 완료된 라운드가 없으므로, 이번 라운드는 baseline 확립 또는 contract 보정부터 시작해도 됩니다."
        if next_round_number(ledger_path) == 0
        else "이미 이전 라운드가 있으므로, best-known state를 기준으로 다음 가설 하나만 실행하세요."
    )

    return textwrap.dedent(
        f"""
        # Codex Research Round {round_num}

        당신은 host-managed Codex CLI 연구 루프의 **한 라운드만** 수행합니다.
        이번 호출은 `codex-research` 스킬 운영 규칙을 따릅니다.

        ## 먼저 읽을 스킬 파일
        {refs_text}

        ## 이번 호출의 운영 규칙
        - 한 라운드 = 가설 1개만 실행합니다.
        - git commit, branch 조작, push는 하지 마세요. keep/revert/optional commit은 host runner가 처리합니다.
        - 반드시 `hard gates`, `experiment status`, `control action`을 분리해 판단하세요.
        - `control action`은 `pass | refine | pivot | rescope | escalate | stop` 중 하나여야 합니다.
        - `experiment status`는 `keep | discard | crash` 중 하나여야 합니다.
        - 근거는 `{evidence_path}`에 Markdown으로 남기고, `{snapshot_path}`를 최신 상태로 갱신하세요.
        - `{program_path}`와 `{contract_path}`를 source of truth로 다루세요.
        - {baseline_note}

        ## 작업 위치
        - workspace: {workspace}
        - state dir: {state_dir}
        - program: {program_path}
        - contract: {contract_path}
        - state snapshot: {snapshot_path}
        - ledger: {ledger_path}
        - round directory: {round_dir}
        - current HEAD: {head_ref or "non-git / unavailable"}

        ## 사용자/운영자 program
        {program_text}

        ## research contract
        {contract_text}

        ## current state snapshot
        {snapshot_text}

        ## recent ledger excerpt
        {ledger_excerpt}

        ## 반드시 수행할 일
        1. 현재 contract가 실행 가능한지 판단합니다.
        2. 이번 라운드의 단일 가설을 선택합니다.
        3. 필요하면 workspace 파일을 작은 변경으로 수정하고 검증합니다.
        4. `{evidence_path}`에 이번 실험의 가설, 실행, 근거, 판정을 남깁니다.
        5. `{snapshot_path}`를 최신 best-known state, 최근 판정, 다음 후보로 갱신합니다.
        6. 마지막 응답은 JSON schema에 맞는 JSON만 반환합니다.

        ## JSON 응답 제약
        - `round`는 {round_num}이어야 합니다.
        - `updated_files`에는 실제로 바뀐 workspace/state 파일 경로를 넣으세요.
        - `evidence_files`에는 최소 `{evidence_path}`를 포함하세요.
        - 근거가 부족하면 과장하지 말고 `rescope` 또는 `escalate`를 사용하세요.
        """
    ).strip() + "\n"


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
    cmd: list[str] = [codex_bin]
    if search:
        cmd.append("--search")

    cmd.extend([
        "exec", "-",
        "-C", str(workspace),
        "--output-schema", str(SCHEMA_PATH),
        "--json",
        "-o", str(last_message_path),
    ])

    if model:
        cmd.extend(["-m", model])
    if sandbox:
        cmd.extend(["-s", sandbox])
    if full_auto:
        cmd.append("--full-auto")
    if skip_git_repo_check:
        cmd.append("--skip-git-repo-check")

    add_dirs: list[Path] = []
    if not _is_relative_to(skill_dir, workspace):
        add_dirs.append(skill_dir)
    if not _is_relative_to(state_dir, workspace):
        add_dirs.append(state_dir)
    for value in extra_dirs:
        add_dirs.append(Path(value).expanduser().resolve())
    seen: set[str] = set()
    for path in add_dirs:
        key = str(path)
        if key in seen:
            continue
        seen.add(key)
        cmd.extend(["--add-dir", key])

    cmd.extend(["--color", "never"])
    return cmd


# ---------------------------------------------------------------------------
# Response handling
# ---------------------------------------------------------------------------


def read_json_file(path: Path) -> dict[str, object]:
    try:
        raw = read_text(path).strip()
    except SystemExit as exc:
        raise JsonParseError(str(exc)) from exc
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise JsonParseError(f"JSON 파싱 실패: {path}\n{exc}\n---\n{raw}") from exc
    if not isinstance(data, dict):
        raise JsonParseError(f"JSON 최상위 구조는 object여야 합니다: {path}")
    return data


def fallback_response(round_num: int, message: str) -> dict[str, object]:
    return {
        "round": round_num,
        "objective": "",
        "hypothesis": "runner failure",
        "change_summary": "codex exec invocation failed",
        "hard_gates": {"result": "fail", "details": message},
        "metric": "unavailable",
        "evidence_summary": message,
        "experiment_status": "crash",
        "control_action": "escalate",
        "best_state_summary": "best-known state unchanged",
        "next_step": "inspect runner logs before continuing",
        "notes": message,
        "updated_files": [],
        "evidence_files": [],
    }


def validate_response_schema_basics(
    response: dict[str, object], *, response_path: Path
) -> dict[str, object]:
    required_fields = ("experiment_status", "control_action", "hypothesis")
    missing_fields = [field for field in required_fields if field not in response]
    if missing_fields:
        warn(
            "응답 JSON에 필수 필드가 없습니다 "
            f"({', '.join(missing_fields)}): {response_path}"
        )

    hypothesis = collapse_ws(str(response.get("hypothesis", "")).strip())
    if not hypothesis:
        warn(f"`hypothesis` 가 비어 있습니다: {response_path}")
        response["hypothesis"] = "(가설 없음)"
    else:
        response["hypothesis"] = hypothesis

    experiment_status = collapse_ws(str(response.get("experiment_status", "")).strip())
    if not experiment_status:
        warn(
            f"`experiment_status` 가 비어 있어 기본값 `crash` 를 사용합니다: {response_path}"
        )
        response["experiment_status"] = "crash"
    elif experiment_status not in VALID_EXPERIMENT_STATUSES:
        warn(
            "`experiment_status` 값이 유효하지 않아 기본값 `crash` 를 사용합니다 "
            f"({experiment_status}): {response_path}"
        )
        response["experiment_status"] = "crash"
    else:
        response["experiment_status"] = experiment_status

    control_action = collapse_ws(str(response.get("control_action", "")).strip())
    if not control_action:
        warn(
            f"`control_action` 이 비어 있어 기본값 `escalate` 를 사용합니다: {response_path}"
        )
        response["control_action"] = "escalate"
    elif control_action not in VALID_CONTROL_ACTIONS:
        warn(
            "`control_action` 값이 유효하지 않아 기본값 `escalate` 를 사용합니다 "
            f"({control_action}): {response_path}"
        )
        response["control_action"] = "escalate"
    else:
        response["control_action"] = control_action

    return response


def summarize_response(round_num: int, response: dict[str, object]) -> str:
    hard_gates = response.get("hard_gates", {})
    hard_gate_result = hard_gates.get("result", "?") if isinstance(hard_gates, dict) else "?"
    return (
        f"[round {round_num:03d}] "
        f"hard_gates={hard_gate_result} "
        f"experiment_status={response.get('experiment_status')} "
        f"control_action={response.get('control_action')} "
        f"hypothesis={collapse_ws(str(response.get('hypothesis', '')))}"
    )


def should_stop(
    control_action: str, loop_forever: bool, rounds_done: int, max_rounds: int | None
) -> bool:
    if max_rounds is not None and rounds_done >= max_rounds:
        return True
    if control_action in {"pass", "stop", "rescope", "escalate"}:
        return True
    if loop_forever:
        return False
    return False


# ---------------------------------------------------------------------------
# Main loop: cmd_run
# ---------------------------------------------------------------------------


def cmd_run(args: argparse.Namespace) -> int:
    workspace = resolve_workspace(args.workspace)
    state_dir = resolve_state_dir(workspace, args.state_dir)
    ensure_codex_exists(args.codex_bin)
    maybe_bootstrap_files(workspace, state_dir, args.objective, force=False)
    ensure_runtime_files(state_dir)

    program_path = state_dir / "program.md"
    contract_path = state_dir / "contract.md"
    snapshot_path = state_dir / "state_snapshot.md"
    ledger_path = state_dir / "ledger.tsv"
    rounds_dir = state_dir / "rounds"

    git_root = detect_git_root(workspace)
    state_dir_rel = _relative_to_or_none(state_dir, workspace)
    if git_root and not args.allow_dirty:
        ensure_clean_git_tree(workspace, state_dir_rel)

    commit_on_keep = args.commit_on_keep
    if commit_on_keep is None:
        commit_on_keep = git_root is not None

    max_rounds = None if args.loop_forever else args.max_rounds
    rounds_done = 0

    while True:
        round_num = next_round_number(ledger_path)
        round_dir = rounds_dir / f"round-{round_num:03d}"
        round_dir.mkdir(parents=True, exist_ok=True)

        prompt_path = round_dir / "prompt.md"
        last_message_path = round_dir / "last-message.json"
        response_path = round_dir / "response.json"
        stdout_path = round_dir / "codex-events.jsonl"
        stderr_path = round_dir / "codex-stderr.log"
        evidence_path = round_dir / "evidence.md"

        prompt = build_round_prompt(
            workspace=workspace,
            skill_dir=ROOT,
            state_dir=state_dir,
            program_path=program_path,
            contract_path=contract_path,
            snapshot_path=snapshot_path,
            ledger_path=ledger_path,
            round_dir=round_dir,
            round_num=round_num,
            head_ref=current_head(workspace) if git_root else None,
        )
        write_text(prompt_path, prompt)

        cmd = build_codex_command(
            codex_bin=args.codex_bin,
            workspace=workspace,
            skill_dir=ROOT,
            state_dir=state_dir,
            last_message_path=last_message_path,
            model=args.model,
            sandbox=args.sandbox,
            full_auto=args.full_auto,
            search=args.search,
            extra_dirs=args.add_dir or [],
            skip_git_repo_check=args.skip_git_repo_check or git_root is None,
        )

        print(f"== round {round_num:03d} ==")
        print("command:", " ".join(cmd))
        with stdout_path.open("w", encoding="utf-8") as stdout_handle, \
             stderr_path.open("w", encoding="utf-8") as stderr_handle:
            proc = subprocess.Popen(
                cmd,
                cwd=str(workspace),
                stdin=subprocess.PIPE,
                stdout=stdout_handle,
                stderr=stderr_handle,
                text=True,
            )
            try:
                proc.communicate(input=prompt, timeout=args.timeout_seconds or None)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
                response = fallback_response(
                    round_num,
                    f"codex exec timed out after {args.timeout_seconds} seconds (process killed)",
                )
            else:
                completed_returncode = proc.returncode
                if completed_returncode != 0:
                    response = fallback_response(
                        round_num,
                        f"codex exec failed with exit code {completed_returncode}; see {stdout_path} and {stderr_path}",
                    )
                elif not last_message_path.exists():
                    response = fallback_response(
                        round_num,
                        f"codex exec finished without writing {last_message_path}; see {stdout_path}",
                    )
                else:
                    try:
                        response = read_json_file(last_message_path)
                    except JsonParseError as exc:
                        response = fallback_response(round_num, str(exc))

        response = validate_response_schema_basics(response, response_path=last_message_path)

        write_text(response_path, json.dumps(response, ensure_ascii=False, indent=2) + "\n")

        experiment_status = str(response.get("experiment_status", ""))
        control_action = str(response.get("control_action", ""))
        evidence_ref = str(evidence_path if evidence_path.exists() else response_path)
        notes_suffix = ""
        keep_without_commit = False

        if git_root:
            if experiment_status == "keep":
                if commit_on_keep:
                    commit_ref = commit_keep_result(
                        workspace,
                        state_dir_rel,
                        round_num,
                        str(response.get("hypothesis", "")),
                    )
                    notes_suffix = f"(commit={commit_ref})"
                    if commit_ref.startswith(("stage-failed", "commit-failed")):
                        warn(f"git commit 실패: {commit_ref}")
                        if not args.allow_dirty:
                            keep_without_commit = True
                else:
                    notes_suffix = "(keep without auto-commit)"
                    if not args.allow_dirty:
                        keep_without_commit = True
            elif experiment_status in {"discard", "crash"} and workspace_changes_exist(
                workspace, state_dir_rel
            ):
                restored = restore_workspace(workspace, state_dir_rel)
                if restored:
                    notes_suffix = "(workspace reverted to HEAD)"
                else:
                    notes_suffix = "(workspace restore FAILED; dirty state possible)"
                    if not args.allow_dirty:
                        warn("workspace 복원 실패. --allow-dirty 없이 다음 라운드를 진행할 수 없습니다.")
                        keep_without_commit = True

        append_ledger_row(
            ledger_path,
            round_num=round_num,
            response=response,
            evidence_ref=evidence_ref,
            notes_suffix=notes_suffix,
        )

        print(summarize_response(round_num, response))
        print(f"  prompt:   {prompt_path}")
        print(f"  response: {response_path}")
        print(f"  stdout:   {stdout_path}")
        if evidence_path.exists():
            print(f"  evidence: {evidence_path}")
        print()

        rounds_done += 1
        if keep_without_commit:
            print(
                "keep 결과를 commit하지 않았기 때문에 자동 다중 라운드를 이어서 돌리지 않습니다.\n"
                "--commit-on-keep 또는 --allow-dirty를 사용하면 이어서 진행할 수 있습니다."
            )
            break
        if should_stop(control_action, args.loop_forever, rounds_done, max_rounds):
            break

        if git_root and not args.allow_dirty:
            ensure_clean_git_tree(workspace, state_dir_rel)

    return 0


# ---------------------------------------------------------------------------
# CLI parser
# ---------------------------------------------------------------------------


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="codex-research 스킬용 Codex CLI 반복 실행기",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # -- init --
    init_p = subparsers.add_parser("init", help="program/contract/state 템플릿 생성")
    init_p.add_argument("--workspace", default=".", help="연구를 수행할 workspace 디렉터리")
    init_p.add_argument(
        "--state-dir", help="상태 파일을 둘 디렉터리 (기본: <workspace>/.codex-research)"
    )
    init_p.add_argument("--objective", help="초기 objective 문장")
    init_p.add_argument("--force", action="store_true", help="기존 템플릿 파일도 덮어쓰기")
    init_p.set_defaults(func=cmd_init)

    # -- status --
    status_p = subparsers.add_parser("status", help="현재 snapshot/ledger 상태 출력")
    status_p.add_argument("--workspace", default=".", help="연구를 수행할 workspace 디렉터리")
    status_p.add_argument("--state-dir", help="상태 파일 디렉터리")
    status_p.set_defaults(func=cmd_status)

    # -- run --
    run_p = subparsers.add_parser("run", help="Codex CLI 연구 루프 실행")
    run_p.add_argument("--workspace", default=".", help="연구를 수행할 workspace 디렉터리")
    run_p.add_argument("--state-dir", help="상태 파일 디렉터리")
    run_p.add_argument("--objective", help="state dir가 아직 없을 때만 초기 objective로 사용")
    run_p.add_argument("--codex-bin", default="codex", help="Codex CLI 실행 파일 경로")
    run_p.add_argument("--model", help="codex exec 에 전달할 model")
    run_p.add_argument(
        "--sandbox",
        choices=["read-only", "workspace-write", "danger-full-access"],
        help="codex exec sandbox",
    )
    run_p.add_argument("--search", action="store_true", help="Codex web search 활성화")
    run_p.add_argument("--full-auto", action="store_true", help="codex exec --full-auto 전달")
    run_p.add_argument(
        "--skip-git-repo-check", action="store_true", help="codex exec --skip-git-repo-check 전달"
    )
    run_p.add_argument("--max-rounds", type=int, default=3, help="최대 라운드 수 (기본: 3)")
    run_p.add_argument(
        "--loop-forever",
        action="store_true",
        help="control_action이 종료 신호를 줄 때까지 계속 실행",
    )
    run_p.add_argument(
        "--timeout-seconds", type=int, default=1800, help="라운드별 codex exec 타임아웃 (기본: 1800)"
    )
    run_p.add_argument("--add-dir", action="append", help="codex exec 에 추가 writable directory 전달")
    run_p.add_argument("--allow-dirty", action="store_true", help="git dirty tree에서도 실행 허용")
    run_p.add_argument(
        "--commit-on-keep",
        dest="commit_on_keep",
        action="store_true",
        default=None,
        help="keep 결과를 자동 commit",
    )
    run_p.add_argument(
        "--no-commit-on-keep",
        dest="commit_on_keep",
        action="store_false",
        help="keep 결과를 자동 commit 하지 않음",
    )
    run_p.set_defaults(func=cmd_run)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
