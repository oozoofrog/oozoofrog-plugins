# Android Platform Mapping (Jetpack Compose)

Maps unified tokens to Android Compose implementation values.

## Layout & Spacing

| Unified token | Android value | Compose API | Notes |
|----------|-----------|-------------|------|
| base-unit | 4.dp | Use literal value | Material minimum unit |
| grid-base | 8.dp | `Modifier.padding(8.dp)` | M3 base spacing unit |
| spacing-scale | 4-48.dp | `Spacer(Modifier.height(N.dp))` | 4dp-step scale |
| screen-margin-compact | 16.dp | `Modifier.padding(horizontal = 16.dp)` | Mobile margin |
| screen-margin-regular | 24.dp | `Modifier.padding(horizontal = 24.dp)` | Tablet margin |
| content-width-max | 672.dp | `Modifier.widthIn(max = 672.dp)` | Optimal reading width |
| touch-target-min | 48x48.dp | `Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)` | M3 touch target (48dp) |
| golden-ratio | 1:1.618 | `BoxWithConstraints` ratio computation | Rams proportional system |
| sqrt2-ratio | 1:1.414 | `Modifier.aspectRatio(1f / 1.414f)` | A-series ratio |
| grid-columns | 12 columns | `LazyVerticalGrid(columns = GridCells.Fixed(12))` | Standard grid |
| grid-gutter | 8-16.dp | `Arrangement.spacedBy(16.dp)` | Column gap |
| hierarchy-levels | 3 levels | `Typography.titleLarge/bodyLarge/labelSmall` | M3 hierarchy |
| void-ratio | 70-90% | `Modifier.fillMaxWidth(0.3f)` | Lee Ufan minimalism |
| albers-nesting | 3-4 levels | nested `Box` / `Surface` | Container depth limit |

## Typography

| Unified token | Android value | Compose API | Notes |
|----------|-----------|-------------|------|
| font-system | Roboto / Noto Sans | `FontFamily.Default` | System default |
| body-size | 16sp | `MaterialTheme.typography.bodyLarge` | M3 body |
| headline-size | 28-32sp | `MaterialTheme.typography.headlineLarge` | M3 headline |
| caption-size | 11-12sp | `MaterialTheme.typography.labelSmall` | Secondary text |
| type-scale | M3 15 steps | `Typography(displayLarge..labelSmall)` | Material Type Scale |
| line-height-ratio | 1.25-1.5 | `lineHeight = (fontSize * 1.4).sp` | Latin line height |
| line-height-korean | 1.5-1.6 | `lineHeight = (fontSize * 1.6).sp` | Korean line-height correction |
| letter-spacing-title | -0.02em | `letterSpacing = (-0.02).em` | Large text |
| korean-tracking | -0.01em | `letterSpacing = (-0.01).em` | Korean tracking |
| font-weight-range | Thin-Black | `FontWeight.Thin` ~ `FontWeight.Black` | 9 weights |
| text-align | Start | `textAlign = TextAlign.Start` | LTR default |
| readable-line-length | ~60 chars | `Modifier.widthIn(max = 580.dp)` | Max readable width |
| contrast-ratio-text | 4.5:1 | M3 semantic colors auto-guaranteed | WCAG AA |
| korean-word-break | per word | `LineBreak.Heading` / custom | keep-all equivalent |

## Color & Surface

| Unified token | Android value | Compose API | Notes |
|----------|-----------|-------------|------|
| system-blue | #007AFF approx | `MaterialTheme.colorScheme.primary` | M3 primary |
| system-red | #FF3B30 approx | `MaterialTheme.colorScheme.error` | M3 error |
| system-green | #34C759 approx | custom `Color(0xFF34C759)` | No green in M3 |
| bg-primary | surface/background | `MaterialTheme.colorScheme.background` | Light/dark auto |
| bg-secondary | surfaceVariant | `MaterialTheme.colorScheme.surfaceVariant` | Secondary background |
| palette-3color | primary, background, onBackground | `ColorScheme(primary=, background=, ...)` | M3 minimal theme |
| accent-usage | 5-15% | `MaterialTheme.colorScheme.primary` accent only | Area limit |
| surface-flat | no texture | `Surface(color = ...)` | Solid surface |
| disabled-opacity | 0.38f | `Modifier.alpha(0.38f)` | M3 disabled baseline |
| dark-elevation | tonal elevation | `Surface(tonalElevation = 3.dp)` | M3 tonal elevation |
| rothko-dark-surface | tinted darkness | `darkColorScheme(surface = Color(0xFF1A1520))` | Tinted dark mode |
| blur-backdrop | - | `Modifier.blur(20.dp)` (API 31+) | Android 12+ |
| separator | M3 outline | `MaterialTheme.colorScheme.outlineVariant` | Divider |
| color-functional | semantic | `primary/error/tertiary` mapping | Meaning-based color |

### Accessibility notes
- `turrell-kelvin`: Offer automatic color-temperature transitions as opt-in only in immersive/wellness modes; default reading/work screens prefer a fixed tone preset. Immediate opt-out must be available in settings.
- `rothko-dark-surface`: Body text maintains at least WCAG AA 4.5:1; large text, icons, dividers, and input borders maintain at least 3:1 contrast. Keep tinted surface tiers instead of pure black, and place long-form content on a separate Surface.

## Shape & Geometry

| Unified token | Android value | Compose API | Notes |
|----------|-----------|-------------|------|
| corner-radius-small | 8.dp | `RoundedCornerShape(8.dp)` | M3 small |
| corner-radius-medium | 12.dp | `RoundedCornerShape(12.dp)` | M3 medium |
| corner-radius-large.android | 16.dp (M3 Large) | `RoundedCornerShape(16.dp)` | M3 spec takes priority. For iOS equivalence use corner-radius-xl 28.dp |
| corner-radius-xl | 28.dp | `RoundedCornerShape(28.dp)` | M3 extra-large |
| corner-radius-zero | 0.dp | `RectangleShape` | Square style |
| pill-shape | 50% | `CircleShape` or `RoundedCornerShape(50)` | Pill form |
| form-vocabulary | 3 types | `RectangleShape`, `CircleShape`, custom | Base forms |
| icon-size | 24.dp | `Icon(modifier = Modifier.size(24.dp))` | M3 default |
| depth-layers.android | 5 levels (M3 Level 0-5) | `Surface(shadowElevation = 0/1/3/6/12.dp)` | M3 tonal + shadow elevation |
| mondrian-border | 4.dp solid | `Modifier.border(4.dp, Color.Black)` | Grid line |

## Motion & Interaction

| Unified token | Android value | Compose API | Notes |
|----------|-----------|-------------|------|
| duration-fast | 150ms | `tween(durationMillis = 150)` | Hover/click |
| duration-standard | 300ms | `tween(durationMillis = 300, easing = EaseInOut)` | Standard transition |
| duration-slow | 450ms | `tween(durationMillis = 450)` | Modal/sheet |
| duration-immersive | 2-5s | `tween(durationMillis = 3000)` | Mode transition |
| spring-damping | 0.7-0.85 | `spring(dampingRatio = 0.8f, stiffness = Spring.StiffnessMedium)` | Elastic feedback |
| spring-response | 0.3-0.5s | `spring(stiffness = Spring.StiffnessLow)` | Spring response |
| easing-default | EaseInOut | `FastOutSlowInEasing` | M3 default |
| easing-minimal | EaseOut | `FastOutLinearInEasing` | Restrained motion |
| reduce-motion | alternative | check `LocalReduceMotion.current` | Accessibility handling |
| haptic-feedback | 3 types | `HapticFeedbackType.LongPress/TextHandleMove` | Haptic feedback |
| gesture-velocity | 500.dp/s | `detectDragGestures` velocity threshold | Swipe detection |
| scroll-overscroll | glow/stretch | `Modifier.verticalScroll()` built-in | M3 overscroll |
| frame-rate | 60/90/120fps | `setFrameRate()` API | Variable refresh rate |
| animation-purpose | functional only | 0 decorative animations | Norman principle |
| loading-indicator | M3 LinearProgressIndicator | `LinearProgressIndicator()` | Progress display |
| breath-animation | brightness +-5% | `infiniteTransition.animateFloat(0.95f, 1f, ...)` | Turrell breath |
| focus-indicator | outline | `Modifier.focusable()` + `indication` | Accessibility focus |

### Accessibility notes
- `turrell-breath`: When `LocalReduceMotion` or an equivalent setting is on, replace the breath animation with a stop/crossfade. On repeat, brightness change stays within ±5% and the cycle within 4-8 seconds.


## Token-level usage envelope (round-004)

- `riley-bw`, `riley-stripe-width`: Use only on Compose layers separated from content, such as `LinearProgressIndicator`, divider, or decorative stripe surfaces. Prohibited behind `TextField`, focus indicator, or input/reading backgrounds; keep stripes at 2dp or wider. Limit pattern surfaces to 50% or less of the screen, except for transitional UI.
- `turrell-kelvin`, `turrell-breath`: Activate only on ambient surface/immersive routes when `LocalReduceMotion` is off. Automatic color-temperature changes must have both opt-in and opt-out, the applied surface must be at least 30% of the viewport, transitions stay at 2 seconds or longer, and breath stays within ±5% / 4-8 seconds.
- `rothko-dark-surface`: Extend only as tone-based `Surface` tiers; pure black replacement and texture overlay are prohibited. Body must maintain 4.5:1, large text and outline/icon/border must maintain 3:1, and place long-form content on a separate `Surface`/`surfaceVariant`.
