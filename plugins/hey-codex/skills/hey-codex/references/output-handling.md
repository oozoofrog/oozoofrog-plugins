# Output Handling Strategy

## Stripping ANSI Escape Codes

Strip ANSI escape sequences from Codex CLI output:

    codex exec "프롬프트" 2>&1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'

## Display Strategy by Output Size

Measure line count after stripping ANSI.

| Size | Handling |
|------|------|
| < 50 lines | Show raw output as-is |
| 50–200 lines | Summarize key content + confirm "전체 출력을 보시겠습니까?" |
| > 200 lines | Show summary only + save to `/tmp/codex-output-$(date +%s).txt` then report the path |

## Post-processing by Mode

### read mode (one-way)
1. Show Codex stdout
2. Exit

### suggest mode (two-way)
1. Show summary of Codex stdout
2. Confirm with user: "이 제안을 적용할까요?"
3. On approval: Claude Code applies to code via Edit/Write tools
4. On rejection: report "제안을 적용하지 않았습니다" then exit

### write mode — git repository (two-way)
1. Record `git status` before running Codex
2. Run Codex (`--full-auto`)
3. Capture changes with `git diff`
4. Based on number of changed files:
   - 1–5: show change summary
   - 6+: show `git diff --stat` + propose detailed review
5. On problems, offer `git checkout .` rollback option

### write mode — non-git directory (two-way)
1. Pre-run snapshot: `find . -type f -exec stat -f '%m %N' {} \; | sort > /tmp/codex-pre-snapshot.txt`
   (record file path + modification time together to enable change detection)
2. Run Codex
3. Post-run snapshot with the same command: `/tmp/codex-post-snapshot.txt`
4. Report changed/created/deleted/modified files with `diff /tmp/codex-pre-snapshot.txt /tmp/codex-post-snapshot.txt`
5. Note that rollback is not available
