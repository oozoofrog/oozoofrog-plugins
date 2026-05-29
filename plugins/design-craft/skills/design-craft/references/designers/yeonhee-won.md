# 원연희 (Yeonhee Won) -- Design Token Dictionary

## Profile
- **Active period**: 2000s-present, peak 2010s-present (Apple Hangul typography)
- **Main affiliations**: Apple Korea typography team, Apple global font engineering
- **Key contributions**: SF Pro Hangul adaptation and optimization, Apple platform Hangul typography guidelines, Hangul letter-spacing/line-spacing correction system, standardization of Hangul rendering quality across the Apple ecosystem
- **Design lineage**: Hangul typography tradition → Apple Human Interface Guidelines Hangul localization → SF Pro Hangul extension

## Design Philosophy (quantifiable principles)

| Principle | Quantitative translation | UI metric |
|------|----------|----------|
| Hangul-Latin harmony | Match visual size when mixing Hangul/Latin | Match Hangul medial height against x-height |
| System consistency | Identical rendering on all Apple platforms | Unify iOS/macOS/watchOS Hangul tokens |
| Readability first | 99%+ Hangul legibility on small displays | Body text legible even on 38mm watchOS |
| Precise letter-spacing | Apply Hangul-specific letter-spacing table | Kerning optimization for 11,172 composed Hangul characters |
| Cultural fit | Respect Hangul typography tradition | Reflect vertical-writing and mixed-script typesetting rules |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| korean-body-size | 17pt (iOS default body) | Apple HIG — Dynamic Type default size | S |
| korean-minimum-size | 11pt (iOS minimum legible size) | Apple HIG — Hangul minimum size recommendation | A |
| watchos-body | 16pt (40mm), 17pt (44mm) | watchOS HIG — Hangul body size | A |
| line-height-korean | 1.4-1.6 (wider line-spacing vs Latin 1.2) | Apple HIG — Hangul line-spacing correction guide | A |
| paragraph-spacing | 60-80% of body size | Apple HIG — Hangul paragraph spacing | B |
| margin-horizontal | 16pt (compact), 20pt (regular) | Apple HIG — iOS horizontal margin | S |
| text-container-ratio | Hangul text area = 5-10% wider than Latin | Correction for Hangul glyphs being wider than Latin | B |
| grid-base | 8pt (Apple standard grid) | Apple HIG — base grid unit | S |

### Typography

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| font-sf-korean | Apple SD Gothic Neo → SF Pro Hangul | Apple system font evolution | S |
| font-weight-korean | Ultralight-Black (9 weights) | SF Pro Hangul weight system | A |
| korean-tracking | -0.01em ~ -0.02em (slightly tighter than default) | Apple Hangul tracking correction value | B |
| korean-x-height-match | Hangul medial height = 80-85% of Latin cap-height | SF Pro Hangul-Latin mixed-script visual matching analysis | B |
| korean-ascender | 95-100% of Latin ascender | SF Pro Hangul top-alignment analysis | B |
| korean-descender | 80-90% of Latin descender (Hangul has little bottom overhang) | SF Pro Hangul bottom-alignment analysis | B |
| font-size-scale | 11, 13, 15, 17, 20, 22, 28, 34pt (Dynamic Type) | Apple HIG — Dynamic Type 7 steps | S |
| line-break-rule | Hangul word-unit line breaks, syllable-unit allowed | Apple Hangul line-break rules | A |
| word-spacing | Hangul word space = 25-33% of Hangul width | Apple Hangul word-spacing analysis | B |
| mixed-script-baseline | Hangul/Latin baseline alignment correction +1-2pt | SF Pro Hangul-Latin mixed-script baseline correction | B |

### Color & Surface

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| text-primary | label semantic color (light: #000000, dark: #FFFFFF) | Apple HIG — semantic text color | S |
| text-secondary | secondaryLabel (light: 60% opacity) | Apple HIG — secondary text color | S |
| text-tertiary | tertiaryLabel (light: 30% opacity) | Apple HIG — tertiary text color | S |
| korean-rendering | subpixel antialiasing → grayscale AA | Apple Retina display Hangul rendering | A |
| contrast-ratio | minimum 4.5:1 (body), 3:1 (large text) | Apple accessibility guidelines | S |
| tint-color | systemBlue (#007AFF) default accent | Apple HIG — default tint color | S |
| background | systemBackground (light: #FFFFFF, dark: #000000) | Apple HIG — semantic background color | S |

### Form & Curvature

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| korean-em-square | 1000 UPM (units per em) | SF Pro font metrics | S |
| stroke-contrast | Hangul vertical:horizontal stroke = 1.1-1.3:1 (low contrast) | SF Pro Hangul stroke-contrast analysis | B |
| corner-radius-glyph | Subtle glyph corner rounding (CFF2 hinting) | SF Pro Hangul glyph-shape analysis | B |
| hangul-structure | Initial/medial/final placed within square em-box | Hangul compositional structure — letter width = height | S |
| button-radius | 10pt (iOS default), continuous corner | Apple HIG — button curvature | S |
| text-field-height | 34pt (compact), 44pt (regular) | Apple HIG — Hangul input field height | A |
| glyph-width | full-width (em) width — Hangul is monospace by default | SF Pro Hangul glyph-width analysis | A |

### Interaction & Motion

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| keyboard-input | Dubeolsik/Sebeolsik input → real-time composition display | iOS/macOS Hangul input method | S |
| composition-feedback | underline during composition, removed after completion | Apple Hangul inline input UX | S |
| autocorrect-delay | Hangul autocorrect = 0.5-1s after word completion | iOS Hangul autocorrect timing | B |
| text-selection | Hangul syllable-unit selection (double-tap = word) | iOS Hangul text-selection rules | A |
| dynamic-type-animation | 0.3s ease-in-out transition on size change | iOS Dynamic Type transition animation | A |
| font-smoothing | subpixel → grayscale AA (Retina) | Apple text-rendering transition | A |

## Evolution by Era

| Era | Turning point | Key numeric changes |
|------|--------|---------------|
| Early 2000s | Apple Korea Hangul localization foundations | Lucida Grande Hangul supplement, basic letter-spacing setup |
| 2007-2012 | iPhone/iPad Hangul optimization | Apple SD Gothic Neo introduced, iOS Hangul rendering system established |
| 2013-2015 | iOS 7 flat design transition | Helvetica Neue Hangul pairing optimization, Dynamic Type Hangul support |
| 2015-2019 | SF Pro Hangul integration | SF Pro Hangul expanded to 9 weights, watchOS Hangul optimization |
| 2020-present | SF Pro Rounded/Hangul extension | Variable Font Hangul adaptation, accessibility strengthened |

## Influence Relationships

- **Hangul typography tradition → 원연희 (Yeonhee Won)**: 세종대왕 (King Sejong) 훈민정음 (Hunminjeongeum) geometry, 최정호 (Choi Jeong-ho) Myeongjo system
- **Apple SF design team → 원연희 (Yeonhee Won)**: Applied SF Pro Latin design principles to Hangul
- **원연희 (Yeonhee Won) → Apple Hangul ecosystem**: iOS/macOS/watchOS/visionOS Hangul typography quality standard
- **원연희 (Yeonhee Won) → Hangul web typography**: Apple Hangul guidelines became the de facto standard for web/app Hangul typesetting
- **Key references**: Apple Human Interface Guidelines — Typography, SF Pro font release notes

## UI Application Mapping

| 원연희 (Yeonhee Won) principle | Modern UI token translation rule |
|------------|----------------------|
| Hangul-Latin visual matching | Correct Hangul visual size even at identical `font-size` — use `font-size-adjust` |
| Wide Hangul line-spacing | `line-height: 1.5` (Hangul), `line-height: 1.3` (Latin) — separate per language |
| Letter-spacing correction | `letter-spacing: -0.01em` (Hangul default), standard for Latin |
| Dynamic Type | `.font(.body)` — auto-reflects user-set size, guarantees Hangul minimum 11pt |
| Word-unit line breaks | `word-break: keep-all` (Hangul), minimize syllable splitting |
| Composition input UX | Handle `compositionupdate` events during Hangul input, visually indicate composition state |
| Accessibility contrast | Hangul body contrast 4.5:1+, use semantic colors `.foregroundStyle(.primary)` |
| System font | `-apple-system, BlinkMacSystemFont` → SF Pro Hangul applied automatically |
| Square em-box | Hangul width:height = 1:1, fixed-width → advantageous for alignment in tables/grids |
| Dark mode Hangul | Hangul stroke weight correction — `font-weight` +50 visual correction in dark mode |
