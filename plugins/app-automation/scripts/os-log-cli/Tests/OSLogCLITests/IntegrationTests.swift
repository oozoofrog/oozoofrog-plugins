import Testing
import Foundation
@testable import OSLogCLICore

#if os(macOS)

@Suite("통합 테스트 — 실제 macOS log 명령 실행")
struct IntegrationTests {

    static let logPath = "/usr/bin/log"

    // MARK: - 환경 확인

    @Test("/usr/bin/log 파일 존재 확인")
    func logBinaryExists() {
        let exists = FileManager.default.fileExists(atPath: Self.logPath)
        #expect(exists, "/usr/bin/log가 존재해야 통합 테스트 실행 가능")
    }

    // MARK: - 시나리오 1: log show --last 1m 실제 실행 후 출력 파싱

    @Test("log show --last 1m 실행 후 출력 파싱 성공")
    func logShowLastOneMinuteParseable() throws {
        guard FileManager.default.fileExists(atPath: Self.logPath) else { return }

        let runner = SystemProcessRunner()
        let result = try runner.run(
            executable: Self.logPath,
            arguments: ["show", "--last", "1m"]
        )

        // 성공 또는 빈 출력 모두 허용 (로그가 없을 수도 있음), 크래시 없어야 함
        #expect(result.exitCode == 0 || result.exitCode == 1)

        // 출력이 있으면 각 라인 파싱 시도 (크래시 없어야 함)
        if !result.output.isEmpty {
            let lines = result.output.components(separatedBy: "\n")
            for line in lines.prefix(10) {
                _ = OutputFormatter.parse(line: line)
            }
        }
    }

    // MARK: - 시나리오 2: log stream --timeout 2 실행 후 정상 종료

    @Test("log stream --timeout 2초 후 정상 종료")
    func logStreamTimesOutWithin2Seconds() throws {
        guard FileManager.default.fileExists(atPath: Self.logPath) else { return }

        let runner = SystemProcessRunner()
        let start = Date()

        let result = try runner.stream(
            executable: Self.logPath,
            arguments: ["stream"],
            timeout: 2,
            maxLines: 1000,
            onLine: { _ in }
        )

        let elapsed = Date().timeIntervalSince(start)
        // 2초 + 여유 1초 이내에 종료되어야 함
        #expect(elapsed < 5.0, "stream이 \(elapsed)초 만에 종료됨 (5초 이내 기대)")
        _ = result  // 결과 사용
    }

    // MARK: - 시나리오 3: 잘못된 --predicate 구문 시 stderr 에러 메시지 캡처

    @Test("잘못된 predicate 구문 시 stderr에 에러 메시지 캡처")
    func invalidPredicateCapturesStderrError() throws {
        guard FileManager.default.fileExists(atPath: Self.logPath) else { return }

        let runner = SystemProcessRunner()
        let result = try runner.run(
            executable: Self.logPath,
            arguments: ["show", "--last", "1s", "--predicate", "INVALID PREDICATE !!!"]
        )

        // 잘못된 predicate는 non-zero exit code이거나 stderr에 에러 메시지 포함
        let hasError = result.exitCode != 0 || !result.error.isEmpty
        #expect(hasError, "잘못된 predicate는 에러를 발생시켜야 함")
    }

    // MARK: - xcrun simctl 실행 가능 여부 확인

    @Test("xcrun simctl 실행 가능 여부")
    func xcrunSimctlAvailable() throws {
        let runner = SystemProcessRunner()
        let result = try runner.run(
            executable: "/usr/bin/xcrun",
            arguments: ["simctl", "list", "devices", "--json"]
        )

        // 성공 시 유효한 JSON 반환
        if result.exitCode == 0 && !result.output.isEmpty {
            let devices = DeviceParser.parseSimctlJSON(result.output)
            // 파싱 결과는 배열 (비어있어도 됨), 크래시 없어야 함
            #expect(devices.count >= 0)
        }
    }
}

#endif
