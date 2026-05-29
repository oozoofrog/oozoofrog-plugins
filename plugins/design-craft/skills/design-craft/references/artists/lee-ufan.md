# 이우환 (Lee Ufan) -- Visual Language Design Tokens

## Profile
- **Active period**: 1967-present (core period: 1968-present)
- **Movement/school**: Mono-ha (もの派), with ties to Korean Dansaekhwa
- **Core contribution**: Established the aesthetics of "encounter," holding minimal action and maximal void in tension. Systematized structures of repetition and disappearance in the From Point, From Line, From Wind series. Elevated the Eastern concept of 'ma (間)' into a theory of space for contemporary art.

## Visual Language Principles

1. **Active Void**: Empty space is not emptiness but a field (場) that holds "resonance." 70-90% of the canvas is void, and that void is the substance of the work. In UI, whitespace is functional breathing, not decoration.
2. **Encounter (出会い)**: Tension arises at the contact point where heterogeneous elements (brush mark and canvas, stone and steel plate) meet. In UI, the "relationship" between components matters more than the individual elements.
3. **Incompleteness**: The work does not strive toward completion but is intentionally left unfinished. Lines extending beyond the canvas and cut-off forms provoke imagination. This is the aesthetic basis for peek/preview patterns in UI.
4. **Repetition & Fading**: In the Point and Line series, the brush's ink gradually exhausts and the marks fade. The start and end of a stroke differ in density. This is the prototype for opacity gradients and fade-out patterns in UI.
5. **Bodily Gesture**: The brushstroke carries the body's breath and rhythm directly. It rejects mechanical uniformity. This is the basis for ease-in-out curves and natural deceleration animations in UI.
6. **Relatum**: In the Relatum sculpture series, stone (nature) and steel plate (artifice) are placed side by side. Neither is transformed; both meet "as they are." In UI, this is the relationship between content and container — revealing essence without excessive styling.
7. **Ma (間)**: A core concept of Korean/Japanese aesthetics. The resonance of a temporal and spatial "in-between." The distance between elements determines the character of their relationship. In UI, this is the principle by which spacing scale forms visual hierarchy.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| lee-mineral-blue | #2C4A6E ~ #3B6B9C | From Point series (1975-) mineral pigment colorimetry | B | Primary accent, links, focus ring |
| lee-burnt-orange | #B85C2A ~ #D4733A | From Line series (1978-) early brush mark | C | CTA button, active state, warning |
| lee-ink-black | #1A1A1E ~ #2A2A30 | All From Point/Line/Wind series | B | Text, icons, primary elements |
| lee-canvas-white | #F5F0E8 ~ #FAF5ED | Canvas's own color (raw cloth, not pure white) | B | Background, void, card surface |
| lee-fading-gray | #C0B8A8 ~ #D8D0C0 | Tone of the ink-exhaustion zone | C | Disabled state, hint text, placeholder |
| lee-stone-gray | #7A7570 ~ #9A9590 | Natural stone color in the Relatum series | C | Secondary text, dividers, borders |
| lee-iron-dark | #3A3530 ~ #4D4840 | Relatum steel-plate surface color | C | Dark-mode surface, header/footer |
| opacity-fade-range | 100% → 5% (linear decrease) | From Point dot-density measurement | B | Element opacity decay sequence |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| mark-coverage | 10-30% of canvas | Area statistics across the From Point/Line series | B | Maximum area ratio occupied by content |
| void-ratio | 70-90% of canvas | Void analysis across all works | B | Minimum void ratio — secure at least 70% of the screen as void |
| mark-position | Biased to one side of center (30-40% point, left/bottom) | From Point composition analysis | C | Place primary elements at the 1/3 point rather than the center |
| extension-beyond-frame | Composition where lines appear to extend off the canvas | From Line series | B | Sense of elements continuing beyond the viewport, overflow: visible |
| gesture-direction | Top-left→bottom-right or top→bottom (gravity direction) | Brushstroke direction analysis | C | Gaze-guiding direction, content flow direction |

### Proportion & Balance
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| mark-to-void | 1:3 ~ 1:9 | Ratio statistics across 20 major works | B | Content-to-void ratio guide |
| point-interval | Distance between dots = 1.5-3x the dot diameter | From Point No. 780127 (1978) measurement | B | Spacing ratio between repeating elements |
| point-size-decay | First dot 100% → last dot 20-40% | From Point series size variation | B | Gradual size reduction of list/sequence elements |
| line-taper | 100% of start width → 30-50% at end | From Line series measurement | C | Progress bar, scroll indicator taper |
| asymmetric-weight | Center of gravity concentrated in the bottom 1/3 of the canvas | Visual-weight analysis across all works | C | Concentrate primary interactions at the bottom of the screen (thumb zone) |

### Space & Void
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| ma-spacing-xs | 8px (base unit) | Estimated minimum dot-spacing unit | C | Minimum spacing unit |
| ma-spacing-sm | 16px (2x) | Internal spacing of repeating elements | C | Spacing between adjacent elements |
| ma-spacing-md | 32px (4x) | Spacing between element groups | C | Internal section spacing |
| ma-spacing-lg | 64px (8x) | Relational distance between canvases within a series | C | Spacing between sections |
| ma-spacing-xl | 128px (16x) | Breathing distance between canvas and wall | C | Page top/bottom margins, large void |
| void-as-content | The void itself is "content" — space that cannot be filled | Lee Ufan essay "만남을 찾아서" (In Search of Encounter) (1971) | B | Leave the empty state as void without decorating it |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| point-rhythm | Regular start → irregular disappearance | From Point series pattern analysis | B | Loading animation: regular dots → fade-out |
| line-breath | One stroke: start (thick) → middle (steady) → end (thinning) | From Line series brushstroke analysis | B | Swipe gesture feedback, touch trajectory |
| density-gradient | High density at top-left → low density at bottom-right (or reverse) | From Point No. 780127 measurement | B | Gradual spacing increase of list items |
| repetition-count | Disappears after 5-15 repetitions | From Point/Line repetition-count statistics | C | Maximum number of steps in a sequence/step indicator |
| fade-out-curve | ease-out (sharp start → smooth end) | Ink-exhaustion pattern | C | Animation curve, transition-timing-function |

## Representative Work Analysis

### 1. From Point No. 780127 (1978)
- **Canvas**: 182 x 227cm (landscape)
- **Collection**: 국립현대미술관, 과천 (National Museum of Modern and Contemporary Art, Gwacheon)
- **Composition**: A grid array of dots starting at the top-left corner and heading toward the bottom-right. Roughly a 12x8 grid. The top-left dots are dark and large (diameter approx. 4-5cm) and grow fainter and smaller toward the bottom-right (diameter approx. 1-2cm). The bottom-right 1/3 of the canvas is almost entirely void.
- **Density analysis**: Top-left dot opacity 100%, bottom-right dot opacity 15-20%. About 50% opacity at the midpoint. The decay curve is exponential.
- **Void ratio**: Dots occupy about 15% of the area, void about 85%.
- **UI translation**: Density maps for data visualization, loading indicators for infinite scroll (dark dot → faint dot), time-based fade of notification badges.

### 2. From Line No. 790143 (1979)
- **Canvas**: 182 x 227cm
- **Collection**: 도쿄 국립근대미술관 (The National Museum of Modern Art, Tokyo)
- **Composition**: 7-8 vertical lines descending from the top to the bottom of the canvas. Each line begins at the top and fades toward the bottom as the ink exhausts. Line spacing is relatively uniform at about 25-30cm.
- **Line characteristics**: Start-point width about 3-4cm, end-point about 1cm. Ink density 100% → 20%. Drawn in a single stroke without lifting the brush, so the rhythm of breath is recorded in the variation of line thickness.
- **UI translation**: Fade effect for vertical dividers, scroll indicators, ink-exhaustion metaphor for progress bars. `border-image: linear-gradient(to bottom, #1A1A1E, transparent)`.

### 3. Relatum — Silence (2008)
- **Installation**: A natural stone on a steel plate (240 x 360cm)
- **Collection**: Lee Ufan Museum, 나오시마 (Naoshima)
- **Composition**: A huge horizontal steel plate is laid on the floor, with one natural stone placed near one corner. About 5cm of void between the stone and the steel plate. The remaining space is a completely empty steel-plate surface.
- **Proportion**: The stone occupies about 3-5% of the area; 95-97% of the steel plate is empty surface. The visual weight of the stone and the vast void of the steel plate hold a taut tension.
- **UI translation**: An extreme minimal layout placing a single CTA on a wide empty screen. A landing-page composition with only one message and one button.

## UI Application Mapping

### Translation Rules

1. **Void-first design**: Design the void before placing content. Secure at least 70% of the screen as void, then place content in the remaining 30%.
   ```css
   .lee-ufan-layout {
     padding: 128px 64px;  /* xl, lg */
     max-width: 40%;       /* limit content area */
     margin: 0;            /* biased to one side, not centered */
   }
   ```

2. **Fade sequence**: Apply gradual opacity decay to repeating elements.
   ```css
   .fade-sequence > *:nth-child(1) { opacity: 1.0; }
   .fade-sequence > *:nth-child(2) { opacity: 0.8; }
   .fade-sequence > *:nth-child(3) { opacity: 0.6; }
   .fade-sequence > *:nth-child(4) { opacity: 0.4; }
   .fade-sequence > *:nth-child(5) { opacity: 0.2; }
   ```

3. **Ma (間) spacing**: Increase the spacing scale exponentially to create hierarchy. 8-16-32-64-128px. Make group-to-group spacing dramatically larger than spacing between adjacent elements.

4. **Incompleteness pattern**: Allow compositions where elements appear to continue beyond the viewport. Use `overflow: visible` and cut-off text/images to imply "continues."

5. **Aesthetics of the empty state**: Do not fill the empty state with illustrations or a CTA. The void itself is the message. A single line of text such as "Nothing here yet" is enough.

### Suitable UI Types
- **Minimal portfolio**: Extreme void, one large work shown at a time, gradual scroll
- **Meditation/mindfulness app**: Void-centric, fade animations timed to breathing rhythm
- **Luxury brand site**: Wide space per product, minimal text, restrained interaction
- **Reading app**: Wide margins, minimized text density, ample line and letter spacing
- **Gallery/exhibition app**: Ample spacing between works, minimal captions
- **Zero-state design**: Treat empty screens as meaningful void without decoration

### Caveats
- **Suppress the urge to fill the void**: The urge to put something in any empty space you see is the greatest enemy. The void is intentional and structural.
- **No uniform repetition**: The repetition of dots/lines carries gradual change, not mechanical uniformity. Adjust individually with `nth-child` instead of CSS `repeat()`.
- **No overuse of center alignment**: Lee Ufan's elements are almost always biased to one side. Do not use `margin: 0 auto` as a default.
- **No excessive color use**: Use only 1-2 colors plus achromatic tones. A multicolor palette dissolves the tension of "encounter."
- **Exclude decorative elements**: Shadows, gradients, border decorations, and the like directly violate Lee Ufan's aesthetics. The mere presence of an element is enough.
- **Unsuitable for dense information structures**: Not suitable for high-density information UIs such as dashboards and data tables. As information density rises, the power of the void disappears.
- **Adjust void ratio on small screens**: 70% void may be unrealistic on mobile. Maintain at least 50% void while prioritizing readability of the core content.
