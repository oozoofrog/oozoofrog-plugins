# Mark Rothko -- Visual Language Design Tokens

## Profile
- **Active period**: 1936-1970 (mature period: 1949-1970)
- **Movement/school**: Color Field Painting, Abstract Expressionism
- **Core contribution**: Elevated color itself to a medium for conveying emotion. Invented a structure that immerses the viewer in a color experience through vertical stacking of 2-3 color fields and feathering (soft edge) of their boundaries. The first systematic experiment to use scale as an emotional tool.

## Visual Language Principles

1. **Immersive Scale**: Large canvases (150-300cm) fill the field of view and pull the viewer into the color. The archetype for full-screen background color, hero images, and immersive experiences in UI.
2. **Stacked Fields**: Stack 2-3 color fields vertically. Each field holds an independent emotion, yet the overall composition forms a single emotional narrative. Matches the section structure of vertically scrolling UI.
3. **Feathered Edge**: Field boundaries are not sharply divided but bleed gradually. The ambiguity of the boundary creates breathing room between fields. The aesthetic basis for CSS gradient, blur, and opacity transitions.
4. **Color Vibration**: Deliberately place complementary/analogous color combinations where adjacent fields visually vibrate. Color relationships feel alive and moving rather than static.
5. **Inner Luminosity**: Multiple translucent paint layers create the effect of light emanating from within. The aesthetic basis for `opacity`, `backdrop-filter`, and layered overlays in UI.
6. **Emotional Truth**: Rothko said, "나는 색채와 형태의 관계에 관심이 없다. 기본적인 인간 감정 — 비극, 환희, 운명 — 을 표현하는 것에만 관심이 있다." The principle that UI color choices affect the user's emotional state beyond functional purpose.
7. **Contemplative Distance**: Rothko recommended that viewers stand 45cm from the work. In UI, full-screen background color creates an experience that envelops the user. The overall screen tone, not small elements, is the key.

## Quantitative Design Tokens

### Color System
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| rothko-orange-warm | #CC4400 ~ #E86B2A | Orange and Yellow (1956) measured | B | High-energy CTA, active state |
| rothko-yellow-glow | #E8B800 ~ #FFCC33 | Orange and Yellow (1956) | B | Highlight, hover state, notification |
| rothko-red-deep | #8B1A1A ~ #A02020 | No. 61 (Rust and Blue, 1953) | B | Warning, strong emotional triggers |
| rothko-blue-night | #1A1A4D ~ #2B2B6B | No. 61 (Rust and Blue, 1953) | B | Dark mode background, deep immersion zones |
| rothko-maroon-dark | #3B0A0A ~ #5C1515 | Late Rothko Chapel works | B | Dark mode deep background |
| rothko-black-luminous | #1A1520 ~ #2A2030 | Black in Deep Red (1957) | B | Deepest layer, overlay |
| rothko-plum | #4A1942 ~ #6B2D5E | No. 301 (1959) | C | Premium UI, luxury branding |
| rothko-chapel-gray | #2A2A25 ~ #3D3D35 | Rothko Chapel panels (1964-67) | B | Dark mode surface, meditative UI |
| rothko-green-muted | #2D4A3E ~ #3E6B55 | No. 3/No. 13 (Magenta, Black, Green on Orange, 1949) | B | Secondary state, nature/health-related UI |
| rothko-white-warm | #F0E8D8 ~ #FAF2E6 | Early-work background color analysis | C | Light mode warm background, paper texture simulation |
| rothko-transition-zone | midpoint of two adjacent colors, opacity 30-70% | Boundary-zone color extraction across all works | F | Gradient midpoint of the field boundary |

### Composition & Layout
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| field-count | 2-3 (rarely 4) | Statistics across all works | B | Number of major sections (2-3 zones per screen) |
| field-orientation | Vertical stacking (horizontal fields stacked vertically) | Structure across all works | B | Vertical scroll section composition |
| canvas-aspect-ratio | Portrait 4:5 ~ 3:4 (some landscape exist) | Representative works measured | B | Mobile-first screen ratio |
| field-margin-from-edge | 2-5% inset from left/right of canvas | Measured (fields do not touch the edge) | B | Left/right inset of content, safe-area padding |
| field-shape | Wide horizontal rectangle (width:height ≈ 3:1 ~ 5:1) | Field shape measurement | B | Horizontal ratio of sections/cards, wide banner form |
| field-corner | Indeterminate corners (neither right-angled nor rounded, paint bled) | Technique observation | B | border-radius: 2-6px subtle rounded corners, or organic outline via mask |

### Proportion & Balance
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| top-field-ratio | 35-50% of total height | 2-field works measured | B | Top section (hero) height ratio |
| bottom-field-ratio | 30-45% of total height | 2-field works measured | B | Bottom section (content) height ratio |
| middle-field-ratio | 15-30% of total height (in 3-field works) | 3-field works measured | B | Middle transition zone ratio |
| field-width-to-canvas | 90-96% | All works (field left/right margins) | B | Content width ratio relative to max-width |
| inter-field-gap | 2-5% of canvas height | Field spacing measured | B | Breathing gap between sections |

### Space & Whitespace
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| background-bleed | Background color behind fields exposed like a border (2-5%) | All works | B | Whitespace color between container and background |
| top-margin | 3-8% from canvas top to first field | Measured | B | Top safe area, status bar space |
| bottom-margin | 5-10% from canvas bottom to last field | Measured | B | Bottom margin, tab bar/FAB space |
| breathing-space | Background exposure between fields = 5-15% of total area | Statistics across all works | C | Total ratio of inter-section whitespace |

### Visual Rhythm & Repetition
| Token | Value/Range | Source | Confidence | UI Application |
|--------|---------|------|--------|---------|
| edge-feather-width | 10-25px at field boundary (1-3% relative to canvas) | Measured | B | Gradient transition zone, blur radius |
| luminosity-layers | 3-7 translucent layers overlaid | Technique analysis (NGA conservation report) | C | opacity 0.6-0.9 layered overlay effect |
| color-temperature-shift | Warm-cool contrast within one work | Pattern across all works | C | Top (warm)-bottom (cool) temperature gradient |
| pulse-rhythm | Subtle brightness variation within a field (±5-10%) | Digital scan analysis | F | Subtle background color animation, breathing effect |

## Representative Work Analysis

### 1. Orange and Yellow (1956)
- **Canvas**: 231 x 180cm (portrait, approx. 1.28:1)
- **Collection**: Albright-Knox Art Gallery, Buffalo
- **Composition**: 2 color fields stacked vertically. Top = yellow-orange (~48% of total height), bottom = deep orange (~40%). Background = orange-tinted yellow. The background color is exposed like a thin border between fields and at the edges.
- **Field relationship**: The top is brighter and wider than the bottom. The brightness difference between the two fields is about 20%, a soft contrast. The analogous combination (orange-yellow) maximizes harmony and warmth.
- **Feathering**: Boundary transition zone of about 15-20px (~1% of canvas height). A "breathing" boundary rather than full blending. The bottom edge of the top field and the top edge of the bottom field bleed toward each other.
- **Emotional effect**: Overall bright and warm tone. Recorded as evoking emotions of "joy" and "optimism" (consistent with Rothko's own intent and critical reception).
- **UI conversion**: Hero (top bright field) + content (bottom deep field) 2-section structure. Suited to onboarding and success screens that deliver a positive experience.
  ```css
  .rothko-warm {
    background: linear-gradient(180deg, #FFCC33 0%, #FFCC33 46%, #E8A020 50%, #E86B2A 54%, #E86B2A 100%);
  }
  ```

### 2. No. 61 (Rust and Blue, 1953)
- **Canvas**: 294 x 232cm (large portrait)
- **Collection**: Museum of Contemporary Art, Los Angeles
- **Composition**: Top = rust red/brown (~45%), bottom = deep blue (~42%), narrow background exposure between (~3%). The colors overlap subtly at the boundary of the two fields.
- **Emotional contrast**: Warm top (anxiety, passion) vs. cool bottom (subsidence, depth). Dramatic temperature contrast. The near-complementary relationship (red-blue) creates tension.
- **Brightness analysis**: Top L* ≈ 35-40, bottom L* ≈ 15-25. About 15-20 L* difference makes for strong contrast while both remain in the mid-low brightness range, maintaining heaviness.
- **UI conversion**: The visual archetype of light mode ↔ dark mode switching. Warm-tone header + cool-tone content area. Or representing the top (warning) + bottom (severe) stages of warning/danger state screens.

### 3. Rothko Chapel panels (1964-67, 14 works)
- **Scale**: 14 canvases surrounding the entire wall, octagonal space. 1-3 panels arranged on each wall.
- **Collection**: Rothko Chapel, Houston, Texas
- **Colors**: Deep maroon, near-black purple, deep brown — subtle variations in the 5-15% brightness difference range. The same panel appears as a different color depending on lighting conditions.
- **Composition types**: A mix of single-color panels (monoform), 2-field vertical stacks (dyad), and 3-field vertical stacks (triad). A total art (Gesamtkunstwerk) integrating building structure and work composition.
- **Dark mode tokens**: Subtle distinction within an extremely low brightness range (L*: 5-20) is the key. Darkness that maintains hue rather than using pure black (#000). As time passes and the eye adapts, subtle hue differences emerge — the same principle by which a user perceives differences between surfaces the longer they stay in dark mode.
- **UI conversion**: Surface level system for dark mode.
  ```css
  :root[data-mode="dark"] {
    --surface-0: #1A1520;  /* deepest background (chapel wall) */
    --surface-1: #2A2030;  /* card, sheet (middle panel) */
    --surface-2: #3B2A40;  /* raised element (bright panel) */
    --surface-3: #4D3B52;  /* hover/focus (lit surface) */
  }
  ```
  An artistic precursor to the surface tint concept of Material Design 3.

## UI Application Mapping

### Conversion Rules

1. **Background color system**: Apply a subtle gradient rather than a solid background. Instead of a single `background-color`, use `linear-gradient` with a 2-5% brightness difference. The gradient direction is always vertical (180deg).
   ```css
   background: linear-gradient(180deg, #2A2030 0%, #1A1520 100%);
   ```

2. **Section transitions**: Place a `backdrop-filter: blur(8-16px)` or `linear-gradient` transition zone at section boundaries. A color fade instead of a sharp dividing line (border).

3. **Immersion layers**: Overlay a translucent dark layer such as `background: rgba(26, 21, 32, 0.85)` on modals and overlays to create depth.

4. **Emotional color mapping**: Decide color temperature based on the screen's purpose.
   - Active/productive screens → warm palette (rothko-orange, rothko-yellow)
   - Reading/meditation/focus screens → cool palette (rothko-blue, rothko-maroon)

5. **Dark mode surface levels**: No pure black (#000). Use hue-bearing darkness in stages.
   ```
   --surface-0: #1A1520;  /* deepest background */
   --surface-1: #2A2030;  /* card, sheet */
   --surface-2: #3D3045;  /* raised element */
   --surface-3: #4F4058;  /* hover, focus */
   ```

### Suitable UI Types
- **Meditation/wellness apps**: Breathing effect of color fields, soft transitions, immersive backgrounds
- **Reading/viewer apps**: Subtle tonal differences in dark mode, hue-bearing darkness that reduces eye strain
- **Music/audio players**: Emotional color transitions, background gradients that change over time
- **Onboarding/storytelling**: Experience 2-3 color field sections sequentially via vertical scroll
- **Premium brand sites**: Deep color, inner luminosity effect, restrained whitespace
- **Exhibition/gallery apps**: Dark surface system that does not interfere with appreciating the works

### Cautions
- **Do not overuse sharp dividing lines**: Sharp divisions like `border: 1px solid` directly violate Rothko's aesthetic. Distinguish zones with color difference and gradients.
- **No pure black (#000)**: Always use hue-bearing darkness, even in dark mode. Pure black feels "dead."
- **Do not place excessive elements**: Do not put 4 or more independent sections on one screen. Rothko's works convey sufficient emotion with 2-3 fields.
- **Caution: unsuitable for small screens**: Applying these tokens to small elements like icon size or button size makes the effect disappear. Apply only to fields that occupy at least 30% of the screen.
- **Avoid high saturation**: Rothko's colors gain their power from deep brightness, not high saturation. Neon or over-saturated colors destroy the aesthetic.
- **No fast animation**: Use slow transitions of 500ms-2000ms for field changes. Fast color changes of 100ms or less harm the Rothko-esque "breathing."
- **Caution: text overload**: Placing a lot of text over a color field weakens the field's emotional power. The color field itself is the message, so keep text to a minimum.
- **No pattern/texture**: Do not place patterns or textures over color fields. The purity of the field is the key. Treatments like `background-image: url(texture.png)` destroy the aesthetic.

## Rothko's Emotion-Color Mapping Reference

The change in Rothko's colors across periods reflects changes in his emotional state:

| Period | Representative Colors | Emotional Tone | UI Mood Mapping |
|------|----------|---------|---------------|
| 1949-1952 (early mature period) | Bright yellow, red, orange | Optimism, energy, joy | Onboarding, success, celebration screens |
| 1953-1957 (middle period) | Deep red, brown, blue | Tension, contrast, intensity | Warning, important decisions, immersion states |
| 1958-1963 (late period) | Dark red, black, maroon | Heaviness, introversion, contemplation | Dark mode, night mode, focus mode |
| 1964-1970 (final period) | Black, gray, brown | Calm, emptiness, meditation | Meditation apps, sleep mode, minimal UI |

This change reflects Rothko's personal history and declining health, but in UI design it can be converted into the universal principle of "adjusting color temperature and brightness according to the user's activity level." Use bright, warm tones for active contexts and dark, cool tones for rest/focus contexts.

## Rothko's Recommended Viewing Conditions → UI Environment Mapping

- **Lighting**: Weak indirect lighting. In UI, lower screen brightness and auto-adjust brightness in response to ambient light.
- **Distance**: 45cm (very close). Matches the distance of holding a phone in hand. An aesthetic more suited to mobile than desktop.
- **Size**: Fill the field of view. The color field must occupy at least 60% of the screen for the immersion effect to occur.
- **Time**: Look for a long time. Design an experience of staying on one screen rather than fast scrolling.
