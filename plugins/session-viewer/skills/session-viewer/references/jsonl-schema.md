# Claude Code Session JSONL Schema

This document catalogs the types and fields of the JSONL lines that Claude Code writes to `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl`. The skill's parser (`extract_user_text`, `load_messages` in `src/src/data.rs`) follows this schema.

## Directory Encoding

The session directory name is the cwd encoded with the following rule:

```
replace each '/' or '.' with '-'
```

| cwd | encoded directory name |
|---|---|
| `/Users/oozoofrog` | `-Users-oozoofrog` |
| `/Volumes/eyedisk/develop/kakao-talk` | `-Volumes-eyedisk-develop-kakao-talk` |
| `/Users/foo/site.io/.claude/x` | `-Users-foo-site-io--claude-x` |

The leading dash, as in `-Users-foo`, comes from the leading `/` of the cwd. A double dash like `--claude` occurs when `/.claude` (slash + dot) is both replaced with dashes.

This encoding is lossy — `kakao-talk` and `kakao.talk` encode to the same value. For typical cwds the collision probability is low.

## Line Types

Each line is a single JSON object. Empty lines or lines that fail to parse are skipped.

### 1. `permission-mode`

At session start or on mode switch.

```json
{
  "type": "permission-mode",
  "permissionMode": "auto",
  "sessionId": "033fc3a3-750c-4d09-afc0-4e4915db9408"
}
```

| field | type | description |
|---|---|---|
| `type` | `"permission-mode"` | fixed |
| `permissionMode` | string | one of `"auto"`, `"acceptEdits"`, `"plan"`, `"default"`, `"bypassPermissions"`, `"dontAsk"` |
| `sessionId` | uuid | current session ID |

### 2. `user`

User message. `message.content` can take two forms.

#### 2a. content as string

```json
{
  "type": "user",
  "message": {
    "role": "user",
    "content": "안녕하세요"
  }
}
```

#### 2b. content as block array

```json
{
  "type": "user",
  "message": {
    "role": "user",
    "content": [
      { "type": "text", "text": "이 함수 분석해줘" },
      { "type": "tool_result", "tool_use_id": "toolu_abc123", "content": "...결과 텍스트..." }
    ]
  }
}
```

Handling by block type:

- `type: "text"` — use the `text` field
- `type: "tool_result"` — matched by `tool_use_id`; `content` is a string or a `[{type:"text", text:"..."}]` array

Special case: if the user text starts with `<system-reminder>`, `<command-message>`, `<command-name>`, `<command-args>`, or `<local-command-stdout>`, it is classified as noise and excluded when extracting the first user prompt (the skill also excludes it from the detail view).

### 3. `assistant`

Assistant response. `message.content` is always a block array.

```json
{
  "type": "assistant",
  "message": {
    "role": "assistant",
    "content": [
      { "type": "text", "text": "분석 결과는..." },
      {
        "type": "tool_use",
        "id": "toolu_abc123",
        "name": "Read",
        "input": { "file_path": "/Users/.../foo.rs" }
      },
      { "type": "thinking", "thinking": "사용자가 원하는 건..." }
    ]
  }
}
```

Block types:

- `type: "text"` — normal response text
- `type: "tool_use"` — tool call. Use `name`, `id`, `input`. `input` is an arbitrary JSON object
- `type: "thinking"` — extended thinking. Use the string in the `thinking` field

### 4. Hook Events (`attachment` field)

A line with no `type` field, or a different value, that has an `attachment` object is treated as a hook event.

```json
{
  "parentUuid": null,
  "isSidechain": false,
  "attachment": {
    "type": "hook_success",
    "hookName": "SessionStart:startup",
    "toolUseID": "...",
    "hookEvent": "SessionStart",
    "content": "",
    "stdout": "..."
  }
}
```

| field | meaning |
|---|---|
| `attachment.hookName` | e.g. `"SessionStart:startup"`, `"UserPromptSubmit"`, `"PreToolUse"` |
| `attachment.hookEvent` | hook event type (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`) |
| `attachment.stdout` | stdout of the hook script — often JSON to inject additional context |

### 5. Other Lines

Lines that match none of the four above are currently silently skipped by the skill. Line types that may be supported in the future:

- compaction (`compact`) events
- `summary` lines
- diagnostic (`telemetry`) lines

## First User Prompt Extraction Algorithm

For the preview shown in the session list, extraction proceeds as follows:

1. Scan the file line by line
2. For `type == "user"`, extract the text from content (if a block array, concatenate all `text` blocks)
3. Trim the extracted text, then filter with `is_system_noise` (system-reminder, etc.)
4. Truncate the first text that passes to 200 characters and use it

If the result is empty, display `(no user message)`.

## Message Count

`msg_count` is the number of valid JSON lines in the file (excluding empty/parse-failed lines). It is a raw event count combining user/assistant/hook/permission-mode — different from the number of turns the user exchanged.

If you need the exact turn count, re-count with `type == "user" && content is not system noise`.

## Time Ordering

The session list is sorted in descending order by the file's mtime (last modified). It uses the file system mtime rather than a timestamp inside the JSONL — simple, fast, and a good reflection of the last activity time.

## Change History

The schema evolves across Claude Code versions. The following are the currently observed shapes and may change in the future:

- The `parentUuid` and `isSidechain` fields may appear on every line (for sidechain agent tracking)
- `sessionId` is usually omitted outside of `permission-mode` lines (the filename is the sessionId)
- New block types (e.g. `image`, `document`) may be added

The skill parser silently skips unknown types, so it is forward-compatible.
