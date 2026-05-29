# Jan Tschichold -- Design Token Dictionary

## Profile
- **Active period**: 1925-1974, core periods 1925-1935 (New Typography), 1947-1967 (Penguin Books)
- **Main affiliations**: Professor at the Munich school of printing, Penguin Books typography director (1947-1949)
- **Key contributions**: "Die neue Typographie" (1928), "Typographische Gestaltung" (1935), Penguin Books grid standardization, Sabon typeface design (1967)
- **Design lineage**: Bauhaus influence → founding of New Typography → return to traditional typography (a rare U-turn)

## Design Philosophy (quantifiable principles)

| Principle | Quantitative translation | UI metric |
|------|----------|----------|
| Asymmetric layout (early) | central axis 0%, asymmetric placement 100% | left-aligned by default |
| Golden section (late) | page ratio 2:3, text area ratio golden ratio | content area 61.8% |
| Functional typography | 0 decorative typefaces (early), functional serifs allowed (late) | typeface count ≤ 2 |
| Hierarchical clarity | size contrast ≥ 1.5x (heading vs body) | visual hierarchy within 3 levels |
| Proportional margins | inner:top:outer:bottom = 2:3:4:6 | apply margin proportion rule |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| page-ratio | 2:3 (golden section approximation) | "Die neue Typographie" (1928) p.145 | S |
| margin-inner | 1/9 of total width | Tschichold golden section rule (Van de Graaf canon variant) | S |
| margin-top | 1/9 of total height | Tschichold margin proportion system | S |
| margin-outer | 2x inner (2/9 of total width) | Tschichold margin proportion system | S |
| margin-bottom | 2x top (2/9 of total height) | Tschichold margin proportion system | S |
| text-area-ratio | about 44.4% of total area (based on 1/9 margins) | golden section calculated value | A |
| asymmetric-axis | 1/3 left of center (early work) | "Die neue Typographie" layout analysis | A |
| penguin-grid | 4 horizontal divisions + 3 columns | Penguin Composition Rules (1947) | S |
| penguin-margin | uniform 3/4 inch (19mm) on all sides | Penguin Composition Rules | S |
| grid-base-ui | 4pt or 8pt (digital translation) | UI scaling of Tschichold proportion system | F |

### Typography

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| font-family-early | sans-serif only (Akzidenz-Grotesk, Futura) | "Die neue Typographie" (1928) manifesto | S |
| font-family-late | serifs allowed (Garamond, Bembo, Sabon) | Penguin Books typeface selection (1947-49) | S |
| font-sabon | Sabon (1967) — modernized Garamond | typeface designed directly by Tschichold | S |
| font-size-body | 10-12pt (print body text) | Penguin Composition Rules | S |
| font-size-ratio | heading:body = 1.5:1 ~ 2:1 | "Typographische Gestaltung" (1935) | A |
| line-height | 120-140% of body size (auto leading) | Penguin Composition Rules leading specification | S |
| line-length | 60-70 characters/line (English basis) | Tschichold readability rule | S |
| letter-spacing-caps | +5-10% tracking expansion for uppercase setting | "Die neue Typographie" uppercase rule | S |
| text-align-early | left aligned (flush left, ragged right) | "Die neue Typographie" asymmetry principle | S |
| text-align-late | justified allowed | Penguin Books body text setting | S |
| orphan-widow | minimum 2 lines (orphans/widows forbidden) | Penguin Composition Rules | S |
| font-size-ui | 14-16pt (body), 21-24pt (heading) | UI translation of proportion system | F |

### Color & Surface

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| palette-early | black/white/red 3-color system | "Die neue Typographie" poster analysis | S |
| red-accent | red = accent only (10-20% area) | Tschichold early poster color analysis | A |
| penguin-orange | approx #FF6600 (Penguin orange) | Penguin Books cover color (1935-) | A |
| penguin-color-code | orange=fiction, green=crime, blue=biography | Penguin Books genre color system | S |
| background | pure white (#FFFFFF) — print default | print typography tradition | A |
| color-count | 2-3 colors/page (black + 1-2 accents) | Tschichold color restraint principle | A |
| contrast-ratio | minimum 10:1 (black type on white paper print) | print typography readability standard | A |
| surface | matte paper texture, digital is solid flat | based on Tschichold's print medium | D |

### Form & Curvature

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| corner-radius | 0px (right angles) | Tschichold geometric form principle | A |
| rule-weight | 0.5-2pt horizontal/vertical lines | Tschichold print rule analysis | A |
| form-vocabulary | line, rectangle, circle — 3 types | "Die neue Typographie" geometry principle | S |
| diagonal-use | diagonal = eye guidance (early work 30%+) | Tschichold early poster composition analysis | A |
| border | none or 0.5pt hairline | Penguin Books divider line analysis | A |
| penguin-frame | triple frame (outer line-gap-inner line) | Penguin Books cover design (1947-49) | S |
| icon-style | minimized use — replaced by typography | Tschichold text-first principle | A |

### Interaction & Motion

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| transition-duration | 0.2-0.3s (calm transitions) | UI interpretation of print-based static philosophy | F |
| animation | none — text-centric static layout | based on Tschichold's print medium | D |
| page-turn | page transition = simple cut or slide | digital translation of book page turning | F |
| reading-flow | left→right, top→bottom natural flow observed | Tschichold readability principle | S |
| scroll-behavior | smooth continuous scroll (book scroll analogy) | digital translation of print text | F |

## Changes by Era

| Period | Turning point | Key numeric changes |
|------|--------|---------------|
| 1925-1933 | New Typography period | asymmetry 100%, sans-serif only, red/black 2 colors, diagonal use |
| 1933-1946 | Nazi persecution → exile to Switzerland | start of return to traditional typography, serifs reintroduced |
| 1947-1949 | Penguin Books overhaul | 500+ covers standardized, grid system established, justified alignment adopted |
| 1950-1967 | classicism maturity + Sabon design | strict adherence to golden section ratio, performed typeface design directly |
| 1967-1974 | late years — synthesis of principles | attempt to integrate early avant-garde and late classicism |

## Influence Relationships

- **Bauhaus → Tschichold**: constructivist typography of Moholy-Nagy and El Lissitzky
- **Tschichold → Swiss typography**: Müller-Brockmann and Emil Ruder inherited New Typography
- **Tschichold → Penguin Books**: prototype of the standard for mass-publishing typography
- **Tschichold → Robert Bringhurst**: Tschichold's proportion system cited in "Elements of Typographic Style"
- **Tschichold → web typography**: leading/tracking/line-length rules form the basis of CSS typography guidelines
- **Main references**: "Die neue Typographie" (1928), "Typographische Gestaltung" (1935), "The Form of the Book" (1975)

## UI Application Mapping

| Tschichold principle | Modern UI token translation rule |
|----------------|----------------------|
| Asymmetric layout | `text-align: left`, left-aligned by default, only headings centered |
| Golden section margins | padding ratio `inner:top:outer:bottom = 2:3:4:6` |
| 60-70 character line length | `max-width: 65ch`, `line-height: 1.4` |
| 2-3 color limit | 3 CSS variables — `--text`, `--bg`, `--accent` |
| 2-typeface system | `font-family` 1 sans-serif + 1 serif (or sans-serif alone) |
| Orphans/widows forbidden | `orphans: 2; widows: 2` |
| Geometric form | `border-radius: 0`, line/right-angle based |
| Hierarchical size contrast | heading `1.5-2em`, body `1em`, caption `0.875em` |
| Color = function | red/accent = CTA/warning, black = body, gray = secondary |
| Static reading experience | 0 animations in content area, `content-visibility: auto` |
