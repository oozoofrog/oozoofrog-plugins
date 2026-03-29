import Testing
import Foundation
@testable import OSLogCLICore

@Suite("ShowCommand 유닛 테스트")
struct ShowCommandTests {

    // MARK: - 시나리오 3: show --last 1h → 올바른 log 인자 전달

    @Test("--last 1h 설정 시 log show --last 1h 인자 전달")
    func lastOptionPassedToLogShow() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "", error: "", exitCode: 0)

        var command = ShowCommand.testInstance(last: "1h")
        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastRunExecutable == "/usr/bin/log")
        #expect(mock.lastRunArguments.contains("show"))
        #expect(mock.lastRunArguments.contains("--last"))
        let idx = mock.lastRunArguments.firstIndex(of: "--last")
        if let idx {
            #expect(mock.lastRunArguments[mock.lastRunArguments.index(after: idx)] == "1h")
        }
    }

    // MARK: - 시나리오 4: show --start/--end 검증

    @Test("--start와 --end 설정 시 올바른 인자 전달")
    func startEndOptionsPassedToLogShow() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "", error: "", exitCode: 0)

        var command = ShowCommand.testInstance(start: "2024-01-01T00:00:00", end: "2024-01-01T01:00:00")
        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastRunArguments.contains("--start"))
        #expect(mock.lastRunArguments.contains("--end"))

        let startIdx = mock.lastRunArguments.firstIndex(of: "--start")
        if let startIdx {
            #expect(mock.lastRunArguments[mock.lastRunArguments.index(after: startIdx)] == "2024-01-01T00:00:00")
        }

        let endIdx = mock.lastRunArguments.firstIndex(of: "--end")
        if let endIdx {
            #expect(mock.lastRunArguments[mock.lastRunArguments.index(after: endIdx)] == "2024-01-01T01:00:00")
        }
    }

    @Test("--start만 설정 시 --end 없이 인자 전달")
    func startOnlyWithoutEnd() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "", error: "", exitCode: 0)

        var command = ShowCommand.testInstance(start: "2024-01-01T00:00:00")
        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastRunArguments.contains("--start"))
        #expect(!mock.lastRunArguments.contains("--end"))
    }

    // MARK: - 시나리오 5: --last와 --start 동시 사용 시 ValidationError

    @Test("--last와 --start 동시 사용 시 ValidationError")
    func lastAndStartMutuallyExclusiveThrowsError() {
        var command = ShowCommand.testInstance(last: "1h", start: "2024-01-01T00:00:00")

        #expect(throws: (any Error).self) {
            try command.validate()
        }
    }

    @Test("--last와 --end 동시 사용 시 ValidationError")
    func lastAndEndMutuallyExclusiveThrowsError() {
        var command = ShowCommand.testInstance(last: "30m", end: "2024-01-01T01:00:00")

        #expect(throws: (any Error).self) {
            try command.validate()
        }
    }

    @Test("--last만 설정 시 ValidationError 없음")
    func lastOnlyNoValidationError() throws {
        var command = ShowCommand.testInstance(last: "2h")
        try command.validate()
    }

    @Test("--start와 --end만 설정 시 ValidationError 없음")
    func startEndOnlyNoValidationError() throws {
        var command = ShowCommand.testInstance(start: "2024-01-01T00:00:00", end: "2024-01-01T01:00:00")
        try command.validate()
    }

    @Test("모든 옵션 nil 시 ValidationError 없음")
    func allOptionsNilNoValidationError() throws {
        var command = ShowCommand.testInstance()
        try command.validate()
    }

    // MARK: - 기타 검증

    @Test("show 명령이 /usr/bin/log를 실행함")
    func showCommandUsesCorrectExecutable() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "", error: "", exitCode: 0)

        var command = ShowCommand.testInstance()
        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastRunExecutable == "/usr/bin/log")
        #expect(mock.lastRunArguments.first == "show")
    }

    @Test("출력 라인 파싱 및 포맷 처리")
    func outputLinesAreParsedAndFormatted() throws {
        let mockOutput = "2024-01-15 10:23:45.000000+0900 MyApp[1234:5678] <Warning>: test message"
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: mockOutput, error: "", exitCode: 0)

        var command = ShowCommand.testInstance(format: .compact)
        try command.runWithRunner(mock, filterValues: LogFilterValues())
    }

    @Test("stderr 출력이 있으면 에러 스트림에 전달")
    func stderrOutputForwarded() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "", error: "some error", exitCode: 1)

        let command = ShowCommand.testInstance()
        try command.runWithRunner(mock, filterValues: LogFilterValues())
    }

    @Test("파싱 불가 비공백 라인은 그대로 출력")
    func unparsableNonEmptyLinePassedThrough() throws {
        let mock = MockProcessRunner()
        mock.runResult = ProcessResult(output: "not a log line\nanother non-log line", error: "", exitCode: 0)

        let command = ShowCommand.testInstance()
        try command.runWithRunner(mock, filterValues: LogFilterValues())
    }
}

// MARK: - 테스트 헬퍼

extension ShowCommand {
    /// ArgumentParser property wrapper를 우회하여 테스트용 인스턴스 생성
    static func testInstance(
        last: String? = nil,
        start: String? = nil,
        end: String? = nil,
        format: OutputStyle = .compact
    ) -> ShowCommand {
        var command = ShowCommand()
        command.last = last
        command.start = start
        command.end = end
        command.format = format
        return command
    }
}
