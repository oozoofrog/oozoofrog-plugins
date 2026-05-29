# Conflict Report

Records conflicting token values between designers/painters within the same category.

## Resolution Strategy Legend
- **Superset compatibility**: a broader range subsumes a narrower one -> adopt the broader range
- **Context separation**: apply different values depending on use/context
- **Weighted average**: derive a midpoint via confidence weighting
- **variants**: irreconcilable -> coexist as separate variants

## Layout & Spacing

| Token | Designer A value | Designer B value | Resolution |
|------|------------|------------|----------|
| base-unit | Ive: 4pt, Kare: 4pt | Rams: 8pt, Vignelli: 8pt, Brockmann: 8pt | **Superset compatibility** -- adopt 4pt (8pt is a multiple of 4pt) |
| whitespace-ratio | Ive/Brockmann: 40-60% | Lee Ufan: 70-90% | **Context separation** -- standard UI: 40-60%, minimal/meditative UI: 70-90% |
| grid-columns | Brockmann: 2,3,4,6 columns | Vignelli: 2,3,6,12 columns | **Superset compatibility** -- adopt 12-column system (includes all divisions) |
| margin-ratio | Rams: 10-20% | Tschichold: inner:top:outer:bottom = 2:3:4:6 | **Context separation** -- app UI: uniform margins, reading/print: proportional margins |
| content-density | Rams: element density 20-30% | Kandinsky: allows 10-50+ elements | **Context separation** -- minimal UI: Rams, dashboard/data: Kandinsky |

## Typography

| Token | Designer A value | Designer B value | Resolution |
|------|------------|------------|----------|
| font-family-count | Brockmann: strictly 1 family | Vignelli: 2-3 families | **Context separation** -- utility UI: 1 family, editorial: 2-3 families |
| text-align | Brockmann/Tschichold (early): left-aligned only | Tschichold (late): justified allowed | **Context separation** -- UI body text: left-aligned, long-form reading: justified possible |
| text-transform | Vignelli: prefers uppercase | Rams/Brockmann: lowercase by default | **Context separation** -- signage/titles: uppercase, body/labels: lowercase |
| font-size-ratio | Tschichold: title:body = 1.5:1~2:1 | Rand: 2:1~3:1 (strong contrast) | **variants** -- moderate(1.5-2x), bold(2-3x) |
| body-size | Ive: 17pt (iOS) | Norman: 16px (web) | **Context separation** -- iOS: 17pt, Web: 16px |

## Color & Surface

| Token | Designer A value | Designer B value | Resolution |
|------|------------|------------|----------|
| gradient | Rams/Mondrian/Malevich: not used | Rothko: vertical gradient required | **Context separation** -- structural UI: flat solid color, immersive background: gradient |
| background-white | Ive: pure white #FFFFFF | Mondrian: off-white #F5F5F0, Lee Ufan: raw cloth #F5F0E8, Malevich: #F0EDE5 | **variants** -- pure-white(#FFF), warm-white(#F5F0E8), cream(#F0EDE5) |
| dark-bg | Ive/Dye: pure black #000000 (OLED) | Rothko: tinted darkness #1A1520 | **Context separation** -- OLED power saving: pure black, general dark mode: tinted darkness |
| accent-usage | Rams: 5% or less | Mondrian: 15-30% | Rand: 30-50% | **Context separation** -- minimal: 5%, standard: 15-30%, brand emphasis: 30-50% |
| color-count | Rams: 3 colors (black-white-accent1) | Kandinsky: at least 3-4 multi-color | **Context separation** -- tool/utility: 3 colors, creative/visualization: multi-color |
| shadow | Rams/Mondrian/Malevich: no box-shadow | Dye/Matas: express depth via shadow | **Context separation** -- flat structure: depth via color difference, physical layers: shadow allowed |
| surface-warmth | Turrell: color temperature varies by time of day | Ive: fixed semantic color | **Context separation** -- standard app: fixed semantic, meditation/wellness: time-adaptive |

## Shape & Geometry

| Token | Designer A value | Designer B value | Resolution |
|------|------------|------------|----------|
| corner-radius | Ive/Dye: 6-22pt continuous curvature | Rams/Vignelli/Mondrian: 0px right angle | **Context separation** -- Apple: continuous curvature, graphic: right angle. **Additional resolution**: convert corner-radius-large into per-platform `.ios`/`.web`/`.android` separated tokens |
| layout-symmetry | Rams: 95% left-right symmetry | Mondrian/Brockmann/Lee Ufan: asymmetry | **Context separation** -- product/tool: symmetry, art/editorial: asymmetry |
| grid-strictness | Brockmann/Vignelli: 100% grid alignment | Kandinsky/Malevich: free placement | **Context separation** -- informational UI: strict grid, creative/visualization: free placement |
| form-style | Kare: organic curves 40% (friendliness) | Malevich: organic curves 0% (pure geometry) | **Context separation** -- consumer app: Kare friendliness, art/minimal: Malevich pure geometry |
| diagonal-use | Kandinsky/Malevich: 15-45 degree tilt allowed | Mondrian: diagonals fully excluded | **Context separation** -- orthogonal UI: no diagonals, dynamic UI: diagonals allowed |

## Motion & Interaction

| Token | Designer A value | Designer B value | Resolution |
|------|------------|------------|----------|
| transition-duration | Rams: 0.15-0.25s (restrained) | Turrell: 2-5s (gradual) | **Context separation** -- functional transition: 0.15-0.35s, immersive/mode transition: 2-5s |
| easing | Rams: linear/ease-out | Ive/Matas: spring(damping 0.7-0.85) | **Context separation** -- minimal: ease-out, physical feedback: spring |
| animation-count | Rams: 1 concurrent per screen | Kandinsky: multi-layer parallel possible | **Context separation** -- tool UI: 1, visualization/creative: multi-layer allowed |
| scroll-behavior | Vignelli: page snap | Matas: inertial scroll + rubber-banding | **Context separation** -- presentation: snap, feed/content: inertial |
| hover-feedback | Rams: opacity 0.85 (subtle) | Rand: color inversion (dramatic) | **variants** -- subtle(opacity), bold(inversion) |
