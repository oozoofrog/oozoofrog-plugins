# 제품 스펙: os-log-cli

## 개요

iOS/watchOS Simulator, macOS 앱, 실제 디바이스(USB)에서 실행 중인 디버그 앱의 os_log를 조회·스트리밍할 수 있는 Swift CLI 도구.
`log stream` 및 `log show` 명령을 래핑하며, subsystem/category/level/process/predicate 기반 필터링과 compact/json/verbose 출력 포맷을 지원한다.
swift-argument-parser를 사용하며, 테스트 커버리지 100%가 핵심 요구사항이다.

## 대상 플랫폼

macOS (CLI 도구 자체). 로그 수집 대상: iOS Simulator, watchOS Simulator, macOS 앱, 실제 iOS/watchOS 디바이스(USB)

## 핵심 기능

1. `stream` 서브커맨드 — `log stream` 래핑, 실시간 로그 스트리밍 (--timeout 기본 30s, --max-lines 기본 100)
2. `show` 서브커맨드 — `log show` 래핑, 저장된 로그 조회 (--last, --start/--end 시간 범위)
3. `devices` 서브커맨드 — 사용 가능한 시뮬레이터(simctl) + 실제 디바이스(devicectl) 목록
4. `LogFilter` — 공통 필터 옵션(--subsystem, --category, --level, --process, --predicate, --device)을 log CLI 인자로 변환
5. `OutputFormatter` — 로그 라인 파싱 + compact/json/verbose 포맷팅
6. Swift Package 구조 — Package.swift + Sources/ 분리, swift-argument-parser 1.7.1 의존성
7. 유닛 테스트 전체 — LogFilter, OutputFormatter, DevicesCommand 파싱 로직 각각 100% 커버리지
8. 통합 테스트 — 실제 `log` 명령 실행 경로 포함, 전체 100% 커버리지

## 기술 스택

- 언어: Swift 6.3
- CLI 프레임워크: swift-argument-parser 1.7.1
- 프레임워크: Foundation (Process, Pipe, FileHandle)
- 테스트: Swift Testing (`@Test`, `#expect`)
- 빌드: `swift build`, `swift test --enable-code-coverage`
- 참조 문서: apple-craft 참조 문서 해당 없음 (순수 CLI, UIKit/SwiftUI 없음)

## 환경

- Xcode MCP: 연결됨 (`mcp__xcode__BuildProject`, `mcp__xcode__RunAllTests`, `mcp__xcode__RunSomeTests` 사용 가능)
- 검증 도구: BuildProject (SPM 타겟), RunAllTests (커버리지 포함), GetBuildLog
- 프로젝트 규칙: CLAUDE.md — commands 금지, skills/ 사용, 버전 동기화 필수
- Git 상태: clean, main 브랜치
- 시뮬레이터 자동화: mcp-baepsae 사용 가능 (devices 서브커맨드 검증 시 활용 가능)
- Swift 버전: 6.3 (arm64-apple-macosx26.0)

## 사용자 맥락

- 핵심 우선순위: 기능적 정확성 + 테스트 커버리지 100%
- 차별화 방향: 없음 (순수 CLI 도구, AI/위젯/접근성 불필요)
- 기술적 제약:
  - app-automation 플러그인의 `scripts/os-log-cli/` 하위에 위치
  - Swift Package 구조 (Package.swift + Sources/ 분리)
  - swift-argument-parser 사용 필수
  - 100% 코드 커버리지 필수
  - Swift 6.3 strict concurrency 준수
- 디자인 취향: CLI UX — 명확한 에러 메시지, --help 자동 생성 (ArgumentParser 기본 제공)

## 차별화 기능

- `devices` 서브커맨드: `xcrun simctl list devices --json` + `xcrun devicectl list devices` 통합 파싱으로 iOS/watchOS Simulator와 실제 디바이스를 단일 뷰로 제공
- `--predicate` 옵션: macOS `log` 명령의 NSPredicate 문법 그대로 노출, 고급 필터링 지원
- `--format json` 출력: 로그 라인을 구조화된 JSON 배열로 변환 — 다른 도구와 파이프라인 연결 용이
- `--max-lines` + `--timeout` 조합: CI/자동화 환경에서 스트림이 무한 대기하지 않도록 안전 장치 제공
- `LogFilter.buildArguments()` 순수 함수 설계: 외부 의존성 없이 단위 테스트 가능한 구조

## 범위 외

- SwiftUI/UIKit/AppKit GUI 없음
- 로그 영속 저장 (DB, 파일 아카이브) 없음
- Xcode 내 플러그인/익스텐션 없음
- Android/Linux 지원 없음
- 무선(Wi-Fi) 디바이스 연결 — USB(devicectl) 전용
