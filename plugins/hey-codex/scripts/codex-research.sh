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
  codex-research.sh init . "Codex CLI 연구 루프를 개선한다"
  codex-research.sh status .
  codex-research.sh run . --max-rounds 5 --search --full-auto

Notes:
  - workspace를 생략하면 현재 디렉터리를 사용합니다.
  - run 뒤의 추가 인자는 그대로 codex-research.py run 에 전달됩니다.
  - PYTHON_BIN 환경변수로 사용할 python 실행 파일을 바꿀 수 있습니다.
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
    if [[ $# -gt 0 ]]; then
      shift
    fi
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
    workspace="$PWD"
    if [[ $# -gt 0 ]]; then
      if [[ "$1" == --* ]]; then
        echo "경고: workspace 인자 '$1' 가 옵션처럼 보여 현재 디렉터리($PWD)를 사용합니다." >&2
      else
        workspace="$1"
        shift
      fi
    fi
    exec "$PYTHON_BIN" "$RUNNER" run --workspace "$workspace" "$@"
    ;;

  *)
    echo "알 수 없는 명령: $subcommand" >&2
    echo >&2
    usage >&2
    exit 1
    ;;
esac
