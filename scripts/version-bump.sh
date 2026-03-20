#!/bin/bash
# Usage: ./scripts/version-bump.sh <plugin-name> [patch|minor|major]
# Bumps version in both plugin.json and marketplace.json

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_NAME="${1:?Usage: version-bump.sh <plugin-name> [patch|minor|major]}"
BUMP_TYPE="${2:-patch}"

PLUGIN_JSON="$REPO_ROOT/plugins/$PLUGIN_NAME/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"

if [ ! -f "$PLUGIN_JSON" ]; then
  echo "ERROR: Plugin '$PLUGIN_NAME' not found at $PLUGIN_JSON"
  exit 1
fi

# Get current version from marketplace.json (source of truth)
CURRENT_VERSION=$(python3 -c "
import json, sys
with open('$MARKETPLACE_JSON') as f:
    data = json.load(f)
for p in data['plugins']:
    if p['name'] == '$PLUGIN_NAME':
        print(p.get('version', '0.0.0'))
        sys.exit(0)
print('0.0.0')
")

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP_TYPE" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
  *) echo "ERROR: Invalid bump type '$BUMP_TYPE' (use patch|minor|major)"; exit 1 ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Update marketplace.json
python3 -c "
import json
with open('$MARKETPLACE_JSON', 'r') as f:
    data = json.load(f)
for p in data['plugins']:
    if p['name'] == '$PLUGIN_NAME':
        p['version'] = '$NEW_VERSION'
with open('$MARKETPLACE_JSON', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

# Update plugin.json (add version if missing)
python3 -c "
import json
with open('$PLUGIN_JSON', 'r') as f:
    data = json.load(f)
data['version'] = '$NEW_VERSION'
with open('$PLUGIN_JSON', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

echo "$PLUGIN_NAME: $CURRENT_VERSION → $NEW_VERSION"
