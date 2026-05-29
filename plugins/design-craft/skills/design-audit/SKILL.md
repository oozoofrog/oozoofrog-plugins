---
name: design-audit
description: "Audits an app's current design state and matches it against the awesome-design-md catalog (full bodies of 69 brand DESIGN.md files internalized) to deliver a Top-3 design-system matching report with exact hex/font/value citations. Use for '디자인 진단', '디자인 감사', 'design audit', '디자인 체크', '디자인 상태', '디자인 분석', '디자인 리뷰', '내 앱 디자인', '우리 앱 디자인', '디자인 시스템 추천', '어떤 디자인이 어울려', '어떤 디자인이 맞을까', 'DESIGN.md 추천', '디자인 매칭', '디자인 벤치마크', 'awesome-design-md' requests. Accepts platform-agnostic input (iOS/Web/Android/tokens), returns a Top-3 matching report plus each brand's exact design tokens, and behaves equivalently to having installed the DESIGN.md via the getdesign CLI."
model: opus
argument-hint: "[<target path|screenshot|description> --platform ios|web|android|any]"
---

<example>
user: "내 iOS 앱 디자인 진단해줘"
assistant: "design-audit 모드로 전환. Xcode 프로젝트의 색상·폰트·컴포넌트 토큰을 스캔하고, awesome-design-md 69개 브랜드 중 Top-3 매칭을 리포트로 제공합니다."
</example>

<example>
user: "우리 웹 앱에 어떤 디자인 시스템이 어울릴까? 스크린샷 첨부"
assistant: "design-audit 모드로 전환. 스크린샷의 색상/타이포/밀도/무드를 추출하고, 카탈로그 인덱스와 매칭해 Top-3를 선정합니다."
</example>

<example>
user: "'다크 미니멀, 보라 포인트, 개발자 도구 느낌' 이런 방향이야. 맞는 DESIGN.md 추천해줘"
assistant: "서술형 입력을 파싱해 trait 벡터(무드/색상/카테고리)를 구성하고, matching-rubric으로 Top-3를 리포트합니다."
</example>

# design-audit

Audit the current app's design state and match the best-fitting Top-3 brand design systems from VoltAgent's [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) catalog, producing a **report** with exact hex/font/value citations.

Respond to the user in Korean.

## Equivalence Principle — Parity with the getdesign CLI

This skill should deliver results **equivalent** to working from a DESIGN.md installed via `npx getdesign@latest add <slug>`. To achieve this:

- **Full-body internalization**: the actual `DESIGN.md` bodies of all 69 brands are byte-level replicated under `$REF/designs/*.md`. No summarizing or restructuring.
- **Exact citation**: when the report mentions brand tokens (color hex, font family, numeric values), read them directly from the body and cite verbatim rather than paraphrasing — paraphrase loses the load-bearing exact values.
- **Provenance**: `$REF/designs/manifest.json` preserves the original sha256 hashes, commit, and update date; `$REF/designs/ATTRIBUTION.md` records the MIT license and attribution.

If the user wants to install a chosen brand into their project, also offer the `npx getdesign@latest add <slug>` command as an optional aid.

## Path Convention

This skill's absolute path varies by install environment (e.g., direct repository use vs. placement under `~/.claude/plugins/cache/.../design-audit/`). All paths in this document are **relative to the skill directory where this SKILL.md lives**, with these shorthand symbols:

```
$SKILL = directory where this SKILL.md lives (absolute path resolved at runtime)
$REF   = $SKILL/references
```

**Read tool calls**: the Read tool requires absolute paths, so when you see an example like `Read $REF/designs/stripe.md`, construct `<skill absolute path>/references/designs/stripe.md` from the absolute path where SKILL.md was loaded. Use that resolved path rather than a hardcoded `plugins/...` path, which breaks across install environments.

**Bash script calls**: when running `$SKILL/scripts/*.sh`, use the `$CLAUDE_PLUGIN_ROOT` environment variable or the absolute path from when SKILL.md was loaded. Scripts resolve their own path via `BASH_SOURCE`, so internal logic is portable as long as the call path is correct.

## Scope and Non-Scope

| Scope (the skill does this) | Non-scope (the skill does not) |
|---------------------|---------------------------|
| Extract current app's design tokens/mood/category | Replace actual code colors/fonts |
| Top-3 matching based on 69 internalized DESIGN.md bodies | Generate platform-specific token code |
| Exact hex/font/value citation for Top-3 brands | Implement SwiftUI/CSS/Compose conversion |
| Provide selection rationale, trade-offs, contrast references | Run installation (user does this directly) |

For platform-specific token conversion/application, switch to the **design-craft** skill. For designer/painter-based generation, use the **design-research + design-craft** combination.

## Input Sources

Use three inputs alone or combined. The more you combine, the higher the accuracy.

1. **Code/token files** — SwiftUI Color, Asset Catalog, CSS variables, Tailwind config, Android colors.xml, design tokens JSON
2. **Screenshots** — images provided by the user or captured from the Simulator/browser (visual analysis via the Read tool)
3. **Narrative** — natural-language descriptions like "dark minimal, purple accent, developer tool"

## Workflow

### Phase 0: Identify Input

Determine the input type:

- Project path given → proceed in **code extraction mode**
- Image file/screenshot attached → proceed in **visual analysis mode**
- Text description only → proceed in **narrative parsing mode**
- Nothing given → request at least one source (AskUserQuestion is available)

The `--platform ios|web|android|any` argument branches the extraction strategy. Default is `any` (platform-agnostic tokens only).

### Phase 1: Extract Design State

Load `$REF/extraction-guide.md` and follow the block for the relevant platform. Structure the extraction into a **trait vector** with these 6 fields:

| Field | Content | Example |
|------|------|------|
| palette | 3–5 main colors + brightness extremes | `#0A0A0A`, `#8B5CF6`, `#F5F5F4` / very-low-brightness + high-saturation purple |
| typography | family + main weights | `Geist`, weight 400/600 / mono `JetBrains Mono` |
| density | spacing/component density | loose / moderate / dense |
| mood | 3 mood keywords | `minimal`, `dark`, `developer` |
| surface | background/card treatment | flat / elevated / gradient |
| category | inferred industry | `developer-tool`, `fintech`, `ai-llm`, ... |

Mark **fields that cannot be extracted** as `unknown` and state this in the report. Do not fill missing data with guesses, since fabricated tokens make the match misleading.

### Phase 2: First-Pass Matching (Index-Based Screening)

Load `$REF/catalog-index.md` — an index structuring the 69 brands into 9 categories. Each entry has `slug | category | file | one_liner | traits[]`.

Compute the **Top-5 candidates** using the scoring formula in `$REF/matching-rubric.md`:

```
score(brand) = palette_match * 0.30
             + mood_match    * 0.25
             + category_fit  * 0.20
             + typography_fit * 0.15
             + density_fit   * 0.10
```

Before finalizing Top-3 from Top-5, first perform the **body verification in Phase 3**. Follow these rules:

- **Avoid category bias**: if all of Top-3 are in the same category, consider swapping the 2nd place for a candidate from a different category
- **Rationale required**: cite at least 2 matching traits ("which traits matched") for each match
- **Record trade-offs**: report not only strengths but also "which characteristics are sacrificed by adopting this brand"

### Phase 3: Second-Pass Matching (Body Precision Verification)

For each Top-5 candidate, load `$REF/designs/{slug}.md` with the Read tool — this file is a byte-level replica of the original DESIGN.md body.

Extract the following from the body and re-check against the vector:

1. **Section 1 — Visual Theme & Atmosphere**: reconfirm mood keywords
2. **Section 2 — Color Palette & Roles**: actual hex values (e.g., Stripe Purple `#533afd`)
3. **Section 3 — Typography Rules**: actual font family names (e.g., `sohne-var`, `SF Pro`)
4. **Section 7 — Do's and Don'ts**: identify guidelines that may conflict with the user's app

If the body conflicts with the index one_liner, **prioritize the body** and re-score. Example: if a brand tagged only `purple` in the index turns out to use `#6366F1` (indigo) in the body, recompute palette_match.

After re-scoring, finalize Top-3. If Top-5 is insufficient for information gathering, you may expand to Top-7.

### Phase 4: Generate Report

Follow the section structure of `$REF/report-template.md` exactly. The report has these 7 sections:

1. **요약** — current app trait vector (6 fields)
2. **Top-3 매칭** — per-brand score, rationale, trade-offs
3. **Top-3 디자인 토큰 발췌** — **measured** palette/typo/key values cited directly from each brand's DESIGN.md body (no paraphrasing)
4. **선택 가이드** — which candidate fits which situation
5. **본문 전체 경로** — `Read $REF/designs/{slug}.md` + auxiliary install command
6. **주의사항** — data limits, unverified inferences
7. **다음 단계** — after selection, convert tokens via design-craft or install directly

Output the report as markdown text. If file saving is needed, ask the user for the path.

### Phase 5: Suggest Follow-up

Right after the report, present only a single follow-up option to the user:

- "Top-3 중 X를 골랐다면 → 본문 전체 로드 확장 / 설치 커맨드 실행 / design-craft로 토큰 변환"

Do not modify code automatically. End here without user approval, since installation and code changes belong to the user.

## Catalog Freshness

`$REF/designs/*.md` and `$REF/designs/manifest.json` are a byte-level snapshot of the npm `getdesign@0.6.8` tarball (currently 69 brands). To check whether upstream has been updated:

```bash
# 스킬 상대 경로 — 런타임에서 스킬 절대 경로로 확장
bash $SKILL/scripts/fetch-catalog-diff.sh

# Bash에서 변수로 접근할 때 (플러그인 설치 환경)
bash $CLAUDE_PLUGIN_ROOT/skills/design-audit/scripts/fetch-catalog-diff.sh
```

This script downloads the `manifest.json` from the latest `getdesign` tarball on the npm registry, compares it against the local `$REF/designs/manifest.json` sha256 hashes/brand set, and outputs new, removed, and body-changed brands. If differences are found, re-sync with `$SKILL/scripts/sync-designs.sh` (then manually update the table in `$REF/catalog-index.md`); if there are none, it exits 0.

## Per-Input-Source Detail

### Code/Token File Mode

For platform blocks, refer to the relevant section of `$REF/extraction-guide.md`. The core search patterns are:

- **iOS**: `**/*.xcassets/**/Contents.json`, `Color(red:green:blue:)`, `Color("Asset")`, `Font.custom`, `.font(.system)`
- **Web**: `:root { --color-* }`, `tailwind.config.*`, `theme.extend.colors`, global CSS variables
- **Android**: `res/values/colors.xml`, `Theme.kt`, `MaterialTheme.colorScheme`
- **Platform-agnostic**: `design-tokens.json`, `tokens.yaml`, `*.tokens.*`

Find files with Glob/Grep and read exact values with Read. Read values from the source rather than guessing colors, since guessed colors corrupt the vector.

### Screenshot Mode

Open the image with the Read tool and identify:

- **Dominant hex** of 3–5 colors (approximate values acceptable, e.g., `#2E2A2B`-level precision)
- **Typography**: serif vs sans vs mono, weight contrast strength
- **Density**: elements per screen, padding area ratio
- **Mood**: dark/light, flat/gradient, editorial/functional

If multiple images are provided, prioritize common traits and note per-screen differences separately.

### Narrative Mode

Extract the 6 fields from the natural-language description. Mark missing fields as `unknown` and present up to 2 follow-up questions to the user:

- "주 색상은 무엇인가? (hex 또는 이름)"
- "타이포 방향은 serif/sans/mono 중 어느 쪽인가?"

If 3 or more questions would be needed, allow uncertainty and proceed with `unknown`.

## Agent Delegation

Large code scans that are burdensome within a single skill turn can be delegated to an Explore subagent:

```
Agent(subagent_type=Explore,
      description="앱 디자인 토큰 스캔",
      prompt="<플랫폼별 glob 패턴 + 추출 기준>. Top 색상 5개와 폰트 패밀리만 리포트. 200단어 이내.")
```

After delegation, assemble the trait vector and run matching on the main thread.

## Limits and Caveats

- **Catalog snapshot point**: internalized from `getdesign@0.6.8` (2026-04-24). When upstream updates, `scripts/fetch-catalog-diff.sh` detects the diff and `scripts/sync-designs.sh` re-syncs.
- **"Similar" is not the default**: the most similar brand is not necessarily the best. Include "contrast brands" (1–2 in a completely different direction) in the report as references to expand the user's imagination.
- **Brand trademarks**: the token values this skill provides are design-system records extracted from public CSS values; rights to each brand's logo, trademark, and visual identity belong to the respective company. Legal review is needed before commercial use.

## Additional Resources

### Reference Files

- **`references/catalog-index.md`** — index of 69 brands' category/slug/traits/local file paths
- **`references/designs/*.md`** — full DESIGN.md bodies of 69 brands (byte-replicated from awesome-design-md originals)
- **`references/designs/manifest.json`** — each file's sha256 hash/sourceCommit/update date
- **`references/designs/ATTRIBUTION.md`** — full MIT license and source attribution
- **`references/extraction-guide.md`** — extraction strategies and glob patterns per iOS/Web/Android/platform-agnostic input
- **`references/matching-rubric.md`** — trait vector vs catalog matching scoring formula (+ body re-scoring rules)
- **`references/report-template.md`** — Top-3 report markdown structure (7 sections — includes body token excerpts)

### Scripts

- **`scripts/fetch-catalog-diff.sh`** — compares the `manifest.json` of the latest remote npm package (`getdesign`) tarball against local hashes to detect changes
- **`scripts/sync-designs.sh`** — re-syncs `references/designs/` from a new tarball when upstream changes are found
- **`scripts/fetch-design-md.sh`** — immediately prints the local body for a slug and provides auxiliary install command/URL guidance

### Related Skills

- **design-craft** — use after selecting a brand from Top-3 to convert to platform-specific tokens
- **design-research** — use when designer/painter-based tokens are needed (in contrast to brand-based)
