# Web Platform Mapping (CSS)

Convert unified tokens into Web CSS implementation values.

## Layout & Spacing

| Unified token | Web value | CSS Property | Notes |
|----------|--------|-------------|------|
| base-unit | 4px | `--space-1: 4px` | CSS variable base unit |
| grid-base | 8px | `--space-2: 8px` | All spacing in 8px multiples |
| spacing-scale | 4-48px | `--space-{1..12}: calc(var(--base) * N)` | 4px-unit scale |
| screen-margin-compact | 16px | `padding-inline: 16px` | Mobile margin |
| screen-margin-regular | 20px | `padding-inline: clamp(16px, 4vw, 40px)` | Desktop fluid margin |
| content-width-max | 672px | `max-width: 672px; margin-inline: auto` | Optimal reading width |
| touch-target-min | 44px | `min-height: 44px; min-width: 44px` | Mobile touch area |
| golden-ratio | 1:1.618 | `grid-template-columns: 1fr 1.618fr` | Or 38.2%/61.8% |
| sqrt2-ratio | 1:1.414 | `aspect-ratio: 1 / 1.414` | A-series ratio |
| grid-columns | 12 columns | `grid-template-columns: repeat(12, 1fr)` | Standard grid |
| grid-gutter | 8-16px | `gap: 16px` | Column spacing |
| alignment-axes | 3 or fewer | `align-items`, `justify-content` | Limit alignment axes |
| hierarchy-levels | 3 levels | `<h1>/<h2>/<p>` | Visual hierarchy |
| void-ratio | 70-90% | `max-width: 30%` (content) | Lee Ufan minimalism |
| mondrian-grid | uneven split | `grid-template-columns: 1fr 2.5fr 0.8fr` | Unequal fr units |
| tschichold-margin | 2:3:4:6 ratio | `padding: 3vw 4vw 6vw 2vw` | Proportional margins |

## Typography

| Unified token | Web value | CSS Property | Notes |
|----------|--------|-------------|------|
| font-system | system-ui | `font-family: system-ui, -apple-system, sans-serif` | System typeface |
| font-classic-sans | Helvetica | `font-family: 'Helvetica Neue', Arial, sans-serif` | Classic alternative |
| font-classic-serif | Georgia | `font-family: Georgia, 'Times New Roman', serif` | Serif alternative |
| body-size | 16px | `font-size: 1rem` (16px base) | WCAG recommended minimum |
| headline-size | 28-34px | `font-size: clamp(1.75rem, 3vw, 2.125rem)` | Responsive heading |
| caption-size | 11-12px | `font-size: 0.75rem` | Secondary text |
| type-scale | 1.2-1.5 ratio | `--step-N: calc(1rem * pow(1.25, N))` | Modular scale |
| line-height-ratio | 1.4-1.5 | `line-height: 1.5` | WCAG 1.4.12 baseline (1.5 or more recommended) |
| line-height-korean | 1.5-1.6 | `line-height: 1.6` (`:lang(ko)`) | Korean leading adjustment |
| letter-spacing-title | -0.02em | `letter-spacing: -0.02em` | Large text |
| letter-spacing-caps | +0.05em | `letter-spacing: 0.05em; text-transform: uppercase` | Uppercase tracking |
| korean-tracking | -0.01em | `letter-spacing: -0.01em` (`:lang(ko)`) | Korean tracking |
| font-weight-range | 100-900 | `font-weight: 100` ~ `900` | Variable font |
| text-align | left | `text-align: left` | LTR default |
| readable-line-length | 65ch | `max-width: 65ch` | Readable line length |
| contrast-ratio-text | 4.5:1 (AA) | `color: #1a1a1a; background: #fff` | WCAG compliant |
| orphan-widow | 2 lines minimum | `orphans: 2; widows: 2` | Orphan prevention |
| korean-word-break | by word | `word-break: keep-all` | Korean line breaking |

## Color & Surface

| Unified token | Web value | CSS Property | Notes |
|----------|--------|-------------|------|
| system-blue | #007AFF | `--color-primary: #007AFF` | Default accent |
| system-red | #FF3B30 | `--color-destructive: #FF3B30` | Warning/delete |
| system-green | #34C759 | `--color-success: #34C759` | Success state |
| bg-primary-light | #FFFFFF | `--bg-primary: #FFFFFF` | Light background |
| bg-primary-dark | #000000 | `--bg-primary: #000000` | Dark background (OLED) |
| bg-secondary | #F2F2F7 / #1C1C1E | `--bg-secondary: #F2F2F7` | Grouped background |
| palette-3color | black-white-accent | `--text, --bg, --accent` 3 variables | Minimal theme |
| accent-usage | 5-15% area | restrict accent color usage | Area guideline |
| blur-backdrop | 20-40px | `backdrop-filter: blur(20px)` | Translucent blur |
| separator | rgba(60,60,67,0.29) | `border-bottom: 1px solid rgba(60,60,67,0.29)` | Separator |
| surface-flat | no texture | `background-image: none` | Solid surface |
| disabled-opacity | 0.38 | `opacity: 0.38` | Disabled state |
| dark-elevation | +4-8% brightness | `--surface-1: hsl(0,0%,11%)` ~ `--surface-3` | Brightness by depth |
| rothko-dark-surface | tinted darkness | `--surface-0: #1A1520` ~ `--surface-3: #4D3B52` | Tinted dark mode |
| gradient-vertical | vertical gradient | `background: linear-gradient(180deg, ...)` | Rothko background |
| mondrian-gap-as-line | gap = line role | `gap: 4px; background: #1A1A1A` | Grid lines |
| color-functional | semantic-based | `--info, --success, --warning, --error` | Semantic variables |

### Accessibility notes
- `turrell-kelvin`: Time-of-day-based color-temperature transitions are used as opt-in only in immersive/wellness modes. On default reading screens, prefer a fixed theme preset, and always provide an opt-out for automatic changes.
- `rothko-dark-surface`: Body text maintains at least WCAG AA 4.5:1; large text, icons, separators, and input borders maintain at least 3:1 contrast. Maintain a tinted dark surface instead of pure black, and separate long-form text into a dedicated panel/overlay.

## Shape & Geometry

| Unified token | Web value | CSS Property | Notes |
|----------|--------|-------------|------|
| corner-radius-small | 8px | `border-radius: 8px` | Button/field |
| corner-radius-medium | 13px | `border-radius: 13px` | Card/cell |
| corner-radius-large.web | 22px | `border-radius: 22px` | Modal/widget |
| corner-radius-zero | 0px | `border-radius: 0` | Square style |
| pill-shape | 9999px | `border-radius: 9999px` | Pill shape |
| form-vocabulary | 3 kinds | `clip-path: circle()`, `polygon()`, rect | Basic shapes |
| icon-stroke | 1.5-2px | `stroke-width: 1.5px` (SVG) | Icon weight |
| depth-layers.web | 3 levels | `box-shadow: 0 1px 3px`, `0 4px 12px`, `0 8px 24px` | elevation |
| mondrian-border | 3-8px solid | `border: 4px solid #1A1A1A` | Grid lines |
| riley-stripe | 2-20px | `repeating-linear-gradient(...)` | Stripe pattern |

### Accessibility notes
- `riley-bw` / `riley-stripe-width`: Limit high-contrast repeating stripes to decorative/loading surfaces; forbid them as backgrounds behind text, inputs, or focus elements. Limit screen occupancy to 50% or less, and maintain at least 2px at 1x.

## Motion & Interaction

| Unified token | Web value | CSS Property | Notes |
|----------|--------|-------------|------|
| duration-fast | 150ms | `transition-duration: 150ms` | Hover/click |
| duration-standard | 300ms | `transition-duration: 300ms` | Standard transition |
| duration-slow | 450ms | `transition-duration: 450ms` | Modal appearance |
| duration-immersive | 2-5s | `transition-duration: 3s` | Mode transition |
| easing-default | ease-in-out | `transition-timing-function: ease-in-out` | Default |
| easing-minimal | ease-out | `transition-timing-function: ease-out` | Restrained motion |
| spring-css | spring-like | `transition: 300ms cubic-bezier(0.34, 1.56, 0.64, 1)` | Spring approximation |
| reduce-motion | fallback | `@media (prefers-reduced-motion: reduce) { * { transition-duration: 0.01ms !important; } }` | Accessibility |
| hover-subtle | opacity 0.85 | `&:hover { opacity: 0.85 }` | Rams restraint |
| hover-bold | color inversion | `&:hover { filter: invert(1) }` | Rand drama |
| animation-purpose | functional only | 0 decorative animations | Norman principle |
| scroll-behavior | smooth | `scroll-behavior: smooth` | Smooth scrolling |
| loading-stripe | stripe animation | `background: repeating-linear-gradient(-45deg, ...)` | Riley pattern |
| breath-animation | brightness +-5% | `@keyframes breathe { 50% { opacity: 0.95 } }` | Turrell breathing |
| focus-visible | 2px outline | `&:focus-visible { outline: 2px solid var(--accent) }` | WCAG 2.2 |

### Accessibility notes
- `turrell-breath`: Under `@media (prefers-reduced-motion: reduce)` it must be replaced with a static state or static crossfade. Repeating animations must not exceed ±5% brightness variation and a 4-8 second cycle.
- `riley`-family animations (`loading-stripe`) must also apply the no-flash/no-flicker rule together with the content-separation principle.


## Token-level usage envelope (round-004)

- `riley-bw`, `riley-stripe-width`: Use only on pattern surfaces separated from content, such as `loading-stripe`, divider, and hero decoration. Forbid them as backgrounds behind `Text`, `input`, or `:focus-visible` targets, and turn the animation off under `prefers-reduced-motion: reduce`. Pattern surfaces are limited to 50% or less of the screen, excluding transitional UI.
- `turrell-kelvin`, `turrell-breath`: Automatic color-temperature changes are allowed only when both opt-in and opt-out exist, and apply only to surfaces occupying 30% or more of the screen, such as an ambient panel/immersive section. Transitions last 2 seconds or more, breathing must not exceed ±5%/4-8s, and dense text is separated into a dedicated overlay panel.
- `rothko-dark-surface`: Extend only through the `--surface-0`~`--surface-3` tiers; forbid `#000000` pure-black substitution or texture overlay. Body must maintain 4.5:1, and large text and separator/icon/border must maintain 3:1; place long-form content in a dedicated panel/overlay.
