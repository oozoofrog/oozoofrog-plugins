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
    static func parseDevicectlOutput(_ output: String) -> [DeviceInfo] {
        // devicectl 출력 형식 예시:
        // Name                UDID                                   Status    Platform      OS
        // ──────────────────  ─────────────────────────────────────  ────────  ────────────  ──────────
        // My iPhone           00000000-0000000000000000              connected  iPhone        17.0
        var result: [DeviceInfo] = []
        let lines = output.components(separatedBy: "\n")

        // 헤더/구분선 건너뛰기
        var dataStarted = false
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }

            // 구분선 (─ 문자 포함) 감지
            if trimmed.contains("─") {
                dataStarted = true
                continue
            }

            // 헤더 라인 감지 (UDID, Name, Status 등 키워드)
            if !dataStarted {
                if trimmed.lowercased().contains("udid") || trimmed.lowercased().contains("name") {
                    continue
                }
                continue
            }

            // 공백으로 분리된 컬럼 파싱
            let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            guard parts.count >= 4 else { continue }

            // UDID 패턴 감지 (UUID 형식: 8자리-16자리 hex)
            let uuidPattern = #"^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{16}$"#
            let uuidRegex = try? NSRegularExpression(pattern: uuidPattern)
            guard let uuidIndex = parts.firstIndex(where: { part in
                let r = NSRange(part.startIndex..., in: part)
                return uuidRegex?.firstMatch(in: part, range: r) != nil
            }) else { continue }

            let udid = parts[uuidIndex]
            let name = parts[0..<uuidIndex].joined(separator: " ")
            let status = uuidIndex + 1 < parts.count ? parts[uuidIndex + 1] : "unknown"
            let platform = uuidIndex + 2 < parts.count ? parts[uuidIndex + 2] : ""
            let osVersion = uuidIndex + 3 < parts.count ? parts[uuidIndex + 3] : ""
            let osString = [platform, osVersion].filter { !$0.isEmpty }.joined(separator: " ")

            result.append(DeviceInfo(
                udid: udid,
                name: name,
                type: .device,
                os: osString,
                status: status
            ))
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
        try runWithRunner(SystemProcessRunner())
    }

    /// ProcessRunner를 주입받아 실행 (테스트 가능)
    mutating func runWithRunner(_ runner: any ProcessRunner) throws {
        var allDevices: [DeviceInfo] = []

        // 1. simctl로 시뮬레이터 목록 조회
        let simctlDevices = fetchSimulators(runner: runner)
        allDevices += simctlDevices

        // 2. devicectl로 실제 디바이스 목록 조회 (미설치 시 graceful degradation)
        let physicalDevices = fetchPhysicalDevices(runner: runner)
        allDevices += physicalDevices

        if allDevices.isEmpty {
            if json {
                print("[]")
            } else {
                print("No devices found.")
            }
            return
        }

        if json {
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
        let header = String(format: "%-40s %-30s %-10s %-15s %-10s",
            "UDID", "Name", "Type", "OS", "Status")
        print(header)
        print(String(repeating: "-", count: 110))
        for device in devices {
            let row = String(format: "%-40s %-30s %-10s %-15s %-10s",
                device.udid,
                device.name,
                device.type.rawValue,
                device.os,
                device.status)
            print(row)
        }
    }
}
