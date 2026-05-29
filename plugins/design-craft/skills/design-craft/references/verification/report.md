# Design Token Verification Report

## Verification Summary
- sync basis: `unified-tokens.md`, `conflicts.md`, `platform-ios.md`, `platform-web.md`, `platform-android.md`, `platforms/*.md`, and related designer/artist source documents
- audited corpus: 59 deterministic checks (`source credibility 20 + numeric accuracy 22 + internal consistency 17`) + 3 `UNVERIFIABLE` inventory items per the round-001 basis (reduced to 0 remaining in round-004)
- PASS: 52 / WARNING: 7 / FAIL: 0 / UNVERIFIABLE: 0
- baseline note: round-001 removed prior drift and fixed the baseline against the current documents (PASS 44 / WARNING 15 / FAIL 0 / UNVERIFIABLE 3).
- round-002 delta: added a `Source grade (lowest)` column to `unified-tokens.md`, resolving all 8 source-credibility WARNINGs. The primary metric dropped from WARNING 15 → 7.
- round-003 delta: added Riley/Turrell/Rothko accessibility warning annotations to `unified-tokens.md` and `platform-{ios,web,android}.md`, closing hard gate 2. The WARNING total stayed at 7.
- round-004 delta: reduced the 3 `UNVERIFIABLE` items for Riley/Turrell/Rothko to allow/conditional/forbid rules via a token-level accessibility usage envelope in `unified-tokens.md` and implementation checklists in `platform-{ios,web,android}.md`. The WARNING total stayed at 7 and `UNVERIFIABLE` went 3 → 0.

## 1. Source Credibility Verification (20 checks → PASS 20 / WARNING 0 / FAIL 0)

### Retained PASS inventory
- `touch-target-min`
- `corner-radius-small`
- `system-blue`
- `separator-color`
- `cognitive-chunk-max`
- `mondrian-red`
- `rothko-surface-dark`
- `lee-canvas-white`
- `turrell-kelvin`
- `riley-bw`
- `albers-nesting-levels`
- `font-family-count`

### Mixed-grade inventory resolved in round-002
| Token | round-001 issue | round-002 resolution |
|---|---|---|
| `base-unit` | `Ive(S)` and `Tschichold/Kare(F)` contributions were not distinguished within one row. | Stated `Source grade (lowest)=F` so the low-credibility contribution is not hidden. |
| `grid-base` | `Dye/Won(S)`, `Matas(B)`, and `Rams/Vignelli/Brockmann(F)` were mixed together. | Marked `Source grade (lowest)=F` so the 8pt UI-conversion source does not appear as an official value. |
| `body-size` | The mixed rationale of `Ive(S)`, `Norman(D/C)`, and `Matas(A)` was listed in one row without grades. | Marked `Source grade (lowest)=D` to surface the strength of the mixed cross-platform rationale. |
| `whitespace-ratio` | `Ive(B)`, `Rand(A)`, and `Brockmann(A)` appeared at the same confidence. | Marked `Source grade (lowest)=B` to expose the mix of measured and interpretive values. |
| `accent-usage` | `Rams(B)`, `Mondrian(C)`, and `Rand(D)` appeared as peers in the conflict-resolution row. | Marked `Source grade (lowest)=D` to make clear that the context-separation rule is not a high-credibility single value. |
| `disabled-opacity` | Based on `Norman(A)`, but the interpretive range was hidden in the token table. | Fixed the rationale strength at `Source grade (lowest)=A` to reduce interpretive room on reuse. |
| `easing-minimal` | The interpretive UI conversion (F) of `Rams` and `Brockmann` appeared as a default value. | Stated `Source grade (lowest)=F` to reveal it as an auxiliary reference. |
| `gradient-usage` | A conflict-resolution row, but the credibility difference between structural UI and immersive-background rules was absent from the table. | Marked `Source grade (lowest)=F` to expose its interpretive/context-separation nature. |

## 2. Numeric Accuracy Verification (22 checks → PASS 17 / WARNING 5 / FAIL 0)

### PASS inventory
- iOS: `touch-target-min`, `screen-margin-compact`, `body-size`, `system-blue`, `bg-secondary`, `separator-color`
- Web: `body-size`, `contrast-ratio-text`, `line-height-ratio`, `disabled-opacity`
- Android: `touch-target-min`, `screen-margin-regular`, `corner-radius-small`, `corner-radius-medium`, `body-size`, `depth-layers`, `headline-size`

### WARNING inventory
| Area | Token | Current verdict | Rationale |
|---|---|---|---|
| iOS | `corner-radius-small` | WARNING | `platform-ios` fixes the unified `6-8pt` range to 8pt. The Apple official summary is 8pt and the `Ive` measurement is 6-8pt, so the numeric spread remains. |
| iOS | `corner-radius-medium` | WARNING | `platform-ios` adopts 13pt for the unified `10-13pt` range. The card/sheet 12pt of the Apple official summary and `Alan Dye`'s 13pt coexist with a 1pt difference. |
| iOS | `corner-radius-large` | WARNING | unified `16-22pt` and `platform-ios` 22pt can match, but the Apple official summary only has the 12pt sheet-centric value, so the large-radius rationale leans toward the designer doc. |
| Web | `touch-target-min` | WARNING | `platform-web` adopts 44px. This is more conservative than the WCAG 2.2 AA minimum of 24px and is an AAA-level choice, so the criterion level must be stated. |
| Android | `corner-radius-large` | WARNING | `platform-android` keeps M3 `16.dp` as default and annotates that `corner-radius-xl 28.dp` should be used when iOS visual parity is required. The spec-first vs. visual-parity-first strategy has not yet converged to a single choice. |

## 3. Internal Consistency Verification (17 checks → PASS 15 / WARNING 2 / FAIL 0)

### PASS inventory
- unified vs conflicts: `gradient-usage`, `whitespace-ratio vs void-ratio`, `corner-radius`, `base-unit`, `accent-usage`, `font-size-ratio`
- cross-platform: `base-unit`, `body-size`, `touch-target`, `disabled-opacity`
- conflict resolution: `base-unit`, `gradient`, `corner-radius`, `font-family-count`, `accent-area`

### WARNING inventory
| Item | Current verdict | Rationale |
|---|---|---|
| `corner-radius-large` cross-platform parity | WARNING | iOS/Web are 22pt/22px, Android default is 16dp. A correction annotation was added to `platform-android` so this is not a FAIL, but one token name simultaneously points to two visual strategies. |
| `depth-layers` cross-platform parity | WARNING | unified branches into `iOS 3 levels / Android 5 levels`, resolving the prior FAIL, but the same token name still hides differing layer cardinalities. A separate alias or platform suffix is needed. |

## 4. UNVERIFIABLE inventory (0 remaining)

In round-004, the 3 items left over from round-001~003 were reduced not via a **new empirical study** but via a **conservative token-level usage envelope** combining the original artist documents with the accessibility criteria in `platforms/*.md`. That is, the `UNVERIFIABLE` items were eliminated, but this is an operational resolution that specifies allow/conditional/forbid rules for product application, not an overwrite of the original art research.

| Item | round-004 resolution rule | Rationale bundle | Remaining verdict |
|---|---|---|---|
| Accessibility-safe range of `Riley`'s high-contrast stripes (`riley-bw`, `riley-stripe-width`) | Added a rule to `unified-tokens.md`: allow only for loading/dividers/decorative panels, pattern area ≤ 50%, maintain ≥ 2px, forbid content backgrounds and multi-period overlaps. Reinforced `platform-web.md` and others with a reduce-motion / no-focus-background checklist. | `bridget-riley.md`'s stripe-width 2-20px, breathing-contrast 50% whitespace, no large-area/content backgrounds + `platforms/web.md` WCAG 2.2 contrast/focus criteria | resolved (conservative envelope) |
| Accessibility-safe range of `Turrell`'s color temperature / breathing (`turrell-kelvin`, `turrell-breath`) | Reduced to rules: ambient surface ≥ 30%, prefer fixed presets, automatic change is opt-in + opt-out, transition ≥ 2s, breathing ±5%/4-8s, stop/crossfade under reduce-motion. | `james-turrell.md`'s small-element unsuitability, 2-5s gradual transition, breath 4-8s, opt-out caution + `platforms/apple.md`/`platforms/android.md` surface/motion criteria | resolved (conservative envelope) |
| Text/boundary legibility range of `Rothko`'s dark surface (`rothko-surface-dark`) | Documented rules: body text 4.5:1, large text/icon/separator/input border 3:1, long-form text on a separated panel, no pure black/texture, no fast transitions under 500ms. | `rothko.md`'s surface-0~3, no pure black, no texture, slow transition 500-2000ms + `platforms/web.md` WCAG AA text/non-text criteria | resolved (contrast matrix + surface rule) |

## 5. Notes on the Current Hard Gates
- hard gate 1 (source-grade annotation on every token in `unified-tokens.md`): **met** — the `Source grade (lowest)` column is filled for 122/122 tokens.
- hard gate 2 (accessibility warning annotations on the Riley/Turrell/Rothko risk tokens): **met** — added `riley-bw`, `riley-stripe-width`, `turrell-kelvin`, `turrell-breath`, `rothko-surface-dark` warning annotations to `unified-tokens.md` and `platform-{ios,web,android}.md`.
- hard gate 3 (alternative verification results or range estimates for the 3 `UNVERIFIABLE` items): **met** — round-004 added token-level usage envelopes / implementation checklists to `unified-tokens.md` and `platform-{ios,web,android}.md`, reducing all 3 to allow/conditional/forbid rules.

## 6. Priority Recommendations
1. **stop condition met**: with WARNING 7, UNVERIFIABLE 0, and hard gates passing, terminating the loop (`control_action=stop`) is appropriate within this contract scope.
2. follow-up optional task (out-of-contract optimization): reorganize `corner-radius-large` and `depth-layers` via token split or platform alias to reduce the 2 remaining cross-platform WARNINGs.
