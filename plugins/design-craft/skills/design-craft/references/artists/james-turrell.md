# James Turrell -- Visual Language Design Tokens

## Profile
- **Active period**: 1966-present (core period: 1966-present)
- **Movement/school**: Light and Space Movement
- **Key contributions**: Established light itself as a sculptural medium. Designed an integrated environment of natural and artificial light at Roden Crater (1979-). Used the Ganzfeld effect (loss of depth perception from a homogeneous visual field) as an artistic tool. Realized the phenomenology of perception as inhabitable, experiential space.

## Visual Language Principles

1. **Seeing Light, Not Things**: Treat light not as a means of illuminating objects but as something perceived in its own right. In UI, the principle that background color, screen brightness, and color temperature are "the experience itself" rather than "a vessel holding content".
2. **Ganzfeld Effect (Total Field)**: When homogeneous colored light fills the entire visual field, depth perception disappears and a sense of infinite space arises. In UI, the basis for the immersive effect created by a solid full-screen background.
3. **Color Temperature as Emotion**: The color temperature of light (Kelvin) directly induces psychological states. 2700K (warm yellow) = intimacy, 5000K (neutral) = clarity, 7500K (cool blue) = alertness. In UI, the basis for deliberately designing the color temperature of dark/light mode.
4. **Gradual Adaptation**: Turrell's works require staying 10-15 minutes or more to perceive subtle changes in light. Retinal adaptation (dark/light adaptation) is part of the experience. In UI, the basis for adaptive UI where the interface changes subtly over usage time.
5. **Dissolving Boundaries**: In Turrell's spaces, the boundaries between wall, floor, and ceiling disappear under light. In UI, the principle of reducing container boundaries and separating regions through color transitions.
6. **Sky Space**: An elliptical aperture in the ceiling presents the sky like a "painting". Framing transforms perception. In UI, the principle that the viewport/frame transforms the meaning of content.
7. **Ambient Intelligence**: Surrounding lighting changes in response to time and weather. The environment adapts at a level the user does not consciously notice. In UI, the basis for automatic time-of-day color temperature adjustment and ambient light sensor use.

## Quantitative Design Tokens

### Color System
| Token | Value/range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| turrell-warm-glow | #FF8C42 ~ #FFAA5C (≈2700K) | Aten Reign (2013) orange phase colorimetry | B | Night mode, warm notifications, welcome screens |
| turrell-pink-dusk | #E87EB0 ~ #F09BC0 (≈3500K) | Aten Reign pink phase | B | Transition states, soft alert, mid-intensity indicators |
| turrell-magenta | #B840A0 ~ #D050B8 | Ganzfeld installation colorimetry (Akhob, 2013) | C | Emphasis, premium, brand point |
| turrell-blue-twilight | #4060C0 ~ #5070D0 (≈6500K) | Roden Crater civil twilight photography | C | Default accent, links, focus ring |
| turrell-blue-deep | #1A2060 ~ #2A3080 (≈7500K) | Roden Crater astronomical twilight photography | B | Dark mode deep background, immersive regions |
| turrell-white-daylight | #F0F0F8 ~ #FAFAFE (≈5000K) | Sky Space noon color temperature | B | Light mode neutral background, content regions |
| turrell-red-ambient | #CC3030 ~ #E04040 | Aten Reign red phase | C | Urgent alerts, focus inducement, energy expression |
| turrell-green-liminal | #30A060 ~ #40C070 | Ganzfeld installation green phase | D | Success, completion, nature association |
| turrell-void-black | #0A0A15 ~ #12122A | Perceptual Cell interior full darkness | B | Deepest background, OLED power saving, extreme dark mode |
| kelvin-gradient | 2700K→5000K→7500K | Roden Crater sunrise-noon-sunset color temperature | B | Automatic time-of-day color temperature transition system |

### Composition & Layout
| Token | Value/range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| ganzfeld-fill | 100% solid fill (entire visual field) | Ganzfeld installation principle | B | Full-screen solid background, immersive mode |
| aperture-shape | Elliptical or rectangular aperture | Sky Space series aperture form | B | Content frame shape, mask shape |
| aperture-ratio | Aperture is 15-30% of the visual field | Sky Space aperture-to-wall ratio | C | Main content area to whitespace ratio |
| transition-duration | Color transition 10-45 min (extremely slow change) | Aten Reign color cycle | B | Long transition time: CSS transition 2-5s (abbreviated) |
| layer-count | 2-5 overlaid layers of light | Aten Reign (2013) concentric ellipse structure | B | Number of overlaid layers, overlay depth |

### Proportion & Balance
| Token | Value/range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| surround-to-aperture | Surround (70-85%) : aperture (15-30%) | Sky Space ratio analysis | B | Frame (surround) : content ratio |
| light-falloff | Center 100% → edge 60-80% (soft attenuation) | Ganzfeld illuminance distribution | C | radial-gradient bright center → dark edge |
| concentric-ratio | Inner layer is 60-75% of outer | Aten Reign concentric ellipse ratio | C | Size ratio of overlaid cards/modals |
| symmetry-type | Central symmetry (radial or concentric) | All-works symmetry analysis | B | Center-focus layout, radial menu |
| horizon-line | 50% point of the visual field (physical horizon) | Sky Space aperture vertical position | C | Vertical center placement of main content |

### Space & Whitespace
| Token | Value/range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| immersive-padding | 0 (elements reach the viewport edge) | Ganzfeld principle (no boundaries) | B | Remove margin/padding in immersive mode |
| perceptual-depth | Mismatch between physical and perceived depth | Ganzfeld effect research | C | Simulate infinite depth with box-shadow, blur |
| boundary-softness | 10-20% gradual transition at the wall-light boundary | Turrell installation corner treatment | B | gradient fade at region boundaries, no sharp border |
| void-space | Pure colored-light region with no perceptible elements | Perceptual Cell, Dark Space | B | Deliberate "empty region" — pure color field with no content or decoration |
| threshold-space | Light→dark transition corridor (adaptation-inducing space) | Roden Crater entry tunnel | C | Intermediate transition screen on mode change (splash/transition screen) |

### Visual Rhythm & Repetition
| Token | Value/range | Source | Confidence | UI application |
|--------|---------|------|--------|---------|
| color-cycle-speed | Full cycle 10-60 min | Aten Reign, Roden Crater cycle | B | Background color auto-change period (abbreviated to 2-10s in UI) |
| kelvin-shift-rate | 200-500K change per hour | Natural light sunrise-sunset color temperature change rate | B | Time-of-day color temperature transition speed |
| concentric-rhythm | Concentric ellipses/circles in 2-5 layers | Aten Reign structure | B | Repetition structure of overlaid elements |
| breath-animation | Brightness ±5-10% subtle oscillation, period 4-8s | Turrell installation breathing effect observation | C | Subtle background brightness change animation (breathing effect) |
| dawn-dusk-symmetry | Sunrise and sunset color sequences are symmetric | Roden Crater program analysis | C | App start (warm tones) ↔ exit (cool tones) color symmetry |

## Key Works Analysis

### 1. Aten Reign (2013)
- **Scale**: Entire rotunda of the Solomon R. Guggenheim Museum (height approx. 28m, width approx. 18m)
- **Collection**: Temporary installation (2013.6-9)
- **Composition**: Installed 5 layers of concentric elliptical fabric screens along the spiral ramp of the Guggenheim circular rotunda. Individual LED lighting in each layer transformed color independently. Color progressed differently from the outermost to the innermost layer.
- **Color cycle**: Cycled the full spectrum — red→orange→pink→purple→blue→green and so on — over an approximately 45-minute cycle. Each layer changed with a time offset, so the contrast between concentric circles continuously shifted.
- **Kelvin range**: Cycled a range of approximately 2200K (reddish orange) ~ 8000K (cool blue).
- **UI translation**: Concentric overlay structure. In a 5-stage depth modal/sheet system, each layer has an independent color.
  ```css
  .aten-layer-1 { background: rgba(255, 140, 66, 0.9); }
  .aten-layer-2 { background: rgba(232, 126, 176, 0.85); }
  .aten-layer-3 { background: rgba(184, 64, 160, 0.8); }
  .aten-layer-4 { background: rgba(64, 96, 192, 0.75); }
  .aten-layer-5 { background: rgba(26, 32, 96, 0.7); }
  ```

### 2. Roden Crater (1979-ongoing)
- **Scale**: Entire extinct-volcano crater in the Arizona desert (diameter approx. 400m)
- **Collection**: Skystone Foundation
- **Composition**: Excavated 6 or more tunnels and chambers inside the crater. Precise apertures in each chamber let light enter at specific angles aligned with particular astronomical phenomena (sunrise, sunset, summer solstice, winter solstice, moonrise). Under construction over several decades.
- **Color temperature experience**: Exterior (bright, 5500K) → entry tunnel (progressive darkness, 10-15 min adaptation time) → chamber interior (full darkness or pure skylight through the aperture). The transition from light to dark and back to light is the core experience.
- **UI translation**: An archetype for onboarding/mode transitions. Light mode → transition screen (2-3s, mid-tone) → dark mode. Induce gradual adaptation rather than an abrupt transition. `transition: background-color 3s ease-in-out`.

### 3. Akhob (2013, permanent installation)
- **Scale**: Inside Louis Vuitton Las Vegas CityCenter, a 2-story-high space
- **Collection**: Louis Vuitton (permanent installation)
- **Composition**: A pure Ganzfeld experience space. As the viewer walks up a ramp, homogeneous colored light fills the entire visual field. The boundaries of floor, wall, and ceiling disappear, creating the feeling of floating in infinite color space. Color transitions gradually over a 10-minute cycle.
- **Ganzfeld effect**: Loss of depth perception, distortion of spatial sense, a sensation of "floating" within colored light. Viewers may stagger, requiring safety assistance.
- **UI translation**: Immersive media playback screens, meditation app backgrounds, VR/AR environment color. UI where "the environment itself" rather than content is the experience. `position: fixed; inset: 0; background: #B840A0; transition: background-color 5s;`

## UI Application Mapping

### Translation Rules

1. **Color temperature system**: Automatically adjust UI color temperature by time of day.
   ```css
   /* Morning (6-9): warm tones */
   :root[data-time="morning"] {
     --bg: #FFF8E8;           /* ≈3500K */
     --surface: #FFFAF0;
     --accent: #FF8C42;
   }
   /* Day (9-17): neutral tones */
   :root[data-time="day"] {
     --bg: #F0F0F8;           /* ≈5000K */
     --surface: #FAFAFE;
     --accent: #4060C0;
   }
   /* Night (17-22): cool tones */
   :root[data-time="night"] {
     --bg: #1A2060;           /* ≈7500K → warm dark */
     --surface: #2A3080;
     --accent: #E87EB0;
   }
   ```

2. **Ganzfeld immersive mode**: Create an experience that "envelops" the user with a full-screen solid background. Minimize content so the color field itself becomes the experience.
   ```css
   .ganzfeld-mode {
     position: fixed;
     inset: 0;
     background: var(--immersive-color);
     transition: background-color 5s ease-in-out;
   }
   ```

3. **Boundary dissolution**: Reduce container borders and separate regions with color gradients. `border: none`, `border-radius: 0`, instead use `background` differences and `backdrop-filter: blur()`.

4. **Gradual transition**: Apply slow 2-5s transitions to mode changes (light/dark) and screen transitions. Abrupt change directly violates Turrell's aesthetic.
   ```css
   * { transition: background-color 2s ease-in-out, color 1.5s ease; }
   ```

5. **Concentric layers**: Overlay modals, sheets, and overlays concentrically. Assign each layer an independent color (brightness/hue variation).

6. **Breathing effect**: Subtly oscillate background brightness within a ±5% range on a 4-8s period. A change at a level the user does not consciously perceive.
   ```css
   @keyframes breathe {
     0%, 100% { opacity: 1; }
     50% { opacity: 0.95; }
   }
   .breathing-bg { animation: breathe 6s ease-in-out infinite; }
   ```

### Suitable UI Types
- **Meditation/wellness apps**: Ganzfeld immersive mode, breathing animation, automatic color temperature adjustment
- **Sleep/night mode**: Warm color temperature (2700K), extremely low brightness, gradual darkening
- **Media players**: Full-screen immersion, background filled with album-art color
- **VR/AR interfaces**: Environment color adaptation, spatial sense control, depth perception adjustment
- **Luxury brands**: UI where colored-light experience becomes brand identity, like Akhob
- **Exhibition/museum apps**: Color temperature adapted to the viewing environment, harmony between artwork and UI
- **Smart home control**: Lighting color temperature integration, unified control of time-space-emotion

### Cautions
- **No abrupt color transitions**: Color changes must have a transition time of at least 2 seconds. `transition-duration: 0.3s` directly violates Turrell's aesthetic. Maintain a speed where the user "senses but is not startled by" the change.
- **No high-contrast patterns**: Turrell's light is homogeneous and soft. Sharp boundaries, checkerboards, and stripe patterns destroy the aesthetic.
- **Unsuitable for small elements**: These tokens are effective only when applied to large surfaces covering 30% or more of the screen. They have no effect on small elements such as icons and buttons.
- **Ensure text legibility**: Text over bright colored-light backgrounds must secure sufficient contrast. Comply with the WCAG AA standard (4.5:1). When needed, use `text-shadow` or a translucent background panel.
- **Consider battery/performance**: Continuous background-color change animations consume battery. Enable GPU acceleration with `will-change: background-color`, `transform: translateZ(0)`, and pause animations in the background.
- **Beware Ganzfeld overuse**: A full-screen solid color is powerful, but applying it to every screen destroys content accessibility. Activate it only in specific modes (meditation, music playback).
- **Color temperature auto-adjustment opt-out**: Always provide an option for the user to disable automatic color temperature changes. It may give an unintended experience to users with color vision deficiency.
- **Physical environment dependency**: Turrell's works are optimized for physical space. Screens are affected by ambient lighting, so recommend using the ambient light sensor API while preparing a fallback.
