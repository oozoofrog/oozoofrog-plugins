---
name: yoda
description: "Learning-science-based code review and educational content generation. /yoda review for Before/After/Why reviews, /yoda share to spread to a team in 4 formats (md/web/wiki/slides). 코드 리뷰, 코드 분석, 코드 설명, 팀 공유, 온보딩, 기술 세미나, 지식 전파 요청 시 활성화"
argument-hint: "[review <target> | share <input> --format md|web|wiki|slides --audience junior|mid|senior]"
model: opus
---

<example>
user: "이 ViewModel 리뷰해줘"
assistant: "/yoda review 모드로 6단계 파이프라인을 실행하여 Before/After/Why 기반 3계층 리뷰를 수행하겠습니다."
</example>

<example>
user: "이 코드를 팀에 공유할 마크다운 문서로 만들어줘"
assistant: "/yoda share --format md 모드로 Worked Examples와 이중 코딩 원칙을 적용한 교육 마크다운 문서를 생성하겠습니다."
</example>

<example>
user: "방금 리뷰한 내용으로 세미나 슬라이드 만들어줘"
assistant: "/yoda share --from-review --format slides 모드로 인지적 도제 모델링을 적용한 15장 Marp 프레젠테이션을 생성하겠습니다."
</example>

<example>
user: "Swift Concurrency 패턴을 주니어한테 설명하는 위키 글 써줘"
assistant: "/yoda share --format wiki --audience junior 모드로 4막 내러티브 구조와 높은 비계 수준의 위키 페이지를 생성하겠습니다."
</example>

# Yoda

Unified skill for learning-science-based code review and educational content generation.

Where conventional code review focuses on **"What"** (what is wrong), yoda also addresses **"Why"** (why it is wrong, why it should be fixed this way). It turns code review into a **learning experience** through Before/After/Why triples, 3-layer progressive disclosure, curiosity triggers, ZPD calibration, and per-format learning-science principles.

**Respond to the user in Korean.** All output is written in Korean.

---

## Reference documents

Read the references below before running, so the rules they define are applied consistently.

- `review-reference.md` — Review mode 6-phase pipeline, 3-layer output structure, severity classification details
- `share-reference.md` — Share mode per-format generation strategy, --from-review pipeline, ZPD calibration details
- `learning-science.md` — 4 core principles, per-format additional principles, curiosity trigger rules, ZPD calibration matrix

---

## Mode selection

Analyze keywords in the user input to auto-select the mode.

| Mode | Keywords | Description |
|------|--------|------|
| **review** | 리뷰, 분석, 검토, 코드 봐줘, 코드 확인, 점검 | Code analysis + 3-layer learning-science-based report generation |
| **share** | 공유, 전파, 세미나, 슬라이드, 위키, 문서, 온보딩, 마크다운 | Educational content generation (supports 4 formats) |

---

## 4 core principles

Apply to all output. See `learning-science.md` for detailed rules.

| # | Principle | Application |
|---|------|------|
| 1 | **Before/After/Why triple** | For every finding, place the problem code (Before) + fixed code (After) + reason (Why) adjacently. Start Why with a curiosity trigger |
| 2 | **Signaling/labeling** | Attach a severity label (🔴🟡🔵🟢💡) + cognitive error type ([Slip]/[Rule]/[Knowledge]/[Lapse]) to every finding |
| 3 | **Coherence -- remove the unnecessary** | Remove what the reader already knows, information unrelated to the finding, decorative phrasing, and disclaimers |
| 4 | **Chunking** | One section/slide/card = one concept. Keep total findings to 7 or fewer |
| 5 | **Specification grounding** | Ground findings in concrete tests/contracts/specifications. Label speculation-based findings as "확인 필요" |
| 6 | **Growth framing** | Frame as a learning opportunity rather than a defect. Use normalizing phrasing + growth language |

---

## Review mode

### Entry point

```
/yoda review <파일|디렉토리>
```

- Targets a single source file or a directory path.
- For a directory, recursively traverse the source files underneath and review them all.

### Internal pipeline (6 phases)

| Phase | Name | Summary |
|-------|------|------|
| 1 | Context collection | Read the target code + git log/blame + explore tests/dependencies + infer author intent (run implicitly) |
| 2 | Multi-perspective analysis | Independent analysis through 5 lenses: structure/clarity/safety/performance/tests. Collect findings exhaustively first (no cap during analysis); apply the top-N selection (up to 3 per lens, 7 or fewer total) only at the output stage |
| 3 | Finding structuring | Structure each finding as a Before/After/Why triple (curiosity trigger → principle link → real impact) |
| 4 | Severity + error type classification | 🔴🟡🔵🟢💡 severity + [Slip]/[Rule]/[Knowledge]/[Lapse] cognitive error type tags |
| 5 | Mental model visualization | Generate one Mermaid diagram only when an architecture change is needed (conditional) |
| 6 | Metacognition prompt | Stimulate thinking with 2 questions on scalability/change-readiness + transfer/application |

### Output: 3-layer progressive disclosure

| Layer | Target reader | Time required |
|-------|----------|----------|
| **Layer 1: Key summary** | Busy lead, quick check | 30s |
| **Layer 2: Detailed analysis** | Code author, reviewer | 5-10 min |
| **Layer 3: Deep insight** | Developer with the will to learn | +5 min |

See `review-reference.md` and `templates/md-template.md` for detailed pipeline rules and output examples.

---

## Share mode

### Entry point

```
/yoda share <입력> [--format md|web|wiki|slides] [--audience junior|mid|senior]
```

### Input types

| Input | Detection method | Handling |
|------|----------|------|
| `--from-review` | Check for flag presence | Extract the previous review result from the conversation and convert it |
| File/directory | Verify path existence with `Glob` | Run independent analysis, then generate content |
| Free text | None of the two above apply | Explore the codebase with `Grep`, then generate based on real examples |

### Per-format generation & delegation

If `--format` is not given, present the format choices to the user and ask.

| Format | Generation method | Reinforced principles |
|------|----------|----------|
| **md** | Generate directly into `docs/yoda/YYYY-MM-DD-[slug].md` with the `Write` tool | Worked Examples (Sweller) + dual coding (Mayer) + elaboration questions (Dunlosky) |
| **web** | Generate interactive HTML directly, or delegate to the `frontend-design` skill | Progressive disclosure (Nielsen) + retrieval practice (Roediger & Karpicke) + personalization (Mayer) |
| **wiki** | Generate wiki markdown with the `Write` tool. Publish directly when Confluence MCP is connected | Storytelling (4-act narrative) + social constructivism (Vygotsky) + elaboration questions |
| **slides** | Generate 15 Marp markdown slides directly with the `Write` tool | Signaling reinforcement + coherence maximization + cognitive apprenticeship modeling (Collins et al.) |

> **확장**: `pptx` 스킬이 설치되어 있으면 `--format pptx`로 발표자 노트 포함 PowerPoint를 생성할 수 있다. 미설치 시 이 옵션은 표시하지 않는다.

### ZPD calibration (`--audience`)

Following Vygotsky's Zone of Proximal Development (ZPD) theory, calibrate content per audience level. Defaults to `mid` when unspecified.

| audience | Before/After/Why adjustment | Terminology handling |
|----------|----------------------|----------|
| **junior** | Explain Why in detail. Place rich comments in the After code | Include term explanations. Spell out full names alongside abbreviations |
| **mid** | Standard Before/After/Why triple. Name the principle + explain core impact | Use shared team vocabulary |
| **senior** | Turn Why into a question (prompt thinking without giving the answer) | Free use of abbreviations/jargon |

See `share-reference.md` and `templates/` for detailed per-format generation strategies and the --from-review pipeline.

---

## Usage

```bash
# Review 모드
/yoda review ChatRoomViewModel.swift          # 단일 파일 리뷰
/yoda review Sources/Feature/Chat/             # 디렉토리 리뷰

# Share 모드 — review 결과 기반
/yoda share --from-review --format md           # 마크다운 문서로 변환
/yoda share --from-review --format slides       # Marp 세미나 슬라이드로 변환
/yoda share --from-review --format slides       # Marp 슬라이드로 변환

# Share 모드 — 독립 콘텐츠 생성
/yoda share Sources/Feature/Chat/ --format wiki --audience junior   # 주니어 대상 위키
/yoda share "Swift Concurrency 에러 처리" --format web              # 인터랙티브 HTML

# Review → Share 파이프라인
/yoda review UserProfileViewModel.swift         # 1단계: 리뷰
/yoda share --from-review --format slides       # 2단계: 리뷰 결과를 슬라이드로
```

---

## Limitations

- Static analysis only; code is not executed.
- Severity classification involves qualitative judgment.
- For new files without git history, some steps of context collection (Phase 1) are skipped.
- `--format pptx` is available only when the `pptx` skill is installed.
