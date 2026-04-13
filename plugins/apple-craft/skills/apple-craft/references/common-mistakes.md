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
