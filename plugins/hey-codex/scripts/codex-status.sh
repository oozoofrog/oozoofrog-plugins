#!/bin/bash
# hey-codex process status checker
# Usage: codex-status.sh <session-token>
#
# Checks whether a codex-run.sh session is still running.
# Uses PID file + kill -0 to verify process liveness.
#
# Output:
#   RUNNING (PID=<pid>, output=<N>lines)
#   COMPLETED
#   FAILED (exit code: <code>)
#   CRASHED (PID gone, status not updated)
#   NOT_FOUND

TOKEN="${1:?missing session token}"

PID_FILE="/tmp/codex-${TOKEN}-pid.txt"
STATUS_FILE="/tmp/codex-${TOKEN}-status.txt"
RAW_OUTPUT="/tmp/codex-${TOKEN}-raw.txt"

if [ ! -f "$STATUS_FILE" ]; then
  echo "NOT_FOUND"
  exit 0
fi

STATUS=$(cat "$STATUS_FILE")

case "$STATUS" in
  running)
    PID=$(cat "$PID_FILE" 2>/dev/null)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      LINES=$(wc -l < "$RAW_OUTPUT" 2>/dev/null | tr -d ' ' || echo 0)
      echo "RUNNING (PID=$PID, output=${LINES}lines)"
    else
      echo "CRASHED (PID gone, status not updated)"
    fi
    ;;
  completed)
    echo "COMPLETED"
    ;;
  failed:*)
    echo "FAILED (exit code: ${STATUS#failed:})"
    ;;
  *)
    echo "UNKNOWN ($STATUS)"
    ;;
esac
