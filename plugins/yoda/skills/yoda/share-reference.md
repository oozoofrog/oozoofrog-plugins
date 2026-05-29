# Share Mode Reference

Reference for the full execution pipeline of yoda share mode and per-format generation strategies.

---

## Entry Point

```
/yoda share <input> [--format md|web|wiki|slides] [--audience junior|mid|senior]
```

### Parameters

| Parameter | Required | Default | Description |
|----------|------|--------|------|
| `<input>` | Required | — | `--from-review`, a file/directory path, or free text |
| `--format` | Required | **none** (ask the user) | Output format: `md`, `web`, `wiki`, `slides` |
| `--audience` | Optional | `mid` | Target audience level: `junior`, `mid`, `senior` |

#### Behavior when --format is missing

If `--format` is not specified, ask the user to choose as follows:

```
어떤 형식으로 공유할까요?

1. **md** — 마크다운 문서 (docs/ 폴더에 저장)
2. **web** — 인터랙티브 HTML 페이지
3. **wiki** — 위키 페이지 (Confluence 등)
4. **slides** — Marp 프레젠테이션 슬라이드
```

---

## Input Type Detection

| Input | Detection method | Processing pipeline |
|------|----------|---------------|
| `--from-review` | Check flag presence | Extract the most recent review result from the conversation → convert to the selected format |
| File/directory | Verify path existence with `Glob` | Run standalone analysis → generate content |
| Free text | When neither of the above applies | Explore the codebase with `Grep` → generate content based on real examples |

---

## Per-Format Generation Strategy

### 1. md (Markdown document)

#### Generation method

Generate directly with the `Write` tool.

#### Save path

```
docs/yoda/YYYY-MM-DD-[slug].md
```

#### Reinforcement principles

| Principle | Application |
|------|------|
| **Worked Examples** (Sweller) | Present a complete Before/After/Why example, decomposed step by step |
| **Dual Coding** (Mayer) | Visualize structure/flow with Mermaid diagrams |
| **Elaborative interrogation** (Dunlosky 2013) | Place a "points to consider" question at the end of each section |

---

### 2. web (Interactive HTML)

#### Generation method

Generate the interactive HTML page directly, or delegate to the `frontend-design` skill.

#### Save path

```
docs/yoda/YYYY-MM-DD-[slug].html
```

#### Reinforcement principles

| Principle | Application |
|------|------|
| **Progressive disclosure** (Nielsen) | Hide advanced content with collapse/tabs. Expose only the essentials on the first screen |
| **Retrieval practice** (Roediger & Karpicke 2006) | Use interactive quizzes so readers actively recall what they learned |
| **Personalization** (Mayer) | Use a conversational tone, use the reader's real code as examples |

---

### 3. wiki (Wiki page)

#### Generation method

Generate with the `Write` tool in Markdown or wiki-macro format. If a Confluence MCP server is connected, publish directly.

#### Narrative structure

Write in a four-act structure following storytelling principles:

| Act | Content | Purpose |
|----|------|------|
| **Setup** | "A real situation our team faced" — the context in which the problem arose | Build rapport, spark interest |
| **Development** | The detective process of uncovering the causes one by one | Model analytical thinking |
| **Climax** | Before/After/Why — the key discovery and resolution | Deliver the core of the learning |
| **Resolution** | Action items the team can apply + discussion questions | Drive practice, social constructivism |

#### Reinforcement principles

| Principle | Application |
|------|------|
| **Storytelling** (narrative) | A four-act structure for reading enjoyment and learning effect at once |
| **Social constructivism** (Vygotsky) | Place questions that prompt comments/feedback |
| **Elaborative interrogation** (Dunlosky 2013) | Extend with "What if we applied this pattern to another module in our project?" |

---

### 4. slides (Marp presentation)

#### Generation method

Generate directly with the `Write` tool in Marp markdown format.

#### Save path

```
docs/yoda/YYYY-MM-DD-[slug]-slides.md
```

#### 15-slide structure

| No. | Slide | Content |
|------|---------|------|
| 1 | Title | Topic + one-line summary + date |
| 2 | Today's question | Curiosity trigger — the core question that runs through the whole talk |
| 3 | Current situation | Before code (visualize the problem situation) |
| 4 | Where it hurts | Highlight the problem spots (⚠️ marker) |
| 5 | Why #1 | First cause analysis |
| 6 | Why #2 | Second cause analysis (if applicable) |
| 7 | Real-world impact | Data such as crash rate, performance figures, maintenance cost |
| 8 | Turning point | "So what now?" — present the solution direction |
| 9 | After code | Fixed code (key changes only) |
| 10 | Comparison | Before vs After side by side |
| 11 | Principle | Name the applied design principle + core explanation |
| 12 | Visualization | Mermaid diagram (when architecture changes) |
| 13 | Praise | Praise what was done well + patterns to keep |
| 14 | Action items | Three things the team can apply immediately |
| 15 | Discussion | Metacognitive prompt — close with 2 questions |

#### HTML conversion command

```bash
npx @marp-team/marp-cli docs/yoda/YYYY-MM-DD-[slug]-slides.md --html --output docs/yoda/YYYY-MM-DD-[slug]-slides.html
```

#### Reinforcement principles

| Principle | Application |
|------|------|
| **Signaling** | Concentrate the key message in the slide title. Maximize visual emphasis with bold and emoji |
| **Coherence** | One slide = one message. Fully remove unnecessary text/decoration |
| **Cognitive apprenticeship modeling** (Collins et al.) | Expose the expert's thinking process step by step |

---

### Extension: pptx (PowerPoint) — requires the `pptx` skill

> `--format pptx` is available only in environments where the `pptx` skill is installed. If not installed, do not offer this option.

PowerPoint that adds presenter notes based on Mayer's Modality Principle to the 15-slide structure of the slides format. For the detailed structure, see `templates/pptx-template.md`.

---

## Reveal Gate (disclosure-order control)

Apply per-format disclosure policies so the reader goes through **predict → compare → evaluate** stages rather than seeing the fixed code immediately.

### Per-format Reveal policy

| Format | Reveal method | Implementation |
|------|------------|------|
| **md** | Soft gate — start the first sentence of Why with a prediction question. Place an evaluation question after After | Keep the order Before → prediction question → Why → After → evaluation question |
| **web** | Hard gate — collapse Why/After with `<details>`/tabs | Expose Before + prediction question → reveal Why/After on click |
| **wiki** | Soft gate — guide naturally at the development-climax boundary of the narrative | Setup-development (problem awareness) → climax (reveal the solution) |
| **slides** | Hard gate — separate slides | Before slide → self-explanation slide ("이 문제가 무엇이고, 어떻게 고치시겠습니까?") → Why/After slide |

### Reveal intensity by audience

| audience | Prediction question | Hint | Evaluation question |
|----------|----------|------|----------|
| **junior** | Required (includes 1 hint) | Form: "이 코드에서 ○○ 부분을 살펴보세요" | Optional — maintain confidence |
| **mid** | Required | None | Optional |
| **senior** | Required (open-ended question form) | None | Required — "이 수정의 트레이드오프는?" |

### Coach Mode (optional option for md format)

To maximize learning effect with `--format md`, you can optionally apply **coach mode**:

- **Worksheet section**: Before code + prediction question + blank space (the reader thinks/writes on their own)
- **Answer section**: Why + After + evaluation question
- Clearly separate the two sections with a horizontal rule (`---`)
- Guidance at the end of the worksheet section: *"아래로 스크롤하기 전에 위 질문에 대해 먼저 생각해보세요."*

> Coach mode is especially effective when `--audience junior` or for onboarding/educational purposes.

---

## ZPD Calibration

Following Vygotsky's Zone of Proximal Development (ZPD) theory, calibrate content by `--audience` level.

| audience | Before/After/Why adjustment | Terminology handling | Additional content |
|----------|----------------------|----------|------------|
| **junior** | Explain Why in detail. Build up step by step from basic concepts. Place rich comments in the After code | Include term glosses. Spell out full names alongside abbreviations | Official docs links, reference pointers |
| **mid** | Apply the standard Before/After/Why triple. Name the principle + explain the core impact | Use shared team vocabulary | Name the principle only |
| **senior** | **Turn Why into a question** (induce thinking without giving the answer) | Free use of shorthand/technical terms. May cite academic references directly | Trade-off analysis, comparison of alternative approaches |

---

## --from-review Pipeline

A 5-stage pipeline that converts review-mode results into share mode.

### Stage 1: Locate the review output

Find the most recent `/yoda review` output in the current conversation.

- If there is **no** review output in the conversation: return an error message.
- If there are **multiple** reviews: use the most recent one.

### Stage 2: Extract Layer 2 + Layer 3

Extract the following elements from the review output:

| Extraction target | Source |
|----------|------|
| Findings (Before/After/Why) | Layer 2 |
| Praise | Layer 3 |
| Insight | Layer 3 |
| Mermaid diagram | Layer 3 (if present) |
| Metacognitive prompt | Layer 3 |
| Severity counts | Layer 1 |

### Stage 3: Restructure for the selected format

Restructure the extracted content into the structure of the format specified in `--format`.

### Stage 4: Apply per-format reinforcement principles

Apply each format's reinforcement principles (see the "Per-Format Generation Strategy" section of this document).

### Stage 5: Output via the corresponding format method

| Format | Output method |
|------|----------|
| md | Create file with `Write` → return path |
| web | Generate interactive HTML → return file path |
| wiki | Generate in Markdown/wiki format → return file path |
| slides | Generate Marp markdown with `Write` → guide the conversion command → return path |
| pptx | Available only when the `pptx` skill is installed → return PowerPoint file path |
