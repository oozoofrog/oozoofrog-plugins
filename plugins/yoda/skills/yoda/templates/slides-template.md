# Slides (Marp) Output Template

Marp presentation structure template for the `--format slides` output of yoda share mode.

---

## 15-Slide Structure

| # | Slide | Content | Cognitive Apprenticeship Stage |
|---|---------|------|----------------|
| 1 | Hook | Provocative question — runs through the entire talk | — |
| 2-3 | Context | Background + actual code | Modeling |
| 4-6 | Mental Model | Build the concept gradually (1 slide = 1 concept) | Coaching |
| 7-8 | Before | Problem code + highlight the problem spots | Scaffolding |
| 9 | Why | Distill the core reason | Scaffolding |
| 10 | After | Fixed code (core changes only) | Fading |
| 11 | Aha Insight | The key realization in one sentence | Fading |
| 12-13 | Generalization | Generalize the pattern + summarize the principle | Exploration |
| 14 | CTA | 3 action items + answer to the Hook | Exploration |
| 15 | Resources | References + metacognitive question | Exploration |

## Slide Authoring Rules

- 1 slide = 1 concept (minimize text density)
- Excerpt only the core 3-5 lines of each code block
- Mark problem spots with `// ⚠️`, improvement spots with `// ✅`
- Keep Mermaid diagram nodes to 5 or fewer

## Save and Convert

```
docs/yoda/YYYY-MM-DD-{slug}-slides.md
```

```bash
npx @marp-team/marp-cli docs/yoda/YYYY-MM-DD-{slug}-slides.md --html
```
