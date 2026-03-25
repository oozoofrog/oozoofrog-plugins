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
