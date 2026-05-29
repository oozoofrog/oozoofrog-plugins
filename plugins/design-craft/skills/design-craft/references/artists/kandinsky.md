# Wassily Kandinsky -- Visual Language Design Tokens

## Profile
- **Active period**: 1896-1944 (abstract turn: 1910-1944)
- **Movement/school**: Der Blaue Reiter, Bauhaus, Abstract Composition
- **Core contribution**: In the 1926 treatise "Point and Line to Plane (Punkt und Linie zu Fläche)," established a systematic grammar of visual elements. Quantified the triangular color-form-emotion correspondence theory (triangle=yellow, circle=blue, square=red). The first system to explain abstract art through musical compositional principles.

## Visual Language Principles

1. **Inner Necessity**: Every form and color choice must be a necessary expression of inner emotion. Meaning, not decoration, determines form. In UI, this is the principle that "every visual element must have a functional reason."
2. **Color-Form Correspondence**: Yellow is the triangle (sharpness, advancing), blue is the circle (receding, depth), red is the square (stability, weight). Synergy arises only when color and form match emotionally.
3. **Musical Composition**: Compose painting like music. Repetition (rhythm), contrast (harmony), thematic development (melody). This is why Kandinsky's works are titled "Composition" and "Improvisation." The basis for visual rhythm and hierarchy in UI.
4. **Temperature & Weight**: Yellow is warm and light; blue is cold and heavy; red is warm and heavy. Color carries physical properties. The principle for tuning visual weight through color in UI.
5. **Tension & Release**: The diagonal is tension, the horizontal is release, the vertical is ascent. The direction of a line determines emotion. The principle for tuning layout dynamism in UI.
6. **Total Composition**: The whole relationship, not individual elements, determines the work. No element is judged in isolation; each is evaluated in the context of the whole. The principle of prioritizing the harmony of the whole page over individual components in UI.
7. **Point Energy**: The point is "the most concise form" and carries inner tension. Its energy varies with size, position, and surrounding relationships. The aesthetic basis for dot indicators, bullets, and notification badges in UI.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| kandinsky-yellow | #F0C800 ~ #FFD700 | Composition VIII (1923) colorimetry | B | Warning, emphasis, advancing elements, CTA background |
| kandinsky-blue-deep | #1A237E ~ #283593 | Several Circles (1926) background colorimetry | B | Deep background, dark mode, immersive areas |
| kandinsky-blue-light | #42A5F5 ~ #64B5F6 | Composition VIII circular elements | C | Informational elements, links, secondary actions |
| kandinsky-red | #C62828 ~ #E53935 | Composition VIII triangle/square elements | B | Primary actions, warnings, weighty elements |
| kandinsky-black | #1A1A1A ~ #212121 | Lines and form outlines across all works | B | Text, icons, structural lines |
| kandinsky-violet | #6A1B9A ~ #8E24AA | Several Circles (1926) | C | Premium, creative areas, secondary emphasis |
| kandinsky-orange | #E65100 ~ #F57C00 | Composition VIII triangular areas | C | Secondary CTA, hover state, active indicator |
| kandinsky-green | #2E7D32 ~ #43A047 | Several Circles (1926) circular elements | C | Success, completion, positive feedback |
| kandinsky-bg-warm | #FFF8E1 ~ #FFFDE7 | Estimated Bauhaus-period background color | D | Light-mode warm background |
| kandinsky-bg-dark | #0D1B2A ~ #1B2838 | Based on Several Circles background | B | Dark-mode deep background |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| element-count | 10-50+ elements per composition | Composition VII-X statistics | B | Complex dashboards, multi-element screens allowed |
| focal-point-count | 2-4 primary focal points | Composition VIII gaze-tracking analysis | C | Max number of primary CTA/info points |
| grid-freedom | Irregular — free placement without a grid | Structural analysis of all works | B | position: absolute-based free layout |
| diagonal-axis | Primary composition axis 30-60° diagonal | Composition VIII axis analysis | C | Diagonal direction for gaze guidance |
| layer-depth | 3-7 overlapping layers | Composition series layer analysis | C | Number of z-index levels, layer structure |

### Proportion & Balance
| Token | Value/Range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| triangle-aspect | Equilateral triangle base, height:base = 0.87:1 | Point and Line to Plane treatise (1926) | B | Default ratio for triangular UI elements (arrows, direction) |
| circle-prominence | Circle elements occupy 20-40% of the whole | Several Circles (1926) measurement | B | Upper limit on circular component usage frequency |
| size-range | max:min = 10:1 ~ 30:1 | Composition VIII size distribution | C | Dramatic size differences in visual hierarchy allowed |
| color-form-map | triangle=yellow, circle=blue, square=red | Point and Line to Plane treatise (1926) p.73-78 | B | Emotional pairing principle of form and color |
| weight-balance | Visual weight balanced within ±15% of center | Composition VIII center-of-weight analysis | C | Visual center of weight near screen center |

### Space & Whitespace
| Token | Value/Range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| breathing-room | Minimum 5% whitespace around primary elements | Composition VIII element spacing | C | Minimum component margin |
| density-zones | High-density (cluster) + low-density (rest) zones coexist | Density analysis of all works | B | Information-density variation — clustered areas alternate with rest areas |
| edge-proximity | Primary elements 5-15% inward from the edge | Edge analysis of all works | C | safe area padding |
| void-purpose | Empty space defines the relationships between elements | Point and Line to Plane treatise | B | Whitespace as a visual tool for grouping/separation |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| line-types | 4 types: straight, curved, angular, free curve | Point and Line to Plane treatise (1926) | B | Classification of divider/path/arrow styles |
| tension-direction | horizontal=cold, vertical=warm, diagonal=tension | Point and Line to Plane treatise | B | Selecting the emotional property of layout axes |
| concentric-rhythm | Concentric circles repeated 2-7 rings | Several Circles (1926) measurement | B | Radial menus, concentric-circle charts, radar charts |
| polyphonic-layering | 3-5 independent visual "voices" proceeding simultaneously | Composition VII (1913) analysis | C | Multiple information layers shown simultaneously (map + markers + paths) |
| geometric-vocabulary | 5 forms: point, line, triangle, circle, square | Entire Point and Line to Plane treatise | B | Limit the UI form vocabulary to 5 forms |

## Major Work Analysis

### 1. Composition VIII (1923)
- **Canvas**: 140 x 201cm (landscape)
- **Collection**: Solomon R. Guggenheim Museum, New York
- **Composition**: A masterwork of the Bauhaus period. Two large circles at upper left (concentric, black outer ring + violet interior), a checkerboard-pattern triangle on the right, and straight and curved lines at various angles crossing throughout. About 30-40 individual form elements.
- **Color distribution**: background = bright yellow-cream (~60%), black lines/forms (~15%), blue/violet circles (~10%), red/orange triangles/squares (~10%), other (~5%)
- **Hierarchy**: The large circle at upper left (diameter about 20% of canvas height) is the primary focal point. The cluster of triangles at upper right is the secondary focal point. A diagonal connects the two focal points.
- **UI translation**: The compositional principle for a complex dashboard. 2-3 primary widgets (large charts) + many small indicators + connecting lines (showing relationships). Specify primary regions with `grid-template-areas` and freely place the rest.

### 2. Several Circles (1926)
- **Canvas**: 140.3 x 140.7cm (nearly square)
- **Collection**: Solomon R. Guggenheim Museum, New York
- **Composition**: About 20-25 circles of varying size distributed over a deep navy background. A large circle at upper left (black outer ring + interior concentric circles), the rest small to medium. The circles partially overlap.
- **Color**: background = deep navy (#0D1B2A), circles = black, blue, violet, red, orange, yellow, green — multicolor. The large circle has 3-4 concentric rings. Circles of differing transparency overlap to produce blended colors.
- **Size distribution**: largest circle diameter = ~30% of canvas, smallest circle = ~2%. Size ratio about 15:1. Most are small to medium (5-10%).
- **UI translation**: Bubble charts, tag clouds, skill-map visualizations for a dark-mode dashboard. Circle size = importance, color = category, overlap = relevance. Use `mix-blend-mode: screen` for the color-blending effect in overlap areas.

### 3. Composition VII (1913)
- **Canvas**: 200 x 300cm (large landscape)
- **Collection**: Tretyakov Gallery, Moscow
- **Composition**: The most complex composition among all of Kandinsky's works. Over 50 form elements distributed across the entire canvas. A swirling-form nucleus sits at the center, with energy radiating outward from it. Lines, circles, triangles, and free forms overlap in multiple layers.
- **Density**: 60% of the elements concentrate in the high-density center (30% of the canvas). The edges are relatively open.
- **Musical correspondence**: Called a "visual symphony." A polyphonic structure in which multiple independent visual themes proceed simultaneously.
- **UI translation**: The compositional principle for complex data visualization. Guide attention through density variation, and design the gaze flow from periphery to center. Density control per zoom level in a map-based interface.

## UI Application Mapping

### Translation Rules

1. **Color-form pairing**: Translate Kandinsky's correspondence theory into UI semantics.
   ```
   triangle(yellow) → warning/caution icons, direction indicators
   circle(blue)     → information, avatars, status indicators
   square(red)      → primary action buttons, emphasis cards
   ```

2. **Density-variation design**: Do not apply uniform density to the screen. Deliberately alternate high-density areas where key information clusters with low-density areas of visual rest.
   ```css
   .dense-zone { gap: 8px; padding: 16px; }
   .rest-zone  { gap: 32px; padding: 64px; }
   ```

3. **Multi-layer composition**: Do not place elements on a single plane; compose with 3-5 layers. Background, supporting structure, primary content, interactive elements, overlay.
   ```css
   .layer-bg     { z-index: 0; opacity: 0.3; }
   .layer-struct { z-index: 1; opacity: 0.6; }
   .layer-main   { z-index: 2; opacity: 1.0; }
   .layer-action { z-index: 3; }
   ```

4. **Emotional use of lines**: Apply Kandinsky's line theory to dividers, paths, and arrows.
   - horizontal → calm separation (section division)
   - vertical → sense of ascent (sidebar, timeline)
   - diagonal → dynamism (progress, trend)
   - curve → organic connection (relationship lines, flow charts)

5. **Concentric-circle pattern**: Express depth and hierarchy with overlapping circles. Suited to radial menus, radar charts, and circular progress.

6. **Polyphonic information**: Display multiple information layers simultaneously, giving each its own independent visual rhythm. Map + markers + paths + labels coexist while each retains its own style.

### Suitable UI Types
- **Data visualization**: bubble charts, network graphs, radar charts, multi-layer maps
- **Complex dashboards**: multi-element screens where widgets of various sizes coexist
- **Creative tools**: drawing, presentation, mind-map editors
- **Music/audio apps**: interfaces where visual rhythm matters, equalizers, visualizers
- **Education platforms**: concept relationship diagrams, learning-path visualizations, interactive diagrams
- **Portfolios**: gallery layouts composed of varied forms and colors

### Cautions
- **No disorder or confusion**: Kandinsky's complex compositions are not random. Every element is part of the whole "symphony." Listing elements without intent is not aesthetics but chaos.
- **Beware color-form mismatch**: Placing blue on a triangle or yellow on a circle produces visual dissonance. Unless the dissonance is intentional, follow the correspondence theory.
- **Guard against density overload**: Composition VII-level complexity is exceptional. For most UI, take the Several Circles level (20-25 elements) as the upper limit.
- **No line overuse**: Structural lines must carry visual meaning. Decorative lines violate the "Inner Necessity" principle.
- **Unsuitable for monochrome UI**: Kandinsky's aesthetic is fundamentally multicolor. It is unsuited to black-and-white or monochrome interfaces. Use at least 3-4 colors.
- **Avoid static placement**: Putting every element into an aligned grid removes the Kandinsky-like dynamism. Deliberately place some elements off the grid.
- **Mind small screens**: Multi-element compositions can be confusing on mobile. On mobile, prefer the Several Circles style (simple circle-based), and limit complex Compositions to tablet/desktop.
