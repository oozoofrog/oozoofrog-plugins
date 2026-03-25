#!/bin/zsh
# apple-craft: 참조 문서 존재 확인
REF_DIR="${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references"
count=$(find "$REF_DIR" -name "*.md" ! -name "_index.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$count" -lt 1 ]]; then
  echo "apple-craft: 참조 문서가 없습니다. scripts/sync-docs.sh를 먼저 실행하세요." >&2
  exit 1
fi
echo "apple-craft: ${count}개 참조 문서 확인됨"
