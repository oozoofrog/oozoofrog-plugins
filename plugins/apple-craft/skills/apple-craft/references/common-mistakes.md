# Common Mistakes (based on reference docs)

Common mistakes and correct patterns for each framework.

## Liquid Glass

```swift
// ❌ Wrong: individual glassEffect on multiple views without GlassEffectContainer
VStack {
    Text("A").glassEffect()
    Text("B").glassEffect()
}

// ✅ Correct: wrap in GlassEffectContainer to support morphing
GlassEffectContainer {
    VStack {
        Text("A").glassEffect()
        Text("B").glassEffect()
    }
}
```

## FoundationModels

```swift
// ❌ Wrong: creating a session directly without checking availability
let session = LanguageModelSession()

// ✅ Correct: always check availability before use
let model = SystemLanguageModel.default
guard case .available = model.availability else { return }
let session = LanguageModelSession()
```

## Swift 6.3 C Interop

```swift
// ❌ Wrong: assuming a plain Swift function can be called directly from C
func callFromC() {
    print("Hello")
}

// ✅ Correct: use @c to declare a C entry point when one is needed
@c(MyLibrary_callFromC)
func callFromC() {
    print("Hello")
}
```

## Swift 6.3 Module Selectors

```swift
// ❌ Wrong: relying on implicit resolution when an API of the same name exists in multiple modules
import ModuleA
import ModuleB

let value = getValue()

// ✅ Correct: specify a module selector at the conflict point
let valueA = ModuleA::getValue()
let valueB = ModuleB::getValue()
```

## Swift 6.2 Concurrency

```swift
// ❌ Wrong (Swift 6.1): assuming a nonisolated async function runs in the background
class PhotoProcessor {
    func process() async { /* now runs on the caller's actor */ }
}

// ✅ Correct (Swift 6.2): use @concurrent when background execution is required
class PhotoProcessor {
    @concurrent
    func process() async { /* explicitly runs on the background thread pool */ }
}
```

### DispatchSemaphore / NSLock — migrate to actor

```swift
// ❌ Wrong: synchronously blocking on future work (cooperative pool deadlock risk)
final class ResourcePool {
    private let semaphore = DispatchSemaphore(value: 3)
    func acquire() {
        semaphore.wait()   // synchronously waits for another Task's signal()
    }
}

// ✅ Correct: async gating with an actor
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

Rationale: John McCall (Swift Core Team) — "single scheduled thread만으로도 데드락 가능". See `references/swift-concurrency-supplement.md` § 1 for details.

### AsyncStream — bufferingPolicy unspecified

```swift
// ❌ Wrong: default .unbounded → memory blowup when producer is fast
let stream = AsyncStream<Event> { continuation in
    legacy.onEvent = { continuation.yield($0) }
}

// ✅ Correct: always specify bufferingPolicy
let (stream, continuation) = AsyncStream.makeStream(
    of: Event.self,
    bufferingPolicy: .bufferingNewest(64)   // or .bufferingOldest(n)
)
```

Details: `references/swift-concurrency-supplement.md` § 4

### withTaskGroup results unconsumed — use DiscardingTaskGroup

```swift
// ❌ Wrong: plain TaskGroup while not using results → memory accumulation
await withTaskGroup(of: Void.self) { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}

// ✅ Correct (iOS 18+): release children immediately on completion
await withDiscardingTaskGroup { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}
```

⚠️ `DiscardingTaskGroup` has no `next()` method, so it cannot collect results. Use a plain `withTaskGroup` if you need results.

### holding a lock across an await

```swift
// ❌ Wrong: awaiting while holding a lock — forward-progress violation risk
let lock = NSLock()
func update() async {
    lock.lock()
    defer { lock.unlock() }
    let data = await fetchRemote()   // 🚫 await across lock
    state.merge(data)
}

// ✅ Correct: await outside the lock, keep the lock for a short critical section only
func update() async {
    let data = await fetchRemote()
    lock.lock()
    defer { lock.unlock() }
    state.merge(data)
}

// ✅ Better choice: migrate to an actor
actor StateStore {
    var state: State = .init()
    func update() async {
        let data = await fetchRemote()
        state.merge(data)
    }
}
```

Rationale: WWDC21 10254 — "you should be careful not to hold locks across an await". Details: `references/swift-concurrency-supplement.md` § 1.1 Tier 2

## Swift Testing (6.3)

```swift
// ❌ Wrong: treating even non-fatal diagnostics as test failures
#expect(cacheMisses.isEmpty)

// ✅ Correct: record the result but use a warning issue if you don't want it to fail
Issue.record("Cache miss detected during warm-up", severity: .warning)
```

## SwiftData Inheritance

```swift
// ❌ Wrong: deep inheritance hierarchy
@Model class A { }
@Model class B: A { }
@Model class C: B { }  // 3 levels or more → avoid

// ✅ Correct: shallow IS-A relationships only
@Model class Trip { var name: String }
@Model class BusinessTrip: Trip { var company: String }
```

## WebKit + SwiftUI

```swift
// ❌ Wrong: creating a WebView from a URL only — no state management
WebView(url: URL(string: "https://example.com")!)

// ✅ Correct: state management with WebPage
@State private var page = WebPage()
// ...
WebView(page)
    .onAppear { page.load(url: URL(string: "https://example.com")!) }
```
