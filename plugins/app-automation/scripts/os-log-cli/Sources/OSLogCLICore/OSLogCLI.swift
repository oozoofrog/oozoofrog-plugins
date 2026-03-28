import ArgumentParser

/// os-log CLI 루트 커맨드 (F007)
public struct OSLogCLI: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "os-log",
        abstract: "iOS/macOS/watchOS 앱의 os_log를 조회·스트리밍하는 CLI 도구",
        version: "1.0.0",
        subcommands: [StreamCommand.self, ShowCommand.self, DevicesCommand.self]
    )

    public init() {}
}
