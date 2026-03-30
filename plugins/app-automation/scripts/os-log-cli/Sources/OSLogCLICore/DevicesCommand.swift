import ArgumentParser
import Foundation

/// 디바이스 정보 구조체
struct DeviceInfo: Sendable, Encodable {
    let udid: String
    let name: String
    let type: DeviceType
    let os: String
    let status: String

    enum DeviceType: String, Sendable, Encodable {
        case simulator
        case device
    }
}

/// simctl/devicectl 출력 파싱 (순수 함수, 테스트 가능)
enum DeviceParser {
    /// `xcrun simctl list devices --json` 출력에서 Booted 시뮬레이터 파싱
    static func parseSimctlJSON(_ jsonString: String) -> [DeviceInfo] {
        guard
            let data = jsonString.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let devices = root["devices"] as? [String: [[String: Any]]]
        else {
            return []
        }

        var result: [DeviceInfo] = []
        for (osKey, deviceList) in devices {
            for device in deviceList {
                guard
                    let udid = device["udid"] as? String,
                    let name = device["name"] as? String,
                    let state = device["state"] as? String
                else { continue }

                // Booted 상태인 디바이스만 포함
                guard state == "Booted" else { continue }

                // OS 문자열 추출
                let osString = parseOSFromRuntimeKey(osKey)

                result.append(DeviceInfo(
                    udid: udid,
                    name: name,
                    type: .simulator,
                    os: osString,
                    status: state
                ))
            }
        }
        return result
    }

    /// `xcrun devicectl list devices` 텍스트 출력에서 실제 디바이스 파싱
    ///
    /// 실제 출력 형식:
    /// ```
    /// Name               Hostname                           Identifier                             State                Model
    /// ----------------   --------------------------------   ------------------------------------   ------------------   -------
    /// eyephone           eyephone.coredevice.local          6198787F-2780-55F0-B3C4-2756280A1A74   connected            iPhone 14 Pro
    /// ```
    static func parseDevicectlOutput(_ output: String) -> [DeviceInfo] {
        var result: [DeviceInfo] = []
        let lines = output.components(separatedBy: "\n")

        var dataStarted = false
        var columnMap: [String: Int] = [:]

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            if !dataStarted {
                // 구분선 감지 (- 또는 ─ 문자와 공백으로만 구성)
                let dashes = trimmed.filter { $0 != " " }
                if !dashes.isEmpty && dashes.allSatisfy({ $0 == "-" || $0 == "─" }) {
                    dataStarted = true
                    continue
                }

                // 헤더 후보 파싱 (마지막 유효 헤더를 사용)
                let fields = splitColumns(trimmed)
                if fields.count >= 3 {
                    var map: [String: Int] = [:]
                    for (i, f) in fields.enumerated() {
                        map[f.lowercased()] = i
                    }
                    columnMap = map
                }
                continue
            }

            // 데이터 라인 파싱
            let fields = splitColumns(trimmed)
            guard fields.count >= 3 else { continue }

            let nameIdx = columnMap["name"] ?? 0
            let udidIdx = columnMap["identifier"] ?? columnMap["udid"] ?? min(2, fields.count - 1)
            let stateIdx = columnMap["state"] ?? columnMap["status"] ?? min(3, fields.count - 1)
            let modelIdx = columnMap["model"] ?? min(fields.count - 1, 4)

            let name = nameIdx < fields.count ? fields[nameIdx] : ""
            let udid = udidIdx < fields.count ? fields[udidIdx] : ""
            let status = stateIdx < fields.count ? fields[stateIdx] : ""
            let model = modelIdx < fields.count ? fields[modelIdx] : ""

            guard !udid.isEmpty else { continue }

            result.append(DeviceInfo(
                udid: udid,
                name: name,
                type: .device,
                os: model,
                status: status
            ))
        }
        return result
    }

    /// 3개 이상의 연속 공백으로 컬럼을 분리
    static func splitColumns(_ line: String) -> [String] {
        let nsLine = line as NSString
        guard let regex = try? NSRegularExpression(pattern: #"\s{3,}"#) else {
            return [line]
        }

        let fullRange = NSRange(location: 0, length: nsLine.length)
        let matches = regex.matches(in: line, range: fullRange)

        var result: [String] = []
        var lastEnd = 0

        for match in matches {
            if match.range.location > lastEnd {
                let field = nsLine.substring(
                    with: NSRange(location: lastEnd, length: match.range.location - lastEnd)
                )
                result.append(field.trimmingCharacters(in: .whitespaces))
            }
            lastEnd = match.range.location + match.range.length
        }

        if lastEnd < nsLine.length {
            let field = nsLine.substring(from: lastEnd)
            let trimmed = field.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                result.append(trimmed)
            }
        }

        return result
    }

    /// SimRuntime 키 → 사람이 읽기 좋은 OS 문자열 변환
    static func parseOSFromRuntimeKey(_ key: String) -> String {
        // 예: "com.apple.CoreSimulator.SimRuntime.iOS-17-0" → "iOS 17.0"
        // 예: "com.apple.CoreSimulator.SimRuntime.watchOS-10-0" → "watchOS 10.0"
        let suffix = key.components(separatedBy: ".").last ?? key
        let parts = suffix.components(separatedBy: "-")
        guard parts.count >= 2 else { return key }

        let platformName = parts[0]
        let versionParts = parts[1...]
        let version = versionParts.joined(separator: ".")
        return "\(platformName) \(version)"
    }
}

struct DevicesCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "devices",
        abstract: "사용 가능한 시뮬레이터 및 실제 디바이스 목록 표시"
    )

    @Flag(name: .long, help: "JSON 배열 형식으로 출력")
    var json: Bool = false

    mutating func run() throws {
        try runWithRunner(SystemProcessRunner(), outputJSON: json)
    }

    /// ProcessRunner를 주입받아 실행 (테스트 가능)
    func runWithRunner(_ runner: any ProcessRunner, outputJSON: Bool = false) throws {
        var allDevices: [DeviceInfo] = []

        // 1. simctl로 시뮬레이터 목록 조회
        let simctlDevices = fetchSimulators(runner: runner)
        allDevices += simctlDevices

        // 2. devicectl로 실제 디바이스 목록 조회 (미설치 시 graceful degradation)
        let physicalDevices = fetchPhysicalDevices(runner: runner)
        allDevices += physicalDevices

        if allDevices.isEmpty {
            if outputJSON {
                print("[]")
            } else {
                print("No devices found.")
            }
            return
        }

        if outputJSON {
            printJSON(allDevices)
        } else {
            printTable(allDevices)
        }
    }

    // MARK: - Private helpers

    private func fetchSimulators(runner: any ProcessRunner) -> [DeviceInfo] {
        guard let result = try? runner.run(
            executable: "/usr/bin/xcrun",
            arguments: ["simctl", "list", "devices", "--json"]
        ) else {
            return []
        }
        return DeviceParser.parseSimctlJSON(result.output)
    }

    private func fetchPhysicalDevices(runner: any ProcessRunner) -> [DeviceInfo] {
        guard let result = try? runner.run(
            executable: "/usr/bin/xcrun",
            arguments: ["devicectl", "list", "devices"]
        ) else {
            return []
        }
        if result.exitCode != 0 {
            return []
        }
        return DeviceParser.parseDevicectlOutput(result.output)
    }

    private func printJSON(_ devices: [DeviceInfo]) {
        guard let data = try? JSONEncoder().encode(devices),
              let string = String(data: data, encoding: .utf8) else {
            print("[]")
            return
        }
        print(string)
    }

    private func printTable(_ devices: [DeviceInfo]) {
        // Swift String 패딩 (String(format:"%s") 사용 시 segfault 가능 — 직접 padding 처리)
        func pad(_ s: String, to width: Int) -> String {
            if s.count >= width { return s }
            return s + String(repeating: " ", count: width - s.count)
        }
        let header = [
            pad("UDID", to: 40),
            pad("Name", to: 30),
            pad("Type", to: 10),
            pad("OS", to: 15),
            "Status"
        ].joined(separator: " ")
        print(header)
        print(String(repeating: "-", count: 110))
        for device in devices {
            let row = [
                pad(device.udid, to: 40),
                pad(device.name, to: 30),
                pad(device.type.rawValue, to: 10),
                pad(device.os, to: 15),
                device.status
            ].joined(separator: " ")
            print(row)
        }
    }
}
