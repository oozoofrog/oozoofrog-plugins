---
name: swift-master
description: Swift 6.2/6.3 동시성 전문 가이드 — @concurrent, nonisolated(nonsending), 모듈 기본 격리, AsyncStream.makeStream, DiscardingTaskGroup, 13가지 CRITICAL 안티패턴. **lock/semaphore/sync 차단형 동기화 전면 금지**. "swift concurrency", "async/await", "actor 리뷰", "@concurrent", "nonisolated", "asyncstream", "taskgroup", "swift 6.2", "swift 6.3", "동시성 리뷰" 요청 시 활성화
argument-hint: "[review | guide | generate | concurrency] [대상]"
---

<example>
user: "이 actor 코드 리뷰해줘"
assistant: "/swift-master review 모드로 Swift 6.2/6.3 동시성 안티패턴을 점검합니다."
</example>

<example>
user: "@concurrent 언제 써야 해?"
assistant: "/swift-master guide 모드로 @concurrent vs nonisolated(nonsending) 결정 트리를 안내합니다."
</example>

<example>
user: "AsyncStream으로 CLLocation 브릿지 만들어줘"
assistant: "/swift-master generate 모드로 makeStream(of:) 패턴 코드를 생성합니다."
</example>

<example>
user: "DispatchSemaphore 쓰고 있는데 괜찮아?"
assistant: "사용 금지 패턴입니다. /swift-master로 actor 대체안을 제시합니다."
</example>

# Swift Master — Swift 6.2/6.3 동시성 전문가

Swift 6.2/6.3 기준 Concurrency 베스트 프랙티스, 안티패턴 탐지, 코드 생성을 제공합니다.

---

## 🚫 절대 금지 — 차단형 동기화 (Swift Core Team 공식 입장)

**`lock` / `semaphore` / `sync` 패턴은 사용 금지**입니다. Swift Concurrency의 협력적 스레드 풀(cooperative thread pool)은 논리 코어 수만큼만 스레드를 보유하며, **단 하나의 스레드라도 `wait()`로 잠들면 데드락**이 발생할 수 있습니다.

> "Swift Concurrency's scheduling algorithm assumes that threads will never be blocked on 'future work'."
> — John McCall, Swift Core Team ([Swift Forums](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046))

### 즉시 대체 매트릭스

| 🚫 금지 | ✅ 대체 |
|---------|---------|
| `DispatchSemaphore.wait()` | `actor` |
| `NSLock` / `NSRecursiveLock` | `actor` |
| `os_unfair_lock` / `pthread_mutex_t` | `actor` (또는 iOS 18+ `Mutex<T>`) |
| `DispatchQueue.sync { }` | `await actor.method()` |
| `DispatchGroup.wait()` | `withTaskGroup` / `withDiscardingTaskGroup` |
| `Thread.sleep` | `try await Task.sleep(for:)` |
| 콜백 → `semaphore.signal()` 변환 | `withCheckedContinuation` |
| MainActor에서 무거운 `await` | `@concurrent` 함수 분리 |

> 상세 근거 및 코드 예시는 [concurrency-reference.md](./concurrency-reference.md) 참조.

---

## 모드 선택

| 키워드 | 모드 | 설명 |
|--------|------|------|
| 리뷰, review, check | **REVIEW** | 13가지 동시성 안티패턴 탐지 |
| 가이드, guide, best practice | **GUIDE** | 결정 트리 + 권장 패턴 안내 |
| 생성, generate, 만들어 | **GENERATE** | actor / AsyncStream / TaskGroup 코드 생성 |
| concurrency, async, actor, @concurrent, nonisolated | **CONCURRENCY** | 동시성 전용 종합 리뷰 |

---

## 13가지 CRITICAL 안티패턴

| # | 패턴 | 탐지 | 수정 |
|---|------|------|------|
| C1 | **Blocking in Async** | `semaphore.wait()`, `NSLock`, `DispatchQueue.sync`, `Thread.sleep` in async/actor | **Actor** |
| C2 | Continuation Double Resume | `continuation.resume` 2회+ | `resume(with: result)` 한 번 |
| C3 | Missing Continuation Resume | 모든 경로에서 resume 누락 | guard + defer |
| C4 | Sendable Violation | non-Sendable이 actor 경계 넘음 | Struct 또는 `nonisolated(nonsending)` |
| C5 | Actor Reentrancy Race | await 후 상태 가정 | 트랜잭션 / Task 캐싱 |
| C6 | Core Data Thread Violation | viewContext를 Task에서 직접 사용 | `perform` 또는 `@MainActor` |
| C7 | Realm Thread Violation | Realm 객체를 다른 Task에서 접근 | ThreadSafeReference |
| C8 | Unsafe Task Detachment | `Task.detached` 남용 | 일반 `Task` |
| C9 | MainActor Blocking | `@MainActor`에서 무거운 async | **`@concurrent`** 분리 |
| C10 | Swift 6 Isolation Crash | Legacy callback executor 불일치 | `@preconcurrency`, `assumeIsolated` |
| **C11** | **Wrong async isolation default** | `func foo() async` + 호출자 액터 기대 | `nonisolated(nonsending)` 명시 |
| **C12** | **Unbounded AsyncStream Buffer** | `AsyncStream { }` + `bufferingPolicy` 미지정 | `.bufferingNewest(n)` |
| **C13** | **TaskGroup result leak** | `withTaskGroup`에서 결과 미소비 | **`withDiscardingTaskGroup`** |

---

## 탐지 패턴 (grep)

```
# 🚫 차단형 동기화 (CC1)
DispatchSemaphore                               # → actor
NSLock|NSRecursiveLock|os_unfair_lock           # → actor
DispatchQueue\.\w+\.sync                        # → await
DispatchGroup\(\).*wait\(\)                     # → TaskGroup
Thread\.sleep                                   # → Task.sleep
pthread_mutex                                   # → actor

# 안티패턴
continuation\.resume.*\n.*continuation\.resume  # CC2: Double resume
Task\.detached\s*\{                             # CC8: Detached
AsyncStream\s*\{(?!.*bufferingPolicy)           # CC12: Missing buffer policy
withTaskGroup.*Void\.self                       # CC13: → DiscardingTaskGroup

# Swift 6.2 신규 키워드 (권장)
@concurrent\s+func                              # SE-0461
nonisolated\(nonsending\)                       # SE-0461
\.defaultIsolation\(MainActor\.self\)           # SE-0466
```

---

## Quick Reference Cards

### Swift Concurrency Decision Tree (Swift 6.2+)

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

🚫 절대 금지: NSLock / DispatchSemaphore / DispatchQueue.sync / DispatchGroup.wait
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
│  (UI 업데이트)                 │  func foo() async        │
├───────────────────────────────────────────────────────────┤
│  특정 actor에서 실행           │  actor 메서드로 정의     │
└───────────────────────────────────────────────────────────┘

Upcoming flag: NonisolatedNonsendingByDefault
→ 활성 시 평범한 `func foo() async`가 자동으로 호출자 액터 상속
```

### TaskGroup 선택

```
병렬 작업 결과를 어떻게 다루나?

├─ 결과 수집 필요         → withTaskGroup / withThrowingTaskGroup
├─ 결과 무시, side-effect → withDiscardingTaskGroup ✅ (iOS 17+)
└─ 결과 무시 + 에러 시 전체 취소 → withThrowingDiscardingTaskGroup ✅

🚫 withTaskGroup(of: Void.self) — 결과 미소비 시 메모리 누적 (CC13)
```

### AsyncStream 생성

```
어떤 방식?

├─ iOS 17+ 권장        → AsyncStream.makeStream(of:bufferingPolicy:)
├─ 단순 pull           → AsyncStream(unfolding:onCancel:)
└─ 클래식 push         → AsyncStream { continuation in ... }

⚠️ bufferingPolicy 항상 명시 (.bufferingNewest(n)) — 기본 .unbounded 위험
⚠️ onTermination에서 외부 등록 해제 (델리게이트, observer)
```

---

## 출력 형식

```markdown
## Swift Master Review Report

**Files Reviewed:** {count}
**Total Issues:** {count}

### CRITICAL (Must Fix)

#### [C1] Blocking in Async
- **File:** `src/Cache.swift:42`
- **Code:** `private let lock = NSLock()`
- **Issue:** 협력적 스레드 풀 데드락 위험 (Swift Core Team 공식 금지)
- **Fix:** actor로 전환 또는 iOS 18+ `Mutex<T>` 적용
- **Reference:** [concurrency-reference.md → 차단형 동기화 전면 금지](./concurrency-reference.md)
```

---

## 참조

- [concurrency-reference.md](./concurrency-reference.md) — 13개 안티패턴 + Swift 6.2/6.3 신규 + AsyncStream/TaskGroup 패턴

## 출처

- [SE-0461 — Run nonisolated async functions on the caller's actor](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [SE-0466 — Control Default Actor Isolation Inference](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [Swift 6.2 / 6.3 Released](https://www.swift.org/blog/)
- [WWDC25 — Embracing Swift concurrency](https://developer.apple.com/videos/play/wwdc2025/268/)
- [Swift Forums — Why semaphores are unsafe in Swift Concurrency](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046)

## 한계

- **정적 분석 기반** — 컴파일러 진단 아님. 실제 런타임 동작은 Xcode Instruments로 확인 필요
- **iOS 17+ / Swift 6.2+ 기준** — 하위 버전은 `@available` 분기 검토 필요
- **레거시 Obj-C 경계** — `@preconcurrency import` 영역은 Swift 컴파일러도 완전 검증 불가, 수동 리뷰 병행
