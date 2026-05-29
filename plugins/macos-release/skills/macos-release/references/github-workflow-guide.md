# GitHub Actions Homebrew Auto-Deploy Workflow

A CI/CD pipeline that automatically updates the Homebrew Cask when a GitHub Release is created.

## Overall Structure

```
.github/workflows/
├── release.yml              ← build + DMG + create GitHub Release
└── update-homebrew.yml      ← auto-update Cask on Release event
```

Why split into two workflows: when `release.yml` creates a release, `update-homebrew.yml` is triggered by the `release.published` event. Separation of concerns lets each run and be debugged independently.

## Prerequisites

### 1. Create a Personal Access Token (PAT)

Pushing to the Homebrew tap repo requires access to another repo.

1. GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Click "Generate new token"
3. Settings:
   - Token name: `homebrew-tap-updater`
   - Expiration: 90 days or an appropriate period
   - Repository access: "Only select repositories" → select the homebrew-tap repo
   - Permissions: Contents (Read and write)
4. Copy the token

### 2. Register a Repository Secret

1. FrogTray repo → Settings → Secrets and variables → Actions
2. "New repository secret"
3. Name: `HOMEBREW_TAP_TOKEN`
4. Value: the PAT copied above

## Workflow 1: Release Build (release.yml)

Runs on manual trigger or tag push.

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
            # Extract version from tag (v1.5 → 1.5)
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

## Workflow 2: Homebrew Cask Auto-Update (update-homebrew.yml)

Runs automatically when a GitHub Release is published.

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

          # Get the DMG asset URL
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

          # Clean up indentation (remove leading whitespace added by heredoc)
          sed -i 's/^          //' "$CASK_FILE"

      - name: Commit and push
        run: |
          cd homebrew-tap
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add "Casks/$CASK_NAME.rb"
          git commit -m "Update $APP_NAME cask to ${{ steps.release.outputs.version }}"
          git push

## Per-Project Customization Points

Items to check when adapting the script to your project:

| Variable | Description | Example |
|------|------|------|
| `APP_NAME` | App name | `FrogTray` |
| `SCHEME` | Xcode scheme | `FrogTray` |
| `PROJECT_DIR` | Parent directory of xcodeproj | `FrogTray` |
| `TAP_REPO` | Homebrew tap repo | `oozoofrog/homebrew-tap` |
| `CASK_NAME` | Cask filename (lowercase) | `frogtray` |
| `HOMEBREW_TAP_TOKEN` | Secret name | Changeable |

## Local Script vs GitHub Actions Comparison

| Aspect | Local Script | GitHub Actions |
|------|-------------|----------------|
| Build environment | Developer's Mac | GitHub macOS runner |
| Code signing | Local keychain | Separate setup required |
| Speed | Fast (local) | Wait for runner allocation |
| Automation | Manual run | Automatic on tag push |
| Local install | Immediate | Separate download required |
| Reproducibility | Environment-dependent | Consistent environment |

**Recommendation**: Run the local script and GitHub Actions in parallel.
- Fast iterative development: local `scripts/release.sh`
- CI/CD automation: GitHub Actions (especially Homebrew updates)

## Advanced: Full Pipeline via GitHub Actions

A pattern where you push only the tag locally and let CI handle everything else:

```bash
# Locally
git tag -a v1.5 -m "Release v1.5"
git push origin v1.5
# → GitHub Actions handles build → DMG → Release → Homebrew automatically
```

With this pattern, `release.yml` either calls `update-homebrew.yml` directly,
or they are automatically chained via release events.
```
