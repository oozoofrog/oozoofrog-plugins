# Swift Concurrency Supplement (oozoofrog policy)

이 문서는 Xcode 26.4 sync 원본인 `swift-concurrency.md`(Apple 발췌)와 `swift-6-3-language-and-tooling.md`(Manual supplement)를 보충하는 oozoofrog 개인 정책·심화 가이드입니다.

**관계도**:
- `swift-concurrency.md` → Apple 원본 (수정 금지, sync로 덮어씀)
- `swift-6-3-language-and-tooling.md` → Swift 6.3 일반 도구/언어 보강
- **`swift-concurrency-supplement.md`(본 문서)** → 차단형 동기화 정책, SE-0461/SE-0466 심화, AsyncStream/TaskGroup/Mutex 정석 패턴, 검증된 컴파일 가능 예제

---

## 1. 차단형 동기화 정책 — Apple 공식 입장 기반

Swift Concurrency의 협력적 스레드 풀(cooperative thread pool)은 **CPU 코어 수만큼만** 스레드를 보유하며 forward-progress 계약을 전제로 동작합니다. 이 계약을 깨는 동기화 패턴은 **단 하나의 스레드 차단만으로도 전체 데드락**을 유발할 수 있습니다.

### 1.1 두 단계 정책

#### Tier 1 — 절대 금지 (future-work 차단)

다음 패턴은 **다른 작업이 끝나기를 동기적으로 기다리는** 형태이며, 협력적 풀의 forward-progress 계약을 직접 위반합니다.

| 금지 패턴 | 위반 메커니즘 | 즉시 대체 |
|-----------|---------------|-----------|
| `DispatchSemaphore.wait()` | 다른 Task의 `signal()`을 동기 대기 → 같은 풀 스레드면 데드락 | `actor` + 카운터 |
| `NSCondition` / `pthread_cond_*` | 다른 스레드 시그널 동기 대기 | `actor` + `withCheckedContinuation` |
| `DispatchQueue.sync { }` (값 반환 목적) | Dispatch 큐가 다른 풀 스레드에서 실행되어야 함 | `await actor.method()` |
| `DispatchGroup().wait()` | 모든 자식 완료 동기 대기 | `withTaskGroup` / `withDiscardingTaskGroup` |
| `DispatchGroup().notify(queue:)` (현재 task 차단 의도) | 동일 | 동일 |
| `Thread.sleep(forTimeInterval:)` | OS 스레드 점유한 채 sleep | `try await Task.sleep(for: .seconds(n))` |
| 콜백 → `semaphore.signal()` 후 `wait()` | classic future-work 차단 | `withCheckedContinuation` |

#### Tier 2 — 조건부 허용 (forward-progress 락)

다음 락은 **자신을 보유한 스레드가 항상 전진**하므로 forward-progress 계약을 위반하지 않지만, 여전히 **actor가 우선**입니다.

| 패턴 | 허용 조건 | 권장 |
|------|-----------|------|
| `os_unfair_lock` / `NSLock` / `pthread_rwlock_t` | (1) critical section이 매우 짧고 (2) **내부에서 `await` 금지** (3) 같은 스레드에서 unlock 보장 | 가능하면 `actor`로 전환 |
| `Mutex<T>` (iOS 18+, `Synchronization`) | `withLock` 클로저가 sync로 강제되어 await 차단이 컴파일 시점에 보장 | actor가 과한 단일 카운터 등에 한정 |

### 1.2 공식 근거 (직접 인용)

> **"Swift Concurrency's scheduling algorithm assumes that threads will never be blocked on 'future work'."**
> — John McCall, Swift Core Team
> ([Swift Forums](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/4))

> **"On Darwin, Dispatch assumes that threads running on behalf of Swift Concurrency never block in this way, so if they violate the rules, the program can actually deadlock with just a single scheduled thread."**
> — John McCall ([같은 스레드 #11](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/11))

> **"Avoid waiting on condition variables or semaphores. Fine-grained, briefly-held locks are acceptable if necessary, but avoid locks that have a lot of contention or are held for long periods of time. If you have code that needs to do these things, move that code outside of the concurrency thread pool — for example, by running it on a Dispatch queue — and bridge it to the concurrency world using continuations."**
> — Mike Ash, [WWDC22 110350 "Visualize and optimize Swift concurrency"](https://developer.apple.com/videos/play/wwdc2022/110350/)

> **"Primitives like semaphores and condition variables are unsafe to use with Swift concurrency. This is because they hide dependency information from the Swift runtime, but introduce a dependency in execution in your code."**
> — Rokhini Prabhu, [WWDC21 10254 "Swift concurrency: Behind the scenes"](https://developer.apple.com/videos/play/wwdc2021/10254/)

> **"Reader-writer locks are not otherwise problematic in Swift Concurrency, except that you must take care to unlock them from the same thread that locked them — which is to say, don't `await` while holding a lock."**
> — John McCall ([Swift Forums #4](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046/4))

### 1.3 검증 도구

```bash
# Xcode scheme의 Run / Test arguments 환경변수
LIBDISPATCH_COOPERATIVE_POOL_STRICT=1
```

WWDC21에서 Apple이 공식 안내한 디버그 런타임 강제 모드. 협력적 풀에서 forward-progress 위반 시 즉시 검출. 개발/테스트 빌드에 활성화 권장.

---

## 2. SE-0461 심화 — `@concurrent` / `nonisolated(nonsending)`

Apple 원본 `swift-concurrency.md`는 `@concurrent`의 사용 예만 보여주고 정확한 사양은 다루지 않습니다. 이 절은 [SE-0461 원문](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)의 정확한 사양을 정리합니다.

### 2.1 `@concurrent` 정확한 사양

함수가 **항상 글로벌 executor**로 점프하도록 시그니처에 명시. 호출자가 액터에 있으면 인자/반환값에 Sendable 체크가 강제됩니다.

**제약 (SE-0461 명시)**:
- 동기 함수에 적용 불가 — *"This is an artificial limitation that could later be lifted"*
- 다른 isolation과 조합 금지: global actor, isolated parameter, `@isolated(any)` 모두 컴파일 에러
- `@Sendable`, `sending`과는 함께 사용 가능

**컴파일 에러 메시지 (SE-0461 인용)**:
```
error: global function 'runsOnMainActor()' has multiple actor-isolation
       attributes (@MainActor and @concurrent)
error: cannot use @concurrent on global function 'runsSomewhere(isolation:)'
       because it has an isolated parameter: 'isolation'
error: cannot use '@concurrent' together with '@isolated(any)'
```

**제약 예시 (SE-0461 인용)**:
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

### 2.2 `nonisolated(nonsending)` 정확한 사양

호출자의 액터에서 **그대로 실행**되는 async 함수. 함수가 **암시적 actor 파라미터**를 받아 격리 경계를 넘지 않습니다.

> "This behavior is accomplished by implicitly passing an optional actor parameter to the async function. The function will run on this actor's executor." — SE-0461

**중요한 함정**: `nonisolated(nonsending)` 함수 본문에서 `Task { }`를 만들면 **caller actor를 상속하지 않습니다** (sync `nonisolated`와 동일). 이 때문에 함수 내부에서 `Task { lock.wait() }` 패턴은 데드락 가능.

```swift
// SE-0461 인용 (lines 269–285)
class NotSendable {
    func performSync() { ... }

    nonisolated(nonsending)
    func performAsync() async { ... }
}

actor MyActor {
    let x: NotSendable
    func call() async {
        x.performSync()        // okay
        await x.performAsync() // okay (NotSendable이 actor를 떠나지 않음)
    }
}
```

### 2.3 `NonisolatedNonsendingByDefault` upcoming flag

- **정확한 명칭**: `NonisolatedNonsendingByDefault`
- **활성화** (Swift upcoming-feature 표준 메커니즘):

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
# 컴파일러 직접 플래그
-enable-upcoming-feature NonisolatedNonsendingByDefault
```

활성화 시 평범한 `func foo() async`가 자동으로 `nonisolated(nonsending)` 의미로 해석. 미활성 시 종전대로 `@concurrent` 의미.

### 2.4 ABI 영향

`@concurrent` ↔ `nonisolated(nonsending)` 전환은 **ABI 변경** (암시적 actor parameter 추가/제거). resilient 라이브러리 작성 시 dual-entry-point 패턴 필요. 앱 타깃에서는 무관.

---

## 3. SE-0466 심화 — 모듈 단위 기본 격리

[SE-0466 원문](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md). UI 앱·스크립트·executable 타깃에서 매번 `@MainActor`를 붙이지 않아도 모듈 전체를 메인 액터로 추론할 수 있습니다.

### 3.1 빌드 플래그

```bash
-default-isolation MainActor    # 미주석 선언이 모두 @MainActor
-default-isolation nonisolated  # 명시적 기본값 (지정하지 않은 것과 동일)
```

> "The only valid arguments to `-default-isolation` are `MainActor` and `nonisolated`. It is an error to specify both `-default-isolation MainActor` and `-default-isolation nonisolated`." — SE-0466

custom global actor는 허용되지 않음 (proposal 명시).

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

**허용 값**: `MainActor.self` 또는 `nil`만 (그 외 컴파일 에러).

```swift
// Package.swift
.target(
    name: "MyApp",
    swiftSettings: [
        .defaultIsolation(MainActor.self)   // UI 모듈
    ]
)

.target(
    name: "MyDomain",
    swiftSettings: [
        .defaultIsolation(nil)              // 명시적 nonisolated (생략과 동일)
    ]
)
```

### 3.3 격리 추론 예외 (false-positive 방지)

`-default-isolation MainActor` ON일 때도 다음은 **자동으로 nonisolated**:

1. 명시적 actor isolation이 있는 선언
2. 상속받은 isolation (superclass / overridden / protocol conformance / member propagation)
3. `actor` 타입 내부의 모든 선언 (static var, method, init, deinit 포함)
4. typealias, import 문, enum case, 개별 accessor (global actor 자체 불가)
5. **`SendableMetatype`을 상속하는 protocol에 직접 conform하는 타입**
6. nonisolated 타입 안에 중첩된 타입

`Sendable`, `Codable`(→ `Encodable`/`Decodable`이 `SendableMetatype` 상속), `CodingKey`, `Transferable` 등은 5번 규칙으로 자동 nonisolated 추론. 즉:

```swift
// -default-isolation MainActor 하에서

struct S: Codable {            // @MainActor (Codable은 직접 SendableMetatype 상속 X)
    var a: Int
    enum CodingKeys: CodingKey { // nonisolated (CodingKey는 SendableMetatype 상속)
        case a
    }
}
```

---

## 4. AsyncStream 권장 패턴 — `makeStream(of:)`

iOS 17부터 `AsyncStream.makeStream(of:bufferingPolicy:)`가 **공식 권장**입니다. `(stream, continuation)` 튜플을 반환해 continuation을 외부에 보관하기 쉬워 델리게이트/콜백 브리지에 가장 적합합니다.

### 4.1 정확한 시그니처

```swift
@backDeployed(before: macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0)
static func makeStream(
    of elementType: Element.Type = Element.self,
    bufferingPolicy limit: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
) -> (stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation)
```

**`BufferingPolicy` 케이스** (Sendable):
- `.unbounded` — 무제한 버퍼 (⚠️ 기본값, producer ≫ consumer 시 메모리 폭주)
- `.bufferingOldest(Int)` — 가득 차면 **새** 요소 폐기 (오래된 것 유지)
- `.bufferingNewest(Int)` — 가득 차면 **오래된** 요소 폐기 (최신 유지)

⚠️ enum 이름이 직관과 반대. "Newest = 새 요소를 **유지**", "Oldest = 오래된 요소를 **유지**".

### 4.2 Termination 차이 주의

| 타입 | Termination 케이스 |
|------|------|
| `AsyncStream.Continuation.Termination` | `.finished`, `.cancelled` (associated value 없음) |
| `AsyncThrowingStream.Continuation.Termination` | `.finished(Failure?)`, `.cancelled` |

두 타입을 혼동하면 패턴 매칭이 깨지므로 주의.

### 4.3 CLLocationManager 정석 브리지 (검증됨)

`CLLocationManagerDelegate`는 `NSObjectProtocol` 상속 → 채택 클래스는 **반드시 NSObject 상속** 필요. delegate 미설정이면 콜백이 절대 호출되지 않습니다.

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
        manager.delegate = self                       // 핵심: super.init() 후 delegate 설정
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

    // CLLocationManagerDelegate (nonisolated — delegate runloop에서 호출됨)

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

**핵심 규칙**:
- `bufferingPolicy` 항상 명시
- delegate 메서드는 `nonisolated` + `Task { @MainActor in ... }`로 hop
- `Info.plist`에 `NSLocationWhenInUseUsageDescription` 키 필수 (런타임 크래시 방지)
- iOS 17+ 대안: `CLLocationUpdate.liveUpdates(_:)` (직접 AsyncSequence 제공)

---

## 5. TaskGroup vs DiscardingTaskGroup

### 5.1 결정 표

| 패턴 | 용도 | 핵심 특성 |
|------|------|-----------|
| `withTaskGroup(of:)` | 자식 결과를 모아 reduce/배열로 사용 | 결과 미소비 시 메모리 누적 |
| `withThrowingTaskGroup(of:)` | 위 + 에러 전파 | 첫 throw 시 그룹 취소는 명시 호출 필요 |
| `withDiscardingTaskGroup` (iOS 18+, back-deployed) | side-effect만, 결과 버림 | 자식 완료 즉시 release |
| `withThrowingDiscardingTaskGroup` (iOS 18+, back-deployed) | 위 + **자식 throw 시 그룹 자동 cancel** | 서버/리스너 패턴 |

> "A throwing discarding task group becomes canceled when *any* of its child tasks throws." — [Apple Developer Documentation](https://developer.apple.com/documentation/swift/throwingdiscardingtaskgroup#Cancellation-behavior)

### 5.2 next() 메서드 부재

`DiscardingTaskGroup`은 **`next()` 메서드 자체가 없습니다**. 결과 회수 자체가 정의상 불가능. 결과가 필요하면 일반 `TaskGroup`.

### 5.3 검증된 예제

```swift
// ✅ DiscardingTaskGroup — 자식 완료 즉시 release
func processFireAndForget(_ urls: [URL]) async {
    await withDiscardingTaskGroup { group in
        for url in urls {
            group.addTask {
                _ = try? await URLSession.shared.data(from: url)
            }
        }
        // body 종료 시 모든 child 자동 await
    }
}

// ✅ ThrowingDiscardingTaskGroup — 하나라도 throw → 전체 자동 취소
func runListeners(_ listeners: [Listener]) async throws {
    try await withThrowingDiscardingTaskGroup { group in
        for listener in listeners {
            group.addTask { try await listener.run() }
        }
    }
}
```

### 5.4 Bounded Concurrency (Sliding Window)

`maxConcurrent` 제한으로 자원 폭발 방지. **결과 수집형은 일반 TaskGroup**, side-effect 전용은 DiscardingTaskGroup이지만 `next()`가 없어 윈도우 슬라이딩 불가.

```swift
func processAll<T: Sendable, R: Sendable>(
    _ items: [T],
    maxConcurrent: Int,
    work: @Sendable @escaping (T) async -> R
) async -> [R] {
    await withTaskGroup(of: R.self) { group in
        var iterator = items.makeIterator()

        // 1) 초기 윈도우 채우기
        for _ in 0..<maxConcurrent {
            guard let item = iterator.next() else { break }
            group.addTask { await work(item) }
        }

        // 2) 하나 끝날 때마다 다음 작업 추가
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

### 6.1 정확한 시그니처

```swift
import Synchronization

@frozen struct Mutex<Value> where Value: ~Copyable

init(_ initialValue: consuming sending Value)

borrowing func withLock<Result, E>(
    _ body: (inout sending Value) throws(E) -> sending Result
) throws(E) -> sending Result where E: Error, Result: ~Copyable
```

**가용성**: macOS 15+, iOS 18+, watchOS 11+, tvOS 18+, visionOS 2+

### 6.2 사용 조건 (core team 가이드)

> "default to actors, unless you have reasons not to. And one such reason could be that you're building a concurrent data-structure."
> — Konrad Malawski (Apple), [SE-0433 가이드 스레드](https://forums.swift.org/t/se-0433-mutex-vs-actor-general-advice/71338/7)

> "Deadlocks are not possible with the actor model" whereas mutexes are "prone to deadlocks ... and live-locks."
> — [SE-0433 본문](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0433-mutex.md)

**Mutex<T> 허용 조건**:
1. critical section이 매우 짧고
2. **`withLock` 클로저 내부에서 `await` 사용 안 함** (시그니처상 sync 강제 → 컴파일 에러로 차단됨)
3. actor의 hop 비용이 부담스러운 경우만

```swift
import Synchronization

final class HitCounter: Sendable {
    private let count = Mutex<Int>(0)

    func increment() {
        count.withLock { value in
            value += 1
            // ❌ 여기에 await 쓰면 컴파일 에러 — withLock은 non-async closure
        }
    }

    func current() -> Int {
        count.withLock { $0 }
    }
}
```

---

## 7. Continuation + URLSession 취소 패턴

### 7.1 환각 정정

**`URLSessionDataTask.completionHandler`는 mutable property로 존재하지 않습니다.** completionHandler는 `URLSession.dataTask(with:completionHandler:)` 팩토리에서만 받습니다. 이전 일부 자료에서 setter처럼 사용한 패턴은 환각.

### 7.2 권장 패턴 (대부분의 경우 충분)

URLSession async API들은 **Task cancellation에 자동으로 반응**합니다.

```swift
// 가장 단순하고 권장
func fetch(_ url: URL) async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

### 7.3 명시적 cancellation hook이 필요할 때

```swift
func fetchWithExplicitCancel(_ url: URL) async throws -> Data {
    let session = URLSession.shared
    let task = session.dataTask(with: url)        // 팩토리 (completionHandler nil)

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Data, Error>) in
            Task {
                do {
                    let (data, _) = try await session.data(from: url)
                    cont.resume(returning: data)
                } catch {
                    cont.resume(throwing: error)
                }
            }
            task.resume()
        }
    } onCancel: {
        task.cancel()
    }
}
```

> 일반적인 권장은 7.2 패턴. 7.3은 delegate 기반 download/streaming task 등 task 핸들이 직접 필요한 경우만.

### 7.4 ResourcePool actor + CheckedContinuation

CheckedContinuation은 Sendable이므로 actor stored property로 안전하게 보관.

```swift
actor ResourcePool<Resource: Sendable> {
    private var available: [Resource]
    private var waiters: [CheckedContinuation<Resource, Never>] = []

    init(_ resources: [Resource]) { self.available = resources }

    func acquire() async -> Resource {
        if let r = available.popLast() { return r }
        return await withCheckedContinuation { cont in
            // 이 클로저는 actor isolation 안에서 실행 → self 변경 안전
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

## 8. 정책 적용 체크리스트

apple-craft 코드 리뷰/구현 시:

- [ ] **`DispatchSemaphore`, `NSCondition`, `pthread_cond_*`, `dispatch_sync`, `DispatchGroup.wait()`** 검색 → 발견 시 actor 또는 TaskGroup으로 전환
- [ ] **`Thread.sleep`** → `Task.sleep(for:)`
- [ ] **lock을 `await` 가로질러 보유**하는지 검사 (Tier 2 락 한정 검사)
- [ ] **`AsyncStream { ... }` 생성 시 `bufferingPolicy` 명시** 여부
- [ ] **`withTaskGroup(of: Void.self)`** 패턴 → side-effect만이면 `withDiscardingTaskGroup`로
- [ ] **`@concurrent` vs `nonisolated(nonsending)` vs `@MainActor` vs actor 메서드** 의도 명확
- [ ] UI 앱 타깃은 `.defaultIsolation(MainActor.self)` 적용 검토
- [ ] 디버그 빌드에 `LIBDISPATCH_COOPERATIVE_POOL_STRICT=1` 환경변수 설정

---

## 9. 출처

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
