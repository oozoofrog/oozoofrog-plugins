# Kazimir Malevich -- Visual Language Design Tokens

## Profile
- **Active period**: 1904-1935 (core Suprematist phase: 1915-1927)
- **Movement/school**: Suprematism (Супрематизм)
- **Key contribution**: Declared "the Suprematism of pure feeling" with Black Square in 1915. Reduced geometric forms (square, circle, cross) to the minimal unit of painting. Reached the extreme of abstraction by dissolving even form with White on White (1918). The philosophical origin point of minimal design.

## Visual Language Principles

1. **Pure Form**: Completely rejects the representation of nature and composes solely with geometric forms. The square is the most fundamental form. In UI, the rectangle of cards, buttons, and input fields is justified as the "archetypal form."
2. **Non-Objectivity**: Form points to no object. It exists in itself. This is the principle that a UI icon should be a "signal of function" rather than a "miniature of an object."
3. **Dynamic Floating**: Forms escape gravity and float across the canvas. Free placement rather than a fixed grid. In UI, this is the aesthetic basis for the FAB (Floating Action Button), draggable elements, and free-placement layouts.
4. **Hierarchical Geometry**: Large forms dominate small forms. Size is visual hierarchy. In UI, this corresponds directly to the principle of visual hierarchy.
5. **Absolute Simplicity**: Reduce until nothing more can be subtracted. White on White is the extreme of this principle. In UI, it is the most radical declaration of minimalism: "leave only the essential elements."
6. **Color-Plane Autonomy**: Each color plane carries independent energy. Red advances, blue recedes. In UI, this is the principle that color determines depth (z-index).
7. **Zero-Gravity Composition**: There is no up/down distinction. The work holds even when rotated. In responsive design, this is the principle that the composition must be preserved when switching between landscape and portrait.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| malevich-black | #0A0A0A ~ #1C1C1C | Black Square (1915) digital colorimetry (cracks excluded) | B | Highest emphasis, key CTA, text |
| malevich-white | #F0EDE5 ~ #FAF7F0 | White on White (1918) background plane | B | Background, cards, whitespace (off-white, not pure white) |
| malevich-white-warm | #F5F0E0 ~ #FFF8E8 | White on White (1918) tilted square plane | C | Surface-level distinction, card on card |
| malevich-red | #CC1A1A ~ #E62E2E | Red Square (1915) measured | B | Warning, urgent, primary destructive |
| malevich-yellow | #E8C800 ~ #FFD700 | Suprematist Composition (1916) colorimetry | C | Caution, highlight, badge |
| malevich-blue | #1A3A8B ~ #2850A8 | Suprematist Painting (1916) colorimetry | C | Info, link, selected state |
| malevich-green | #2A6B3A ~ #3D8B50 | Suprematist Composition (1916) | D | Success, completion, positive feedback |
| suprematist-bg | #E8E0D0 ~ #F0E8D8 | 0.10 exhibition background restored color | C | Gallery-style layout background |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| shape-count | 1-12 geometric forms per composition | Suprematist Composition series statistics | B | Max number of primary UI elements per screen |
| dominant-shape-size | 20-45% of canvas | Black Square, Red Square measured | B | Hero element, primary card size |
| satellite-shape-size | 2-8% of canvas | Suprematist Composition secondary elements | B | Secondary button, icon, badge size |
| rotation-angles | 0°, 15°, 30°, 45°, 60° | Rotation-angle statistics across all works | B | Element tilt (mainly decorative use) |
| overlap-frequency | 30-50% of forms overlap other forms | Suprematist Composition series | C | z-index layering, card overlap |
| center-offset | Primary form deviates 10-30% from center | Center analysis across all works | C | Deviation value for asymmetric layouts |

### Proportion & Balance
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| black-square-ratio | Square — 1:1 (actual slight asymmetry: 1:1.02) | Black Square (1915) Tretyakov Gallery measured | B | Reference ratio for square components |
| rectangle-ratio | long:short = 1.5:1 ~ 3:1 | Suprematist rectangle statistics | C | Card, banner, input field ratio |
| cross-ratio | width:height = 1:1 (equal cross), arm length:width = 4:1 ~ 6:1 | Suprematist Cross (1920) | C | Close button, add button form ratio |
| circle-to-square | Circle diameter = 70-100% of adjacent square's side | Suprematist Composition statistics | D | Size relation between circular avatar and square card |
| size-hierarchy | largest:smallest form = 5:1 ~ 15:1 | Multi-form composition measured | C | Minimum scale-factor difference for visual hierarchy |

### Space & Whitespace
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| white-ground-ratio | 50-80% of canvas | Background ratio across all works | B | Minimum whitespace ratio |
| shape-cluster-gap | 0-5% between forms (some overlap) | Suprematist Composition spacing analysis | C | Gap between related elements (small or overlapping) |
| shape-to-edge | 5-15% between form and canvas edge | Edge margin across all works | B | Screen edge safe area |
| float-space | Minimum free space around a form 3-8% | Per-form margin measured | C | Minimum margin around a component |
| white-on-white-gap | Minimum perceivable difference between two white planes = L*: 3-5 | White on White (1918) colorimetry | B | Minimum lightness difference between same-color surface levels |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| form-vocabulary | square, circle, cross, triangle (4 types) | Form inventory across all works | B | Basic UI shapes: card, avatar, close, direction indicator |
| scatter-pattern | irregular distribution, cluster + isolated forms mixed | Suprematist Composition distribution analysis | C | Bento grid, free-placement dashboard |
| diagonal-rhythm | forms arranged along a 15-45° diagonal axis | Suprematism (1915-16) measured | C | Diagonal gaze guidance, tilted card arrangement |
| scale-variation | 3-5 levels of size difference coexisting on the same screen | All works | B | Minimum number of size steps for visual hierarchy |
| achromatic-dominance | 60-80% of the work is achromatic (black/white/gray) | Color statistics across all works | B | Achromatic base + chromatic accent strategy |

## Representative Work Analysis

### 1. Black Square (1915)
- **Canvas**: 79.5 x 79.5cm (square)
- **Collection**: Tretyakov Gallery, Moscow
- **Composition**: One black square on a white background. The black plane occupies about 62-65% of the canvas. The square is not a perfect square but has slight asymmetry (1-2mm difference in each side's length). A white border of about 7-8cm at the edges.
- **Cracks (craquelure)**: Over time, a net-like crazing formed in the black plane, exposing underlying colors (green, pink). Not intended, but reinterpretable as a "texture of time."
- **Ratio**: black square side ≈ 79-80% of canvas side. white border ≈ 10% of canvas side.
- **UI conversion**: A single large CTA at the center of the screen. `width: 80%; aspect-ratio: 1; margin: 10% auto;`. Extreme simplicity — demand only one action per screen.

### 2. White on White (1918)
- **Canvas**: 79.4 x 79.4cm (square)
- **Collection**: Museum of Modern Art, New York
- **Composition**: A white square in a slightly different tone, placed at about a 15° tilt on an off-white background. The lightness difference between the two whites is around L*: 3-5. The tilted square is slightly biased toward the upper right of the canvas.
- **Color difference**: background = warm white (#F0EDE5), square = cool white (#FAF7F0). Form distinguished by color temperature difference alone.
- **Extreme reduction**: chroma, contrast, and form almost all removed. Named by Malevich himself "the zero point of painting."
- **UI conversion**: The archetype of a surface-level system. Distinguish a card on a same-color card by a slight lightness/color-temperature difference. `background: #FAF7F0` (card) on `background: #F0EDE5` (background). Express elevation by color difference alone, without box-shadow.

### 3. Suprematist Composition (1916)
- **Canvas**: 88.5 x 71cm (portrait)
- **Collection**: Multiple versions exist; representatively the Stedelijk Museum
- **Composition**: Squares, rectangles, and trapezoids of various sizes distributed across the canvas, tilted at 15-45° angles. A large red square at the center, surrounded by small black/blue/yellow forms. 8-12 forms total.
- **Hierarchy**: largest form (red) = ~20% of canvas, smallest form = ~2%. Size ratio about 10:1.
- **Overlap**: 3-4 pairs of forms overlap. Front-back relationships (z-index) arise in the overlapping regions.
- **UI conversion**: Bento grid dashboard, drag-and-drop canvas, free-placement widget board. Express importance through size hierarchy, and add visual vitality through rotation.

## UI Application Mapping

### Conversion Rules

1. **Limit form vocabulary**: Restrict UI components to 4 basic forms.
   - square/rectangle → card, button, input field
   - circle → avatar, toggle, FAB
   - cross → close, add, expand
   - triangle → direction indicator, dropdown arrow

2. **Black-and-white-first design**: Design first in achromatic colors (black/white/gray), then add chromatic colors as accents. Allow chromatic color in no more than 20% of total area.
   ```css
   :root {
     --surface: #F0EDE5;
     --on-surface: #1C1C1C;
     --accent: #CC1A1A;  /* 20% or less */
   }
   ```

3. **Surface levels (White on White)**: Express depth with slight color differences instead of shadows.
   ```css
   --surface-0: #F0EDE5;  /* background */
   --surface-1: #F5F0E0;  /* card */
   --surface-2: #FAF7F0;  /* raised element */
   --surface-3: #FFFFFF;  /* topmost */
   ```

4. **Size hierarchy**: Set a size difference of at least 5:1 between primary and secondary elements. Do not overuse medium sizes. Make large things clearly large, small things clearly small.

5. **Free placement**: Do not be bound by a strict grid. Allow elements to feel like they are "floating." Use `position: absolute` or manual placement with CSS Grid's `grid-column/row`.

6. **Rotation accent**: Place one element tilted at 15-45° in a static composition to add visual energy. `transform: rotate(15deg)`. Limit to 1-2 elements, however.

### Suitable UI Types
- **Minimal landing page**: like Black Square, one message, one action
- **Art gallery/exhibition**: arrange works in a geometric grid, forms floating on a white background
- **Design tools**: free placement on a canvas, drag-and-drop interface
- **Dashboard (bento)**: bento grid with widgets of various sizes placed freely
- **Typography site**: letters themselves act as geometric forms, text-centric layout
- **Onboarding flow**: show only one core form/message per screen

### Cautions
- **No decorative curves**: Organic curves, waves, and free curves directly violate Suprematism. Allow only the circle and exclude ellipses or irregular curves.
- **No excessive gradients**: Malevich's color planes are flat and homogeneous. A gradient within a color plane damages the purity of the form.
- **Minimize photos/illustrations**: Figurative images violate the "non-objectivity" principle. If unavoidable, confine them within a geometric mask (square/circle).
- **No color overuse**: Use 3 or fewer chromatic colors per screen. Achromatic is always the protagonist.
- **Beware uniform placement**: Placing all elements at uniform size and spacing destroys Suprematist dynamism. Size differences and irregular spacing are key.
- **Beware shadow abuse**: Suprematist forms are flat. Overly applying physical depth with `box-shadow` destroys the aesthetic. Prioritize the color-difference strategy of White on White.
- **No overcrowding**: Placing 12 or more geometric forms on one screen becomes "information overload" rather than "pure feeling."
- **Beware responsive rotation**: Tilted elements can be clipped or break the layout on small screens. Apply `transform: rotate()` only when sufficient margin is secured.
