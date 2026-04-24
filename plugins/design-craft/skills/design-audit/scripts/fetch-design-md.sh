#!/usr/bin/env bash
# fetch-design-md.sh
# 지정된 슬러그의 로컬 DESIGN.md 본문을 출력한다.
# 본문은 references/designs/{slug}.md에 바이트 수준으로 내재화되어 있다.
#
# 사용:
#   bash scripts/fetch-design-md.sh <slug>
#   bash scripts/fetch-design-md.sh stripe
#   bash scripts/fetch-design-md.sh linear.app
#
# 옵션:
#   --paths-only   본문 대신 경로·커맨드만 출력
#   --head N       본문의 앞 N행만 출력 (기본: 전체)

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN_DIR="${SKILL_DIR}/references/designs"

PATHS_ONLY=0
HEAD_LINES=""
SLUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths-only) PATHS_ONLY=1; shift ;;
    --head) HEAD_LINES="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
usage: $(basename "$0") <slug> [--paths-only] [--head N]

  <slug>           예: stripe, linear.app, x.ai
  --paths-only     본문 출력을 생략하고 경로만 표시
  --head N         본문 앞 N행만 표시
EOF
      exit 0
      ;;
    -*) echo "[error] 알 수 없는 옵션: $1" >&2; exit 2 ;;
    *)
      if [[ -z "$SLUG" ]]; then SLUG="$1"; else
        echo "[error] slug는 하나만 지정" >&2; exit 2
      fi
      shift
      ;;
  esac
done

if [[ -z "$SLUG" ]]; then
  echo "[error] slug를 지정하세요. 예: $(basename "$0") stripe" >&2
  exit 2
fi

LOCAL_FILE="${DESIGN_DIR}/${SLUG}.md"

if [[ ! -f "$LOCAL_FILE" ]]; then
  echo "[error] 로컬 본문 없음: $LOCAL_FILE" >&2
  echo "슬러그 목록 확인: ls $DESIGN_DIR | grep -v ATTRIBUTION" >&2
  exit 2
fi

cat <<EOF
==[ DESIGN.md: $SLUG ]==

# 로컬 경로 (즉시 접근, 권장)
Read plugins/design-craft/skills/design-audit/references/designs/${SLUG}.md

# 프로젝트 루트에 설치 (선택)
npx getdesign@latest add $SLUG

# 브라우저 확인
https://getdesign.md/${SLUG}/design-md

EOF

if [[ "$PATHS_ONLY" -eq 1 ]]; then
  exit 0
fi

echo "==[ BODY ]=="
if [[ -n "$HEAD_LINES" ]]; then
  head -n "$HEAD_LINES" "$LOCAL_FILE"
  echo
  echo "... (head $HEAD_LINES of $(wc -l <"$LOCAL_FILE" | tr -d ' ') lines)"
else
  cat "$LOCAL_FILE"
fi
