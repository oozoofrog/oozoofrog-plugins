# Common Mistakes (참조 문서 기반)

각 프레임워크에서 자주 발생하는 실수와 올바른 패턴입니다.

## Liquid Glass

```swift
// ❌ Wrong: GlassEffectContainer 없이 여러 뷰에 개별 glassEffect
VStack {
    Text("A").glassEffect()
    Text("B").glassEffect()
}

// ✅ Correct: GlassEffectContainer로 감싸서 morphing 지원
GlassEffectContainer {
    VStack {
        Text("A").glassEffect()
        Text("B").glassEffect()
    }
}
```

## FoundationModels

```swift
// ❌ Wrong: 가용성 체크 없이 바로 세션 생성
let session = LanguageModelSession()

// ✅ Correct: 반드시 가용성 체크 후 사용
let model = SystemLanguageModel.default
guard case .available = model.availability else { return }
let session = LanguageModelSession()
```

## Swift 6.3 C Interop

```swift
// ❌ Wrong: plain Swift 함수를 C에서 바로 호출할 수 있다고 가정
func callFromC() {
    print("Hello")
}

// ✅ Correct: C entry point가 필요하면 @c로 명시
@c(MyLibrary_callFromC)
func callFromC() {
    print("Hello")
}
```

## Swift 6.3 Module Selectors

```swift
// ❌ Wrong: 동일 이름 API가 여러 모듈에 있을 때 암묵적 해석에 의존
import ModuleA
import ModuleB

let value = getValue()

// ✅ Correct: 충돌 지점에서 모듈 선택자를 명시
let valueA = ModuleA::getValue()
let valueB = ModuleB::getValue()
```

## Swift 6.2 Concurrency

```swift
// ❌ Wrong (Swift 6.1): nonisolated async 함수가 백그라운드에서 실행된다고 가정
class PhotoProcessor {
    func process() async { /* 이제 호출자의 actor에서 실행됨 */ }
}

// ✅ Correct (Swift 6.2): 백그라운드 실행이 필요하면 @concurrent 명시
class PhotoProcessor {
    @concurrent
    func process() async { /* 명시적으로 백그라운드 스레드 풀에서 실행 */ }
}
```

### DispatchSemaphore / NSLock — actor로 전환

```swift
// ❌ Wrong: future-work를 동기 차단 (협력적 풀 데드락 위험)
final class ResourcePool {
    private let semaphore = DispatchSemaphore(value: 3)
    func acquire() {
        semaphore.wait()   // 다른 Task의 signal()을 동기 대기
    }
}

// ✅ Correct: actor로 비동기 게이팅
actor ResourcePool {
    private var available: Int = 3
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func acquire() async {
        if available > 0 { available -= 1; return }
        await withCheckedContinuation { waiters.append($0) }
    }
    func release() {
        if let w = waiters.first { waiters.removeFirst(); w.resume() }
        else { available += 1 }
    }
}
```

근거: John McCall (Swift Core Team) — "single scheduled thread만으로도 데드락 가능". 상세는 `references/swift-concurrency-supplement.md` § 1 참조.

### AsyncStream — bufferingPolicy 미지정

```swift
// ❌ Wrong: 기본 .unbounded → producer 빠를 때 메모리 폭주
let stream = AsyncStream<Event> { continuation in
    legacy.onEvent = { continuation.yield($0) }
}

// ✅ Correct: 항상 bufferingPolicy 명시
let (stream, continuation) = AsyncStream.makeStream(
    of: Event.self,
    bufferingPolicy: .bufferingNewest(64)   // 또는 .bufferingOldest(n)
)
```

상세: `references/swift-concurrency-supplement.md` § 4

### withTaskGroup 결과 미소비 — DiscardingTaskGroup으로

```swift
// ❌ Wrong: 결과를 안 쓰면서 일반 TaskGroup → 메모리 누적
await withTaskGroup(of: Void.self) { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}

// ✅ Correct (iOS 18+): 자식 완료 즉시 release
await withDiscardingTaskGroup { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}
```

⚠️ `DiscardingTaskGroup`은 `next()` 메서드 자체가 없어 결과 수집 불가. 결과가 필요하면 일반 `withTaskGroup` 사용.

### lock을 await 가로질러 보유

```swift
// ❌ Wrong: lock 유지한 채 await — forward-progress 위반 위험
let lock = NSLock()
func update() async {
    lock.lock()
    defer { lock.unlock() }
    let data = await fetchRemote()   // 🚫 await across lock
    state.merge(data)
}

// ✅ Correct: lock 밖에서 await, lock은 짧은 critical section만
func update() async {
    let data = await fetchRemote()
    lock.lock()
    defer { lock.unlock() }
    state.merge(data)
}

// ✅ 더 나은 선택: actor로 전환
actor StateStore {
    var state: State = .init()
    func update() async {
        let data = await fetchRemote()
        state.merge(data)
    }
}
```

근거: WWDC21 10254 — "you should be careful not to hold locks across an await". 상세: `references/swift-concurrency-supplement.md` § 1.1 Tier 2

## Swift Testing (6.3)

```swift
// ❌ Wrong: 비치명적 진단까지 테스트 실패로 처리
#expect(cacheMisses.isEmpty)

// ✅ Correct: 결과는 남기되 실패로 만들고 싶지 않으면 warning issue 사용
Issue.record("Cache miss detected during warm-up", severity: .warning)
```

## SwiftData Inheritance

```swift
// ❌ Wrong: 깊은 상속 계층
@Model class A { }
@Model class B: A { }
@Model class C: B { }  // 3단계 이상 → 지양

// ✅ Correct: 얕은 IS-A 관계만
@Model class Trip { var name: String }
@Model class BusinessTrip: Trip { var company: String }
```

## WebKit + SwiftUI

```swift
// ❌ Wrong: URL만으로 WebView 생성 후 상태 관리 불가
WebView(url: URL(string: "https://example.com")!)

// ✅ Correct: WebPage로 상태 관리
@State private var page = WebPage()
// ...
WebView(page)
    .onAppear { page.load(url: URL(string: "https://example.com")!) }
```
