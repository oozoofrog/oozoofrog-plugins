# Matching Rubric — Trait vector vs catalog matching scoring

**Two-stage matching structure**:

- **Phase 2 (index screening)**: derive the Top-5 candidates using only the one_liner and traits from `catalog-index.md`. Cheap keyword matching.
- **Phase 3 (body-level precise verification)**: for each of the Top-5, load Sections 2–3 of `references/designs/{slug}.md` via Read and re-score palette and typography. If the index and the body disagree, prefer the body.

The formula below applies to both stages, but in Phase 3 the weights of palette_match and typography_fit are computed more strictly based on the actual hex values and font names.

## Score formula

```
score(brand) = 0.30 * palette_match
             + 0.25 * mood_match
             + 0.20 * category_fit
             + 0.15 * typography_fit
             + 0.10 * density_fit
```

Each sub-score is in the `[0, 1]` range. The weights sum to 1.0.

## Computing the sub-scores

### palette_match (0.30)

**Phase 2 (index-based)**: normalize the user's palette color families and compare them against the color keywords in the brand traits:

| Match level | Score |
|-----------|------|
| Primary accent color family exact match (purple ↔ purple) | 1.0 |
| Similar color family (purple ↔ violet, pink-purple) | 0.7 |
| Partial match at the secondary-color level | 0.4 |
| Only sub-lightness (dark/light) matches | 0.3 |
| No match | 0.0 |

**Phase 3 (body-based precise recomputation)**: parse the actual hex values from Section 2 of `references/designs/{slug}.md` and recompute the HSL distance against the user's palette:

```
distance(userHex, brandHex) = |ΔH|/180 + |ΔS|/100 + |ΔL|/100  # normalize each component
# weight-sum 1.0 - min(distance, 1.0) to re-derive palette_match
```

If the Phase 3 recomputation differs from the Phase 2 score by `±0.15` or more, adopt the body-based value and re-rank. Example: if Stripe is tagged `purple` in the index but the body reveals `#533afd` (a high-purity violet), it is farther than expected from the user's "soft lavender" and the score may be lowered.

**Note**: if the user is "dark + neutral", `mono`-based brands (`uber`, `spacex`, `x.ai`) should score high; if "dark + accent", `supabase` (emerald), `linear.app` (purple), `kraken` (purple) should score high.

### mood_match (0.25)

Jaccard similarity of the user's mood keywords and the brand's traits keywords × 1.0:

```
mood_match = |user_mood ∩ brand_traits| / |user_mood ∪ brand_traits|
```

Normalize keywords using the Mood dictionary in `catalog-index.md` before comparing. Group synonyms like `minimal` ≡ `austere` ≡ `sparse` and `premium` ≡ `elegant` in the dictionary:

- `minimal` = {minimal, austere, sparse, subtraction}
- `premium` = {premium, elegant, luxury}
- `playful` = {playful, friendly, illustration}
- `editorial` = {editorial, magazine, serif-headings}
- `cinematic` = {cinematic, full-bleed, photo}
- `bold` = {bold, monumental, uppercase}

### category_fit (0.20)

| Match level | Score |
|-----------|------|
| Same category | 1.0 |
| Adjacent category (developer-tool ↔ backend-devops) | 0.7 |
| Unrelated category | 0.3 |
| `unknown` | 0.5 (no penalty) |

**Adjacent category table**:

| Category | Adjacent |
|----------|------|
| AI & LLM | Developer Tools, Backend |
| Developer Tools | AI & LLM, Backend |
| Backend | Developer Tools, Productivity |
| Productivity | Backend, Design Tools |
| Design Tools | Productivity, Media |
| Fintech | Productivity, Media |
| E-commerce | Media, Design Tools |
| Media | E-commerce, Automotive |
| Automotive | Media, E-commerce |

### typography_fit (0.15)

**Phase 2 (index-based)**:

| User typography | Brand keywords | Score |
|-------------------|--------------|------|
| mono family | `mono`, `geist`, `terminal` | 1.0 |
| sans (modern) | `geist`, `neo-grotesk`, `sans` | 1.0 |
| serif | `serif`, `editorial`, `magazine` | 1.0 |
| uppercase heavy | `uppercase`, `monumental`, `bold` | 1.0 |
| No match | | 0.3 |
| `unknown` | | 0.5 |

**Phase 3 (body-based precise recomputation)**: parse the actual font-family string from Section 3 of `references/designs/{slug}.md`. Same family name → 1.0, same category (both mono/sans/serif) → 0.7, different → 0.3. Example: if the user's app uses `Geist` and Vercel's body also specifies `Geist`, it gets the top score.

### density_fit (0.10)

| User density | Compatible brand trait | Score |
|----------------|-----------------|------|
| loose | `minimal`, `premium`, `sparse`, `cinematic` | 1.0 |
| moderate | `clean`, `structured`, `editorial` | 1.0 |
| dense | `dashboard`, `data-dense`, `trading`, `docs` | 1.0 |
| Opposite trait | | 0.2 |
| `unknown` | | 0.5 |

## Top-3 selection post-processing

1. **Prevent category bias**: if the Top-3 are filled only with the same category, consider replacing the 2nd-place entry with an adjacent-category candidate. But the score gap between the 2nd place and the new candidate must be within `0.05`.
2. **Tie tiebreaker**: on a tie, prefer the side whose brand traits explicitly list the user's primary accent color.
3. **Provide a contrast brand**: additionally provide one brand whose mood and color are the polar opposite of the Top-3 as a "Contrast reference". Example: if the Top-3 are all `dark/minimal`, use `zapier` (warm orange friendly) as the contrast.

## Rationale (justification sentence) requirements

Each Top-3 match must include the following 3 sentences:

1. **Match**: "User trait X matches brand trait Y (score: 0.XX)"
2. **Gain**: "One trait gained by adopting this brand"
3. **Loss**: "One trait sacrificed by adopting this brand"

An empty Loss sentence is a signal that the match's skeptical review is insufficient. State at least one trade-off, even if you have to force it.

## Failure case handling

- **All candidate scores < 0.4**: this means there is no suitable brand in the catalog. State "No strong match in catalog" in the report and offer the user the following paths:
  - Expand scope: `--platform any` or remove the category constraint
  - Alternative: use the `design-research` skill (designer/painter based)
- **Top 3 scores cluster within 0.05**: state "No meaningful difference either way; choice comes down to brand preference."

## Sample calculation

User trait:
- palette: `["#0A0A0A", "#8B5CF6", "#F5F5F4"]` (dark + purple)
- mood: `["minimal", "developer"]`
- category: `developer-tool`
- typography: `mono`
- density: `moderate`
- surface: `dark`

Candidate `linear.app` (traits: minimal, purple, precise / category: Productivity / typography: sans / density: moderate):

- palette_match = 1.0 (purple exact match) × 0.30 = **0.30**
- mood_match = |{minimal} ∩ {minimal, precise}| / |{minimal, developer} ∪ {minimal, precise}| = 1/3 ≈ 0.33 × 0.25 = **0.08**
- category_fit = 0.7 (adjacent) × 0.20 = **0.14**
- typography_fit = 0.3 (mono ≠ sans) × 0.15 = **0.045**
- density_fit = 1.0 (moderate direct match) × 0.10 = **0.10**

**total = 0.665**

Candidate `supabase` (dark, emerald, code / Backend / mono / moderate):

- palette_match = 0.3 (only dark matches, emerald ≠ purple) × 0.30 = **0.09**
- mood_match = |{developer}∩{code}| (with code≡developer dictionary mapping, 1/2=0.5) × 0.25 = **0.125**
- category_fit = 0.7 × 0.20 = **0.14**
- typography_fit = 1.0 × 0.15 = **0.15**
- density_fit = 1.0 × 0.10 = **0.10**

**total = 0.605**

Both candidates are in the 0.6 range. Include both in the report and differentiate them with Loss/Gain.
