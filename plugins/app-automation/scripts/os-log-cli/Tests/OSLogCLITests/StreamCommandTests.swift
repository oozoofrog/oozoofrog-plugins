import Testing
import Foundation
@testable import OSLogCLICore

@Suite("StreamCommand 유닛 테스트")
struct StreamCommandTests {

    let sampleLogLines = [
        "2024-01-15 10:23:45.000000+0900 MyApp[1234:5678] <Warning>: line 1",
        "2024-01-15 10:23:46.000000+0900 MyApp[1234:5678] <Warning>: line 2",
        "2024-01-15 10:23:47.000000+0900 MyApp[1234:5678] <Warning>: line 3",
        "2024-01-15 10:23:48.000000+0900 MyApp[1234:5678] <Warning>: line 4",
        "2024-01-15 10:23:49.000000+0900 MyApp[1234:5678] <Warning>: line 5",
        "2024-01-15 10:23:50.000000+0900 MyApp[1234:5678] <Warning>: line 6",
        "2024-01-15 10:23:51.000000+0900 MyApp[1234:5678] <Warning>: line 7",
    ]

    // MARK: - 시나리오 1: stream --timeout → Mock으로 즉시 종료 시뮬레이션

    @Test("timeout 시나리오 실제 대기 없이 Mock으로 즉시 종료")
    func timeoutSimulatedWithMock() throws {
        let mock = MockProcessRunner()
        mock.streamLines = sampleLogLines

        var command = StreamCommand.testInstance(timeout: 3, maxLines: 100)

        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastStreamTimeout == 3)
        #expect(mock.lastStreamExecutable == "/usr/bin/log")
        #expect(mock.lastStreamArguments.first == "stream")
    }

    // MARK: - 시나리오 2: stream --max-lines 5 → 5줄 수집 후 종료

    @Test("max-lines 5 설정 시 5줄만 수집")
    func maxLinesLimitsOutput() throws {
        let mock = MockProcessRunner()
        mock.streamLines = sampleLogLines  // 7줄

        var command = StreamCommand.testInstance(timeout: 30, maxLines: 5)

        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastStreamMaxLines == 5)
    }

    @Test("stream 명령이 /usr/bin/log stream 인자로 실행됨")
    func streamCommandUsesCorrectExecutable() throws {
        let mock = MockProcessRunner()
        mock.streamLines = []

        var command = StreamCommand.testInstance()

        try command.runWithRunner(mock, filterValues: LogFilterValues())

        #expect(mock.lastStreamExecutable == "/usr/bin/log")
        #expect(mock.lastStreamArguments.first == "stream")
    }

    // MARK: - LogFilter 인자 전달 검증

    @Test("subsystem 필터가 stream 인자에 포함됨")
    func subsystemFilterPassedToStream() throws {
        let mock = MockProcessRunner()
        mock.streamLines = []

        var command = StreamCommand.testInstance()
        var filterValues = LogFilterValues()
        filterValues.subsystem = "com.example"
        try command.runWithRunner(mock, filterValues: filterValues)

        #expect(mock.lastStreamArguments.contains("--predicate"))
        let predicateIdx = mock.lastStreamArguments.firstIndex(of: "--predicate")
        if let idx = predicateIdx {
            #expect(mock.lastStreamArguments[mock.lastStreamArguments.index(after: idx)].contains("com.example"))
        }
    }

    // MARK: - validate 테스트

    @Test("timeout이 0이면 ValidationError 발생")
    func timeoutZeroThrowsValidationError() {
        var command = StreamCommand.testInstance(timeout: 0)

        #expect(throws: (any Error).self) {
            try command.validate()
        }
    }

    @Test("maxLines가 0이면 ValidationError 발생")
    func maxLinesZeroThrowsValidationError() {
        var command = StreamCommand.testInstance(maxLines: 0)

        #expect(throws: (any Error).self) {
            try command.validate()
        }
    }

    @Test("양수 timeout과 maxLines는 ValidationError 없음")
    func validTimeoutAndMaxLinesNoError() throws {
        var command = StreamCommand.testInstance(timeout: 10, maxLines: 50)

        try command.validate()
    }
}

// MARK: - 테스트 헬퍼

extension StreamCommand {
    /// ArgumentParser property wrapper를 우회하여 테스트용 인스턴스 생성
    static func testInstance(
        timeout: TimeInterval = 30,
        maxLines: Int = 100,
        format: OutputStyle = .compact
    ) -> StreamCommand {
        var command = StreamCommand()
        command.timeout = timeout
        command.maxLines = maxLines
        command.format = format
        return command
    }
}
