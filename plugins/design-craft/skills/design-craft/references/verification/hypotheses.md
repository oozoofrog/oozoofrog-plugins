# Design Token Hypotheses

Five testable hypotheses derived from the verification report.

## H1: corner-radius-large cross-platform equivalence

```
H: If corner-radius-large is set to iOS 22pt / Android 16dp,
   then for the same card component the roundedness perceived by iOS users
   and the roundedness perceived by Android users are not visually equivalent.
Source: Ive(B), Dye(S), M3 Shape(S)
Test method: Render an identically proportioned card (16:9) on both platforms and
          have 10 users rate "degree of roundedness" on a 5-point scale.
          Additionally compute and compare the physical curvature ratio (corner-radius / shorter side of the component).
Refutation condition: Reject if the 5-point-scale mean difference is within 0.5 and the curvature ratio difference is within 10%.
```

## H2: Misapplication due to omitted F-grade token labeling

```
H: If source-reliability grades are omitted from the unified token dictionary,
   then F-grade-source tokens (grid-base-ui Rams, easing Rams, transition-duration Vignelli)
   are applied with the same confidence as S-grade tokens, producing results that diverge from the original designer's intent.
Source: Rams grid-base-ui(F), Rams easing(F), Vignelli transition-duration(F)
Test method: Give 5 designers who implement UI with unified tokens a graded version and an ungraded version,
          then compare a "confidence (1-5)" survey for the F-grade tokens.
          Measure the frequency of alternative exploration for F-grade tokens.
Refutation condition: Reject if the F-grade token confidence difference is within 0.3 regardless of whether grades are labeled.
```

## H3: Readability impact of a 0.1 line-height difference on Web

```
H: If Web body text (16px) is set to a line-height of 1.4,
   then compared with the WCAG recommendation (1.5) the readability score of mixed Hangul text drops significantly.
Source: web.md Body line-height 1.5(S), unified line-height-ratio 1.2-1.4
Test method: Render the same mixed Hangul-Latin text at line-height 1.4 and 1.5,
          and compare reading speed (WPM) and subjective readability (7-point Likert) across 20 participants.
          Additionally compare against applying the line-height-korean(1.5-1.6) token.
Refutation condition: Reject if the reading-speed difference is within 5% and the subjective-readability difference is within 0.5 points.
```

## H4: depth-layers 3-tier vs 5-tier perceptual distinction

```
H: If depth-layers is limited to 3 tiers (base/raised/overlay),
   then compared with 5 tiers (M3 Level 0-5) users can distinguish the depth hierarchy
   of cards/sheets/modals equally well.
Source: Dye(S) 3 tiers, M3 Elevation(S) 6 tiers
Test method: Build prototypes implementing the same layout with 3-tier depth and 5-tier depth,
          and have 15 users judge "Is this element above the others?".
          Measure accuracy rate and judgment time.
Refutation condition: If the depth-distinction accuracy of the 3-tier implementation is below 85%,
          or is 15pp or more lower than the 5-tier implementation, reject H4 and recommend adopting 5 tiers.
```

## H5: Does the accent-usage 5-15% range cover every context?

```
H: If accent-usage is unified to 5-15%,
   then minimal UI (Rams intent: under 5%) suffers accent overuse,
   and brand-emphasis UI (Rand intent: 30-50%) suffers accent shortage.
Source: Rams accent-usage(B, under 5%), Mondrian(C, 15-30%), Rand(D, 30-50%)
Test method: For 3 contexts (minimal utility, standard app, brand landing),
          produce 5 variants at accent-usage 5%/10%/15%/25%/35%,
          and collect 10 designers' preferences for "the accent ratio suited to this context".
Refutation condition: Reject if a value within the 5-15% range is the top preference in all 3 contexts.
          If a value outside the range is the top preference in even one, accept the hypothesis — the unified range needs to be reset.
```
