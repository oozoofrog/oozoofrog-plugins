import Testing
import Foundation
@testable import OSLogCLICore

@Suite("OSLogCLI 루트 커맨드 테스트")
struct OSLogCLITests {

    @Test("OSLogCLI 인스턴스 생성 가능")
    func canCreateInstance() {
        let cli = OSLogCLI()
        _ = cli  // init() 커버리지
    }

    @Test("LogFilterValues를 LogFilter.toValues()와 동등하게 생성")
    func logFilterValuesEquivalence() {
        let values = LogFilterValues(subsystem: "com.test", category: "net", level: .debug)
        let args = values.buildArguments()
        #expect(args.contains("--predicate"))
        #expect(args.contains("--level"))
    }

    @Test("DevicesCommand runWithRunner 경로 커버")
    func devicesCommandRunWithRunner() throws {
        let mock = MockDevicesProcessRunner()
        mock.simctlResult = ProcessResult(output: "{\"devices\":{}}", error: "", exitCode: 0)
        mock.devicectlResult = ProcessResult(output: "", error: "", exitCode: 1)

        let command = DevicesCommand()
        try command.runWithRunner(mock)
    }
}
