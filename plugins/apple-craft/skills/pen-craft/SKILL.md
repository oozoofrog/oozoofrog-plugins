---
name: pen-craft
description: Pencil .pen 디자인을 SwiftUI/UIKit 뷰 코드로 단계별 구현 — 컴포넌트 분석, 토큰 매핑, 순차 구현, 시각 검증. "디자인 구현", "pen to code", "pen-craft", "디자인에서 코드", "뷰 구현", "디자인 코드", "pen 파일", "pen to swiftui", "design implementation", "디자인 변환", "pen 구현", "pencil 구현", "Pencil에서 SwiftUI", "디자인 코드로", "pen에서 코드", "디자인 to 코드", "코드로 변환" 요청 시 활성화
argument-hint: "[.pen 파일 경로 또는 프레임 이름]"
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

Pencil MCP의 권장 단계적 절차를 따라 `.pen` 디자인을 SwiftUI/UIKit 뷰 코드로 구현합니다.
단순 변환이 아닌, **컴포넌트 분석 → 토큰 추출 → 순차 구현 → 시각 검증**의 전체 파이프라인을 수행합니다.

> Pencil MCP 연결 필수. 미연결 시 연결 안내 후 종료합니다.

## 실행 모드

pen-craft는 대상 범위에 따라 자동으로 모드를 결정합니다:

| 모드 | 대상 | 절차 |
|------|------|------|
| **component** | 특정 컴포넌트 1개 | Phase 1 → 3 (해당 컴포넌트만) |
| **screen** | 화면 프레임 1개 | Phase 1 → 2 → 3 → 4 → 5 |
| **full** | .pen 파일 전체 | Phase 0 → 1 → 2 → 3 → 4 → 5 (모든 화면) |

## Phase 0: 환경 탐지 & 디자인 읽기

### Step 0-1: Pencil MCP 연결 확인

```
get_editor_state()
```

- 성공 → 활성 .pen 파일 정보 확인, Step 0-2로 진행
- 실패 → "Pencil MCP가 연결되지 않았습니다. Pencil 앱을 실행하고 MCP를 활성화해주세요." 안내 후 종료

### Step 0-2: 대상 .pen 파일 식별

사용자가 경로를 지정한 경우:
```
open_document(filePathOrNew: "경로.pen")
```

미지정 시:
1. `get_editor_state()`의 활성 문서 사용
2. 활성 문서 없으면 `Glob: **/*.pen`으로 프로젝트 내 .pen 파일 탐색
3. 여러 파일이면 사용자에게 선택 요청

### Step 0-3: 전체 구조 파악

```
batch_get(patterns: [{type: "frame", readDepth: 2}])
```

→ 최상위 프레임 목록 (화면 단위) 확인. 사용자가 특정 프레임을 지정하지 않았으면 목록을 보여주고 선택 요청.

### Step 0-4: Pencil 가이드라인 로드

```
get_guidelines(category: "code")
```

→ Pencil의 최신 코드 생성 가이드라인을 확인하여 Phase 3에서 준수.

## Phase 1: 컴포넌트 분석 & 추출

> Pencil 핵심 원칙: "Only process components that appear in the current frame."

### Step 1-1: 대상 프레임 전체 트리 읽기

```
batch_get(nodeIds: ["프레임ID"], readDepth: 10)
```

→ 완전한 노드 트리. 각 노드의 type, name, properties, children 파악.

### Step 1-2: 재사용 컴포넌트(ref) 식별

노드 트리에서 `componentId`가 있는 노드를 찾아 컴포넌트 목록을 작성합니다:

| 컴포넌트 | 인스턴스 수 | override 유형 |
|----------|-----------|-------------|
| CardItem | 3 | text, icon, color |
| ActionButton | 2 | label, style |

### Step 1-3: 컴포넌트별 스크린샷 참조

각 컴포넌트의 대표 인스턴스에 대해:
```
get_screenshot(nodeId: "인스턴스ID")
```

→ 시각적 참조 이미지 확보. Phase 3에서 구현 결과와 비교.

### Step 1-4: 의존성 순서 결정

컴포넌트 간 중첩 관계를 분석하여 **leaf → parent** 순서를 결정:
```
1. IconBadge (leaf — 다른 컴포넌트에 의존 없음)
2. CardItem (IconBadge를 포함)
3. CardSection (CardItem을 포함)
```

→ 이 순서가 Phase 3의 구현 순서.

## Phase 2: 디자인 토큰 추출 & SwiftUI/UIKit 매핑

### Step 2-1: 디자인 변수 추출

```
get_variables()
```

→ .pen 파일에 정의된 모든 디자인 토큰 (색상, 폰트, 간격, 반경 등).

### Step 2-2: 고유 속성 수집

```
search_all_unique_properties(patterns: [{type: "frame"}, {type: "text"}])
```

→ 프레임 전체에서 사용된 모든 고유 속성값 수집. 토큰으로 매핑되지 않은 하드코딩 값 탐지.

### Step 2-3: SwiftUI 토큰 파일 생성

추출된 토큰을 Swift 코드로 변환합니다.

**SwiftUI 타겟:**

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

**UIKit 타겟:** `UIColor`/`UIFont` extension으로 동일 패턴 생성.

**토큰 매핑 테이블 (내부 기록용):**

| Pencil 토큰 | SwiftUI | UIKit |
|-------------|---------|-------|
| $bg | Color.designBackground | UIColor.designBackground |
| $accent | Color.designAccent | UIColor.designAccent |
| $font-body | Font.designBody | UIFont.designBody |
| $spacing-lg | DesignSpacing.lg | DesignSpacing.lg |
| $radius-card | DesignRadius.card | DesignRadius.card |

> 모든 값은 토큰에서만 참조. 하드코딩 금지.

**UIKit 타겟 시 추가:**
```swift
extension UIColor {
    static let designBackground = UIColor(named: "bg")!
    // ...
}
```

**Asset Catalog 연동:**
프로젝트에 `.xcassets`가 있으면 Color Set도 함께 생성합니다.

## Phase 3: 컴포넌트별 순차 구현

> Pencil 핵심 원칙: "Process components ONE AT A TIME (extract → recreate → validate → next)."

Phase 1-4에서 결정한 의존성 순서대로, **한 번에 하나의 컴포넌트만** 처리합니다.

### 각 컴포넌트에 대해:

#### Step 3-A: 컴포넌트 구조 추출

```
batch_get(nodeIds: ["컴포넌트ID"], readDepth: 10)
```

→ 해당 컴포넌트의 완전한 노드 트리. 자식 노드, 레이아웃, 속성 모두 포함.

#### Step 3-B: 인스턴스 override 분석

해당 컴포넌트의 모든 인스턴스를 읽어 override 패턴을 파악:

```
batch_get(nodeIds: ["인스턴스1", "인스턴스2", "인스턴스3"])
```

→ 어떤 속성이 인스턴스마다 다른지 → Swift 프로퍼티로 노출할 필드 결정.

**매핑 규칙:**
- 모든 인스턴스에서 동일한 값 → 상수 (View 내부에 고정)
- 인스턴스마다 다른 값 → 프로퍼티 (init 파라미터)
- 일부만 다른 값 → 옵셔널 프로퍼티 (기본값 있음)

#### Step 3-C: SwiftUI View 작성

**SwiftUI 변환 규칙:**

| Pencil 속성 | SwiftUI |
|------------|---------|
| layout: "vertical" | VStack(spacing:) |
| layout: "horizontal" | HStack(spacing:) |
| layout: "grid" | LazyVGrid / LazyHGrid |
| width: "fill_container" | .frame(maxWidth: .infinity) |
| height: "fill_container" | .frame(maxHeight: .infinity) |
| width: "fit_content" | 기본값 (SwiftUI 자동 사이징) |
| padding: [top, right, bottom, left] | .padding(EdgeInsets(...)) |
| gap: N | VStack/HStack spacing 파라미터 |
| fill: "$token" | .background(Color.designXxx) |
| cornerRadius: N | .clipShape(RoundedRectangle(cornerRadius:)) |
| stroke / border | .overlay(RoundedRectangle(...).stroke(...)) |
| opacity: N | .opacity(N) |
| shadow | .shadow(color:radius:x:y:) |
| type: "text" | Text("...").font(.designXxx) |
| type: "image" | Image(systemName:) 또는 Image("asset") |
| overflow: "scroll" | ScrollView { ... } |

**UIKit 변환 규칙:**

| Pencil 속성 | UIKit |
|------------|-------|
| layout: "vertical" | UIStackView(axis: .vertical) |
| layout: "horizontal" | UIStackView(axis: .horizontal) |
| width: "fill_container" | constraint: widthAnchor == superview |
| padding | layoutMargins / directionalLayoutMargins |
| gap | UIStackView.spacing |
| fill: "$token" | backgroundColor = .designXxx |
| cornerRadius | layer.cornerRadius |

**코드 작성 원칙:**
1. 토큰 파일의 값만 사용 (Phase 2에서 생성한 DesignTokens.swift)
2. 인스턴스 override → Swift 프로퍼티로 노출
3. 컴포넌트 노드 트리 ↔ View 계층 1:1 대응 유지
4. SVG/벡터 → SF Symbols 우선, 없으면 `batch_get(includePathGeometry: true)`로 추출

#### Step 3-D: 빌드 검증

빌드 도구 폴백 체인:
1. Xcode MCP (`BuildProject`) — 최우선
2. `xcodebuild` + `xcsift -E` — CLI 폴백
3. `swift build` — SPM 프로젝트
4. 구문 검증만 (빌드 도구 없음)

빌드 실패 시 에러를 읽고 수정 후 재시도 (최대 3회).

#### Step 3-E: 시각 검증

1. Pencil 디자인 스크린샷 확보 (Phase 1-3에서 이미 캡처):
   ```
   get_screenshot(nodeId: "컴포넌트ID")
   ```

2. (선택) 시뮬레이터에서 구현 결과 스크린샷:
   - baepsae MCP 사용 가능 시: `screenshot_app` 또는 `screenshot`
   - Xcode MCP 사용 가능 시: `RenderPreview`

3. 두 이미지를 비교하여 불일치 확인:
   - 레이아웃 (간격, 정렬)
   - 색상 (토큰 매핑 정확성)
   - 타이포그래피 (폰트, 크기, 굵기)
   - 아이콘/이미지 (크기, 위치)

4. 불일치 발견 시 → 코드 수정 → Step 3-D로 돌아가 재검증

#### Step 3-F: 완료 확인

> Pencil 핵심 원칙: "Only proceed to next component when current is perfect."

현재 컴포넌트가 디자인과 일치할 때만 다음 컴포넌트로 진행.
진행 상황 보고:

```
✅ IconBadge (1/3) — 완료
🔄 CardItem (2/3) — 구현 중
⬜ CardSection (3/3) — 대기
```

## Phase 4: 화면 조립

모든 컴포넌트가 구현되면 전체 화면을 조립합니다.

### Step 4-A: 프레임 재분석

```
batch_get(nodeIds: ["프레임ID"], readDepth: 10)
```

→ 최신 프레임 구조 재확인. Phase 1 이후 변경이 있을 수 있음.

### Step 4-B: 인스턴스 매핑

프레임 내 모든 컴포넌트 인스턴스의 override를 수집:

```
batch_get(nodeIds: ["인스턴스1", "인스턴스2", ...])
```

→ 각 인스턴스의 props (텍스트, 아이콘, 색상 등) 확정.

### Step 4-C: 화면 View 작성

프레임의 레이아웃 구조를 SwiftUI View로 변환:

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

**화면 컨테이너 매핑:**

| 디자인 패턴 | SwiftUI 컨테이너 |
|------------|----------------|
| 스크롤 가능한 목록 | ScrollView + LazyVStack |
| 탭 기반 네비게이션 | TabView |
| 내비게이션 스택 | NavigationStack |
| 모달/시트 | .sheet / .fullScreenCover |
| 그리드 레이아웃 | LazyVGrid |

### Step 4-D: 인스턴스 완전성 검증

> Pencil 핵심 원칙: "Count component instances in design vs implementation."

디자인 내 인스턴스 수와 코드 내 사용 횟수를 비교:

| 컴포넌트 | 디자인 인스턴스 | 코드 사용 | 일치 |
|----------|-------------|---------|------|
| CardItem | 3 | 3 | ✅ |
| ActionButton | 2 | 2 | ✅ |

## Phase 5: 최종 검증

### Step 5-A: 전체 스크린샷 비교

디자인:
```
get_screenshot(nodeId: "프레임ID")
```

구현: baepsae 또는 Xcode MCP로 시뮬레이터 스크린샷.

### Step 5-B: 체크리스트 검증

| 항목 | 확인 |
|------|------|
| 모든 컴포넌트 인스턴스가 코드에 존재 | |
| 모든 override 값이 정확히 반영 | |
| 색상이 디자인 토큰과 일치 | |
| 타이포그래피 (폰트, 크기, 굵기) 일치 | |
| 간격 (padding, gap, margin) 일치 | |
| 레이아웃 방향/정렬 일치 | |
| 코너 라디우스 일치 | |
| 스크롤/오버플로우 동작 정상 | |
| fill_container 요소가 정상 확장 | |
| 하드코딩된 값 없음 (모두 토큰 참조) | |

### Step 5-C: 불일치 수정

불일치 항목이 있으면 해당 컴포넌트의 Step 3로 돌아가 수정.
최종 통과 시 완료 보고.

## 완료 보고

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

## 규칙

1. **Pencil 가이드라인 준수**: Phase 0에서 `get_guidelines(category: "code")`를 반드시 호출하여 최신 권장사항을 확인
2. **컴포넌트 단위 처리**: 한 번에 하나씩. 현재 컴포넌트가 검증될 때까지 다음으로 진행하지 않음
3. **토큰 전용**: 모든 색상/폰트/간격/반경 값은 DesignTokens.swift의 토큰만 사용. 하드코딩 절대 금지
4. **시각 검증 필수**: 각 컴포넌트 완료 시 get_screenshot으로 디자인과 비교
5. **노드 트리 = View 계층**: Pencil 노드 구조와 SwiftUI View 계층이 1:1 대응되어야 함
6. **기존 코드 존중**: 프로젝트에 이미 있는 디자인 시스템/컴포넌트가 있으면 재사용. 중복 생성 금지
7. **에이전트 위임 가능**: full 모드에서 복잡한 화면이 많으면 `design-coder` 에이전트에 위임

## 에이전트 위임

full 모드에서 여러 화면을 처리할 때, `design-coder` 에이전트에 화면별 구현을 위임할 수 있습니다:

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
