# swift-master

Swift 6.2/6.3 동시성(Concurrency) 전문 가이드 스킬.

## 핵심 원칙

**🚫 차단형 동기화 전면 금지** — `lock` / `semaphore` / `sync` 패턴은 협력적 스레드 풀을 데드락에 빠뜨릴 수 있어 사용을 금지합니다 ([Swift Core Team 공식 입장](https://forums.swift.org/t/why-are-semaphores-conditions-and-read-write-locks-unsafe-in-swift-concurrency/80046)).

## 다루는 주제

- `@concurrent` (SE-0461) / `nonisolated(nonsending)` (SE-0461)
- 모듈 단위 기본 격리 (SE-0466)
- `AsyncStream.makeStream(of:)` 권장 패턴
- `withDiscardingTaskGroup` / `withThrowingDiscardingTaskGroup`
- Bounded concurrency (sliding window) 패턴
- 13가지 CRITICAL 동시성 안티패턴 + 8가지 금지→대체 매트릭스

## 사용법

```
/swift-master concurrency review
/swift-master @concurrent 어디 써야 해?
/swift-master AsyncStream 만들어줘
```

## 출처

- [Swift 6.2 / 6.3 Released](https://www.swift.org/blog/)
- [SE-0461 nonisolated nonsending](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [SE-0466 Default Actor Isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [WWDC25 — Embracing Swift concurrency](https://developer.apple.com/videos/play/wwdc2025/268/)
