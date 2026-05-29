# Massimo Vignelli -- Design Token Dictionary

## Profile
- **Active period**: 1954-2014, core period 1965-1990 (Vignelli Associates)
- **Main affiliations**: Co-founded Unimark International (1965), Vignelli Associates (1971-2014)
- **Key contributions**: NYC subway signage system (1972), American Airlines logo (1967), Knoll furniture identity, IBM graphic standards, National Park Service Unigrid system, Bloomingdale's shopping bag
- **Design lineage**: Politecnico di Milano → Swiss modernism → systematization of American corporate identity

## Design Philosophy (quantifiable principles)

| Principle | Quantitative translation | UI metric |
|------|----------|----------|
| Six typefaces are enough | Typeface count ≤ 6 (3 or fewer in actual use) | Font families across the app ≤ 3 |
| The grid is absolute | Grid alignment rate of all elements 100% | Unaligned elements 0 |
| Meaningful form (Semantics) | Form-function match rate 100% | Purely decorative elements 0 |
| Visual Power | Minimum contrast ratio 4.5:1 | WCAG AA or above |
| Timelessness | Trend-dependent elements 0% | Visual obsolescence after 5 years 0% |
| Discipline | Alignment-axis consistency 100% | Max 3 vertical/horizontal axes per screen |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| grid-system | 2-column, 3-column, 6-column division (based on multiples of 6) | "The Vignelli Canon" (2010) p.44 | S |
| unigrid | 12-unit grid, 10 base formats | National Park Service Unigrid System (1977) | S |
| margin-ratio | 10-15% of total area | Vignelli Canon layout analysis | A |
| column-gutter | 1/12 ~ 1/8 of column width | Vignelli Canon grid system | A |
| content-area | 85-90% (content area excluding margins) | Vignelli Associates project measurements | B |
| alignment-axes | Max 3 vertical/horizontal alignment axes per page | Vignelli Canon p.36 | S |
| modular-scale | Integer multiples of the base unit only | Vignelli Canon grid principle | S |
| grid-base-ui | 8pt (digital translation) | UI scaling of Vignelli's 6-unit grid | F |
| hierarchy-levels | Max 3 levels (heading-subheading-body) | Vignelli Canon p.52 typographic hierarchy | S |

### Typography

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| font-family-primary | Helvetica (sans-serif default) | Vignelli Canon p.54 "6 typefaces" | S |
| font-family-serif | Bodoni (serif default), Garamond | Vignelli Canon p.54 | S |
| font-family-count | ≤ 6 (2-3 in practice) | "The Vignelli Canon" declaration | S |
| font-weight | Light(300), Regular(400), Bold(700) — 3 | Vignelli typographic system | A |
| font-size-scale | 1.5x, 2x, 3x of base size (simple integer multiples) | Vignelli Canon p.56 | A |
| line-height | 1.2-1.4 (tight leading) | NYC subway signage measurements | B |
| letter-spacing | Standard (0) ~ slightly wide (+2%) | Vignelli print analysis | B |
| text-transform | Prefers uppercase — signage system | NYC subway signage analysis (Helvetica uppercase) | S |
| subway-sign-size | Station name height 4 inches (10.2cm), direction indicator 2 inches | NYC Transit Authority manual (1970) | S |
| font-size-ui | 14-16pt (body), 24-32pt (heading) | UI translation based on 8pt grid | F |

### Color & Surface

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| palette-subway | Black (#000), white (#FFF), red·blue·green·yellow·orange·brown·purple·gray | NYC subway line color system (1972) | S |
| color-functional | Color = used for line/category distinction | NYC subway color-coding system | S |
| accent-count | 1 color per category, ≤ 8 colors total | NYC subway line color analysis | S |
| background | Pure white (#FFFFFF) or pure black (#000000) | Vignelli poster/print backgrounds | A |
| contrast-ratio | Minimum 7:1 (signage system) | NYC subway signage legibility standard | A |
| color-count-per-layout | 3-4 colors (black·white + 1-2 accents) | Vignelli Canon color principle | A |
| surface | Matte solid color, no texture | Vignelli "flat color" principle | A |
| gradient | Not used — solid color plane division | Vignelli poster analysis | A |

### Form & Curvature

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| corner-radius | 0px (perfect right angles) | Vignelli grid-based straight-line forms | A |
| form-geometry | Rectangle 95%+, circle ≤ 5% | Vignelli poster/signage form analysis | A |
| icon-style | Geometric simple forms, minimal lines | NYC subway pictograms | A |
| line-weight | Uniform thickness, 1-2pt @1x | Vignelli signage system line analysis | B |
| shape-vocabulary | Square, circle, triangle — 3 base forms only | Vignelli Canon p.30 | S |
| aspect-ratio | Prefers A series (1:√2 = 1:1.414) | Vignelli Canon p.44 "A paper sizes" | S |
| border | 0px or 1px solid line — 2 types only | Vignelli layout boundary analysis | A |

### Interaction & Motion

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| transition-duration | 0.15-0.2s (restrained transitions) | UI interpretation of Vignelli's "timeless design" principle | F |
| animation | None — static layout first | Vignelli print-media-based philosophy | D |
| hover-feedback | Color inversion (black↔white) | Interaction translation of Vignelli's high-contrast principle | F |
| state-indicator | Color change only — no form deformation | Interpretation of Vignelli's "form consistency" principle | F |
| scroll-behavior | Page-unit snap scrolling | Interpretation of grid-based page layout | F |
| wayfinding | Color coding + directional arrows | NYC subway signage system | S |

## Changes Over Time

| Period | Turning point | Key numeric changes |
|------|--------|---------------|
| 1954-1964 | Milan education period → emigration to the US | Absorbed European Swiss style, adopted Helvetica |
| 1965-1970 | Founded Unimark International | Established corporate identity system, started NYC subway project |
| 1971-1980 | Independent Vignelli Associates | Unigrid system, established 12-unit grid, consistent use of uppercase |
| 1981-2000 | Maturity — expansion into furniture/products | Extended grid into 3D domain, fixed form vocabulary to 3 types |
| 2001-2014 | Digital transition + Canon release (2010) | Reinterpreted principles for digital media, published the 2010 Vignelli Canon |

## Influence Relationships

- **Swiss typography → Vignelli**: Max Miedinger (Helvetica), Emil Ruder (typography education)
- **Müller-Brockmann → Vignelli**: Transplanted the Swiss grid system into the American corporate environment
- **Vignelli → NYC subway**: Standardized the world's largest-scale public signage system
- **Vignelli → Michael Bierut**: As a Pentagram partner, carried on Vignelli's methodology
- **Vignelli → Material Design**: DNA of strict grids, limited typefaces, and functional color systems
- **Key references**: "The Vignelli Canon" (Massimo Vignelli, 2010), "Design: Vignelli" (2014)

## UI Application Mapping

| Vignelli principle | Modern UI token translation rule |
|--------------|----------------------|
| Six-typeface law | `font-family` variables ≤ 3, system typeface + 1 web font |
| Absolute grid | `display: grid`, 12-column layout, all elements snap to grid |
| A-ratio preference | Card/modal ratio `1:1.414`, `aspect-ratio: 1 / 1.414` |
| Functional color | Color = category/state meaning, decorative colors 0 |
| High-contrast text | `color: #000; background: #FFF` — contrast 21:1, WCAG AAA |
| Perfect right angles | `border-radius: 0`, no rounding whatsoever |
| Uppercase headings | `text-transform: uppercase` + `letter-spacing: 0.05em` |
| Unigrid system | Responsive 12-column grid, 3 breakpoint tiers |
| Static layout | Unnecessary animations 0, respect `prefers-reduced-motion` |
| Wayfinding | Apply color coding to tab bars/sidebars, use icons + text together |
