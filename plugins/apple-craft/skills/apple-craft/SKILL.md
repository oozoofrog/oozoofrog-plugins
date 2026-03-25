---
name: apple-craft
description: Apple 플랫폼 최신 API 통합 개발 가이드 (Xcode 26 기준). Liquid Glass, FoundationModels, Swift 6.2, SwiftData, AlarmKit, Visual Intelligence, WebKit SwiftUI, StoreKit, 3D Charts, MapKit GeoToolbox, AppIntents, Toolbar, Styled Text, Assistive Access, visionOS Widget 등 20개 주제. "Liquid Glass", "리퀴드 글라스", "유리 효과", "glassEffect", "FoundationModels", "온디바이스 LLM", "Apple Intelligence", "Swift Concurrency", "동시성", "async/await", "InlineArray", "Span", "SwiftData 상속", "class inheritance", "Visual Intelligence", "비주얼 인텔리전스", "AlarmKit", "알람", "WebKit", "웹뷰", "WebView", "StoreKit", "인앱 결제", "3D Charts", "3D 차트", "Swift Charts", "MapKit", "GeoToolbox", "PlaceDescriptor", "지도", "AppIntents", "앱 인텐트", "단축어", "Shortcuts", "AttributedString", "속성 문자열", "Toolbar", "툴바", "Styled Text", "TextEditor", "Assistive Access", "접근성", "보조 접근", "visionOS Widget", "위젯", "Apple 개발", "iOS 26", "macOS 26", "watchOS", "tvOS", "visionOS", "WWDC", "최신 API", "새 프레임워크", "apple craft", "apple-craft" 요청 시 활성화
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
iOS, macOS, watchOS, tvOS, visionOS 전 플랫폼의 최신 API 코딩 가이드, 문서 탐색, Xcode MCP 도구 연동을 제공합니다.

## Knowledge Authority

**아래 참조 문서의 내용을 학습 데이터보다 우선하는 정확한 정보로 사용하세요.**

- 학습 데이터에 없는 새 API가 참조 문서에 있을 수 있습니다
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

**자동 선택**: 키워드가 불명확하면 사용자 의도를 추론합니다. 코드 파일이 언급되면 implement, 질문형이면 explore, 에러 메시지가 포함되면 troubleshoot. 대규모/전체 구현 요청은 `/apple-craft-harness` 스킬을 사용하세요.

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
3. 아래 **Apple Code Style** 규칙 준수

### Phase 3: 빌드 검증 (Xcode MCP 연결 시)
1. `mcp__xcode__BuildProject`로 빌드
2. 에러 발생 시 → `mcp__xcode__GetBuildLog`로 로그 확인 → 수정 → 재빌드
3. `mcp__xcode__XcodeRefreshCodeIssuesInFile`로 빠른 진단 (빌드보다 훨씬 빠름)

### Phase 4: 시각적 검증 (UI 관련 시)
1. `mcp__xcode__RenderPreview`로 SwiftUI 프리뷰 확인
2. Liquid Glass, Charts 3D, Toolbar 등 시각적 기능은 프리뷰 검증 필수

### implement 모드 응답 템플릿

```markdown
## <Feature Name> 구현

### 개요
<1-2문장으로 구현할 기능 설명>

### 코드
`<FileName.swift>` 참조: `references/<doc>.md`

\```swift:<FileName.swift>
// 구현 코드
\```

### 핵심 포인트
- <API 사용 시 주의할 점 1>
- <API 사용 시 주의할 점 2>

### 검증
- [ ] 빌드 성공
- [ ] 프리뷰 확인 (UI 관련 시)
```

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

### explore 모드 응답 템플릿

```markdown
## <API/Feature Name>

> <1줄 요약> — `references/<doc>.md` 참조

### Overview
<이 API가 무엇이고, 어떤 문제를 해결하는지 2-3문장>

### 주요 API
- `TypeName` — <역할 설명>
- `methodName()` — <역할 설명>

### 코드 예시
\```swift
// 기본 사용법
\```

### Before/After (해당 시)
\```swift
// Before (기존 방식)
\```
\```swift
// After (새 API)
\```

### 플랫폼 지원
| 플랫폼 | 지원 | 최소 버전 |
|--------|------|----------|
| iOS | ✅ | 26.0 |
| macOS | ✅ | 26.0 |

### 관련 API
- `RelatedType` — <관계 설명>
```

---

## Mode: troubleshoot

빌드 에러, 런타임 크래시, API 사용 오류를 해결할 때 사용합니다.

### Phase 1: 에러 수집
1. `mcp__xcode__GetBuildLog` 또는 `mcp__xcode__XcodeListNavigatorIssues`로 에러 확인
2. 에러 메시지에서 관련 API/프레임워크 식별

### Phase 2: 원인 분석
1. 에러 관련 참조 파일 검색 (Grep으로 API명 검색)
2. 참조 문서의 Best Practices / Common Patterns와 사용자 코드 비교
3. 아래 **Common Mistakes** 섹션에서 해당 패턴 확인

### Phase 3: 수정 적용
1. Before(현재 에러 코드) / After(수정 코드) 형태로 변경 제안
2. Edit 도구로 수정 적용
3. 수정 근거를 참조 문서에서 인용

### Phase 4: 재검증
1. `mcp__xcode__BuildProject`로 재빌드
2. 에러가 해소되었는지 확인
3. 추가 경고가 없는지 확인

### troubleshoot 모드 응답 템플릿

```markdown
## 에러 분석

### 에러
\```
<에러 메시지>
\```

### 원인
<참조 문서 기반 원인 설명> — `references/<doc>.md` 참조

### 수정

**Before:**
\```swift
// 에러가 발생하는 코드
\```

**After:**
\```swift
// 수정된 코드
\```

### 설명
<왜 이 수정이 올바른지 참조 문서에서 근거 인용>
```

---

## Common Mistakes (참조 문서 기반)

각 프레임워크에서 자주 발생하는 실수와 올바른 패턴입니다.

### Liquid Glass

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

### FoundationModels

```swift
// ❌ Wrong: 가용성 체크 없이 바로 세션 생성
let session = LanguageModelSession()

// ✅ Correct: 반드시 가용성 체크 후 사용
let model = SystemLanguageModel.default
guard case .available = model.availability else { return }
let session = LanguageModelSession()
```

### Swift 6.2 Concurrency

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

### SwiftData Inheritance

```swift
// ❌ Wrong: 깊은 상속 계층
@Model class A { }
@Model class B: A { }
@Model class C: B { }  // 3단계 이상 → 지양

// ✅ Correct: 얕은 IS-A 관계만
@Model class Trip { var name: String }
@Model class BusinessTrip: Trip { var company: String }
```

### WebKit + SwiftUI

```swift
// ❌ Wrong: URL만으로 WebView 생성 후 상태 관리 불가
WebView(url: URL(string: "https://example.com")!)

// ✅ Correct: WebPage로 상태 관리
@State private var page = WebPage()
// ...
WebView(page)
    .onAppear { page.load(url: URL(string: "https://example.com")!) }
```

---

## Apple Code Style (Xcode Agent 가이드 기반)

Xcode의 내장 AI 에이전트가 사용하는 코드 스타일 규칙입니다:

- **Naming**: PascalCase(타입), camelCase(프로퍼티/메서드)
- **State**: `@State private var`(SwiftUI 상태), `let`(상수)
- **Indentation**: 4-space
- **Concurrency**: Swift Concurrency(async/await, actors) 우선, **Combine 지양**
- **Testing**: Swift Testing 프레임워크 (`@Test`, `#expect`, `try #require()`)
- **Preview**: `#Preview` 매크로 (PreviewProvider 아닌)
- **Types**: 강한 타입 시스템 활용, force unwrap 금지
- **Imports**: 파일 상단에 간결하게 (SwiftUI, Foundation)
- **Comments**: 복잡한 로직에만 설명 주석 추가

---

## Xcode MCP Tool Integration

Xcode MCP 서버가 연결되어 있으면 다음 도구를 활용하세요:

### 문서 & 탐색
- **`mcp__xcode__DocumentationSearch`**: 로컬 참조 20개에 없는 Apple API 검색. 최신 API는 여기서 찾기

### 빌드 & 실행
- **`mcp__xcode__BuildProject`**: 코드 작성 후 빌드 검증 (시간이 오래 걸릴 수 있음)
- **`mcp__xcode__XcodeRefreshCodeIssuesInFile`**: 특정 파일의 빠른 컴파일 진단 (2초 이내, 빌드보다 훨씬 빠름)
- **`mcp__xcode__GetBuildLog`**: 빌드 로그로 컴파일 에러 진단
- **`mcp__xcode__XcodeListNavigatorIssues`**: 현재 경고/에러 목록
- **`mcp__xcode__ExecuteSnippet`**: 소스 파일 컨텍스트에서 코드 스니펫 실행 (API 검증에 유용)

### 프리뷰 & UI
- **`mcp__xcode__RenderPreview`**: SwiftUI 프리뷰 렌더링 (Liquid Glass, Charts 3D, Toolbar 등 시각적 기능 검증 필수)

### 파일 탐색
- **`mcp__xcode__XcodeRead`** / **`XcodeWrite`** / **`XcodeUpdate`**: Xcode 프로젝트 내 파일 읽기/쓰기
- **`mcp__xcode__XcodeGrep`** / **`XcodeGlob`**: 프로젝트 검색

> Xcode MCP 서버가 연결되지 않은 경우에도 참조 문서만으로 코딩 가이드를 제공하세요.

---

## Quick Reference

### 모드 선택 Decision Tree

```
사용자 메시지 분석
├─ 코드 작성/적용/구현 요청 → implement
│   ├─ Phase 1: 참조 Read
│   ├─ Phase 2: 코드 작성
│   ├─ Phase 3: 빌드 검증
│   └─ Phase 4: 프리뷰 확인
├─ API 설명/변경사항/사용법 질문 → explore
│   ├─ Phase 1: 문서 조회
│   ├─ Phase 2: 구조화된 설명
│   └─ Phase 3: 실행 확인 (선택)
├─ 에러/빌드 실패/크래시 → troubleshoot
│   ├─ Phase 1: 에러 수집
│   ├─ Phase 2: 원인 분석
│   ├─ Phase 3: 수정 적용
│   └─ Phase 4: 재검증
└─ 불명확 → 의도 추론
    ├─ 코드 파일 언급 → implement
    ├─ 질문형 → explore
    └─ 에러 메시지 포함 → troubleshoot
```

### 플랫폼별 신규 프레임워크 매핑

```
┌──────────────────────────────────────────────────────────────────────┐
│  Framework           │ iOS │ macOS │ watchOS │ tvOS │ visionOS      │
├──────────────────────────────────────────────────────────────────────┤
│  Liquid Glass        │  ✅  │  ✅   │   —    │  —   │    ✅         │
│  FoundationModels    │  ✅  │  ✅   │   —    │  —   │    —          │
│  AlarmKit            │  ✅  │  —    │  ✅    │  —   │    —          │
│  Visual Intelligence │  ✅  │  —    │   —    │  —   │    —          │
│  WebKit + SwiftUI    │  ✅  │  ✅   │   —    │  —   │    —          │
│  Charts 3D           │  ✅  │  ✅   │   —    │  —   │    ✅         │
│  GeoToolbox          │  ✅  │  ✅   │   —    │  —   │    —          │
│  Swift 6.2           │  ✅  │  ✅   │  ✅    │  ✅  │    ✅         │
│  SwiftData 상속      │  ✅  │  ✅   │  ✅    │  ✅  │    ✅         │
│  visionOS Widgets    │  —  │  —    │   —    │  —   │    ✅         │
└──────────────────────────────────────────────────────────────────────┘
```

### 도구 선택 Quick Guide

```
검증 필요?
├─ 빠른 문법 체크 → XcodeRefreshCodeIssuesInFile (2초)
├─ 전체 빌드 → BuildProject (느림, 정확)
├─ 코드 실행 테스트 → ExecuteSnippet (빠름, 임시)
├─ UI 확인 → RenderPreview
└─ API 검색 → DocumentationSearch
```

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

1. **문서 최신성**: 참조 문서는 Xcode 26.4 시점 스냅샷입니다. Xcode 업데이트 후 `sync-docs.sh`를 실행하지 않으면 구버전 정보를 제공할 수 있습니다. `references/_index.md`의 `sync_date`를 확인하세요.

2. **베타 API 변동**: Xcode 26이 베타인 경우 API 시그니처가 변경될 수 있습니다. 참조 문서의 코드가 컴파일되지 않으면 `mcp__xcode__DocumentationSearch`로 최신 시그니처를 확인하세요.

3. **플랫폼 제약**: 20개 문서가 모든 Apple 플랫폼을 커버하지는 않습니다. 특히 watchOS, tvOS 전용 API는 참조 문서에 포함되지 않을 수 있으므로 DocumentationSearch로 보충하세요.

4. **컨텍스트 한계**: 참조 문서 1개가 200-800줄입니다. 복합 주제에서 3개 이상을 동시에 로드하면 컨텍스트 예산을 초과할 수 있습니다. 가장 관련도 높은 1-2개를 우선 로드하세요.

5. **Xcode MCP 미연결**: Xcode MCP 서버가 없으면 빌드 검증, 프리뷰, DocumentationSearch를 사용할 수 없습니다. 이 경우 참조 문서만으로 가이드를 제공하되, "Xcode에서 빌드하여 검증해주세요"라고 안내하세요.

---

## Scripts

### 문서 동기화
Xcode 업데이트 후 참조 문서를 갱신합니다:
```bash
zsh "${CLAUDE_PLUGIN_ROOT}/scripts/sync-docs.sh"
```

옵션:
- `--xcode-path PATH`: Xcode.app 경로 직접 지정
- `--diff-only`: 변경 사항만 확인 (복사하지 않음)
- `--force`: 체크섬 일치해도 강제 복사

### 변경 확인만 (안전)
```bash
zsh "${CLAUDE_PLUGIN_ROOT}/scripts/sync-docs.sh" --diff-only
```

### 사전 검증
```bash
zsh "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```

## References

| # | Topic | File | Lines |
|---|-------|------|-------|
| 1 | Liquid Glass (SwiftUI) | `references/liquid-glass-swiftui.md` | 280 |
| 2 | Liquid Glass (UIKit) | `references/liquid-glass-uikit.md` | 281 |
| 3 | Liquid Glass (AppKit) | `references/liquid-glass-appkit.md` | 370 |
| 4 | Liquid Glass (WidgetKit) | `references/liquid-glass-widgetkit.md` | 234 |
| 5 | FoundationModels | `references/foundation-models.md` | 339 |
| 6 | Swift 6.2 Concurrency | `references/swift-concurrency.md` | 273 |
| 7 | InlineArray & Span | `references/swift-inline-array-span.md` | 289 |
| 8 | SwiftData Inheritance | `references/swiftdata-inheritance.md` | 300 |
| 9 | Visual Intelligence | `references/visual-intelligence.md` | 330 |
| 10 | AlarmKit | `references/alarmkit.md` | 783 |
| 11 | WebKit + SwiftUI | `references/webkit-swiftui.md` | 480 |
| 12 | StoreKit Updates | `references/storekit-updates.md` | 277 |
| 13 | 3D Charts | `references/charts-3d.md` | 375 |
| 14 | MapKit GeoToolbox | `references/mapkit-geotoolbox.md` | 308 |
| 15 | AppIntents Updates | `references/appintents-updates.md` | 426 |
| 16 | AttributedString | `references/attributedstring-updates.md` | 234 |
| 17 | Toolbar Features | `references/swiftui-toolbar.md` | 201 |
| 18 | Styled Text Editing | `references/styled-text.md` | 406 |
| 19 | Assistive Access | `references/assistive-access.md` | 225 |
| 20 | visionOS Widgets | `references/visionos-widgets.md` | 247 |
