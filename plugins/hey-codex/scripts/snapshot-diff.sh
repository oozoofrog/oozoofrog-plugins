#!/bin/bash
set -euo pipefail

# hey-codex snapshot diff for non-git directories
# NOTE: macOS only — uses `stat -f` (BSD stat). Not compatible with GNU/Linux `stat -c`.
# Usage:
#   snapshot-diff.sh pre [directory]   — take pre-execution snapshot
#   snapshot-diff.sh post [directory]  — take post-execution snapshot and diff
# Optional:
#   SNAPSHOT_DIFF_TOKEN=<token>        — 같은 디렉터리에서 동시에 실행할 때 세션 분리
# stdout: diff output showing added/removed/modified files

MODE="${1:-}"
DIR_INPUT="${2:-.}"

if [[ ! -d "$DIR_INPUT" ]]; then
    echo "ERROR: 디렉터리가 없습니다: $DIR_INPUT" >&2
    exit 1
fi

DIR="$(cd "$DIR_INPUT" && pwd)"
SNAPSHOT_ROOT="${TMPDIR:-/tmp}"
SNAPSHOT_TOKEN="${SNAPSHOT_DIFF_TOKEN:-default}"
SNAPSHOT_KEY="$(printf '%s\t%s\n' "$DIR" "$SNAPSHOT_TOKEN" | shasum -a 256 | awk '{print $1}')"
PRE_SNAP="$SNAPSHOT_ROOT/codex-snapshot-${SNAPSHOT_KEY}.pre.tsv"
POST_SNAP="$SNAPSHOT_ROOT/codex-snapshot-${SNAPSHOT_KEY}.post.tsv"

# Script-level cleanup for temp files (bash 3.2 compatible)
_CLEANUP_FILES=()
_cleanup() { rm -f "${_CLEANUP_FILES[@]}"; }
trap _cleanup EXIT

take_snapshot() {
    local find_err snapshot_rows
    find_err="$(mktemp "${SNAPSHOT_ROOT}/codex-snapshot-find-err.XXXXXX")"
    snapshot_rows="$(mktemp "${SNAPSHOT_ROOT}/codex-snapshot-rows.XXXXXX")"
    _CLEANUP_FILES+=("$find_err" "$snapshot_rows")
    while IFS= read -r -d '' path; do
        local mtime
        mtime="$(stat -f '%m' "$path" 2>/dev/null)" || { echo "경고: stat 실패 — $path" >&2; continue; }
        printf '%s\t%s\n' "$mtime" "$path" >> "$snapshot_rows"
    done < <(find "$DIR" -type f -not -path '*/\.*' -print0 2>"$find_err")
    LC_ALL=C sort -t $'\t' -k2,2 "$snapshot_rows"
    if [[ -s "$find_err" ]]; then
        echo "경고: find 실행 중 오류 발생:" >&2
        head -5 "$find_err" >&2
    fi
    rm -f "$find_err" "$snapshot_rows"
}

print_prefixed_lines() {
    local prefix="$1"
    local file="$2"
    while IFS= read -r line; do
        printf '  %s %s\n' "$prefix" "$line"
    done < "$file"
}

report_diff() {
    local pre_files post_files added_file deleted_file modified_file

    pre_files="$(mktemp "$SNAPSHOT_ROOT/codex-snapshot-pre-files.XXXXXX")"
    post_files="$(mktemp "$SNAPSHOT_ROOT/codex-snapshot-post-files.XXXXXX")"
    added_file="$(mktemp "$SNAPSHOT_ROOT/codex-snapshot-added.XXXXXX")"
    deleted_file="$(mktemp "$SNAPSHOT_ROOT/codex-snapshot-deleted.XXXXXX")"
    modified_file="$(mktemp "$SNAPSHOT_ROOT/codex-snapshot-modified.XXXXXX")"
    _CLEANUP_FILES+=("$pre_files" "$post_files" "$added_file" "$deleted_file" "$modified_file")

    cut -f2- "$PRE_SNAP" > "$pre_files"
    cut -f2- "$POST_SNAP" > "$post_files"

    LC_ALL=C comm -13 "$pre_files" "$post_files" > "$added_file"
    LC_ALL=C comm -23 "$pre_files" "$post_files" > "$deleted_file"
    # join requires same sort order as take_snapshot (LC_ALL=C, sorted by field 2)
    LC_ALL=C join -t $'\t' -1 2 -2 2 -o 1.2,1.1,2.1 "$PRE_SNAP" "$POST_SNAP" \
        | awk -F $'\t' '$2 != $3 {print $1}' > "$modified_file"

    if [[ -s "$added_file" ]]; then
        echo "추가된 파일:"
        print_prefixed_lines "+" "$added_file"
    fi
    if [[ -s "$deleted_file" ]]; then
        echo "삭제된 파일:"
        print_prefixed_lines "-" "$deleted_file"
    fi
    if [[ -s "$modified_file" ]]; then
        echo "수정된 파일:"
        print_prefixed_lines "~" "$modified_file"
    fi
    if [[ ! -s "$added_file" && ! -s "$deleted_file" && ! -s "$modified_file" ]]; then
        echo "변경 없음"
    fi
    # temp files are cleaned up by the EXIT trap via _CLEANUP_FILES
}

case "$MODE" in
    pre)
        take_snapshot > "$PRE_SNAP"
        echo "스냅샷 저장: $(wc -l < "$PRE_SNAP" | tr -d ' ')개 파일"
        ;;
    post)
        if [[ ! -f "$PRE_SNAP" ]]; then
            echo "ERROR: pre 스냅샷이 없습니다. 먼저 'snapshot-diff.sh pre'를 실행하세요." >&2
            exit 1
        fi
        take_snapshot > "$POST_SNAP"
        if [[ ! -s "$POST_SNAP" ]]; then
            echo "경고: post 스냅샷이 비어 있습니다. 디렉터리에 파일이 없거나 스냅샷에 실패했을 수 있습니다." >&2
        fi
        report_diff
        rm -f "$PRE_SNAP" "$POST_SNAP"
        ;;
    *)
        echo "Usage: snapshot-diff.sh [pre|post] [directory]" >&2
        exit 1
        ;;
esac
