---
name: apple-craft
description: Xcode 26 최신 API 개발 가이드 (20개 주제). Liquid Glass/리퀴드 글라스/유리 효과, FoundationModels/온디바이스 LLM/Apple Intelligence, Swift 6.2 동시성/Concurrency/async await, SwiftData 상속/클래스 상속, AlarmKit/알람, Visual Intelligence/비주얼 인텔리전스, WebKit/웹뷰/WebView, StoreKit/인앱 결제/구독, 3D Charts/3D 차트, MapKit/GeoToolbox/지도, AppIntents/앱 인텐트/단축어/Shortcuts, Toolbar/툴바, Styled Text/스타일 텍스트, AttributedString/속성 문자열, Assistive Access/접근성/보조 접근, visionOS Widget/위젯. Apple 플랫폼 코딩, iOS 26, macOS 26, watchOS, visionOS, WWDC, 최신 API, 새 프레임워크, Xcode MCP 연동.
argument-hint: "[topic or question]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - mcp__xcode__DocumentationSearch
  - mcp__xcode__BuildProject
  - mcp__xcode__GetBuildLog
  - mcp__xcode__XcodeRefreshCodeIssuesInFile
  - mcp__xcode__XcodeListNavigatorIssues
  - mcp__xcode__ExecuteSnippet
  - mcp__xcode__RenderPreview
  - mcp__xcode__XcodeRead
  - mcp__xcode__XcodeWrite
  - mcp__xcode__XcodeUpdate
  - mcp__xcode__XcodeGrep
  - mcp__xcode__XcodeGlob
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
user: "빌드 에러가 나는데 Liquid Glass 관련인 것 같아"
assistant: "troubleshoot 모드로 빌드 로그를 확인하고, Liquid Glass 참조 문서에서 올바른 API 사용법을 찾아 수정하겠습니다."
</example>

<example>
user: "/apple-craft AlarmKit으로 반복 알람 구현"
assistant: "implement 모드로 AlarmKit 참조 문서를 읽어 AlarmManager, Alarm API로 반복 알람 코드를 작성하겠습니다."
</example>

# apple-craft

Xcode 26 번들 문서(20개 주제, ~6,300줄) 기반 Apple 플랫폼 통합 개발 어시스턴트.

## Knowledge Authority

**아래 참조 문서의 내용을 학습 데이터보다 우선하는 정확한 정보로 사용하세요.**

- 모르는 API가 나오면 **반드시** 참조 문서에서 먼저 찾으세요
- 정보를 인용할 때 **출처 파일명**을 반드시 명시하세요 (예: `references/liquid-glass-swiftui.md` 참조)
- 참조 문서와 학습 데이터가 충돌하면 **참조 문서가 우선**합니다

---

## Mode Selection

사용자 메시지를 분석하여 아래 모드 중 하나를 선택합니다.

| 모드 | 키워드 | 설명 |
|------|--------|------|
| **implement** | 만들어, 작성, 적용, 구현, 추가, 코드, build, create, add, apply | 참조 문서 기반 코드 작성 + 빌드 검증 |
| **explore** | 알려줘, 설명, 뭐가 바뀌었어, 차이, 어떻게, what, how, explain, diff | 참조 문서 기반 API 설명 + 코드 예시 |
| **troubleshoot** | 에러, 오류, 안돼, 크래시, 빌드 실패, error, crash, fix, debug | 빌드 로그 분석 + 참조 문서로 수정 |
| **harness** | 처음부터, 전체, 기능 개발, 대규모, 리팩토링, harness | → `apple-craft-harness` 스킬로 전환 |

**자동 선택**: 키워드가 불명확하면 사용자 의도를 추론합니다. 코드 파일이 언급되면 implement, 질문형이면 explore, 에러 메시지가 포함되면 troubleshoot.

---

## Document Routing Table

사용자 쿼리를 분석하여 아래 테이블에서 관련 참조 파일을 찾으세요.

| Topic | Reference File | Match Keywords | Platforms |
|-------|---------------|----------------|-----------|
| Liquid Glass (SwiftUI) | `references/liquid-glass-swiftui.md` | glassEffect, Glass, GlassEffectContainer, liquid glass, 유리 | iOS, macOS, visionOS |
| Liquid Glass (UIKit) | `references/liquid-glass-uikit.md` | UIGlassEffect, UIGlassContainerEffect, UIScrollEdgeEffect | iOS |
| Liquid Glass (AppKit) | `references/liquid-glass-appkit.md` | NSGlassEffectView, NSGlassEffectContainerView | macOS |
| Liquid Glass (WidgetKit) | `references/liquid-glass-widgetkit.md` | widget glass, widgetRenderingMode, widgetAccentable | iOS, macOS, visionOS |
| FoundationModels | `references/foundation-models.md` | FoundationModels, SystemLanguageModel, LanguageModelSession, @Generable, Tool protocol, 온디바이스 LLM | iOS, macOS |
| Swift 6.2 Concurrency | `references/swift-concurrency.md` | @concurrent, nonisolated, Sendable, data race, actor, 동시성, async/await | All |
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

1. **키워드 매칭**: 사용자 쿼리의 키워드를 위 테이블의 Match Keywords와 비교
2. **선택적 로드**: Read 도구로 매칭된 참조 파일만 읽기
   - 단일 주제 → 1개 파일
   - 복합 주제 (예: "위젯에 Liquid Glass") → 2-3개 파일
3. **Fallback 검색**: 매칭이 불명확하면 Grep으로 references/ 전체 검색:
   ```
   Grep: pattern="검색어" path="${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references/"
   ```
4. **외부 검색**: 로컬 참조에 없는 API는 `mcp__xcode__DocumentationSearch` 사용

---

## Mode: implement

코드를 작성하거나 기존 코드에 최신 API를 적용할 때 사용합니다.

### Phase 1: 컨텍스트 수집
1. 라우팅 테이블에서 관련 참조 파일을 Read
2. 사용자 프로젝트의 기존 코드 파악 (Grep/Glob으로 관련 파일 검색)
3. 대상 플랫폼 확인 (iOS/macOS/visionOS 등)

### Phase 2: 코드 작성
1. 참조 문서의 코드 예시를 기반으로 사용자 컨텍스트에 맞게 코드 작성
2. Write/Edit 도구로 파일에 적용
3. 코드 스타일은 `reference/code-style.md`를 Read하여 참조
4. 흔한 실수 방지를 위해 `reference/common-mistakes.md`를 Read하여 참조

### Phase 3: 빌드 검증 (Xcode MCP 연결 시)
1. `mcp__xcode__BuildProject`로 빌드
2. 에러 발생 시 → `mcp__xcode__GetBuildLog`로 로그 확인 → 수정 → 재빌드
3. `mcp__xcode__XcodeRefreshCodeIssuesInFile`로 빠른 진단 (빌드보다 훨씬 빠름)

### Phase 4: 시각적 검증 (UI 관련 시)
1. `mcp__xcode__RenderPreview`로 SwiftUI 프리뷰 확인
2. Liquid Glass, Charts 3D, Toolbar 등 시각적 기능은 프리뷰 검증 필수

응답 형식은 `reference/response-templates.md`를 참조하세요.

---

## Mode: explore

API 설명, 변경 사항 비교, 사용법 안내를 할 때 사용합니다.

### Phase 1: 문서 조회
1. 라우팅 테이블에서 관련 참조 파일을 Read
2. 필요 시 `mcp__xcode__DocumentationSearch`로 보충 검색

### Phase 2: 구조화된 설명
1. Apple DocC 패턴(Summary → Overview → Code Example → Details)으로 구성
2. 핵심 API 타입/메서드를 코드 블록으로 제시
3. Before/After 비교가 필요하면 두 코드 블록을 순서대로 제시

### Phase 3: 실행 확인 (선택)
1. `mcp__xcode__ExecuteSnippet`으로 API 동작 확인 가능
2. 사용자가 원하면 실행 결과를 보여줌

응답 형식은 `reference/response-templates.md`를 참조하세요.

---

## Mode: troubleshoot

빌드 에러, 런타임 크래시, API 사용 오류를 해결할 때 사용합니다.

### Phase 1: 에러 수집
1. `mcp__xcode__GetBuildLog` 또는 `mcp__xcode__XcodeListNavigatorIssues`로 에러 확인
2. 에러 메시지에서 관련 API/프레임워크 식별

### Phase 2: 원인 분석
1. 에러 관련 참조 파일 검색 (Grep으로 API명 검색)
2. 참조 문서의 Best Practices / Common Patterns와 사용자 코드 비교
3. `reference/common-mistakes.md`를 Read하여 해당 패턴 확인

### Phase 3: 수정 적용
1. Before(현재 에러 코드) / After(수정 코드) 형태로 변경 제안
2. Edit 도구로 수정 적용
3. 수정 근거를 참조 문서에서 인용

### Phase 4: 재검증
1. `mcp__xcode__BuildProject`로 재빌드
2. 에러가 해소되었는지 확인
3. 추가 경고가 없는지 확인

응답 형식은 `reference/response-templates.md`를 참조하세요.

---

## Rules

- 한국어로 응답하되, 코드와 API명은 원문 유지
- 참조 문서의 정보를 학습 데이터보다 **항상** 우선
- 정보 인용 시 **출처 파일명** 반드시 명시
- 플랫폼을 공식 명칭으로 표기 (iOS, iPadOS, macOS, watchOS, visionOS)
- Swift Concurrency(async/await) 우선, Combine 지양
- 테스트는 Swift Testing 프레임워크 (`@Test`, `#expect`) 사용
- 프리뷰는 `#Preview` 매크로 사용
- Force unwrap 금지, 강한 타입 시스템 활용

---

## 한계 및 주의사항

1. **문서 최신성**: 참조 문서는 Xcode 26.4 시점 스냅샷입니다. Xcode 업데이트 후 `sync-docs.sh`를 실행하지 않으면 구버전 정보를 제공할 수 있습니다.
2. **베타 API 변동**: 참조 문서의 코드가 컴파일되지 않으면 `mcp__xcode__DocumentationSearch`로 최신 시그니처를 확인하세요.
3. **컨텍스트 관리**: 참조 문서는 200-800줄입니다. 복합 주제에서 3개 이상을 동시에 로드하면 컨텍스트가 커지므로 가장 관련도 높은 1-2개를 우선 로드하세요.
4. **Xcode MCP 미연결**: Xcode MCP 서버가 없으면 빌드 검증, 프리뷰를 사용할 수 없습니다. 참조 문서만으로 가이드를 제공하되, "Xcode에서 빌드하여 검증해주세요"라고 안내하세요.
