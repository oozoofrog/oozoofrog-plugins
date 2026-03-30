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
Name                 Hostname                              Identifier                             State                Model
-----------------    ----------------------------------    ------------------------------------   ------------------   -------------------------------------------
eyephone             eyephone.coredevice.local             6198787F-2780-55F0-B3C4-2756280A1A74   connected            iPhone 14 Pro (iPhone15,2)
My Apple Watch       watch.coredevice.local                C8C1FD6D-8ED8-5B16-81EF-7657982F4CBA   available (paired)   Apple Watch Series 8 (Watch6,14)
"""

@Suite("DevicesCommand 파싱 유닛 테스트")
struct DevicesCommandTests {

    // MARK: - 시나리오 1: simctl JSON 샘플 파싱 → DeviceInfo 배열

    @Test("simctl JSON 파싱 시 DeviceInfo 배열 반환")
    func parsesSimctlJSONToDeviceInfoArray() {
        let devices = DeviceParser.parseSimctlJSON(simctlJSONFixture)
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

    @Test("devicectl 텍스트 출력 파싱 시 DeviceInfo 배열 반환")
    func parsesDevicectlOutput() {
        let devices = DeviceParser.parseDevicectlOutput(devicectlOutputFixture)
        #expect(devices.count == 2)
    }

    @Test("devicectl 파싱된 디바이스 필드 검증")
    func parsedPhysicalDeviceFields() {
        let devices = DeviceParser.parseDevicectlOutput(devicectlOutputFixture)
        let phone = devices.first { $0.name == "eyephone" }
        #expect(phone != nil)
        #expect(phone?.udid == "6198787F-2780-55F0-B3C4-2756280A1A74")
        #expect(phone?.type == .device)
        #expect(phone?.status == "connected")
        #expect(phone?.os.contains("iPhone 14 Pro") == true)
    }

    @Test("devicectl 파싱 시 multi-word 상태 처리")
    func parsesMultiWordStatus() {
        let devices = DeviceParser.parseDevicectlOutput(devicectlOutputFixture)
        let watch = devices.first { $0.name == "My Apple Watch" }
        #expect(watch != nil)
        #expect(watch?.status == "available (paired)")
        #expect(watch?.udid == "C8C1FD6D-8ED8-5B16-81EF-7657982F4CBA")
    }

    @Test("devicectl 파싱된 디바이스 타입이 device")
    func parsedPhysicalDeviceTypeIsDevice() {
        let devices = DeviceParser.parseDevicectlOutput(devicectlOutputFixture)
        for device in devices {
            #expect(device.type == .device)
        }
    }

    @Test("devicectl 빈 출력 시 빈 배열 반환")
    func emptyDevicectlOutputReturnsEmptyArray() {
        let devices = DeviceParser.parseDevicectlOutput("")
        #expect(devices.isEmpty)
    }

    @Test("devicectl 구분선 없는 출력 시 빈 배열 반환")
    func devicectlWithoutSeparatorReturnsEmpty() {
        let output = "Some random text without separator"
        let devices = DeviceParser.parseDevicectlOutput(output)
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

    // MARK: - 시나리오 6: runWithRunner 통합 경로 (Mock)

    @Test("시뮬레이터 있을 때 printTable 경로 실행")
    func runWithRunnerPrintTablePath() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: simctlJSONFixture, error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock, outputJSON: false)
    }

    @Test("시뮬레이터 있을 때 --json 플래그로 printJSON 경로")
    func runWithRunnerPrintJSONPath() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: simctlJSONFixture, error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock, outputJSON: true)
    }

    @Test("디바이스 없을 때 'No devices found.' 경로")
    func runWithRunnerNoDevicesFound() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: emptySimctlJSON, error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock, outputJSON: false)
    }

    @Test("디바이스 없을 때 --json 빈 배열 출력")
    func runWithRunnerNoDevicesFoundJSON() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: emptySimctlJSON, error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock, outputJSON: true)
    }

    @Test("devicectl exitCode != 0 시 graceful degradation")
    func runWithRunnerDevicectlFailsGracefully() throws {
        let mock = MockDevicesProcessRunner()
        // simctl 성공, devicectl 실패
        mock.simctlResult = ProcessResult(output: simctlJSONFixture, error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "error", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock)
    }

    @Test("devicectl 실행 실패(throw) 시 graceful degradation")
    func runWithRunnerDevicectlThrowsGracefully() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: simctlJSONFixture, error: "", exitCode: 0)
        mock.devicectlShouldThrow = true

        let command = DevicesCommand()
        try command.runWithRunner(mock)
    }

    @Test("simctl 실행 실패 시 graceful degradation")
    func runWithRunnerSimctlThrowsGracefully() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlShouldThrow = true
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 0)

        let command = DevicesCommand()
        try command.runWithRunner(mock)
    }
}

/// DevicesCommand 전용 Mock — simctl과 devicectl을 구분하여 응답
final class MockDevicesProcessRunner: ProcessRunner, @unchecked Sendable {
    var simctlResult = ProcessResult(output: "", error: "", exitCode: 0)
    var devicectlResult = ProcessResult(output: "", error: "", exitCode: 0)
    var simctlShouldThrow = false
    var devicectlShouldThrow = false

    func run(executable: String, arguments: [String]) throws -> ProcessResult {
        if arguments.contains("simctl") {
            if simctlShouldThrow { throw NSError(domain: "test", code: 1) }
            return simctlResult
        }
        if arguments.contains("devicectl") {
            if devicectlShouldThrow { throw NSError(domain: "test", code: 1) }
            return devicectlResult
        }
        return ProcessResult(output: "", error: "", exitCode: 0)
    }

    func stream(
        executable: String,
        arguments: [String],
        timeout: TimeInterval,
        maxLines: Int,
        onLine: @escaping @Sendable (String) -> Void
    ) throws -> ProcessResult {
        ProcessResult(output: "", error: "", exitCode: 0)
    }
}
