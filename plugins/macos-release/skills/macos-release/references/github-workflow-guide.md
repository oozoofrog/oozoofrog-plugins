# GitHub Actions Homebrew 자동 배포 워크플로우

GitHub Release가 생성되면 자동으로 Homebrew Cask를 업데이트하는 CI/CD 파이프라인입니다.

## 전체 구조

```
.github/workflows/
├── release.yml              ← 빌드 + DMG + GitHub Release 생성
└── update-homebrew.yml      ← Release 이벤트 시 Cask 자동 업데이트
```

두 워크플로우를 분리하는 이유: `release.yml`이 릴리스를 생성하면 `update-homebrew.yml`이 `release.published` 이벤트로 트리거됩니다. 관심사 분리로 각각 독립적으로 실행/디버깅할 수 있습니다.

## 사전 설정

### 1. Personal Access Token (PAT) 생성

Homebrew tap 리포에 push하려면 다른 리포 접근 권한이 필요합니다.

1. GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. "Generate new token" 클릭
3. 설정:
   - Token name: `homebrew-tap-updater`
   - Expiration: 90일 또는 적절한 기간
   - Repository access: "Only select repositories" → homebrew-tap 리포 선택
   - Permissions: Contents (Read and write)
4. 토큰 복사

### 2. Repository Secret 등록

1. FrogTray 리포 → Settings → Secrets and variables → Actions
2. "New repository secret"
3. Name: `HOMEBREW_TAP_TOKEN`
4. Value: 위에서 복사한 PAT

## 워크플로우 1: 릴리스 빌드 (release.yml)

수동 트리거 또는 태그 push 시 실행됩니다.

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: '릴리스 버전 (예: 1.5)'
        required: true
        type: string
  push:
    tags:
      - 'v*'

env:
  APP_NAME: FrogTray
  SCHEME: FrogTray
  PROJECT_DIR: FrogTray

jobs:
  build-and-release:
    runs-on: macos-latest
    permissions:
      contents: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Determine version
        id: version
        run: |
          if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
            echo "version=${{ inputs.version }}" >> "$GITHUB_OUTPUT"
          else
            # 태그에서 버전 추출 (v1.5 → 1.5)
            echo "version=${GITHUB_REF_NAME#v}" >> "$GITHUB_OUTPUT"
          fi

      - name: Build Release
        run: |
          xcodebuild \
            -project "$PROJECT_DIR/$APP_NAME.xcodeproj" \
            -scheme "$SCHEME" \
            -configuration Release \
            -derivedDataPath .build/xcode \
            -destination 'platform=macOS' \
            clean build

      - name: Create DMG
        id: dmg
        run: |
          VERSION="${{ steps.version.outputs.version }}"
          BUILT_APP=".build/xcode/Build/Products/Release/$APP_NAME.app"
          DMG_PATH="$APP_NAME-$VERSION.dmg"
          STAGING=".build/dmg-staging"

          mkdir -p "$STAGING"
          cp -R "$BUILT_APP" "$STAGING/"
          ln -s /Applications "$STAGING/Applications"

          TEMP_DMG=".build/temp.dmg"
          hdiutil create -srcfolder "$STAGING" -volname "$APP_NAME" \
            -fs HFS+ -format UDRW -size 50m "$TEMP_DMG" -quiet

          hdiutil convert "$TEMP_DMG" -format UDZO \
            -imagekey zlib-level=9 -o "$DMG_PATH" -quiet

          SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')

          echo "path=$DMG_PATH" >> "$GITHUB_OUTPUT"
          echo "sha256=$SHA256" >> "$GITHUB_OUTPUT"

      - name: Create GitHub Release
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          VERSION="${{ steps.version.outputs.version }}"
          DMG="${{ steps.dmg.outputs.path }}"

          NOTES=$(git log --pretty=format:"- %s" \
            "$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo HEAD~5)..HEAD" \
            | grep -v "Bump version" || echo "- 업데이트")

          gh release create "v$VERSION" "$DMG" \
            --title "$APP_NAME v$VERSION" \
            --notes "$NOTES"
```

## 워크플로우 2: Homebrew Cask 자동 업데이트 (update-homebrew.yml)

GitHub Release가 publish되면 자동으로 실행됩니다.

```yaml
name: Update Homebrew Cask

on:
  release:
    types: [published]

env:
  TAP_REPO: oozoofrog/homebrew-tap
  CASK_NAME: frogtray
  APP_NAME: FrogTray

jobs:
  update-cask:
    runs-on: ubuntu-latest

    steps:
      - name: Extract release info
        id: release
        run: |
          VERSION="${GITHUB_REF_NAME#v}"
          echo "version=$VERSION" >> "$GITHUB_OUTPUT"

          # DMG 에셋 URL 가져오기
          DMG_URL=$(gh api "repos/${{ github.repository }}/releases/tags/$GITHUB_REF_NAME" \
            --jq '.assets[] | select(.name | endswith(".dmg")) | .browser_download_url')
          echo "dmg_url=$DMG_URL" >> "$GITHUB_OUTPUT"
        env:
          GH_TOKEN: ${{ github.token }}

      - name: Download DMG and calculate SHA256
        id: sha
        run: |
          curl -sL "${{ steps.release.outputs.dmg_url }}" -o app.dmg
          SHA256=$(shasum -a 256 app.dmg | awk '{print $1}')
          echo "sha256=$SHA256" >> "$GITHUB_OUTPUT"

      - name: Checkout Homebrew tap
        uses: actions/checkout@v4
        with:
          repository: ${{ env.TAP_REPO }}
          token: ${{ secrets.HOMEBREW_TAP_TOKEN }}
          path: homebrew-tap

      - name: Update Cask
        run: |
          VERSION="${{ steps.release.outputs.version }}"
          SHA256="${{ steps.sha.outputs.sha256 }}"
          CASK_FILE="homebrew-tap/Casks/$CASK_NAME.rb"

          mkdir -p homebrew-tap/Casks

          cat > "$CASK_FILE" <<CASK
          cask "$CASK_NAME" do
            version "$VERSION"
            sha256 "$SHA256"

            url "https://github.com/${{ github.repository }}/releases/download/v#{version}/$APP_NAME-#{version}.dmg"
            name "$APP_NAME"
            desc "macOS menu bar system monitor"
            homepage "https://github.com/${{ github.repository }}"

            depends_on macos: ">= :ventura"

            app "$APP_NAME.app"

            zap trash: [
              "~/Library/Preferences/com.oozoofrog.macos.$APP_NAME.plist",
            ]
          end
          CASK

          # 들여쓰기 정리 (heredoc이 추가한 앞쪽 공백 제거)
          sed -i 's/^          //' "$CASK_FILE"

      - name: Commit and push
        run: |
          cd homebrew-tap
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add "Casks/$CASK_NAME.rb"
          git commit -m "Update $APP_NAME cask to ${{ steps.release.outputs.version }}"
          git push

## 프로젝트별 커스터마이징 포인트

스크립트를 프로젝트에 맞게 수정할 때 확인할 항목:

| 변수 | 설명 | 예시 |
|------|------|------|
| `APP_NAME` | 앱 이름 | `FrogTray` |
| `SCHEME` | Xcode 스키마 | `FrogTray` |
| `PROJECT_DIR` | xcodeproj 상위 디렉토리 | `FrogTray` |
| `TAP_REPO` | Homebrew tap 리포 | `oozoofrog/homebrew-tap` |
| `CASK_NAME` | Cask 파일명 (소문자) | `frogtray` |
| `HOMEBREW_TAP_TOKEN` | Secret 이름 | 변경 가능 |

## 로컬 스크립트 vs GitHub Actions 비교

| 관점 | 로컬 스크립트 | GitHub Actions |
|------|-------------|----------------|
| 빌드 환경 | 개발자 Mac | GitHub macOS runner |
| 코드사이닝 | 로컬 키체인 | 별도 설정 필요 |
| 속도 | 빠름 (로컬) | runner 할당 대기 |
| 자동화 | 수동 실행 | 태그 push 시 자동 |
| 로컬 설치 | 즉시 | 별도 다운로드 필요 |
| 재현성 | 환경 의존 | 일관된 환경 |

**권장**: 로컬 스크립트와 GitHub Actions를 병행 운영합니다.
- 빠른 반복 개발: 로컬 `scripts/release.sh`
- CI/CD 자동화: GitHub Actions (특히 Homebrew 업데이트)

## 고급: 전체 파이프라인을 GitHub Actions로

로컬에서는 태그만 push하고, 나머지를 모두 CI에서 처리하는 패턴:

```bash
# 로컬에서
git tag -a v1.5 -m "Release v1.5"
git push origin v1.5
# → GitHub Actions가 빌드 → DMG → Release → Homebrew 자동 처리
```

이 패턴이면 `release.yml`에서 `update-homebrew.yml`을 직접 호출하거나,
릴리스 이벤트 체인으로 자동 연결됩니다.
```
