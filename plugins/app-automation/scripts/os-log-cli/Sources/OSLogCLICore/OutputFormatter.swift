import Foundation
import ArgumentParser

/// 출력 스타일 선택지
enum OutputStyle: String, ExpressibleByArgument, CaseIterable, Sendable {
    case compact
    case json
    case verbose
}

/// 파싱된 로그 엔트리
struct LogEntry: Sendable {
    let timestamp: String
    let process: String
    let subsystem: String?
    let category: String?
    let level: String
    let message: String
}

/// 로그 라인 파싱 및 포맷 변환
enum OutputFormatter {
    // `log stream` / `log show` 출력 형식 예시:
    // 2024-01-15 10:23:45.678901+0900 MyApp[1234:5678] <Warning>: [subsystem/category] message
    // 또는
    // 2024-01-15 10:23:45.678901+0900 kernel[0] <Notice>: message
    private static let linePattern: NSRegularExpression? = {
        // 타임스탬프 프로세스[pid:tid] <레벨>: 메시지 형식 매칭
        let pattern = #"^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+[+-]\d{4})\s+(.+?\[\d+(?::\d+)?\])\s+<(\w+)>:\s+(.*)$"#
        return try? NSRegularExpression(pattern: pattern)
    }()

    /// log 출력 라인 하나를 파싱하여 LogEntry 반환 (실패 시 nil)
    static func parse(line: String) -> LogEntry? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        guard let regex = linePattern else { return nil }
        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, range: range) else {
            return nil
        }

        func captureGroup(_ index: Int) -> String? {
            guard let range = Range(match.range(at: index), in: trimmed) else { return nil }
            return String(trimmed[range])
        }

        guard
            let timestamp = captureGroup(1),
            let processStr = captureGroup(2),
            let levelStr = captureGroup(3),
            let rawMessage = captureGroup(4)
        else {
            return nil
        }

        // [subsystem/category] 접두어 파싱 (선택적)
        var subsystem: String? = nil
        var category: String? = nil
        var message = rawMessage

        let subsystemCategoryPattern = #"^\[([^/\]]+)/([^\]]+)\]\s+(.*)"#
        if let scRegex = try? NSRegularExpression(pattern: subsystemCategoryPattern),
           let scMatch = scRegex.firstMatch(in: rawMessage, range: NSRange(rawMessage.startIndex..., in: rawMessage)) {
            if let ssRange = Range(scMatch.range(at: 1), in: rawMessage),
               let catRange = Range(scMatch.range(at: 2), in: rawMessage),
               let msgRange = Range(scMatch.range(at: 3), in: rawMessage) {
                subsystem = String(rawMessage[ssRange])
                category = String(rawMessage[catRange])
                message = String(rawMessage[msgRange])
            }
        }

        return LogEntry(
            timestamp: timestamp,
            process: processStr,
            subsystem: subsystem,
            category: category,
            level: levelStr,
            message: message
        )
    }

    /// LogEntry를 지정한 스타일로 포맷
    static func format(_ entry: LogEntry, style: OutputStyle) -> String {
        switch style {
        case .compact:
            return formatCompact(entry)
        case .json:
            return formatJSON(entry)
        case .verbose:
            return formatVerbose(entry)
        }
    }

    // MARK: - Private formatters

    private static func formatCompact(_ entry: LogEntry) -> String {
        var parts = [entry.timestamp, entry.level, entry.message]
        if let subsystem = entry.subsystem {
            parts.insert(subsystem, at: 2)
        }
        return parts.joined(separator: " | ")
    }

    private static func formatJSON(_ entry: LogEntry) -> String {
        var dict: [String: String] = [
            "timestamp": entry.timestamp,
            "process": entry.process,
            "level": entry.level,
            "message": entry.message
        ]
        if let subsystem = entry.subsystem {
            dict["subsystem"] = subsystem
        }
        if let category = entry.category {
            dict["category"] = category
        }

        // JSONEncoder를 사용한 직렬화
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.sortedKeys]
        ),
        let jsonString = String(data: data, encoding: .utf8) else {
            return "{\"error\": \"json serialization failed\"}"
        }
        return jsonString
    }

    private static func formatVerbose(_ entry: LogEntry) -> String {
        var lines = [
            "Timestamp : \(entry.timestamp)",
            "Process   : \(entry.process)",
            "Level     : \(entry.level)",
            "Message   : \(entry.message)"
        ]
        if let subsystem = entry.subsystem {
            lines.insert("Subsystem : \(subsystem)", at: 3)
        }
        if let category = entry.category {
            lines.insert("Category  : \(category)", at: 4)
        }
        return lines.joined(separator: "\n")
    }
}
