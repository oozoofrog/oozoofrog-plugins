#!/bin/bash
set -euo pipefail

# SessionStart hook: CLAUDE.md 존재 여부 확인
# CLAUDE.md가 없으면 컨텍스트 아키텍처 초기화를 안내한다.

CLAUDE_MD="$CLAUDE_PROJECT_DIR/CLAUDE.md"

if [ ! -f "$CLAUDE_MD" ]; then
  cat <<EOF
{"systemMessage": "ℹ️ CLAUDE.md가 없습니다. \`/context-architect:init\`으로 컨텍스트 아키텍처를 초기화할 수 있습니다."}
EOF
fi
