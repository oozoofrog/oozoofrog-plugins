import ArgumentParser
import Foundation

struct StreamCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "stream",
        abstract: "실시간 os_log 스트리밍 (log stream 래핑)"
    )

    @OptionGroup var filter: LogFilter

    @Option(name: .long, help: "스트리밍 타임아웃 (초, 기본값: 30)")
    var timeout: TimeInterval = 30

    @Option(name: .long, help: "최대 수집 로그 줄 수 (기본값: 100)")
    var maxLines: Int = 100

    @Option(name: .long, help: "출력 포맷 (compact/json/verbose, 기본값: compact)")
    var format: OutputStyle = .compact

    mutating func validate() throws {
        guard timeout > 0 else {
            throw ValidationError("--timeout 값은 0보다 커야 합니다.")
        }
        guard maxLines > 0 else {
            throw ValidationError("--max-lines 값은 0보다 커야 합니다.")
        }
    }

    mutating func run() throws {
        try runWithRunner(SystemProcessRunner())
    }

    /// ProcessRunner를 주입받아 실행 (테스트 가능)
    mutating func runWithRunner(_ runner: any ProcessRunner) throws {
        var args = ["stream"]
        args += filter.buildArguments()

        // @Sendable 클로저에서 inout self 캡처 불가 — 값 미리 복사
        let capturedFormat = format
        let result = try runner.stream(
            executable: "/usr/bin/log",
            arguments: args,
            timeout: timeout,
            maxLines: maxLines,
            onLine: { line in
                if let entry = OutputFormatter.parse(line: line) {
                    print(OutputFormatter.format(entry, style: capturedFormat))
                } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    print(line)
                }
            }
        )

        if !result.error.isEmpty {
            fputs(result.error, stderr)
        }
    }
}
