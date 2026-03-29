import ArgumentParser
import Foundation

struct ShowCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "저장된 os_log 조회 (log show 래핑)"
    )

    @OptionGroup var filter: LogFilter

    @Option(name: .long, help: "최근 기간 (예: 1h, 30m, 2d)")
    var last: String?

    @Option(name: .long, help: "시작 시각 (ISO8601, 예: 2024-01-01T00:00:00)")
    var start: String?

    @Option(name: .long, help: "종료 시각 (ISO8601, 예: 2024-01-01T01:00:00)")
    var end: String?

    @Option(name: .long, help: "출력 포맷 (compact/json/verbose, 기본값: compact)")
    var format: OutputStyle = .compact

    mutating func validate() throws {
        // --last와 --start/--end는 상호 배제
        if last != nil && (start != nil || end != nil) {
            throw ValidationError("--last와 --start/--end는 동시에 사용할 수 없습니다.")
        }
    }

    mutating func run() throws {
        try runWith(runner: SystemProcessRunner())
    }

    /// ProcessRunner를 주입받아 실행 (테스트 가능)
    func runWith(runner: any ProcessRunner) throws {
        try runWithRunner(runner, filterValues: filter.toValues())
    }

    /// ProcessRunner와 LogFilterValues를 주입받아 실행 (테스트 가능)
    func runWithRunner(_ runner: any ProcessRunner, filterValues: LogFilterValues) throws {
        var args = ["show"]

        if let last {
            args += ["--last", last]
        } else {
            if let start {
                args += ["--start", start]
            }
            if let end {
                args += ["--end", end]
            }
        }

        args += filterValues.buildArguments()

        let result = try runner.run(
            executable: "/usr/bin/log",
            arguments: args
        )

        if !result.output.isEmpty {
            for line in result.output.components(separatedBy: "\n") {
                if let entry = OutputFormatter.parse(line: line) {
                    print(OutputFormatter.format(entry, style: format))
                } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                    print(line)
                }
            }
        }

        if !result.error.isEmpty {
            fputs(result.error, stderr)
        }
    }
}
