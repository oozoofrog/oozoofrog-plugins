---
name: appstore-deploy
description: "App Store release automation — run the full pipeline at once or control it step by step. Auto-detects and self-heals errors during deployment, and self-diagnoses script/environment issues. Use for '배포', 'deploy', 'TestFlight', '앱스토어', 'App Store', '스크린샷', 'screenshots', '메타데이터', 'metadata', '베타', '출시', 'App Preview', '시연 영상' requests. For the full release pipeline use the /release skill. Use this skill to directly run individual deployment steps (screenshots, metadata, TestFlight, App Store)."
---

# App Store Release Automation

Manages the App Store deployment pipeline for Apple apps. Auto-detects errors during deployment and self-heals where possible.

Respond to the user in Korean.

## Core Principle: Self-Healing

Every step in this skill follows an **Execute → Verify → Repair** loop:

```
실행 (Execute)
  → 성공? → 다음 단계
  → 실패? → 오류 분석 (Diagnose)
    → 자동 수복 가능? → 수복 (Repair) → 재실행
    → 수복 불가? → 사용자에게 수동 실행 안내 (! 명령 제시)
```

---

## Phase 0: Pre-flight Check

Run this before starting any deployment workflow — it catches environment problems early before they fail mid-pipeline.

### Auto-detect the project

```bash
# Xcode 프로젝트 탐지
XCODEPROJ=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)
XCWORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" | head -1)

# 스킴 목록
xcodebuild -project "$XCODEPROJ" -list -json 2>/dev/null | jq -r '.project.schemes[]'

# 현재 버전
grep 'MARKETING_VERSION' "${XCODEPROJ}/project.pbxproj" | sort -u

# fastlane 설정
test -f fastlane/Fastfile && echo "Fastfile: OK" || echo "Fastfile: MISSING"
test -f fastlane/Appfile && echo "Appfile: OK" || echo "Appfile: MISSING"
```

### Verify the environment

```bash
# 1. fastlane 설치 확인
which fastlane || echo "MISSING"

# 2. App Store Connect API Key 탐지
# 일반적인 경로들을 순서대로 확인
for keypath in \
  ~/.appstoreconnect/AuthKey_*.p8 \
  ~/.private_keys/AuthKey_*.p8 \
  fastlane/AuthKey_*.p8; do
  ls $keypath 2>/dev/null && break
done

# 3. 시뮬레이터 상태 확인
xcrun simctl list devices available | grep -E "(iPhone|Apple Watch)" | head -5

# 4. Git 상태 확인
git status --porcelain
```

### Auto-repair matrix

| Problem | Auto-repair | Method |
|------|----------|------|
| fastlane not installed | ✅ | Run `gem install fastlane` |
| API Key missing | ❌ | Point the user to the expected path |
| Script not executable | ✅ | Run `chmod +x` |
| Simulator off | ✅ | Run `xcrun simctl boot` |
| uncommitted changes | ⚠️ | Confirm with the user whether to commit |

---

## Workflow selection

| Request | Workflow |
|------|-----------|
| 전체 배포 / 풀 릴리스 / 출시 | [Full release pipeline](#full-release-pipeline) |
| 릴리스 노트 / 업데이트 문구 | [1. Release notes](#1-release-notes-generation) |
| 버전 업데이트 / bump | [2. Version bump](#2-version-bump) |
| 스크린샷 / App Preview / 시연 영상 | [3. Screenshots & App Preview](#3-screenshots--app-preview) |
| 메타데이터 / 스토어 정보 | [4. Metadata sync](#4-metadata-sync) |
| TestFlight / 베타 | [5. TestFlight deployment](#5-testflight-deployment) |
| App Store 제출 | [6. App Store deployment](#6-app-store-deployment) |

---

## Full release pipeline

```
Phase 0: 환경 사전 검증 ─── 자동 수복
Step 1: 버전 범프 ─── 사용자 선택
Step 2: 릴리스 노트 생성 ─── 사용자 확인
Step 3: 스크린샷 & App Preview ─── 사용자 확인
Step 4: 메타데이터 동기화 ─── 자동
Step 5: 커밋 & 태그 & 푸시 ─── 사용자 확인
Step 6: TestFlight / App Store 배포 ─── 사용자 선택
```

---

## 1. Release notes generation

### Execute

```bash
git tag --sort=-creatordate | head -3
git log --merges --oneline <이전태그>..HEAD
git log <이전태그>..HEAD --pretty=format:"%s" | grep -E "^(feat|fix|refactor)"
```

### Writing rules

- User perspective (technical terms → user-facing language)
- Exclude developer-tooling changes

### Apply (detect by project structure)

1. `docs/appstore-metadata.md` exists → replace the English/Korean `### What's New` sections
2. `fastlane/metadata/` exists → update per-locale `release_notes.txt` directly
3. Neither exists → create `fastlane/metadata/en-US/release_notes.txt`

### Verify & repair

```
검증: 파일 교체 후 Read하여 새 버전 번호가 포함되어 있는지 확인
수복: 교체 실패 시 → Grep으로 현재 릴리스 노트 위치를 찾아 재시도
```

---

## 2. Version bump

### Execute

```bash
grep 'MARKETING_VERSION' "${XCODEPROJ}/project.pbxproj" | sort -u
```

Change MARKETING_VERSION with Edit replace_all.

### Verify & repair

```
검증: 변경 후 grep으로 새 버전이 적용되었는지 확인
수복: replace_all 실패 시 → 현재 버전 문자열을 정확히 확인하여 재시도
```

---

## 3. Screenshots & App Preview

### 3-1. Screenshots

**Attempt order (auto-fallback):**

```
1차: fastlane ios screenshots (또는 프로젝트의 screenshot lane)
  → 성공? → 완료
  → 실패? → 에러 로그 분석
    → 시뮬레이터 부팅 실패 → xcrun simctl boot <UDID> → 재시도
    → 빌드 실패 → xcodebuild 에러 확인 → 수정 후 재시도
    → 그래도 실패?

2차: Scripts/ 디렉토리에 캡처 스크립트가 있으면 실행
  → 스크립트 실행 권한 없음 → chmod +x → 재시도
  → 그래도 실패?

3차: 사용자에게 터미널 실행 안내
  "! fastlane ios screenshots" 제시
```

### 3-2. App Preview demo video

**Limitation**: simctl recordVideo cannot stay alive in the background inside the Claude Code sandbox.

```
1차: Scripts/에 녹화 스크립트가 있으면 Bash 도구로 시도
  → 실패 (샌드박스 제한)?

2차: 사용자에게 터미널 실행 안내
  "! bash Scripts/record_app_preview.sh" 제시
```

### baepsae UI automation notes (when using the baepsae MCP)

```
- tap_tab: Liquid Glass 탭바는 tabCount 명시 필수
- 시뮬레이터 UDID: xcrun simctl list devices available로 동적 탐지
```

---

## 4. Metadata sync

### Execute (by project structure)

```bash
# prepare_app_store_assets.py가 있으면 실행
test -f Scripts/prepare_app_store_assets.py && python3 Scripts/prepare_app_store_assets.py

# 없으면 fastlane deliver로 메타데이터만 동기화
# fastlane deliver --skip_binary_upload --skip_screenshots
```

### Verify & repair

```
검증: fastlane/metadata/ 디렉토리에 릴리스 노트가 반영되었는지 확인
수복:
  - 스크립트 실행 실패 → Python 버전 확인 → 경로 수정
  - fastlane/metadata 디렉토리 없음 → mkdir -p 후 재실행
```

---

## 5. TestFlight deployment

### Execute

```bash
fastlane ios beta
```

This takes a while, so try `run_in_background: true`. On failure, point the user to `! fastlane ios beta`.

### Verify & repair

```
검증: fastlane 출력에서 "Successfully uploaded" 확인
수복:
  - 코드 서명 실패 → Xcode Automatic Signing 확인 안내
  - 빌드 실패 → xcodebuild -configuration Release build 에러 확인 → 수정
  - 업로드 실패 → API Key 확인 + 네트워크 확인
  - 버전 충돌 → CURRENT_PROJECT_VERSION +1 후 재시도
```

---

## 6. App Store deployment

```bash
# 바이너리만
fastlane ios release

# 메타데이터/스크린샷만
fastlane ios store_assets

# 풀 배포
fastlane ios release_full
```

**Run only after explicit user confirmation** — this submits to the App Store and is externally visible.

---

## Metadata SOT

`docs/appstore-metadata.md` (if present) → `fastlane/metadata/` one-way sync. **Never edit `fastlane/metadata/` directly** — it is a generated target and direct edits will be overwritten by the next sync.

---

## Error auto-diagnosis matrix

| Error message / situation | Cause | Auto-repair |
|-----------------|------|----------|
| `Unable to find a device matching` | Simulator name mismatch | `xcrun simctl list devices` → auto-select an available device |
| `No signing certificate` | Code signing not configured | Point to Xcode Automatic Signing |
| `App Store Connect API key not found` | Wrong API Key path | Search the common paths in sequence |
| `The bundle version must be higher` | Build number conflict | Auto-bump CURRENT_PROJECT_VERSION +1 |
| `Tab bar has no children` | Liquid Glass tab bar | Auto-add `tabCount` |
| `No accessibility element matched` | App screen changed | `analyze_ui` → analyze the current UI → re-detect coordinates/label |
| `Recording completed` + empty file | Sandbox limitation | Point to running `! bash Scripts/...` in the terminal |
| `error: Provisioning profile` | Provisioning expired | Point to re-enabling Xcode Automatically manage signing |
| `ImportError` / Python error | Python dependency | `python3 -m pip install` or verify the path |
| Script `Permission denied` | Not executable | Run `chmod +x` |
