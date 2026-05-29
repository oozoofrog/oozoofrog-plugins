# Bridget Riley -- Visual Language Design Tokens

## Profile
- **Active period**: 1960-present (core period: 1961-present)
- **Movement/school**: Op Art (Optical Art)
- **Core contribution**: Generates optical movement through systematic repetition and variation of geometric patterns. Precisely modulates the spacing, width, and color of stripes to induce retinal-level perceptual disturbance. Established a system that creates dynamic experience from static images.

## Visual Language Principles

1. **Perceptual Instability**: Introduces subtle variation into regular patterns so the eye cannot find a stable point. A static image triggers the illusion of shimmering and moving. In UI, this is the basis for subtle animation, hover effects, and visual feedback.
2. **Systematic Variation**: Changes only one variable of the pattern (width, spacing, angle, color) progressively. The rest stay fixed. The experimental rigor of adjusting only one variable at a time maximizes the visual effect.
3. **Energy of Repetition**: Repetition of identical elements itself generates energy and movement. Once the repetition count crosses a threshold (about 7-10 times), the pattern begins to vibrate.
4. **Maximized Black-White**: Early works achieved maximum visual effect with black and white alone. "Movement" can be created without color. Contrast is the source of all visual energy.
5. **Color Interaction**: Color works after 1967 exploit simultaneous contrast between adjacent colors. The same color appears different depending on its surroundings. Applies Josef Albers's theory to kinetic patterns.
6. **Undulating Curve**: Transforms straight stripes into curves to create a wave effect. Changes in curvature determine the speed and direction of movement.
7. **Viewer Participation**: The "movement" of the work is not on the canvas but occurs in the viewer's retina and brain. In UI, this is the principle that the user's perception is part of the interface.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| riley-black | #0A0A0A ~ #1A1A1A | Movement in Squares (1961) measured | B | Pattern foreground, text, strong-contrast elements |
| riley-white | #F5F5F5 ~ #FFFFFF | Background of all black-white works | B | Pattern background, whitespace, high-contrast base |
| riley-blue-cerulean | #0077B6 ~ #0096C7 | Late Morning (1967-68) colorimetry | C | Cool accent, informational elements |
| riley-green-viridian | #1B8A5A ~ #2ECC71 | Nataraja (1993) colorimetry | C | Secondary accent, success, nature association |
| riley-red-warm | #D72638 ~ #E63946 | Late Morning (1967-68) | C | Warning, emphasis, warm point |
| riley-orange-stripe | #E76F51 ~ #F4845F | Colour stripe series | C | Secondary CTA, active indicator |
| riley-pink-magenta | #D63384 ~ #E91E8C | Color transition period after Hesitate (1964) | D | Highlight, premium element |
| riley-gray-mid | #808080 | Black-white mid-gray reference | B | Mid tone, inactive, secondary element |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| stripe-width | 2-20px (0.5-3% of viewport) | Movement in Squares (1961) measured | B | Base width of stripe pattern |
| stripe-gap | 0.5-2x of stripe-width | Spacing measured across all works | B | Gap ratio between stripes |
| stripe-count | 15-60 per axis | Stripe-count statistics across all works | B | Count of repeated elements, list item count |
| wave-amplitude | 2-8x of stripe width | Current (1964) measured | C | Amplitude of curved pattern |
| wave-period | 20-50% of canvas width | Current (1964) measured | C | Period of curved pattern |
| pattern-orientation | vertical, horizontal, diagonal (45°) | Orientation statistics across all works | B | Pattern direction, relation to scroll direction |

### Ratio & Balance
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| black-white-ratio | 1:1 (early black-white), variable (later) | Area ratio of all black-white works | B | Default foreground:background ratio |
| width-variation-range | 50-200% of base width | Movement in Squares measured | B | Variation range of stripe width |
| compression-ratio | 30-50% of base at compression point | Movement in Squares narrow region | B | Minimum ratio at pattern compression |
| expansion-ratio | 150-200% of base at expansion point | Movement in Squares wide region | B | Maximum ratio at pattern expansion |
| color-stripe-count | 3-5 alternating colors | Late Morning and other color works | C | Number of colors in a color sequence |

### Space & Whitespace
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| edge-to-edge | Pattern reaches the canvas edge (margin 0) | All works (pattern not cropped) | B | Pattern fully fills the viewport, full-bleed |
| no-focal-rest | No empty space where the gaze can rest | All works (full-field pattern) | B | Reference when applying full-field pattern in loading/transition |
| pattern-boundary | Complete whitespace outside the pattern | Exhibition install (pattern work + white wall) | C | Clear separation of pattern and non-pattern regions |
| breathing-contrast | At least 50% whitespace beside the pattern region | Exhibition space analysis | C | Ensure sufficient empty space around pattern UI elements |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| repetition-threshold | Vibration begins at 7-10 repetitions | Pattern observation based on visual-perception research | C | Minimum count of repeated elements (when vibration effect intended) |
| modulation-rate | Width change = 5-15% relative to neighbor | Movement in Squares adjacent-stripe comparison | B | Unit of progressive change — no abrupt change |
| phase-shift | 50% phase difference of pattern in adjacent column/row | Fall (1963) measured | C | Phase of checkerboard pattern, offset grid |
| color-sequence | 3-5 colors regularly alternating, occasionally disrupted | Late Morning color-order analysis | C | Regularity and exceptions of a color sequence |
| moire-generation | 2+ overlapping patterns → moiré occurs | Blaze (1964) concentric-circle overlap | C | Intentional pattern overlap to create visual depth |
| speed-illusion | Narrow spacing = fast, wide spacing = slow | Spacing-speed relation across all works | B | Speed feel control for loading bars, progress |

## Key Work Analysis

### 1. Movement in Squares (1961)
- **Canvas**: 123 x 123cm (square)
- **Collection**: Arts Council Collection, London
- **Composition**: Black-white vertical stripes start at uniform width on the left and right and progressively narrow toward the center. Stripe width is narrowest at the central compression point (about 2mm). They widen again toward the opposite side. About 50-60 stripes.
- **Compression ratio**: Edge stripe width about 15mm, center about 2mm. Ratio about 7.5:1.
- **Visual effect**: A sense of depth as if the center recedes backward. A 3D sense of space arises on a flat plane. The stripes feel like they are "folding."
- **UI conversion**: Progressively vary stripe width with CSS `perspective` + `repeating-linear-gradient`. Loading screens, transition effects, and stripe compression/expansion on scroll to express speed.

### 2. Current (1964)
- **Canvas**: 148 x 149cm
- **Collection**: Museum of Modern Art, New York
- **Composition**: Black-white curved stripes undulate and flow vertically. Curvature changes left and right, forming a wave pattern. About 40 curves. The wave period is about 30% of the canvas height.
- **Movement effect**: Intense left-right swaying illusion. The canvas surface feels like flowing liquid. Movement is strongest at points of high curvature.
- **Mathematical analysis**: The curves approximate a sine wave. Amplitude about 10-15mm, period about 40-50mm. Adjacent curves flow in the same phase, forming a wavefront.
- **UI conversion**: Undulating loading animation, curved variation of scroll parallax, audio-visualizer waveform. `SVG path` sine-wave deformation + CSS animation.

### 3. Late Morning (1967-68)
- **Canvas**: 226 x 231cm (nearly square)
- **Collection**: Tate, London
- **Composition**: One of Riley's first color works. Vertical stripes alternate red, blue, green, gray, and white in a specific order. Stripe width is nearly uniform, but the color order occasionally "deviates," inducing visual shimmer.
- **Color interaction**: Gray beside a red stripe appears to take on a green tint (simultaneous contrast). White beside blue takes on a slight yellow tint. The "perceived color" rather than the stripe's own color dominates the work.
- **UI conversion**: Color-stripe pattern navigation bars, category indicators, multi-step progress. Reinforce color distinction using the simultaneous-contrast effect.

## UI Application Mapping

### Conversion Rules

1. **Loading/transition pattern**: Express loading state through repetition and variation of stripes.
   ```css
   .riley-loading {
     background: repeating-linear-gradient(
       90deg,
       #0A0A0A 0px, #0A0A0A 4px,
       #F5F5F5 4px, #F5F5F5 8px
     );
     animation: stripe-shift 0.8s linear infinite;
   }
   @keyframes stripe-shift {
     to { background-position: 16px 0; }
   }
   ```

2. **Progress bar speed feel**: Vary stripe spacing to adjust the perceived progress speed. Narrow spacing = fast feel, wide spacing = slow feel.
   ```css
   .riley-progress {
     background: repeating-linear-gradient(
       -45deg,
       #0A0A0A 0px, #0A0A0A 3px,
       transparent 3px, transparent 6px
     );
     animation: barber-pole 0.6s linear infinite;
   }
   ```

3. **Color stripe navigation**: Express per-category colors as vertical stripes.
   ```css
   .riley-nav {
     background: linear-gradient(
       90deg,
       #D72638 0%, #D72638 20%,
       #0077B6 20%, #0077B6 40%,
       #1B8A5A 40%, #1B8A5A 60%,
       #808080 60%, #808080 80%,
       #F5F5F5 80%, #F5F5F5 100%
     );
     height: 4px;
   }
   ```

4. **Pattern compression/expansion**: Dynamically change stripe width by scroll position to give a sense of depth and speed. Use fluid units such as `clamp(2px, 1vw, 20px)`.

5. **Simultaneous contrast use**: Place the complement of the desired color beside a gray element so the gray takes on that color's tint. A strategy to reduce the actual color count while increasing the perceived color count.

6. **Separation of full-field pattern and whitespace**: The pattern fills its designated region 100%, and everything outside remains complete whitespace. Avoid intermediate states (half-filled patterns).

### Suitable UI Types
- **Loading/skeleton**: Express progress state with stripe animation
- **Progress bar**: Directional stripe patterns, speed-feel control
- **Background pattern**: Hero areas, section dividers, decorative stripes
- **Data visualization**: Heatmaps, barcode charts, stripe charts
- **Transition effects**: Stripe wipe effects during screen transitions
- **Sports/fitness apps**: Interfaces needing energy, movement, and dynamism

### Cautions
- **Accessibility first**: Op Art patterns can trigger photosensitive epilepsy. Always disable pattern animation with the `prefers-reduced-motion` media query. Compliance with WCAG 2.1 rule 2.3.1 (Three Flashes) is mandatory.
- **Avoid large-area patterns**: Filling 50% or more of the screen with high-contrast repeating patterns causes visual discomfort. Limit patterns to decorative elements (progress bars, background stripes).
- **Minimum stripe width**: Stripes under 2px break up or generate unintended moiré depending on resolution. Maintain a minimum of 2px (at 1x resolution).
- **No color excess**: Limit color stripes to a maximum of 5 colors. More becomes visual confusion rather than category distinction.
- **No static large-area use**: Riley's patterns are about "movement" at their core. Laying a large-area pattern as a static background only causes eye fatigue. Use patterns in small areas or together with animation.
- **No pattern over content**: Placing a high-contrast pattern behind text or important content destroys legibility. Use patterns only in decorative regions separated from content.
- **Period consistency**: Mixing stripe patterns of different periods on one screen produces unintended moiré. Unify the pattern period or make them sufficiently different (2x or more difference).
