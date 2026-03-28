import Foundation

/// 프로세스 실행 결과
struct ProcessResult: Sendable {
    let output: String
    let error: String
    let exitCode: Int32
}

/// 외부 프로세스를 실행하는 프로토콜 (Mock 주입을 위해 추상화)
protocol ProcessRunner: Sendable {
    /// 지정된 명령어를 실행하고 결과를 반환
    func run(
        executable: String,
        arguments: [String]
    ) throws -> ProcessResult

    /// 스트리밍 실행: 각 라인을 실시간으로 핸들러에 전달. timeout/maxLines 초과 시 종료.
    func stream(
        executable: String,
        arguments: [String],
        timeout: TimeInterval,
        maxLines: Int,
        onLine: @Sendable (String) -> Void
    ) throws -> ProcessResult
}

/// 실제 Foundation.Process를 사용하는 구현체
struct SystemProcessRunner: ProcessRunner {
    func run(
        executable: String,
        arguments: [String]
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: stdoutData, encoding: .utf8) ?? ""
        let error = String(data: stderrData, encoding: .utf8) ?? ""

        return ProcessResult(
            output: output,
            error: error,
            exitCode: process.terminationStatus
        )
    }

    func stream(
        executable: String,
        arguments: [String],
        timeout: TimeInterval,
        maxLines: Int,
        onLine: @Sendable (String) -> Void
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()

        var lineCount = 0
        var collectedOutput: [String] = []
        var stderrOutput = ""

        // 타임아웃을 위한 타이머
        let deadline = Date().addingTimeInterval(timeout)

        let handle = stdoutPipe.fileHandleForReading
        var buffer = ""

        // 실시간 라인 읽기 루프
        while process.isRunning {
            let now = Date()
            if now >= deadline {
                process.terminate()
                break
            }
            if lineCount >= maxLines {
                process.terminate()
                break
            }

            // 0.05초 단위로 읽기
            let available = handle.availableData
            if !available.isEmpty, let chunk = String(data: available, encoding: .utf8) {
                buffer += chunk
                while let newline = buffer.firstIndex(of: "\n") {
                    let line = String(buffer[buffer.startIndex..<newline])
                    buffer = String(buffer[buffer.index(after: newline)...])
                    onLine(line)
                    collectedOutput.append(line)
                    lineCount += 1
                    if lineCount >= maxLines {
                        process.terminate()
                        break
                    }
                }
            } else {
                Thread.sleep(forTimeInterval: 0.05)
            }
        }

        // 남은 버퍼 처리
        if !buffer.isEmpty {
            let line = buffer
            onLine(line)
            collectedOutput.append(line)
        }

        process.waitUntilExit()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        stderrOutput = String(data: stderrData, encoding: .utf8) ?? ""

        return ProcessResult(
            output: collectedOutput.joined(separator: "\n"),
            error: stderrOutput,
            exitCode: process.terminationStatus
        )
    }
}
