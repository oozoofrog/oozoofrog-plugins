# Alan Dye -- Design Token Dictionary

## Profile
- **Active period**: 2006-present, core period 2014-present (VP of Human Interface Design)
- **Main affiliation**: Apple VP of Human Interface Design (2015-present), Apple marketing graphic design team (2006-2014)
- **Key contributions**: watchOS UI design, iOS 14+ widget system, Apple marketing visual identity, Dynamic Island (iPhone 14 Pro), visionOS spatial interface, leading the later iOS visual language
- **Design lineage**: Apple marketing design → HI design under Jony Ive → post-Ive independent vision (physical-digital integration)

## Design Philosophy (quantifiable principles)

| Principle | Quantitative conversion | UI metric |
|------|----------|----------|
| Glanceability | Core information recognition ≤ 2s | watchOS complication data points ≤ 3 |
| Physical-digital continuity | Physical input → digital response ≤ 16ms | Digital Crown rotation → UI scroll 1:1 mapping |
| Adaptive layout | Automatic reflow per device size | Supports 4 sizes: 40mm/44mm/45mm/49mm |
| Entry point simplification | Reach core function ≤ 1 tap | widget → app = 1 tap, complication → app = 1 tap |
| Depth and hierarchy | Clear z-axis layer separation | Max 3-level depth (background-content-overlay) |

## Quantitative Design Tokens

### Layout & spacing

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| watchos-screen-40mm | 162×197pt (394×484px @2x) | watchOS HIG — 40mm screen spec | S |
| watchos-screen-44mm | 184×224pt (448×544px @2x) | watchOS HIG — 44mm screen spec | S |
| watchos-screen-45mm | 198×242pt (396×484px @2x) | watchOS HIG — 45mm screen spec | S |
| watchos-screen-49mm | 205×251pt (410×502px @2x) | watchOS HIG — 49mm Ultra screen spec | S |
| watchos-margin | 8.5pt each side (40mm), 9pt (44mm) | watchOS HIG — screen margin | S |
| widget-small | 169×169pt (@2x iPhone 15 Pro) | iOS HIG — Small widget size | S |
| widget-medium | 360×169pt (@2x iPhone 15 Pro) | iOS HIG — Medium widget size | S |
| widget-large | 360×379pt (@2x iPhone 15 Pro) | iOS HIG — Large widget size | S |
| widget-padding | 16pt (default inner margin) | iOS HIG — widget padding | S |
| widget-corner-radius | 22pt (continuous corner) | iOS HIG — widget curvature | S |
| dynamic-island-min | 126×37pt (collapsed state) | iPhone 14 Pro Dynamic Island measured | A |
| dynamic-island-max | 371×160pt (expanded state) | iPhone 14 Pro Dynamic Island measured | A |
| grid-base | 8pt (Apple standard) | Apple HIG — base grid unit | S |

### Typography

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| font-system | SF Pro (iOS/macOS), SF Compact (watchOS) | Apple system typeface system | S |
| font-rounded | SF Pro Rounded (friendly context) | Apple HIG — rounded typeface variant | S |
| watchos-title | 17pt Bold (SF Compact) | watchOS HIG — title size | S |
| watchos-body | 15pt Regular (SF Compact) | watchOS HIG — body size | S |
| watchos-caption | 12pt Regular (SF Compact) | watchOS HIG — caption size | S |
| widget-title | 16-20pt Semibold (SF Pro) | iOS HIG — widget title | A |
| widget-body | 13-15pt Regular (SF Pro) | iOS HIG — widget body | A |
| dynamic-type-range | 11pt (xSmall) ~ 53pt (AX5) | iOS HIG — full Dynamic Type range | S |
| font-weight-range | Ultralight(100) ~ Black(900), 9 weights | SF Pro weight spec | S |
| line-height | 1.2 (title), 1.35-1.4 (body) | Apple HIG typography guidelines | A |

### Color & surface

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| system-colors | 12-color semantic palette (red~brown) | Apple HIG — 12 system colors | S |
| tint-color | systemBlue #007AFF (default accent) | Apple HIG — default tint | S |
| background-primary | systemBackground (#FFF / #000) | Apple HIG — primary background | S |
| background-secondary | secondarySystemBackground (#F2F2F7 / #1C1C1E) | Apple HIG — secondary background | S |
| material-blur | 5 types (ultra-thin~ultra-thick) | Apple HIG — translucent blur material | S |
| vibrancy | 4 types (label, secondaryLabel, fill, separator) | Apple HIG — vibrancy effect | S |
| watchos-background | pure black #000000 (OLED optimized) | watchOS HIG — background = pure black | S |
| dark-mode-elevation | brightness +4-8% on z-axis raise | Apple HIG — dark mode depth expression | A |
| contrast-ratio | min 4.5:1 (body), 3:1 (large) | Apple accessibility guidelines | S |

### Form & curvature

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| corner-radius-small | 10pt (buttons, text fields) | Apple HIG — small element curvature | S |
| corner-radius-medium | 13pt (cards, cells) | Apple HIG — medium element curvature | A |
| corner-radius-large | 22pt (widgets, modals) | Apple HIG — large element curvature | S |
| continuous-corner | squircle (superellipse) curve | Apple proprietary curvature formula — not in CSS | S |
| watchos-corner | follows screen curvature (full screen) | watchOS — screen = rounded rectangle | S |
| icon-size | 29, 40, 60, 76, 83.5, 1024pt (app icon) | Apple HIG — app icon size system | S |
| icon-corner-ratio | 22.37% of icon size (iOS) | Apple app icon curvature formula | S |
| sf-symbol-weight | 9 weights × 3 scales | SF Symbols — weight·scale matrix | S |
| depth-layers | 3 levels (base, raised, overlay) | Apple HIG — depth system | S |

### Interaction & motion

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| spring-animation | mass:1, stiffness:100-300, damping:10-20 | Apple spring animation default analysis | A |
| transition-push | 0.35s (navigation push transition) | iOS UINavigationController default | S |
| transition-modal | 0.4s (modal presentation) | iOS modal transition time measured | A |
| haptic-feedback | 3 types (light, medium, heavy) + 6 notify | Apple Haptic engine feedback system | S |
| digital-crown | 1 rotation = 100% of content height scroll | watchOS Digital Crown mapping | A |
| scroll-deceleration | fast(0.99) / normal(0.998) | UIScrollView decelerationRate | S |
| long-press-duration | 0.5s (default), 0.12s (3D Touch) | iOS long-press recognition time | S |
| rubber-band | 1/3 ratio deceleration on overscroll | iOS rubber-band effect ratio | A |
| dynamic-island-morph | 0.3-0.5s shape transition animation | Dynamic Island transition time measured | A |

## Changes Over Time

| Period | Turning point | Key numeric changes |
|------|--------|---------------|
| 2006-2013 | Apple marketing design | skeuomorphism → flat transition period, leading marketing visuals |
| 2014-2016 | watchOS 1.0 + VP appointment | 38/42mm screen layout, established glance UI concept |
| 2017-2019 | watchOS maturity + iOS refinement | Series 4 rounded screen introduced, complication system expansion |
| 2020-2022 | widget system + Dynamic Island | iOS 14 widget grid, iPhone 14 Pro Dynamic Island |
| 2023-present | visionOS + Vision Pro | spatial UI 3D depth system, gaze-tracking-based interaction |

## Influence Relationships

- **Jony Ive → Dye**: applied Ive's flat design / materiality principles to HI design
- **Swiss typography → Dye**: SF Pro's grid-based typeface system
- **Dye → watchOS ecosystem**: established the ultra-small-screen UI paradigm
- **Dye → widget economy**: iOS widgets influenced Android·web widget design
- **Dye → spatial computing**: visionOS as the new standard for XR UI design
- **Key references**: Apple HIG (developer.apple.com/design), WWDC design sessions

## UI Application Mapping

| Dye principle | Modern UI token conversion rule |
|---------|----------------------|
| Glanceability | widget/complication = data points ≤ 3, text ≤ 2 lines |
| Continuous curvature | SwiftUI `.clipShape(.rect(cornerRadius:, style: .continuous))` |
| Semantic color | `.foregroundStyle(.primary)`, `.tint(.accentColor)` — no hardcoding |
| Translucent material | `.background(.ultraThinMaterial)` — expresses depth and context simultaneously |
| Spring motion | `.animation(.spring(response: 0.35, dampingFraction: 0.7))` |
| Adaptive layout | `@Environment(\.horizontalSizeClass)` + ViewThatFits |
| Haptic feedback | `UIImpactFeedbackGenerator(style: .medium)` — 1:1 with physical input |
| Dynamic Type | `.font(.body)` + `.dynamicTypeSize(...)` full range support |
| 3-level depth | `base` → `raised`(+shadow) → `overlay`(+blur) |
| OLED optimization | pure black (#000) background in watchOS/dark mode, power saving |
