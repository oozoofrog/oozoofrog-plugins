#!/bin/bash
# Check if plugin files were modified without a version bump.
# Used as a Stop hook to remind about version updates.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Get modified plugin directories from unstaged + staged changes
MODIFIED_PLUGINS=$(git diff --name-only HEAD 2>/dev/null | grep '^plugins/' | cut -d'/' -f2 | sort -u || true)

if [ -z "$MODIFIED_PLUGINS" ]; then
  exit 0
fi

WARNINGS=""

for PLUGIN in $MODIFIED_PLUGINS; do
  # Check if version-related files were also changed
  VERSION_CHANGED=$(git diff --name-only HEAD 2>/dev/null | grep -E "^(plugins/$PLUGIN/\.claude-plugin/plugin\.json|\.claude-plugin/marketplace\.json)$" || true)

  if [ -z "$VERSION_CHANGED" ]; then
    WARNINGS="$WARNINGS\n  - $PLUGIN"
  fi
done

if [ -n "$WARNINGS" ]; then
  echo "⚠️  다음 플러그인이 수정되었지만 버전이 업데이트되지 않았습니다:$WARNINGS"
  echo ""
  echo "버전 업데이트: ./scripts/version-bump.sh <plugin-name> [patch|minor|major]"
fi
