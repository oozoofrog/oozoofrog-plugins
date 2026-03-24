#!/bin/bash
# hey-codex output processor
# Usage: process-output.sh [raw_output_file]
# - Strips ANSI escape codes (CSI sequences)
# - Counts lines
# - Outputs disposition based on line count thresholds
# stdout format:
#   Line 1: line_count
#   Line 2: "short" (<50) | "long" (50-200) | "/tmp/codex-output-XXXX.txt" (>200)
#   Line 3+: cleaned output (if short or long)
# The caller (LLM) should:
#   "short" → display as-is
#   "long"  → summarize + offer to show full output
#   path    → summarize + show saved path

INPUT="${1:--}"
CLEANED=$(cat "$INPUT" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
LINE_COUNT=$(echo "$CLEANED" | wc -l | tr -d ' ')

echo "$LINE_COUNT"

if [ "$LINE_COUNT" -gt 200 ]; then
    OUTFILE="/tmp/codex-output-$(date +%s).txt"
    echo "$CLEANED" > "$OUTFILE"
    echo "$OUTFILE"
elif [ "$LINE_COUNT" -ge 50 ]; then
    echo "long"
    echo "$CLEANED"
else
    echo "short"
    echo "$CLEANED"
fi
