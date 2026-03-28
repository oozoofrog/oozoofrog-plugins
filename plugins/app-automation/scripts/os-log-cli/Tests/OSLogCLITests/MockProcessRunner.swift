import Foundation
@testable import OSLogCLICore

/// 테스트에서 실제 Process 실행 없이 미리 정의된 출력을 주입하는 Mock
final class MockProcessRunner: ProcessRunner, @unchecked Sendable {
    /// run() 호출 시 반환할 결과
    var runResult: ProcessResult = ProcessResult(output: "", error: "", exitCode: 0)

    /// stream() 호출 시 onLine 핸들러에 전달할 라인 목록
    var streamLines: [String] = []

    /// stream() 호출 시 반환할 종료 코드
    var streamExitCode: Int32 = 0

    /// 마지막으로 run()에 전달된 인자 기록
    var lastRunExecutable: String = ""
    var lastRunArguments: [String] = []

    /// 마지막으로 stream()에 전달된 인자 기록
    var lastStreamExecutable: String = ""
    var lastStreamArguments: [String] = []
    var lastStreamTimeout: TimeInterval = 0
    var lastStreamMaxLines: Int = 0

    func run(
        executable: String,
        arguments: [String]
    ) throws -> ProcessResult {
        lastRunExecutable = executable
        lastRunArguments = arguments
        return runResult
    }

    func stream(
        executable: String,
        arguments: [String],
        timeout: TimeInterval,
        maxLines: Int,
        onLine: @Sendable (String) -> Void
    ) throws -> ProcessResult {
        lastStreamExecutable = executable
        lastStreamArguments = arguments
        lastStreamTimeout = timeout
        lastStreamMaxLines = maxLines

        // 미리 정의된 라인들을 핸들러에 전달 (maxLines까지)
        let linesToSend = Array(streamLines.prefix(maxLines))
        for line in linesToSend {
            onLine(line)
        }

        return ProcessResult(
            output: linesToSend.joined(separator: "\n"),
            error: "",
            exitCode: streamExitCode
        )
    }
}
