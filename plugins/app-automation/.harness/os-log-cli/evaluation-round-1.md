# Evaluation Round 1/3

## 메타 정보
- 평가 시각: 2026-03-28
- 검증 도구: static (빌드 + 테스트 실행 + 커버리지 측정)
- 시뮬레이터: N/A (CLI 도구)
- 보조 도구: swift build, swift test --enable-code-coverage, xcrun llvm-cov report
- 커버리지 실측: TOTAL 79.15% (목표: 100%)

---

## 기능별 상세 평가

### F001: Swift Package 구조 생성

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 8/10 | `swift build` Build complete!, `swift test --list-tests` 정상. swift-tools-version: 6.0, .macOS(.v13), swift-argument-parser 1.7.1 모두 확인. 단, 실행 타겟명이 spec의 "OSLogCLI"가 아닌 "OSLogCLI + OSLogCLICore"로 2-tier 분리. 기능적으로는 동일하게 동작하나 spec 명세(OSLogCLI 단일 실행 타겟)와 구조 불일치. |
| 코드 품질 | 9/10 | Package.swift 구조 명확. OSLogCLICore(라이브러리) + OSLogCLIMain(실행) 분리는 테스트 가능성을 위한 합리적 결정. common-mistakes.md 해당 항목 없음. |
| UI 품질 | 9/10 | CLI 도구이므로 UI 항목 해당 없음. 디렉토리 구조 명확 (Sources/OSLogCLICore, Sources/OSLogCLIMain, Tests/OSLogCLITests). |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **8.7** | **PASS** (정적 모드 재분배: 기능완성×0.40 + 코드품질×0.30 + UI품질×0.30 = 3.2+2.7+2.7) |

**발견 사항:**
- Package.swift의 실행 타겟명이 "OSLogCLI"가 아닌 "OSLogCLIMain"으로 선언됨. spec과 명칭 불일치이나 바이너리는 정상 생성.

**수정 지침:** 수정 불필요 (기능적 동등성 확인됨).

---

### F002: LogFilter.swift 구현

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 8/10 | `@OptionGroup` 선언(LogFilter) + `buildArguments()` 순수 함수 구현 확인. subsystem+category AND 조합, --predicate 우선, --level 5종, --device 인자 모두 정상. 단, 테스트는 `LogFilterValues`(순수 구조체)를 직접 사용하며 `LogFilter.toValues()` 자체는 커버되지 않음(미커버 10라인). |
| 코드 품질 | 9/10 | `LogFilterValues: Sendable` + `LogFilter: ParsableArguments, Sendable` 분리 설계는 Swift 6.3 strict concurrency에 대응하는 패턴. force unwrap 없음. |
| UI 품질 | 8/10 | --help 출력에서 모든 옵션 설명 명확. CLI UX 적절. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **8.3** | **PASS** |

**발견 사항:**
- LogFilter.swift:70-79 — `toValues()` 메서드가 테스트에서 호출되지 않음. 커버리지 80%. F008(LogFilterTests)이 `LogFilterValues`를 직접 생성하여 `toValues()`를 우회함.

**수정 지침:**
1. `Tests/OSLogCLITests/LogFilterTests.swift` — `LogFilter.toValues()` 호출 경로를 검증하는 @Test 케이스 1개 추가. 예: `LogFilter` 인스턴스의 `toValues()` 호출 후 반환된 `LogFilterValues`의 각 필드 검증.

---

### F003: OutputFormatter.swift 구현

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 9/10 | `LogEntry`, `OutputStyle`, `parse()`, `format()` 모두 존재. 정상 라인 파싱 확인, nil 반환 케이스 처리, compact/json/verbose 세 스타일 정상 동작. json 포맷은 `JSONSerialization`으로 유효한 JSON 직렬화. subsystem/category nil 방어 처리 완료. |
| 코드 품질 | 9/10 | force unwrap 없음. 정규표현식을 `static let`으로 한 번만 컴파일. `formatJSON` 실패 시 에러 JSON 반환(크래시 없음). |
| UI 품질 | 9/10 | compact/json/verbose 포맷 모두 명확한 구조. compact의 `|` 구분자 일관성. verbose의 레이블-값 정렬. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **9.0** | **PASS** |

**발견 사항:**
- OutputFormatter.swift:2라인 미커버 (98.26% 라인 커버리지). 미커버 라인: `subsystem 있고 category nil` 경로의 `formatVerbose` 내 category 삽입 라인. 실질적으로 무해하나 100% 달성 불완전.

**수정 지침:**
1. `Tests/OSLogCLITests/OutputFormatterTests.swift` — subsystem 있고 category nil인 LogEntry의 verbose 포맷에서 `Category` 레이블이 없음을 명시적으로 검증하는 케이스 강화.

---

### F004: StreamCommand.swift 구현

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 7/10 | `--timeout`, `--max-lines`, `--format`, `@OptionGroup filter` 모두 존재. `--help` 출력 정상. validate()에서 0 값 방어. `runWithRunner()` 주입 구조로 테스트 가능. 단, `run()` 자체(StreamCommand.swift:30-32)가 미커버 — `SystemProcessRunner()`를 직접 사용하는 경로가 테스트되지 않음. |
| 코드 품질 | 8/10 | `ProcessRunner` 프로토콜 주입 설계로 의존성 역전 달성. force unwrap 없음. `@Sendable` 클로저 적용. 단, `run()` 메서드가 테스트 불가능한 SystemProcessRunner() 직접 생성 경로를 감춤 — 설계는 올바르나 커버리지 불완전. |
| UI 품질 | 8/10 | --help 출력에 모든 옵션 표시, 기본값 명시됨. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **7.7** | **PASS** |

**발견 사항:**
- StreamCommand.swift:30-32 — `mutating func run()` 미커버. 실제 `log stream` 실행 경로 테스트 없음.
- StreamCommand.swift:49 — `else if !line.trimmingCharacters(in: .whitespaces).isEmpty` 분기 미커버. 파싱 실패한 비어있지 않은 라인을 그대로 출력하는 경로.
- StreamCommand.swift:54-56 — `result.error` 비어있지 않을 때 stderr 출력 경로 미커버.

**수정 지침:**
1. `Tests/OSLogCLITests/StreamCommandTests.swift` — Mock에서 파싱 불가한 비공백 라인(예: "Filtering the log data using...")을 포함하는 케이스 추가하여 L49 분기 커버.
2. `Tests/OSLogCLITests/StreamCommandTests.swift` — `MockProcessRunner.streamExitCode`와 에러 메시지를 설정하여 L54-56 stderr 분기 커버.
3. `run()` 자체는 IntegrationTests에서 실제 `log stream` 호출로 커버 가능.

---

### F005: ShowCommand.swift 구현

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 7/10 | `--last`, `--start`, `--end`, `--format`, `validate()` 상호 배제 로직 정상. `runWithRunner()` 주입 구조 확인. 단, `run()` 자체(ShowCommand.swift:31-33)가 미커버. |
| 코드 품질 | 8/10 | 구조는 StreamCommand와 동일하게 견고. force unwrap 없음. --start만 있을 때 --end 없이 정상 처리. |
| UI 품질 | 8/10 | --help 출력 정상. --last, --start, --end 옵션 모두 표시. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **7.7** | **PASS** |

**발견 사항:**
- ShowCommand.swift:31-33 — `mutating func run()` 미커버.
- ShowCommand.swift:62 — `else if !line.trimmingCharacters(in: .whitespaces).isEmpty` 분기 미커버. 파싱 실패 비공백 라인 출력 경로.
- ShowCommand.swift:67-69 — stderr 출력 분기 미커버.
- ShowCommand.swift에 `--max-lines` 옵션이 없음. spec(F005)은 "run() 메서드"의 85.11% 커버리지를 언급하지 않았으나, F005 description에서 `--max-lines`를 언급하지 않으므로 미구현이 아닌 설계 선택으로 판단.

**수정 지침:**
1. `Tests/OSLogCLITests/ShowCommandTests.swift` — Mock 출력에 파싱 불가한 비공백 라인을 포함하여 L62 분기 커버.
2. `Tests/OSLogCLITests/ShowCommandTests.swift` — stderr 에러 출력 분기 검증 강화 (기존 stderrOutputForwarded 테스트가 있으나 L67-69 분기가 미커버인 이유 재확인 필요).

---

### F006: DevicesCommand.swift 구현

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 5/10 | `DeviceParser` 파싱 로직(순수 함수)은 정상. `--json` 플래그 `devices --json` 실행 시 `[]` 출력(유효 JSON). `devices` 실행 시 "No devices found." 출력 (Exit 0). `--help` 출력 정상. 단, `DevicesCommand.runWithRunner()`, `fetchSimulators()`, `fetchPhysicalDevices()`, `printTable()`, `printJSON()` 메서드 전체가 0% 미커버. 커버리지 54.95% — 구현의 절반 이상이 테스트되지 않음. |
| 코드 품질 | 6/10 | `DeviceParser`를 순수 enum으로 분리한 설계는 올바름. `printTable()`에서 `String(format:"%s")` segfault 문제를 직접 패딩으로 수정한 것은 적절. 단, `runWithRunner()` 전체가 테스트되지 않아 런타임 동작 미검증. |
| UI 품질 | 5/10 | 테이블 출력 포맷 코드(`printTable`)는 존재하나 실행 경로가 전혀 테스트되지 않음. 시뮬레이터 없는 환경에서 기본 케이스만 확인됨. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **5.3** | **PARTIAL** |

**발견 사항:**
- DevicesCommand.swift:140-232 — `runWithRunner()`, `fetchSimulators()`, `fetchPhysicalDevices()`, `printJSON()`, `printTable()` 전체 0% 커버. F010(DevicesCommandTests)이 `DeviceParser` 파싱 함수만 테스트하고 `DevicesCommand` 자체는 테스트하지 않음.
- DevicesCommand.swift:157-161 — `json == false` 일 때 "No devices found." 출력 경로 미커버.
- DevicesCommand.swift:165-169 — `json == true` 일 때 `printJSON()` 호출 경로 미커버.
- DevicesCommand.swift:174-195 — `fetchSimulators()`, `fetchPhysicalDevices()` 전체 미커버.

**수정 지침:**
1. `Tests/OSLogCLITests/DevicesCommandTests.swift` — `MockProcessRunner`를 주입하는 `DevicesCommand.runWithRunner()` 테스트 케이스 추가:
   - simctl 결과 있을 때 `printTable()` 호출 경로 커버
   - `--json` 플래그 설정 시 `printJSON()` 호출 경로 커버
   - simctl 결과 없을 때 "No devices found." 출력 경로 커버
   - `fetchPhysicalDevices()` graceful degradation 경로 커버 (exitCode != 0 케이스)

---

### F007: OSLogCLI.swift @main 루트 커맨드

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 7/10 | `swift run OSLogCLI --help` 에서 stream/show/devices 서브커맨드 모두 확인. `--version 1.0.0` 정상. 알 수 없는 서브커맨드 호출 시 에러 메시지 + Exit 64(non-zero). 서브커맨드 없이 호출 시 help 텍스트 출력. 모든 CLI 동작 정상. 단, `OSLogCLI.swift:12`의 `public init()` — 커버리지 0%. |
| 코드 품질 | 8/10 | `CommandConfiguration`으로 commandName, abstract, version, subcommands 선언. 구조 간결. |
| UI 품질 | 8/10 | --help 출력 명확, SUBCOMMANDS 섹션 정상. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **7.7** | **PASS** |

**발견 사항:**
- OSLogCLI.swift:12 — `public init() {}` 0% 커버. ArgumentParser가 `@main`으로 직접 진입점을 처리하기 때문에 테스트 바이너리에서 `OSLogCLI`의 `init()`이 호출되지 않음. 이는 구조적 문제로, `@testable import`로 직접 인스턴스 생성 테스트 케이스가 필요함.

**수정 지침:**
1. `Tests/OSLogCLITests/` — `OSLogCLITests.swift` 파일 신규 생성 또는 기존 파일에 `OSLogCLI()` 인스턴스 생성과 `configuration` 필드 검증 @Test 케이스 추가:
   ```swift
   @Test("OSLogCLI configuration 검증")
   func osloglCliConfiguration() {
       let cli = OSLogCLI()
       #expect(OSLogCLI.configuration.commandName == "os-log")
       #expect(OSLogCLI.configuration.version == "1.0.0")
       _ = cli
   }
   ```

---

### F008: LogFilterTests

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 8/10 | 14개 @Test 함수. 5가지 시나리오 + level 5종 + 추가 조합 케이스. 모든 테스트 통과. XCTest 혼용 없음(순수 Swift Testing). 단, `LogFilter.toValues()` 호출 경로 미포함 — F002 커버리지 미달의 직접 원인. |
| 코드 품질 | 8/10 | LogFilterValues 직접 생성 방식은 테스트 격리성이 좋으나 `toValues()` 경로를 우회하는 부작용. |
| UI 품질 | 8/10 | 테스트 이름이 의도를 명확히 설명. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **8.0** | **PASS** |

**발견 사항:**
- `LogFilter.toValues()` 경로를 테스트하는 케이스 없음 → LogFilter.swift 80% 커버리지의 원인.

**수정 지침:**
1. `Tests/OSLogCLITests/LogFilterTests.swift` — `LogFilter` 파싱 인스턴스의 `toValues()` 호출 테스트 1개 추가.

---

### F009: OutputFormatterTests

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 9/10 | 14개 @Test. 6가지 시나리오 모두 커버. json 포맷 `JSONSerialization`으로 구조적 검증. nil 케이스 방어 테스트 존재. XCTest 혼용 없음. |
| 코드 품질 | 9/10 | `#require`로 파싱 실패 시 테스트 자체 실패 처리 — 의도적이고 명확. |
| UI 품질 | 9/10 | 테스트 커버리지 98.26% (2라인 미커버). 사실상 완전 커버. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **9.0** | **PASS** |

---

### F010: DevicesCommandTests

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 6/10 | `DeviceParser` 파싱 로직(parseSimctlJSON, parseDevicectlOutput, parseOSFromRuntimeKey)은 테스트됨. simctl JSON 픽스처 인라인 존재, 실제 xcrun/Process 호출 없음. 단, `DevicesCommand.runWithRunner()` 자체가 테스트되지 않음 — F006 커버리지 미달의 직접 원인. |
| 코드 품질 | 8/10 | 픽스처 분리 명확. @Test 함수명 서술적. |
| UI 품질 | 7/10 | Booted/Shutdown 필터링 명시적 검증. JSON 직렬화 구조적 검증. 단, devicectl 픽스처의 UDID가 실제 UUID 형식이 아니어서 `parsesDevicectlOutput` 테스트가 실제로 파싱 성공 경로를 커버하지 못함 — 테스트가 `#expect(devices.count >= 0)`으로 모호하게 작성됨. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **7.0** | **PASS** |

**발견 사항:**
- DevicesCommandTests.swift:100-104 — `parsesDevicectlOutput` 테스트의 픽스처 UDID("00000000-0000000000000000")가 `NSRegularExpression`의 UUID 패턴(`^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}$`)에 매칭되지 않음. 실제 파싱 성공 경로 미검증.
- `DevicesCommand.runWithRunner()` 테스트 부재 — F006의 54.95% 커버리지 원인.

**수정 지침:**
1. `Tests/OSLogCLITests/DevicesCommandTests.swift` — devicectl 픽스처의 UDID를 올바른 형식(`00000000-000000000000`)으로 수정하고 파싱 성공 케이스를 명시적으로 검증.
2. `DevicesCommand.runWithRunner(MockProcessRunner())` 테스트 케이스 추가 (F006 수정 지침과 동일).

---

### F011: StreamCommand + ShowCommand 유닛 테스트

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 7/10 | `ProcessRunner` 프로토콜 Sources/에 정의, `MockProcessRunner` Tests/에 정의. 실제 Process() 직접 생성 없음. 5가지 시나리오 대부분 존재. timeout 시나리오는 Mock으로 즉시 종료 시뮬레이션. 단, StreamCommand의 `result.error` stderr 분기와 파싱 실패 비공백 라인 분기 미커버. ShowCommand의 `run()` 자체 미커버. |
| 코드 품질 | 8/10 | MockProcessRunner 설계 깔끔. `testInstance()` 헬퍼로 ArgumentParser property wrapper 우회 패턴 적절. ShowCommandTests에서 `var command`가 불필요하게 선언됨 — 컴파일러 경고 6건 발생 (`let`으로 변경 필요). |
| UI 품질 | 8/10 | 테스트 의도 명확. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **7.7** | **PASS** |

**발견 사항:**
- ShowCommandTests.swift:15, 34, 56, 108, 121, 130 — `var command`가 `let`이어야 함. 컴파일러 경고 6건 발생.
- StreamCommandTests.swift:25, 41, 53, 68 — `var command`가 `let`이어야 함. 컴파일러 경고 4건 발생.
- 이 경고들이 Swift 6 strict concurrency 환경에서는 오류로 승격될 수 있음.

**수정 지침:**
1. `Tests/OSLogCLITests/ShowCommandTests.swift` — `var command`를 `let command`로 교체 (6곳).
2. `Tests/OSLogCLITests/StreamCommandTests.swift` — `var command`를 `let command`로 교체 (4곳).

---

### F012: 통합 테스트 (IntegrationTests)

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 8/10 | `#if os(macOS)` 조건부 컴파일 확인. `/usr/bin/log` 존재 확인. log show --last 1s 실제 실행 성공. log stream --timeout 2 실행 후 5초 이내 종료(실측 1.388초). 잘못된 predicate 에러 캡처. xcrun simctl 실행 확인. 모든 4개 통합 테스트 통과. |
| 코드 품질 | 8/10 | `guard FileManager.default.fileExists` 방어 패턴. 실행 시간 여유 범위(5초) 설정. |
| UI 품질 | 8/10 | 실제 시스템 동작 검증. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **8.0** | **PASS** |

---

### F013: 전체 코드 커버리지 100% 검증

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 1/10 | **커버리지 79.15% — 핵심 요구사항 미달. FAIL 기준.** coverage-report.txt 파일은 존재하나 TOTAL이 100%가 아님. 개별 파일 상황: OSLogCLI.swift 0%, DevicesCommand.swift 54.95%, LogFilter.swift 80.00%, StreamCommand.swift 85.11%, ShowCommand.swift 89.58%. ProcessRunner.swift 90.29%. OutputFormatter.swift 98.26%만 허용 가능 수준. |
| 코드 품질 | 2/10 | 커버리지 미달 원인이 테스트 설계 누락(DevicesCommand.runWithRunner 미테스트, OSLogCLI.init 미테스트, run() 메서드 미커버)으로 구조적 문제. |
| UI 품질 | 1/10 | coverage-report.txt에 79.15%가 기록됨 — 100% 목표 달성 실패를 문서화. |
| 인터랙션 품질 | 0/10 | 정적 모드 — 면제 |
| **가중 평균** | **1.3** | **FAIL** |

**발견 사항 (파일별 미커버 요약):**

| 파일 | 라인 커버리지 | 주요 미커버 영역 |
|------|-------------|----------------|
| OSLogCLI.swift | 0% | `public init()` (L12) — 전체 1라인 미커버 |
| DevicesCommand.swift | 54.95% | `runWithRunner()` (L145-170), `fetchSimulators()` (L174-182), `fetchPhysicalDevices()` (L184-195), `printJSON()` (L197-204), `printTable()` (L206-231) 전체 미커버 |
| LogFilter.swift | 80.00% | `toValues()` (L70-79) 미커버 |
| StreamCommand.swift | 85.11% | `run()` (L30-32), 파싱실패 비공백 분기 (L49), stderr 분기 (L54-56) |
| ShowCommand.swift | 89.58% | `run()` (L31-33), 파싱실패 비공백 분기 (L62), stderr 분기 (L67-69) |
| OutputFormatter.swift | 98.26% | formatVerbose의 category 삽입 분기 2라인 |
| ProcessRunner.swift | 90.29% | LineCollector.flush() (L39-48), SystemProcessRunner 일부 경계 분기 |

**수정 지침 (우선순위 순):**
1. **[최우선] DevicesCommand 테스트 확장** — `DevicesCommandTests.swift`에 `runWithRunner(MockProcessRunner())` 케이스 추가. 예상 커버리지 개선: 54.95% → ~90%
2. **[우선] OSLogCLI.init 테스트** — `OSLogCLI()` 인스턴스 생성 @Test 추가. 0% → 100%
3. **[보통] LogFilter.toValues() 테스트** — `LogFilter` 파싱 인스턴스의 `toValues()` 호출 경로 커버
4. **[보통] StreamCommand/ShowCommand run() 및 분기 커버** — 실제 `log stream/show` 통합 테스트 또는 Mock으로 추가 분기 커버
5. **[낮음] LineCollector.flush() 커버** — `ProcessRunner.swift`의 flush() 경로 테스트

---

## 종합 결과

| ID | 기능 | 기능완성 | 코드품질 | UI품질 | 인터랙션 | 가중평균 | 판정 |
|----|------|---------|---------|--------|---------|---------|------|
| F001 | Swift Package 구조 | 8 | 9 | 9 | - | 8.7 | PASS |
| F002 | LogFilter.swift | 8 | 9 | 8 | - | 8.3 | PASS |
| F003 | OutputFormatter.swift | 9 | 9 | 9 | - | 9.0 | PASS |
| F004 | StreamCommand.swift | 7 | 8 | 8 | - | 7.7 | PASS |
| F005 | ShowCommand.swift | 7 | 8 | 8 | - | 7.7 | PASS |
| F006 | DevicesCommand.swift | 5 | 6 | 5 | - | 5.3 | PARTIAL |
| F007 | OSLogCLI.swift @main | 7 | 8 | 8 | - | 7.7 | PASS |
| F008 | LogFilterTests | 8 | 8 | 8 | - | 8.0 | PASS |
| F009 | OutputFormatterTests | 9 | 9 | 9 | - | 9.0 | PASS |
| F010 | DevicesCommandTests | 6 | 8 | 7 | - | 6.9 | PARTIAL |
| F011 | Stream/ShowCommand 테스트 | 7 | 8 | 8 | - | 7.7 | PASS |
| F012 | 통합 테스트 | 8 | 8 | 8 | - | 8.0 | PASS |
| F013 | 커버리지 100% 검증 | 1 | 2 | 1 | - | 1.3 | **FAIL** |

PASS: 11/13 (84.6%)
PARTIAL: 2/13 (F006, F010)
FAIL: 1/13 (F013)

## 판정: NEED_REVISION

PASS 기준(80%)은 수치상 충족(84.6%)이나, **F013은 핵심 요구사항("테스트 커버리지 100% 필수")의 직접 위반**이므로 NEED_REVISION으로 판정합니다.
오케스트레이터 지시에 따라 F013 FAIL은 전체 판정을 NEED_REVISION으로 강제합니다.

### Builder에게 전달할 수정 항목 (우선순위 순)

1. **[F013/F006 — 필수]** `DevicesCommandTests.swift` — `DevicesCommand.runWithRunner(MockProcessRunner())` 테스트 케이스 추가 (simctlDevices 있는 경우/없는 경우/json 플래그 각각)
2. **[F013/F007 — 필수]** `OSLogCLI` 인스턴스 생성 및 configuration 검증 @Test 케이스 추가
3. **[F013/F002/F008 — 필수]** `LogFilter.toValues()` 호출 경로 커버 @Test 추가
4. **[F013/F004 — 필수]** StreamCommand.swift L49, L54-56 분기 커버 테스트 추가
5. **[F013/F005 — 필수]** ShowCommand.swift L62, L67-69 분기 커버 테스트 추가
6. **[F011 — 권장]** ShowCommandTests.swift + StreamCommandTests.swift의 `var command` → `let command` 경고 수정 (10곳)
7. **[F010 — 권장]** devicectl 픽스처 UDID를 실제 UUID 형식으로 수정하여 파싱 성공 경로 검증
