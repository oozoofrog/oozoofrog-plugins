import Testing
import Foundation
@testable import OSLogCLICore

@Suite("OutputFormatter 유닛 테스트")
struct OutputFormatterTests {

    // 정상적인 log stream 출력 샘플
    let sampleLine = "2024-01-15 10:23:45.678901+0900 MyApp[1234:5678] <Warning>: [com.example/network] HTTP request failed"
    let sampleLineNoSubsystem = "2024-01-15 10:23:45.678901+0900 kernel[0] <Notice>: system boot complete"

    // MARK: - 시나리오 1: 정상 log 라인 파싱 → LogEntry 반환

    @Test("정상 log 라인 파싱 시 LogEntry 반환")
    func parsesNormalLogLine() {
        let entry = OutputFormatter.parse(line: sampleLine)
        #expect(entry != nil)
        if let entry {
            #expect(entry.timestamp == "2024-01-15 10:23:45.678901+0900")
            #expect(entry.process == "MyApp[1234:5678]")
            #expect(entry.level == "Warning")
            #expect(entry.subsystem == "com.example")
            #expect(entry.category == "network")
            #expect(entry.message == "HTTP request failed")
        }
    }

    @Test("subsystem/category 없는 라인 파싱")
    func parsesLineWithoutSubsystemCategory() {
        let entry = OutputFormatter.parse(line: sampleLineNoSubsystem)
        #expect(entry != nil)
        if let entry {
            #expect(entry.subsystem == nil)
            #expect(entry.category == nil)
            #expect(entry.message == "system boot complete")
        }
    }

    // MARK: - 시나리오 2: 잘못된 형식 → nil 반환

    @Test("잘못된 형식 입력 시 nil 반환")
    func returnsNilForInvalidFormat() {
        let entry = OutputFormatter.parse(line: "this is not a log line")
        #expect(entry == nil)
    }

    @Test("빈 문자열 입력 시 nil 반환")
    func returnsNilForEmptyString() {
        let entry = OutputFormatter.parse(line: "")
        #expect(entry == nil)
    }

    @Test("공백만 있는 문자열 입력 시 nil 반환")
    func returnsNilForWhitespaceOnly() {
        let entry = OutputFormatter.parse(line: "   ")
        #expect(entry == nil)
    }

    @Test("타임스탬프 없는 라인 nil 반환")
    func returnsNilForMissingTimestamp() {
        let entry = OutputFormatter.parse(line: "MyApp[1234] <Error>: some message")
        #expect(entry == nil)
    }

    // MARK: - 시나리오 3: compact 포맷

    @Test("compact 포맷 출력 형식 검증")
    func compactFormatContainsRequiredParts() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLine))
        let output = OutputFormatter.format(entry, style: .compact)

        #expect(output.contains("2024-01-15 10:23:45.678901+0900"))
        #expect(output.contains("Warning"))
        #expect(output.contains("HTTP request failed"))
        // compact는 | 구분자 사용
        #expect(output.contains("|"))
    }

    @Test("compact 포맷 subsystem nil 케이스 크래시 없음")
    func compactFormatWithNilSubsystem() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLineNoSubsystem))
        let output = OutputFormatter.format(entry, style: .compact)
        #expect(!output.isEmpty)
    }

    // MARK: - 시나리오 4: verbose 포맷

    @Test("verbose 포맷 출력 형식 검증")
    func verboseFormatContainsLabels() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLine))
        let output = OutputFormatter.format(entry, style: .verbose)

        #expect(output.contains("Timestamp"))
        #expect(output.contains("Process"))
        #expect(output.contains("Level"))
        #expect(output.contains("Message"))
        #expect(output.contains("\n"))
    }

    @Test("verbose 포맷 subsystem nil 케이스 크래시 없음")
    func verboseFormatWithNilSubsystem() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLineNoSubsystem))
        let output = OutputFormatter.format(entry, style: .verbose)
        #expect(!output.isEmpty)
        #expect(!output.contains("Subsystem"))
    }

    // MARK: - 시나리오 5: json 포맷 → 유효한 JSON

    @Test("json 포맷 유효한 JSON 문자열 반환")
    func jsonFormatProducesValidJSON() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLine))
        let output = OutputFormatter.format(entry, style: .json)

        // JSONSerialization으로 파싱 가능한지 구조적 검증
        let data = try #require(output.data(using: .utf8))
        let parsed = try JSONSerialization.jsonObject(with: data)
        let dict = try #require(parsed as? [String: String])

        #expect(dict["timestamp"] == "2024-01-15 10:23:45.678901+0900")
        #expect(dict["level"] == "Warning")
        #expect(dict["message"] == "HTTP request failed")
        #expect(dict["subsystem"] == "com.example")
        #expect(dict["category"] == "network")
    }

    @Test("json 포맷 subsystem nil 케이스 유효한 JSON")
    func jsonFormatWithNilSubsystemIsValid() throws {
        let entry = try #require(OutputFormatter.parse(line: sampleLineNoSubsystem))
        let output = OutputFormatter.format(entry, style: .json)

        let data = try #require(output.data(using: .utf8))
        let parsed = try JSONSerialization.jsonObject(with: data)
        let dict = try #require(parsed as? [String: String])

        #expect(dict["subsystem"] == nil)
        #expect(dict["category"] == nil)
        #expect(dict["message"] == "system boot complete")
    }

    // MARK: - 시나리오 6: subsystem/category nil인 경우 처리

    @Test("subsystem nil인 LogEntry 세 포맷 모두 크래시 없음")
    func allFormatsHandleNilSubsystem() {
        let entry = LogEntry(
            timestamp: "2024-01-01 00:00:00.000000+0000",
            process: "TestApp[1]",
            subsystem: nil,
            category: nil,
            level: "Debug",
            message: "test message"
        )

        let compact = OutputFormatter.format(entry, style: .compact)
        let json = OutputFormatter.format(entry, style: .json)
        let verbose = OutputFormatter.format(entry, style: .verbose)

        #expect(!compact.isEmpty)
        #expect(!json.isEmpty)
        #expect(!verbose.isEmpty)
    }

    @Test("subsystem 있고 category nil인 LogEntry 처리")
    func handlesSubsystemWithNilCategory() {
        let entry = LogEntry(
            timestamp: "2024-01-01 00:00:00.000000+0000",
            process: "App[1]",
            subsystem: "com.example",
            category: nil,
            level: "Info",
            message: "hello"
        )

        let compact = OutputFormatter.format(entry, style: .compact)
        let json = OutputFormatter.format(entry, style: .json)
        let verbose = OutputFormatter.format(entry, style: .verbose)

        #expect(compact.contains("com.example"))
        #expect(json.contains("com.example"))
        #expect(verbose.contains("com.example"))
    }
}
