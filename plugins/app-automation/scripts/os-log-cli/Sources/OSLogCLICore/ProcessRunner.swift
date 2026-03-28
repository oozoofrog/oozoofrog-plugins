import Foundation

/// 비동기 라인 수집기 (readabilityHandler에서 사용)
final class LineCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var buffer = ""
    private let maxLines: Int
    private let onLine: @Sendable (String) -> Void
    private(set) var lines: [String] = []

    var lineCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return lines.count
    }

    init(maxLines: Int, onLine: @escaping @Sendable (String) -> Void) {
        self.maxLines = maxLines
        self.onLine = onLine
    }

    func append(_ chunk: String) {
        lock.lock()
        defer { lock.unlock() }

        guard lines.count < maxLines else { return }

        buffer += chunk
        while let newline = buffer.firstIndex(of: "\n") {
            let line = String(buffer[buffer.startIndex..<newline])
            buffer = String(buffer[buffer.index(after: newline)...])
            lines.append(line)
            onLine(line)
            if lines.count >= maxLines { break }
        }
    }

    /// 남은 버퍼를 마지막 라인으로 처리
    func flush() {
        lock.lock()
        defer { lock.unlock() }

        if !buffer.isEmpty && lines.count < maxLines {
            lines.append(buffer)
            onLine(buffer)
            buffer = ""
        }
    }
}

/// Thread-safe 문자열 버퍼 (readabilityHandler에서 사용)
final class ThreadSafeBuffer: @unchecked Sendable {
    private let lock = NSLock()
    private var chunks: [String] = []

    func append(_ chunk: String) {
        lock.lock()
        chunks.append(chunk)
        lock.unlock()
    }

    var value: String {
        lock.lock()
        defer { lock.unlock() }
        return chunks.joined()
    }
}

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
        onLine: @escaping @Sendable (String) -> Void
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

        // 대량 출력 시 파이프 버퍼 데드락 방지: 비동기로 읽기
        let stdoutCollector = ThreadSafeBuffer()
        let stderrCollector2 = ThreadSafeBuffer()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            stdoutCollector.append(chunk)
        }
        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            stderrCollector2.append(chunk)
        }

        try process.run()
        process.waitUntilExit()

        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        return ProcessResult(
            output: stdoutCollector.value,
            error: stderrCollector2.value,
            exitCode: process.terminationStatus
        )
    }

    func stream(
        executable: String,
        arguments: [String],
        timeout: TimeInterval,
        maxLines: Int,
        onLine: @escaping @Sendable (String) -> Void
    ) throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // 비동기 라인 수집 (readabilityHandler로 블로킹 방지)
        let collectedLines = LineCollector(maxLines: maxLines, onLine: onLine)

        // stderr도 비동기로 수집 (readDataToEndOfFile 데드락 방지)
        let stderrCollector = ThreadSafeBuffer()

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            guard let chunk = String(data: data, encoding: .utf8) else { return }
            collectedLines.append(chunk)
            if collectedLines.lineCount >= maxLines {
                process.terminate()
            }
        }

        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            stderrCollector.append(chunk)
        }

        try process.run()

        // 타임아웃 대기
        let deadline = DispatchTime.now() + timeout
        let semaphore = DispatchSemaphore(value: 0)

        process.terminationHandler = { _ in
            semaphore.signal()
        }

        let waitResult = semaphore.wait(timeout: deadline)
        if waitResult == .timedOut && process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }

        // readabilityHandler 해제
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        let stderrOutput = stderrCollector.value

        return ProcessResult(
            output: collectedLines.lines.joined(separator: "\n"),
            error: stderrOutput,
            exitCode: process.terminationStatus
        )
    }
}
