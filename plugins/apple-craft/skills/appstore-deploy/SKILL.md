---
name: appstore-deploy
description: "App Store 릴리스 자동화 — 전체 파이프라인을 한 번에 실행하거나 단계별로 제어합니다. 배포 중 오류를 자동 감지·수복하고, 스크립트/환경 문제를 자가 진단합니다. '배포', 'deploy', 'TestFlight', '앱스토어', 'App Store', '스크린샷', 'screenshots', '메타데이터', 'metadata', '베타', '출시', 'App Preview', '시연 영상' 요청 시 사용하세요. 전체 릴리스 파이프라인은 /release 스킬을 사용하세요. 이 스킬은 개별 배포 단계(스크린샷, 메타데이터, TestFlight, App Store)를 직접 실행할 때 사용합니다."
---

# App Store 릴리스 자동화

Apple 앱의 App Store 배포 파이프라인을 관리합니다.
배포 중 발생하는 오류를 자동 감지하고, 가능한 범위에서 자가 수복합니다.

## 핵심 원칙: 자가 수복 (Self-Healing)

이 스킬의 모든 단계는 **실행 → 검증 → 수복** 루프를 따릅니다:

```
실행 (Execute)
  → 성공? → 다음 단계
  → 실패? → 오류 분석 (Diagnose)
    → 자동 수복 가능? → 수복 (Repair) → 재실행
    → 수복 불가? → 사용자에게 수동 실행 안내 (! 명령 제시)
```

---

## Phase 0: 환경 사전 검증 (Pre-flight Check)

**모든 배포 워크플로우 시작 전에 반드시 실행합니다.**

### 프로젝트 자동 탐지

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

### 환경 검증

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

### 자동 수복 매트릭스

| 문제 | 자동 수복 | 방법 |
|------|----------|------|
| fastlane 미설치 | ✅ | `gem install fastlane` 실행 |
| API Key 없음 | ❌ | 사용자에게 경로 안내 |
| 스크립트 실행 권한 없음 | ✅ | `chmod +x` 실행 |
| 시뮬레이터 꺼짐 | ✅ | `xcrun simctl boot` 실행 |
| uncommitted changes | ⚠️ | 사용자에게 커밋 여부 확인 |

---

## 워크플로우 선택

| 요청 | 워크플로우 |
|------|-----------|
| 전체 배포 / 풀 릴리스 / 출시 | [전체 릴리스 파이프라인](#전체-릴리스-파이프라인) |
| 릴리스 노트 / 업데이트 문구 | [1. 릴리스 노트](#1-릴리스-노트-생성) |
| 버전 업데이트 / bump | [2. 버전 범프](#2-버전-범프) |
| 스크린샷 / App Preview / 시연 영상 | [3. 스크린샷 & App Preview](#3-스크린샷--app-preview) |
| 메타데이터 / 스토어 정보 | [4. 메타데이터 동기화](#4-메타데이터-동기화) |
| TestFlight / 베타 | [5. TestFlight 배포](#5-testflight-배포) |
| App Store 제출 | [6. App Store 배포](#6-app-store-배포) |

---

## 전체 릴리스 파이프라인

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

## 1. 릴리스 노트 생성

### 실행

```bash
git tag --sort=-creatordate | head -3
git log --merges --oneline <이전태그>..HEAD
git log <이전태그>..HEAD --pretty=format:"%s" | grep -E "^(feat|fix|refactor)"
```

### 작성 규칙

- 사용자 관점 (기술 용어 → 사용자 언어)
- 개발자 도구 변경 제외

### 적용 (프로젝트 구조에 따라 탐지)

1. `docs/appstore-metadata.md` 존재 → English/Korean `### What's New` 섹션 교체
2. `fastlane/metadata/` 존재 → 로케일별 `release_notes.txt` 직접 업데이트
3. 위 모두 없으면 → `fastlane/metadata/en-US/release_notes.txt` 생성

### 검증 & 수복

```
검증: 파일 교체 후 Read하여 새 버전 번호가 포함되어 있는지 확인
수복: 교체 실패 시 → Grep으로 현재 릴리스 노트 위치를 찾아 재시도
```

---

## 2. 버전 범프

### 실행

```bash
grep 'MARKETING_VERSION' "${XCODEPROJ}/project.pbxproj" | sort -u
```

Edit replace_all로 MARKETING_VERSION 변경.

### 검증 & 수복

```
검증: 변경 후 grep으로 새 버전이 적용되었는지 확인
수복: replace_all 실패 시 → 현재 버전 문자열을 정확히 확인하여 재시도
```

---

## 3. 스크린샷 & App Preview

### 3-1. 스크린샷

**실행 시도 순서 (자동 폴백):**

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

### 3-2. App Preview 시연 영상

**제한**: simctl recordVideo는 Claude Code 샌드박스에서 백그라운드 유지 불가.

```
1차: Scripts/에 녹화 스크립트가 있으면 Bash 도구로 시도
  → 실패 (샌드박스 제한)?

2차: 사용자에게 터미널 실행 안내
  "! bash Scripts/record_app_preview.sh" 제시
```

### baepsae UI 자동화 주의사항 (baepsae MCP 사용 시)

```
- tap_tab: Liquid Glass 탭바는 tabCount 명시 필수
- 시뮬레이터 UDID: xcrun simctl list devices available로 동적 탐지
```

---

## 4. 메타데이터 동기화

### 실행 (프로젝트 구조에 따라)

```bash
# prepare_app_store_assets.py가 있으면 실행
test -f Scripts/prepare_app_store_assets.py && python3 Scripts/prepare_app_store_assets.py

# 없으면 fastlane deliver로 메타데이터만 동기화
# fastlane deliver --skip_binary_upload --skip_screenshots
```

### 검증 & 수복

```
검증: fastlane/metadata/ 디렉토리에 릴리스 노트가 반영되었는지 확인
수복:
  - 스크립트 실행 실패 → Python 버전 확인 → 경로 수정
  - fastlane/metadata 디렉토리 없음 → mkdir -p 후 재실행
```

---

## 5. TestFlight 배포

### 실행

```bash
fastlane ios beta
```

시간이 걸리므로 `run_in_background: true` 시도.
실패 시 `! fastlane ios beta` 안내.

### 검증 & 수복

```
검증: fastlane 출력에서 "Successfully uploaded" 확인
수복:
  - 코드 서명 실패 → Xcode Automatic Signing 확인 안내
  - 빌드 실패 → xcodebuild -configuration Release build 에러 확인 → 수정
  - 업로드 실패 → API Key 확인 + 네트워크 확인
  - 버전 충돌 → CURRENT_PROJECT_VERSION +1 후 재시도
```

---

## 6. App Store 배포

```bash
# 바이너리만
fastlane ios release

# 메타데이터/스크린샷만
fastlane ios store_assets

# 풀 배포
fastlane ios release_full
```

**반드시 사용자 확인 후 실행.**

---

## 메타데이터 SOT

`docs/appstore-metadata.md` (존재 시) → `fastlane/metadata/` 단방향 동기화.
**절대 fastlane/metadata/ 직접 수정 금지.**

---

## 오류 자동 진단 매트릭스

| 에러 메시지/상황 | 원인 | 자동 수복 |
|-----------------|------|----------|
| `Unable to find a device matching` | 시뮬레이터 이름 불일치 | `xcrun simctl list devices` → 가용 기기 자동 선택 |
| `No signing certificate` | 코드 서명 미설정 | Xcode Automatic Signing 안내 |
| `App Store Connect API key not found` | API Key 경로 오류 | 일반적인 경로들 순차 탐색 |
| `The bundle version must be higher` | 빌드 번호 충돌 | CURRENT_PROJECT_VERSION +1 자동 범프 |
| `Tab bar has no children` | Liquid Glass 탭바 | `tabCount` 자동 추가 |
| `No accessibility element matched` | 앱 화면 변경 | `analyze_ui` → 현재 UI 분석 → 좌표/label 재탐지 |
| `Recording completed` + 빈 파일 | 샌드박스 제한 | `! bash Scripts/...` 터미널 실행 안내 |
| `error: Provisioning profile` | 프로비저닝 만료 | Xcode Automatically manage signing 재활성화 안내 |
| `ImportError` / Python 에러 | Python 의존성 | `python3 -m pip install` 또는 경로 확인 |
| 스크립트 `Permission denied` | 실행 권한 없음 | `chmod +x` 실행 |
