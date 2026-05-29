# Learning Science Reference

The learning-science principles that govern every output of the yoda skill.

---

## 4 Core Principles (always applied to every output)

### 1. Before/After/Why Triple

> For every finding, place the **problem code (Before) + fixed code (After) + reason (Why)** adjacent to each other.

**Basis:** Sweller Cognitive Load Theory, Mayer contiguity principle (largest effect size in the Noetel 2022 meta-analysis), Dunlosky (2013) elaborative interrogation.

#### Before block

- Quote the actual problem code **verbatim**.
- Do not abbreviate or replace it with pseudocode.
- Add a `// ⚠️` marker at the problem spot to guide the eye.

#### Why block

- Start with a **curiosity trigger** (information-gap question).
- **Name** the principle (e.g., "SRP violation", "race condition").
- Explain the actual impact **concretely** (crash rate, performance numbers, maintenance cost).

#### After block

- Include the fixed code + **inline comments on the key changes**.
- Minimize code unrelated to the change.

#### Adjacency rule

- The three blocks Before, Why, After must be visible **together without scrolling**.
- If a single finding exceeds one screen, split it.
- For long code blocks, excerpt only the essential part and elide the rest with `// ... (변경 없음)`.

---

### 2. Signaling / Labeling

> Attach a severity label to every finding.

**Basis:** Noetel (2022) signaling/cueing effect, Conventional Comments.

| Label | Meaning | Criteria |
|------|------|----------|
| 🔴 Must Fix | Must be fixed | Crash, data loss, security vulnerability, severe performance degradation |
| 🟡 Should Improve | Improvement recommended | Reduced maintainability, potential bug, design-principle violation |
| 🔵 Nit | Minor improvement | Naming, formatting, convention inconsistency |
| 🟢 Praise | Praise | Well-written code, best-practice application |
| 💡 Insight | Insight | Learning point, alternative approach, team-level discussion suggestion |

#### Application rules

- Place the label at the **very front** of the finding title: `🔴 Must Fix: 강제 언래핑으로 인한 크래시 위험`
- Show a **per-severity summary count** at the top of the output: `🔴 2 | 🟡 3 | 🔵 1 | 🟢 2 | 💡 1`
- Keep 🟢 Praise at a minimum of 20% of all findings to provide positive reinforcement.
- Do not output findings without a label.

---

### 3. Coherence -- Remove the Unnecessary

> Remove what the reader already knows and information irrelevant to the finding.

**Basis:** Mayer (2025) meta-analysis -- extraneous information significantly impairs learning.

#### Removal targets

- **Language-basics explanations**: do not explain the target language's basic syntax/concepts (assume the reader is a developer in that language).
- **Code context unrelated to the finding**: do not verbosely quote surrounding code that is not under review.
- **Repeated explanations**: when the same principle applies to multiple findings, explain it in detail on first appearance and replace later mentions with a reference (`위 #2 참조`).
- **Decorative phrasing**: remove transition phrases such as "이제 살펴보겠습니다", "다음으로 넘어가서".
- **Disclaimers**: remove vague hedges such as "이것은 제 의견입니다", "상황에 따라 다를 수 있습니다".

#### Preservation targets

- Do not abbreviate any element of the Before/After/Why triple.
- Always keep severity labels and the basis.
- Do not remove curiosity-trigger questions.

---

### 4. Chunking

> One section/slide/card = one concept.

**Basis:** Miller (1956) 7±2 rule, Hermans (2021) programmer cognitive-load research.

#### Application rules

- Cover **one concept** per finding (Before/After/Why).
- When one code block contains multiple problems, **split per problem**.
- Collect **all** findings during analysis without limit; for output, **select the top findings and present 7 or fewer** (if more than 7 candidates exist, group them by priority for output).
- Make visual separation between sections clear (horizontal rules, headings).
- Group related findings under a **group heading**, but each must remain independently understandable within the group.

---

## Per-Format Additional Principles

The 4 core principles always apply; depending on the output format, additionally apply the principles below.

### md (Markdown)

| Principle | How to apply |
|------|----------|
| **Dual coding** (Mayer) | Visualize structure/flow with Mermaid diagrams. Pair text explanation with the diagram |
| **Elaborative interrogation** (Dunlosky 2013) | Place a "생각해볼 점" question at the end of each section. Prompt the reader to think actively |

### web (HTML)

| Principle | How to apply |
|------|----------|
| **Progressive disclosure** (Nielsen) | Hide deeper content with collapsibles (details/summary) and tabs. The first view exposes only the essentials |
| **Retrieval practice** (Roediger & Karpicke 2006) | Use interactive quizzes/checklists so the reader recalls the learned content directly |
| **Personalization** (Mayer) | Use a conversational tone; use the reader's own code directly as examples |

### wiki (Confluence, etc.)

| Principle | How to apply |
|------|----------|
| **Storytelling** (narrative) | Narrative structure of problem discovery → cause investigation → resolution. Start with "우리 팀이 겪은 실제 사례" |
| **Social constructivism** (Vygotsky) | Place comment/feedback-eliciting questions. "이 부분에 대해 다른 접근법이 있다면 댓글로 공유해주세요" |
| **Elaborative interrogation** (Dunlosky 2013) | Pose extension questions of the form "이 패턴을 우리 프로젝트의 다른 모듈에 적용한다면?" |

### slides (presentation markdown)

| Principle | How to apply |
|------|----------|
| **Signaling reinforcement** | Concentrate the key message in the slide title. Maximize visual emphasis (bold, color) |
| **Coherence maximization** | One slide = one message. Completely remove unnecessary text/decoration |
| **Cognitive apprenticeship modeling** (Collins et al.) | Expose the expert's thought process step by step: "내가 이 코드를 처음 봤을 때 → 의심한 점 → 확인한 방법 → 결론" |

### pptx (PowerPoint) — only when the `pptx` skill is installed

| Principle | How to apply |
|------|----------|
| All slides principles | Apply the slides principles above identically |
| **Modality principle** (Mayer) | Place detailed explanation in the speaker notes. Keep the slide body keyword/diagram-centric. Separate what the audience reads from what the presenter says |

---

## Curiosity-Trigger Generation Rules

**Basis:** Loewenstein (1994) information-gap theory -- curiosity arises when a person perceives a gap between "what they know" and "what they want to know".

### Good examples

- "이 코드가 모든 테스트를 통과하는데, 어떤 조건에서 깨질까요?"
- "이 함수의 시간 복잡도가 O(n)으로 보이지만, 실제로는 O(n^2)인 이유가 뭘까요?"
- "이 싱글톤이 Thread-safe해 보이지만, 동시 접근에서 문제가 되는 이유는?"
- "이 컴포넌트가 deinit/dispose되지 않는데, 메모리 릭의 원인은 어디일까요?"

### Bad examples

- "왜 이럴까요?" -- too vague to create an information gap
- "이건 안 좋습니다" -- a judgment, not a question
- "어떻게 생각하세요?" -- not grounded in concrete facts
- "이 코드를 개선할 수 있을까요?" -- presents an obligation, not a gap

### Generation rules

1. **Always grounded in concrete facts**: must reference a specific behavior, number, or condition in the code.
2. **Calibrate gap size**: avoid questions that are too easy (no gap) and too hard (excessive gap).
3. **Hint at the answer without fully revealing it**: "모든 테스트를 통과하는데" (hints normal behavior) + "어떤 조건에서 깨질까요?" (points at the unknown).
4. **One trigger per finding**: do not chain multiple questions.
5. **Place as the first sentence of the Why block**: the answer follows immediately after the trigger, preserving the contiguity principle.

---

## ZPD Calibration Matrix

**Basis:** Vygotsky (1978) Zone of Proximal Development -- teaching is most effective between the learner's current level and the level reachable with help.

| audience | Scaffolding level | Before/After/Why adjustment | Terminology |
|----------|----------|----------------------|------|
| **junior** | High | Explain Why in detail. Build up from basic concepts step by step. Comment the After code richly. Explain "왜 이렇게 바꿨는지" line by line | Include term glosses. On first use of an abbreviation, give the full name (e.g., "SRP(단일 책임 원칙)") |
| **mid** | Medium | Apply the standard Before/After/Why triple. Name the principle + explain the key impact. Comment only the key changes in the After code | Use shared team vocabulary. Team-agreed terms may be used without explanation |
| **senior** | Low | **Convert Why into a question** (induce thinking without giving the answer). Present only Before/After and ask, like "이 변경의 트레이드오프는?". Completely omit basics they already know | Free use of abbreviations/technical terms. May cite academic references directly |

### Calibration rules

- If the `audience` parameter is not specified, use **mid** as the default.
- Do not mix audience levels within the same output.
- Place more Praise (🟢) for junior to build confidence (minimum 30%).
- Place more Insight (💡) for senior to induce deep discussion (minimum 30%).

---

## Extended Principles (research-based reinforcement)

The principles below are validated improvements derived from the latest 2024-2026 research.

### 5. Cognitive Error-Type Classification

> For each finding, classify **why the developer made that mistake** in cognitive-psychology terms.

**Basis:** Huang & Madeira (2024) HECR — code review applying cognitive error-type classification improved true positives by ~400%.

| Tag | Type | Meaning | Improvement direction |
|------|------|------|----------|
| `[Slip]` | Execution error | Has correct knowledge but errs in execution (typo, off-by-one) | Linting, checklists |
| `[Rule]` | Rule error | Applies a familiar pattern to an ill-fitting situation (misreads an API contract) | Precondition learning |
| `[Knowledge]` | Knowledge gap | Has never encountered the concept (unaware of race condition) | Learning, practice |
| `[Lapse]` | Forgetting | Knows it but forgot (missing error handling) | Automation, reminders |

#### Application rules

- Attach an error-type tag to 🔴 Must Fix and 🟡 Should Improve findings.
- In the Why block, present a **tailored improvement direction** based on the error type.
- Go beyond "what is wrong" to "why this mistake occurred".

---

### 6. Self-Explanation Prompts

> After showing the Before code, do not provide the Why immediately; give the reader a chance to think first.

**Basis:** Chapagain & Rus (AAAI 2025) — self-explanation significantly improves depth of code comprehension (d=0.55). Utrecht University (2025) — step-by-step retrieval practice improves recall after 1 week by 2.4x.

#### Application rules (web/slides formats)

1. Present the Before code with a ⚠️ marker.
2. Place the question **"이 코드의 문제가 무엇이고, 어떻게 고치시겠습니까?"**.
3. Reveal the Why + After on click / next slide.

#### Application rules (md/wiki formats)

- Keep the existing Before → Why → After order, but begin the Why block with a curiosity-trigger **question** so the reader pauses and thinks.

---

### 7. Specification Grounding

> Describe every finding grounded in a **concrete test, contract, or specification**.

**Basis:** arXiv (2026) "The Specification as Quality Gate" — specification-based review improved developer acceptance rate by 90.9%. Prevents the "echo problem" of LLM reviews (plausible but wrong findings).

#### Application rules

- Where possible, state the violated test/contract/type-system constraint.
  - Good: "이 코드는 `ThreadSafeQueue` 프로토콜의 thread-safety 계약을 위반합니다 (L42)"
  - Bad: "이 코드는 thread-safe하지 않습니다"
- When there is no test, suggest which test would have caught this problem.
- Label findings based on speculation as "확인 필요".

---

### 8. Metacognitive Scaffolding

> Induce active thinking in the developer reading the review in 3 stages.

**Basis:** numerous 2024-2025 studies — AI-generated content risks inducing "metacognitive laziness". Plan-monitor-evaluate scaffolding prevents this.

| Stage | Prompt | Placement |
|------|---------|----------|
| **Plan** | "이 코드를 읽기 전에, 어떤 유형의 문제를 예상하시나요?" | Right after Layer 1 (optional) |
| **Monitor** | "이 설명이 예상과 일치하나요?" | End of each Why block (optional) |
| **Evaluate** | "이 수정이 작동하지 않는 경우는 없을까요?" | End of each After block (optional) |

#### Application rules

- Metacognitive prompts are **added** to the Phase 6 questions in the Layer 3 "생각해볼 점" section.
- For junior audiences, place the monitoring prompt explicitly to form a self-checking habit.
- For senior audiences, reinforce the evaluation prompt to induce critical thinking.

---

### 9. Growth-Mindset Framing

> Frame every finding as a **learning opportunity**, not a failure.

**Basis:** Dweck mindset theory + Springer (2024) code-review anxiety study — a cognitive-behavioral workshop significantly reduced review anxiety.

#### Application rules

- Include a **normalizing phrase** in 🔴 Must Fix: "이 패턴은 숙련된 개발자도 자주 빠지는 함정입니다"
- Use growth language ("다음 단계", "마스터리 과정") instead of deficit language ("실패", "잘못된").
- On repeat findings, emphasize **progress** rather than regression: "이전에는 단순한 케이스에서 이 문제가 있었는데, 이번에는 더 복잡한 변형에서 발견되었습니다 — 단순 케이스는 이미 마스터하셨습니다"
