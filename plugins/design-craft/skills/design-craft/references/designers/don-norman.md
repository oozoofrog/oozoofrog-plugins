# Don Norman -- Design Token Dictionary

## Profile
- **Active period**: 1980s-present, key book 1988 ("The Design of Everyday Things")
- **Main affiliations**: UCSD cognitive science professor, Apple Advanced Technology Group(1993-1998), Nielsen Norman Group co-founder(1998)
- **Key contributions**: established affordance/signifier concepts, popularized "user-centered design (UCD)", 3-level emotional design model, popularized the term "UX"
- **Design lineage**: James J. Gibson(ecological psychology) → Norman(cognitive science UX) → all of modern UCD/HCI

## Design Philosophy (quantifiable principles)

| Principle | Quantitative conversion | Measurement basis |
|------|----------|----------|
| Affordance | Visual cues on 95%+ of operable elements | First-time success rate in usability testing |
| Signifier | At least 2 visual distinctions on interactive elements (color+shape etc.) | Number of visual cues |
| Feedback | Response ≤ 100ms after user action | Latency |
| Mapping | Control-result spatial match rate 100% | Natural mapping ratio |
| Constraint | 80%+ blocking rate of error-prone paths | Defensive UI ratio |
| Conceptual Model | System-state visibility 90%+ | User mental-model match rate |
| Error Tolerance | Undoable actions 95%+, destructive actions confirmation dialog 100% | Recoverability |

## Quantitative Design Tokens

### Layout & Spacing

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| cognitive-chunk-max | 7 ±2 items (major element groups per screen) | Miller's Law (1956) | C |
| nav-depth-max | ≤ 3 levels (depth limit) | Norman "3-click rule" variant | D |
| choices-per-screen | ≤ 7 items (major choices) | Hick's Law optimal range | C |
| grouping-proximity | Spacing between related elements ≤ 50% of spacing between unrelated elements | Gestalt proximity principle | C |
| visual-hierarchy-levels | 3-4 levels (title/subtitle/body/caption) | Norman cognitive-load recommendation | D |
| action-zone | Key CTA within thumb reach (bottom 1/3 area) | Steven Hoober research (2013) | C |
| fitts-target-min | 44x44pt (touch), 24x24pt (pointer) | Fitts's Law + Apple/Google HIG | S |
| label-proximity | Label-field spacing ≤ 8pt (visual connection) | Gestalt proximity | C |
| error-message-proximity | ≤ 4pt from the field where the error occurred | Norman feedback-immediacy principle | D |
| whitespace-cognitive | Margin between information blocks ≥ 16pt | Minimum spacing for cognitive separation | C |

### Typography

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| readable-line-length | 45-75 chars/line (optimal 60 chars) | Baymard Institute readability research | C |
| font-size-min | 16px (mobile body minimum) | WCAG + readability research | C |
| font-size-body | 16-18px (desktop), 16px (mobile) | NN/g readability recommendation | D |
| contrast-ratio-normal | ≥ 4.5:1 (AA), ≥ 7:1 (AAA) | WCAG 2.1 | S |
| contrast-ratio-large | ≥ 3:1 (AA), ≥ 4.5:1 (AAA) — 18pt+ text | WCAG 2.1 | S |
| heading-scale-ratio | 1.2-1.5x (step-wise increase) | Typographic scale convention | C |
| label-weight | Field label ≥ medium(500) — distinct from body | Norman signifier principle | D |
| error-text-color | Red + icon (dual coding for color-vision deficiency) | Norman dual-coding principle | D |
| instruction-text | No gray text — guarantee 4.5:1 contrast | WCAG + NN/g | C |
| text-alignment | Left alignment default (LTR) — no justified alignment | Readability research | C |

### Color & Surface

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| status-success | Green + check icon (dual coding) | Norman dual coding | D |
| status-error | Red + warning icon (dual coding) | Norman dual coding | D |
| status-warning | Orange/yellow + caution icon | Norman feedback principle | D |
| status-info | Blue + info icon | Norman feedback principle | D |
| interactive-distinction | Interactive element color ≠ non-interactive — minimum 3:1 contrast | Signifier principle | D |
| focus-indicator | 2px+ outline, 3:1 contrast against background | WCAG 2.2 Focus Visible | S |
| disabled-opacity | 0.38-0.5 (clear distinction of disabled state) | Material Design + Norman constraint | A |
| selected-state | Background-color change + check mark (dual coding) | Norman visibility principle | D |
| color-alone-never | No information conveyed by color alone — always paired with shape/text | WCAG 1.4.1 + Norman | S |
| palette-functional | Meaning-based color — use semantic tokens | Norman mapping principle | D |

### Shape & Curvature

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| button-min-size | 44x44pt (touch), 24x24px (pointer) | Fitts's Law + HIG | S |
| button-padding | Horizontal 16-24pt, vertical 8-12pt | Securing touch area + label readability | A |
| clickable-affordance | Button: background color + rounding + elevation (optional) | Triple affordance cue | D |
| link-affordance | Underline + color distinction (at least 2 cues) | Signifier dual coding | D |
| input-border | 1-2px solid border — clear distinction of input area | Affordance boundary indication | D |
| icon-with-label | No icon-only usage — pair with label (on first use) | Norman mapping principle | D |
| icon-size-min | 24x24pt (securing visibility) | NN/g icon research | C |
| toggle-size | Minimum 48pt width (space to distinguish on/off state) | Affordance + Fitts | D |
| form-field-height | 40-48pt (touch), 32-40px (desktop) | Touch target + readability | A |
| progress-indicator | Progress visualization required — for 3s+ tasks | Norman feedback principle | D |

### Interaction & Motion

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| response-instant | ≤ 100ms (perception of instant response) | Jakob Nielsen 3-level response time | C |
| response-seamless | ≤ 1s (maintains continuity) | Nielsen response-time research (1993) | C |
| response-attention | ≤ 10s (attention-retention limit) | Nielsen response-time research | C |
| loading-feedback | Spinner above 1s, progress indicator above 3s | Norman feedback principle + Nielsen | C |
| undo-availability | 100% undo provided for destructive actions | Norman error-tolerance principle | D |
| confirm-destructive | Confirmation dialog required before delete/irreversible actions | Norman constraint principle | D |
| error-recovery-time | Error detection→correction ≤ 15s (average) | Usability research benchmark | C |
| hick-response-time | RT = a + b·log₂(n+1) — n choices | Hick's Law (1952) | C |
| fitts-movement-time | MT = a + b·log₂(2D/W) — distance D, width W | Fitts's Law (1954) | C |
| animation-purpose | State-transition explanation only — no decorative animation | Norman feedback principle | D |
| transition-cognitive | 0.2-0.4s (range maintaining cognitive continuity) | NN/g animation research | C |

### Cognitive-Law Quantitative Tokens

| Token | Formula/value | Source | Confidence |
|--------|---------|------|--------|
| millers-law | Working-memory capacity = 7 ±2 chunks | George Miller (1956) | C |
| hicks-law | Response time = a + b·log₂(n+1) | Hick (1952), Hyman (1953) | C |
| fitts-law | Movement time = a + b·log₂(2D/W) | Paul Fitts (1954) | C |
| jakobs-law | Users form expectations based on experience with existing sites | Jakob Nielsen | D |
| teslers-law | Conservation of complexity — there is a minimum complexity the system must absorb | Larry Tesler | D |
| doherty-threshold | Response ≤ 400ms → maintains engagement | Doherty & Thadhani (1982) | C |
| peak-end-rule | Experience evaluation = peak emotion + end emotion | Kahneman (1993) | C |
| serial-position | Recall rate of first + last items ≥ 70% | Ebbinghaus (1885) | C |
| von-restorff | Recall rate of visually distinct items increases 2-3x | Von Restorff (1933) | C |
| zeigarnik-effect | Recall rate of incomplete tasks 90%+ (2x vs. completed) | Zeigarnik (1927) | C |

### Emotional Design Tokens (Emotional Design 3 levels)

| Token | Value/range | Source | Confidence |
|--------|---------|------|--------|
| visceral-first-impression | Visual appeal judged within first 50ms | Lindgaard et al. (2006) | C |
| visceral-color-warmth | Warm colors(red/orange/yellow) = active, cool colors(blue/green) = calm | Color psychology research | C |
| behavioral-task-success | Task completion rate ≥ 95% (good usability) | NN/g benchmark | D |
| behavioral-error-rate | Error rate ≤ 5% (good usability) | NN/g benchmark | D |
| behavioral-efficiency | Novice time vs. expert ≤ 2x | Usability research benchmark | C |
| reflective-brand-trust | NPS ≥ 50 (high recommendation intent) | Net Promoter Score benchmark | D |
| reflective-delight | Unexpected positive moment ≥ 1/session | UX emotional research | D |

## Changes Over Time

| Period | Turning point | Key numerical change |
|------|--------|---------------|
| 1988 | "The Design of Everyday Things" first edition | Affordance concept popularized → spread of 3D effects on UI buttons |
| 1993-1998 | Work at Apple ATG | Official use of the term "UX", start of quantifying user testing |
| 2002 | "Emotional Design" published | Visceral/behavioral/reflective 3 levels → introduction of emotional metrics |
| 2004 | "Signifier" concept separated | Clarified distinction between affordance(physical) ≠ signifier(cognitive) |
| 2013 | "The Design of Everyday Things" revised edition | Formal introduction of signifier, large addition of digital UI examples |
| 2023+ | AI/LLM era | Autonomous-agent UX, redefinition of cognitive load in conversational interfaces |

## Influence Relationships

- **James J. Gibson → Norman**: Transplanted the "affordance" concept from ecological psychology into the design domain
- **Gestalt psychology → Norman**: Converted proximity/similarity/continuity/closure principles into UI layout principles
- **Norman → Apple HIG**: Directly reflected cognitive-science principles into HIG during his 1993-1998 tenure at Apple
- **Norman → WCAG**: Indirect influence of cognitive-load and dual-coding principles on accessibility standards
- **Norman ↔ Jakob Nielsen**: Nielsen Norman Group — 10 usability heuristics complement Norman's principles
- **Norman → all of modern UCD**: "user-centered design" methodology is the basis of the ISO 9241-210 standard
- **Key references**: "The Design of Everyday Things" (1988/2013 revised), "Emotional Design" (2004), "Living with Complexity" (2010)

## Norman 7-Stage Action Model → UI Checklist

| Stage | Description | UI token/check |
|------|------|-------------|
| 1. Form goal | What the user wants to achieve | Does the screen title reflect the goal |
| 2. Form intention | Deciding what action to take | Does the CTA label state the action ("Save", "Delete") |
| 3. Specify action | Concrete operation plan | Is the operation sequence natural (left→right, top→bottom) |
| 4. Execute action | Click/tap/input | Touch target ≥ 44pt, click feedback ≤ 100ms |
| 5. Perceive state | Perceiving system response | Visual/auditory/haptic feedback present |
| 6. Interpret state | Understanding the meaning of the response | Clear success/failure message, dual coding |
| 7. Evaluate outcome | Judging whether the goal was achieved | Completion-state visualization (check, progress 100%) |

## UI Application Mapping

| Norman principle | Modern UI token conversion rule |
|-------------|----------------------|
| Affordance | Give buttons background color+rounding+hover effect, minimize flat text buttons |
| Signifier | At least 2 visual cues on interactive elements (color+shape, color+underline, etc.) |
| Feedback | Visual/auditory/haptic response within 100ms on every action, spinner when loading exceeds 1s |
| Mapping | Slider left→right = increase, toggle right = ON — natural directional match |
| Constraint | Disable impossible actions(`disabled`), block invalid input in real time |
| Conceptual Model | Always make system state visible (breadcrumbs, progress indicator, current location) |
| Error Tolerance | Provide Ctrl+Z, confirm before delete, trash-bin pattern, 30-day recovery |
| Dual coding | No meaning conveyed by color alone — pair with icon/text/pattern |
| Cognitive load | Choices per screen ≤ 7, steps ≤ 3, information grouping required |
| Fitts's Law | Make frequently used CTAs large(≥ 48pt), use screen edges/corners |
