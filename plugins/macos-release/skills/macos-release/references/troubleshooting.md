# Release troubleshooting

## Common symptoms

| Symptom | Common cause | Check/fix first |
|---------|--------------|-----------------|
| Build succeeds but app does not change | App from a different build path, or an existing installed app still running | Quit the app → clean build → re-confirm the actual install path |
| DMG creation fails | Insufficient disk space, same volume name already mounted, permission issue | Check space, detach the existing mount, re-confirm the output path |
| App will not launch after local install | Wrong bundle copy, failed overwrite of an old app, signing issue | Check mount path/copy path, remove the existing app then reinstall |
| Homebrew tap push rejected | New commits exist on remote | Retry after `git pull --rebase origin main` |
| `gh release create` fails | Same tag/release already exists | Delete the existing release or use a new version/tag |
| Version not changed in pbxproj | `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` update pattern mismatch | Verify the actual file format, then re-fix the source of truth |
| Formula/Cask verification fails | Errors in URL, sha256, install path, app path, or zap path | Confirm only one target file was edited, then re-run audit/install/test |
| Homebrew update fails in workflow | Missing secret, insufficient token permissions, tap repo conflict | Check secret name/permissions, recover with a manual script |

## What to include when reporting a problem
- Which stage failed
- The last stage that succeeded
- The commands that were run
- Relevant logs or error messages
- The next command to recover manually instead of via automation

## Recovery principles
- On build/package failure, do not proceed to the publish stage
- If only Homebrew failed, separate the release and the tap update when cleaning up
- If an external publish has already happened, sort out the follow-up fix/redeploy path first instead of rolling back
