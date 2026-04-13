# Swift 6.3 Language and Tooling Updates

## Overview

Swift 6.3 shipped with Xcode 26.4 and expands Swift beyond app-only concerns into better C interoperability, more capable package tooling, stronger test ergonomics, and broader platform reach.

Use this reference when the question is about:
- new Swift 6.3 language features
- C interoperability from Swift
- package and build changes in SwiftPM 6.3
- Swift Testing additions in 6.3
- DocC 6.3 capabilities
- Embedded Swift or Swift on Android

Use `swift-concurrency.md` together with this document when the question is specifically about actor isolation, `@concurrent`, or the Swift 6.2 approachable concurrency model.

## Version Context

- **Compiler**: Swift 6.3
- **Apple toolchain pairing**: Xcode 26.4
- **Language mode**: Swift 6, Swift 5, Swift 4.2, Swift 4 remain available in the Xcode 26.4 toolchain

## Language and Standard Library

### C Interoperability with `@c`

Swift 6.3 introduces the `@c` attribute, which lets you expose Swift functions to C code in your project.

Use `@c` when:
- a Swift function needs a stable C symbol name
- mixed Swift/C or Swift/C++ codebases need direct entry points
- you want to implement a C-declared function in Swift with `@implementation`

#### Basic export

```swift
@c
func callFromC() {
    print("Called from C")
}
```

This causes Swift to emit a corresponding declaration in the generated C header.

#### Custom C symbol name

```swift
@c(MyLibrary_callFromC)
func callFromC() {
    print("Called from C")
}
```

Use an explicit symbol name when the C-facing API needs a stable prefix or must match an existing naming convention.

#### Implement an existing C declaration in Swift

```c
// C header
void callFromC(void);
```

```swift
@c @implementation
func callFromC() {
    print("Swift implementation for a C declaration")
}
```

With `@c @implementation`, Swift validates that the Swift signature matches a pre-existing declaration in a C header instead of generating a new declaration.

#### Guidance

- Prefer `@c` over ad hoc bridging patterns when the goal is a real C entry point.
- Keep the C-facing surface narrow and intentional.
- Use a custom symbol name for public or cross-target entry points to avoid accidental ambiguity.
- Treat `@c @implementation` as a contract with the header. If the declaration changes, update the Swift side immediately.

### Module Selectors

Swift 6.3 adds module selectors so code can explicitly choose which imported module should provide a symbol.

This is useful when:
- two modules expose the same symbol name
- the standard library name collides with an imported symbol
- you want to make symbol provenance explicit in mixed-domain code

```swift
import ModuleA
import ModuleB

let a = ModuleA::getValue()
let b = ModuleB::getValue()
```

You can also use the `Swift` module name directly:

```swift
let task = Swift::Task {
    await work()
}
```

#### Guidance

- Use module selectors to resolve ambiguity, not as a blanket style rule.
- Prefer local clarity. If a collision only happens in one place, scope the selector to that call site.

### Performance Control for Library APIs

Swift 6.3 adds finer-grained controls for library authors who need to shape client-side optimization behavior.

#### `@specialize`

Use `@specialize` to provide pre-specialized implementations of generic APIs for common concrete types.

```swift
@specialize(where T == Int)
func sum<T: BinaryInteger>(_ values: [T]) -> T {
    values.reduce(0, +)
}
```

#### `@inline(always)`

Use `@inline(always)` only when you intentionally want direct call sites to inline the function body.

```swift
@inline(always)
func clampToUnit(_ value: Double) -> Double {
    min(max(value, 0), 1)
}
```

#### `@export(implementation)`

Use `@export(implementation)` in ABI-stable libraries when clients should see a function implementation for additional optimization opportunities.

```swift
@export(implementation)
public func isPowerOfTwo(_ value: Int) -> Bool {
    value > 0 && (value & (value - 1)) == 0
}
```

#### Guidance

- These features are mainly for library and performance-sensitive package authors, not routine app code.
- Do not scatter optimization attributes broadly.
- Start with profiling, then add the narrowest attribute that solves the measured problem.

## Package and Build Improvements

### Swift Build Preview in SwiftPM

Swift 6.3 includes a preview of **Swift Build** integrated into Swift Package Manager.

This preview brings a unified build engine across supported platforms for a more consistent cross-platform development experience.

### Macro-Friendly Prebuilt Swift Syntax

SwiftPM 6.3 improves macro authoring by allowing shared macro implementation code to use prebuilt Swift Syntax binaries in libraries that are only used by macros.

### Discoverable Package Traits

Swift 6.3 adds the `swift package show-traits` command so a package can expose the traits it supports.

```bash
swift package show-traits
```

### Documentation Generation Improvements

SwiftPM 6.3 also improves inherited documentation control for command plugins that generate symbol graphs.

## Core Library Updates

### Swift Testing

Swift 6.3 improves Swift Testing in three notable areas.

#### Warning issues

`Issue.record` can now record a warning instead of only creating a failure-grade issue.

```swift
Issue.record("Cache miss rate looks suspicious", severity: .warning)
```

Use warnings for diagnostics that should appear in test results without failing the whole test.

#### Test cancellation

You can cancel the current test and its task hierarchy after execution has already started.

```swift
try Test.cancel()
```

This is especially useful when an individual test case or parameterized argument should not proceed further.

#### Image attachments

Swift 6.3 adds image attachment support on Apple and Windows platforms through cross-import overlays with UI frameworks such as UIKit.

### DocC

Swift 6.3 adds three new experimental DocC capabilities.

#### Markdown output

DocC can emit Markdown versions of documentation pages in addition to rendered JSON.

```bash
docc convert --enable-experimental-markdown-output
```

#### Static HTML content embedding

DocC can embed a lightweight per-page HTML summary into `index.html` for better discoverability and no-JavaScript accessibility.

```bash
docc convert --transform-for-static-hosting --experimental-transform-for-static-hosting-with-content
```

#### Code block annotations

Swift 6.3 adds experimental code block annotations such as:
- `nocopy`
- `highlight=[...]`
- `showLineNumbers`
- `wrap=80`

````
```swift, highlight=[1, 3], showLineNumbers
let greeting = "Hello"
let name = "World"
print("\(greeting), \(name)!")
```
````

Enable the feature with:

```bash
docc convert --enable-experimental-code-block-annotations
```

## Platforms and Environments

### Embedded Swift

Embedded Swift has broad improvements in Swift 6.3, including better C interoperability, improved debugging support, and progress toward a more complete linkage model.

### Official Swift SDK for Android

Swift 6.3 includes the first official release of the Swift SDK for Android.

This means Swift packages can target Android with an officially supported SDK, and Swift code can integrate with existing Android applications through Swift Java and Swift Java JNI Core.

## Project Guidance for apple-craft

When a user asks about Swift 6.3:

1. Load this document first for language and tooling changes.
2. If the question also involves actor isolation or `@concurrent`, load `swift-concurrency.md` too.
3. If the question is about package-level adoption, prefer this document over generic older guidance.
4. For Apple app framework questions, continue routing to the framework-specific documents.

## Common Pitfalls

- Do not assume a plain Swift function is automatically callable from C. Use `@c` explicitly.
- Do not use module selectors everywhere. Use them where ambiguity exists or clarity genuinely improves.
- Do not add `@inline(always)` or `@export(implementation)` without a measured reason.
- Do not fail a test for every diagnostic. Use warning issues when the result should be visible but non-fatal.
- Do not treat Android support as Apple UI portability. The 6.3 update is about SDK and package portability.

## Source URLs

- https://www.swift.org/blog/swift-6.3-released/
- https://developer.apple.com/support/xcode/
