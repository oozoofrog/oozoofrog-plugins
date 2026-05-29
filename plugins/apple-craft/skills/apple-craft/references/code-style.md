# Apple Code Style & Xcode MCP Tool Integration

## Apple Code Style (based on the Xcode Agent guide)

Code style rules used by Xcode's built-in AI agent:

- **Naming**: PascalCase (types), camelCase (properties/methods)
- **State**: `@State private var` (SwiftUI state), `let` (constants)
- **Indentation**: 4-space
- **Concurrency**: prefer Swift Concurrency (async/await, actors), **avoid Combine**
- **Testing**: Swift Testing framework (`@Test`, `#expect`, `try #require()`)
- **Preview**: `#Preview` macro (not PreviewProvider)
- **Types**: leverage the strong type system, no force unwrap
- **Imports**: keep concise at the top of the file (SwiftUI, Foundation)
- **Comments**: add explanatory comments only for complex logic

## Swift 6.3 Practical Notes

- **C Interop**: when a C call site is needed, use `@c` instead of relying on a plain Swift function.
- **Module Selectors**: use the `Module::symbol` syntax only when conflict resolution or semantic disambiguation is required.
- **Optimization Attributes**: use `@specialize`, `@inline(always)`, `@export(implementation)` only with measured justification.
- **Testing Diagnostics**: for non-fatal test diagnostics, prefer `Issue.record(..., severity: .warning)`.
- **Test Cancellation**: if a precondition breaks during execution, consider `try Test.cancel()` rather than forcing continuation.

## Xcode MCP Tool Integration

When the Xcode MCP server is connected, use the following tools:

### Documentation & Navigation
- **`mcp__xcode__DocumentationSearch`**: search Apple APIs not in the 21 local references. Find the latest APIs here.

### Build & Run
- **`mcp__xcode__BuildProject`**: build verification after writing code (may take a long time)
- **`mcp__xcode__XcodeRefreshCodeIssuesInFile`**: fast compile diagnostics for a specific file (under 2 seconds, much faster than a build)
- **`mcp__xcode__GetBuildLog`**: diagnose compile errors from the build log
- **`mcp__xcode__XcodeListNavigatorIssues`**: list of current warnings/errors
- **`mcp__xcode__ExecuteSnippet`**: run a code snippet in the context of a source file (useful for API verification)

### Preview & UI
- **`mcp__xcode__RenderPreview`**: render SwiftUI previews (essential for verifying visual features like Liquid Glass, Charts 3D, Toolbar, etc.)

### File Navigation
- **`mcp__xcode__XcodeRead`** / **`XcodeWrite`** / **`XcodeUpdate`**: read/write files within the Xcode project
- **`mcp__xcode__XcodeGrep`** / **`XcodeGlob`**: search the project

### Tool Selection Quick Guide

```
Need verification?
├─ Quick syntax check → XcodeRefreshCodeIssuesInFile (2s)
├─ Full build → BuildProject (slow, accurate)
├─ Code execution test → ExecuteSnippet (fast, temporary)
├─ UI check → RenderPreview
└─ API search → DocumentationSearch
```

> Even when the Xcode MCP server is not connected, provide the coding guide using the reference documents alone.
