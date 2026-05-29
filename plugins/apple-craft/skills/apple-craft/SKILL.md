---
name: apple-craft
description: Apple platform development assistant — Swift, SwiftUI, UIKit, AppKit, Xcode build/preview/debug, writing/editing/refactoring/migrating code, explaining APIs, fixing performance issues. The default entry point for general Apple development. Use apple-review for code review/PR review, and apple-harness for from-scratch/full implementations or long-running large-scale work. iOS, macOS, watchOS, visionOS. swift, swiftui, uikit, appkit, xcode, 빌드, 프리뷰, 디버깅, 코드 작성, 코드 수정, 리팩토링, 마이그레이션, 아키텍처, SPM, CocoaPods, xcodeproj, swift concurrency, combine, swiftdata, coredata, objective-c, swift package, 테스트, unit test, 시뮬레이터, instruments, 성능, 메모리, 크래시, build error, API 설명, 앱 개발, Apple 플랫폼 코딩, iOS 26, macOS 26, WWDC, 최신 API, 새 프레임워크.
argument-hint: "[topic, question, or task]"
---

<example>
user: "Liquid Glass 효과를 SwiftUI 뷰에 적용하는 방법 알려줘"
assistant: "implement 모드로 Liquid Glass SwiftUI 참조 문서를 읽어서 glassEffect() 적용 코드를 작성하겠습니다."
</example>

<example>
user: "FoundationModels로 온디바이스 LLM 사용하는 코드 작성해줘"
assistant: "implement 모드로 FoundationModels 참조 문서를 읽고 SystemLanguageModel + LanguageModelSession 코드를 작성하겠습니다."
</example>

<example>
user: "Swift 6.2 Concurrency에서 뭐가 바뀌었어?"
assistant: "explore 모드로 Swift Concurrency 참조 문서를 읽어서 Approachable Concurrency 변경 사항을 설명하겠습니다."
</example>

<example>
user: "Swift 6.3에서 @c랑 module selector가 뭐야?"
assistant: "explore 모드로 Swift 6.3 참조 문서를 읽어서 C interop와 module selector 변경 사항을 설명하겠습니다."
</example>

<example>
user: "빌드 에러가 나는데 Liquid Glass 관련인 것 같아"
assistant: "troubleshoot 모드로 빌드 로그를 확인하고, Liquid Glass 참조 문서에서 올바른 API 사용법을 찾아 수정하겠습니다."
</example>

<example>
user: "/apple-craft AlarmKit으로 반복 알람 구현"
assistant: "implement 모드로 AlarmKit 참조 문서를 읽어 AlarmManager, Alarm API로 반복 알람 코드를 작성하겠습니다."
</example>

<example>
user: "이 SwiftUI 뷰에서 리스트 성능이 느린데 개선해줘"
assistant: "troubleshoot 모드로 프로젝트 코드를 분석하고, LazyVStack 전환 및 id 최적화를 적용하겠습니다."
</example>

<example>
user: "MVVM 패턴으로 네트워크 레이어 리팩토링해줘"
assistant: "implement 모드로 프로젝트 구조를 파악하고, async/await 기반 네트워크 레이어를 MVVM으로 리팩토링하겠습니다."
</example>

<example>
user: "Swift Testing으로 기존 XCTest를 마이그레이션하고 싶어"
assistant: "implement 모드로 기존 테스트 파일을 분석하고, @Test와 #expect 기반으로 마이그레이션 코드를 작성하겠습니다."
</example>

<example>
user: "WKWebView를 SwiftUI에 붙여줘"
assistant: "implement 모드로 WebKit + SwiftUI 참조 문서를 읽고 UIViewRepresentable/NSViewRepresentable 기반 통합 코드를 작성하겠습니다."
</example>

<example>
user: "이 크래시 원인 찾아서 고쳐줘"
assistant: "troubleshoot 모드로 에러 로그와 관련 코드를 분석해 크래시 원인을 식별하고 수정하겠습니다."
</example>

# apple-craft

Unified Apple platform development assistant — write, edit, and debug Swift/SwiftUI/UIKit/AppKit code with Xcode MCP integration.
Backed by Xcode 26 reference docs (20 topics) plus Swift 6.3 supplements, covering the latest APIs and language/tooling changes.

Respond to the user in Korean.

## Knowledge Authority

The reference docs below are more accurate than training data for recent Apple APIs. Prefer them when there's a conflict, look there first for unfamiliar APIs, and cite the source filename (e.g. see `references/liquid-glass-swiftui.md`) so users can trace it.

---

## Family Boundary

- Implementing, editing, debugging, and explaining are this skill's default scope.
- When review/inspection/PR-review is the core request, switch to `apple-review`.
- For long-running work that builds a new feature/app from scratch or restructures the whole app, switch to `apple-harness`.

---

## Mode Selection

Analyze the user message and pick one of the modes below.

| Mode | Keywords | Description |
|------|--------|------|
| **implement** | 만들어, 작성, 적용, 구현, 추가, 코드, 리팩토링, 마이그레이션, build, create, add, apply, refactor | Write code + build verification. Use the latest APIs when a reference doc matches |
| **explore** | 알려줘, 설명, 뭐가 바뀌었어, 차이, 어떻게, 비교, 추천, what, how, explain, diff, compare | API/code explanation + code examples. Search official docs with `DocumentationSearch` |
| **troubleshoot** | 에러, 오류, 안돼, 크래시, 빌드 실패, 느려, 성능, 메모리, error, crash, fix, debug, slow | Build log/code analysis + fix. Use `GetBuildLog`, `XcodeListNavigatorIssues` |
| **review** | 리뷰, 코드 리뷰, review, 검토, 점검, PR 리뷰, audit, 봐줘, 확인해, 체크, 살펴, 분석, check, analyze, inspect | → Switch to the `apple-review` skill |
| **harness** | 처음부터, 전체, 기능 개발, 대규모, 전면 리팩토링, harness | → Switch to the `apple-harness` skill |

**Auto-select**: when keywords are unclear, infer user intent. If a code file is mentioned use implement, for questions use explore, when an error message is included use troubleshoot, and for evaluation/opinion requests on existing code use review.

**Priority on keyword conflict**: when keywords from two modes appear together, choose by the user's primary intent. "에러 있는지 검토해줘" → review (review is the main verb), "리뷰 결과 에러 수정해줘" → troubleshoot (fix is the main verb). In particular, prefer review when `리뷰/검토/점검/PR 리뷰` is explicit, and prefer harness when `처음부터/전체/전면/대규모` is explicit. Otherwise apple-craft handles implement/fix/debug/explain.

---

## Core Workflow

The workflow shared by all modes. It applies to every Apple platform task regardless of whether a reference doc matches.

### Phase 0: Establish project context

1. Use Glob to map the project structure (`*.xcodeproj`, `Package.swift`, `Podfile`, `*.swift`)
2. Confirm target platforms and minimum deployment target
3. Identify existing code patterns/architecture (MVVM, TCA, Clean Architecture, etc.)
4. Identify project rules and coding conventions

### Xcode MCP tool strategy

Use the Xcode MCP server actively when it's connected. When it's not, fall back to general tools (Bash, Read, Grep, etc.).

| Purpose | Tool | When to use |
|------|------|----------|
| Quick code diagnosis | `XcodeRefreshCodeIssuesInFile` | Immediately after editing code (within 2s) |
| Full build | `BuildProject` + `GetBuildLog` | Verification after changes are complete |
| UI check | `RenderPreview` | When editing SwiftUI views |
| API search | `DocumentationSearch` | Unknown APIs, signature confirmation |
| Code execution | `ExecuteSnippet` | Behavior confirmation, logic verification |
| Error list | `XcodeListNavigatorIssues` | At the start of troubleshoot |

### When to auto-load reference docs

- If the user's query keywords **match** the Document Routing Table below → Read the reference doc to provide latest API info
- If they **don't match** → proceed without a reference doc, using general Swift/Apple framework knowledge plus Xcode MCP tools
- For code style, see `references/code-style.md`
- To avoid common mistakes, see `references/common-mistakes.md`

---

## Document Routing Table

Analyze the user query and find the relevant reference file in the table below.

| Topic | Reference File | Match Keywords | Platforms |
|-------|---------------|----------------|-----------|
| Liquid Glass (SwiftUI) | `references/liquid-glass-swiftui.md` | glassEffect, Glass, GlassEffectContainer, liquid glass, 유리 | iOS, macOS, visionOS |
| Liquid Glass (UIKit) | `references/liquid-glass-uikit.md` | UIGlassEffect, UIGlassContainerEffect, UIScrollEdgeEffect | iOS |
| Liquid Glass (AppKit) | `references/liquid-glass-appkit.md` | NSGlassEffectView, NSGlassEffectContainerView | macOS |
| Liquid Glass (WidgetKit) | `references/liquid-glass-widgetkit.md` | widget glass, widgetRenderingMode, widgetAccentable | iOS, macOS, visionOS |
| FoundationModels | `references/foundation-models.md` | FoundationModels, SystemLanguageModel, LanguageModelSession, @Generable, Tool protocol, 온디바이스 LLM | iOS, macOS |
| Swift 6.3 Language & Tooling | `references/swift-6-3-language-and-tooling.md` | Swift 6.3, @c, module selectors, ::, @specialize, @inline(always), @export(implementation), swift package show-traits, Issue.record, Test.cancel, DocC, Android SDK | All |
| Swift 6.2 Concurrency (Apple original) | `references/swift-concurrency.md` | @concurrent, nonisolated, Sendable, data race, actor, 동시성, async/await | All |
| Concurrency Supplement (policy / deep-dive) | `references/swift-concurrency-supplement.md` | lock, semaphore, sync, DispatchSemaphore, NSLock, Mutex, AsyncStream.makeStream, bufferingPolicy, DiscardingTaskGroup, ThrowingDiscardingTaskGroup, bounded concurrency, sliding window, nonisolated(nonsending), NonisolatedNonsendingByDefault, defaultIsolation, MainActor 모듈 격리, SE-0461, SE-0466, SE-0433, forward progress, cooperative thread pool, 협력적 스레드 풀, 데드락, CLLocationManager AsyncStream, URLSession 취소, CheckedContinuation actor, LIBDISPATCH_COOPERATIVE_POOL_STRICT | All |
| InlineArray & Span | `references/swift-inline-array-span.md` | InlineArray, Span, MutableSpan, RawSpan, OutputSpan, UTF8Span | All |
| SwiftData Inheritance | `references/swiftdata-inheritance.md` | SwiftData, @Model, class inheritance, 클래스 상속, polymorphic | All |
| Visual Intelligence | `references/visual-intelligence.md` | Visual Intelligence, SemanticContentDescriptor, IntentValueQuery, 비주얼 인텔리전스 | iOS |
| AlarmKit | `references/alarmkit.md` | AlarmKit, AlarmManager, Alarm, AlarmPresentation, AlarmAttributes, 알람 | iOS, watchOS |
| WebKit + SwiftUI | `references/webkit-swiftui.md` | WebKit, WebView, WebPage, callJavaScript, 웹뷰 | iOS, macOS |
| StoreKit Updates | `references/storekit-updates.md` | StoreKit, AppTransaction, SubscriptionOfferView, in-app purchase, 인앱 결제, 구독 | iOS, macOS |
| 3D Charts | `references/charts-3d.md` | Chart3D, SurfacePlot, Chart3DPose, Chart3DCameraProjection, 3D 차트 | iOS, macOS, visionOS |
| MapKit GeoToolbox | `references/mapkit-geotoolbox.md` | MapKit, GeoToolbox, PlaceDescriptor, PlaceRepresentation, geocoding, 지도 | iOS, macOS |
| AppIntents Updates | `references/appintents-updates.md` | AppIntents, SnippetIntent, @ComputedProperty, @DeferredProperty, Shortcuts, 단축어, Spotlight | iOS, macOS, watchOS |
| AttributedString | `references/attributedstring-updates.md` | AttributedString, TextAlignment, WritingDirection, LineHeight, 속성 문자열 | iOS, macOS |
| Toolbar Features | `references/swiftui-toolbar.md` | toolbar, ToolbarSpacer, DefaultToolbarItem, SearchToolbarBehavior, 툴바 | iOS, macOS |
| Styled Text Editing | `references/styled-text.md` | TextEditor, AttributedTextSelection, textFormattingDefinition, 스타일 텍스트 | iOS, macOS |
| Assistive Access | `references/assistive-access.md` | AssistiveAccess, AssistiveAccessScene, accessibilityAssistiveAccessEnabled, 접근성 | iOS |
| visionOS Widgets | `references/visionos-widgets.md` | supportedMountingStyles, widgetTexture, levelOfDetail, showsWidgetContainerBackground | visionOS |

## Reference Loading Strategy

1. **Keyword match**: compare the user query keywords against the Match Keywords in the table above
2. **Selective load**: Read only the matched reference files
   - Single topic → 1 file
   - Composite topic (e.g. "Liquid Glass in a widget") → 2-3 files
3. **Fallback search**: when the match is unclear, Grep across references/:
   ```
   Grep: pattern="<search term>" path="${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references/"
   ```
4. **External search**: for APIs not in the local references, use `mcp__xcode__DocumentationSearch`

### Concurrency pair-loading rule

When Swift Concurrency keywords match, load **both files together**:
- `references/swift-concurrency.md` (Apple original — Approachable Concurrency overview, isolated conformances, base spec)
- `references/swift-concurrency-supplement.md` (oozoofrog policy — no blocking synchronization, SE-0461/0466/0433 deep dives, verified code examples, exact conditions under which `lock` is allowed)

The `lock` / `semaphore` / `sync` / `Mutex` / `AsyncStream.makeStream` / `DiscardingTaskGroup` / `bounded concurrency` / `nonisolated(nonsending)` / `defaultIsolation` keywords can load the supplement alone.

---

## Mode: implement

Use when writing or editing code in a Swift/Xcode project.

### Phase 1: Gather context
1. Run Phase 0 of the Core Workflow
2. Match keywords against the Document Routing Table → on a match, Read the relevant reference file
3. Survey the user's existing code (Grep/Glob for related files)

### Phase 2: Write code
1. If a reference doc matched, base the code on its examples; otherwise use general Swift knowledge
2. Apply changes via Write/Edit
3. Read `references/code-style.md` for code style
4. On a reference match, Read `references/common-mistakes.md` to avoid common mistakes

### Phase 3: Build verification (when Xcode MCP is connected)
1. Quick diagnosis with `mcp__xcode__XcodeRefreshCodeIssuesInFile` (first)
2. Full build with `mcp__xcode__BuildProject` if needed
3. On error → check logs with `mcp__xcode__GetBuildLog` → fix → rebuild

### Phase 3.5: Re-verify requirements

A successful build only means it compiled — not that the user's requirements are met.

1. **Match against requirements**:
   - List the user requirements gathered in Phase 1
   - Cross-check the written code 1:1 against each requirement
   - Read the code to directly confirm the core logic/API usage

2. **Final check against reference best practices**:
   - If a reference doc matched in Phase 1, re-check its best practices
   - Read `references/common-mistakes.md` for a final anti-pattern cross-check
   - Grep for "Wrong" patterns to confirm none remain in the written code

3. **Verdict**:
   - All requirements met + no anti-patterns → proceed to Phase 4
   - Unmet requirements exist → **return to Phase 2** and rewrite
   - Anti-pattern found → fix only that part, then re-run Phase 3 (build re-verification)

4. **Regression limit**: the Phase 2 → 3 → 3.5 loop runs **at most twice**.
   If requirements remain unmet after two regressions, report the current state to the user and ask for a decision.

### Phase 4: Visual verification (for UI work)
1. Check the SwiftUI preview with `mcp__xcode__RenderPreview`
2. Verify visual features like Liquid Glass, Charts 3D, and Toolbar in the preview, since visual regressions aren't caught by a build

See `references/response-templates.md` for response formats.

---

## Mode: explore

Use when explaining Apple framework APIs, comparing changes, or guiding usage.

### Phase 1: Look up docs
1. Match keywords against the Document Routing Table → on a match, Read the relevant reference file
2. Search official docs with `mcp__xcode__DocumentationSearch` (use regardless of match)
3. If the user's project has related code, survey it with Grep/Glob

### Phase 2: Structured explanation
1. Structure per the Apple DocC pattern (Summary → Overview → Code Example → Details)
2. Present key API types/methods as code blocks
3. When a Before/After comparison helps, present the two code blocks in sequence

### Phase 3: Execution check (optional)
1. Verify API behavior with `mcp__xcode__ExecuteSnippet`
2. Show the results if the user wants them

See `references/response-templates.md` for response formats.

---

## Mode: troubleshoot

Use when resolving build errors, runtime crashes, performance issues, or API misuse.

### Phase 1: Collect errors
1. Check errors with `mcp__xcode__GetBuildLog` or `mcp__xcode__XcodeListNavigatorIssues`
2. When Xcode MCP isn't connected, analyze the error messages/logs the user provided
3. Identify the relevant API/framework from the error message

### Phase 2: Root-cause analysis
1. Match keywords against the Document Routing Table → on a match, search the reference file
2. On a match, Read `references/common-mistakes.md` to check for known patterns
3. Without a match, analyze the cause with general Swift/Xcode debugging knowledge
4. Compare the user's code against the correct pattern

### Phase 3: Apply the fix
1. Propose the change as Before (current erroring code) / After (fixed code)
2. Apply the fix via Edit
3. If a reference doc matched, cite it as the basis for the fix

### Phase 4: Re-verify
1. Quick diagnosis with `mcp__xcode__XcodeRefreshCodeIssuesInFile`
2. Rebuild with `mcp__xcode__BuildProject` if needed
3. Confirm the error is gone and no new warnings appear

See `references/response-templates.md` for response formats.

---

## Rules

- Respond in Korean, keeping code and API names in their original form
- Support **all Apple platform Swift/Xcode work** (regardless of reference doc matches)
- On a reference doc match, follow the Knowledge Authority above (prefer it over training data and cite the source filename)
- Use official platform names (iOS, iPadOS, macOS, watchOS, visionOS)
- Prefer Swift Concurrency (async/await) over Combine
- Use the Swift Testing framework (`@Test`, `#expect`) for tests
- Use the `#Preview` macro for previews
- Avoid force unwrap; lean on the strong type system
- Respect the project's existing patterns and code style — project conventions take precedence
- Use the Xcode MCP tools (build, preview, doc search) actively when they're available

---

## Limitations and caveats

1. **Reference scope**: provides the 20 bundled Xcode 26.4 docs, the Swift 6.3 supplements, and the Concurrency Supplement (no-blocking-synchronization policy + SE-0461/0466/0433 deep dives). Frameworks/APIs not in the references are still supported via general knowledge and `DocumentationSearch`.
2. **Beta API drift**: if a reference doc's code won't compile, confirm the latest signature with `mcp__xcode__DocumentationSearch`.
3. **Context management**: reference docs are 200-800 lines. Loading 3+ at once on a composite topic grows context, so load the 1-2 most relevant first.
4. **Xcode MCP not connected**: without the Xcode MCP server, build verification and previews are unavailable. Support as far as possible with general tools (Bash, Read, etc.), and advise the user "Xcode에서 빌드하여 검증해주세요".
