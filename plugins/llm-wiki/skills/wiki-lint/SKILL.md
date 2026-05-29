---
name: wiki-lint
description: "Check wiki health — detect contradictions, orphan pages, missing cross-references, stale content, and propose new pages/sources. \"위키 점검\", \"wiki lint\", \"위키 검증\", \"wiki check\", \"위키 건강\", \"wiki health\", \"위키 정리\", \"wiki cleanup\", \"위키 진단\", \"wiki validate\", \"위키 상태\" 등의 요청에 사용하세요."
argument-hint: "[--fix: auto-fix mode] [--report: report-only output]"
---

<example>
user: "/wiki-lint"
assistant: "위키 건강 상태를 점검하겠습니다."
</example>

<example>
user: "위키 점검해줘"
assistant: "위키의 구조, 교차참조, 콘텐츠 품질을 검사하겠습니다."
</example>

<example>
user: "/wiki-lint --fix"
assistant: "위키를 점검하고, 구조적 문제는 자동 수정하겠습니다."
</example>

<example>
user: "위키 정리 좀 해줘"
assistant: "위키 건강 점검 후 수정 가능한 항목을 자동으로 정리하겠습니다."
</example>

<example>
user: "wiki health check"
assistant: "위키의 전체 건강 상태를 진단하겠습니다."
</example>

# Wiki Lint

Check the wiki's structural health, cross-reference integrity, and content quality.

> **Core principle**: A wiki grows as it is used, but it decays without maintenance. Lint periodically checks wiki health to keep cross-reference integrity, content freshness, and structural consistency.

Respond to the user in Korean.

## Argument handling

- `--fix` → auto-fix structural issues (content fixes always require user confirmation)
- `--report` → report only, no fix suggestions
- default (no args) → check + fix suggestions (fix after user confirmation)

## Execution Steps

### Phase 0: Confirm the wiki exists

1. Check that the `.wiki/` directory exists.
   - If missing: print "위키가 초기화되지 않았습니다." and stop.
2. Read `.wiki/schema.md`.
3. Read `.wiki/index.md`.
4. List all pages under `.wiki/pages/` (`Glob` for `.wiki/pages/*.md`).

### Phase 1: Structural Health

1. **Index ↔ page consistency**:
   - Listed in `index.md` but no file in `pages/` → **Critical: 유령 인덱스 항목**
   - Exists in `pages/` but absent from `index.md` → **Warning: 미등록 페이지**

2. **Frontmatter validity**:
   - Parse and validate the YAML frontmatter of every page.
   - Confirm required fields (`title`, `type`, `created`, `updated`) are present.
   - Confirm `type` is a valid type defined in schema.md.
   - Confirm `updated` is later than `created`.

3. **Filename rules**:
   - kebab-case compliance
   - 64 characters or fewer
   - allowed characters only (lowercase, digits, hyphen)

4. **Source/reference validation**:
   - `sources` field: each entry actually exists in the `sources/` directory.
   - `references` field: each entry actually exists in the `pages/` directory (entry name + `.md`).
   - **analysis type exception**: an analysis page with no `sources` and only `references` is valid (it was created via wiki-query --save).

### Phase 2: Link Integrity

Read every page and extract `[[wikilinks]]`:

1. **Broken links**:
   - The target of `[[target]]` does not exist as `pages/target.md` → **Warning: 깨진 링크**
   - This may be an intentional "red link" (a page that does not exist yet), so it is a Warning.

2. **Orphan pages**:
   - A page not referenced by any `[[wikilink]]` from any other page → **Warning: 고아 페이지**
   - `overview.md` and `glossary-*.md` are exceptions (entry points by design).

3. **One-way references**:
   - A references `[[B]]`, but B's related entries do not contain `[[A]]` → **Info: 단방향 참조**

4. **Cross-reference density**:
   - A page with no cross-references at all → **Info: 고립 페이지**
   - Detect pages with extremely few cross-references relative to the average.

### Phase 3: Content Quality

1. **Stale content**:
   - A page whose `updated` date is more than 30 days old → **Info: 갱신 필요 가능성**
   - A wiki page not updated after its source file changed → **Warning: 소스 변경 후 미갱신**
   - **api-learn stale detection**: for pages where `source_kind: api-learn` and `authority_path` is present:
     - Check that the file at `authority_path` exists (if deleted → **Warning: 권위 원본 삭제됨**)
     - If the source reference's frontmatter `collected` date is newer than the wiki page's `updated` → **Warning: API 레퍼런스가 갱신됨, 위키 재동기화 필요**
     - If the source reference's `version` differs from the version in the wiki page's tags → **Warning: 라이브러리 버전 불일치**

2. **Stub pages**:
   - A page with body content under 100 characters → **Info: 스텁 페이지 (내용 보강 필요)**

3. **Contradiction markers**:
   - List pages containing a `> ⚠️ 모순` block → **Info: 미해결 모순**

4. **Duplicate pages**:
   - Pages with overlapping titles or aliases → **Warning: 중복 가능성**
   - Detect pages with identical tags and similar content.

### Phase 4: Suggestions

Generate suggestions for wiki growth:

1. **New page suggestions**:
   - Broken link targets (red links) → suggest creating those pages.
   - Concepts mentioned across multiple pages but lacking their own page → suggest creating a page.

2. **New source suggestions**:
   - Identify areas with poor wiki coverage.
   - Suggest exploring related sources.

3. **Structure improvement suggestions**:
   - Excessively long pages → suggest splitting.
   - Duplicate pages → suggest merging.
   - Suggest category re-classification.

### Phase 5: Report & Fix

#### Report output

```markdown
# Wiki Lint Report

## 요약
| 항목 | Critical | Warning | Info |
|------|----------|---------|------|
| 구조 | {N} | {N} | {N} |
| 교차참조 | {N} | {N} | {N} |
| 콘텐츠 | {N} | {N} | {N} |
| **합계** | **{N}** | **{N}** | **{N}** |

## 위키 통계
- 총 페이지: {N}개
- 총 소스: {N}개
- 총 교차참조: {N}개
- 평균 교차참조/페이지: {N.N}
- 고아 페이지: {N}개
- 미해결 모순: {N}건

## 상세 진단

### Critical
| 항목 | 위치 | 설명 |
|------|------|------|
| ... | ... | ... |

### Warning
| 항목 | 위치 | 설명 |
|------|------|------|
| ... | ... | ... |

### Info
| 항목 | 위치 | 설명 |
|------|------|------|
| ... | ... | ... |

## 제안
1. {제안 내용}
2. {제안 내용}
```

#### Auto-fix (`--fix` or user approval)

**Auto-fixable (structural issues)**:
- Add unregistered pages to index.md
- Remove ghost index entries
- Fill in missing required frontmatter fields
- Add the back-reference for one-way references
- Update page_count/source_count in index.md

**Requires user confirmation (content issues)**:
- Augmenting stub pages
- Merging duplicate pages
- Resolving contradictions
- Updating stale content

After fixing, append a lint record to log.md:
```
| {YYYY-MM-DD} | lint | — | {N}개 | {수정 요약} |
```

## Rules

- Always notify the user when a Critical issue is found.
- Even with `--fix`, content fixes require user confirmation — content changes are not safely reversible without the user's intent.
- With `--report`, do not modify any file.
- Do not delete wiki pages; the user deletes them directly.
- Language: respond in Korean.
