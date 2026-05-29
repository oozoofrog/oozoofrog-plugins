---
name: os-log
description: Inspect os_log from iOS/watchOS/macOS debug apps — live streaming, stored log queries, device listing. Activate on "os_log", "로그 확인", "log stream", "log show", "디바이스 로그", "앱 로그", "os log", "콘솔 로그", "실시간 로그", "로그 스트리밍", "디버그 로그", "시뮬레이터 로그".
argument-hint: "[stream|show|devices] [filter options]"
---

<example>
user: "시뮬레이터에서 실행 중인 앱의 os_log를 실시간으로 보여줘"
assistant: "os-log-cli의 stream 명령으로 시뮬레이터의 실시간 로그를 스트리밍하겠습니다."
</example>

<example>
user: "com.myapp 서브시스템의 최근 5분 로그를 확인해줘"
assistant: "os-log-cli show --last 5m --subsystem com.myapp으로 저장된 로그를 조회하겠습니다."
</example>

<example>
user: "에러 레벨 로그만 JSON 형식으로 보여줘"
assistant: "os-log-cli show --level error --format json으로 에러 로그를 구조화된 JSON으로 출력하겠습니다."
</example>

<example>
user: "연결된 디바이스/시뮬레이터 목록을 보여줘"
assistant: "os-log-cli devices로 현재 부팅된 시뮬레이터와 USB 연결 디바이스를 확인하겠습니다."
</example>

<example>
user: "네트워크 카테고리 로그를 실시간으로 스트리밍해줘"
assistant: "os-log-cli stream --subsystem com.myapp --category networking으로 네트워크 관련 로그만 필터링하여 스트리밍하겠습니다."
</example>

<example>
user: "특정 predicate로 로그를 검색해줘"
assistant: "os-log-cli show --predicate 'eventMessage CONTAINS \"error\"'로 고급 필터링을 적용하겠습니다."
</example>

# os-log

A Swift CLI tool for inspecting os_log from debug apps running on iOS/watchOS/macOS.
It wraps the macOS `log` command to provide live streaming, stored log queries, and device listing.

Respond to the user in Korean.

## Build and run the CLI

os-log-cli is a Swift Package and needs to be built on first use.

```bash
# Build (first time only, cached afterward)
swift build --package-path plugins/app-automation/scripts/os-log-cli

# Run
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI <subcommand> [options]
```

> Run `swift run` from the project root (`/Volumes/eyedisk/develop/oozoofrog/oozoofrog-plugins`), since `--package-path` is resolved relative to it.

## Subcommands

### stream — live log streaming

Wraps `log stream`. Collects os_log from a running app in real time.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream [options]
```

| Option | Description | Default |
|------|------|--------|
| `--subsystem` | Subsystem filter (e.g. `com.myapp`) | - |
| `--category` | Category filter (e.g. `networking`) | - |
| `--level` | Log level (`default`/`info`/`debug`/`error`/`fault`) | - |
| `--process` | Process name or PID | - |
| `--predicate` | Raw NSPredicate filter | - |
| `--device` | Device UDID | - |
| `--timeout` | Auto-terminate time (seconds) | 30 |
| `--max-lines` | Maximum number of lines to collect | 100 |
| `--format` | Output format (`compact`/`json`/`verbose`) | `compact` |

`--timeout` and `--max-lines` guard against Claude's 2-minute Bash tool timeout. Adjust them as needed.

### show — query stored logs

Wraps `log show`. Searches and filters past logs.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show [options]
```

| Option | Description | Example |
|------|------|------|
| `--last` | Recent time window | `5m`, `1h`, `2d` |
| `--start` | Start time (ISO8601) | `2024-01-01T00:00:00` |
| `--end` | End time (ISO8601) | `2024-01-01T01:00:00` |

> `--last` and `--start`/`--end` cannot be used together.

The shared filter options (`--subsystem`, `--category`, `--level`, `--process`, `--predicate`, `--device`, `--format`) are also available.

### devices — list devices

Shows booted simulators and USB-connected physical devices together.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI devices [--json]
```

The `--json` flag outputs a JSON array.

## Usage patterns

### Pattern 1: live logs for a specific app

When the user gives an app name or Bundle ID:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream \
  --subsystem com.example.myapp --timeout 10 --max-lines 50
```

### Pattern 2: post-mortem error analysis

After a crash or error:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 5m --level error --format verbose
```

### Pattern 3: advanced predicate search

Fine-grained filtering with NSPredicate syntax:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 1h --predicate 'subsystem == "com.myapp" AND eventMessage CONTAINS "network"'
```

### Pattern 4: identify a device, then stream its logs

```bash
# 1. List devices
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI devices

# 2. Stream logs for a specific device
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream \
  --device <UDID> --subsystem com.myapp
```

### Pattern 5: pipe JSON output into a pipeline

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 1m --format json | python3 -m json.tool
```

## Rules

1. For `stream`, set `--timeout` and `--max-lines` to reasonable values so the Bash tool's 2-minute timeout is not hit.
2. If the user doesn't know the subsystem, start with a short `stream --timeout 5 --max-lines 20` to discover which subsystems are active.
3. `--format json` suits structured analysis; `--format verbose` suits detailed debugging.
4. Copy a UDID from the `devices` output into `--device` to target logs at a specific device.
5. `--predicate` follows NSPredicate syntax exactly — invalid syntax returns an error.
