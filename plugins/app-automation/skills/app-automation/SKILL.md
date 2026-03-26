---
name: app-automation
description: Apple 앱 자동화 가이드 — iOS Simulator + macOS 앱 UI 인터랙션, 접근성 검증, 스크린샷/비디오, 워크플로우 자동화. "시뮬레이터 자동화", "앱 자동화", "app automation", "UI 테스트", "접근성 검증", "스크린샷", "시뮬레이터 탭", "macOS 앱 조작", "인터랙션 테스트", "워크플로우 자동화" 요청 시 활성화
argument-hint: "[자동화 대상 앱, 시나리오, 또는 질문]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - mcp__plugin_axe-simulator_axe-simulator__axe_tap
  - mcp__plugin_axe-simulator_axe-simulator__axe_swipe
  - mcp__plugin_axe-simulator_axe-simulator__axe_type
  - mcp__plugin_axe-simulator_axe-simulator__axe_key
  - mcp__plugin_axe-simulator_axe-simulator__axe_key_combo
  - mcp__plugin_axe-simulator_axe-simulator__axe_button
  - mcp__plugin_axe-simulator_axe-simulator__axe_gesture
  - mcp__plugin_axe-simulator_axe-simulator__axe_screenshot
  - mcp__plugin_axe-simulator_axe-simulator__axe_describe_ui
  - mcp__plugin_axe-simulator_axe-simulator__axe_list_simulators
  - mcp__plugin_axe-simulator_axe-simulator__axe_batch
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

Apple 앱 자동화 가이드 — iOS Simulator + macOS 앱 UI 인터랙션, 접근성 검증, 스크린샷/비디오, 워크플로우 자동화.

baepsae MCP 서버를 핵심 도구로 사용하며, axe-simulator 플러그인이 있으면 호환 매핑으로 활용합니다.

> 도구 레퍼런스: `references/baepsae-tools.md` 참조

---

## 1. 도구 탐지 패턴

자동화 작업 시작 전에 사용 가능한 도구를 다음 우선순위로 탐지합니다.

### 우선순위 1: baepsae MCP

baepsae MCP 서버가 연결되어 있으면 **모든 자동화 기능**을 직접 사용할 수 있습니다. 35개 도구 전체를 지원합니다.

- 확인: `baepsae_version` 또는 `doctor` 호출
- iOS Simulator + macOS 앱 모두 지원

### 우선순위 2: axe-simulator 플러그인

axe-simulator MCP 플러그인이 활성화되어 있으면 iOS Simulator 자동화를 수행할 수 있습니다. baepsae 대비 도구 수가 적지만 핵심 기능을 커버합니다.

- 확인: `mcp__plugin_axe-simulator_axe-simulator__axe_list_simulators` 호출
- iOS Simulator만 지원 (macOS 앱 자동화 불가)
- 도구 매핑은 하단 **axe-simulator 호환** 섹션 참조

### 우선순위 3: CLI 폴백

MCP 도구가 없으면 `xcrun simctl` CLI로 기본 시뮬레이터 조작을 수행합니다.

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

> CLI 폴백은 UI 인터랙션(탭, 스와이프 등)과 접근성 분석을 지원하지 않습니다. 이런 기능이 필요하면 baepsae 또는 axe-simulator 설치를 안내하세요.

---

## 2. iOS Simulator 자동화

### 시뮬레이터 관리

```
list_simulators              # 사용 가능한 시뮬레이터 목록
install_app(path)            # .app 번들 설치
launch_app(bundleId)         # 앱 실행
terminate_app(bundleId)      # 앱 종료
uninstall_app(bundleId)      # 앱 삭제
open_url(url)                # URL 스킴/딥링크 열기
```

### UI 인터랙션

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

### 접근성 트리 분석

```
analyze_ui()                 # 전체 접근성 트리 덤프 — UI 구조 파악의 첫 단계
analyze_ui(appBundleId)      # 특정 앱의 접근성 트리
query_ui(selector)           # 특정 요소 검색 (id:"loginBtn", label:"로그인", type:"Button")
```

**활용 패턴**:
1. `analyze_ui()`로 전체 UI 구조를 파악
2. 원하는 요소의 셀렉터(label, id, type) 확인
3. `tap(selector)` 등으로 해당 요소에 인터랙션
4. 다시 `analyze_ui()`로 UI 상태 변화 확인

### 스크린샷 / 비디오

```
screenshot()                 # 현재 화면 스크린샷
screenshot(path)             # 지정 경로에 저장
record_video(path, duration) # 비디오 녹화 (초 단위)
stream_video()               # 비디오 스트리밍
```

---

## 3. macOS 앱 자동화

> macOS 자동화는 **baepsae MCP만** 지원합니다. axe-simulator, CLI 폴백으로는 불가합니다.

### 앱 관리

```
list_apps()                  # 설치된 앱 목록
activate_app(bundleId)       # 앱 활성화/포커스
get_focused_app()            # 현재 포커스 앱 정보
list_windows(bundleId)       # 앱의 윈도우 목록
```

### UI 인터랙션

```
tap(selector, appBundleId)   # macOS 앱 내 요소 탭
type_text(text, appBundleId) # macOS 앱에 텍스트 입력
right_click(selector)        # 우클릭 (컨텍스트 메뉴)
menu_action(app, menu, item) # 메뉴 바 액션 실행
key_combo(keys)              # 키보드 단축키 (Cmd+S, Cmd+A 등)
clipboard(action, text)      # 클립보드 읽기/쓰기
```

### 스크린샷

```
screenshot_app(bundleId)     # 특정 앱 윈도우 스크린샷
screenshot_app(bundleId, windowId) # 특정 윈도우 캡처
```

**macOS 자동화 팁**:
- `activate_app`으로 먼저 앱을 포그라운드로 가져오기
- `get_focused_app`으로 현재 활성 앱 확인 후 작업
- `menu_action`은 메뉴 바 경로를 정확히 지정 (예: "File" → "Save As...")
- 접근성 권한이 필요할 수 있음 — `doctor`로 환경 진단

---

## 4. 워크플로우 자동화

### run_steps: 멀티스텝 시나리오 실행

여러 자동화 단계를 하나의 워크플로우로 묶어 순차 실행합니다.

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

**주요 옵션**:
- `continueOnError: true` — 특정 단계 실패해도 나머지 계속 실행
- `continueOnError: false` (기본값) — 실패 시 즉시 중단
- `wait` 단계로 애니메이션/네트워크 대기
- 각 단계 결과를 배열로 반환

**셀렉터 wait/retry 패턴**:
UI 요소가 아직 렌더링되지 않았을 때:
1. `wait` 단계 추가 (1-3초)
2. `query_ui`로 요소 존재 확인
3. 없으면 재시도

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

## 5. apple-craft 하네스 연동

apple-craft 플러그인의 **harness-evaluator**가 이 플러그인의 자동화 도구를 활용하여 런타임 검증을 수행할 수 있습니다.

### Evaluator 활용 시나리오

| Evaluator 단계 | app-automation 도구 | 용도 |
|----------------|---------------------|------|
| 앱 실행 확인 | `launch_app` + `analyze_ui` | 빌드된 앱이 정상 실행되는지 |
| UI 렌더링 검증 | `screenshot` + `analyze_ui` | 화면이 설계대로 렌더링되는지 |
| 인터랙션 검증 | `tap` + `query_ui` | 버튼 탭 후 예상 화면으로 전환되는지 |
| 접근성 검증 | `analyze_ui` | 모든 요소에 접근성 레이블이 있는지 |
| E2E 시나리오 | `run_steps` | 전체 사용자 플로우가 정상 동작하는지 |

**연동 방법**: Evaluator가 빌드 완료 후 자동화 도구를 호출하여 런타임 상태를 검증합니다. `analyze_ui`로 UI 트리를 확인하고, `screenshot`으로 시각적 결과를 캡처합니다.

---

## 6. axe-simulator 호환

axe-simulator 플러그인이 설치된 환경에서는 아래 도구 매핑으로 iOS Simulator 자동화를 수행합니다.

| baepsae 도구 | axe-simulator 도구 | 비고 |
|-------------|-------------------|------|
| `tap` | `axe_tap` | 셀렉터/좌표 모두 지원 |
| `swipe` | `axe_swipe` | direction 파라미터 동일 |
| `type_text` | `axe_type` | |
| `key` | `axe_key` | |
| `key_combo` | `axe_key_combo` | |
| `button` | `axe_button` | home, lock 등 |
| `gesture` | `axe_gesture` | 프리셋 제스처 |
| `screenshot` | `axe_screenshot` | |
| `analyze_ui` | `axe_describe_ui` | 접근성 트리 분석 |
| `list_simulators` | `axe_list_simulators` | |
| `run_steps` (간이) | `axe_batch` | 멀티스텝 배치 |

**axe-simulator에서 없는 기능**:
- macOS 앱 자동화 전체 (activate_app, menu_action, screenshot_app 등)
- `query_ui` (특정 요소 검색)
- `record_video`, `stream_video`
- `drag_drop`, `right_click`, `clipboard`
- `install_app`, `uninstall_app`, `open_url`
- `run_steps`의 고급 옵션 (continueOnError 등)

> axe-simulator는 iOS Simulator 핵심 기능만 제공합니다. 전체 기능이 필요하면 baepsae MCP를 사용하세요.

---

## Rules

- 자동화 작업 전 **반드시** `analyze_ui`(또는 `axe_describe_ui`)로 현재 UI 상태를 파악
- 셀렉터는 `id:` → `label:` → `type:` → 좌표 순으로 우선 사용 (안정성 순)
- 좌표 기반 탭은 해상도 의존적이므로 **최후 수단**으로만 사용
- `wait` 단계를 적절히 배치하여 비동기 UI 업데이트를 고려
- macOS 자동화 시 **접근성 권한** 확인 필수 (`doctor`로 진단)
- 스크린샷은 `/tmp/` 또는 프로젝트 지정 디렉토리에 저장
- 한국어로 응답하되, 도구명/파라미터명은 원문 유지
- 도구 레퍼런스가 필요하면 `references/baepsae-tools.md`를 Read
