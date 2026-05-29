# Susan Kare -- Design Token Dictionary

## Profile
- **Active period**: 1982-present, core period 1982-1986 (Apple Macintosh), 2015-present (Pinterest)
- **Main affiliations**: Apple Computer (1982-1986), NeXT (1986-1989), Microsoft (Windows 3.0 card games), Pinterest Creative Director
- **Key contributions**: Macintosh system icons (Happy Mac, Command, bomb, trash), Chicago font, Geneva/Monaco fonts, Windows Solitaire cards, established the pixel-art icon system
- **Design lineage**: mosaic/embroidery techniques → 32×32 bitmap grid → mother of modern icon design

## Design Philosophy (Quantifiable Principles)

| Principle | Quantitative Translation | UI Metric |
|------|----------|----------|
| Grid constraint = creativity | Expression within 32×32 = 1024 pixels | Recognizable at minimum resolution |
| 1-bit clarity | 100% meaning conveyed in 2 colors, black/white | Monochrome icon recognition rate 95%+ |
| Metaphor first | 80%+ icons have real-world counterparts | Minimize user learning time |
| Human warmth | Include curved/organic forms | Friendly, not cold impression |
| Universal recognition | Culture-independent symbols | Global recognition rate 90%+ |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| icon-grid-large | 32×32 px (standard icon) | Macintosh System 1.0 icon spec (1984) | S |
| icon-grid-small | 16×16 px (menu/cursor) | Macintosh menu icon/cursor spec | S |
| icon-padding | 1-2px margin at grid edge | Macintosh icon measurement — avoid edge touch | A |
| icon-centering | Visual center alignment (not mathematical center) | Kare icon placement analysis — visual correction applied | A |
| cursor-hotspot | Top-left vertex (1,1) | Macintosh arrow cursor hotspot position | S |
| desktop-icon-spacing | 80px horizontal, 64px vertical spacing | Macintosh Finder icon grid (System 1-6) | A |
| bit-depth | 1-bit (black/white, 2 values) | Macintosh 128K hardware constraint | S |
| screen-resolution | 512×342 px, 72dpi | Macintosh 128K monitor spec | S |
| grid-base-ui | 4pt (low-resolution digital conversion) | 16px-based ×4 multiple system | F |

### Typography

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| font-chicago | Chicago — bitmap, 12pt default | Macintosh system font (1984) — designed by Kare | S |
| font-geneva | Geneva — bitmap, sans-serif, 9-12pt | Macintosh secondary font — designed by Kare | S |
| font-monaco | Monaco — bitmap, monospace, 9pt | Macintosh monospace font — designed by Kare | S |
| pixel-grid-font | Glyph = manually placed on pixel grid | Kare bitmap font production method | S |
| chicago-x-height | 7px (at 12pt) | Chicago font measurement | A |
| chicago-cap-height | 9px (at 12pt) | Chicago font measurement | A |
| chicago-weight | Medium close to Bold (1-bit legibility) | Chicago stroke thickness — low-resolution correction | A |
| line-height | Glyph height + 3-4px leading | Macintosh system text leading | A |
| font-size-ui | 12-14pt (system default) | Macintosh text size at 72dpi | S |

### Color & Surface

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| palette-1bit | #000000 (black), #FFFFFF (white) — 2 colors | Macintosh 128K 1-bit display | S |
| dither-pattern | 50% checkerboard = gray simulation | Macintosh 1-bit gray rendering technique | S |
| pattern-library | 38 base patterns (stripes, dots, grids, etc.) | Macintosh System pattern palette — designed by Kare | S |
| highlight-color | Invert — black↔white toggle | Macintosh selection state representation | S |
| background | #FFFFFF (pure white desktop) | Macintosh Finder default background | S |
| contrast-ratio | 21:1 (pure black/pure white — maximum contrast) | 1-bit display physical constraint | S |
| surface-texture | Texture simulation via bitmap patterns | Kare pattern system | S |

### Form & Curvature

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| pixel-perfect | Every form = integer pixel coordinates | 1-bit bitmap grid constraint | S |
| corner-radius | Stepped approximation (1px steps) — true curves impossible | Circle approximation analysis on 32×32 grid | S |
| circle-approx | Circle recognizable at diameter ≥ 8px | Kare circular icon measurement (Happy Mac face) | A |
| line-weight | 1px (minimum unit) — 2px = thick line | 1-bit bitmap line thickness constraint | S |
| icon-metaphor | Simplification of real-world objects (trash, folder, clock) | Macintosh icon metaphor analysis | S |
| happy-mac-face | 12×8px face area (within 32×32) | Happy Mac icon measurement | A |
| command-symbol | 4 connected loops — borrowed from Swedish tourist signage | ⌘ Command key symbol (found by Kare) | S |
| trash-icon | 32×32, 2-tier structure (lid + bin) | Macintosh trash icon measurement | S |
| form-warmth | Organic curves 40%+ (straight lines only 60%) | Kare icon form analysis — avoid mechanical coldness | A |

### Interaction & Motion

| Token | Value/Range | Source | Confidence |
|--------|---------|------|--------|
| click-feedback | Icon Invert — instant | Macintosh icon click feedback | S |
| drag-feedback | Only icon outline shown moving | Macintosh Finder drag representation | S |
| cursor-blink | Insertion point blink 530ms on/530ms off | Macintosh text cursor timing | A |
| menu-highlight | Invert (black background + white text) — instant switch | Macintosh menu highlight | S |
| animation-frame | 2-4 frames (clock icon = 4-frame rotation) | Macintosh system animation analysis | S |
| watch-cursor | 4-frame rotation loop, 0.5s per frame | Macintosh wait cursor (wristwatch) | A |
| transition | None — instant switch (hardware constraint) | Macintosh 128K processing speed | S |
| feedback-timing | ≤ 50ms (invert feedback) | Macintosh click response time measurement | A |

## Evolution by Era

| Era | Turning Point | Key Numeric Changes |
|------|--------|---------------|
| 1982-1984 | Early Macintosh development | 32×32 1-bit, Chicago font, designed 50+ core icons |
| 1984-1986 | Post-launch expansion of Macintosh | Pattern library of 38 types, complete cursor set |
| 1986-1989 | Move to NeXT | Introduced high-resolution grayscale icons, 48×48 grid |
| 1990-2010 | Freelance / various clients | Color icons, vector transition, resolution independence |
| 2015-present | Pinterest + art practice | Extended pixel art into fine art, large-canvas work |

## Influence Relationships

- **Mosaic/embroidery/pointillism → Kare**: tradition of grid-based image making
- **Kare → macOS/iOS icons**: metaphor-based icon design DNA (folder, trash, document)
- **Kare → Windows**: Solitaire card design, Windows 3.0 icon system
- **Kare → emoji**: 32×32 bitmap expression technique influenced early emoji design
- **Kare → pixel art genre**: proved the aesthetic value of constraint-based design
- **Key references**: "Susan Kare Icons" (MOMA collection), Andy Hertzfeld "Revolution in the Valley" (2004)

## UI Application Mapping

| Kare Principle | Modern UI Token Translation Rule |
|----------|----------------------|
| 32×32 grid | Based on SF Symbols — Small(20pt), Medium(25pt), Large(30pt) |
| 1-bit clarity | Icon = recognizable even in single color, use `currentColor` |
| Metaphor-based | Icon = real-world counterpart, `accessibility-label` required |
| Pixel perfect | `image-rendering: pixelated` (retro), vector SVG for modern |
| Invert feedback | Selection state = invert background/foreground colors, `.tint(.accentColor)` |
| Pattern system | State differentiation = pattern (stripes = inactive, solid = active, dots = in progress) |
| Friendly form | Slightly round icon corners, `border-radius: 4-8px` |
| Visual correction | Use visual center, not mathematical center, when aligning icons |
| Constraint = creativity | Pursue maximum expressiveness within icon size constraints, design at `@1x` |
| Minimal animation | State transition = 2-4 frames, respect `prefers-reduced-motion` |
