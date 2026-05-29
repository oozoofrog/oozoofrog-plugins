# macOS release checklist

## 1. Fix the release scope
First, lock in which of the following this is.
- Full release
- dry-run / pre-check
- Homebrew only
- workflow/CI only
- Version update only
- Packaging only

If the user wants only a specific step, do not force the full pipeline.

## 2. Pre-start checks
### Required tools
- `gh` CLI installed and authenticated: `gh auth status`
- Whether Xcode/Swift build is possible (`xcodebuild`, `swift`, required toolchain)
- Whether the Git working tree state is safe (`git status --short`)
- Whether the Homebrew tap can be cloned locally or pushed to remote

### Project detection
Search targets first:
- `scripts/release.sh`
- `fastlane/Fastfile`
- `.github/workflows/`
- `*.xcodeproj`, `*.xcworkspace`
- `Formula/*.rb`, `Casks/*.rb`, `homebrew-*`
- Version/build number source files (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`, plist, etc.)

Detection table:

| Item | Usual location | If missing |
|------|----------------|------------|
| release script | `scripts/release.sh` | Re-check whether an existing flow exists rather than creating a new script |
| Xcode project/workspace | `*.xcodeproj`, `*.xcworkspace` | Specify the path manually or classify as a SwiftPM/CLI structure |
| Homebrew tap | `../homebrew-tap`, `../homebrew-*` | Decide whether to create a new tap last |
| Current version | pbxproj / plist / manifest | First confirm the single source of truth in use |

## 3. Existing-structure-first principle
- If `scripts/release.sh` exists, **always try dry-run first**.
- Example: `./scripts/release.sh --dry-run [version]`
- If an existing tap/workflow exists, preserve its structure.
- Do not add a parallel structure when a release structure already exists.

## 4. Safe default order
1. Verify/bump version
2. Build
3. Packaging (DMG/ZIP/tarball)
4. Local verification
5. GitHub Release or tag push
6. Apply to Homebrew

Principles:
- If build/packaging fails, abort the publish step
- Do not proceed to external publish without local install or smoke test
- Even when only Homebrew fails, report release and tap problems separately

## 5. App/CLI branching
- GUI macOS app → centered on DMG/ZIP + Cask
- CLI → centered on source tarball / binary / Formula

If the decision is ambiguous, first confirm whether the final artifact is a `.app`.

## 6. Required result-report items
- What scope the release was
- Reused existing scripts/workflows/taps
- List of changed files
- Commands executed
- Generated version/artifacts
- Remaining manual steps
- Recovery commands on failure
