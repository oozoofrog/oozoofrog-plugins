# Claude Code Session JSONL Schema

이 문서는 Claude Code가 `~/.claude/projects/<encoded-cwd>/<session-uuid>.jsonl`에 기록하는 JSONL 라인의 종류와 필드를 정리한다. 스킬의 파서(`src/src/main.rs`의 `extract_user_text`, `load_messages`)가 이 스키마를 따른다.

## 디렉토리 인코딩

세션 디렉토리 이름은 cwd를 다음 규칙으로 인코딩한 것이다:

```
replace each '/' or '.' with '-'
```

| cwd | encoded directory name |
|---|---|
| `/Users/oozoofrog` | `-Users-oozoofrog` |
| `/Volumes/eyedisk/develop/kakao-talk` | `-Volumes-eyedisk-develop-kakao-talk` |
| `/Users/foo/site.io/.claude/x` | `-Users-foo-site-io--claude-x` |

`-Users-foo` 처럼 leading dash로 시작하는 것은 cwd의 leading `/` 때문이다. `--claude` 같은 double dash는 `/.claude` (slash + dot)이 모두 dash로 치환되며 발생.

이 인코딩은 lossy다 — `kakao-talk`과 `kakao.talk`은 같은 인코딩이 된다. 일반적인 cwd에서는 충돌 가능성이 낮다.

## 라인 타입

각 라인은 단일 JSON 오브젝트. 빈 줄 또는 파싱 실패 라인은 skip.

### 1. `permission-mode`

세션 시작 또는 모드 전환 시.

```json
{
  "type": "permission-mode",
  "permissionMode": "auto",
  "sessionId": "033fc3a3-750c-4d09-afc0-4e4915db9408"
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `type` | `"permission-mode"` | 고정 |
| `permissionMode` | string | `"auto"`, `"acceptEdits"`, `"plan"`, `"default"`, `"bypassPermissions"`, `"dontAsk"` 중 하나 |
| `sessionId` | uuid | 현재 세션 ID |

### 2. `user`

사용자 메시지. `message.content`는 두 형태가 가능하다.

#### 2a. content가 string

```json
{
  "type": "user",
  "message": {
    "role": "user",
    "content": "안녕하세요"
  }
}
```

#### 2b. content가 block 배열

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

블록 타입별 처리:

- `type: "text"` — `text` 필드 사용
- `type: "tool_result"` — `tool_use_id`로 매칭, `content`는 string 또는 `[{type:"text", text:"..."}]` 배열

특수 케이스: 사용자 텍스트가 `<system-reminder>`, `<command-message>`, `<command-name>`, `<command-args>`, `<local-command-stdout>`로 시작하면 노이즈로 분류하여 첫 user prompt 추출 시 제외 (스킬에서는 detail view에서도 제외).

### 3. `assistant`

어시스턴트 응답. `message.content`는 항상 block 배열.

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

블록 타입:

- `type: "text"` — 일반 응답 텍스트
- `type: "tool_use"` — 도구 호출. `name`, `id`, `input` 사용. `input`은 임의 JSON 오브젝트
- `type: "thinking"` — extended thinking. `thinking` 필드의 string 사용

### 4. Hook 이벤트 (`attachment` 필드)

`type` 필드가 없거나 다른 값이고 `attachment` 객체를 가진 라인은 hook 이벤트로 처리.

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

| 필드 | 의미 |
|---|---|
| `attachment.hookName` | 예: `"SessionStart:startup"`, `"UserPromptSubmit"`, `"PreToolUse"` |
| `attachment.hookEvent` | hook event 종류 (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`) |
| `attachment.stdout` | hook 스크립트의 stdout — 종종 JSON으로 추가 컨텍스트 주입 |

### 5. 기타 라인

위 4가지로 매칭되지 않는 라인은 현재 스킬에서 silent하게 skip된다. 향후 확장 가능한 라인 종류:

- 압축(`compact`) 이벤트
- `summary` 라인
- 진단(`telemetry`) 라인

## 첫 user prompt 추출 알고리즘

세션 목록 표시용 미리보기를 위해 다음 절차로 추출:

1. 파일을 한 줄씩 스캔
2. `type == "user"`이고 content에서 텍스트를 추출 (block 배열이면 모든 `text` 블록 합침)
3. 추출 텍스트를 trim 후, `is_system_noise`로 필터 (system-reminder 등)
4. 첫 번째로 통과한 텍스트를 200자로 truncate하여 사용

빈 결과인 경우 `(no user message)`로 표시.

## 메시지 카운트

`msg_count`는 파일 안의 valid JSON 라인 개수 (빈 줄/파싱 실패 제외). user/assistant/hook/permission-mode 모두 합친 raw event count다 — 사용자가 주고받은 turn 수와는 다르다.

정확한 turn 수가 필요하면 `type == "user" && content가 시스템 노이즈가 아님` 으로 다시 카운트해야 한다.

## 시간 정렬

세션 목록은 파일의 mtime (last modified) 내림차순 정렬. JSONL 안의 timestamp가 아닌 파일 시스템 mtime 사용 — 단순하고 빠르며, 마지막 활동 시점을 잘 반영한다.

## 변경 이력

스키마는 Claude Code 버전에 따라 진화한다. 다음 사항은 현재 관찰된 형태이며 향후 변경 가능:

- `parentUuid`, `isSidechain` 필드는 모든 라인에 있을 수 있음 (sidechain agent 추적용)
- `sessionId`는 `permission-mode` 라인 외에는 보통 생략됨 (파일명이 곧 sessionId)
- 새로운 block type (예: `image`, `document`)이 추가될 수 있음

스킬 파서는 알 수 없는 type을 silent skip하므로 forward-compatible.
