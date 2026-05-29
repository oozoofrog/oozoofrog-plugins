# Homebrew publishing guide

## 1. Cask vs Formula
Default decision criteria:
- GUI macOS app (`.app`) → usually `Cask`
- CLI tool → usually `Formula`

Supplementary criteria:
- Menu bar apps, status bar apps, and general GUI apps favor Cask
- CLI distribution of the form `brew install user/tap/tool` favors Formula
- When unclear, check the final artifact (`.app` vs CLI binary) and the user's install expectation (`--cask` vs plain `brew install`)

## 2. Shared tap principles
In a shared tap (`homebrew-tap`), follow these rules.
- Modify **only the single file** for the target project's formula/cask.
- Do not touch other `Formula/` or `Casks/` entries.
- If the tap repo is dirty with unrelated changes, clean it up first or stop the work.
- Before pushing, always verify the current work is confined to that single target file.

## 3. Formula pattern
Typically verify the following.
- source tarball URL or release binary URL
- recompute `sha256`
- build dependencies such as `depends_on "go" => :build`
- `brew audit --strict --formula`
- `brew install --build-from-source`
- `brew test`

For CLIs, a source-build Formula is often more favorable for maintenance and shared tap operation.

## 4. Cask pattern
Typically verify the following.
- DMG/ZIP URL
- artifact `sha256`
- `app` path
- `depends_on macos:` if needed
- `zap` path
- minimal check that the app launches correctly after install

Example skeleton:
```ruby
cask "appname" do
  version "X.Y.Z"
  sha256 "..."

  url "https://github.com/USER/REPO/releases/download/v#{version}/App-#{version}.dmg"
  name "AppName"
  desc "App description"
  homepage "https://github.com/USER/REPO"

  app "AppName.app"
end
```

## 5. Shared tap push conflicts
Another project may have updated the same tap, so the following is usually needed.

```bash
git pull --rebase origin main
git push origin main
```

If there are unrelated local changes, it is safer to stop before rebase/push.

## 6. Report items
- which tap repo was used
- which formula/cask file was modified
- changed values for URL/sha256/version
- audit/install/test results
- whether a push or rebase conflict occurred
