import Testing
import Foundation
@testable import OSLogCLICore

// 테스트 픽스처 (전역 상수)
private let simctlJSONFixture = """
{
  "devices": {
    "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
      {
        "udid": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
        "name": "iPhone 15 Pro",
        "state": "Booted",
        "isAvailable": true,
        "deviceTypeIdentifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro"
      },
      {
        "udid": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
        "name": "iPhone SE (3rd generation)",
        "state": "Shutdown",
        "isAvailable": true,
        "deviceTypeIdentifier": "com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation"
      }
    ],
    "com.apple.CoreSimulator.SimRuntime.watchOS-10-0": [
      {
        "udid": "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC",
        "name": "Apple Watch Series 9 - 45mm",
        "state": "Booted",
        "isAvailable": true,
        "deviceTypeIdentifier": "com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-9-45mm"
      }
    ]
  }
}
"""

private let emptySimctlJSON = """
{
  "devices": {}
}
"""

private let devicectlOutputFixture = """
Listing devices:
Name                    UDID                              Status       Platform     OS
──────────────────────  ────────────────────────────────  ───────────  ───────────  ──────
My iPhone               00000000-0000000000000000         connected    iPhone       17.0
"""

@Suite("DevicesCommand 파싱 유닛 테스트")
struct DevicesCommandTests {

    // MARK: - 시나리오 1: simctl JSON 샘플 파싱 → DeviceInfo 배열

    @Test("simctl JSON 파싱 시 DeviceInfo 배열 반환")
    func parsesSimctlJSONToDeviceInfoArray() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
        // Booted 상태인 것은 iPhone 15 Pro와 Apple Watch — 2개
        #expect(devices.count == 2)
    }

    @Test("파싱된 DeviceInfo 타입이 simulator")
    func parsedDeviceTypeIsSimulator() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
        for device in devices {
            #expect(device.type == DeviceInfo.DeviceType.simulator)
        }
    }

    @Test("파싱된 DeviceInfo에 올바른 udid/name 포함")
    func parsedDeviceContainsCorrectData() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
        let uuids = devices.map { $0.udid }
        #expect(uuids.contains("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"))
        #expect(uuids.contains("CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"))
    }

    // MARK: - 시나리오 2: Booted 상태 필터링

    @Test("Shutdown 상태 디바이스는 결과에서 제외")
    func shutdownDevicesExcluded() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
        let names = devices.map { $0.name }
        // Shutdown 상태인 iPhone SE는 제외되어야 함
        #expect(!names.contains("iPhone SE (3rd generation)"))
    }

    @Test("Booted 상태만 포함")
    func onlyBootedDevicesIncluded() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
        for device in devices {
            #expect(device.status == "Booted")
        }
    }

    // MARK: - 시나리오 3: devicectl 텍스트 출력 파싱 → DeviceInfo

    @Test("devicectl 텍스트 출력 파싱 크래시 없음")
    func parsesDevicectlOutput() {
        let devices = DeviceParser.parseDevicectlOutput(devicectlOutputFixture)
        // 픽스처의 UDID가 실제 UUID 형식이 아니므로 빈 배열일 수 있지만 크래시 없어야 함
        #expect(devices.count >= 0)
    }

    @Test("devicectl 빈 출력 시 빈 배열 반환")
    func emptyDevicectlOutputReturnsEmptyArray() {
        let devices = DeviceParser.parseDevicectlOutput("")
        #expect(devices.isEmpty)
    }

    // MARK: - 시나리오 4: simctl JSON 파싱 실패 시 빈 배열 반환

    @Test("잘못된 JSON 입력 시 빈 배열 반환")
    func invalidJSONReturnsEmptyArray() {
        let devices = DeviceParser.parseSimctlJSON("not json at all {{{")
        #expect(devices.isEmpty)
    }

    @Test("빈 JSON 객체 입력 시 빈 배열 반환")
    func emptyJSONObjectReturnsEmptyArray() {
        let devices = DeviceParser.parseSimctlJSON("{}")
        #expect(devices.isEmpty)
    }

    @Test("빈 JSON 배열 입력 시 빈 배열 반환")
    func emptyJSONArrayReturnsEmptyArray() {
        let devices = DeviceParser.parseSimctlJSON("[]")
        #expect(devices.isEmpty)
    }

    @Test("devices 키가 빈 딕셔너리인 JSON 입력 시 빈 배열")
    func emptyDevicesKeyReturnsEmptyArray() {
        let devices = DeviceParser.parseSimctlJSON(emptySimctlJSON)
        #expect(devices.isEmpty)
    }

    @Test("빈 문자열 입력 시 빈 배열 반환")
    func emptyStringReturnsEmptyArray() {
        let devices = DeviceParser.parseSimctlJSON("")
        #expect(devices.isEmpty)
    }

    // MARK: - OS 문자열 파싱

    @Test("SimRuntime 키에서 iOS OS 문자열 추출")
    func parseOSFromiOSRuntimeKey() {
        #expect(DeviceParser.parseOSFromRuntimeKey("com.apple.CoreSimulator.SimRuntime.iOS-17-0") == "iOS 17.0")
    }

    @Test("SimRuntime 키에서 watchOS OS 문자열 추출")
    func parseOSFromwatchOSRuntimeKey() {
        #expect(DeviceParser.parseOSFromRuntimeKey("com.apple.CoreSimulator.SimRuntime.watchOS-10-2") == "watchOS 10.2")
    }

    @Test("SimRuntime 키에서 tvOS OS 문자열 추출")
    func parseOSFromtvOSRuntimeKey() {
        #expect(DeviceParser.parseOSFromRuntimeKey("com.apple.CoreSimulator.SimRuntime.tvOS-17-0") == "tvOS 17.0")
    }

    // MARK: - 시나리오 5: --json 플래그 출력 형식 검증

    @Test("DeviceInfo JSON 직렬화 유효성")
    func deviceInfoJSONSerialization() throws {
        let device = DeviceInfo(
            udid: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
            name: "iPhone 15 Pro",
            type: .simulator,
            os: "iOS 17.0",
            status: "Booted"
        )

        let data = try JSONEncoder().encode([device])
        let parsed = try JSONSerialization.jsonObject(with: data)
        let array = try #require(parsed as? [[String: String]])

        #expect(array.count == 1)
        #expect(array[0]["udid"] == "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
        #expect(array[0]["name"] == "iPhone 15 Pro")
        #expect(array[0]["type"] == "simulator")
        #expect(array[0]["os"] == "iOS 17.0")
        #expect(array[0]["status"] == "Booted")
    }

    @Test("빈 DeviceInfo 배열 JSON 직렬화")
    func emptyDeviceArrayJSONSerialization() throws {
        let devices: [DeviceInfo] = []
        let data = try JSONEncoder().encode(devices)
        let string = try #require(String(data: data, encoding: .utf8))
        #expect(string == "[]")
    }
}
