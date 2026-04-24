#!/usr/bin/env bash
# sync-designs.sh
# npm 레지스트리의 최신 getdesign tarball을 내려받아
# references/designs/ 디렉토리를 재동기화한다.
#
# 동작:
#   1) 최신 버전 확인
#   2) tarball 다운로드
#   3) templates/*.md 및 manifest.json을 references/designs/로 복사
#   4) ATTRIBUTION.md는 보존(덮어쓰지 않음)
#
# 사용:
#   bash scripts/sync-designs.sh [--dry-run]

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="${SKILL_DIR}/references/designs"
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) echo "[error] 알 수 없는 옵션: $arg" >&2; exit 2 ;;
  esac
done

if ! command -v curl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
  echo "[error] curl, python3, tar가 필요합니다" >&2
  exit 2
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

META_JSON="${TMP_DIR}/meta.json"
curl -sfL "https://registry.npmjs.org/getdesign" -o "$META_JSON"

LATEST_VERSION="$(python3 -c "import json; d=json.load(open('$META_JSON')); print(d['dist-tags']['latest'])")"
TARBALL_URL="$(python3 -c "import json; d=json.load(open('$META_JSON')); v=d['dist-tags']['latest']; print(d['versions'][v]['dist']['tarball'])")"

echo "==[ sync-designs ]=="
echo "source: getdesign@$LATEST_VERSION"
echo "dest:   $DEST_DIR"
[[ "$DRY_RUN" -eq 1 ]] && echo "mode:   dry-run (파일 변경 없음)"
echo

TARBALL="${TMP_DIR}/pkg.tgz"
curl -sfL "$TARBALL_URL" -o "$TARBALL"
tar -xzf "$TARBALL" -C "$TMP_DIR"

SRC_TEMPLATES="${TMP_DIR}/package/templates"
if [[ ! -d "$SRC_TEMPLATES" ]]; then
  echo "[error] tarball 구조가 예상과 다릅니다: $SRC_TEMPLATES 없음" >&2
  exit 2
fi

# 신규/변경/삭제 계산
TO_ADD=()
TO_UPDATE=()
TO_DELETE=()

for src in "$SRC_TEMPLATES"/*.md "$SRC_TEMPLATES"/manifest.json; do
  name="$(basename "$src")"
  dst="${DEST_DIR}/${name}"
  if [[ ! -f "$dst" ]]; then
    TO_ADD+=("$name")
  elif ! cmp -s "$src" "$dst"; then
    TO_UPDATE+=("$name")
  fi
done

shopt -s nullglob
for dst in "${DEST_DIR}"/*.md; do
  name="$(basename "$dst")"
  [[ "$name" == "ATTRIBUTION.md" ]] && continue
  if [[ ! -f "${SRC_TEMPLATES}/${name}" ]]; then
    TO_DELETE+=("$name")
  fi
done
shopt -u nullglob

echo "ADD:    ${#TO_ADD[@]} 파일"
[[ ${#TO_ADD[@]} -gt 0 ]] && printf '  + %s\n' "${TO_ADD[@]}"
echo "UPDATE: ${#TO_UPDATE[@]} 파일"
[[ ${#TO_UPDATE[@]} -gt 0 ]] && printf '  ~ %s\n' "${TO_UPDATE[@]}"
echo "DELETE: ${#TO_DELETE[@]} 파일"
[[ ${#TO_DELETE[@]} -gt 0 ]] && printf '  - %s\n' "${TO_DELETE[@]}"
echo

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] 실제 변경은 수행되지 않았습니다."
  exit 0
fi

if [[ ${#TO_ADD[@]} -eq 0 && ${#TO_UPDATE[@]} -eq 0 && ${#TO_DELETE[@]} -eq 0 ]]; then
  echo "이미 동기화 상태. 변경 사항 없음."
  exit 0
fi

# 실제 동기화
for name in "${TO_ADD[@]}" "${TO_UPDATE[@]}"; do
  cp "${SRC_TEMPLATES}/${name}" "${DEST_DIR}/${name}"
done

for name in "${TO_DELETE[@]}"; do
  rm -f "${DEST_DIR}/${name}"
done

echo "동기화 완료 → getdesign@$LATEST_VERSION"
echo "다음 단계: references/catalog-index.md의 표에 신규/삭제 브랜드 반영"
