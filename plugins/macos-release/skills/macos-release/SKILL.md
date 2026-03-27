---
name: macos-release
description: macOS 앱 릴리스 파이프라인 자동화 — Xcode 버전 범프, Release 빌드, DMG 패키징, 로컬 설치, GitHub Release, Homebrew Cask 배포, GitHub Actions CI/CD를 관리합니다. "릴리스", "release", "버전 업데이트", "version bump", "배포", "deploy", "홈브루 업데이트", "brew cask", "DMG 만들기", "새 버전 배포", "publish", "CI/CD", "workflow", "자동 배포", "GitHub Actions" 등 macOS 앱 배포 관련 요청이 있을 때 반드시 사용하세요. "새 버전 배포해주세요", "릴리스 스크립트 만들어주세요", "홈브루에 올려주세요", "배포 자동화 워크플로우 만들어주세요" 같은 요청도 포함합니다.
argument-hint: "[release | setup | dry-run | brew-only | ci-setup] [version]"
---

<example>
user: "새 버전 릴리스해주세요"
assistant: "기존 릴리스 스크립트를 감지했습니다. 먼저 dry-run으로 확인하겠습니다."
</example>

<example>
user: "릴리스 파이프라인 만들어주세요"
assistant: "프로젝트 구조를 분석해서 scripts/release.sh를 생성하겠습니다."
</example>

<example>
user: "홈브루 캐스크만 업데이트해주세요"
assistant: "Homebrew tap의 Cask 파일을 현재 릴리스에 맞게 업데이트하겠습니다."
</example>

<example>
user: "배포 자동화 워크플로우 만들어주세요"
assistant: "GitHub Actions 워크플로우 2개(빌드+릴리스, Homebrew 자동 업데이트)를 생성하겠습니다."
</example>

# macOS App Release Pipeline

macOS 앱의 전체 릴리스 수명주기를 관리하는 스킬입니다.

## Pipeline Overview

릴리스는 7단계로 구성됩니다. 각 단계는 이전 단계의 성공에 의존합니다:

```
버전 범프 → 빌드 → DMG → 로컬 설치 → Git Push → GitHub Release → Homebrew Cask
```

파이프라인 설계 원칙: **파괴적 작업(git push, GitHub release)은 빌드와 로컬 설치 성공 후에만 실행**합니다.
로컬 설치까지 성공하면 사용자가 앱을 직접 확인할 수 있고, 문제가 있으면 아직 외부에 공개되기 전이라 중단이 쉽습니다.

## 시작 전 점검

### 필수 도구
1. `gh` CLI 설치 및 인증 (`gh auth status`)
2. `xcodebuild` 사용 가능
3. Git 작업 디렉토리 깨끗 (커밋되지 않은 변경 없음)
4. Homebrew tap 리포지토리가 로컬에 존재

### 프로젝트 탐지

프로젝트에서 다음을 확인합니다:

| 항목 | 찾는 위치 | 없으면 |
|------|----------|--------|
| 릴리스 스크립트 | `scripts/release.sh` | 생성 제안 |
| Xcode 프로젝트 | `*.xcodeproj`, `*.xcworkspace` | 수동 경로 지정 |
| Homebrew tap | `../homebrew-tap` 또는 `../homebrew-*` | 생성 안내 |
| 현재 버전 | `MARKETING_VERSION` in pbxproj | 사용자에게 확인 |

## 기존 릴리스 스크립트 사용

`scripts/release.sh`가 존재하면:

1. **반드시 dry-run 먼저**: `./scripts/release.sh --dry-run [version]`
2. 실행 계획을 사용자에게 보여주기
3. 확인 후 실행: `./scripts/release.sh [version]`

일반적인 옵션:
- 인자 없음: 마이너 버전 자동 증가 (1.2 → 1.3)
- 버전 인자: 특정 버전 (`./scripts/release.sh 2.0`)
- `--skip-brew`: Homebrew 업데이트 건너뛰기
- `--dry-run`: 모든 단계 미리보기

## 릴리스 스크립트 생성

스크립트가 없으면 `scripts/release.sh`를 만듭니다. 상세 가이드는 `references/release-script-guide.md`를 참조하세요.

핵심 설계 결정:

### 버전 범프 전략
pbxproj에서 `MARKETING_VERSION`과 `CURRENT_PROJECT_VERSION`을 읽고 업데이트합니다.
**빌드 전에 디스크에서 먼저 변경**해야 빌드된 앱에 올바른 버전이 들어갑니다.
커밋은 빌드 성공 후에 하면 실패 시 롤백이 쉽습니다.

### 로컬 설치 (앱 종료 → 덮어쓰기 → 재실행)
```bash
# 3단계 escalation: SIGTERM → 5초 대기 → SIGKILL
pkill -x "$APP_NAME" || true
sleep 1
for i in {1..5}; do pgrep -x "$APP_NAME" || break; sleep 1; done
pgrep -x "$APP_NAME" && pkill -9 -x "$APP_NAME"

# DMG 마운트 → 복사 → 언마운트
DMG_MOUNT=$(hdiutil attach "$DMG" -nobrowse -noverify -noautoopen | grep "/Volumes/" | awk '{print $NF}')
rm -rf "$INSTALLED_APP"
ditto "$DMG_MOUNT/$APP.app" "$INSTALLED_APP"
hdiutil detach "$DMG_MOUNT" -quiet
open "$INSTALLED_APP"
```

### Homebrew Cask vs Formula
- **Cask**: GUI 앱 (.app) — DMG/ZIP으로 배포
- **Formula**: CLI 도구 — 소스에서 빌드하거나 바이너리 다운로드

macOS 메뉴바 앱, 상태바 앱, GUI가 있는 모든 앱 → **Cask 사용**

### Homebrew Tap 관리
- 개인 통합 tap: `homebrew-tap` (여러 프로젝트에 권장)
- 프로젝트별 tap: `homebrew-{project}` (단일 프로젝트용)

통합 tap 패턴 (`brew install --cask user/tap/app`)을 권장합니다. 여러 프로젝트를 하나의 리포에서 관리할 수 있어서요.

### 릴리스 노트 자동 생성
```bash
git log --pretty=format:"- %s" "v${PREV_VERSION}..HEAD" | grep -v "Bump version"
```

## Homebrew 전용 작업

캐스크만 업데이트할 때:

### 새 Tap 생성
```bash
gh repo create username/homebrew-tap --public
git clone git@github.com:username/homebrew-tap.git
mkdir -p homebrew-tap/Casks
```

### Cask 파일 템플릿
```ruby
cask "appname" do
  version "X.Y"
  sha256 "..."

  url "https://github.com/USER/REPO/releases/download/v#{version}/App-#{version}.dmg"
  name "AppName"
  desc "App description"
  homepage "https://github.com/USER/REPO"

  depends_on macos: ">= :ventura"

  app "AppName.app"

  zap trash: [
    "~/Library/Preferences/com.user.app.plist",
  ]
end
```

### Push 충돌 해결
다른 프로젝트가 같은 tap을 업데이트했을 수 있습니다:
```bash
cd "$HOMEBREW_TAP" && git pull --rebase origin main && git push origin main
```

## GitHub Actions 자동 배포

로컬 스크립트 대신 (또는 병행하여) GitHub Actions로 배포를 자동화할 수 있습니다.
상세 가이드는 `references/github-workflow-guide.md`를 참조하세요.

### 워크플로우 구성

```
.github/workflows/
├── release.yml              ← 빌드 + DMG + GitHub Release
└── update-homebrew.yml      ← Release 이벤트 시 Cask 자동 업데이트
```

### 핵심 흐름

```
태그 push (v1.5) → release.yml (빌드+DMG+Release) → update-homebrew.yml (Cask 업데이트)
```

`release.yml`이 GitHub Release를 생성하면 `release.published` 이벤트가 발생하고,
`update-homebrew.yml`이 자동으로 트리거되어 Homebrew Cask를 업데이트합니다.

### 사전 설정

1. **PAT 생성**: GitHub Settings → Fine-grained token → homebrew-tap 리포 Contents 권한
2. **Secret 등록**: FrogTray 리포 Settings → Secrets → `HOMEBREW_TAP_TOKEN`

### update-homebrew.yml 핵심

```yaml
on:
  release:
    types: [published]

jobs:
  update-cask:
    runs-on: ubuntu-latest
    steps:
      - name: Download DMG and get SHA256
        run: |
          DMG_URL=$(gh api "repos/$REPO/releases/tags/$TAG" \
            --jq '.assets[] | select(.name | endswith(".dmg")) | .browser_download_url')
          curl -sL "$DMG_URL" -o app.dmg
          SHA256=$(shasum -a 256 app.dmg | awk '{print $1}')

      - name: Update Cask and push
        # Checkout homebrew-tap, update .rb, commit, push
```

### 로컬 vs CI 선택 가이드

| 상황 | 권장 |
|------|------|
| 빠른 반복 개발 | 로컬 `scripts/release.sh` |
| 팀 프로젝트 / 재현 가능한 빌드 | GitHub Actions |
| 코드사이닝 필요 | 로컬 (키체인 접근 용이) |
| Homebrew만 자동화 | `update-homebrew.yml` 단독 사용 |

**병행 운영** 패턴이 가장 유연합니다: 로컬에서 빌드+릴리스, CI에서 Homebrew 자동 업데이트.

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 빌드 성공인데 앱이 안 바뀜 | 다른 빌드 경로의 앱 실행 중 | pkill → clean build → 올바른 경로에서 실행 |
| DMG 생성 실패 | 디스크 공간 부족 / 같은 볼륨명 마운트됨 | 공간 확인, `hdiutil detach` |
| Homebrew tap push 거부 | 리모트에 새 커밋 | `git pull --rebase origin main` |
| `gh release create` 실패 | 같은 태그 이미 존재 | `gh release delete vX.Y` 또는 다른 버전 |
| 버전이 pbxproj에서 안 바뀜 | sed 패턴 불일치 | `MARKETING_VERSION = ` 형식 확인 (공백 주의) |

## References

이 스킬의 `references/` 디렉토리에 상세 가이드가 있습니다. 필요한 경우에만 Read 도구로 읽으세요.

- `references/release-checklist.md`: 전체 릴리스 체크리스트, 사전 점검, dry-run 우선 원칙
- `references/release-script-guide.md`: `scripts/release.sh` 설계, dry-run/skip-brew/버전 범프/DMG/Cask 반영 패턴
- `references/github-workflow-guide.md`: GitHub Actions 릴리스 + Homebrew 자동 업데이트 워크플로우
- `references/homebrew-publishing.md`: Homebrew Cask/Formula 선택, 공용 tap 운영 규칙, push/rebase 패턴
- `references/local-install-and-dmg.md`: DMG/ZIP 로컬 설치 검증, 앱 종료/덮어쓰기/재실행 절차
- `references/troubleshooting.md`: 릴리스 중 자주 만나는 실패 증상과 복구 방향
