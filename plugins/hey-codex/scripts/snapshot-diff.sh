#!/bin/bash
# hey-codex snapshot diff for non-git directories
# NOTE: macOS only — uses `stat -f` (BSD stat). Not compatible with GNU/Linux `stat -c`.
# Usage:
#   snapshot-diff.sh pre [directory]   — take pre-execution snapshot
#   snapshot-diff.sh post [directory]  — take post-execution snapshot and diff
# stdout: diff output showing added/removed/modified files

DIR="${2:-.}"
PRE_SNAP="/tmp/codex-snapshot-pre.txt"
POST_SNAP="/tmp/codex-snapshot-post.txt"

take_snapshot() {
    find "$DIR" -type f -not -path '*/\.*' -exec stat -f '%m %N' {} \; 2>/dev/null | sort
}

case "$1" in
    pre)
        take_snapshot > "$PRE_SNAP"
        echo "스냅샷 저장: $(wc -l < "$PRE_SNAP" | tr -d ' ')개 파일"
        ;;
    post)
        take_snapshot > "$POST_SNAP"
        if [ ! -f "$PRE_SNAP" ]; then
            echo "ERROR: pre 스냅샷이 없습니다. 먼저 'snapshot-diff.sh pre'를 실행하세요."
            exit 1
        fi
        # Extract just filenames for add/delete detection
        PRE_FILES=$(awk '{print $2}' "$PRE_SNAP" | sort)
        POST_FILES=$(awk '{print $2}' "$POST_SNAP" | sort)

        ADDED=$(comm -13 <(echo "$PRE_FILES") <(echo "$POST_FILES"))
        DELETED=$(comm -23 <(echo "$PRE_FILES") <(echo "$POST_FILES"))
        # Modified: same file, different mtime
        MODIFIED=$(comm -12 <(echo "$PRE_FILES") <(echo "$POST_FILES") | while read f; do
            pre_mtime=$(grep " ${f}$" "$PRE_SNAP" | awk '{print $1}')
            post_mtime=$(grep " ${f}$" "$POST_SNAP" | awk '{print $1}')
            if [ "$pre_mtime" != "$post_mtime" ]; then
                echo "$f"
            fi
        done)

        [ -n "$ADDED" ] && echo "추가된 파일:" && echo "$ADDED" | sed 's/^/  + /'
        [ -n "$DELETED" ] && echo "삭제된 파일:" && echo "$DELETED" | sed 's/^/  - /'
        [ -n "$MODIFIED" ] && echo "수정된 파일:" && echo "$MODIFIED" | sed 's/^/  ~ /'
        [ -z "$ADDED" ] && [ -z "$DELETED" ] && [ -z "$MODIFIED" ] && echo "변경 없음"

        # Cleanup
        rm -f "$PRE_SNAP" "$POST_SNAP"
        ;;
    *)
        echo "Usage: snapshot-diff.sh [pre|post] [directory]"
        exit 1
        ;;
esac
