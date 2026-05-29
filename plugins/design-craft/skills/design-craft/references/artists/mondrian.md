# Piet Mondrian -- Visual Language Design Tokens

## Profile
- **Active period**: 1892-1944 (peak creative period: 1911-1944)
- **Movement/school**: De Stijl (Neoplasticism)
- **Core contribution**: Reduced painting to vertical lines, horizontal lines, three primary colors, and achromatic tones, establishing a visual grammar of universal harmony. The first pure abstract system to directly influence architecture, design, and typography.

## Visual Language Principles

1. **Orthogonal Order**: Compose every structure using only verticals and horizontals. Exclude diagonals and curves to achieve maximum clarity. The philosophical archetype of CSS Grid and Flexbox in UI.
2. **Asymmetric Equilibrium**: Balance is struck not by left-right symmetry but by mutual compensation of area, color, and position. A large white plane and a small red plane carry equal visual weight. A color's visual weight is inversely proportional to its area.
3. **Primary Purity**: Use only red, blue, yellow + black, white, gray. Mixed colors compromise purity. Consistent with the semantic color palette principle of UI design systems.
4. **Plane Independence**: Each color plane is an independent unit, and lines (grid lines) partition the planes. Illustrates the relationship between the independence of UI components and the grid system.
5. **Dynamic Repose**: Though the composition is static, asymmetry causes the gaze to circulate. A layout principle that intentionally guides the user's eye flow.
6. **Reductive Purity**: Reduce nature's complex forms to vertical-horizontal relationships. Mondrian asserted that "nature is curved, but art must be straight". The principle of removing ornament and leaving only structure in UI.
7. **Universal Harmony**: Pursue universal proportional relationships rather than personal taste. The De Stijl manifesto (1918) aimed at "universality beyond individuality". Directly corresponds to the consistency principle of design systems.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| mondrian-red | #CC2200 ~ #E63929 | Composition II (1930) digital colorimetry | B | Primary action, CTA buttons, alert emphasis |
| mondrian-blue | #1B3B8C ~ #2040A0 | Composition with Red, Blue, and Yellow (1930) | B | Informational elements, links, selected state |
| mondrian-yellow | #F2D516 ~ #FFE135 | Composition with Large Red Plane (1921) | B | Highlights, badges, notification points |
| mondrian-black | #0A0A0A ~ #1A1A1A | Consistent grid lines across all works | B | Grid lines, borders, dividers |
| mondrian-white | #F5F5F0 ~ #FAFAF5 | Background planes across all works (off-white, not pure white) | B | Background, card planes, whitespace |
| mondrian-gray | #B0B0AA ~ #C8C8C0 | Gray planes in some late works | C | Disabled state, secondary background |
| mondrian-warm-white | #FAF0E6 ~ #FFF8DC | Composition A (1920) background plane | F | Warm background variant, warm-toned cards |
| color-usage-density | only 15-30% of total area is chromatic | area statistics of 10 major works | C | Upper-limit guideline for chromatic color usage ratio |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| grid-line-weight | 3-8px (0.5-1.2% relative to canvas) | Composition series measurements | B | Grid dividers, border thickness |
| grid-cell-min | 5-8% of canvas | Composition II (1930) | B | Minimum component size |
| grid-cell-max | 40-55% of canvas | Composition with Large Red Plane (1921) | B | Hero region, main content ratio |
| grid-columns | 2-5 unequal divisions | statistics across all works | C | CSS Grid non-uniform column setup |
| grid-rows | 2-4 unequal divisions | statistics across all works | C | CSS Grid non-uniform row setup |

### Proportion & Balance
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| dominant-plane-ratio | 35-55% of total | Composition series area analysis | B | Main content region ratio |
| accent-plane-ratio | 3-12% of total | color plane area measurement | B | CTA/emphasis element size ratio |
| color-to-white-ratio | color planes 15-35% : white planes 65-85% | statistics of 8 major works | B | Color usage density, whitespace ratio |
| asymmetry-offset | 10-25% bias from center | composition center analysis | C | Offset value for asymmetric layouts |

### Space & Whitespace
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| white-plane-dominance | 50-70% of total | white plane ratio across all works | B | Blank ratio for whitespace-centered layouts |
| edge-margin | 0-3% from canvas edge to first line | measurement | B | Container outer margin (minimal or 0) |
| inter-cell-gap | equal to line thickness (3-8px) | grid structure analysis | B | Grid gap, spacing between components |
| canvas-to-frame | lines extend to the canvas edge | all works (lines are not clipped) | B | Grid lines reach the viewport edges, overflow allowed |
| negative-space-cluster | 2-3 white planes adjoin to form a large whitespace | Composition series | C | Intentionally cluster whitespace regions to secure visual rest space |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| rhythm-regularity | aperiodic rhythm | spacing analysis across all works | C | Set grid track sizes unevenly |
| boogie-pulse-size | 8-12px square repeating unit | Broadway Boogie Woogie (1942) measurement | B | Icon size, micro-interaction unit |
| boogie-color-alternation | red-yellow-blue-gray 4-color alternating pattern | Broadway Boogie Woogie (1942) | B | Color cycling for status badges, step indicators |
| boogie-grid-density | 15-20 lines/axis | Broadway Boogie Woogie (1942) | B | High-density dashboard grid composition |
| line-continuity | lines run from one canvas edge straight through to the opposite edge | Composition series | B | Grid lines traverse the viewport completely, partial lines forbidden |
| intersection-emphasis | no thickness change at line intersections (constant) | grid intersections across all works | B | Keep constant thickness at grid intersections with no special ornament |

## Key Work Analysis

### 1. Composition with Red, Blue, and Yellow (1930)
- **Canvas**: roughly 46 x 46cm square
- **Collection**: Kunsthaus Zurich
- **Composition**: 2 vertical lines and 2 horizontal lines create 9 regions. Large red plane in the upper right (~40% of total), small blue plane in the lower left (~5%), small yellow plane in the lower right (~3%)
- **Proportion analysis**: vertical line positions = 25%, 75% from the left / horizontal line positions = 30%, 80% from the top
- **Color plane contrast**: red area is 8x the blue and 13x the yellow → visual weight balanced by inverse proportion of area
- **Visual weight formula**: red(40% x high saturation) ≈ blue(5% x medium saturation + receding-color correction) + yellow(3% x advancing-color correction) + lightness of the white plane
- **UI conversion**: `grid-template-columns: 1fr 2fr; grid-template-rows: 1.4fr 2.5fr 1fr;` unequal grid. Place main content in the upper-right 40% region and secondary actions in the small lower-left region.

### 2. Broadway Boogie Woogie (1942-43)
- **Canvas**: 127 x 127cm square
- **Collection**: Museum of Modern Art, New York
- **Composition**: color-plane blocks form the grid instead of black lines. About 16 vertical lines, 14 horizontal lines. The black grid lines of early works are replaced by sequences of color blocks — the lines themselves become rhythmic elements.
- **Rhythm pattern**: yellow-red-blue-gray blocks alternate at irregular intervals. Enlarged color blocks placed at intersections. Unit block size about 8-12px (relative to canvas). Aperiodic interval repetition like the syncopation of jazz.
- **Urban grid mapping**: a visual translation of the Manhattan street grid. Intersections = emphasis nodes. The hierarchical difference between Avenue (vertical) and Street (horizontal) is reflected in differences of line thickness and block size.
- **Color distribution**: yellow ~45%, red ~25%, blue ~15%, gray ~15% (based on blocks within the grid lines)
- **UI conversion**: repeating tile patterns in dashboards, color indicators in navigation bars, heatmap structures in data visualization. Especially suited to progress bars, step indicators, and timeline visualizations.

### 3. Composition II in Red, Blue, and Yellow (1930)
- **Canvas**: roughly 51 x 51cm
- **Collection**: Kunsthaus Zurich
- **Composition**: a large red plane occupying the left 2/3 dominates. Narrow white, blue, and yellow strips stacked vertically on the right
- **Proportion**: main division line = at the 66% point of the canvas width (a 2:1 ratio, not a golden-ratio approximation). Horizontal division line = at about the 75% point from the top
- **Extreme asymmetry**: the red plane occupies ~50% of the total while the remaining 5 regions share the other 50%. The work showing the most dramatic area contrast
- **UI conversion**: sidebar (1/3) + main content (2/3) layout pattern. Or on mobile, top hero (2/3) + bottom action bar (1/3) composition

## UI Application Mapping

### Conversion Rules

1. **Grid system**: set unequal tracks with `display: grid`. Apply asymmetric ratios in fr units to `grid-template-columns` and `grid-template-rows`.
   ```css
   .mondrian-layout {
     display: grid;
     grid-template-columns: 1fr 2.5fr 0.8fr;
     grid-template-rows: 1fr 3fr 1.2fr;
     gap: 4px;
     background: #1A1A1A; /* gap acts as the lines */
   }
   .mondrian-layout > * {
     background: #FAFAF5; /* default white plane */
   }
   ```

2. **Color assignment**: map to semantic colors.
   - mondrian-red → destructive/primary-action (CTA buttons, important alerts)
   - mondrian-blue → informational/link (links, selected state, navigation)
   - mondrian-yellow → warning/highlight (badges, notification dots, new-item markers)
   - Use chromatic color in only 15-25% of the total area. The rest is white planes and black lines.

3. **Border system**: all dividers are mondrian-black, 3-8px solid lines. No radius (only right angles allowed). `border: 4px solid #1A1A1A;`. Lines can also be simulated with CSS Grid `gap` + the parent `background-color`.

4. **Whitespace strategy**: large white planes are "intentional blank space" that permit content-free regions. Suppress the urge to fill every region. Empty grid cells are a core element of the layout.

5. **Component independence**: the component in each grid cell functions independently. Minimize dependencies between cells. A change in one cell does not affect another.

6. **Typography**: use only sans-serif typefaces. The De Stijl movement preferred geometric sans-serifs such as Futura and Gill Sans. Text alignment is left-aligned by default; center alignment is allowed but justified alignment is forbidden.

7. **Color plane placement strategy**: place color planes at corners or edges. An isolated color plane in the center of the canvas almost never appears in Mondrian's work. This is the rationale for placing CTAs at the corners or edges of the screen in UI.

### Suitable UI Types
- **Dashboards**: place KPI cards in an unequal grid, combine large charts + small metrics
- **Portfolio/gallery**: asymmetric image grid, an orderly variant of the masonry layout
- **Landing pages**: hero region (large plane) + secondary info (small planes) composition
- **Design tools**: canvas-based interfaces, grid overlay systems
- **Minimal brand sites**: whitespace-centered, strong structural grid

### Cautions
- **No excessive color planes**: if color planes exceed 35% of the total, the Mondrian aesthetic is destroyed. Maintain the white-plane-dominant principle.
- **No rounded corners**: `border-radius` directly violates De Stijl principles. When applying this style, keep all corners at right angles.
- **Exclude diagonal/curved elements**: do not use slanted text, circular avatars, wavy dividers, etc.
- **Avoid equal divisions**: an equal grid like `1fr 1fr 1fr` is not Mondrian-like. Always use unequal ratios.
- **Restrain shadow effects**: shadows (box-shadow) harm the flatness of the planes. Express depth only through color contrast.
- **Beware overcrowding**: except for the Broadway Boogie Woogie style, limit the cell count to 9 or fewer. Too many divisions cause confusion.
- **No gradients**: Mondrian's color planes are flat and homogeneous. Gradients, textures, and patterns inside a color plane harm purity.
- **Minimize icons/illustrations**: figurative imagery compromises the purity of abstract composition. If icons must be used, limit them to simple geometric forms.

## De Stijl Mathematical Principles Reference

Mathematical principles shared by Mondrian and the De Stijl group (Theo van Doesburg, Gerrit Rietveld):

- **Dynamic Equilibrium**: symmetry is a static, dead balance. Only the dynamic balance of asymmetry holds vitality. Van Doesburg called this "counterpoint composition".
- **Universality of the right angle**: the right angle is the most fundamental structural relationship, arising in nature from the relationship between gravity (vertical) and the horizontal plane.
- **Proportional relationships**: Mondrian deliberately avoided using the golden ratio. Instead, intuitively determined ratios are unique to each work. In a design system this means "freedom within rules" — fix the grid but let the division ratios be determined fluidly according to content.
- **Rietveld Schroder House (1924)**: an architectural realization of De Stijl principles. Interior walls were made reconfigurable with sliding panels → a physical precedent for responsive layouts.
