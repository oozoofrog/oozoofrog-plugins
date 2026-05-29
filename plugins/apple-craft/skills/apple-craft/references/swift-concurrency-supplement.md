# Swift Concurrency Supplement (oozoofrog policy)

This document is an oozoofrog personal policy and deep-dive guide that supplements the Xcode 26.4 sync originals `swift-concurrency.md` (Apple excerpt) and `swift-6-3-language-and-tooling.md` (Manual supplement).

**Relationship map**:
- `swift-concurrency.md` → Apple original (do not edit, overwritten by sync)
- `swift-6-3-language-and-tooling.md` → Swift 6.3 general tooling/language reinforcement
- **`swift-concurrency-supplement.md` (this document)** → blocking-synchronization policy, SE-0461/SE-0466 deep dive, AsyncStream/TaskGroup/Mutex canonical patterns, verified compilable examples

---

## 1. Blocking-Synchronization Policy — based on Apple's official position

Swift Concurrency's cooperative thread pool holds **only as many threads as CPU cores** and operates on the premise of a forward-progress contract. Synchronization patterns that break this contract can cause a **full deadlock with even a single blocked thread**.

### 1.1 Two-Tier Policy

#### Tier 1 — Absolutely Forbidden (blocks on future-work)

The following patterns **synchronously wait for other work to finish** and directly violate the cooperative pool's forward-progress contract.

| Forbidden pattern | Violation mechanism | Immediate replacement |
|-----------|---------------|-----------|
| `DispatchSemaphore.wait()` | Synchronously waits for another Task's `signal()` → deadlock if on the same pool thread | `actor` + counter |
| `NSCondition` / `pthread_cond_*` | Synchronously waits for another thread's signal | `actor` + `withCheckedContinuation` |
| `DispatchQueue.sync { }` (to return a value) | The Dispatch queue must run on another pool thread | `await actor.method()` |
| `DispatchGroup().wait()` | Synchronously waits for all children to complete | `withTaskGroup` / `withDiscardingTaskGroup` |
| `DispatchGroup().notify(queue:)` (intended to block the current task) | Same | Same |
| `Thread.sleep(forTimeInterval:)` | Sleeps while occupying an OS thread | `try await Task.sleep(for: .seconds(n))` |
| callback → `semaphore.signal()` then `wait()` | classic future-work blocking | `withCheckedContinuation` |

#### Tier 2 — Conditionally Allowed (forward-progress locks)

The following locks **always let the holding thread make forward progress**, so they do not violate the forward-progress contract, but **actors are still preferred**.

| Pattern | Allowed condition | Recommendation |
|------|-----------|------|
| `os_unfair_lock` / `NSLock` / `pthread_rwlock_t` | (1) critical section is very short, (2) **no `await` inside**, (3) unlock guaranteed on the same thread | Convert to `actor` if possible |
| `Mutex<T>` (iOS 18+, `Synchronization`) | `withLock` closure is forced sync, so await-blocking is guaranteed at compile time | Limited to single counters etc. where an actor is overkill |

### 1.2 Official Basis (direct quotes)

> **"Swift Concurrency's scheduling algorithm assumes that threads will never be blocked on 'future work'."**
> — John McCall, Swift Core Team
> ([Swift Forums](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/4))

> **"On Darwin, Dispatch assumes that threads running on behalf of Swift Concurrency never block in this way, so if they violate the rules, the program can actually deadlock with just a single scheduled thread."**
> — John McCall ([same thread #11](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/11))

> **"Avoid waiting on condition variables or semaphores. Fine-grained, briefly-held locks are acceptable if necessary, but avoid locks that have a lot of contention or are held for long periods of time. If you have code that needs to do these things, move that code outside of the concurrency thread pool — for example, by running it on a Dispatch queue — and bridge it to the concurrency world using continuations."**
> — Mike Ash, [WWDC22 110350 "Visualize and optimize Swift concurrency"](https://developer.apple.com/videos/play/wwdc2022/110350/)

> **"Primitives like semaphores and condition variables are unsafe to use with Swift concurrency. This is because they hide dependency information from the Swift runtime, but introduce a dependency in execution in your code."**
> — Rokhini Prabhu, [WWDC21 10254 "Swift concurrency: Behind the scenes"](https://developer.apple.com/videos/play/wwdc2021/10254/)

> **"Reader-writer locks are not otherwise problematic in Swift Concurrency, except that you must take care to unlock them from the same thread that locked them — which is to say, don't `await` while holding a lock."**
> — John McCall ([Swift Forums #4](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/4))

### 1.3 Verification Tool

```bash
# Environment variable for the Xcode scheme's Run / Test arguments
LIBDISPATCH_COOPERATIVE_POOL_STRICT=1
```

The debug-runtime strict mode officially announced by Apple at WWDC21. Detects forward-progress violations in the cooperative pool immediately. Recommended to enable in dev/test builds.

---

## 2. SE-0461 Deep Dive — `@concurrent` / `nonisolated(nonsending)`

The Apple original `swift-concurrency.md` only shows usage examples of `@concurrent` and does not cover the precise specification. This section summarizes the precise specification from the [SE-0461 source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md).

### 2.1 `@concurrent` Precise Specification

Declares in the signature that the function **always hops to the global executor**. If the caller is on an actor, Sendable checks are enforced on arguments/return values.

**Constraints (stated in SE-0461)**:
- Cannot be applied to synchronous functions — *"This is an artificial limitation that could later be lifted"*
- Cannot combine with other isolation: global actor, isolated parameter, and `@isolated(any)` all produce compile errors
- Can be used together with `@Sendable` and `sending`

**Compile error messages (quoted from SE-0461)**:
```
error: global function 'runsOnMainActor()' has multiple actor-isolation
       attributes (@MainActor and @concurrent)
error: cannot use @concurrent on global function 'runsSomewhere(isolation:)'
       because it has an isolated parameter: 'isolation'
error: cannot use '@concurrent' together with '@isolated(any)'
```

**Constraint examples (quoted from SE-0461)**:
```swift
@MainActor @concurrent func runsOnMainActor() async {}        // error
@concurrent func runsSomewhere(isolation: isolated (any Actor)?) async {}  // error
func longCompute(fn: @concurrent @isolated(any) () async -> Void) async {} // error

actor MyActor {
    var value = 0
    @concurrent
    func isolatedToSelf() async {
        value += 1   // error: cannot access actor-isolated state
    }
}
```

### 2.2 `nonisolated(nonsending)` Precise Specification

An async function that **runs as-is on the caller's actor**. The function takes an **implicit actor parameter** and does not cross an isolation boundary.

> "This behavior is accomplished by implicitly passing an optional actor parameter to the async function. The function will run on this actor's executor." — SE-0461

**Important pitfall**: creating a `Task { }` inside the body of a `nonisolated(nonsending)` function **does not inherit the caller actor** (same as sync `nonisolated`). Because of this, the `Task { lock.wait() }` pattern inside the function can deadlock.

```swift
// SE-0461 quote (lines 269–285)
class NotSendable {
    func performSync() { ... }

    nonisolated(nonsending)
    func performAsync() async { ... }
}

actor MyActor {
    let x: NotSendable
    func call() async {
        x.performSync()        // okay
        await x.performAsync() // okay (NotSendable does not leave the actor)
    }
}
```

### 2.3 `NonisolatedNonsendingByDefault` upcoming flag

- **Exact name**: `NonisolatedNonsendingByDefault`
- **Enabling** (standard Swift upcoming-feature mechanism):

```swift
// Package.swift
.target(
    name: "MyApp",
    swiftSettings: [
        .enableUpcomingFeature("NonisolatedNonsendingByDefault")
    ]
)
```

```bash
# Direct compiler flag
-enable-upcoming-feature NonisolatedNonsendingByDefault
```

When enabled, a plain `func foo() async` is automatically interpreted with `nonisolated(nonsending)` semantics. When disabled, it keeps the previous `@concurrent` semantics.

### 2.4 ABI Impact

Switching between `@concurrent` ↔ `nonisolated(nonsending)` is an **ABI change** (adding/removing the implicit actor parameter). When writing resilient libraries, a dual-entry-point pattern is needed. Irrelevant for app targets.

---

## 3. SE-0466 Deep Dive — Module-Wide Default Isolation

[SE-0466 source](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md). For UI apps, scripts, and executable targets, the entire module can be inferred as the main actor without attaching `@MainActor` every time.

### 3.1 Build Flags

```bash
-default-isolation MainActor    # all unannotated declarations become @MainActor
-default-isolation nonisolated  # explicit default (same as not specifying)
```

> "The only valid arguments to `-default-isolation` are `MainActor` and `nonisolated`. It is an error to specify both `-default-isolation MainActor` and `-default-isolation nonisolated`." — SE-0466

Custom global actors are not allowed (stated in the proposal).

### 3.2 SwiftPM `.defaultIsolation` API

```swift
extension SwiftSetting {
    @available(_PackageDescription, introduced: 6.2)
    public static func defaultIsolation(
        _ globalActor: MainActor.Type?,
        _ condition: BuildSettingCondition? = nil
    ) -> SwiftSetting
}
```

**Allowed values**: `MainActor.self` or `nil` only (anything else is a compile error).

```swift
// Package.swift
.target(
    name: "MyApp",
    swiftSettings: [
        .defaultIsolation(MainActor.self)   // UI module
    ]
)

.target(
    name: "MyDomain",
    swiftSettings: [
        .defaultIsolation(nil)              // explicit nonisolated (same as omitting)
    ]
)
```

### 3.3 Isolation Inference Exceptions (false-positive prevention)

Even when `-default-isolation MainActor` is ON, the following are **automatically nonisolated**:

1. Declarations with explicit actor isolation
2. Inherited isolation (superclass / overridden / protocol conformance / member propagation)
3. All declarations inside an `actor` type (including static var, method, init, deinit)
4. typealias, import statements, enum case, individual accessors (a global actor itself is not allowed)
5. **Types that directly conform to a protocol inheriting `SendableMetatype`**
6. Types nested inside a nonisolated type

`Sendable`, `Codable` (→ `Encodable`/`Decodable` inherit `SendableMetatype`), `CodingKey`, `Transferable`, etc. are inferred as automatically nonisolated by rule 5. That is:

```swift
// Under -default-isolation MainActor

struct S: Codable {            // @MainActor (Codable does not directly inherit SendableMetatype)
    var a: Int
    enum CodingKeys: CodingKey { // nonisolated (CodingKey inherits SendableMetatype)
        case a
    }
}
```

---

## 4. AsyncStream Recommended Pattern — `makeStream(of:)`

Since iOS 17, `AsyncStream.makeStream(of:bufferingPolicy:)` is **officially recommended**. It returns a `(stream, continuation)` tuple, making it easy to retain the continuation externally — the best fit for delegate/callback bridges.

### 4.1 Precise Signature

```swift
@backDeployed(before: macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0)
static func makeStream(
    of elementType: Element.Type = Element.self,
    bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
) -> (stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation)
```

**`BufferingPolicy` cases** (Sendable):
- `.unbounded` — unlimited buffer (⚠️ default; memory blowup when producer ≫ consumer)
- `.bufferingOldest(Int)` — when full, discards **new** elements (keeps the old)
- `.bufferingNewest(Int)` — when full, discards **old** elements (keeps the newest)

⚠️ The enum names are counterintuitive. "Newest = **keep** new elements", "Oldest = **keep** old elements".

### 4.2 Beware of Termination Differences

| Type | Termination case |
|------|------|
| `AsyncStream.Continuation.Termination` | `.finished`, `.cancelled` (no associated value) |
| `AsyncThrowingStream.Continuation.Termination` | `.finished(Failure?)`, `.cancelled` |

Confusing the two types breaks pattern matching, so be careful.

### 4.3 CLLocationManager Canonical Bridge (verified)

`CLLocationManagerDelegate` inherits `NSObjectProtocol` → the adopting class **must inherit from NSObject**. If the delegate is not set, callbacks are never invoked.

```swift
import CoreLocation

@MainActor
final class LocationBridge: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: AsyncStream<CLLocation>.Continuation?

    let stream: AsyncStream<CLLocation>

    override init() {
        var localContinuation: AsyncStream<CLLocation>.Continuation!
        self.stream = AsyncStream(bufferingPolicy: .bufferingNewest(1)) { c in
            localContinuation = c
        }
        super.init()
        self.continuation = localContinuation
        manager.delegate = self                       // key: set delegate after super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest

        continuation?.onTermination = { [weak manager] termination in
            // termination: .finished | .cancelled
            Task { @MainActor in manager?.stopUpdatingLocation() }
        }
    }

    func start() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            continuation?.finish()
        }
    }

    // CLLocationManagerDelegate (nonisolated — called on the delegate runloop)

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            for loc in locations { continuation?.yield(loc) }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailWithError error: any Error) {
        Task { @MainActor in continuation?.finish() }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
}
```

**Key rules**:
- Always specify `bufferingPolicy`
- Delegate methods should hop with `nonisolated` + `Task { @MainActor in ... }`
- The `NSLocationWhenInUseUsageDescription` key is required in `Info.plist` (prevents a runtime crash)
- iOS 17+ alternative: `CLLocationUpdate.liveUpdates(_:)` (provides an AsyncSequence directly)

---

## 5. TaskGroup vs DiscardingTaskGroup

### 5.1 Decision Table

| Pattern | Use | Key characteristic |
|------|------|-----------|
| `withTaskGroup(of:)` | Collect child results to reduce/array | Memory accumulates if results are not consumed |
| `withThrowingTaskGroup(of:)` | Above + error propagation | Cancelling the group on the first throw requires an explicit call |
| `withDiscardingTaskGroup` (iOS 18+, back-deployed) | Side-effects only, results discarded | Releases each child immediately on completion |
| `withThrowingDiscardingTaskGroup` (iOS 18+, back-deployed) | Above + **automatically cancels the group when a child throws** | Server/listener pattern |

> "A throwing discarding task group becomes canceled when *any* of its child tasks throws." — [Apple Developer Documentation](https://developer.apple.com/documentation/swift/throwingdiscardingtaskgroup#Cancellation-behavior)

### 5.2 Absence of the next() Method

`DiscardingTaskGroup` **has no `next()` method at all**. Retrieving results is impossible by definition. If you need results, use a regular `TaskGroup`.

### 5.3 Verified Example

```swift
// ✅ DiscardingTaskGroup — release each child immediately on completion
func processFireAndForget(_ urls: [URL]) async {
    await withDiscardingTaskGroup { group in
        for url in urls {
            group.addTask {
                _ = try? await URLSession.shared.data(from: url)
            }
        }
        // all children awaited automatically when the body ends
    }
}

// ✅ ThrowingDiscardingTaskGroup — any throw → whole group auto-cancelled
func runListeners(_ listeners: [Listener]) async throws {
    try await withThrowingDiscardingTaskGroup { group in
        for listener in listeners {
            group.addTask { try await listener.run() }
        }
    }
}
```

### 5.4 Bounded Concurrency (Sliding Window)

Prevents resource explosion with a `maxConcurrent` limit. **Result-collecting cases use a regular TaskGroup**; side-effect-only cases use DiscardingTaskGroup, but window sliding is impossible because it has no `next()`.

```swift
func processAll<T: Sendable, R: Sendable>(
    _ items: [T],
    maxConcurrent: Int,
    work: @Sendable @escaping (T) async -> R
) async -> [R] {
    await withTaskGroup(of: R.self) { group in
        var iterator = items.makeIterator()

        // 1) fill the initial window
        for _ in 0..<maxConcurrent {
            guard let item = iterator.next() else { break }
            group.addTask { await work(item) }
        }

        // 2) add the next task each time one finishes
        var results: [R] = []
        for await result in group {
            results.append(result)
            if let next = iterator.next() {
                group.addTask { await work(next) }
            }
        }
        return results
    }
}
```

---

## 6. `Mutex<T>` (iOS 18+, Synchronization)

### 6.1 Precise Signature

```swift
import Synchronization

@frozen struct Mutex<Value> where Value: ~Copyable

init(_ initialValue: consuming sending Value)

borrowing func withLock<Result, E>(
    _ body: (inout sending Value) throws(E) -> sending Result
) throws(E) -> sending Result where E: Error, Result: ~Copyable
```

**Availability**: macOS 15+, iOS 18+, watchOS 11+, tvOS 18+, visionOS 2+

### 6.2 Usage Condition (core team guidance)

> "default to actors, unless you have reasons not to. And one such reason could be that you're building a concurrent data-structure."
> — Konrad Malawski (Apple), [SE-0433 guidance thread](https://forums.swift.org/t/se-0433-mutex-vs-actor-general-advice/71338/7)

> "Deadlocks are not possible with the actor model" whereas mutexes are "prone to deadlocks ... and live-locks."
> — [SE-0433 body](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0433-mutex.md)

**Conditions allowing Mutex<T>**:
1. The critical section is very short, and
2. **No `await` is used inside the `withLock` closure** (signature forces sync → blocked by a compile error)
3. Only when the actor hop cost is burdensome

```swift
import Synchronization

final class HitCounter: Sendable {
    private let count = Mutex<Int>(0)

    func increment() {
        count.withLock { value in
            value += 1
            // ❌ writing await here is a compile error — withLock is a non-async closure
        }
    }

    func current() -> Int {
        count.withLock { $0 }
    }
}
```

---

## 7. Continuation + URLSession Cancellation Pattern

### 7.1 Hallucination Correction

**`URLSessionDataTask.completionHandler` does not exist as a mutable property.** completionHandler is only received from the `URLSession.dataTask(with:completionHandler:)` factory. Patterns in some earlier material that used it like a setter are hallucinations.

### 7.2 Recommended Pattern (sufficient in most cases)

URLSession async APIs **respond to Task cancellation automatically**.

```swift
// simplest and recommended
func fetch(_ url: URL) async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

### 7.3 When an Explicit Cancellation Hook Is Truly Needed

**In most cases the § 7.2 pattern is sufficient.** URLSession async APIs respond to Task cancellation automatically.

Scenarios where an explicit hook is truly needed are very rare (e.g. combining a download/streaming task's progress callback with an external cancel signal). The canonical approach for such cases:

1. **Implement `URLSessionDataDelegate` / `URLSessionDownloadDelegate` as a separate class** — pass it to the async API via the `delegate:` parameter (iOS 15+)
2. Capture the task handle in the delegate to handle external cancel signals
3. Or receive the task from the `dataTask(with:completionHandler:)` factory and deliver the result directly to a continuation — but in this case, to avoid a Sendable race when capturing the task variable, separate synchronization is needed such as a `final class` holder + `Mutex<URLSessionDataTask?>`

**Wrong patterns (code not shown for illustration — beware of the following anti-patterns)**:
- Creating task A with `dataTask(with:url)` and separately calling `data(from:url)` inside `withCheckedThrowingContinuation` causes **two distinct HTTP requests**, and cancellation only cancels task A → the actual result request is not cancelled
- Trying to receive the result with `Task { try await ... }` inside the continuation closure causes the same race

**Recommendation**: use the § 7.2 pattern as the default, and if the above scenario is truly needed, refer to the "Bridging from sync to async" pattern from [WWDC21 10254](https://developer.apple.com/videos/play/wwdc2021/10254/) and implement it per project.

### 7.4 ResourcePool actor + CheckedContinuation

CheckedContinuation is Sendable, so it can be safely held as an actor stored property.

```swift
actor ResourcePool<Resource: Sendable> {
    private var available: [Resource]
    private var waiters: [CheckedContinuation<Resource, Never>] = []

    init(_ resources: [Resource]) { self.available = resources }

    func acquire() async -> Resource {
        if let r = available.popLast() { return r }
        return await withCheckedContinuation { cont in
            // this closure runs inside actor isolation → mutating self is safe
            waiters.append(cont)
        }
    }

    func release(_ resource: Resource) {
        if let waiter = waiters.first {
            waiters.removeFirst()
            waiter.resume(returning: resource)
        } else {
            available.append(resource)
        }
    }
}
```

---

## 8. Policy Application Checklist

When reviewing/implementing apple-craft code:

- [ ] Search for **`DispatchSemaphore`, `NSCondition`, `pthread_cond_*`, `dispatch_sync`, `DispatchGroup.wait()`** → if found, convert to actor or TaskGroup
- [ ] **`Thread.sleep`** → `Task.sleep(for:)`
- [ ] Check whether a lock is **held across an `await`** (Tier 2 lock-specific check)
- [ ] Whether **`bufferingPolicy` is specified when creating `AsyncStream { ... }`**
- [ ] **`withTaskGroup(of: Void.self)`** pattern → if side-effect only, switch to `withDiscardingTaskGroup`
- [ ] Clear intent among **`@concurrent` vs `nonisolated(nonsending)` vs `@MainActor` vs actor method**
- [ ] Consider applying `.defaultIsolation(MainActor.self)` to UI app targets
- [ ] Set the `LIBDISPATCH_COOPERATIVE_POOL_STRICT=1` environment variable in debug builds

---

## 9. Sources

### Swift Evolution
- [SE-0461 — Run nonisolated async functions on the caller's actor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [SE-0466 — Control Default Actor Isolation Inference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [SE-0433 — Synchronous Mutual Exclusion Lock (Mutex)](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0433-mutex.md)
- [SE-0470 — `SendableMetatype`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md)
- [Vision: Approachable Concurrency](https://github.com/swiftlang/swift-evolution/blob/main/visions/approachable-concurrency.md)

### Apple Developer Documentation
- [`AsyncStream.makeStream(of:bufferingPolicy:)`](https://developer.apple.com/documentation/swift/asyncstream/makestream(of:bufferingpolicy:))
- [`AsyncStream.Continuation.onTermination`](https://developer.apple.com/documentation/swift/asyncstream/continuation/ontermination)
- [`AsyncStream.Continuation.Termination`](https://developer.apple.com/documentation/swift/asyncstream/continuation/termination)
- [`DiscardingTaskGroup`](https://developer.apple.com/documentation/swift/discardingtaskgroup)
- [`ThrowingDiscardingTaskGroup`](https://developer.apple.com/documentation/swift/throwingdiscardingtaskgroup)
- [`Mutex`](https://developer.apple.com/documentation/synchronization/mutex)
- [`Mutex.withLock(_:)`](https://developer.apple.com/documentation/synchronization/mutex/withlock(_:))
- [`Task.init(name:priority:operation:)`](https://developer.apple.com/documentation/swift/task/init(name:priority:operation:)-2dll5)
- [`CLLocationManager.delegate`](https://developer.apple.com/documentation/corelocation/cllocationmanager/delegate)
- [`URLSession.data(from:delegate:)`](https://developer.apple.com/documentation/foundation/urlsession/data(from:delegate:))
- [`withTaskCancellationHandler(operation:onCancel:isolation:)`](https://developer.apple.com/documentation/swift/withtaskcancellationhandler(operation:oncancel:isolation:))
- [`CheckedContinuation`](https://developer.apple.com/documentation/swift/checkedcontinuation)

### WWDC
- [WWDC25 268 — Embracing Swift concurrency (Doug Gregor)](https://developer.apple.com/videos/play/wwdc2025/268/)
- [WWDC22 110350 — Visualize and optimize Swift concurrency (Mike Ash, Harjas Monga)](https://developer.apple.com/videos/play/wwdc2022/110350/)
- [WWDC21 10254 — Swift concurrency: Behind the scenes (Rokhini Prabhu, Varun Gandhi)](https://developer.apple.com/videos/play/wwdc2021/10254/)

### Swift Forums (Core Team)
- [Why are semaphores, conditions, and read-write locks unsafe in Swift Concurrency?](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046) — John McCall posts #4, #11, #12
- [Cooperative pool deadlock when calling into an opaque subsystem](https://forums.swift.org/t/cooperative-pool-deadlock-when-calling-into-an-opaque-subsystem/70685) — John McCall, Joe Groff
- [Task's Forward Progress with sync code](https://forums.swift.org/t/tasks-forward-progress-with-sync-code/58112) — John McCall #3, Konrad Malawski #7
- [SE-0433 Mutex vs actor – General advice?](https://forums.swift.org/t/se-0433-mutex-vs-actor-general-advice/71338) — Konrad Malawski #7
