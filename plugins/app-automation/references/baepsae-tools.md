# mcp-baepsae Tool Reference

> Version: 6.1.1 | iOS Simulator + macOS app automation

---

## UI Interaction (8)

| Tool | Description | Target |
|------|-------------|--------|
| `analyze_ui` | Accessibility tree analysis — grasp the full UI structure | iOS/macOS |
| `query_ui` | Search for a specific UI element (id, label, type) | iOS/macOS |
| `tap` | Tap (coordinates or accessibility selector) | iOS/macOS |
| `tap_tab` | Tap a tab bar item | iOS/macOS |
| `type_text` | Text input (paste/keyboard) | iOS/macOS |
| `swipe` | Swipe gesture | iOS/macOS |
| `scroll` | Scroll | iOS/macOS |
| `drag_drop` | Drag and drop | iOS/macOS |

### Key parameters

**analyze_ui**
- `appBundleId` (optional) — scope to a specific app
- Returns: accessibility element tree (label, id, type, value, frame)

**query_ui**
- `selector` — search condition (`id:loginBtn`, `label:로그인`, `type:Button`)
- `appBundleId` (optional) — scope to an app

**tap**
- `selector` — accessibility selector (`label:확인`, `id:submitBtn`)
- `x`, `y` — coordinate-based tap (alternative to selector)
- `appBundleId` (optional) — target app on macOS

**type_text**
- `text` — text to enter
- `method` — `paste` (default) or `keyboard`
- `selector` (optional) — target input element
- `appBundleId` (optional) — target app on macOS

**swipe**
- `direction` — `up`, `down`, `left`, `right`
- `selector` (optional) — target element
- `distance` (optional) — swipe distance

**scroll**
- `direction` — `up`, `down`, `left`, `right`
- `selector` (optional) — scroll target
- `amount` (optional) — scroll amount

**drag_drop**
- `from` — start coordinates or selector
- `to` — end coordinates or selector

### Examples

```
# Analyze the full accessibility tree
analyze_ui()

# Tap the element labeled "로그인"
tap(selector: "label:로그인")

# Coordinate-based tap
tap(x: 200, y: 400)

# Text input
type_text(text: "hello@example.com", selector: "id:emailField")

# Swipe down
swipe(direction: "down")
```

---

## Input Control (4)

| Tool | Description | Target |
|------|-------------|--------|
| `key` | Single key input | iOS/macOS |
| `key_sequence` | Key sequence input | iOS/macOS |
| `key_combo` | Key combination (Cmd+A, etc.) | iOS/macOS |
| `touch` | Coordinate-based touch | iOS |

### Key parameters

**key**
- `key` — key name (`return`, `escape`, `tab`, `delete`, `space`)

**key_sequence**
- `keys` — key array (`["a", "b", "c"]`)
- `delay` (optional) — delay between keys (ms)

**key_combo**
- `keys` — keys to press simultaneously (`["command", "a"]`, `["command", "shift", "s"]`)

**touch**
- `x`, `y` — touch coordinates
- `duration` (optional) — long press (ms)

### Examples

```
# Enter key
key(key: "return")

# Cmd+A (select all)
key_combo(keys: ["command", "a"])

# Sequential key input
key_sequence(keys: ["h", "e", "l", "l", "o"], delay: 50)

# Long press
touch(x: 200, y: 300, duration: 1000)
```

---

## Simulator Operations (12)

| Tool | Description |
|------|-------------|
| `list_simulators` | List of available simulators |
| `screenshot` | Simulator screenshot |
| `record_video` | Record video |
| `stream_video` | Stream video |
| `open_url` | Open URL (deep link, universal link) |
| `install_app` | Install app (.app bundle path) |
| `launch_app` | Launch app (bundle ID) |
| `terminate_app` | Terminate app |
| `uninstall_app` | Uninstall app |
| `button` | Hardware button |
| `gesture` | Preset gesture |

### Key parameters

**list_simulators**
- No parameters. Returns the list of booted simulators and available devices.

**screenshot**
- `path` (optional) — save path. Returns base64 if omitted.
- `simulatorId` (optional) — target simulator UDID

**record_video**
- `path` — save path
- `duration` — recording duration (seconds)

**install_app**
- `path` — .app bundle path

**launch_app**
- `bundleId` — app bundle ID (e.g., `com.example.app`)

**terminate_app / uninstall_app**
- `bundleId` — target app bundle ID

**open_url**
- `url` — URL to open (deep link, universal link, etc.)

**button**
- `name` — button name: `home`, `lock`, `volumeUp`, `volumeDown`, `siri`

**gesture**
- `name` — preset gesture: `scrollUp`, `scrollDown`, `scrollLeft`, `scrollRight`, `pinchIn`, `pinchOut`, `rotateLeft`, `rotateRight`

### Examples

```
# Check the simulator list
list_simulators()

# Install → launch app
install_app(path: "/path/to/MyApp.app")
launch_app(bundleId: "com.example.myapp")

# Save a screenshot
screenshot(path: "/tmp/current-screen.png")

# Record video (10 seconds)
record_video(path: "/tmp/demo.mp4", duration: 10)

# Home button
button(name: "home")

# Pinch zoom in
gesture(name: "pinchOut")

# Open a deep link
open_url(url: "myapp://settings/profile")
```

---

## macOS System (8)

| Tool | Description |
|------|-------------|
| `list_apps` | List of installed apps |
| `menu_action` | Run a menu bar action |
| `get_focused_app` | Info on the currently focused app |
| `list_windows` | List of windows |
| `activate_app` | Activate/focus an app |
| `screenshot_app` | App window screenshot |
| `right_click` | Right-click |
| `clipboard` | Read/write the clipboard |

### Key parameters

**list_apps**
- No parameters. Returns the list of running apps.

**activate_app**
- `bundleId` — app to activate (e.g., `com.apple.Safari`)

**get_focused_app**
- No parameters. Returns info on the current foreground app.

**list_windows**
- `bundleId` (optional) — query windows of a specific app only

**menu_action**
- `app` — target app name (e.g., `"Safari"`)
- `menuPath` — menu path array (e.g., `["File", "Save As..."]`)

**screenshot_app**
- `bundleId` — target app
- `windowId` (optional) — capture a specific window
- `path` (optional) — save path

**right_click**
- `selector` — right-click target (selector or coordinates)
- `appBundleId` (optional) — target app

**clipboard**
- `action` — `read` or `write`
- `text` (on write) — text to store in the clipboard

### Examples

```
# Check the currently focused app
get_focused_app()

# Activate Safari
activate_app(bundleId: "com.apple.Safari")

# Run the "New Folder" menu in Finder
menu_action(app: "Finder", menuPath: ["File", "New Folder"])

# App window screenshot
screenshot_app(bundleId: "com.apple.Safari", path: "/tmp/safari.png")

# Copy text to the clipboard
clipboard(action: "write", text: "복사할 텍스트")

# Read the clipboard
clipboard(action: "read")
```

---

## Workflow (1)

| Tool | Description |
|------|-------------|
| `run_steps` | Run a multi-step workflow |

### Key parameters

**run_steps**
- `steps` — array of steps to run. Each step contains an `action` field plus the parameters of the corresponding tool.
- `continueOnError` (optional, default `false`) — if `true`, skip failed steps and continue

### Examples

```json
{
  "steps": [
    { "action": "launch_app", "bundleId": "com.example.app" },
    { "action": "wait", "seconds": 2 },
    { "action": "analyze_ui" },
    { "action": "tap", "selector": "label:시작하기" },
    { "action": "wait", "seconds": 1 },
    { "action": "screenshot", "path": "/tmp/step-result.png" }
  ],
  "continueOnError": false
}
```

---

## Utility (3)

| Tool | Description |
|------|-------------|
| `baepsae_help` | Help (tool list, usage) |
| `baepsae_version` | Currently installed version info |
| `doctor` | Environment diagnostics (Xcode CLI, simulator, accessibility permissions, etc.) |

### Examples

```
# Environment diagnostics
doctor()

# Check version
baepsae_version()
```

---

## iOS vs macOS key differences

| Feature | iOS Simulator | macOS app |
|---------|---------------|-----------|
| App install/uninstall | `install_app` / `uninstall_app` | Not available (system manages apps) |
| App launch | `launch_app` | `activate_app` |
| Hardware buttons | `button` (home, lock, etc.) | Not applicable |
| Gestures | `gesture` (pinch, rotate, etc.) | Not applicable |
| Menu actions | Not applicable | `menu_action` |
| Window management | Not applicable | `list_windows` |
| Right-click | Not applicable | `right_click` |
| Clipboard | Not applicable | `clipboard` |
| Touch | `touch` (coordinate-based) | Not applicable |
| Open URL | `open_url` | Not applicable |
| Video | `record_video`, `stream_video` | Not applicable |

---

## axe-simulator tool mapping

Tool correspondence table for environments where the axe-simulator plugin is active.

| baepsae | axe-simulator | MCP tool name |
|---------|---------------|---------------|
| `analyze_ui` | `axe_describe_ui` | `mcp__plugin_axe-simulator_axe-simulator__axe_describe_ui` |
| `tap` | `axe_tap` | `mcp__plugin_axe-simulator_axe-simulator__axe_tap` |
| `swipe` | `axe_swipe` | `mcp__plugin_axe-simulator_axe-simulator__axe_swipe` |
| `type_text` | `axe_type` | `mcp__plugin_axe-simulator_axe-simulator__axe_type` |
| `key` | `axe_key` | `mcp__plugin_axe-simulator_axe-simulator__axe_key` |
| `key_combo` | `axe_key_combo` | `mcp__plugin_axe-simulator_axe-simulator__axe_key_combo` |
| `button` | `axe_button` | `mcp__plugin_axe-simulator_axe-simulator__axe_button` |
| `gesture` | `axe_gesture` | `mcp__plugin_axe-simulator_axe-simulator__axe_gesture` |
| `screenshot` | `axe_screenshot` | `mcp__plugin_axe-simulator_axe-simulator__axe_screenshot` |
| `list_simulators` | `axe_list_simulators` | `mcp__plugin_axe-simulator_axe-simulator__axe_list_simulators` |
| `run_steps` (basic) | `axe_batch` | `mcp__plugin_axe-simulator_axe-simulator__axe_batch` |

**baepsae tools not present in axe-simulator**: `query_ui`, `tap_tab`, `scroll`, `drag_drop`, `key_sequence`, `touch`, `record_video`, `stream_video`, `open_url`, `install_app`, `launch_app`, `terminate_app`, `uninstall_app`, `list_apps`, `menu_action`, `get_focused_app`, `list_windows`, `activate_app`, `screenshot_app`, `right_click`, `clipboard`, `run_steps` (advanced), `baepsae_help`, `baepsae_version`, `doctor`
