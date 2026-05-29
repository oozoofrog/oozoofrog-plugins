# Apple HIG Lookup Pattern Guide

> Guide used by harness-design-architect / harness-design-implementer when referencing Apple HIG.
> This document is not the HIG source text but a **lookup strategy + core rules for immediate reference**.

## HIG 3 Principles

- **Hierarchy**: Controls and interface elements float above content, forming a clear visual hierarchy
- **Harmony**: Concentric design in harmony between hardware and software
- **Consistency**: Follow platform conventions to adapt consistently across window sizes and displays

## Conditional DocumentationSearch Strategy

The Designer has already loaded the base iOS rules via `get_guidelines(topic="mobile-app")`.
**Run additional lookups only under the conditions below**:

### When a lookup is needed (content not in Claude's training data)

| Condition | Query | Reason |
|------|------|------|
| Using Liquid Glass | `"Liquid Glass materials design"` | New iOS 26 material, after training cutoff |
| iOS 26 component migration | `"Adopting Liquid Glass visual refresh"` | Floating tab bar, scroll edge, etc. are new |
| Glass color tinting | `"Color Liquid Glass color"` | Tinting rules are new |

### When a lookup is unnecessary (already known to Claude)

| Topic | Reason | Reference instead |
|------|------|--------------|
| Safe Area, layout | Base rules unchanged for years | Foundation checklist below |
| SF Pro typography | Same since iOS 14+ | Typography quick reference below |
| Semantic colors | Well-documented API | Color quick reference below |
| Dynamic Type, VoiceOver | Accessibility basics | Foundation checklist below |
| Dark Mode | Same since iOS 13+ | apple-craft reference docs |

### Graceful Degradation

When DocumentationSearch fails:
- Proceed with this document's checklist + quick references (no network needed)
- Record "⚠️ HIG dynamic lookup failed, based on static reference" in {HARNESS_DIR}/design-spec.md

---

## Liquid Glass Core Rules (immediate reference)

Since this is new iOS 26 content not in Claude's training data, the essentials are summarized here:

1. **Do not use Liquid Glass on the content layer** — controls/navigation layer only
2. **Use effects sparingly** — apply only to the most important functional elements. Overuse disrupts content
3. **Regular vs Clear**:
   - Regular: background blur + luminance adjustment, text-heavy elements (alerts, sidebars, popovers)
   - Clear: high transparency, only over media backgrounds (photos/videos)
4. **Clear + dimming**: on a bright background, add a 35% dark dimming layer
5. **Restrained color tinting**: only on the background of emphasis elements (e.g., Done button). No background color on multiple controls
6. **Both modes required**: even a single-mode app must provide both Light/Dark colors (Glass adaptability)
7. **Test accessibility auto-adaptation**: Reduce Transparency, Increase Contrast, Reduce Motion

---

## HIG Foundation Checklist (shared by Designer/Builder/Evaluator)

### Required (Foundation) — must be satisfied

- [ ] Safe Area compliance (Status Bar, Home Indicator, Dynamic Island)
- [ ] Touch target minimum 44×44pt
- [ ] Use semantic colors (systemBackground, label, separator, etc.)
- [ ] Dark Mode support (provide both colors)
- [ ] Dynamic Type support (body, headline minimum)
- [ ] accessibilityLabel — all interactive elements
- [ ] Navigation Back gesture works
- [ ] Keyboard dismiss handling
- [ ] Contrast ratio 4.5:1 or higher (WCAG AA, 18pt+ or Bold is 3:1)
- [ ] Liquid Glass only on the controls/navigation layer (no content layer)

### Free (Expression) — free on top of Foundation

- Color palette (custom allowed on top of HIG semantics)
- Typography weight/size (SF Pro based, custom fonts also allowed)
- Card/section form (cornerRadius, shadow, material free)
- Layout composition (Grid, Bento, custom free)
- Animation/transition effects (Reduce Motion support required)
- Icon style (SF Symbols weight/rendering free)
- Information structure (hierarchy/grouping approach free)

---

## SwiftUI Semantic Colors Quick Reference

| HIG Semantic | SwiftUI | Use |
|-----------|---------|------|
| Background | Color(.systemBackground) | Base background |
| Secondary BG | Color(.secondarySystemBackground) | Group/card background |
| Tertiary BG | Color(.tertiarySystemBackground) | Nested group |
| Label | Color(.label) | Base text |
| Secondary Label | Color(.secondaryLabel) | Secondary text |
| Separator | Color(.separator) | Divider |
| Accent | Color.accentColor | Emphasis/brand |
| Tint | .tint(.blue) | Interactive |

## Typography Quick Reference

| Text Style | iOS Size | Weight | SwiftUI |
|-----------|----------|--------|---------|
| Large Title | 34pt | Regular | .largeTitle |
| Title 1 | 28pt | Regular | .title |
| Title 2 | 22pt | Regular | .title2 |
| Title 3 | 20pt | Regular | .title3 |
| Headline | 17pt | Semibold | .headline |
| Body | 17pt | Regular | .body |
| Callout | 16pt | Regular | .callout |
| Subheadline | 15pt | Regular | .subheadline |
| Footnote | 13pt | Regular | .footnote |
| Caption 1 | 12pt | Regular | .caption |
| Caption 2 | 11pt | Regular | .caption2 |

Platform default/minimum: iOS 17pt/11pt, macOS 13pt/10pt, watchOS 16pt/12pt, visionOS 17pt/12pt

## Cost Estimate

| Item | Tokens | Cost |
|------|------|------|
| Reading this document | ~2K | ~$0.005 |
| 1 DocumentationSearch | ~2K | ~$0.005 |
| Worst case (read + 3 lookups) | ~8K | ~$0.02 |
| vs. full harness | | <0.5% |
