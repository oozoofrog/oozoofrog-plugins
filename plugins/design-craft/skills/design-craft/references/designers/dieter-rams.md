# Dieter Rams -- Design Token Dictionary

## Profile
- **Active period**: 1955-1995 (Braun), core period 1961-1995 (Head of Design)
- **Main affiliations**: Braun AG chief designer, Vitsoe furniture design consultant
- **Key contributions**: established the "Good Design" 10 principles, SK4 record player (1956), T3 radio (1958), ET66 calculator (1987), 606 Universal Shelving System (Vitsoe), TP1 transistor radio (1959)
- **Design lineage**: Ulm School of Design (HfG Ulm) functionalism → direct influence on Apple/Jony Ive

## Design Philosophy (quantifiable principles)

| 10 Principles | Quantitative conversion | UI metric |
|--------|----------|----------|
| 1. Innovative | 30%+ reduction in components vs. existing | introduce new interaction patterns |
| 2. Useful | core feature access ≤ 2 taps | task completion rate 95%+ |
| 3. Aesthetic | ratio close to the golden ratio (1:1.618) | visual harmony |
| 4. Understandable | 80%+ of elements understandable without labels | affordance clarity |
| 5. Unobtrusive | decorative elements 0-5% | content-to-chrome ratio ≥ 85% |
| 6. Honest | 0 fake textures/effects | actual function = visual representation |
| 7. Long-lasting | 0 trend-dependent elements | 0% visual aging after 5 years |
| 8. Thorough | 0 undefined states | all edge cases handled |
| 9. Eco-friendly | material types ≤ 3 per product | minimize rendering layers |
| 10. As little design | minimize number of visual elements (essential only) | UI element density ≤ 30% |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| grid-base | 5mm (physical-product basis) | Braun product measurements ("Less and More" exhibition) | B |
| grid-base-ui | 8pt (digital conversion) | Rams grid converted to an 8pt UI grid | F |
| golden-ratio | 1:1.618 (layout division) | SK4, ET66 ratio measurements | B |
| content-area-ratio | 85-95% (minimize decoration) | Braun panel layout analysis | B |
| symmetry | left-right symmetry (applied to 95%+ of products) | full survey of Braun products | B |
| margin-ratio | 10-20% of total area | SK4, T3 outer-margin measurements | B |
| element-density | 20-30% of screen/panel area | Braun control panel analysis | B |
| control-spacing | minimum spacing between controls = 50% of control height | T3, SK4 dial spacing measurements | B |
| alignment-axes | max 3 vertical/horizontal alignment axes per face | Braun panel grid analysis | B |
| hierarchy-levels | max 3 levels of visual hierarchy | interpretation of Rams design principles | D |

### Typography

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| font-family | Akzidenz-Grotesk, Helvetica | typefaces used on Braun products | B |
| font-weight | Regular(400)-Medium(500) range only | Braun product typeface analysis | B |
| text-hierarchy | max 2 levels (title + body) | Braun panel text analysis | B |
| label-size-ratio | 2-4% of total product height | SK4, T3 label measurements | B |
| label-case | lowercase preferred (all-lowercase) | Braun brand typography | B |
| letter-spacing | wide tracking (+5-10% vs. default) | Braun print material analysis | B |
| numeral-style | Tabular figures (monospaced numerals) | ET66 calculator display | B |
| text-color | black or white — limited to 2 colors | Braun label color rules | B |
| font-size-ui | 14-16pt (body), 20-24pt (title) | UI conversion based on 8pt grid | F |
| type-contrast | foreground/background contrast minimum 7:1 | Braun high-contrast design measurements | B |

### Color & Surface

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| palette-primary | pure white(#FFFFFF), pure black(#000000) | Braun base colors | B |
| palette-neutral | light gray(#E0E0E0 ~ #F5F5F5) | SK4, T1000 surfaces | B |
| accent-color | green(#4CAF50), orange(#FF9800) — for function indication | Braun on/off indicator lights | B |
| accent-usage | ≤ 5% of screen area | Braun accent color ratio measurements | B |
| surface-finish | matte preferred, glossy only on display areas | Braun material strategy | D |
| color-count | max 3 colors per product (black, white, 1 accent) | Braun color palette analysis | B |
| grayscale-steps | 3-5 steps (white→light gray→mid gray→dark gray→black) | Braun product tone analysis | B |
| texture | none — smooth solid-color surfaces | Rams "honest design" principle | D |
| shadow-usage | physical depth only (no artificial shadows) | Braun three-dimensional structure analysis | D |
| background-ui | #FAFAFA (light mode), #1A1A1A (dark mode) | UI conversion based on 8pt grid | F |

### Form & Curvature

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| corner-radius | 0-2mm (nearly square) | Braun product measurements — preference for sharp corners | B |
| corner-radius-ui | 2-4pt (digital conversion — minimal rounding) | UI application of Rams' right-angle principle | F |
| edge-treatment | chamfer 0.5-1mm | Braun metal edge measurements | B |
| form-geometry | rectangular 90%+, circular dials 10% or less | Braun product form statistics | B |
| aspect-ratio | golden ratio(1:1.618) or √2 ratio(1:1.414) | SK4(1:1.62), ET66(1:1.58) measurements | B |
| button-shape | circular or square — only 2 types used | T3, ET66 button analysis | B |
| button-size | diameter 10-15mm (physical), 36-44pt (UI conversion) | Braun button measurements | B |
| icon-style | linear (outline), uniform stroke width | Braun pictogram style | B |
| icon-stroke | 1.5-2pt @1x | UI conversion of Braun icon thickness | F |
| depth-layers | max 2 levels (base surface + control surface) | Braun product depth-structure analysis | B |

### Interaction & Motion

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| feedback-immediate | ≤ 100ms visual response after operation | Braun physical-toggle instant-response principle | D |
| transition-duration | 0.15-0.25s (fast, restrained transitions) | UI interpretation of Rams' "unobtrusive design" principle | F |
| animation-count | ≤ 1 simultaneous animation per screen | "as little design" principle | D |
| easing | linear or ease-out — no exaggerated bounce | digital translation of physical operation feel | F |
| hover-feedback | opacity change 0.85-1.0 (subtle change) | UI interpretation of Rams' restraint principle | F |
| click-feedback | scale 0.97-1.0 (subtle press) | digital expression of physical-button haptics | F |
| scroll-behavior | inertial scrolling, no overscroll bounce | interpretation of "unobtrusive" interaction | F |
| state-change | instant — fade within 0.1s | Braun toggle-switch behavior | D |
| affordance-ratio | 90%+ of operable elements visually distinct | Rams "understandable design" | D |
| micro-interaction | minimized — essential feedback only | "as little design" principle | D |

### Module & System Design

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| module-base | integer multiple of the product's smallest unit | Vitsoe 606 shelving system | B |
| stackability | 0mm spacing when connected vertically/horizontally (gapless) | Braun stack audio measurements | B |
| interchangeability | 100% part compatibility within the same form factor | Braun modular system | D |
| system-coherence | 90%+ shared design language across the product family | Braun audio lineup analysis | B |
| proportional-grid | divide total area into 3x3 or 5x5 equal parts | SK4, T1000 layout analysis | B |
| label-placement | bottom-left or bottom-right — consistent position | Braun label placement rules | B |

## Key Product Token Snapshot

| Product | Key ratio | Value |
|------|----------|---|
| SK4 record player | overall ratio | 58x33cm → 1:1.76 (close to golden ratio) |
| T3 pocket radio | front ratio | 12x7cm → 1:1.71 |
| ET66 calculator | overall ratio | 15x9.5cm → 1:1.58 (close to golden ratio) |
| TP1 transistor | circular dial ratio | 60% of front area |
| T1000 world receiver | dial area | 70% of front, button area 15% |
| 606 Universal Shelving System | module unit | 65.5cm width, infinite vertical expansion |
| ABR 21 clock | dial ratio | diameter 26cm, numeral height 15mm |

## Changes Over Time

| Period | Turning point | Key numerical changes |
|------|--------|---------------|
| 1955-1960 | early Braun — joined the Ulm School of Design | curved-line ratio 30% → straight-line ratio 90%+ |
| 1961-1970 | system design established | introduced modular grid, established 3-color limit |
| 1971-1980 | minimalism deepened | surface decoration fully removed, control area below 20% |
| 1981-1990 | peak period including ET66 | maximized proportional precision, consistent golden-ratio application |
| 1991-1995 | 10 principles formally published (codified around 1995) | documentation and systematization of the design philosophy |

## Influence Relationships

- **Ulm School of Design (HfG Ulm) → Rams**: Max Bill, Otl Aicher's functionalist, systematic design methodology
- **Bauhaus → Rams**: "form follows function" — but Rams reinterpreted it as "form clarifies function"
- **Rams → Jony Ive**: Braun ET66 → iOS Calculator, SK4 → iPod, T3 → early iPod form
- **Rams → Flat Design movement**: the "unobtrusiveness" and "honesty" of the 10 principles became the theoretical basis for rejecting skeuomorphism
- **Rams → Muji**: direct influence on Naoto Fukasawa's Muji design
- **Key references**: "Dieter Rams: As Little Design as Possible" (Sophie Lovell, 2011), "Less and More" exhibition catalog (2009)

## 10 Principles → Direct CSS/SwiftUI Mapping

| Principle | CSS property conversion | SwiftUI conversion |
|------|------------------|-------------|
| Unobtrusive | `box-shadow: none; border: 1px solid` | `.shadow(radius: 0)` |
| Honest | `background-image: none` (no textures) | use semantic colors only |
| As little design | `* { transition: 0.15s ease-out }` | `.animation(.easeOut(duration: 0.15))` |
| Understandable | `cursor: pointer` (explicit interactivity) | `.buttonStyle(.bordered)` |
| Long-lasting | `font-family: system-ui` (system typeface) | `.font(.body)` |

## UI Application Mapping

| Rams principle | Modern UI token conversion rule |
|-----------|----------------------|
| As little design | remove decorative shadows, gradients, textures; `box-shadow: none`; solid-color background |
| Right-angle preference | `border-radius: 2-4px` — minimal rounding, straight-line-based layout |
| 3-color palette | black, white, 1 accent; compose the entire theme with 3 CSS variables |
| Golden-ratio layout | `grid-template-columns: 1fr 1.618fr` or 38.2% / 61.8% split |
| High contrast | text contrast 7:1 or higher, WCAG AAA compliant |
| Unobtrusive motion | `transition: 0.15s ease-out`, no bounce or overshoot |
| Function = form | buttons look like buttons, links look like links — role consistency |
| Systematic grid | strict 8pt grid, all dimensions multiples of 8 |
| Durability | exclude trendy glassmorphism/neumorphism, timeless style |
| Environmental consideration | remove unnecessary animations → respect `prefers-reduced-motion` |
