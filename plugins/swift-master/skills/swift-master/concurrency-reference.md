# Swift Concurrency Reference Guide

Swift Concurrency 안티패턴, 변환 규칙, 베스트 프랙티스입니다. **Swift 6.2 / 6.3 기준** (정확한 릴리스 시점은 [swift.org/blog](https://www.swift.org/blog/) 참조).

---

## 🚫 절대 금지 — 차단형 동기화 (lock/semaphore/sync)

Swift Concurrency의 협력적 스레드 풀(cooperative thread pool)은 논리 코어 수만큼만 스레드를 보유합니다. **단 하나의 스레드라도 `wait()`로 잠들면 데드락**이 발생할 수 있다는 것이 Swift Core Team의 공식 입장입니다.

> "Swift Concurrency's scheduling algorithm assumes that threads will never be blocked on 'future work'."
> — John McCall, Swift Core Team
> ([Swift Forums](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046))

> "On Darwin, Dispatch assumes that threads running on behalf of Swift Concurrency never block in this way, so if they violate the rules, the program can actually deadlock with just a single scheduled thread."
> — 동일 출처

WWDC25 "[Embracing Swift concurrency](https://developer.apple.com/videos/play/wwdc2025/268/)"는 lock/semaphore 사용 자체를 "복잡성을 피해야 할 신호"로 명시합니다. WWDC21 "[Swift concurrency: Behind the scenes](https://developer.apple.com/videos/play/wwdc2021/10254/)"는 차단형 API가 의존성을 런타임에 숨겨 스케줄링 결정을 깨뜨린다고 설명합니다.

### 금지 → 대체 매트릭스

| 금지 패턴 | 즉시 대체 | 비고 |
|-----------|-----------|------|
| `DispatchSemaphore.wait() / .signal()` | `actor` + 카운터 | 자원 풀 게이팅 |
| `NSLock` / `NSRecursiveLock` 으로 mutable state 보호 | `actor` | 가장 일반적 케이스 |
| `os_unfair_lock` 으로 순간 동기화 | `Mutex<T>` (Synchronization, iOS 18+) | actor가 과한 경우만 |
| `pthread_mutex_t` / `@unchecked Sendable` 핸드롤 락 | `actor` 또는 `Mutex<T>` | 절대 직접 호출 금지 |
| `DispatchQueue.sync { ... }` (값 반환) | `await actor.method()` | 즉시 변환 |
| `DispatchGroup().wait()` | `withTaskGroup` / `withDiscardingTaskGroup` | 구조적 동시성 |
| `DispatchGroup().notify(queue:)` | 동일 (TaskGroup의 scope 종료가 곧 완료) | |
| `Thread.sleep(forTimeInterval:)` | `try await Task.sleep(for: .seconds(n))` | |
| `RunLoop.current.run(until:)` busy-wait | `for await` 패턴 | |
| 콜백 → `semaphore.signal()` 로 동기 변환 | `withCheckedContinuation` | 1회 resume 보장 |
| MainActor에서 무거운 계산을 `await` | `@concurrent` 함수 또는 별도 actor | WWDC25 contention 패턴 |

### Mutex<T> (iOS 18+ Synchronization framework)

actor가 과도한 케이스(예: 단일 카운터 보호)에 한해 `Mutex<T>` 허용. 단 forward-progress 룰을 지키려면 **critical section 내부에서 await 금지**.

```swift
import Synchronization

final class HitCounter: Sendable {
    private let count = Mutex<Int>(0)

    func increment() {
        count.withLock { $0 += 1 }   // OK — sync, no await inside
    }
    func snapshot() -> Int { count.withLock { $0 } }
}
```

`Mutex.withLock`은 **동기 closure만** 받습니다. 락 보유 스레드가 항상 전진하므로 cooperative pool 가정을 위반하지 않지만, 가능하면 actor를 우선합니다.

---

## ⭐ Swift 6.2 / 6.3 동시성 업데이트

Swift 6.2는 **Approachable Concurrency** 우산 아래 격리 모델을 단순화했고, 6.3은 그 모델 위에서 안정 사용을 보장합니다.

### 1. `@concurrent` (SE-0461)

`async` 함수가 **항상 글로벌 executor로 점프**한다는 의도를 시그니처에 명시합니다. 호출자가 액터에 있으면 인자/반환값에 Sendable 체크가 강제됩니다.

```swift
struct ImageService: Sendable {
    @concurrent
    static func decode(_ data: Data) async throws -> CGImage {
        // 메인 액터 호출자라도 여기서는 background executor로 점프
        try await heavyDecode(data)
    }
}

@MainActor
func showImage(_ data: Data) async throws {
    let image = try await ImageService.decode(data) // 자동 hop
    imageView.image = UIImage(cgImage: image)
}
```

**제약**: 동기 함수, 글로벌 액터 격리 함수, isolated 파라미터 함수에는 적용 불가.
**사용 시점**: 메인 액터 또는 임의 액터를 점유한 채 무거운 네트워크/디코딩/CPU 작업을 백그라운드로 명시적 오프로드해야 할 때.

### 2. `nonisolated(nonsending)` (SE-0461)

호출자의 액터에서 **그대로 실행**되는 async 함수. 함수가 암시적 actor 파라미터를 받아 격리 경계를 넘지 않으므로 비-Sendable 파라미터를 안전하게 전달합니다.

```swift
class NotSendable { var value = 0 }

class Service {
    nonisolated(nonsending)
    func update(_ obj: NotSendable) async {
        obj.value += 1   // 호출자 액터에서 실행되므로 안전
    }
}

actor Owner {
    let item = NotSendable()
    func bump() async {
        let svc = Service()
        await svc.update(item)   // OK — Owner 액터에서 그대로 실행
    }
}
```

**Upcoming feature flag**: `NonisolatedNonsendingByDefault`. 활성화 시 `func foo() async` 시그니처가 자동으로 `nonisolated(nonsending)` 의미로 해석되어 호출자 액터 상속이 기본이 됩니다. 미활성 시 종전대로 `@concurrent` 의미. 따라서 lock/semaphore로 강제하던 "이 작업은 같은 컨텍스트에서 실행돼야 한다" 패턴이 시그니처만으로 보장됩니다.

### 3. 모듈 단위 기본 격리 (SE-0466)

UI 앱·스크립트·executable 타깃에서 매번 `@MainActor`를 붙이지 않아도 모듈 전체를 메인 액터로 추론할 수 있습니다.

```bash
# 빌드 플래그
-default-isolation MainActor    # 미주석 선언이 모두 @MainActor
-default-isolation nonisolated  # 기본값
```

```swift
// Package.swift (SwiftPM 6.2+)
.target(
    name: "MyApp",
    swiftSettings: [
        .defaultIsolation(MainActor.self)
    ]
)
```

`MainActor.self` 또는 `nil`만 허용. `actor` 타입 내부, 명시적 격리, `SendableMetatype` 적합 타입은 예외. **권장**: UI 모듈은 `.defaultIsolation(MainActor.self)`, 도메인/네트워크 모듈은 기본(nonisolated).

### 4. Named Tasks (Swift 6.2)

`Task(name: "image-fetch") { ... }` — Instruments / 디버거에 사람-가독 이름 노출.

```swift
let task = Task(name: "feed-prefetch") {
    await prefetchTimeline()
}
```

### 5. Swift 6.3 변경

- **모듈명 셀렉터**: `Swift::Task { ... }` 형태로 동시성/문자열 처리 API를 모듈 명시적으로 참조 (이름 충돌 해소).
- **Swift Testing `try Test.cancel()`**: 실행 중인 테스트와 task hierarchy를 협력적으로 취소.
- **C interop / Embedded / Android SDK** 안정화 (동시성 자체 변경은 SE 단위로는 제한적, 6.2 모델 위에서 완성됨).

---

## 안티패턴 체크리스트

### CRITICAL (13개) — 런타임 크래시/데드락

| # | 패턴 | 탐지 규칙 | 수정 방법 |
|---|------|-----------|-----------|
| C1 | **Blocking in Async (절대 금지)** | `semaphore.wait()`, `DispatchQueue.sync`, `Thread.sleep`, `NSLock.lock()` in async/actor | **Actor** (또는 iOS 18+ `Mutex<T>`) |
| C2 | Continuation Double Resume | `continuation.resume` 2회 이상 | 한 번만 호출, `resume(with: result)` |
| C3 | Missing Continuation Resume | 모든 경로에서 resume 없음 | guard + defer 패턴 |
| C4 | Sendable Violation | non-Sendable을 actor 경계 넘김 | Struct 또는 `nonisolated(nonsending)` |
| C5 | Actor Reentrancy Race | await 후 상태 가정 | 트랜잭션 패턴 / Task 캐싱 |
| C6 | Core Data Thread Violation | viewContext를 Task 내 직접 사용 | `perform` 또는 `@MainActor` |
| C7 | Realm Thread Violation | Realm 객체를 다른 Task에서 접근 | ThreadSafeReference |
| C8 | Unsafe Task Detachment | `Task.detached`로 취소 단절 | 일반 `Task` |
| C9 | MainActor Blocking | `@MainActor`에서 무거운 async 작업 | **`@concurrent`** 함수로 오프로드 |
| C10 | Swift 6 Isolation Crash | Legacy callback executor 불일치 | `@preconcurrency`, `assumeIsolated` |
| **C11** | **Wrong async isolation default** | `func foo() async` + 호출자 액터에서 실행되길 기대 | `nonisolated(nonsending)` 명시 또는 `NonisolatedNonsendingByDefault` 활성 |
| **C12** | **Unbounded AsyncStream Buffer** | `AsyncStream { ... }` 생성 시 `bufferingPolicy` 미지정 | `.bufferingNewest(n)` / `.bufferingOldest(n)` |
| **C13** | **TaskGroup result leak** | `withTaskGroup`에서 결과 미소비 (side-effect만) | **`withDiscardingTaskGroup`** |

### WARNING (10개)

| # | 패턴 | 수정 |
|---|------|------|
| W1 | Task { } 남용 | 구조적 동시성 (async let, TaskGroup) |
| W2 | DispatchGroup in Async | TaskGroup |
| W3 | Missing Cancellation Check | `try Task.checkCancellation()` |
| W4 | Unbounded Task Creation | TaskGroup + 제한 |
| W5 | Ignoring Task Result | `Task<Void, Never>` 명시 |
| W6 | GlobalActor Overuse | 필요한 부분만 격리 |
| W7 | AsyncSequence Retain Cycle | `[weak self]` |
| W8 | Missing Task Priority | `Task(priority:)` 명시 |
| W9 | Synchronous Property Access | `nonisolated` 또는 async |
| W10 | withTaskGroup Missing throws | `withThrowingTaskGroup` |

### INFO (8개)

| # | 패턴 | 권장 |
|---|------|------|
| I1 | Class Instead of Struct | Struct 사용 |
| I2 | Missing autoreleasepool | autoreleasepool 추가 |
| I3 | XCTest async | Swift Testing (`@Test`) |
| I4 | Completion Handler Retained | async/await 변환 |
| I5 | NotificationCenter Callback | AsyncSequence |
| I6 | Timer Without AsyncSequence | AsyncTimerSequence |
| I7 | URLSession Delegate | async URLSession API |
| I8 | Manual Thread Management | Task |

---

## 핵심 변환 규칙

### 1. Completion Handler → async/await

```swift
// Before
func fetchData(completion: @escaping (Result<Data, Error>) -> Void)

// After
func fetchData() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

### 2. DispatchSemaphore → Actor (🚫 → ✅)

```swift
// 🚫 Before — 데드락 위험
class ResourcePool {
    private let semaphore = DispatchSemaphore(value: 3)
    private var resources: [Resource] = []

    func acquire() -> Resource {
        semaphore.wait()
        return resources.removeLast()
    }
}

// ✅ After
actor ResourcePool {
    private var available: [Resource] = []
    private var waiters: [CheckedContinuation<Resource, Never>] = []

    func acquire() async -> Resource {
        if let resource = available.popLast() { return resource }
        return await withCheckedContinuation { continuation in
            waiters.append(continuation)
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

### 3. NSLock → Actor

```swift
// 🚫 Before
final class Cache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]
    func get(_ key: String) -> Data? { lock.withLock { storage[key] } }
}

// ✅ After
actor Cache {
    private var storage: [String: Data] = [:]
    func get(_ key: String) -> Data? { storage[key] }
}
```

### 4. DispatchGroup → TaskGroup

```swift
// 🚫 Before
let group = DispatchGroup()
for item in items {
    group.enter()
    process(item) { _ in group.leave() }
}
group.wait()  // 🚫 협력적 풀 차단

// ✅ After
await withDiscardingTaskGroup { group in
    for item in items {
        group.addTask { await process(item) }
    }
}
```

### 5. Continuation 안전 패턴

```swift
func modernAPI() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        legacyAPI.load { result in
            // Result 타입 그대로 전달 → 정확히 한 번 보장
            continuation.resume(with: result)
        }
    }
}
```

---

## AsyncStream `makeStream(of:)` 권장 패턴 (iOS 17+)

iOS 17부터는 `AsyncStream.makeStream(of:bufferingPolicy:)`가 **공식 권장 방식**입니다. `(stream, continuation)` 튜플을 반환해 continuation을 외부에 보관하기 쉬워 델리게이트/콜백 브리지에 가장 적합합니다.

```swift
import CoreLocation

final class LocationBridge {
    let stream: AsyncStream<CLLocation>
    private let continuation: AsyncStream<CLLocation>.Continuation
    private let manager = CLLocationManager()

    init() {
        // ⚠️ bufferingPolicy 명시 필수 — 기본 .unbounded 는 producer 빠를 때 메모리 폭주
        let (stream, continuation) = AsyncStream.makeStream(
            of: CLLocation.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        self.stream = stream
        self.continuation = continuation

        continuation.onTermination = { [manager] termination in
            // termination: .finished | .cancelled
            manager.stopUpdatingLocation()
        }
    }

    func didUpdate(_ location: CLLocation) {
        continuation.yield(location)   // 동기 — await 없음
    }

    deinit { continuation.finish() }
}
```

### 핵심 규칙

| 규칙 | 이유 |
|------|------|
| `bufferingPolicy` 항상 명시 | 기본 `.unbounded` → producer ≫ consumer 시 무한 누적 |
| `onTermination`에서 등록 해제 | 소비자 break/return/cancel 시 자원 정리 보장 |
| `[weak self]` 또는 외부 캡처 사용 | init 클로저 내부 `self` 강참조 누수 방지 |
| `yield`는 동기 | delegate/observer 콜백에서 `await` 없이 호출 가능 |

출처: [AsyncStream.makeStream](https://developer.apple.com/documentation/swift/asyncstream/makestream(of:bufferingpolicy:)), [Continuation.onTermination](https://developer.apple.com/documentation/swift/asyncstream/continuation/ontermination).

---

## TaskGroup vs DiscardingTaskGroup

### 결정 표

| 패턴 | 용도 | 핵심 특성 |
|------|------|-----------|
| `withTaskGroup(of:)` | 자식 결과를 모아 reduce/배열로 사용 | 결과 미소비 시 메모리 누적 (C13 위험) |
| `withThrowingTaskGroup(of:)` | 위 + 에러 전파 | 첫 throw 시 그룹 취소는 명시 호출 필요 |
| **`withDiscardingTaskGroup`** (iOS 17+) | side-effect만, 결과 버림 | 자식 완료 즉시 release → 장기 실행 워크로드에 필수 |
| **`withThrowingDiscardingTaskGroup`** (iOS 17+) | 위 + 자식 throw 시 **그룹 자동 cancel** | 서버/리스너 패턴 |

```swift
// ❌ 결과를 안 쓰면서 일반 TaskGroup — 메모리 누적
await withTaskGroup(of: Void.self) { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}

// ✅ DiscardingTaskGroup — 자식 완료 즉시 release
await withDiscardingTaskGroup { group in
    for client in connections {
        group.addTask { await handle(client) }
    }
}

// ✅ 에러 시 전체 자동 취소
try await withThrowingDiscardingTaskGroup { group in
    for listener in listeners {
        group.addTask { try await listener.run() }
    }
}
```

### Bounded Concurrency (Sliding Window)

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

출처: [DiscardingTaskGroup](https://developer.apple.com/documentation/swift/discardingtaskgroup), [ThrowingDiscardingTaskGroup](https://developer.apple.com/documentation/swift/throwingdiscardingtaskgroup).

---

## AsyncStream 기반 레거시 이벤트 변환

여러 번 반복해서 이벤트를 전달하는 레거시 패턴(Delegate, Observer, 다중 호출 Callback)을 `AsyncSequence`로 변환할 때 표준 패턴.

```swift
// Step 1: Sendable 데이터 모델
struct EventResult: Sendable {
    let id: String
    let value: Int
}

// Step 2: Delegate Proxy
final class EventStreamProxy: LegacySystemDelegate, @unchecked Sendable {
    private let continuation: AsyncStream<EventResult>.Continuation
    init(continuation: AsyncStream<EventResult>.Continuation) {
        self.continuation = continuation
    }
    func system(_ system: LegacySystem, didProduceEvent data: LegacyData) {
        continuation.yield(EventResult(id: data.id, value: data.value))
    }
    func systemDidFinish(_ system: LegacySystem) { continuation.finish() }
}

// Step 3: 팩토리 + 수명 관리
func observeEvents(from system: LegacySystem) -> AsyncStream<EventResult> {
    AsyncStream(bufferingPolicy: .bufferingNewest(64)) { continuation in
        let proxy = EventStreamProxy(continuation: continuation)
        system.delegate = proxy
        continuation.onTermination = { @Sendable _ in
            // ⚠️ 등록 해제 누락 시 영구 메모리 누수
            system.delegate = nil
        }
    }
}
```

| 항목 | 설명 |
|------|------|
| `yield`는 동기 | 어떤 델리게이트/콜백에서도 즉시 호출 가능 |
| 수명 관리 | `onTermination`에서 등록 해제 필수 |
| 단방향 데이터 흐름 | `for await` 소비 시 데이터 경쟁 없음 |

---

## Sendable 전략

| 타입 | Sendable 조건 | 비고 |
|------|---------------|------|
| Value Types | `struct`/`enum`의 모든 속성이 Sendable이면 자동 준수 | **가장 안전** |
| Reference Types | `final` 클래스 + 불변(`let`) 속성만 | 제한적 |
| Manual Sync | `actor` 또는 `Mutex<T>` | `@unchecked Sendable`은 기술 부채로 추적 |
| 프로토콜 합성 | `P & Sendable` 문법 | 격리 경계 보증 |

```swift
actor DataManager {
    private var cache: [String: Data] = [:]

    // ✅ 값 타입 반환
    func getData(for key: String) -> Data? { cache[key] }

    // 🚫 참조 타입 노출 금지
    // func getCache() -> [String: SomeClass]
}
```

---

## Actor 재진입 + Task 캐싱

```swift
actor DataCache {
    private enum CacheEntry {
        case inProgress(Task<Data, Error>)
        case ready(Data)
    }
    private var cache: [UUID: CacheEntry] = [:]

    func fetch(id: UUID) async throws -> Data {
        // 1) 진행 중인 Task가 있으면 join → 중복 요청 방지
        if let entry = cache[id] {
            switch entry {
            case .ready(let data): return data
            case .inProgress(let task): return try await task.value
            }
        }
        // 2) 새 Task 생성 + 캐싱
        let task = Task { try await download(id) }
        cache[id] = .inProgress(task)
        do {
            let data = try await task.value
            // ⚠️ await 이후 상태 재검증 필수
            cache[id] = .ready(data)
            return data
        } catch {
            cache[id] = nil
            throw error
        }
    }
}
```

---

## 취소 처리

```swift
func processLargeDataset(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()
        await process(item)
    }
}

func fetchWithCancellation() async throws -> Data {
    let task = URLSession.shared.dataTask(with: url)
    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            task.completionHandler = { data, _, error in
                if let error = error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: data ?? Data()) }
            }
            task.resume()
        }
    } onCancel: {
        task.cancel()
    }
}
```

---

## Decision Trees

### 동시성 결정 트리

```
데이터 공유 필요?
├─ No → 일반 async/await
└─ Yes → 여러 Task에서 접근?
         ├─ No → 단일 Task 내 처리
         └─ Yes → 가변 상태?
                  ├─ No → Struct (자동 Sendable)
                  └─ Yes → Actor 사용
                           ├─ UI 관련? → @MainActor
                           └─ 단순 카운터? → Mutex<T> (iOS 18+)
```

### Async Function Isolation (Swift 6.2)

```
async 함수 작성 → 어디서 실행?

┌───────────────────────────────────────────────────────────┐
│  의도                          │  올바른 시그니처          │
├───────────────────────────────────────────────────────────┤
│  호출자 액터에서 그대로 실행   │  nonisolated(nonsending) │
│  (비-Sendable 인자 안전)       │  func foo() async        │
├───────────────────────────────────────────────────────────┤
│  항상 background로 점프        │  @concurrent             │
│  (CPU/네트워크 무거운 작업)    │  func foo() async        │
├───────────────────────────────────────────────────────────┤
│  메인에서만 실행               │  @MainActor              │
├───────────────────────────────────────────────────────────┤
│  특정 actor에서 실행           │  actor 메서드로 정의     │
└───────────────────────────────────────────────────────────┘
```

### Concurrency 리팩토링 트리

```
레거시 비동기 패턴 유형?
├─ 단발성 콜백          → withCheckedContinuation
├─ 반복 이벤트          → AsyncStream.makeStream
├─ DispatchGroup        → TaskGroup / DiscardingTaskGroup
├─ DispatchQueue.main.async → @MainActor
├─ NSLock/시리얼 큐     → Actor (절대 lock 유지 금지)
└─ 블로킹 SDK API
   └─ DispatchQueue로 오프로딩 + Continuation 브리징
```

---

## Quick Reference

| | async let | TaskGroup |
|---|-----------|-----------|
| 작업 수 | 고정 | 동적 |
| 타입 | 동일하지 않아도 됨 | 동일해야 함 |
| 사용 | 2-3개 병렬 | N개 병렬 |

| | Task | Task.detached |
|---|------|---------------|
| Actor 상속 | ✅ | ❌ |
| 우선순위 상속 | ✅ | ❌ |
| TaskLocal 상속 | ✅ | ❌ |
| 취소 전파 | ✅ | ❌ |

**규칙**: `Task.detached`는 거의 사용하지 않음.

---

## 출처 통합

**Swift Evolution**
- [SE-0461 — nonisolated(nonsending) / @concurrent](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [SE-0466 — Default Actor Isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [SE-0314 — AsyncStream](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0314-async-stream.md)

**Swift.org 블로그**
- [Swift 6.2 Released](https://www.swift.org/blog/swift-6.2-released/)
- [Swift 6.3 Released](https://www.swift.org/blog/swift-6.3-released/)

**Apple 공식 문서**
- [AsyncStream.makeStream](https://developer.apple.com/documentation/swift/asyncstream/makestream(of:bufferingpolicy:))
- [DiscardingTaskGroup](https://developer.apple.com/documentation/swift/discardingtaskgroup)
- [ThrowingDiscardingTaskGroup](https://developer.apple.com/documentation/swift/throwingdiscardingtaskgroup)
- [Concurrency](https://developer.apple.com/documentation/swift/concurrency)

**WWDC**
- [WWDC25 — Embracing Swift concurrency](https://developer.apple.com/videos/play/wwdc2025/268/)
- [WWDC21 — Swift concurrency: Behind the scenes](https://developer.apple.com/videos/play/wwdc2021/10254/)

**Swift Forums (Core Team)**
- [Why are semaphores unsafe in Swift Concurrency](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046)
