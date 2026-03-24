#!/bin/bash
# codex-delegate output processor
# Usage: process-output.sh [raw_output_file]
# - Strips ANSI escape codes
# - Counts lines
# - If >200 lines, saves to /tmp and outputs path
# stdout format:
#   Line 1: line_count
#   Line 2: "inline" | "/tmp/codex-output-XXXX.txt"
#   Line 3+: cleaned output (if inline)

INPUT="${1:--}"
CLEANED=$(cat "$INPUT" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed 's/\x1b\([0-9;]*[a-zA-Z]//g')
LINE_COUNT=$(echo "$CLEANED" | wc -l | tr -d ' ')

echo "$LINE_COUNT"

if [ "$LINE_COUNT" -gt 200 ]; then
    OUTFILE="/tmp/codex-output-$(date +%s).txt"
    echo "$CLEANED" > "$OUTFILE"
    echo "$OUTFILE"
else
    echo "inline"
    echo "$CLEANED"
fi
