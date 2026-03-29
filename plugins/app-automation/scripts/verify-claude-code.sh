#!/bin/bash
# Claude Code CLI 기반 app-automation 플러그인 검증 스크립트

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_DIR/../.." && pwd)"

RUN_AGENT_SMOKE=1
PRINT_RUNTIME_COMMAND=1

usage() {
  cat <<'EOF'
Usage:
  plugins/app-automation/scripts/verify-claude-code.sh [options]

Options:
  --no-agent-smoke       `claude --agent app-automation:ui-verifier` 스모크 테스트를 건너뜁니다.
  --no-runtime-command   마지막에 수동 런타임 검증용 예시 명령을 출력하지 않습니다.
  -h, --help             도움말을 출력합니다.

이 스크립트가 확인하는 것:
  1. Claude Code CLI 설치 및 버전
  2. Claude 인증 상태
  3. app-automation plugin manifest 유효성
  4. session-only plugin 로드 여부 (--plugin-dir)
  5. ui-verifier agent 등록 여부
  6. SKILL.md의 Stop agent hook 선언 존재 여부
  7. (기본) ui-verifier agent를 main agent로 직접 실행하는 간단한 스모크 테스트
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-agent-smoke)
      RUN_AGENT_SMOKE=0
      shift
      ;;
    --no-runtime-command)
      PRINT_RUNTIME_COMMAND=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "알 수 없는 옵션: $1" >&2
      echo "" >&2
      usage >&2
      exit 2
      ;;
  esac
done

pass() {
  echo "✔ $1"
}

fail() {
  echo "✘ $1" >&2
  exit 1
}

section() {
  echo ""
  echo "== $1 =="
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "필수 명령을 찾을 수 없습니다: $1"
}

require_command claude
require_command python3

cd "$REPO_ROOT"

section "Claude Code CLI"
CLAUDE_VERSION="$(claude --version)"
echo "$CLAUDE_VERSION"
pass "Claude Code CLI를 찾았습니다."

section "Claude 인증 상태"
AUTH_JSON="$(claude auth status)"
echo "$AUTH_JSON"
python3 - "$AUTH_JSON" <<'PY'
import json
import sys
data = json.loads(sys.argv[1])
if not data.get("loggedIn"):
    raise SystemExit(1)
PY
pass "Claude 인증이 유효합니다."

section "Plugin manifest 검증"
claude plugin validate "$PLUGIN_DIR" >/tmp/app-automation-plugin-validate.log
cat /tmp/app-automation-plugin-validate.log
pass "plugin manifest 검증 통과"

section "Plugin agent 등록 확인"
AGENTS_OUTPUT="$(claude --plugin-dir "$PLUGIN_DIR" agents)"
echo "$AGENTS_OUTPUT"
echo "$AGENTS_OUTPUT" | grep -q 'app-automation:ui-verifier' || fail "app-automation:ui-verifier agent가 목록에 없습니다."
pass "ui-verifier agent가 등록되었습니다."

section "Session-only plugin 로드 확인"
PLUGIN_LIST_OUTPUT="$(claude --plugin-dir "$PLUGIN_DIR" plugin list)"
echo "$PLUGIN_LIST_OUTPUT"
echo "$PLUGIN_LIST_OUTPUT" | grep -q 'Session-only plugins (--plugin-dir):' || fail "session-only plugin 섹션을 찾지 못했습니다."
echo "$PLUGIN_LIST_OUTPUT" | grep -q 'app-automation@inline' || fail "app-automation session-only plugin이 로드되지 않았습니다."
pass "--plugin-dir 로 session-only plugin 로드 확인"

section "SKILL hook 선언 확인"
grep -q '^hooks:' "$PLUGIN_DIR/skills/app-automation/SKILL.md" || fail "SKILL.md frontmatter에 hooks 선언이 없습니다."
grep -q 'type: agent' "$PLUGIN_DIR/skills/app-automation/SKILL.md" || fail "SKILL.md에 agent hook 선언이 없습니다."
pass "app-automation skill의 Stop agent hook 선언을 확인했습니다."

if [[ "$RUN_AGENT_SMOKE" -eq 1 ]]; then
  section "ui-verifier agent 스모크 테스트"
  AGENT_SMOKE_OUTPUT="$(
    claude \
      --plugin-dir "$PLUGIN_DIR" \
      --agent app-automation:ui-verifier \
      -p "Say OK in one word."
  )"
  echo "$AGENT_SMOKE_OUTPUT"
  [[ "$AGENT_SMOKE_OUTPUT" == "OK" ]] || fail "ui-verifier agent 스모크 테스트가 예상 출력(OK)과 다릅니다."
  pass "ui-verifier agent를 Claude Code CLI에서 직접 실행할 수 있습니다."
fi

section "요약"
pass "Claude Code CLI 기반 기본 검증이 모두 통과했습니다."

if [[ "$PRINT_RUNTIME_COMMAND" -eq 1 ]]; then
  cat <<EOF

다음은 수동 런타임 검증 예시입니다.

1) 대화형 세션:
   claude --plugin-dir "$PLUGIN_DIR"

   세션 안에서 예:
   Use app-automation to run doctor and list available simulators, then use the ui-verifier agent to verify the evidence.

2) verifier를 main agent로 직접 실행:
   claude --plugin-dir "$PLUGIN_DIR" --agent app-automation:ui-verifier

3) 비대화형 1회 실행(환경에 따라 시간이 걸릴 수 있음):
   claude --plugin-dir "$PLUGIN_DIR" --agent app-automation:ui-verifier -p "Run a lightweight environment check for app-automation and report PASS or FAIL with one short reason."
EOF
fi
