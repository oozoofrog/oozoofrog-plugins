#!/usr/bin/env bash
# fetch-catalog-diff.sh
# npm 레지스트리의 최신 getdesign 패키지 tarball을 내려받아
# 로컬 references/designs/manifest.json과 비교.
# 신규/삭제/해시 변경된 브랜드를 출력한다.
#
# 사용:
#   bash scripts/fetch-catalog-diff.sh
#
# 종료 코드:
#   0 — 차이 없음 (동기화 상태)
#   1 — 차이 발견 (sync-designs.sh 실행 권장)
#   2 — 실행 환경 오류

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_MANIFEST="${SKILL_DIR}/references/designs/manifest.json"

if ! command -v curl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
  echo "[error] curl과 python3가 필요합니다" >&2
  exit 2
fi

if [[ ! -f "$LOCAL_MANIFEST" ]]; then
  echo "[error] 로컬 manifest 없음: $LOCAL_MANIFEST" >&2
  exit 2
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# npm 레지스트리 메타데이터에서 최신 버전과 tarball URL 조회
META_JSON="${TMP_DIR}/meta.json"
if ! curl -sfL "https://registry.npmjs.org/getdesign" -o "$META_JSON"; then
  echo "[error] npm 레지스트리 조회 실패" >&2
  exit 2
fi

LATEST_VERSION="$(python3 -c "import json; d=json.load(open('$META_JSON')); print(d['dist-tags']['latest'])")"
TARBALL_URL="$(python3 -c "import json; d=json.load(open('$META_JSON')); v=d['dist-tags']['latest']; print(d['versions'][v]['dist']['tarball'])")"

echo "==[ awesome-design-md catalog diff ]=="
echo "latest getdesign version: $LATEST_VERSION"
echo "tarball:                  $TARBALL_URL"
echo

# tarball 다운로드 및 manifest.json 추출
TARBALL="${TMP_DIR}/pkg.tgz"
REMOTE_MANIFEST="${TMP_DIR}/manifest.json"

if ! curl -sfL "$TARBALL_URL" -o "$TARBALL"; then
  echo "[error] tarball 다운로드 실패" >&2
  exit 2
fi

if ! tar -xzf "$TARBALL" -C "$TMP_DIR" package/templates/manifest.json 2>/dev/null; then
  echo "[error] tarball에서 manifest.json 추출 실패" >&2
  exit 2
fi

mv "${TMP_DIR}/package/templates/manifest.json" "$REMOTE_MANIFEST"

# 두 manifest 비교
python3 - "$LOCAL_MANIFEST" "$REMOTE_MANIFEST" <<'PY'
import json, sys

local_path, remote_path = sys.argv[1], sys.argv[2]
local  = {e["brand"]: e for e in json.load(open(local_path))}
remote = {e["brand"]: e for e in json.load(open(remote_path))}

added   = sorted(set(remote) - set(local))
removed = sorted(set(local)  - set(remote))
changed = []
for brand in sorted(set(local) & set(remote)):
    lh = local[brand].get("templateHash")
    rh = remote[brand].get("templateHash")
    if lh != rh:
        changed.append((brand, lh, rh))

print(f"local brands:  {len(local)}")
print(f"remote brands: {len(remote)}")
print()

any_diff = False

if added:
    any_diff = True
    print("## 신규 브랜드 (원격에만 있음)")
    for b in added:
        print(f"  + {b} — {remote[b].get('description','').strip()}")
    print()

if removed:
    any_diff = True
    print("## 제거된 브랜드 (로컬에만 있음)")
    for b in removed:
        print(f"  - {b}")
    print()

if changed:
    any_diff = True
    print(f"## 본문 변경된 브랜드 ({len(changed)}개)")
    for b, lh, rh in changed:
        print(f"  ~ {b}")
        print(f"      local : {lh}")
        print(f"      remote: {rh}")
    print()

if not any_diff:
    print("차이 없음. references/designs/는 원격과 동기화 상태입니다.")
    sys.exit(0)

print("== 동기화 방법 ==")
print("  bash scripts/sync-designs.sh")
print("  # 확인 후 references/catalog-index.md의 표도 필요 시 갱신")
sys.exit(1)
PY
