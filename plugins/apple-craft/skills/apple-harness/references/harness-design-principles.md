# Harness Design Principles

> Core design-principles document referenced by apple-craft harness agents.
> Source: [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Anthropic, 2026-03-24)

---

## Core Principles

Five design principles agents must always follow.

1. **Minimal complexity**: "Find the simplest solution possible, and only increase complexity when needed." — Every component in a harness encodes an assumption about what the model can't do on its own. Remove unnecessary complexity.

2. **Validate component assumptions**: "Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing." — Each time the model improves, re-evaluate whether existing components are still needed. An assumption may be wrong or may have expired.

3. **Generator-Evaluator separation**: "Tuning a standalone evaluator to be skeptical turns out to be far more tractable than making a generator critical of its own work." — To structurally eliminate self-evaluation bias, separate generation from evaluation. A skeptical scoring requires an Evaluator that exists independently.

4. **Conditional use of the Evaluator**: "The evaluator is not a fixed yes-or-no decision. It is worth the cost when the task sits beyond what the current model does reliably solo." — The Evaluator's value arises when the task exceeds the model's capability boundary. For tasks the model handles reliably on its own, it may be pure overhead.

5. **Harness space movement**: "The space of interesting harness combinations doesn't shrink as models improve. Instead, it moves." — As model performance improves, the harness does not become unnecessary; it moves into more complex, novel task domains. Finding the next novel combination is the core job of an AI engineer.

---

## V2 Pattern (based on Claude Opus 4.6)

The result of substantially simplifying the harness after the release of Claude Opus 4.6. Opus 4.6 is described as "plans more carefully, sustains agentic tasks for longer, can operate more reliably in larger codebases, and has better code review and debugging skills to catch its own mistakes," and its long-context retrieval is also significantly improved.

### Removing the Sprint Structure

- **Reason**: The sprint structure existed to compensate for the model's inability to maintain consistency over long periods. Opus 4.6 maintains consistency even across continuous build sessions of 2+ hours, so sprint decomposition is no longer load-bearing.
- **Method**: Remove the per-sprint iteration (sprint contract negotiation -> implementation -> QA), and have the Generator perform the full build continuously, after which the Evaluator evaluates in a single pass.

### Switching the Evaluator to a Single Pass

- Switched from performing QA each sprint to a single evaluation after build completion.
- When the Evaluator finds problems, it relays feedback to the Generator and, if needed, repeats additional Build-QA rounds.
- The actual DAW case converged in 3 rounds (Build-QA).

### Why the Planner Is Kept

- Giving the Generator only the raw prompt without a Planner causes **under-scope**: "given the raw prompt, it would start building without first speccing its work, and end up creating a less feature-rich application than the planner did."
- The Planner uses only 0.4% ($0.46) of total cost while providing the highest ROI.

### Why the Evaluator Is Kept

- Even on Opus 4.6, the Generator still tends to omit details or leave features as stubs.
- The Evaluator still provides real lift on work beyond the **capability boundary**.

### Replacing context reset with automatic compaction

- On Claude Sonnet 4.5, context anxiety was severe and compaction alone was insufficient, so context reset (full re-initialization of the context window + structured handoff) was essential.
- Opus 4.6 greatly mitigates context anxiety, allowing context growth to be managed with the Claude Agent SDK's automatic compaction alone.
- Removing context reset reduces orchestration complexity, token overhead, and latency.

---

## Evaluator Tuning Methodology

### Self-evaluation bias and its solution

- "When asked to evaluate work they've produced, agents tend to respond by confidently praising the work -- even when, to a human observer, the quality is obviously mediocre."
- This is especially severe for subjective work like design: "there is no binary check equivalent to a verifiable software test."
- **Solution**: Separate the Generator and the Evaluator. Separation alone does not automatically remove leniency, but tuning an independent Evaluator to be skeptical is far more tractable than drawing self-criticism out of the Generator.

### The context anxiety phenomenon and how to handle it

- "Some models also exhibit 'context anxiety,' in which they begin wrapping up work prematurely as they approach what they believe is their context limit."
- On Sonnet 4.5, compaction alone was insufficient and context reset was essential.
- Opus 4.6 largely removes this behavior, so automatic compaction is sufficient.

### Few-shot calibration

- Calibrate the Evaluator by providing few-shot examples that include detailed score analysis.
- "This ensured the evaluator's judgment aligned with my preferences, and reduced score drift across iterations."

### The role of the sprint contract and its replacement in V2

- In V1, before each sprint started, the Generator and Evaluator negotiated a **sprint contract**: "agreeing on what 'done' looked like for that chunk of work before any code was written."
- The Generator proposed and the Evaluator reviewed, iterating until they reached agreement.
- In V2, the sprint structure itself was removed, and the full spec produced by the Planner replaces the role of the contract.

### The Evaluator's tendency toward early leniency

- "In early runs, I watched it identify legitimate issues, then talk itself into deciding they weren't a big deal and approve the work anyway."
- "It also tended to test superficially, rather than probing edge cases, so more subtle bugs often slipped through."
- Solution: Read the Evaluator logs, find the points where its judgment diverged from the developer's expectations, and iteratively update the prompt.

### The tuning iteration process

- "It took several rounds of this development loop before the evaluator was grading in a way that I found reasonable."
- Tuning loop: Read Evaluator logs -> identify judgment-mismatch points -> update QA prompt -> re-run.

### Remaining limits

- "Even then, the harness output showed the limits of the model's QAing capabilities: small layout issues, interactions that felt unintuitive in places, and undiscovered bugs in more deeply nested features that the evaluator hadn't exercised thoroughly."
- Room for improvement remains, but the lift over solo — reaching a level where core features work — is clear.

---

## Frontend Design Evaluation Criteria

Four scoring criteria provided as prompts to both the Generator and the Evaluator. Higher weight is given to Design quality and Originality.

| Criterion | Original definition | apple-craft application |
|------|----------|----------------|
| **Design Quality** | "Does the design feel like a coherent whole rather than a collection of parts? Strong work here means the colors, typography, layout, imagery, and other details combine to create a distinct mood and identity." | Mapped to the UI quality axis -- whether colors, typography, layout, imagery, etc. form a coherent mood and identity |
| **Originality** | "Is there evidence of custom decisions, or is this template layouts, library defaults, and AI-generated patterns? A human designer should recognize deliberate creative choices. Unmodified stock components -- or telltale signs of AI generation like purple gradients over white cards -- fail here." | The "deliberate choice, not anti-pattern" of code quality -- whether conscious design decisions exist, not default templates or AI slop |
| **Craft** | "Technical execution: typography hierarchy, spacing consistency, color harmony, contrast ratios. This is a competence check rather than a creativity check. Most reasonable implementations do fine here by default; failing means broken fundamentals." | The technical execution of the code-quality axis -- fundamentals such as typography hierarchy, spacing consistency, color harmony, contrast ratios |
| **Functionality** | "Usability independent of aesthetics. Can users understand what the interface does, find primary actions, and complete tasks without guessing?" | Mapped to the feature-completeness axis -- whether users can understand the interface and complete tasks regardless of aesthetics |

> **Weighting note**: Claude scores highly on Craft and Functionality by default, while it tends to produce bland output on Design quality and Originality. Therefore, give higher weight to the latter to encourage aesthetic risk-taking.

---

## Case Studies: Cost-Quality Reference Points

### Retro game maker (RetroForge) -- V1, Opus 4.5

**Prompt**: "Create a 2D retro game maker with features including a level editor, sprite editor, entity behaviors, and a playable test mode."

| Approach | Time | Cost | Result |
|------|------|------|------|
| Solo | 20 min | $9 | Core feature (play mode) does not work. Wasted layout space, unclear workflow, entities appear on screen but do not respond to input |
| V1 Harness | 6 hours | $200 | 16 features (10 sprints), AI integration, playable. Full-viewport canvas, coherent visual identity, sprite animation, sound, AI sprite generation, etc. |

#### Examples of specific issues caught by the Evaluator

| Contract criterion | Evaluator finding |
|---|---|
| Rectangle fill tool allows click-drag to fill a rectangular area with selected tile | **FAIL** -- Tool only places tiles at drag start/end points instead of filling the region. `fillRectangle` function exists but isn't triggered properly on `mouseUp`. |
| User can select and delete placed entity spawn points | **FAIL** -- Delete key handler at `LevelEditor.tsx:892` requires both `selection` and `selectedEntityId` to be set, but clicking an entity only sets `selectedEntityId`. Condition should be `selection \|\| (selectedEntityId && activeLayer === 'entity')`. |
| User can reorder animation frames via API | **FAIL** -- PUT `/frames/reorder` route defined after `/{frame_id}` routes. FastAPI matches `'reorder'` as a `frame_id` integer and returns 422: "unable to parse string as an integer." |

> The level editor of Sprint 3 alone had 27 test criteria, and the Evaluator's findings were specific enough to act on directly without further investigation.

### DAW (Digital Audio Workstation) -- V2, Opus 4.6

**Prompt**: "Build a fully featured DAW in the browser using the Web Audio API."

| Agent & Phase | Duration | Cost | Share |
|---|---|---|---|
| Planner | 4.7 min | $0.46 | 0.4% |
| Build Round 1 | 2 hours 7 min | $71.08 | 57.0% |
| QA Round 1 | 8.8 min | $3.24 | 2.6% |
| Build Round 2 | 1 hour 2 min | $36.89 | 29.6% |
| QA Round 2 | 6.8 min | $3.09 | 2.5% |
| Build Round 3 | 10.9 min | $5.88 | 4.7% |
| QA Round 3 | 9.6 min | $4.06 | 3.3% |
| **Total** | **3 hours 50 min** | **$124.70** | **100%** |

**Key insight**: The Planner provides the highest ROI at 0.4% of the cost. The Generator codes consistently for 2+ hours without sprint decomposition.

#### Issues caught by QA

**Round 1**: "The main failure point is Feature Completeness -- while the app looks impressive and the AI integration works well, several core DAW features are display-only without interactive depth: clips can't be dragged/moved on the timeline, there are no instrument UI panels (synth knobs, drum pads), and no visual effect editors (EQ curves, compressor meters). These aren't edge cases -- they're the core interactions that make a DAW usable."

**Round 2**: "Audio recording is still stub-only (button toggles but no mic capture), clip resize by edge drag and clip split not implemented, effect visualizations are numeric sliders, not graphical (no EQ curve)."

### Dutch art museum case (creative leap)

A case from a frontend design experiment showing the creative potential of the Generator-Evaluator loop.

- **Iterations 1~9**: Incremental improvement. A clean dark-themed virtual art-museum landing page. Visually polished but within the expected range.
- **Iteration 10**: A radical shift. Completely discarded the previous approach and reinterpreted it as a **spatial experience**:
  - A 3D room rendered with CSS perspective, a checkered-pattern floor
  - Works freely placed on the walls
  - Doorway-based navigation between galleries instead of scroll/click
- **Significance**: "It was the kind of creative leap that I hadn't seen before from a single-pass generation." -- emergent creativity arising from the Evaluator's iterative feedback pushing the Generator out of safe choices.

---

## Glossary

> Source: [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Anthropic, 2026-03-24)

### Architecture / System Design

| Term | Description |
|------|------|
| **Harness** | An orchestration framework designed to raise the model's performance. Includes agent composition, feedback loops, context management, etc. |
| **GAN-inspired architecture** | A structure inspired by Generative Adversarial Networks. Separates Generator and Evaluator to iteratively improve output quality |
| **Three-agent architecture** | A system composed of three agents: Planner, Generator, Evaluator |
| **Multi-agent system** | A structure in which multiple agents with different roles cooperate to carry out work |

### Agent Roles

| Term | Description |
|------|------|
| **Planner** | An agent that expands a simple 1~4 sentence prompt into a full product spec. Focuses on product context and high-level technical design rather than detailed technical implementation |
| **Generator** | An agent that implements the actual code per the spec. Per-sprint in V1, continuous build in V2 |
| **Evaluator** | An agent that tests and scores the generated output like a real user, using Playwright MCP and the like. Navigates the live page and takes screenshots while evaluating |
| **Initializer agent** | An agent in the early harness that decomposes the product spec into a task list (pre-V1) |

### Context Management

| Term | Description |
|------|------|
| **Context degradation** | The phenomenon where the model's consistency degrades as the context window fills up |
| **Context anxiety** | The model's tendency to wrap up work prematurely because it judges itself near the context limit. Severe on Sonnet 4.5, greatly mitigated on Opus 4.6 |
| **Context reset** | Fully clearing the context window and starting a new agent with a structured handoff. Provides a clean slate |
| **Compaction** | Summarizing the early part of the conversation so the same agent continues with a condensed history. Continuity is maintained but it does not provide a clean slate |
| **Structured handoff** | A mechanism that passes the previous agent's state and the next task as a structured artifact |

### Evaluation Criteria

| Term | Description |
|------|------|
| **Design quality** | Whether colors, typography, layout, etc. form a coherent mood and identity |
| **Originality** | Whether there are deliberate creative choices rather than template defaults or AI-generated patterns |
| **Craft** | The level of technical execution such as typography hierarchy, spacing consistency, color harmony. A competence check |
| **Functionality** | Whether users can understand the interface and carry out tasks regardless of aesthetics |

### Execution Patterns

| Term | Description |
|------|------|
| **Sprint contract** | A contract in which the Generator and Evaluator agree on the "definition of done" before implementation. Removed in V2 |
| **One-feature-at-a-time** | An approach that manages scope by implementing only one feature at a time. The basis of the V1 sprint structure |
| **File-based communication** | A method where agents communicate by reading/writing files |
| **Few-shot calibration** | A technique that calibrates evaluation criteria by providing the Evaluator with score-analysis examples |
| **Methodical ablation** | A systematic simplification method that measures impact by removing harness components one at a time |

### Problems / Failure Modes

| Term | Description |
|------|------|
| **Self-evaluation bias** | The tendency of an agent to overrate the work it produced. Solved by Generator-Evaluator separation |
| **AI slop** | The bland, characterless design patterns AI typically generates, such as purple gradients + white cards |
| **Score drift** | The phenomenon where the Evaluator's scoring criteria gradually shift across repeated runs. Mitigated by few-shot calibration |
| **Under-scope** | The phenomenon where the feature scope shrinks when the Generator is given the raw prompt without a Planner |

### Core Principles

| Term | Description |
|------|------|
| **Load-bearing component** | A core component in the harness that actually contributes to performance. Needs re-evaluation when the model improves |
| **Capability boundary** | The boundary of work the model can handle reliably on its own. Moves outward with each model improvement |
| **Harness space movement** | The principle that, as the model improves, the space of harness combinations does not shrink but moves |
