---
name: os-log
description: iOS/watchOS/macOS 디버그 앱의 os_log 확인 — 실시간 스트리밍, 저장된 로그 조회, 디바이스 목록. "os_log", "로그 확인", "log stream", "log show", "디바이스 로그", "앱 로그", "os log", "콘솔 로그", "실시간 로그", "로그 스트리밍", "디버그 로그", "시뮬레이터 로그" 요청 시 활성화
argument-hint: "[stream|show|devices] [필터 옵션]"
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

iOS/watchOS/macOS에서 실행 중인 디버그 앱의 os_log를 확인하는 Swift CLI 도구.
macOS `log` 명령을 래핑하여 실시간 스트리밍, 저장된 로그 조회, 디바이스 목록 기능을 제공합니다.

## CLI 빌드 및 실행

os-log-cli는 Swift Package로 구성되어 있으며, 최초 사용 시 빌드가 필요합니다.

```bash
# 빌드 (최초 1회, 이후 캐시됨)
swift build --package-path plugins/app-automation/scripts/os-log-cli

# 실행
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI <subcommand> [options]
```

> **중요**: `swift run` 명령은 프로젝트 루트(`/Volumes/eyedisk/develop/oozoofrog/oozoofrog-plugins`)에서 실행하세요.

## 서브커맨드

### stream — 실시간 로그 스트리밍

`log stream`을 래핑합니다. 실행 중인 앱의 os_log를 실시간으로 수집합니다.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream [options]
```

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `--subsystem` | 서브시스템 필터 (예: `com.myapp`) | - |
| `--category` | 카테고리 필터 (예: `networking`) | - |
| `--level` | 로그 레벨 (`default`/`info`/`debug`/`error`/`fault`) | - |
| `--process` | 프로세스 이름 또는 PID | - |
| `--predicate` | NSPredicate 원문 필터 | - |
| `--device` | 디바이스 UDID | - |
| `--timeout` | 자동 종료 시간 (초) | 30 |
| `--max-lines` | 최대 수집 줄 수 | 100 |
| `--format` | 출력 형식 (`compact`/`json`/`verbose`) | `compact` |

**주의**: `--timeout`과 `--max-lines`는 Claude Bash 도구의 2분 타임아웃을 방지하기 위한 안전 장치입니다. 필요 시 값을 조절하세요.

### show — 저장된 로그 조회

`log show`를 래핑합니다. 과거 로그를 검색·필터링합니다.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show [options]
```

| 옵션 | 설명 | 예시 |
|------|------|------|
| `--last` | 최근 기간 | `5m`, `1h`, `2d` |
| `--start` | 시작 시각 (ISO8601) | `2024-01-01T00:00:00` |
| `--end` | 종료 시각 (ISO8601) | `2024-01-01T01:00:00` |

> `--last`와 `--start`/`--end`는 동시 사용 불가.

공통 필터 옵션(`--subsystem`, `--category`, `--level`, `--process`, `--predicate`, `--device`, `--format`)도 사용 가능.

### devices — 디바이스 목록

부팅된 시뮬레이터와 USB 연결 실제 디바이스를 통합 표시합니다.

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI devices [--json]
```

`--json` 플래그로 JSON 배열 출력 가능.

## 사용 패턴

### 패턴 1: 특정 앱의 실시간 로그

사용자가 앱 이름이나 Bundle ID를 알려주면:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream \
  --subsystem com.example.myapp --timeout 10 --max-lines 50
```

### 패턴 2: 에러 로그 사후 분석

크래시나 오류 발생 후:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 5m --level error --format verbose
```

### 패턴 3: 고급 predicate 검색

NSPredicate 문법으로 세밀한 필터링:

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 1h --predicate 'subsystem == "com.myapp" AND eventMessage CONTAINS "network"'
```

### 패턴 4: 디바이스 확인 후 특정 디바이스 로그

```bash
# 1. 디바이스 목록 확인
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI devices

# 2. 특정 디바이스의 로그 스트리밍
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI stream \
  --device <UDID> --subsystem com.myapp
```

### 패턴 5: JSON 출력으로 파이프라인 연결

```bash
swift run --package-path plugins/app-automation/scripts/os-log-cli OSLogCLI show \
  --last 1m --format json | python3 -m json.tool
```

## 규칙

1. `stream` 사용 시 반드시 `--timeout`과 `--max-lines`를 적절히 설정 — Bash 도구의 2분 타임아웃 방지
2. 사용자가 서브시스템을 모르면 먼저 짧은 `stream --timeout 5 --max-lines 20`으로 어떤 서브시스템이 활성화되어 있는지 파악
3. `--format json`은 구조화된 분석에 적합하고, `--format verbose`는 상세 디버깅에 적합
4. `devices` 결과에서 `--device` 옵션에 UDID를 복사하여 특정 디바이스 대상 로그 확인 가능
5. `--predicate`를 사용할 때는 NSPredicate 문법을 정확히 지켜야 함 — 잘못된 구문은 에러 반환
