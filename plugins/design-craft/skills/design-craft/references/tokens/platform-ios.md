# iOS Platform Mapping (SwiftUI / UIKit)

Translate unified tokens into iOS implementation values.

## Layout & Spacing

| Unified token | iOS value | SwiftUI API | Notes |
|----------|--------|-------------|------|
| base-unit | 4pt | use raw value | HIG minimum unit |
| grid-base | 8pt | `.padding(8)` | all spacing a multiple of 8 |
| spacing-scale | 4-48pt | `.padding()`, `Spacer(minLength:)` | 4pt-unit scale |
| screen-margin-compact | 16pt | `.padding(.horizontal, 16)` | size class compact |
| screen-margin-regular | 20pt | `.padding(.horizontal, 20)` | size class regular |
| content-width-max | 672pt | `.frame(maxWidth: 672)` | readableContentGuide |
| touch-target-min | 44x44pt | `.frame(minWidth: 44, minHeight: 44)` | HIG required |
| nav-bar-height | 44/96pt | `.navigationBarTitleDisplayMode(.large)` | managed automatically by UIKit |
| tab-bar-height | 49/83pt | `TabView` | includes home indicator |
| golden-ratio | 1:1.618 | ratio computed via `GeometryReader` | Rams proportion system |
| hierarchy-levels | 3 levels | `.font(.title)/.body/.caption` | limit visual hierarchy |
| void-ratio | 70-90% | place multiple `Spacer()` | Lee Ufan minimalism |
| albers-nesting | 3-4 levels | nested `ZStack` / `overlay` | limit container depth |

## Typography

| Unified token | iOS value | SwiftUI API | Notes |
|----------|--------|-------------|------|
| font-system | SF Pro / SF Compact | `.font(.system(size:weight:))` | system default |
| body-size | 17pt | `.font(.body)` | Dynamic Type default |
| headline-size | 28-34pt | `.font(.largeTitle)` / `.title` | Large Title |
| caption-size | 11-12pt | `.font(.caption)` / `.caption2` | minimum legible size |
| type-scale | 11-34pt, 8 steps | `.font(.caption2)` ~ `.font(.largeTitle)` | Dynamic Type |
| dynamic-type-range | 14-60pt | `.dynamicTypeSize(...)` | full accessibility range |
| line-height-ratio | 1.2-1.4x | `.lineSpacing()` | SF Pro default metrics |
| line-height-korean | 1.4-1.6x | `.lineSpacing(font * 0.5)` | Korean line-height correction |
| letter-spacing-title | -0.4~-1.6pt | `.tracking(-0.4)` | large-text tightening |
| korean-tracking | -0.01em | `.tracking(-0.2)` (at 17pt) | Korean letter-spacing correction |
| font-weight-range | 100-900 | `.fontWeight(.ultraLight)` ~ `.black` | 9 steps |
| text-align | left-aligned | `.multilineTextAlignment(.leading)` | default |
| readable-line-length | 65ch | `.frame(maxWidth: .readableContentWidth)` | max width for readability |

## Color & Surface

| Unified token | iOS value | SwiftUI API | Notes |
|----------|--------|-------------|------|
| system-blue | #007AFF/#0A84FF | `Color.blue` / `.tint(.blue)` | semantic color |
| system-red | #FF3B30/#FF453A | `Color.red` | semantic color |
| system-green | #34C759/#30D158 | `Color.green` | semantic color |
| bg-primary | #FFF/#000 | `Color(.systemBackground)` | light/dark automatic |
| bg-secondary | #F2F2F7/#1C1C1E | `Color(.secondarySystemBackground)` | grouped background |
| blur-material | 5 kinds | `.background(.ultraThinMaterial)` ~ `.thick` | translucent blur |
| separator-color | rgba(60,60,67,0.29) | `Color(.separator)` | system separator |
| disabled-opacity | 0.38 | `.opacity(0.38)` + `.disabled(true)` | disabled state |
| dark-elevation | +4-8% brightness | `Color(.tertiarySystemBackground)` | brightness per depth |
| accent-usage | 5-15% | `.tint(.accentColor)` | limit accent color |
| rothko-surface-dark | #1A1520~#4D3B52 | `Color(red:0.1, green:0.08, blue:0.12)` | tonal dark surface |

### Accessibility notes
- `turrell-kelvin`: offer automatic color-temperature shifting as opt-in only on immersive/wellness screens; keep a fixed color-temperature preset as the default for reading/work screens. Opt-out must be available at any time in settings.
- `rothko-surface-dark`: body text maintains at least WCAG AA 4.5:1, and large text, icons, separators, and input borders maintain at least 3:1 contrast. Place long text on a translucent panel or a separated secondary surface, and do not substitute pure black.

## Shape & Geometry

| Unified token | iOS value | SwiftUI API | Notes |
|----------|--------|-------------|------|
| corner-radius-small | 8pt | `.clipShape(.rect(cornerRadius: 8, style: .continuous))` | buttons/fields |
| corner-radius-medium | 13pt | `.clipShape(.rect(cornerRadius: 13, style: .continuous))` | cards/cells |
| corner-radius-large.ios | 22pt | `.clipShape(.rect(cornerRadius: 22, style: .continuous))` | widgets/modals |
| corner-style | squircle (G2) | `RoundedRectangle(cornerRadius:, style: .continuous)` | Apple proprietary curve |
| pill-shape | height/2 | `Capsule()` | pill-shaped button |
| depth-layers.ios | 3 levels | `.shadow(radius:)` per level | base/raised/overlay |
| sf-symbol | 9 weight x 3 scale | `Image(systemName:).symbolRenderingMode(.hierarchical)` | automatic matching |
| icon-stroke | 1.5-2pt | SF Symbols default | tied to text weight |

## Motion & Interaction

| Unified token | iOS value | SwiftUI API | Notes |
|----------|--------|-------------|------|
| duration-fast | 0.15-0.2s | `.animation(.easeOut(duration: 0.2))` | micro feedback |
| duration-standard | 0.25-0.35s | `.animation(.spring(response: 0.35, dampingFraction: 0.8))` | standard transition |
| duration-slow | 0.4-0.5s | `.animation(.spring(response: 0.5, dampingFraction: 0.7))` | modal entrance |
| spring-damping | 0.7-0.85 | `dampingFraction: 0.8` | slight bounce |
| spring-response | 0.3-0.5s | `response: 0.35` | spring response |
| easing-default | ease-in-out | `.easeInOut` | Core Animation |
| haptic-feedback | 3 kinds + 6 kinds | `UIImpactFeedbackGenerator(style: .medium)` | haptic feedback |
| reduce-motion | crossfade 0.3s | `.animation(reduceMotion ? .easeOut(0.3) : .spring())` | accessibility handling |
| gesture-velocity | 500pt/s | `DragGesture.Value.velocity` | swipe threshold |
| rubber-band | 1/3 deceleration | built into `ScrollView` | overscroll |
| frame-rate | 60fps | `CADisplayLink` / Metal | minimum performance bar |

### Accessibility notes
- `turrell-breath`: when `UIAccessibility.isReduceMotionEnabled` or an equivalent setting is on, stop the breathing animation or replace it with a crossfade. On repeat, brightness change must not exceed ±5% and the period must stay within the 4-8 second range.


## Token-level usage envelope (round-004)

- `riley-bw`, `riley-stripe-width`: use only on `Canvas`/decorative panels/loading surfaces, and forbid as a background behind `Text`, `TextField`, or focusable controls. Keep stripes at 2pt or wider, and limit patterned surfaces to 50% or less of the screen except on transitional UI.
- `turrell-kelvin`, `turrell-breath`: activate in an ambient layer only when `UIAccessibility.isReduceMotionEnabled == false`, and restrict to immersive/wellness screens occupying 30% or more of the viewport. Automatic color-temperature change must have both opt-in and opt-out; transitions stay at 2 seconds or longer and breathing within the ±5%/4-8 second range.
- `rothko-surface-dark`: use only as a tonal dark background of `surface-0`~`surface-3` character, and place long-form text on `secondarySystemBackground` or a glass/overlay panel. Body text must meet 4.5:1, and large text plus separator/icon/border must meet 3:1; texture/pattern/pure-black substitution is forbidden.
