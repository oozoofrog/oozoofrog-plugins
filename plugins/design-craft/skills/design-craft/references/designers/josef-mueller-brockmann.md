# Josef Müller-Brockmann -- Design Token Dictionary

## Profile
- **Active period**: 1950-1996, core period 1955-1980
- **Main affiliations**: Professor at Zurich School of Applied Arts, Müller-Brockmann & Co., IBM Europe design consultant
- **Key contributions**: "Grid Systems in Graphic Design"(1981), Musica Viva concert posters(1950s-70s), Zurich Tonhalle poster series, "The Graphic Artist and His Design Problems"(1961)
- **Design lineage**: Bauhaus Constructivism → established Swiss International Typographic Style → father of the modern grid system

## Design Philosophy (Quantifiable Principles)

| Principle | Quantitative translation | UI metric |
|------|----------|----------|
| Mathematical grid | 100% of elements placed on grid intersections | 0 unaligned elements |
| Objective communication | 0% decorative elements, maximized information density | 0 purely-decorative elements |
| Geometric abstraction | 3 base shapes: circle, square, triangle | 0 organic shapes |
| Sans-serif only | 0% serif typeface usage | 1 typeface (Akzidenz-Grotesk/Helvetica) |
| Asymmetric balance | 0% central-axis symmetry, 100% grid-based asymmetry | left / top-left alignment by default |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| grid-columns | 2, 3, 4, 6 columns (multiples of 2·3) | "Grid Systems" (1981) p.58-74 | S |
| grid-rows | 4, 6, 8 rows (multiples of 2) | "Grid Systems" p.76-88 | S |
| grid-field | column×row intersection = field (base unit) | "Grid Systems" p.52 | S |
| gutter-width | 1/10 ~ 1/6 of field width | "Grid Systems" p.62 | S |
| margin-top | 1/10 ~ 1/8 of total height | "Grid Systems" margin rules | A |
| margin-bottom | 1.5-2× of margin-top | "Grid Systems" bottom-margin rules | A |
| margin-outer | 1/12 ~ 1/8 of total width | "Grid Systems" side margins | A |
| modular-unit | text line height (body size + leading) = base module | "Grid Systems" p.46 | S |
| multi-grid | 2-3 grid types can overlap on the same page | "Grid Systems" p.90-104 | S |
| poster-ratio | 128×90.5cm (SBB standard) → 1:1.414 (√2) | Swiss Federal Railways poster standard size | S |
| grid-base-ui | 8pt (digital conversion) | UI scaling of Brockmann's modular unit | F |

### Typography

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| font-family | Akzidenz-Grotesk (1950-60s), Helvetica (1960s-) | Musica Viva poster typeface analysis | S |
| font-family-count | 1 (single typeface family) | Brockmann single-typeface principle | S |
| font-weight | Light(300), Regular(400), Bold(700) | Musica Viva poster weight analysis | A |
| font-size-scale | 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24, 36, 48, 60, 72pt | "Grid Systems" p.42 standard size list | S |
| line-height | 120% of body size (auto) | "Grid Systems" leading = base unit of one line | S |
| line-length | 7-10 words/line (English), 50-60 chars/line | "Grid Systems" readability rules | A |
| text-align | flush left — avoid justified alignment | Brockmann asymmetric typography principle | S |
| paragraph-spacing | one line height (= 1 module unit) | "Grid Systems" paragraph-spacing rules | S |
| text-transform | lowercase by default, uppercase = title/emphasis | Musica Viva poster analysis | A |
| font-size-ui | 14-16pt (body), 24-36pt (title) | 8pt grid-based conversion | F |

### Color & Surface

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| palette-poster | black, white, 1-2 single-color accents | Musica Viva poster color analysis | S |
| color-functional | color = visual hierarchy/region separation | Brockmann poster color function analysis | A |
| background | pure white (#FFFFFF) or solid-color background | Brockmann poster default background | A |
| accent-area | accent color area ≤ 30% (geometric region) | Musica Viva poster color-area analysis | A |
| contrast-ratio | minimum 7:1 (text/background) | poster readability — long-distance legibility criterion | A |
| gradient | none — solid-color planes only | Brockmann flat-composition principle | S |
| color-count | 2-4 colors/page (including black·white) | Brockmann poster exhaustive analysis | A |
| surface | matte, no texture, pure color planes | Brockmann objective-design principle | A |

### Form & Curvature

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| form-vocabulary | circle, rectangle, triangle, straight line — 4 types | Musica Viva poster form analysis | S |
| corner-radius | 0px (right angle) | Brockmann geometric-form principle | A |
| arc-geometry | concentric circles, evenly divided arcs | Musica Viva "Beethoven" poster analysis | S |
| line-weight | uniform thickness, 0.5-2pt (print) | Brockmann poster line analysis | A |
| circle-ratio | circular area = 20-60% of the surface (poster) | Musica Viva circular-composition measurement | A |
| shape-repetition | identical shape repeated 5-50 times (creating rhythm) | Musica Viva "der Film" poster analysis | A |
| negative-space | whitespace ratio 40-60% | Brockmann poster whitespace analysis | A |
| border | none — the form itself is the boundary | Brockmann frameless composition | A |

### Interaction & Motion

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| transition-duration | 0.2-0.3s (mathematical precision) | UI interpretation of Brockmann's systematic principle | F |
| animation | geometric transforms only (rotate, scale, translate) | motion conversion of Brockmann's geometric vocabulary | F |
| easing | linear (constant speed) — avoid natural curves | interpretation of the mathematical-objectivity principle | F |
| rhythm | evenly spaced repeating pattern | Musica Viva visual-rhythm analysis | A |
| hover-feedback | opacity 0.7-1.0 (simple opacity change) | UI interpretation of Brockmann's restraint principle | F |
| scroll-behavior | grid-snap scroll (field unit) | digital conversion of the grid system | F |

## Evolution by Era

| Era | Turning point | Key numeric changes |
|------|--------|---------------|
| 1950-1955 | Early posters — Constructivist influence | diagonal usage 30%+, irregular composition |
| 1955-1965 | Peak of Musica Viva posters | established circular / concentric-circle composition, 1-2 color limit |
| 1966-1981 | Theorizing the grid system | wrote "Grid Systems", systematized mathematical grid formulas |
| 1982-1996 | IBM consulting + teaching | applied grid to corporate CI, began recognizing digital media |

## Influence Relationships

- **Bauhaus/Constructivism → Brockmann**: geometric composition of El Lissitzky and Moholy-Nagy
- **Max Bill → Brockmann**: mathematical forms of Zurich Concrete Art
- **Brockmann → Vignelli**: Swiss grid → transplanted into American corporate identity
- **Brockmann → CSS Grid/Flexbox**: "Grid Systems" as the theoretical basis of web grid layout
- **Brockmann → Material Design**: 8pt grid, modular unit, field concept
- **Key references**: "Grid Systems in Graphic Design" (1981), "The Graphic Artist and His Design Problems" (1961)

## UI Application Mapping

| Brockmann principle | Modern UI token translation rule |
|---------------|----------------------|
| Mathematical grid | `display: grid; grid-template-columns: repeat(N, 1fr)` — N=2,3,4,6 |
| Modular unit | all spacing in 8pt multiples, `gap: 8px / 16px / 24px` |
| Single typeface | `font-family: system-ui` alone, express hierarchy with 3 weights |
| Left alignment | `text-align: left` by default, no center/right alignment |
| Geometric forms | `border-radius: 0`, `clip-path: circle()` or `polygon()` |
| Objective color | color = region separation/hierarchy function, 0 decorative gradients |
| Whitespace = design | generous `padding` — content density ≤ 60% |
| Rhythmic repetition | repeat identical components, `grid-auto-flow: row` |
| √2 ratio | card/screen ratio `1:1.414`, `aspect-ratio: 1 / 1.414` |
| Constant-speed transition | `transition-timing-function: linear`, no bounce |
