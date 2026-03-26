#!/bin/bash
set -eo pipefail

# SessionStart hook: CLAUDE.md 라인 수 초과 경고
# CLAUDE.md가 200라인을 초과하면 경고, 없으면 초기화를 안내한다.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"

if [ ! -f "$CLAUDE_MD" ]; then
  cat <<EOF
{"systemMessage": "ℹ️ CLAUDE.md가 없습니다. \`/context-architect:init\`으로 컨텍스트 아키텍처를 초기화할 수 있습니다."}
EOF
  exit 0
fi

LINE_COUNT=$(wc -l < "$CLAUDE_MD" | tr -d ' ')

if [ "$LINE_COUNT" -gt 200 ]; then
  cat <<EOF
{"systemMessage": "⚠️ CLAUDE.md가 ${LINE_COUNT}라인으로 200라인 제한을 초과합니다. 컨텍스트 부패(Context Rot) 위험이 있습니다. \`/context-architect:audit\`을 실행하여 분리 대상을 확인하세요."}
EOF
fi
