#!/bin/bash
# hey-codex preflight check
# Usage: preflight.sh
# Exit codes: 0=OK, 1=codex not installed
# stdout: "ok" on success, error message on failure

if ! command -v codex &>/dev/null; then
    echo "codex CLI가 설치되어 있지 않습니다. npm install -g @openai/codex 로 설치해주세요."
    exit 1
fi

echo "ok"
exit 0
