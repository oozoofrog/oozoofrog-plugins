#!/bin/bash
# hey-codex background runner
# Usage: codex-run.sh <mode> <working-dir> [prompt] [extra-flags...]
#   mode: exec | review | exec-full-auto
#
# Launches codex CLI, tracks PID, waits for completion,
# then runs process-output.sh on the raw output.
#
# Session files (TOKEN = nanosecond timestamp):
#   /tmp/codex-{TOKEN}-pid.txt    — codex PID (removed on completion)
#   /tmp/codex-{TOKEN}-raw.txt    — raw stdout+stderr
#   /tmp/codex-{TOKEN}-status.txt — running | completed | failed:{exit_code}
#
# stdout (what Claude reads on background completion):
#   Line 1: SESSION=<TOKEN>
#   Remaining: process-output.sh result (on success) or raw stderr (on failure)

set -euo pipefail

TOKEN=$(date +%s%N)
MODE="${1:?missing mode (exec|review|exec-full-auto)}"; shift
WORKDIR="${1:?missing working directory}"; shift

PID_FILE="/tmp/codex-${TOKEN}-pid.txt"
RAW_OUTPUT="/tmp/codex-${TOKEN}-raw.txt"
STATUS_FILE="/tmp/codex-${TOKEN}-status.txt"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "running" > "$STATUS_FILE"
echo "SESSION=$TOKEN"

# Launch codex based on mode
case "$MODE" in
  exec)
    codex exec --cd "$WORKDIR" "$@" > "$RAW_OUTPUT" 2>&1 &
    ;;
  review)
    codex review --cd "$WORKDIR" "$@" > "$RAW_OUTPUT" 2>&1 &
    ;;
  exec-full-auto)
    codex exec --full-auto --cd "$WORKDIR" "$@" > "$RAW_OUTPUT" 2>&1 &
    ;;
  *)
    echo "unknown mode: $MODE" >&2
    echo "failed:1" > "$STATUS_FILE"
    exit 1
    ;;
esac

CODEX_PID=$!
echo "$CODEX_PID" > "$PID_FILE"

# Wait for codex to finish (no timeout — runs until natural completion)
set +e
wait "$CODEX_PID"
EXIT_CODE=$?
set -e

# Clean up PID file
rm -f "$PID_FILE"

# Report result
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "completed" > "$STATUS_FILE"
  bash "$SCRIPT_DIR/process-output.sh" "$RAW_OUTPUT"
else
  echo "failed:$EXIT_CODE" > "$STATUS_FILE"
  echo "EXIT_CODE=$EXIT_CODE"
  cat "$RAW_OUTPUT" 2>/dev/null || true
fi
