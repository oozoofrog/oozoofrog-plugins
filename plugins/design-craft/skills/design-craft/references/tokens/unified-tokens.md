# Unified Design Token Dictionary

Normalized token system extracted from research on 19 designers/painters.

> `Source grade (lowest)` shows the **lowest confidence grade** among the original tokens reflected in each unified row. That is, a row mixing `S` and `F` is marked `F`; for detailed rationale, refer to the individual designer/artist source documents and `references/verification/report.md`.

## Layout & Spacing

| Token | Value | Source | Source grade (lowest) |
|--------|---|------|----------------|
| base-unit | 4pt | Ive, Tschichold, Kare | F |
| grid-base | 8pt | Ive, Rams, Vignelli, Brockmann, Dye, Matas, Won | F |
| spacing-scale | 4, 8, 12, 16, 20, 24, 32, 40, 48pt | Ive | S |
| ma-spacing | 8-16-32-64-128px (exponential increase) | Lee Ufan | C |
| screen-margin-compact | 16pt | Ive, Won | S |
| screen-margin-regular | 20pt | Ive, Won | S |
| margin-ratio | 10-20% of total area | Rams, Vignelli, Tschichold | B |
| tschichold-margin | inner:top:outer:bottom = 2:3:4:6 | Tschichold | S |
| content-width-max | 672pt (readable) | Ive | S |
| content-area-ratio | 85-95% | Rams, Vignelli | B |
| whitespace-ratio | 40-60% | Ive, Brockmann, Rand | B |
| void-ratio | 70-90% (extreme whitespace) | Lee Ufan | B |
| grid-columns | 2, 3, 4, 6, 12 columns | Vignelli, Brockmann | S |
| grid-gutter | 8pt or 1/10-1/6 of column width | Ive, Brockmann | S |
| alignment-axes | max 3 per surface | Rams, Vignelli | B |
| hierarchy-levels | max 3 levels | Rams, Vignelli, Norman | D |
| cognitive-chunk-max | 7 +-2 items | Norman | C |
| nav-depth-max | 3 levels or fewer | Norman | D |
| touch-target-min | 44x44pt | Ive, Norman | S |
| golden-ratio | 1:1.618 | Rams | B |
| sqrt2-ratio | 1:1.414 (A series) | Vignelli, Brockmann | S |
| nav-bar-height | 44pt (compact) / 96pt (large) | Ive, Dye | A |
| tab-bar-height | 49pt / 83pt | Ive | A |
| mondrian-grid-cell-range | 5-55% uneven division | Mondrian | B |
| rothko-field-count | 2-3 vertically stacked | Rothko | B |
| albers-nesting-levels | 3-4 nested levels | Albers | B |
| malevich-shape-count | 1-12 per screen | Malevich | B |

## Typography

| Token | Value | Source | Source grade (lowest) |
|--------|---|------|----------------|
| font-system | SF Pro / SF Compact | Ive, Dye, Won | S |
| font-classic-sans | Helvetica, Akzidenz-Grotesk | Rams, Vignelli, Brockmann | B |
| font-classic-serif | Bodoni, Garamond, Sabon | Vignelli, Tschichold | S |
| font-family-count | limited to 1-3 families | Vignelli, Brockmann, Tschichold | S |
| type-scale | 11, 12, 13, 15, 17, 20, 22, 28, 34pt | Ive, Dye, Won | S |
| body-size | 17pt (iOS), 16px (web) | Ive, Norman, Matas | D |
| headline-size | 28-34pt | Ive, Dye | A |
| caption-size | 11-12pt | Ive, Dye | S |
| font-size-ratio | title:body = 1.5:1 ~ 3:1 | Tschichold, Rand | A |
| line-height-ratio | 1.2-1.4x (Latin) | Ive, Vignelli, Brockmann | B |
| line-height-korean | 1.4-1.6x | Won | A |
| line-length | 45-75 characters (optimal 60) | Norman, Tschichold | C |
| letter-spacing-body | 0pt (default) | Ive | A |
| letter-spacing-title | -0.4 ~ -1.6pt (tightening) | Ive | A |
| letter-spacing-caps | +5-10% | Tschichold, Rams | B |
| korean-tracking | -0.01em ~ -0.02em | Won | B |
| font-weight-range | Ultralight(100)-Black(900) | Ive, Dye, Won | A |
| text-align | left-aligned by default | Tschichold, Brockmann, Norman | C |
| contrast-ratio-text | min 4.5:1 (AA), 7:1 (AAA) | Norman, Rams | B |
| dynamic-type-range | xSmall(14pt) ~ AX5(60pt) | Ive, Dye | S |
| readable-line-length | max-width: 65ch | Tschichold, Norman | C |
| text-transform-sign | uppercase (signage/titles) | Vignelli | S |

## Color & Surface

| Token | Value | Source | Source grade (lowest) |
|--------|---|------|----------------|
| system-blue | #007AFF / #0A84FF (dark) | Ive, Dye, Won | S |
| system-red | #FF3B30 / #FF453A (dark) | Ive | S |
| system-green | #34C759 / #30D158 (dark) | Ive | S |
| bg-primary | #FFFFFF / #000000 (dark) | Ive, Dye | S |
| bg-secondary | #F2F2F7 / #1C1C1E (dark) | Ive, Dye | S |
| palette-neutral | #E0E0E0 ~ #F5F5F5 | Rams | B |
| palette-primary-3color | black-white-1 accent color | Rams, Tschichold, Rand | B |
| accent-usage | under 5% of screen (minimal) / 15-30% (standard) / 30-50% (brand) | Rams, Mondrian, Rand — see conflicts.md | D |
| color-count-per-layout | 3-4 colors (including black-white) | Rams, Vignelli, Brockmann | B |
| mondrian-red | #CC2200 ~ #E63929 | Mondrian | B |
| mondrian-blue | #1B3B8C ~ #2040A0 | Mondrian | B |
| mondrian-yellow | #F2D516 ~ #FFE135 | Mondrian | B |
| rothko-surface-dark | #1A1520 ~ #4D3B52 (4 levels) | Rothko | B |
| rothko-warm-white | #F0E8D8 ~ #FAF2E6 | Rothko | C |
| malevich-surface-light | #F0EDE5 ~ #FFFFFF (4 levels) | Malevich | C |
| kandinsky-blue-deep | #1A237E ~ #283593 | Kandinsky | B |
| lee-canvas-white | #F5F0E8 ~ #FAF5ED (raw canvas color) | Lee Ufan | B |
| turrell-kelvin | 2700K-5000K-7500K | Turrell | B |
| turrell-warm-glow | #FF8C42 ~ #FFAA5C | Turrell | B |
| turrell-blue-deep | #1A2060 ~ #2A3080 | Turrell | B |
| blur-material | thin/regular/thick (5 types) | Ive, Dye | A |
| blur-radius | 20-40pt | Ive, Matas | B |
| separator-color | rgba(60,60,67,0.29) | Ive | S |
| surface-texture | none (solid flat) | Rams, Vignelli, Brockmann | D |
| gradient-usage | none (Rams, Mondrian) / vertical only (Rothko) | conflict - see conflicts.md | F |
| disabled-opacity | 0.38-0.5 | Norman | A |
| dark-elevation | brightness +4-8% as z-axis rises | Dye, Rothko | B |
| riley-bw | #0A0A0A / #F5F5F5 (max contrast) | Riley | B |
| color-functional | color = meaning/category (no decoration) | Vignelli, Norman, Tschichold | D |

### Accessibility warning notes — Color & Surface
- `riley-bw`: High-contrast black-and-white patterns are used only in **areas separated from content**, such as decoration/loading/separators. Prohibited as a background behind text, input fields, or focus targets, and screen coverage is limited to 50% or less.
- `turrell-kelvin`: Automatic color-temperature shifts of 2700K↔5000K↔7500K are used opt-in only in immersive/wellness modes. Default reading/work screens prioritize a fixed color temperature, and automatic shifts must always offer an opt-out.
- `rothko-surface-dark`: Tinted dark surfaces are allowed, but body text must maintain at least WCAG AA 4.5:1, and large text, icons, separators, and input borders must maintain at least 3:1 contrast. Do not collapse to pure black; when necessary, separate the reading layer with a dedicated panel, secondary surface, or subtle border treatment.

## Shape & Geometry

| Token | Value | Source | Source grade (lowest) |
|--------|---|------|----------------|
| corner-radius-small | 6-8pt | Ive | B |
| corner-radius-medium | 10-13pt | Ive, Dye | B |
| corner-radius-large.ios | 22pt | Dye | S |
| corner-radius-large.web | 22px | Ive (iOS equivalent) | B |
| corner-radius-large.android | 16dp (M3 Large) or 28dp (M3 XL, when iOS equivalence required) | M3 Shape | S |
| corner-style | .continuous (squircle, G2) | Ive, Dye | S |
| corner-radius-zero | 0px (prefers right angles) | Rams, Vignelli, Tschichold, Brockmann, Mondrian | B |
| corner-radius-logo | 0px or 50% (extreme choice) | Rand | S |
| form-vocabulary | square, circle, triangle (3 types) | Vignelli, Brockmann, Rand, Malevich | B |
| icon-stroke | 1.5-2pt @1x | Ive, Rams | F |
| icon-style | linear (outline), uniform weight | Rams, Matas | B |
| aspect-ratio-device | 19.5:9 (iPhone), 4:3 (iPad) | Ive | S |
| aspect-ratio-golden | 1:1.618 | Rams, Rand | B |
| aspect-ratio-a-series | 1:1.414 | Vignelli, Brockmann | S |
| depth-layers.ios | 3 levels: base / raised / overlay | Dye, Matas | A |
| depth-layers.web | 3 levels: base(0) / raised(4-12px shadow) / overlay(8-24px shadow) | Kandinsky | C |
| depth-layers.android | 5 levels: Level 0-5 (M3 tonal + shadow elevation) | M3 Elevation | S |
| sf-symbol-rendering | mono/hierarchical/palette/multicolor | Ive | S |
| pill-shape | height/2 radius (pill form) | Matas | A |
| mondrian-line-weight | 3-8px | Mondrian | B |
| kandinsky-color-form | triangle=yellow, circle=blue, square=red | Kandinsky | B |
| albers-nesting-scale | inner = 70-80% of outer | Albers | B |
| riley-stripe-width | 2-20px | Riley | B |
| turrell-aperture-ratio | aperture 15-30% : surroundings 70-85% | Turrell | C |

### Accessibility warning notes — Shape & Geometry
- `riley-stripe-width`: Stripes maintain a minimum of 2px at 1x, and different repeating patterns are not overlaid on a single screen. Repeating stripes are used only on a separated decorative/loading surface, not as a content background.

## Motion & Interaction

| Token | Value | Source | Source grade (lowest) |
|--------|---|------|----------------|
| duration-fast | 0.15-0.2s | Ive, Rams | F |
| duration-standard | 0.25-0.35s | Ive, Dye | A |
| duration-slow | 0.4-0.5s | Ive, Matas | B |
| duration-immersive | 2-5s (immersive transition) | Turrell, Rothko | F |
| spring-damping | 0.7-0.85 | Ive, Matas | A |
| spring-response | 0.3-0.5s | Ive, Matas, Dye | A |
| easing-default | ease-in-out | Ive | A |
| easing-minimal | ease-out or linear | Rams, Brockmann | F |
| gesture-velocity | 500pt/s (swipe threshold) | Ive, Matas | A |
| haptic-feedback | light/medium/heavy | Ive, Dye | S |
| response-instant | within 100ms | Norman, Rams | C |
| response-seamless | within 1s | Norman | C |
| loading-feedback | spinner if exceeding 1s | Norman | C |
| reduce-motion | replace with crossfade 0.3s | Ive | S |
| animation-purpose | state transitions only (no decoration) | Norman, Rams | D |
| frame-rate | 60fps required | Matas | S |
| rubber-band | 1/3 deceleration on overscroll | Dye, Matas | A |
| lee-fade-curve | ease-out (sharp start, soft end) | Lee Ufan | C |
| lee-opacity-decay | 100% -> 5% linear decrease | Lee Ufan | B |
| riley-repetition-threshold | vibration begins at 7-10 repetitions | Riley | C |
| turrell-breath | brightness +-5%, period 4-8s | Turrell | C |
| turrell-color-cycle | full cycle 10-60 min (UI: 2-10s) | Turrell | B |
| rothko-slow-transition | 500ms-2000ms color-field transition | Rothko | F |
| kare-click-feedback | Invert, within 50ms | Kare | S |

### Accessibility warning notes — Motion & Interaction
- `turrell-breath`: The brightness-breathing animation is replaced with a freeze/crossfade when `reduce-motion` or an equivalent accessibility setting is on. On auto-repeat, the amplitude must not exceed ±5% and the period must stay within the 4-8 second range, and it must not create flash/flicker conditions.

## Token-level accessibility usage envelope (round-004)

| Token | allow | conditional | prohibit | Rationale combination |
|------|---------------|---------------------------|-----------------|-----------|
| `riley-bw`, `riley-stripe-width` | **One-dimensional pattern surfaces separated from content**, such as loading bars, separators, and decorative panels. Stripes maintain 2-20px at 1x. | Hero/transition panels are allowed only when the exposure is transient, `reduce-motion` is off, and no flash/flicker is created. Limit the pattern surface to 50% or less of the screen and pair it with a non-pattern rest surface. | Backgrounds behind text/input/focus elements, persistent large-area exposure of static high-contrast patterns, overlaying repeating patterns of different periods. | A conservative operational rule combining stripe-width 2-20px, breathing-contrast 50% whitespace, and the ban on large-area/content backgrounds from `bridget-riley.md` with the WCAG 2.2 contrast/focus criteria from `platforms/web.md`. |
| `turrell-kelvin` | Used as **fixed presets** of 2700K, 5000K, and 7500K on ambient surfaces that occupy 30% or more of the screen, such as immersive/wellness/media. | Automatic color-temperature transitions are allowed only when both opt-in and opt-out exist. Keep transition time at 2 seconds or more, and separate reading content onto a neutral surface or a dedicated panel. | Persistent automatic color-temperature shifts in default reading/work flows, small elements/controls under 30%, abrupt jump transitions under 2 seconds. | Combines the unsuitability for small elements, 2-5 second gradual transitions, and opt-out caution from `james-turrell.md` with the default surface systems of `platforms/apple.md`/`platforms/android.md`. |
| `turrell-breath` | Used only on large surfaces occupying 30% or more of the screen, such as a background or ambient overlay. Keep amplitude at ±5% and period at 4-8 seconds. | Repetition is allowed only when `reduce-motion` is off and it is an atmosphere layer rather than state-change feedback. Replace with a static crossfade when needed. | Animation of interactive elements themselves such as buttons/inputs/focus rings, backgrounds that directly carry foreground text, repeated playback while `reduce-motion` is on. | Combines the breath-animation 4-8 seconds and small-element unsuitability from `james-turrell.md` with the existing `reduce-motion` token. |
| `rothko-surface-dark` | Tinted dark backgrounds/panels/immersive sections such as `surface-0`~`surface-3`. Limit backgrounds and panels to 2-3 surfaces to preserve the emotional tone. | Place directly only when body text is 4.5:1 and large text, icons, separators, and input borders are 3:1 or higher. Place long-form text on a separated secondary surface/overlay, and gradient/blur must maintain the contrast criteria even after being applied. | pure black substitution, texture/pattern overlay, overuse of primary/neon accents, dense long-form body on a raw dark surface, fast color-field transitions under 500ms. | Combines surface-0~3, the pure-black ban, the texture ban, and slow transition 500-2000ms from `rothko.md` with the WCAG AA text 4.5:1 / non-text 3:1 criteria from `platforms/web.md`. |
