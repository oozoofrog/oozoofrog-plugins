# mcp-baepsae 도구 레퍼런스

> 버전: 6.1.1 | iOS Simulator + macOS 앱 자동화

---

## UI Interaction (8개)

| 도구 | 설명 | 대상 |
|------|------|------|
| `analyze_ui` | 접근성 트리 분석 — 전체 UI 구조 파악 | iOS/macOS |
| `query_ui` | 특정 UI 요소 검색 (id, label, type) | iOS/macOS |
| `tap` | 탭 (좌표 또는 접근성 셀렉터) | iOS/macOS |
| `tap_tab` | 탭바 아이템 탭 | iOS/macOS |
| `type_text` | 텍스트 입력 (paste/keyboard) | iOS/macOS |
| `swipe` | 스와이프 제스처 | iOS/macOS |
| `scroll` | 스크롤 | iOS/macOS |
| `drag_drop` | 드래그 앤 드롭 | iOS/macOS |

### 주요 파라미터

**analyze_ui**
- `appBundleId` (선택) — 특정 앱으로 범위 제한
- 반환: 접근성 요소 트리 (label, id, type, value, frame)

**query_ui**
- `selector` — 검색 조건 (`id:loginBtn`, `label:로그인`, `type:Button`)
- `appBundleId` (선택) — 앱 범위 제한

**tap**
- `selector` — 접근성 셀렉터 (`label:확인`, `id:submitBtn`)
- `x`, `y` — 좌표 기반 탭 (셀렉터와 택일)
- `appBundleId` (선택) — macOS에서 대상 앱 지정

**type_text**
- `text` — 입력할 텍스트
- `method` — `paste` (기본) 또는 `keyboard`
- `selector` (선택) — 입력 대상 요소
- `appBundleId` (선택) — macOS 앱 지정

**swipe**
- `direction` — `up`, `down`, `left`, `right`
- `selector` (선택) — 대상 요소
- `distance` (선택) — 스와이프 거리

**scroll**
- `direction` — `up`, `down`, `left`, `right`
- `selector` (선택) — 스크롤 대상
- `amount` (선택) — 스크롤 양

**drag_drop**
- `from` — 시작 좌표 또는 셀렉터
- `to` — 끝 좌표 또는 셀렉터

### 사용 예시

```
# 접근성 트리 전체 분석
analyze_ui()

# "로그인" 레이블 요소 탭
tap(selector: "label:로그인")

# 좌표 기반 탭
tap(x: 200, y: 400)

# 텍스트 입력
type_text(text: "hello@example.com", selector: "id:emailField")

# 아래로 스와이프
swipe(direction: "down")
```

---

## Input Control (4개)

| 도구 | 설명 | 대상 |
|------|------|------|
| `key` | 단일 키 입력 | iOS/macOS |
| `key_sequence` | 키 시퀀스 입력 | iOS/macOS |
| `key_combo` | 키 조합 (Cmd+A 등) | iOS/macOS |
| `touch` | 좌표 기반 터치 | iOS |

### 주요 파라미터

**key**
- `key` — 키 이름 (`return`, `escape`, `tab`, `delete`, `space`)

**key_sequence**
- `keys` — 키 배열 (`["a", "b", "c"]`)
- `delay` (선택) — 키 사이 딜레이 (ms)

**key_combo**
- `keys` — 동시 누를 키 조합 (`["command", "a"]`, `["command", "shift", "s"]`)

**touch**
- `x`, `y` — 터치 좌표
- `duration` (선택) — 롱프레스 (ms)

### 사용 예시

```
# Enter 키
key(key: "return")

# Cmd+A (전체 선택)
key_combo(keys: ["command", "a"])

# 순차 키 입력
key_sequence(keys: ["h", "e", "l", "l", "o"], delay: 50)

# 롱프레스
touch(x: 200, y: 300, duration: 1000)
```

---

## Simulator Operations (12개)

| 도구 | 설명 |
|------|------|
| `list_simulators` | 사용 가능한 시뮬레이터 목록 |
| `screenshot` | 시뮬레이터 스크린샷 |
| `record_video` | 비디오 녹화 |
| `stream_video` | 비디오 스트리밍 |
| `open_url` | URL 열기 (딥링크, 유니버설 링크) |
| `install_app` | 앱 설치 (.app 번들 경로) |
| `launch_app` | 앱 실행 (번들 ID) |
| `terminate_app` | 앱 종료 |
| `uninstall_app` | 앱 삭제 |
| `button` | 하드웨어 버튼 |
| `gesture` | 프리셋 제스처 |

### 주요 파라미터

**list_simulators**
- 파라미터 없음. 부팅된 시뮬레이터와 사용 가능한 디바이스 목록 반환.

**screenshot**
- `path` (선택) — 저장 경로. 미지정 시 base64 반환.
- `simulatorId` (선택) — 대상 시뮬레이터 UDID

**record_video**
- `path` — 저장 경로
- `duration` — 녹화 시간 (초)

**install_app**
- `path` — .app 번들 경로

**launch_app**
- `bundleId` — 앱 번들 ID (예: `com.example.app`)

**terminate_app / uninstall_app**
- `bundleId` — 대상 앱 번들 ID

**open_url**
- `url` — 열 URL (딥링크, 유니버설 링크 등)

**button**
- `name` — 버튼 이름: `home`, `lock`, `volumeUp`, `volumeDown`, `siri`

**gesture**
- `name` — 프리셋 제스처: `scrollUp`, `scrollDown`, `scrollLeft`, `scrollRight`, `pinchIn`, `pinchOut`, `rotateLeft`, `rotateRight`

### 사용 예시

```
# 시뮬레이터 목록 확인
list_simulators()

# 앱 설치 → 실행
install_app(path: "/path/to/MyApp.app")
launch_app(bundleId: "com.example.myapp")

# 스크린샷 저장
screenshot(path: "/tmp/current-screen.png")

# 비디오 녹화 (10초)
record_video(path: "/tmp/demo.mp4", duration: 10)

# 홈 버튼
button(name: "home")

# 핀치 줌 인
gesture(name: "pinchOut")

# 딥링크 열기
open_url(url: "myapp://settings/profile")
```

---

## macOS System (8개)

| 도구 | 설명 |
|------|------|
| `list_apps` | 설치된 앱 목록 |
| `menu_action` | 메뉴 바 액션 실행 |
| `get_focused_app` | 현재 포커스 앱 정보 |
| `list_windows` | 윈도우 목록 |
| `activate_app` | 앱 활성화/포커스 |
| `screenshot_app` | 앱 윈도우 스크린샷 |
| `right_click` | 우클릭 |
| `clipboard` | 클립보드 읽기/쓰기 |

### 주요 파라미터

**list_apps**
- 파라미터 없음. 실행 중인 앱 목록 반환.

**activate_app**
- `bundleId` — 활성화할 앱 (예: `com.apple.Safari`)

**get_focused_app**
- 파라미터 없음. 현재 포그라운드 앱 정보 반환.

**list_windows**
- `bundleId` (선택) — 특정 앱의 윈도우만 조회

**menu_action**
- `app` — 대상 앱 이름 (예: `"Safari"`)
- `menuPath` — 메뉴 경로 배열 (예: `["File", "Save As..."]`)

**screenshot_app**
- `bundleId` — 대상 앱
- `windowId` (선택) — 특정 윈도우 캡처
- `path` (선택) — 저장 경로

**right_click**
- `selector` — 우클릭 대상 (셀렉터 또는 좌표)
- `appBundleId` (선택) — 대상 앱

**clipboard**
- `action` — `read` 또는 `write`
- `text` (write 시) — 클립보드에 저장할 텍스트

### 사용 예시

```
# 현재 포커스 앱 확인
get_focused_app()

# Safari 활성화
activate_app(bundleId: "com.apple.Safari")

# Finder에서 "새 폴더" 메뉴 실행
menu_action(app: "Finder", menuPath: ["File", "New Folder"])

# 앱 윈도우 스크린샷
screenshot_app(bundleId: "com.apple.Safari", path: "/tmp/safari.png")

# 클립보드에 텍스트 복사
clipboard(action: "write", text: "복사할 텍스트")

# 클립보드 읽기
clipboard(action: "read")
```

---

## Workflow (1개)

| 도구 | 설명 |
|------|------|
| `run_steps` | 멀티스텝 워크플로우 실행 |

### 주요 파라미터

**run_steps**
- `steps` — 실행할 단계 배열. 각 단계는 `action` 필드와 해당 도구의 파라미터를 포함.
- `continueOnError` (선택, 기본값 `false`) — `true`면 실패한 단계를 건너뛰고 계속 진행

### 사용 예시

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

## Utility (3개)

| 도구 | 설명 |
|------|------|
| `baepsae_help` | 도움말 (도구 목록, 사용법) |
| `baepsae_version` | 현재 설치된 버전 정보 |
| `doctor` | 환경 진단 (Xcode CLI, 시뮬레이터, 접근성 권한 등) |

### 사용 예시

```
# 환경 진단
doctor()

# 버전 확인
baepsae_version()
```

---

## iOS vs macOS 주요 차이

| 기능 | iOS Simulator | macOS 앱 |
|------|--------------|---------|
| 앱 설치/삭제 | `install_app` / `uninstall_app` | 불가 (시스템 앱 관리) |
| 앱 실행 | `launch_app` | `activate_app` |
| 하드웨어 버튼 | `button` (home, lock 등) | 해당 없음 |
| 제스처 | `gesture` (pinch, rotate 등) | 해당 없음 |
| 메뉴 액션 | 해당 없음 | `menu_action` |
| 윈도우 관리 | 해당 없음 | `list_windows` |
| 우클릭 | 해당 없음 | `right_click` |
| 클립보드 | 해당 없음 | `clipboard` |
| 터치 | `touch` (좌표 기반) | 해당 없음 |
| URL 열기 | `open_url` | 해당 없음 |
| 비디오 | `record_video`, `stream_video` | 해당 없음 |

---

## axe-simulator 도구 매핑

axe-simulator 플러그인이 활성화된 환경에서의 도구 대응표입니다.

| baepsae | axe-simulator | MCP 도구명 |
|---------|--------------|-----------|
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
| `run_steps` (간이) | `axe_batch` | `mcp__plugin_axe-simulator_axe-simulator__axe_batch` |

**axe-simulator에 없는 baepsae 도구**: `query_ui`, `tap_tab`, `scroll`, `drag_drop`, `key_sequence`, `touch`, `record_video`, `stream_video`, `open_url`, `install_app`, `launch_app`, `terminate_app`, `uninstall_app`, `list_apps`, `menu_action`, `get_focused_app`, `list_windows`, `activate_app`, `screenshot_app`, `right_click`, `clipboard`, `run_steps` (고급), `baepsae_help`, `baepsae_version`, `doctor`
