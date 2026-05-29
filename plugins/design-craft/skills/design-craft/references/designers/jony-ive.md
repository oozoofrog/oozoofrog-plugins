# Jony Ive -- Design Token Dictionary

## Profile
- **Active period**: 1992-2019 (Apple), peak 1996-2019 (served as CDO)
- **Primary affiliation**: Apple Inc. — Industrial Design Group lead → CDO
- **Key contributions**: iMac G3(1998), iPod(2001), iPhone(2007), iPad(2010), MacBook Unibody(2008), Apple Watch(2015), iOS 7 flat redesign(2013)
- **Design lineage**: Officially acknowledged Dieter Rams' influence, translating Braun aesthetics into digital form

## Design Philosophy (Quantifiable Principles)

| Principle | Quantitative conversion | Notes |
|------|----------|------|
| Extreme simplification | UI elements ≤ 5 per screen (iOS 7 basis) | 60% layer reduction after removing skeuomorphism |
| Honesty of materials | 0 surface textures (iOS 7+), 1 real material per product | Aluminum, glass, ceramic |
| Continuity of curvature | G2 continuous (squircle) curves, non-circular rounding | iOS 7 app icon superellipse |
| Whitespace as function | Whitespace ratio relative to content 40-60% | HIG margin basis |
| Precise grid | 4pt/8pt-based spacing system | Common to iOS/macOS |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| base-unit | 4pt | Apple HIG (2013-2019) | S |
| spacing-scale | 4, 8, 12, 16, 20, 24, 32, 40, 48pt | Apple HIG spacing system | S |
| screen-margin-compact | 16pt (left/right) | HIG Layout Margins | S |
| screen-margin-regular | 20pt (left/right) | HIG Layout Margins | S |
| content-width-max | 672pt (readable content) | HIG Readable Width | S |
| nav-bar-height | 44pt (compact) / 96pt (large title) | UIKit default | A |
| tab-bar-height | 49pt (compact) / 83pt (including home indicator) | UIKit default | A |
| status-bar-height | 20pt (pre-X) / 44pt (notch) / 54pt (dynamic island) | iOS measured | B |
| grid-column-gutter | 8pt | HIG grid guide | S |
| whitespace-ratio | 40-60% (relative to screen) | iOS default apps measured | B |

### Typography

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| font-family-system | San Francisco (SF Pro/SF Compact) | Apple official typeface (2015-) | S |
| font-family-pre-2015 | Helvetica Neue | iOS 7-8 system typeface | S |
| type-scale | 11, 12, 13, 15, 17, 20, 22, 28, 34pt | HIG Dynamic Type | S |
| body-size | 17pt | HIG default body | S |
| headline-size | 28-34pt | HIG Large Title | S |
| caption-size | 11-12pt | HIG Caption | S |
| line-height-ratio | 1.2-1.4x (relative to font-size) | SF Pro metrics measured | B |
| font-weight-range | Ultralight(100)-Black(900), 9 steps | SF Pro variable axis | S |
| letter-spacing-body | 0pt (tracking) | SF Pro default | A |
| letter-spacing-title | -0.4 ~ -1.6pt (negative tracking) | HIG large text recommendation | A |

### Color & Surface

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| system-blue | #007AFF (light) / #0A84FF (dark) | HIG System Colors | S |
| system-red | #FF3B30 (light) / #FF453A (dark) | HIG System Colors | S |
| system-green | #34C759 (light) / #30D158 (dark) | HIG System Colors | S |
| background-primary | #FFFFFF (light) / #000000 (dark, OLED) | HIG Backgrounds | S |
| background-secondary | #F2F2F7 (light) / #1C1C1E (dark) | HIG Grouped Background | S |
| background-tertiary | #FFFFFF (light) / #2C2C2E (dark) | HIG Elevated Surface | S |
| separator-color | rgba(60,60,67,0.29) light | HIG Separator | S |
| blur-material | UIBlurEffect.Style — thin/regular/thick | UIKit Vibrancy | A |
| blur-radius | 20-40pt (frosted glass effect) | iOS measured | B |
| surface-material | Aluminum 7000 series, glass (Ceramic Shield) | Apple product spec | S |
| palette-saturation | Saturation 70-90% (system colors), low saturation 10-20% (backgrounds) | HIG color measured | B |

### Form & Curvature

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| corner-radius-small | 6-8pt (buttons, text fields) | HIG components measured | B |
| corner-radius-medium | 10-13pt (cards, modals) | HIG measured | B |
| corner-radius-large | 16-20pt (sheets, widgets) | HIG measured | B |
| corner-radius-app-icon | Continuous curvature (squircle), iOS icon mask | Apple icon grid spec | S |
| corner-style | .continuous (SwiftUI) — G2 continuous curve | RoundedRectangle docs | S |
| device-edge-radius | 39pt (iPhone 14 Pro), 55pt (iPad Pro) | Device spec measured | B |
| icon-grid | 60x60pt @2x (app icon base) | HIG App Icon Spec | S |
| icon-optical-weight | Line weight 1.5-2pt @1x | SF Symbols guide | S |
| aspect-ratio-device | 19.5:9 (iPhone), 4:3 (iPad), 16:10 (Mac) | Device spec | S |
| bezel-to-screen | ≥ 90% screen ratio (2017+) | Apple spec | S |

### Interaction & Motion

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| animation-duration-fast | 0.15-0.2s | UIKit default animation | A |
| animation-duration-standard | 0.25-0.35s | UIKit/SwiftUI transition | A |
| animation-duration-slow | 0.4-0.5s (modal enter/exit) | iOS measured | B |
| spring-damping | 0.7-0.85 (slight bounce) | UIView.animate default | A |
| spring-response | 0.3-0.5s | SwiftUI .spring() | A |
| easing-default | ease-in-out (cubic-bezier(0.42, 0, 0.58, 1)) | Core Animation | A |
| gesture-velocity-threshold | 500pt/s (swipe recognition) | UIKit gesture default | A |
| haptic-feedback | light/medium/heavy (UIImpactFeedbackGenerator) | HIG Haptics | S |
| parallax-depth | 10-20pt parallax (home screen wallpaper) | iOS measured | B |
| touch-target-min | 44x44pt | HIG touch target | S |

### Accessibility & Adaptive

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| dynamic-type-range | xSmall(14pt) ~ AX5(60pt), 12 steps | HIG Dynamic Type | S |
| bold-text-weight | .regular → .semibold automatic conversion | iOS accessibility setting | A |
| reduce-motion | Replaced with crossfade 0.3s (spring animation disabled) | iOS Reduce Motion | S |
| reduce-transparency | Blur removed, replaced with opaque background | iOS Reduce Transparency | S |
| increase-contrast | separator 1pt → 2pt, contrast +20% | iOS Increase Contrast | A |
| color-filter | Grayscale / red-green filter support | iOS color filters | S |
| smart-invert | Color inversion excluding images/media | iOS Smart Invert | S |
| minimum-text-size | 11pt (accessibility minimum — Caption2) | HIG minimum text | S |

### Icons & SF Symbols

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| sf-symbol-scale | small/medium/large (default medium) | SF Symbols 3.0+ | S |
| sf-symbol-weight | Auto-matches text weight | SF Symbols docs | S |
| sf-symbol-rendering | monochrome/hierarchical/palette/multicolor | SF Symbols 4.0 | S |
| sf-symbol-size | Proportional to text point size (automatic) | SF Symbols guide | S |
| app-icon-size-iphone | 60x60pt @2x/@3x (120/180px) | HIG app icon spec | S |
| app-icon-size-ipad | 76x76pt @2x (152px), 83.5x83.5pt @2x (167px) | HIG app icon spec | S |
| app-icon-padding | Icon internal safe area — 10% margin from outer edge | Apple icon grid | S |

## Changes by Era

| Era | Turning point | Key numerical changes |
|------|--------|---------------|
| 1998-2006 | Translucent plastic → aluminum | Material transmittance 70% → 0%, reduced surface reflectance |
| 2007-2012 | Skeuomorphism heyday | 3-5 texture layers per screen, shadow depth 5-15pt |
| 2013 (iOS 7) | Flat design transition | 0 textures, shadow → blur, typeface Helvetica Neue Light |
| 2014 (iPhone 6) | Screen size diversification | size class introduced, added 375pt/414pt widths |
| 2015 | SF Pro introduction + 3D Touch | Pressure 3 levels (peek/pop), variable typeface transition |
| 2017 (iPhone X) | Notch + home indicator | safe area introduced, top 44pt/bottom 34pt inset |
| 2019 | Ive departure, dark mode introduction | Dual color system (#FFFFFF/#000000 based) |

## Influence Relationships

- **Dieter Rams → Jony Ive**: Braun SK4 grid → iPod interface, ET66 calculator → iOS Calculator app (near 1:1 translation)
- **Jony Ive → Material Design**: The flat design transition triggered Google Material Design(2014)
- **Jony Ive → industry-wide**: Unibody aluminum process standardized the laptop industry
- **Reference movements**: Bauhaus (functionalism), De Stijl (geometric purity)
- **Key reference**: "Jony Ive: The Genius Behind Apple's Greatest Products" (Leander Kahney, 2013)

## Key Product Token Snapshot

| Product | Key token | Value |
|------|----------|---|
| iPod Classic | Click wheel diameter | 38mm, circular |
| iPhone (2007) | Screen corner-radius | 10pt, 3.5 inch |
| MacBook Unibody (2008) | Aluminum thickness | 0.3mm shell |
| iPad (2010) | Bezel width | 25mm left/right, 20mm top/bottom |
| Apple Watch (2015) | Digital Crown diameter | 5.3mm |
| iPhone X (2017) | Notch width | 209pt (55.7% of total 375pt) |
| AirPods Pro (2019) | 3 ear tip sizes | S/M/L |

## UI Application Mapping

| Ive principle | Modern UI token conversion rule |
|----------|----------------------|
| 4pt grid | Set all spacing as multiples of 4, minimum unit 4pt |
| Continuous curvature | Use `RoundedRectangle(cornerRadius:, style: .continuous)` instead of SwiftUI `.cornerRadius` |
| System colors | Use semantic colors (Color.primary, .secondary, .accentColor) |
| Blur surface | `.background(.ultraThinMaterial)` ~ `.background(.thickMaterial)` hierarchy |
| Large title | `.navigationBarTitleDisplayMode(.large)` — 34pt Bold |
| Touch area | Ensure `.frame(minWidth: 44, minHeight: 44)` |
| Motion | Apply `.animation(.spring(response: 0.35, dampingFraction: 0.8))` by default |
| Dark mode | Pure black (#000000) background for OLED optimization |
| Whitespace | `.padding()` default 16pt, maintain content-area whitespace ratio ≥ 40% |
| Accessibility | Dynamic Type support required, use `.font(.body)`, no fixed pt |
| SF Symbols | Auto-match same weight as text, `.symbolRenderingMode(.hierarchical)` |
| Safe Area | Use `.ignoresSafeArea()` minimally, content always inside safe area |
