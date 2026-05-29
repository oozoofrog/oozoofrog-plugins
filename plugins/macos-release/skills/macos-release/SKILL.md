---
name: macos-release
description: Automates the macOS app release pipeline — Xcode version bump, Release build, DMG packaging, local install, GitHub Release, Homebrew Cask publishing, and GitHub Actions CI/CD. Use for macOS app distribution requests. 트리거: "릴리스", "release", "버전 업데이트", "version bump", "배포", "deploy", "홈브루 업데이트", "brew cask", "DMG 만들기", "새 버전 배포", "publish", "CI/CD", "workflow", "자동 배포", "GitHub Actions", "새 버전 배포해주세요", "릴리스 스크립트 만들어주세요", "홈브루에 올려주세요", "배포 자동화 워크플로우 만들어주세요".
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

Manages the full release lifecycle of a macOS app.

Respond to the user in Korean.

## Pipeline Overview

A release has 7 stages. Each stage depends on the success of the previous one:

```
버전 범프 → 빌드 → DMG → 로컬 설치 → Git Push → GitHub Release → Homebrew Cask
```

Pipeline design principle: **run destructive actions (git push, GitHub release) only after the build and local install succeed.** Once local install succeeds the user can verify the app directly, and if there is a problem nothing is public yet, so aborting is easy.

## Pre-flight Checks

### Required tools
1. `gh` CLI installed and authenticated (`gh auth status`)
2. `xcodebuild` available
3. Clean git working directory (no uncommitted changes)
4. Homebrew tap repository present locally

### Project detection

Check the project for:

| Item | Where to look | If missing |
|------|----------|--------|
| Release script | `scripts/release.sh` | Suggest creating one |
| Xcode project | `*.xcodeproj`, `*.xcworkspace` | Specify the path manually |
| Homebrew tap | `../homebrew-tap` or `../homebrew-*` | Guide creating one |
| Current version | `MARKETING_VERSION` in pbxproj | Confirm with the user |

## Using an Existing Release Script

If `scripts/release.sh` exists:

1. **Run a dry-run first**: `./scripts/release.sh --dry-run [version]`. The dry-run previews every step before anything destructive runs.
2. Show the execution plan to the user.
3. After confirmation, run: `./scripts/release.sh [version]`

Common options:
- No argument: auto-increment the minor version (1.2 → 1.3)
- Version argument: a specific version (`./scripts/release.sh 2.0`)
- `--skip-brew`: skip the Homebrew update
- `--dry-run`: preview all steps

## Creating a Release Script

If no script exists, create `scripts/release.sh`. See `references/release-script-guide.md` for the detailed guide.

Key design decisions:

### Version bump strategy
Read and update `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in the pbxproj. Change them on disk before building so the built app carries the correct version. Commit after the build succeeds, which makes rollback easy if the build fails.

### Local install (quit app → overwrite → relaunch)
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
- **Cask**: GUI apps (.app) — distributed as DMG/ZIP
- **Formula**: CLI tools — built from source or downloaded as a binary

macOS menu bar apps, status bar apps, and any app with a GUI → **use a Cask**.

### Homebrew tap management
- Personal unified tap: `homebrew-tap` (recommended for multiple projects)
- Per-project tap: `homebrew-{project}` (for a single project)

Prefer the unified tap pattern (`brew install --cask user/tap/app`), since it lets you manage multiple projects from one repo.

### Auto-generating release notes
```bash
git log --pretty=format:"- %s" "v${PREV_VERSION}..HEAD" | grep -v "Bump version"
```

## Homebrew-only Work

When updating only the cask:

### Create a new tap
```bash
gh repo create username/homebrew-tap --public
git clone git@github.com:username/homebrew-tap.git
mkdir -p homebrew-tap/Casks
```

### Cask file template
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

### Resolving push conflicts
Another project may have updated the same tap:
```bash
cd "$HOMEBREW_TAP" && git pull --rebase origin main && git push origin main
```

## GitHub Actions Automated Deployment

You can automate deployment with GitHub Actions instead of (or alongside) the local script. See `references/github-workflow-guide.md` for the detailed guide.

### Workflow layout

```
.github/workflows/
├── release.yml              ← 빌드 + DMG + GitHub Release
└── update-homebrew.yml      ← Release 이벤트 시 Cask 자동 업데이트
```

### Core flow

```
태그 push (v1.5) → release.yml (빌드+DMG+Release) → update-homebrew.yml (Cask 업데이트)
```

When `release.yml` creates a GitHub Release, a `release.published` event fires and `update-homebrew.yml` is triggered automatically to update the Homebrew Cask.

### Prerequisites

1. **Create a PAT**: GitHub Settings → Fine-grained token → Contents permission on the homebrew-tap repo
2. **Register the secret**: FrogTray repo Settings → Secrets → `HOMEBREW_TAP_TOKEN`

### update-homebrew.yml core

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

### Local vs CI guide

| Situation | Recommended |
|------|------|
| Fast iterative development | Local `scripts/release.sh` |
| Team project / reproducible builds | GitHub Actions |
| Code signing required | Local (easier keychain access) |
| Automate Homebrew only | Use `update-homebrew.yml` standalone |

The **side-by-side** pattern is the most flexible: build and release locally, auto-update Homebrew in CI.

## Release Artifact Verification

After DMG creation (Step 3) and before local install (Step 4), verify artifact integrity.

1. **Verify the built app version**:
   - Read `CFBundleShortVersionString` from `.app/Contents/Info.plist`
   - If it does not match the expected version → abort the pipeline and report the cause
2. **Verify the DMG file**:
   - Check the file size (fail if 0 bytes or abnormally small)
   - Compute the SHA256 hash → include it in the GitHub Release body
3. **Verify code signing** (for signed apps):
   - Run `codesign --verify --deep --strict`
   - On failure → abort the pipeline

## User Re-verification Checkpoint (Step 4 → Step 5 gate)

After local install (Step 4) succeeds and before the external publish (Step 5: Git Push), insert a **user confirmation gate**. This checkpoint is the last safety guard before hard-to-undo remote operations.

1. Confirm the locally installed app is running
2. Confirm with the user via AskUserQuestion:
   ```
   로컬 설치가 완료되었습니다.
   - 앱 버전: {version}
   - 설치 경로: {path}
   - DMG: {dmg_path} (SHA256: {hash_prefix}...)

   앱이 정상 동작하는지 직접 확인해주세요.
   다음 단계(Git Push + GitHub Release + Homebrew)를 진행할까요?
   ```
3. User approves → proceed to Step 5 (Git Push)
4. User declines → abort the pipeline, ask for a description of the problem

## Failure Recovery and Per-step Restart

### Pipeline state tracking

Record each step's success/failure in `.claude/release/pipeline-state.json`:

```json
{
  "version": "1.5",
  "startedAt": "2026-03-28T10:00:00Z",
  "steps": [
    {"step": 1, "name": "version-bump", "status": "completed"},
    {"step": 2, "name": "build", "status": "completed"},
    {"step": 3, "name": "dmg", "status": "failed", "error": "hdiutil: Resource busy"},
    {"step": 4, "name": "local-install", "status": "pending"},
    {"step": 5, "name": "git-push", "status": "pending"},
    {"step": 6, "name": "github-release", "status": "pending"},
    {"step": 7, "name": "homebrew", "status": "pending"}
  ]
}
```

### Restart logic

1. On pipeline run, check whether `pipeline-state.json` exists
2. If it exists, prompt via AskUserQuestion:
   ```
   이전 릴리스 v{version}이 Step {N}({name})에서 실패했습니다.
   오류: {error}

   [1] Step {N}부터 재시작
   [2] 처음부터 다시 시작
   [3] 취소
   ```
3. On restart: re-check only the failed step's prerequisites, then run from that step
4. On full completion: delete `pipeline-state.json`

### Per-step prerequisites

| Restart step | Prerequisite |
|------------|----------|
| Step 1 (version bump) | git clean state |
| Step 2 (build) | Version reflected in pbxproj |
| Step 3 (DMG) | Build artifact (.app) exists |
| Step 4 (local install) | DMG file exists |
| Step 5 (Git Push) | Version commit exists + DMG exists |
| Step 6 (GitHub Release) | Tag pushed + DMG exists |
| Step 7 (Homebrew) | GitHub Release exists |

## Troubleshooting

| Symptom | Cause | Resolution |
|------|------|------|
| Build succeeds but the app does not change | An app from a different build path is running | pkill → clean build → launch from the correct path |
| DMG creation fails | Insufficient disk space / a volume with the same name is mounted | Check space, `hdiutil detach` |
| Homebrew tap push rejected | New commits on the remote | `git pull --rebase origin main` |
| `gh release create` fails | The same tag already exists | `gh release delete vX.Y` or use a different version |
| Version does not change in pbxproj | sed pattern mismatch | Check the `MARKETING_VERSION = ` format (mind the whitespace) |

## References

Detailed guides live in this skill's `references/` directory. Read them with the Read tool only when needed.

- `references/release-checklist.md`: full release checklist, pre-flight checks, dry-run-first principle
- `references/release-script-guide.md`: `scripts/release.sh` design, dry-run/skip-brew/version-bump/DMG/Cask patterns
- `references/github-workflow-guide.md`: GitHub Actions release + Homebrew auto-update workflows
- `references/homebrew-publishing.md`: Homebrew Cask/Formula choice, shared tap rules, push/rebase patterns
- `references/local-install-and-dmg.md`: DMG/ZIP local install verification, app quit/overwrite/relaunch procedure
- `references/troubleshooting.md`: common failure symptoms during release and recovery directions
