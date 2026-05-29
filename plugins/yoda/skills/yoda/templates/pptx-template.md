# PPTX Output Template

PowerPoint structure template for the `--format pptx` output of yoda share mode. Delegate to the `pptx` skill if installed; otherwise fall back to Marp slides + a separate presenter-notes markdown.

---

## Structure

Apply the same 15-slide structure as the slides format, but add **presenter notes** to each slide.

### Mayer's Principle (Modality Principle)

| Slide body (visual) | Presenter notes (auditory) |
|---------------------|----------------------------|
| Keywords, diagrams, code | Detailed explanation, transition lines, supplementary notes |
| Minimal text (3 lines or fewer) | Full spoken content |
| What the audience **sees** | What the presenter **says** |

### Per-slide presenter note guide

| # | Slide | Body | Presenter notes |
|---|-------|------|-----------------|
| 1 | Hook | One provocative question | Greeting, background, "발표 끝에 답할 수 있을 겁니다" |
| 2 | Context #1 | 3 situation bullets | Detailed background, "비슷한 경험 있으실 텐데요" |
| 3 | Context #2 | 3-5 lines of problem code | Code context, "잘 동작하는 것처럼 보이죠?" |
| 4-6 | Mental Model | Concept + diagram | Everyday analogy, concept linkage, integrated explanation |
| 7-8 | Before | Problem code + issues | ⚠️ meaning, production impact |
| 9 | Why | Principle name + impact figures | State the Why colloquially, induce the "아하" moment |
| 10 | After | Fixed code + ✅ | Change points vs Before, trade-offs |
| 11 | Aha Insight | One insight sentence | Elaboration, link to personal/team experience |
| 12-13 | Generalization | Scope of application + principle | Concrete cases, CTA transition line |
| 14 | CTA | 3 action items | How to execute, answer to the Hook question |
| 15 | Resources | Reference links + questions | Wrap-up, emphasize recommended materials |

---

## Save path

```
docs/yoda/YYYY-MM-DD-{slug}.pptx
```
