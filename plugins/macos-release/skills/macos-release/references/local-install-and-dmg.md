# Local install and DMG verification

For GUI macOS app releases, it is safer to build the DMG/ZIP and then run a **local install verification** first.

## Goals
- Catch cases where the build succeeded but the actual installed result is broken, before publish
- Confirm that the correct app bundle was overwritten
- Block wrong build paths or stale-app launch problems early

## Basic sequence
1. Quit the running app
2. Mount the DMG or extract the ZIP
3. Remove/overwrite the existing installed app
4. Launch the new app
5. Confirm a minimal smoke test
6. Proceed to the publish step

## App quit procedure
The following order is usually safe.
- Attempt a graceful quit with `pkill -x "$APP_NAME"`
- Wait a few seconds, then retry if it is still alive
- If it really remains, force-kill as a last resort

Example:
```bash
pkill -x "$APP_NAME" || true
sleep 1
for i in {1..5}; do pgrep -x "$APP_NAME" || break; sleep 1; done
pgrep -x "$APP_NAME" && pkill -9 -x "$APP_NAME"
```

## DMG install example
```bash
DMG_MOUNT=$(hdiutil attach "$DMG" -nobrowse -noverify -noautoopen | grep "/Volumes/" | awk '{print $NF}')
rm -rf "$INSTALLED_APP"
ditto "$DMG_MOUNT/$APP.app" "$INSTALLED_APP"
hdiutil detach "$DMG_MOUNT" -quiet
open "$INSTALLED_APP"
```

Notes:
- Check that the same volume name is not already mounted
- Preserve the bundle structure with `ditto` or an equivalent copy method
- Do not confuse the install target path with the build artifact path

## ZIP-based verification
- Extract into a temporary directory
- Confirm the `.app` bundle exists
- Copy to the existing install location
- Confirm basic functionality after launch

## Difference from CLI distribution
For a CLI, the following usually matter more than DMG local install.
- Confirm the binary runs
- Confirm `--help` / version output
- Confirm Homebrew Formula install/test

## Minimal verification example
- Whether the app launches
- Whether the menu bar / main window is displayed
- Whether it initializes without crashing
- Whether the version label is the expected value
