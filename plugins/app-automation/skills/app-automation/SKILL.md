---
name: app-automation
description: Apple app automation guide — iOS Simulator + macOS app UI interaction, accessibility verification, screenshots/video, workflow automation. Activate on "시뮬레이터 자동화", "앱 자동화", "app automation", "UI 테스트", "접근성 검증", "스크린샷", "시뮬레이터 탭", "macOS 앱 조작", "인터랙션 테스트", "워크플로우 자동화" requests.
argument-hint: "[target app, scenario, or question to automate]"
hooks:
  Stop:
    - matcher: ""
      hooks:
        - type: agent
          model: sonnet
          timeout: 90
          prompt: |
            You are the final verifier for the app-automation skill.
            Hook input JSON:
            $ARGUMENTS

            First classify the task:
            - If the skill turn was advisory-only (docs, explanations, planning, recommendations) and the assistant did not claim to execute runtime automation or verification, return {"ok": true}.
            - If the assistant claimed to run or verify simulator/macOS automation, enforce the runtime evidence gates below.

            Runtime evidence gates:
            1. There must be environment evidence such as doctor/baepsae_version success, or you should run a lightweight environment check if missing.
            2. There must be pre-action UI evidence via analyze_ui/query_ui or an explicit reason why this was impossible.
            3. There must be post-action state evidence via query_ui/analyze_ui. Screenshot alone is not enough for PASS.
            4. There must be at least one artifact: screenshot path, video path, or UI tree result summary.
            5. If verification failed, the response must identify the exact failed step and propose a retry strategy.

            Prefer lightweight verification. Use baepsae tools when available. Do not modify project files.
            Return JSON only:
            - {"ok": true}
            - {"ok": false, "reason": "what evidence is missing or what claim failed"}
---

<example>
user: "시뮬레이터에서 앱 UI를 자동으로 탭하고 스크린샷 찍어줘"
assistant: "baepsae MCP 도구를 사용해 시뮬레이터에서 UI 요소를 탭하고 스크린샷을 캡처하겠습니다."
</example>

<example>
user: "macOS 앱의 메뉴를 자동으로 클릭하고 결과를 확인해줘"
assistant: "baepsae의 macOS 자동화 도구로 앱 메뉴 액션을 실행하고 UI 상태를 확인하겠습니다."
</example>

<example>
user: "로그인 → 메인 화면 → 설정 순서로 자동화 워크플로우 만들어줘"
assistant: "run_steps로 멀티스텝 워크플로우를 구성하여 로그인부터 설정 화면까지 자동화하겠습니다."
</example>

<example>
user: "앱의 접근성 트리를 분석해줘"
assistant: "analyze_ui로 현재 화면의 접근성 트리를 파악하고 UI 요소 구조를 분석하겠습니다."
</example>

# app-automation

Apple app automation guide — iOS Simulator + macOS app UI interaction, accessibility verification, screenshots/video, workflow automation.

Use the baepsae MCP server as the core toolset; if the axe-simulator plugin is present, use it via compatibility mapping.

Respond to the user in Korean.

> Tool reference: see `references/baepsae-tools.md`

---

## 1. Tool detection pattern

Before starting automation work, detect available tools in this priority order.

### Priority 1: baepsae MCP

When the baepsae MCP server is connected, all automation features are directly available. It supports the full set of 35 tools.

- Check: call `baepsae_version` or `doctor`
- Supports both iOS Simulator and macOS apps

### Priority 2: axe-simulator plugin

When the axe-simulator MCP plugin is active, you can perform iOS Simulator automation. It has fewer tools than baepsae but covers the core features.

- Check: call `mcp__plugin_axe-simulator_axe-simulator__axe_list_simulators`
- iOS Simulator only (no macOS app automation)
- For tool mapping, see the **axe-simulator compatibility** section below

### Priority 3: CLI fallback

When no MCP tools are available, use the `xcrun simctl` CLI for basic simulator operations.

```bash
# 시뮬레이터 목록
xcrun simctl list devices available

# 앱 설치/실행
xcrun simctl install booted /path/to/App.app
xcrun simctl launch booted com.example.app

# 스크린샷
xcrun simctl io booted screenshot /tmp/screenshot.png

# URL 열기
xcrun simctl openurl booted "https://example.com"

# 앱 종료
xcrun simctl terminate booted com.example.app
```

> The CLI fallback does not support UI interaction (tap, swipe, etc.) or accessibility analysis. If those features are needed, guide the user to install baepsae or axe-simulator.

---

## 2. iOS Simulator automation

### Simulator management

```
list_simulators              # 사용 가능한 시뮬레이터 목록
install_app(path)            # .app 번들 설치
launch_app(bundleId)         # 앱 실행
terminate_app(bundleId)      # 앱 종료
uninstall_app(bundleId)      # 앱 삭제
open_url(url)                # URL 스킴/딥링크 열기
```

### UI interaction

```
tap(selector)                # 접근성 셀렉터로 탭 (label, id, type)
tap(x, y)                    # 좌표로 탭
tap_tab(label)               # 탭바 아이템 탭
swipe(direction, selector)   # 스와이프 (up, down, left, right)
scroll(direction, selector)  # 스크롤
drag_drop(from, to)          # 드래그 앤 드롭
type_text(text)              # 텍스트 입력
key(key)                     # 단일 키 입력
key_sequence(keys)           # 키 시퀀스
key_combo(keys)              # 키 조합
touch(x, y)                  # 좌표 기반 터치
button(name)                 # 하드웨어 버튼 (home, lock, volumeUp 등)
gesture(name)                # 프리셋 제스처 (scrollUp, scrollDown, pinchIn, pinchOut 등)
```

### Accessibility tree analysis

```
analyze_ui()                 # 전체 접근성 트리 덤프 — UI 구조 파악의 첫 단계
analyze_ui(appBundleId)      # 특정 앱의 접근성 트리
query_ui(selector)           # 특정 요소 검색 (id:"loginBtn", label:"로그인", type:"Button")
```

**Usage pattern**:
1. Use `analyze_ui()` to understand the overall UI structure
2. Identify the target element's selector (label, id, type)
3. Interact with that element via `tap(selector)`, etc.
4. Run `analyze_ui()` again to confirm the UI state change

### Screenshot / video

```
screenshot()                 # 현재 화면 스크린샷
screenshot(path)             # 지정 경로에 저장
record_video(path, duration) # 비디오 녹화 (초 단위)
stream_video()               # 비디오 스트리밍
```

---

## 3. macOS app automation

> macOS automation is supported by **baepsae MCP only**. It is not available via axe-simulator or the CLI fallback.

### App management

```
list_apps()                  # 설치된 앱 목록
activate_app(bundleId)       # 앱 활성화/포커스
get_focused_app()            # 현재 포커스 앱 정보
list_windows(bundleId)       # 앱의 윈도우 목록
```

### UI interaction

```
tap(selector, appBundleId)   # macOS 앱 내 요소 탭
type_text(text, appBundleId) # macOS 앱에 텍스트 입력
right_click(selector)        # 우클릭 (컨텍스트 메뉴)
menu_action(app, menu, item) # 메뉴 바 액션 실행
key_combo(keys)              # 키보드 단축키 (Cmd+S, Cmd+A 등)
clipboard(action, text)      # 클립보드 읽기/쓰기
```

### Screenshot

```
screenshot_app(bundleId)     # 특정 앱 윈도우 스크린샷
screenshot_app(bundleId, windowId) # 특정 윈도우 캡처
```

**macOS automation tips**:
- Bring the app to the foreground first with `activate_app`
- Confirm the currently active app with `get_focused_app` before acting
- Specify the menu bar path exactly for `menu_action` (e.g. "File" → "Save As...")
- Accessibility permission may be required — diagnose the environment with `doctor`

---

## 4. Workflow automation

### run_steps: multi-step scenario execution

Bundle multiple automation steps into a single workflow and run them sequentially.

```json
{
  "steps": [
    { "action": "launch_app", "bundleId": "com.example.app" },
    { "action": "wait", "seconds": 2 },
    { "action": "tap", "selector": "label:로그인" },
    { "action": "type_text", "text": "user@example.com", "selector": "id:emailField" },
    { "action": "tap", "selector": "label:다음" },
    { "action": "type_text", "text": "password123", "selector": "id:passwordField" },
    { "action": "tap", "selector": "label:로그인" },
    { "action": "wait", "seconds": 3 },
    { "action": "screenshot", "path": "/tmp/after-login.png" },
    { "action": "analyze_ui" }
  ],
  "continueOnError": false
}
```

**Key options**:
- `continueOnError: true` — keep running the remaining steps even if a step fails
- `continueOnError: false` (default) — stop immediately on failure
- Use a `wait` step to wait for animations/network
- Returns each step result as an array

**Selector wait/retry pattern**:
When a UI element has not yet rendered:
1. Add a `wait` step (1-3s)
2. Confirm the element exists with `query_ui`
3. Retry if absent

```json
{
  "steps": [
    { "action": "query_ui", "selector": "label:메인 화면" },
    { "action": "wait", "seconds": 2 },
    { "action": "query_ui", "selector": "label:메인 화면" },
    { "action": "tap", "selector": "label:설정" }
  ],
  "continueOnError": true
}
```

---

## 5. apple-craft harness integration

The **harness-evaluator** from the apple-craft plugin can use this plugin's automation tools to perform runtime verification.

### Evaluator usage scenarios

| Evaluator stage | app-automation tool | Purpose |
|----------------|---------------------|------|
| App launch check | `launch_app` + `analyze_ui` | Whether the built app launches normally |
| UI rendering verification | `screenshot` + `analyze_ui` | Whether the screen renders as designed |
| Interaction verification | `tap` + `query_ui` | Whether tapping a button transitions to the expected screen |
| Accessibility verification | `analyze_ui` | Whether every element has an accessibility label |
| E2E scenario | `run_steps` | Whether the full user flow works correctly |

**Integration method**: after the build completes, the Evaluator calls the automation tools to verify runtime state. Use `analyze_ui` to inspect the UI tree and `screenshot` to capture the visual result.

---

## 6. axe-simulator compatibility

In environments where the axe-simulator plugin is installed, use the tool mapping below to perform iOS Simulator automation.

| baepsae tool | axe-simulator tool | Note |
|-------------|-------------------|------|
| `tap` | `axe_tap` | Supports both selector and coordinates |
| `swipe` | `axe_swipe` | Same `direction` parameter |
| `type_text` | `axe_type` | |
| `key` | `axe_key` | |
| `key_combo` | `axe_key_combo` | |
| `button` | `axe_button` | home, lock, etc. |
| `gesture` | `axe_gesture` | Preset gestures |
| `screenshot` | `axe_screenshot` | |
| `analyze_ui` | `axe_describe_ui` | Accessibility tree analysis |
| `list_simulators` | `axe_list_simulators` | |
| `run_steps` (simplified) | `axe_batch` | Multi-step batch |

**Features missing in axe-simulator**:
- All macOS app automation (activate_app, menu_action, screenshot_app, etc.)
- `query_ui` (specific element search)
- `record_video`, `stream_video`
- `drag_drop`, `right_click`, `clipboard`
- `install_app`, `uninstall_app`, `open_url`
- Advanced `run_steps` options (continueOnError, etc.)

> axe-simulator provides only the core iOS Simulator features. Use the baepsae MCP when the full feature set is needed.

---

## 7. Verification agent integration

This plugin also ships a `ui-verifier` agent. Its purpose is to separate **automation execution** from **automation verification**.

### When to use it

- "자동화가 진짜 성공했는지 검증해줘"
- "설정 화면까지 갔다고 했는데 selector evidence로 다시 확인해줘"
- "이 플로우가 재현 가능한지 확인해줘"

### Recommended pattern

1. **actor step** — perform the flow via `run_steps`, `tap`, `type_text`, `launch_app`, etc.
2. **observer step** — `ui-verifier` checks evidence via `query_ui`, `analyze_ui`, `screenshot`
3. **exit gate** — this skill's `Stop` agent hook catches missing verification before the final response

### Manual invocation examples

- `Use the ui-verifier agent to verify the last simulator flow`
- `Have the ui-verifier agent check whether the settings screen actually opened`

### ui-verifier hard gate

- `doctor` or equivalent environment check succeeds
- UI state evidence exists before the interaction
- Expected state evidence exists after the interaction
- At least one of screenshot/video/UI tree exists
- On failure, report the blocked step + retry strategy

> If only a screenshot exists without selector evidence, the default verdict is `REFINE`, not PASS.

---

## Rules

- Inspect the current UI state with `analyze_ui` (or `axe_describe_ui`) before automation work, since selectors depend on the live UI tree.
- Prefer selectors in order `id:` → `label:` → `type:` → coordinates (most to least stable).
- Use coordinate-based taps only as a last resort, since they are resolution-dependent.
- Place `wait` steps appropriately to account for asynchronous UI updates.
- Confirm accessibility permission for macOS automation (diagnose with `doctor`), since it is required for UI access.
- Save screenshots to `/tmp/` or a project-designated directory.
- Respond in Korean, keeping tool names and parameter names in their original form.
- Read `references/baepsae-tools.md` when a tool reference is needed.
