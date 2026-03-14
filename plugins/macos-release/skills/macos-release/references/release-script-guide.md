# 릴리스 스크립트 생성 가이드

`scripts/release.sh`를 처음 만들 때 참조하는 상세 가이드입니다.

## 스크립트 구조

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── 설정 변수 ──
APP_NAME="AppName"
SCHEME="AppName"
PROJECT_DIR="AppName"
GITHUB_REPO="user/Repo"

# ── 경로 계산 ──
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PBXPROJ="${REPO_ROOT}/${PROJECT_DIR}/AppName.xcodeproj/project.pbxproj"

# Homebrew tap (환경변수 덮어쓰기 가능)
HOMEBREW_TAP="${HOMEBREW_TAP_PATH:-${REPO_ROOT}/../homebrew-tap}"

# ── 플래그 ──
DRY_RUN=0
SKIP_BREW=0
NEW_VERSION=""
```

## 각 단계 상세

### 1. 인자 파싱

지원해야 할 옵션:
- `--dry-run`: 모든 단계를 출력만 하고 실행하지 않음
- `--skip-brew`: Homebrew Cask 업데이트 건너뛰기
- `-h, --help`: 사용법 출력
- 위치 인자: 버전 번호 (없으면 자동 증가)

### 2. 사전 검증 (Step 0)

```bash
command -v gh >/dev/null 2>&1 || err "gh CLI 필요"
command -v xcodebuild >/dev/null 2>&1 || err "xcodebuild 필요"
[[ -f "${PBXPROJ}" ]] || err "pbxproj 없음"

# 깨끗한 작업 디렉토리 확인 (untracked 파일 제외)
DIRTY=$(git status --porcelain | grep -v '^\?\?' || true)
[[ -z "${DIRTY}" ]] || err "커밋되지 않은 변경사항 있음"

# 태그 중복 확인
git tag -l "${RELEASE_TAG}" | grep -q "${RELEASE_TAG}" && err "태그 존재"
```

### 3. 버전 범프 (Step 1)

```bash
CURRENT_VERSION=$(grep 'MARKETING_VERSION' "$PBXPROJ" | head -1 | sed 's/.*= *//;s/ *;.*//')
CURRENT_BUILD=$(grep 'CURRENT_PROJECT_VERSION' "$PBXPROJ" | head -1 | sed 's/.*= *//;s/ *;.*//')

# 자동 증가: 마이너 버전 +1
if [[ -z "$NEW_VERSION" ]]; then
  MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
  MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
  NEW_VERSION="${MAJOR}.$((MINOR + 1))"
fi
NEW_BUILD=$((CURRENT_BUILD + 1))

# sed로 pbxproj 업데이트 (macOS sed는 -i '' 필요)
sed -i '' "s/MARKETING_VERSION = ${CURRENT_VERSION}/MARKETING_VERSION = ${NEW_VERSION}/g" "$PBXPROJ"
sed -i '' "s/CURRENT_PROJECT_VERSION = ${CURRENT_BUILD}/CURRENT_PROJECT_VERSION = ${NEW_BUILD}/g" "$PBXPROJ"
```

주의: `sed -i` 는 Linux와 macOS에서 동작이 다릅니다.
- macOS: `sed -i '' 's/...'`
- Linux: `sed -i 's/...'`

### 4. Release 빌드 (Step 2)

```bash
DERIVED_DATA="${REPO_ROOT}/.build/xcode"

xcodebuild \
  -project "${REPO_ROOT}/${PROJECT_DIR}/AppName.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration Release \
  -derivedDataPath "${DERIVED_DATA}" \
  -destination 'platform=macOS' \
  clean build 2>&1 | tail -5
```

`-derivedDataPath`를 별도로 지정하는 이유: Xcode의 기본 DerivedData와 섞이지 않게 하고, 빌드 결과물 경로를 예측 가능하게 만듭니다.

### 5. DMG 생성 (Step 3)

```bash
# 스테이징
DMG_STAGING="${REPO_ROOT}/.build/dmg-staging"
mkdir -p "${DMG_STAGING}"
ditto "${BUILT_APP}" "${DMG_STAGING}/${APP_NAME}.app"
ln -s /Applications "${DMG_STAGING}/Applications"

# 임시 read-write DMG
TEMP_DMG="${REPO_ROOT}/.build/temp.dmg"
hdiutil create -srcfolder "${DMG_STAGING}" -volname "${APP_NAME}" \
  -fs HFS+ -format UDRW -size 50m "${TEMP_DMG}" -quiet

# Finder 레이아웃 설정 (osascript)
MOUNT_DIR=$(hdiutil attach "${TEMP_DMG}" -readwrite -noverify -noautoopen | grep "/Volumes/" | awk '{print $NF}')
# ... AppleScript로 아이콘 위치 설정 ...
hdiutil detach "${MOUNT_DIR}" -quiet

# 압축 변환
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${DMG_PATH}" -quiet

# SHA256 (Homebrew 용)
DMG_SHA256=$(shasum -a 256 "${DMG_PATH}" | awk '{print $1}')
```

DMG 포맷:
- `UDRW`: read-write (Finder 설정용 임시)
- `UDZO`: zlib 압축 read-only (배포용 최종)

### 6. 로컬 설치 (Step 4)

기존 앱 종료 → ~/Applications에 복사 → 재실행. 상세 코드는 SKILL.md 참조.

### 7. Git 작업 (Step 5)

```bash
git add "${PBXPROJ}"
git commit -m "Bump version to ${NEW_VERSION} (build ${NEW_BUILD})"
git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"
git push origin main
git push origin "${RELEASE_TAG}"
```

### 8. GitHub Release (Step 6)

```bash
# 릴리스 노트: 이전 태그~HEAD 커밋 메시지
RELEASE_NOTES=$(git log --pretty=format:"- %s" "v${CURRENT_VERSION}..HEAD" | grep -v "Bump version" || echo "- 업데이트")

gh release create "${RELEASE_TAG}" "${DMG_PATH}" \
  --repo "${GITHUB_REPO}" \
  --title "${APP_NAME} ${RELEASE_TAG}" \
  --notes "${RELEASE_NOTES}"

# 릴리스 후 로컬 DMG 삭제
rm -f "${DMG_PATH}"
```

### 9. Homebrew Cask (Step 7)

```bash
CASK_FILE="${HOMEBREW_TAP}/Casks/appname.rb"
mkdir -p "$(dirname "${CASK_FILE}")"

cat > "${CASK_FILE}" <<CASK
cask "appname" do
  version "${NEW_VERSION}"
  sha256 "${DMG_SHA256}"
  url "https://github.com/${GITHUB_REPO}/releases/download/v#{version}/App-#{version}.dmg"
  name "AppName"
  desc "App description"
  homepage "https://github.com/${GITHUB_REPO}"
  depends_on macos: ">= :ventura"
  app "AppName.app"
  zap trash: ["~/Library/Preferences/com.user.app.plist"]
end
CASK

cd "${HOMEBREW_TAP}"
git add "${CASK_FILE}"
git commit -m "Update AppName cask to ${NEW_VERSION}"
git pull --rebase origin main 2>/dev/null || true
git push origin main
```

## 유틸리티 함수 패턴

```bash
step() { echo ""; echo "==> $1"; }
info() { echo "    $1"; }
err()  { echo "오류: $1" >&2; exit 1; }

run() {
  if [[ ${DRY_RUN} -eq 1 ]]; then
    info "[dry-run] $*"
  else
    "$@"
  fi
}
```

## 스크립트 기능 체크리스트

- [ ] `--dry-run` 플래그
- [ ] `--skip-brew` 플래그
- [ ] `--help` 사용법
- [ ] 사전 검증 (도구, 깨끗한 상태, 태그 중복)
- [ ] 버전 자동 증가 또는 명시적 지정
- [ ] clean build
- [ ] DMG 생성 (Finder 레이아웃 포함)
- [ ] 로컬 설치 (앱 종료 → 복사 → 재실행)
- [ ] Git commit + tag + push
- [ ] GitHub Release + DMG 첨부
- [ ] Homebrew Cask 업데이트 (pull --rebase 포함)
- [ ] 한국어 (또는 사용자 언어) 메시지
- [ ] HOMEBREW_TAP_PATH 환경변수 지원
