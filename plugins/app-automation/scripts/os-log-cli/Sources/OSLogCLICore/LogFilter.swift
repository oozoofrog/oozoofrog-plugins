import ArgumentParser

/// 로그 필터 값을 담는 순수 구조체 (테스트에서 직접 생성 가능)
struct LogFilterValues: Sendable {
    var subsystem: String? = nil
    var category: String? = nil
    var level: LogLevel? = nil
    var process: String? = nil
    var predicate: String? = nil
    var device: String? = nil

    /// `log` CLI 인자 배열로 변환 (순수 함수, 외부 I/O 없음)
    func buildArguments() -> [String] {
        var args: [String] = []

        // --predicate를 직접 지정한 경우 그대로 전달
        if let predicate {
            args += ["--predicate", predicate]
        } else {
            // subsystem/category 조합으로 NSPredicate 생성
            var predicateParts: [String] = []
            if let subsystem {
                predicateParts.append("subsystem == \"\(subsystem)\"")
            }
            if let category {
                predicateParts.append("category == \"\(category)\"")
            }
            if !predicateParts.isEmpty {
                args += ["--predicate", predicateParts.joined(separator: " AND ")]
            }
        }

        if let level {
            args += ["--level", level.rawValue]
        }

        if let process {
            args += ["--process", process]
        }

        if let device {
            args += ["--device", device]
        }

        return args
    }
}

/// log CLI 인자에 공통 필터 옵션을 추가하는 ParsableArguments (CLI 파싱 전용)
struct LogFilter: ParsableArguments, Sendable {
    @Option(name: .long, help: "subsystem 필터 (예: com.example.myapp)")
    var subsystem: String?

    @Option(name: .long, help: "category 필터 (예: network)")
    var category: String?

    @Option(name: .long, help: "로그 레벨 필터 (default/info/debug/error/fault)")
    var level: LogLevel?

    @Option(name: .long, help: "프로세스 이름 또는 PID 필터")
    var process: String?

    @Option(name: .long, help: "NSPredicate 형식의 직접 필터 (예: 'subsystem == \"com.x\"')")
    var predicate: String?

    @Option(name: .long, help: "디바이스 UDID (시뮬레이터 또는 실제 디바이스)")
    var device: String?

    /// ParsableArguments → LogFilterValues 변환
    func toValues() -> LogFilterValues {
        LogFilterValues(
            subsystem: subsystem,
            category: category,
            level: level,
            process: process,
            predicate: predicate,
            device: device
        )
    }
}

/// 로그 레벨 선택지
enum LogLevel: String, ExpressibleByArgument, CaseIterable, Sendable {
    case `default`
    case info
    case debug
    case error
    case fault
}
