---
name: pen-craft
description: Step-by-step implementation of Pencil .pen designs into SwiftUI/UIKit view code — component analysis, token mapping, sequential implementation, visual verification. Activate for "디자인 구현", "pen to code", "pen-craft", "디자인에서 코드", "뷰 구현", "디자인 코드", "pen 파일", "pen to swiftui", "design implementation", "디자인 변환", "pen 구현", "pencil 구현", "Pencil에서 SwiftUI", "디자인 코드로", "pen에서 코드", "디자인 to 코드", "코드로 변환" requests.
argument-hint: "[.pen file path or frame name]"
---

<example>
user: "이 .pen 파일의 디자인을 SwiftUI로 구현해줘"
assistant: "pen-craft로 컴포넌트 분석 → 토큰 매핑 → 순차 구현 → 시각 검증 단계를 시작합니다."
</example>

<example>
user: "settings 프레임을 SwiftUI 뷰로 만들어줘"
assistant: "pen-craft로 settings 프레임을 분석하고 단계별로 SwiftUI 뷰를 구현하겠습니다."
</example>

<example>
user: "이 디자인의 카드 컴포넌트를 UIKit으로 구현해줘"
assistant: "pen-craft로 카드 컴포넌트를 추출하고 UIKit UIView로 구현하겠습니다."
</example>

# pen-craft

Implements `.pen` designs into SwiftUI/UIKit view code by following Pencil MCP's recommended step-by-step procedure.
This is not a simple conversion — it runs the full pipeline: **component analysis → token extraction → sequential implementation → visual verification**.

> Pencil MCP connection is required. If not connected, guide the user to connect and then exit.

Respond to the user in Korean.

## Execution modes

pen-craft selects the mode automatically based on the target scope:

| Mode | Target | Procedure |
|------|------|------|
| **component** | A single specific component | Phase 1 → 3 (that component only) |
| **screen** | A single screen frame | Phase 1 → 2 → 3 → 4 → 5 |
| **full** | The entire .pen file | Phase 0 → 1 → 2 → 3 → 4 → 5 (all screens) |

## Phase 0: Environment detection & reading the design

### Step 0-1: Verify Pencil MCP connection

```
get_editor_state()
```

- Success → check the active .pen file info, proceed to Step 0-2
- Failure → guide with "Pencil MCP가 연결되지 않았습니다. Pencil 앱을 실행하고 MCP를 활성화해주세요." and exit

### Step 0-2: Identify the target .pen file

When the user specified a path:
```
open_document(filePathOrNew: "경로.pen")
```

When unspecified:
1. Use the active document from `get_editor_state()`
2. If no active document, search for .pen files in the project with `Glob: **/*.pen`
3. If multiple files, ask the user to choose

### Step 0-3: Grasp the overall structure

```
batch_get(patterns: [{type: "frame", readDepth: 2}])
```

→ Review the top-level frame list (screen units). If the user did not specify a particular frame, show the list and ask them to choose.

### Step 0-4: Load Pencil guidelines

```
get_guidelines(category: "code")
```

→ Check Pencil's latest code generation guidelines so they are followed in Phase 3.

## Phase 1: Component analysis & extraction

> Pencil core principle: "Only process components that appear in the current frame."

### Step 1-1: Read the full tree of the target frame

```
batch_get(nodeIds: ["프레임ID"], readDepth: 10)
```

→ The complete node tree. Identify each node's type, name, properties, and children.

### Step 1-2: Identify reusable components (ref)

Find nodes that have a `componentId` in the node tree and build a component list:

| Component | Instance count | Override type |
|----------|-----------|-------------|
| CardItem | 3 | text, icon, color |
| ActionButton | 2 | label, style |

### Step 1-3: Screenshot reference per component

For a representative instance of each component:
```
get_screenshot(nodeId: "인스턴스ID")
```

→ Capture a visual reference image. Compare against the implementation result in Phase 3.

### Step 1-4: Determine dependency order

Analyze the nesting relationships between components and determine a **leaf → parent** order:
```
1. IconBadge (leaf — 다른 컴포넌트에 의존 없음)
2. CardItem (IconBadge를 포함)
3. CardSection (CardItem을 포함)
```

→ This order is the implementation order in Phase 3.

## Phase 2: Design token extraction & SwiftUI/UIKit mapping

### Step 2-1: Extract design variables

```
get_variables()
```

→ All design tokens defined in the .pen file (colors, fonts, spacing, radius, etc.).

### Step 2-2: Collect unique properties

```
search_all_unique_properties(patterns: [{type: "frame"}, {type: "text"}])
```

→ Collect every unique property value used across the frame. Detect hardcoded values that are not mapped to tokens.

### Step 2-3: Generate the SwiftUI token file

Convert the extracted tokens into Swift code.

**SwiftUI target:**

```swift
// DesignTokens.swift

import SwiftUI

// MARK: - Colors
extension Color {
    static let designBackground = Color("bg")     // $bg
    static let designSurface = Color("surface")    // $surface
    static let designAccent = Color("accent")      // $accent
    static let designTextPrimary = Color("textPrimary")
    static let designTextSecondary = Color("textSecondary")
}

// MARK: - Typography
extension Font {
    static let designLargeTitle: Font = .largeTitle  // $font-largeTitle
    static let designTitle: Font = .title2           // $font-title
    static let designBody: Font = .body              // $font-body
    static let designCaption: Font = .caption        // $font-caption
}

// MARK: - Spacing
enum DesignSpacing {
    static let xs: CGFloat = 4     // $spacing-xs
    static let sm: CGFloat = 8     // $spacing-sm
    static let md: CGFloat = 12    // $spacing-md
    static let lg: CGFloat = 16    // $spacing-lg
    static let xl: CGFloat = 24    // $spacing-xl
    static let xxl: CGFloat = 32   // $spacing-xxl
}

// MARK: - Corner Radius
enum DesignRadius {
    static let card: CGFloat = 12    // $radius-card
    static let button: CGFloat = 8   // $radius-button
    static let input: CGFloat = 6    // $radius-input
}
```

**UIKit target:** generate the same pattern with `UIColor`/`UIFont` extensions.

**Token mapping table (for internal record):**

| Pencil token | SwiftUI | UIKit |
|-------------|---------|-------|
| $bg | Color.designBackground | UIColor.designBackground |
| $accent | Color.designAccent | UIColor.designAccent |
| $font-body | Font.designBody | UIFont.designBody |
| $spacing-lg | DesignSpacing.lg | DesignSpacing.lg |
| $radius-card | DesignRadius.card | DesignRadius.card |

> Reference all values from tokens only; do not hardcode, so the design stays the single source of truth.

**For UIKit target, add:**
```swift
extension UIColor {
    static let designBackground = UIColor(named: "bg")!
    // ...
}
```

**Asset Catalog integration:**
If the project has an `.xcassets`, generate Color Sets alongside it.

## Phase 3: Sequential implementation per component

> Pencil core principle: "Process components ONE AT A TIME (extract → recreate → validate → next)."

Following the dependency order determined in Phase 1-4, process **only one component at a time**.

### For each component:

#### Step 3-A: Extract the component structure

```
batch_get(nodeIds: ["컴포넌트ID"], readDepth: 10)
```

→ The complete node tree of that component, including all child nodes, layout, and properties.

#### Step 3-B: Analyze instance overrides

Read all instances of the component and identify the override pattern:

```
batch_get(nodeIds: ["인스턴스1", "인스턴스2", "인스턴스3"])
```

→ Which properties differ per instance → decide which fields to expose as Swift properties.

**Mapping rules:**
- Same value across all instances → constant (fixed inside the View)
- Different value per instance → property (init parameter)
- Different only in some → optional property (with default)

#### Step 3-C: Write the SwiftUI View

**SwiftUI conversion rules:**

| Pencil property | SwiftUI |
|------------|---------|
| layout: "vertical" | VStack(spacing:) |
| layout: "horizontal" | HStack(spacing:) |
| layout: "grid" | LazyVGrid / LazyHGrid |
| width: "fill_container" | .frame(maxWidth: .infinity) |
| height: "fill_container" | .frame(maxHeight: .infinity) |
| width: "fit_content" | default (SwiftUI automatic sizing) |
| padding: [top, right, bottom, left] | .padding(EdgeInsets(...)) |
| gap: N | VStack/HStack spacing parameter |
| fill: "$token" | .background(Color.designXxx) |
| cornerRadius: N | .clipShape(RoundedRectangle(cornerRadius:)) |
| stroke / border | .overlay(RoundedRectangle(...).stroke(...)) |
| opacity: N | .opacity(N) |
| shadow | .shadow(color:radius:x:y:) |
| type: "text" | Text("...").font(.designXxx) |
| type: "image" | Image(systemName:) or Image("asset") |
| overflow: "scroll" | ScrollView { ... } |

**UIKit conversion rules:**

| Pencil property | UIKit |
|------------|-------|
| layout: "vertical" | UIStackView(axis: .vertical) |
| layout: "horizontal" | UIStackView(axis: .horizontal) |
| width: "fill_container" | constraint: widthAnchor == superview |
| padding | layoutMargins / directionalLayoutMargins |
| gap | UIStackView.spacing |
| fill: "$token" | backgroundColor = .designXxx |
| cornerRadius | layer.cornerRadius |

**Code authoring principles:**
1. Use only the values from the token file (DesignTokens.swift generated in Phase 2)
2. Expose instance overrides as Swift properties
3. Keep a 1:1 correspondence between the component node tree and the View hierarchy
4. SVG/vector → prefer SF Symbols; if unavailable, extract with `batch_get(includePathGeometry: true)`

#### Step 3-D: Build verification

Build tool fallback chain:
1. Xcode MCP (`BuildProject`) — top priority
2. `xcodebuild` + `xcsift -E` — CLI fallback
3. `swift build` — SPM project
4. Syntax check only (no build tool)

On build failure, read the error, fix it, and retry (up to 3 times).

#### Step 3-E: Visual verification

1. Obtain the Pencil design screenshot (already captured in Phase 1-3):
   ```
   get_screenshot(nodeId: "컴포넌트ID")
   ```

2. (Optional) Screenshot the implementation result in the simulator:
   - If baepsae MCP is available: `screenshot_app` or `screenshot`
   - If Xcode MCP is available: `RenderPreview`

3. Compare the two images for mismatches:
   - Layout (spacing, alignment)
   - Color (token mapping accuracy)
   - Typography (font, size, weight)
   - Icons/images (size, position)

4. On mismatch → fix the code → return to Step 3-D and re-verify

#### Step 3-F: Completion check

> Pencil core principle: "Only proceed to next component when current is perfect."

Proceed to the next component only when the current one matches the design.
Report progress:

```
✅ IconBadge (1/3) — 완료
🔄 CardItem (2/3) — 구현 중
⬜ CardSection (3/3) — 대기
```

## Phase 4: Screen assembly

Once all components are implemented, assemble the full screen.

### Step 4-A: Re-analyze the frame

```
batch_get(nodeIds: ["프레임ID"], readDepth: 10)
```

→ Re-confirm the latest frame structure. There may have been changes since Phase 1.

### Step 4-B: Map instances

Collect the overrides of every component instance in the frame:

```
batch_get(nodeIds: ["인스턴스1", "인스턴스2", ...])
```

→ Finalize each instance's props (text, icon, color, etc.).

### Step 4-C: Write the screen View

Convert the frame's layout structure into a SwiftUI View:

```swift
struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSpacing.lg) {
                // 컴포넌트 인스턴스 배치 — override 값 전달
                CardItem(
                    title: "알림",
                    icon: "bell.fill",
                    style: .accent
                )
                CardItem(
                    title: "개인정보",
                    icon: "lock.fill",
                    style: .default
                )
            }
            .padding(EdgeInsets(
                top: DesignSpacing.md,
                leading: DesignSpacing.lg,
                bottom: DesignSpacing.xl,
                trailing: DesignSpacing.lg
            ))
        }
        .background(Color.designBackground)
    }
}
```

**Screen container mapping:**

| Design pattern | SwiftUI container |
|------------|----------------|
| Scrollable list | ScrollView + LazyVStack |
| Tab-based navigation | TabView |
| Navigation stack | NavigationStack |
| Modal/sheet | .sheet / .fullScreenCover |
| Grid layout | LazyVGrid |

### Step 4-D: Verify instance completeness

> Pencil core principle: "Count component instances in design vs implementation."

Compare the number of instances in the design with the usage count in the code:

| Component | Design instances | Code usage | Match |
|----------|-------------|---------|------|
| CardItem | 3 | 3 | ✅ |
| ActionButton | 2 | 2 | ✅ |

## Phase 5: Final verification

### Step 5-A: Full screenshot comparison

Design:
```
get_screenshot(nodeId: "프레임ID")
```

Implementation: simulator screenshot via baepsae or Xcode MCP.

### Step 5-B: Checklist verification

| Item | Check |
|------|------|
| All component instances exist in the code | |
| All override values accurately reflected | |
| Colors match the design tokens | |
| Typography (font, size, weight) matches | |
| Spacing (padding, gap, margin) matches | |
| Layout direction/alignment matches | |
| Corner radius matches | |
| Scroll/overflow behavior works correctly | |
| fill_container elements expand correctly | |
| No hardcoded values (all reference tokens) | |

### Step 5-C: Fix mismatches

If there are mismatched items, return to Step 3 of the relevant component and fix them.
Report completion once the final pass succeeds.

## Completion report

```markdown
## pen-craft 완료

| 항목 | 값 |
|------|-----|
| .pen 파일 | <파일명> |
| 대상 프레임 | <프레임명> |
| 컴포넌트 수 | N개 |
| 생성 파일 | DesignTokens.swift, View 파일 N개 |
| 시각 검증 | PASS / 수동 확인 필요 |

### 생성된 파일 목록
- `DesignTokens.swift` — 디자인 토큰 (색상, 폰트, 간격, 반경)
- `IconBadge.swift` — 아이콘 뱃지 컴포넌트
- `CardItem.swift` — 카드 아이템 컴포넌트
- `SettingsView.swift` — 설정 화면 조립
```

## Rules

1. **Follow Pencil guidelines**: call `get_guidelines(category: "code")` in Phase 0 to check the latest recommendations, since they change over time
2. **Component-by-component processing**: one at a time. Do not move to the next component until the current one is verified
3. **Tokens only**: every color/font/spacing/radius value uses only the tokens in DesignTokens.swift; do not hardcode, so the design remains the single source of truth
4. **Visual verification**: on each component completion, compare against the design with get_screenshot
5. **Node tree = View hierarchy**: the Pencil node structure and the SwiftUI View hierarchy must correspond 1:1
6. **Respect existing code**: if the project already has a design system/components, reuse them instead of duplicating
7. **Agent delegation available**: in full mode, when there are many complex screens, delegate to the `design-coder` agent

## Agent delegation

When handling multiple screens in full mode, you can delegate per-screen implementation to the `design-coder` agent:

```
Agent 도구 호출:
  description: "design-coder: {화면명} SwiftUI 구현"
  subagent_type: "apple-craft:design-coder"
  prompt: |
    .pen 파일: {경로}
    대상 프레임: {프레임 ID}
    토큰 파일: {DesignTokens.swift 경로}
    프레임워크: SwiftUI (또는 UIKit)
    출력 디렉토리: {경로}
    Pencil 가이드라인을 준수하여 컴포넌트 분석 → 순차 구현 → 시각 검증을 진행하세요.
```
