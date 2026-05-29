# Review Mode Reference

Reference for the full execution pipeline and output structure of yoda review mode.

---

## Entry Point

```
/yoda review <file|directory>
```

- The target is a single source file or a directory path.
- For a directory, recursively traverse the source files within it for a full review.
- Output is **always in markdown** format.

---

## Internal Analysis Pipeline (6 Phases)

### Phase 1: Context Gathering

Review accuracy is proportional to the depth of context. Do not just read the code — gather the **context of the change** as well.

| Step | Action | Tool | Purpose |
|------|--------|------|---------|
| 1 | Read the entire target code | `Read` | Grasp the overall structure and flow of the code |
| 2 | Check recent change context | `git log --oneline -10 -- <target>` | Identify change patterns, frequency, and authors from the last 10 commits |
| 3 | Check author/timestamp per line | `git blame <target>` | Identify the owner and authoring time per code region. Detect recently bulk-changed regions |
| 4 | Search for test files | `Grep` (test file pattern) | Verify whether tests exist for the target type and their coverage scope |
| 5 | Explore dependencies | `Grep` (search other files by type name) | List files referencing this type. Estimate the blast radius of a change |
| 6 | Infer author intent | Analyze commit messages, PR descriptions | Understand "why" the code was written this way. Detect the gap between intent and implementation |

#### Context Gathering Rules

- Run Phase 1 **implicitly**. Do not tell the user "I will gather context."
- Proceed to Phase 2 only after completing all steps.
- For a new file with no git history, skip steps 2, 3, and 6.
- If there is no test file, record it as "test absent" in the Phase 2 test lens.

---

### Phase 2: Multi-Perspective Analysis

Analyze the code independently through 5 lenses. Each lens is **for internal analysis** and the lens name is not exposed directly in the final output. Findings are reordered by severity for output.

| Lens | Analysis Content | Concrete Check Items |
|------|------------------|----------------------|
| **Structure** | Separation of responsibilities, dependency direction, module boundaries | SRP violation, circular dependency, God Object, thin wrapper, Feature Envy, broken encapsulation |
| **Clarity** | Naming, abstraction level, readability | Unclear names, excessive abbreviation, wrong abstraction level, magic numbers, unnecessary comments |
| **Safety** | Concurrency, memory, error handling, type safety | data race, memory leak, unhandled errors, type-safety violations |
| **Performance** | Unnecessary cost, inefficient patterns | N+1 problem, unnecessary allocation, main-thread blocking, excessive re-rendering |
| **Test** | Verifiability, test design quality | Test absent, over-mocking, implementation-coupled tests, missing boundary conditions, non-deterministic tests |

#### Analysis Rules

- Run each lens **independently**. When findings overlap across lenses, attribute them to the more severe one.
- Omit lenses with no findings from the output.
- **Collect all findings without omission during analysis — do not cap the analysis itself.** Apply caps only at the output-selection stage: when presenting, select the top findings (up to 3 per lens, and 7 or fewer total) following the chunking principle, while still preserving the full finding set internally.
- After analyzing all 5 lenses, cross-validate: when judgments conflict across lenses, follow the priority lens (Safety > Structure > Performance > Clarity > Test).

---

### Phase 3: Structuring Findings

Structure each finding as a **Before/After/Why triple**. (See `learning-science.md` for detailed rules.)

#### Why Block Integrated Structure

All elements and their order in the Why block are defined below. Respect the **required/optional distinction**, but keep the whole block within **one screen**. When it exceeds that, omit optional elements.

| Order | Element | Required | Content |
|-------|---------|----------|---------|
| 1 | **Curiosity Trigger** | Required | Open with an information-gap question — the first sentence of the Why block |
| 2 | **Principle Link** | Required | Name the violated design principle/pattern (e.g., "SRP violation") |
| 3 | **Evidence Source + Evidence Confidence** | 🔴🟡 Required | Concrete test/contract/type evidence + `높음`/`중간`/`낮음` |
| 4 | **Actual Impact** | Required | What outcome it causes in production |
| 5 | **Normalization Phrase** | 🔴 Required | "이 패턴은 숙련된 개발자도 자주 빠지는 함정입니다" |
| 6 | **Prevention Direction** | 🔴🟡 Required | Intervention strategy by cognitive-error type (last subheading of Why) |

> **Length Principle**: Curiosity trigger (1 sentence) + principle/evidence/impact (1-2 sentences each) + prevention direction (1-2 sentences) = within 6-10 sentences total. This must be visible together with Before/After without scrolling.

#### Before/After Code Rules

- Before: Quote the actual code verbatim. Mark the problem spot with `// ⚠️`.
- After: Fixed code + `// ✅` inline comments on key changes.
- Omit code unrelated to the change with `// ... (변경 없음)`.
- Keep within one screen so Before/After/Why are **visible together without scrolling**.

#### Reveal Gate (Disclosure Order Control)

Control the disclosure order so the reader **thinks first** rather than immediately consuming the Why/After.

Review mode has no `--audience` parameter, so it always applies a **mid-level soft reveal gate**. Per-audience differential reveal applies only in share mode (see `share-reference.md`).

##### Soft Reveal Gate (Review Mode)

Since the output is markdown text, physical collapsing is impossible. Instead, guide via structural ordering:

1. **Before block** — Present the problematic code with a `// ⚠️` marker
2. **Why block** — Open with a curiosity-trigger question to prompt the reader to pause and think, then unfold naturally into the answer
3. **After block** — Present the fixed code

---

### Phase 4: Severity Classification

Attach a severity label to every finding.

| Label | Meaning | Criteria | Requirement |
|-------|---------|----------|-------------|
| 🔴 Must Fix | Must be fixed | Crash, data loss, security vulnerability, severe performance degradation | When applicable |
| 🟡 Should Improve | Improvement recommended | Reduced maintainability, potential bug, design-principle violation | When applicable |
| 🔵 Nit | Minor improvement | Naming, formatting, convention inconsistency | When applicable |
| 🟢 Praise | Praise | Well-written code, applied best practices | **At least 1 required** |
| 💡 Insight | Insight | Learning point, alternative approach, team-level discussion proposal | **1 per whole review** |

#### Classification Rules

- Sort order: 🔴 → 🟡 → 🔵 (most severe first).
- Include at least 1 🟢 Praise. Find a well-done part of the code and praise it concretely.
- Include **exactly 1** 💡 Insight per whole review. An insight worth discussing at the team/project level beyond this code.
- Show the per-severity counts at the top of the output: `🔴 2 | 🟡 3 | 🔵 1 | 🟢 2 | 💡 1`
- Do not output findings without a label.

#### Cognitive Error Classification — Required Output Contract

For 🔴/🟡 findings, mandatorily attach a cognitive-psychology classification of **why the developer made this mistake** plus a tailored intervention strategy (Huang & Madeira 2024 HECR).

##### Required Metadata

Include all 3 of the following in each 🔴/🟡 finding:

| Field | Description | Required |
|-------|-------------|----------|
| **Error type label** | One of `[Slip]`, `[Rule]`, `[Knowledge]`, `[Lapse]` | Required |
| **Classification confidence** | `높음`/`중간`/`낮음` — if low, also note the runner-up candidate | Required |
| **Intervention strategy** | Concrete prevention/learning direction matching the error type | Required |

##### Intervention Strategy Mapping by Error Type

| Type | Meaning | Intervention Strategy | Reflected in Why Block |
|------|---------|----------------------|------------------------|
| `[Slip]` | Correct knowledge, execution mistake (typo, off-by-one) | Suggest linting rule/checklist/auto-formatter | "이 실수를 자동으로 잡을 수 있는 도구: ..." |
| `[Rule]` | Wrong application of a familiar pattern (API-contract misunderstanding) | Explain preconditions + present a counterexample | "이 패턴이 여기서 맞지 않는 이유: ..." |
| `[Knowledge]` | Inexperience with the concept (race condition, etc.) | Explain the concept + provide a worked example | "이 개념의 핵심: ..." + point to learning materials |
| `[Lapse]` | Knew but forgot (missing error handling, etc.) | Suggest automation/reminder/team checklist | "이 패턴을 자동화하는 방법: ..." |

##### Classification Rules

- **When classification confidence is low**: note the runner-up candidate alongside — `[Rule/Knowledge]`
- **When a correct usage example exists within the same project**: prefer `[Lapse]` (likely already known)
- **Place the intervention strategy at the end of the Why block** under a "Prevention Direction" subheading
- The intervention must include a **mechanism + prevention method**, not a mere callout ("just fix it")

##### Integrated Title Format

Both the cognitive-error label and the grounding-state marker go in the title. Normalized format:

```
{심각도} {오류유형}: {발견 제목} {grounding 표기}
```

| Grounding State | Integrated Title Example |
|-----------------|--------------------------|
| grounded | `🔴 Must Fix [Knowledge]: 비격리 상태에서의 data race` |
| partially_grounded | `🟡 Should Improve [Rule]: 캐시 무효화 누락 (추가 검증 권장)` |
| needs_verification | `🟡 Should Improve [Lapse]: 에러 핸들링 누락 (확인 필요)` |

#### Specification Grounding — Required Output Contract

Mandatorily attach **grounding metadata** to every 🔴/🟡 finding.

##### Grounding State Classification

| State | Condition | Output Marker |
|-------|-----------|---------------|
| **grounded** | At least 1 piece of primary evidence exists (test, protocol, type system, etc.) | No marker (default) |
| **partially_grounded** | Only secondary evidence exists (comment, doc, error message, etc.) | `(추가 검증 권장)` after the finding title |
| **needs_verification** | Inference based on code patterns/heuristics with no direct evidence | `(확인 필요)` after the finding title |

##### Required Fields

Include the following in the Why block of each 🔴/🟡 finding:

1. **Evidence source** — State the concrete test/contract/type constraint being violated
   - Good example: "`UserRepository` 프로토콜의 async 계약을 위반 (L42)"
   - Bad example: "thread-safe하지 않습니다"
2. **Evidence confidence** — State the certainty level of the evidence as `높음`/`중간`/`낮음` (a separate field from the cognitive error's "classification confidence")
3. **Test suggestion when evidence is missing** — When not grounded, suggest a test that could verify this issue

##### Expression Constraint Rules

The **permissible level of expression varies** by grounding state:

| State | Allowed Expressions | Forbidden Expressions |
|-------|---------------------|------------------------|
| **grounded** | Assertive forms such as "위반", "오류", "버그" | — |
| **partially_grounded** | "가능성이 높음", "~로 이어질 수 있음" | "위반", "반드시", "확실히" |
| **needs_verification** | "확인 필요", "추가 테스트 필요", "~일 가능성" | All assertive forms |

> **Principle**: The strength of the evidence determines the confidence of the expression. Do not assert without evidence.

#### Growth Mindset Framing

- Include a normalization phrase in 🔴 findings: "이 패턴은 숙련된 개발자도 자주 빠지는 함정입니다"
- Use growth language instead of deficit language

---

### Phase 5: Mental Model Visualization

**Conditional execution**: Only when there is a 🔴 or 🟡 finding that requires an architecture change.

#### Trigger Conditions (meet one or more)

- A change in dependency direction is needed
- A new type is being proposed
- A change in module boundaries is being proposed

#### Visualization Rules

- Generate **only 1 Mermaid diagram**. Do not generate several.
- Type selection criteria:

| Situation | Diagram Type |
|-----------|--------------|
| Dependency change between types | `flowchart` (LR or TD) |
| State transition change | `stateDiagram-v2` |
| Call-flow change | `sequenceDiagram` |

- Express the Before(current) → After(proposed) structure in a single diagram, or split into two Before/After diagrams if needed.
- Keep diagram nodes within 5-8.
- If the trigger conditions do not apply, **skip** Phase 5. Do not even add a note like "Nothing to visualize."

---

### Phase 6: Metacognitive Prompts

yoda review's metacognitive prompts split into **two scopes**. These two are separate and complementary.

#### 6a. Per-review Questions (placed in Layer 3)

Place **2 questions** that run through the whole review at the end of Layer 3.

| Question | Direction | Design Principle |
|----------|-----------|------------------|
| **Question 1** | Extensibility/handling change | "이 코드에 X 요구사항이 추가되면 어디를 수정해야 할까요?" — derived from a concrete change scenario found in the review |
| **Question 2** | Transfer/application | "이 리뷰에서 발견한 패턴이 프로젝트의 다른 어디에도 존재할까요?" — extend an individual finding into a team/project-level improvement |

#### 6b. Per-finding Prompts (inside each Layer 2 finding, optional)

Among the metacognitive scaffolds (plan-monitor-evaluate) in `learning-science.md`, the **monitoring/evaluation** prompts may be optionally placed inside individual findings. However, since review mode is fixed to audience=mid, all are optional.

- **Monitoring**: At the end of the Why block, "이 설명이 예상과 일치하나요?" (optional)
- **Evaluation**: After the After block, "이 수정이 작동하지 않는 경우는?" (optional)

> Use per-finding prompts only within the range that does not exceed the Why block length principle (6-10 sentences). If there are 5 or more findings, omit them to control cognitive load.

#### Common Rules

- Questions must be derived from the **concrete context of the reviewed code**. No generic/abstract questions.
- Apply information-gap theory: mention what the reader "already knows," then guide toward what they "don't yet know."
- Do not provide the answer directly. Only prompt thinking.

---

## Output: 3-Layer Progressive Disclosure

Structure the review output into **3 layers** based on the reader's time budget. Each layer provides value independently, and the deeper one reads, the greater the learning effect.

---

### Layer 1: Core Summary (30s)

The reader must be able to grasp the review result within 30 seconds.

#### Composition

1. **One-line summary** — The core state of this code in one sentence.
2. **Severity counts** — `🔴 2 | 🟡 3 | 🔵 1 | 🟢 2 | 💡 1`
3. **Findings table** — Each finding's label + one-line description.

---

### Layer 2: Detailed Analysis (5-10 min)

#### 🔴 Must Fix, 🟡 Should Improve Findings

- Detailed analysis as a **complete Before/After/Why triple** for each.
- Apply the Phase 3 Why block integrated structure (6 elements) and Reveal Gate as-is.
- Title each finding with the Phase 4 integrated title format (`{심각도} {오류유형}: {제목} {grounding 표기}`).

#### 🔵 Nit Findings

- Collect into a **concise table** instead of individual triples.
- Place Before/After side by side as inline code.

---

### Layer 3: Deep Insight (+5 min)

Extend beyond the review into learning and team improvement.

#### Components

1. **🟢 Praise** — Praise a well-done part of the code concretely.
   - Quote the relevant code + explain why it is good, without Before/After.
   - Name the principle so the reader can consciously repeat this pattern.

2. **💡 Insight** — 1 per whole review. A team-level insight that goes beyond this code.
   - Generalize the found pattern into a team-level improvement proposal.
   - Include a concrete action plan.

3. **Mental Model Visualization** — The Mermaid diagram generated in Phase 5 (only when applicable).

4. **Metacognitive Prompts** — The 2 per-review questions from Phase 6a. (Per-finding prompts are optionally placed inside each Layer 2 finding.)

5. **Share Guidance** — If you want to share this review with the team:

```
> 이 리뷰를 팀과 공유하려면: `/yoda share --from-review`
```

---

## Output Structure Summary

```
┌─────────────────────────────────────┐
│ Layer 1: 핵심 요약 (30초)           │
│  ├─ 한 줄 요약                      │
│  ├─ 심각도 카운트                    │
│  └─ 발견 사항 테이블                 │
├─────────────────────────────────────┤
│ Layer 2: 상세 분석 (5-10분)         │
│  ├─ 🔴 Must Fix × Before/After/Why │
│  ├─ 🟡 Should Improve × B/A/W      │
│  └─ 🔵 Nits 테이블                  │
├─────────────────────────────────────┤
│ Layer 3: 깊은 통찰 (+5분)           │
│  ├─ 🟢 Praise                       │
│  ├─ 💡 Insight                      │
│  ├─ Mermaid 시각화 (해당 시)        │
│  ├─ 메타인지 프롬프트 (2개 질문)    │
│  └─ /yoda share 안내               │
└─────────────────────────────────────┘
```
