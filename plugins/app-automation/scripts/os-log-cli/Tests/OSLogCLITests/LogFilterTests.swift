import Testing
@testable import OSLogCLICore

@Suite("LogFilter 유닛 테스트")
struct LogFilterTests {

    // MARK: - 시나리오 1: 모든 옵션 nil → 빈 배열

    @Test("모든 옵션이 nil이면 빈 배열 반환")
    func allOptionsNilReturnsEmptyArray() {
        var filter = LogFilter()
        filter.subsystem = nil
        filter.category = nil
        filter.level = nil
        filter.process = nil
        filter.predicate = nil
        filter.device = nil

        let args = filter.buildArguments()
        #expect(args.isEmpty)
    }

    // MARK: - 시나리오 2: --subsystem만 설정

    @Test("subsystem만 설정 시 NSPredicate 형식 인자 생성")
    func subsystemOnlyGeneratesPredicate() {
        var filter = LogFilter()
        filter.subsystem = "com.example.myapp"

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--predicate")
        #expect(args[1] == #"subsystem == "com.example.myapp""#)
    }

    // MARK: - 시나리오 3: --category + --level 조합

    @Test("category와 level 조합 시 올바른 인자 순서")
    func categoryAndLevelCombination() {
        var filter = LogFilter()
        filter.category = "network"
        filter.level = .debug

        let args = filter.buildArguments()
        // predicate 2개 + level 2개
        #expect(args.count == 4)
        #expect(args[0] == "--predicate")
        #expect(args[1] == #"category == "network""#)
        #expect(args[2] == "--level")
        #expect(args[3] == "debug")
    }

    @Test("subsystem과 category 동시 설정 시 AND로 조합")
    func subsystemAndCategoryANDPredicate() {
        var filter = LogFilter()
        filter.subsystem = "com.example"
        filter.category = "auth"

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--predicate")
        #expect(args[1] == #"subsystem == "com.example" AND category == "auth""#)
    }

    // MARK: - 시나리오 4: --predicate 직접 설정

    @Test("predicate 직접 설정 시 그대로 전달")
    func directPredicatePassthrough() {
        var filter = LogFilter()
        filter.predicate = #"subsystem == "com.x" AND messageType == fault"#

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--predicate")
        #expect(args[1] == #"subsystem == "com.x" AND messageType == fault"#)
    }

    @Test("predicate와 subsystem 동시 설정 시 predicate 우선")
    func predicateOverridesSubsystem() {
        var filter = LogFilter()
        filter.predicate = "messageType == error"
        filter.subsystem = "com.ignored"

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--predicate")
        #expect(args[1] == "messageType == error")
    }

    // MARK: - 시나리오 5: --device 설정

    @Test("device 설정 시 인자 포함")
    func deviceArgumentIncluded() {
        var filter = LogFilter()
        filter.device = "00000000-AAAA-BBBB-CCCC-000000000001"

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--device")
        #expect(args[1] == "00000000-AAAA-BBBB-CCCC-000000000001")
    }

    // MARK: - 레벨 5종 각각 검증

    @Test("level=default 인자 생성")
    func levelDefault() {
        var filter = LogFilter()
        filter.level = .default

        let args = filter.buildArguments()
        #expect(args.contains("--level"))
        let idx = args.firstIndex(of: "--level")
        #expect(idx != nil)
        if let idx {
            #expect(args[args.index(after: idx)] == "default")
        }
    }

    @Test("level=info 인자 생성")
    func levelInfo() {
        var filter = LogFilter()
        filter.level = .info

        let args = filter.buildArguments()
        let idx = args.firstIndex(of: "--level")
        #expect(idx != nil)
        if let idx {
            #expect(args[args.index(after: idx)] == "info")
        }
    }

    @Test("level=debug 인자 생성")
    func levelDebug() {
        var filter = LogFilter()
        filter.level = .debug

        let args = filter.buildArguments()
        let idx = args.firstIndex(of: "--level")
        #expect(idx != nil)
        if let idx {
            #expect(args[args.index(after: idx)] == "debug")
        }
    }

    @Test("level=error 인자 생성")
    func levelError() {
        var filter = LogFilter()
        filter.level = .error

        let args = filter.buildArguments()
        let idx = args.firstIndex(of: "--level")
        #expect(idx != nil)
        if let idx {
            #expect(args[args.index(after: idx)] == "error")
        }
    }

    @Test("level=fault 인자 생성")
    func levelFault() {
        var filter = LogFilter()
        filter.level = .fault

        let args = filter.buildArguments()
        let idx = args.firstIndex(of: "--level")
        #expect(idx != nil)
        if let idx {
            #expect(args[args.index(after: idx)] == "fault")
        }
    }

    // MARK: - process 옵션

    @Test("process 설정 시 인자 포함")
    func processArgumentIncluded() {
        var filter = LogFilter()
        filter.process = "MyApp"

        let args = filter.buildArguments()
        #expect(args.count == 2)
        #expect(args[0] == "--process")
        #expect(args[1] == "MyApp")
    }

    // MARK: - 전체 조합

    @Test("모든 옵션 설정 시 올바른 인자 순서")
    func allOptionsSetCorrectOrder() {
        var filter = LogFilter()
        filter.subsystem = "com.test"
        filter.level = .error
        filter.process = "TestApp"
        filter.device = "DEVICE-UDID"

        let args = filter.buildArguments()
        #expect(args.contains("--predicate"))
        #expect(args.contains("--level"))
        #expect(args.contains("--process"))
        #expect(args.contains("--device"))
    }
}
