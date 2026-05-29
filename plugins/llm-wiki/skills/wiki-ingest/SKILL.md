---
name: wiki-ingest
description: "Read documents (markdown, text, code docs, web pages), convert them into wiki pages, and update cross-references — ingesting and integrating sources into the wiki. \"위키 수집\", \"wiki ingest\", \"위키에 추가\", \"wiki add\", \"문서 통합\", \"위키 업데이트\", \"wiki update\", \"지식 추가\", \"ingest\", \"위키에 넣어\", \"소스 추가\", \"add source\", \"문서 수집\", \"wiki import\", \"위키 임포트\" 등의 요청에 사용하세요."
argument-hint: "<file|directory|URL> [--batch] [--topic <topic>]"
---

<example>
user: "/wiki-ingest docs/architecture.md"
assistant: "docs/architecture.md를 읽고 위키에 통합하겠습니다."
</example>

<example>
user: "이 문서를 위키에 넣어줘: README.md"
assistant: "README.md를 읽고 위키 페이지로 변환하겠습니다."
</example>

<example>
user: "/wiki-ingest docs/ --batch"
assistant: "docs/ 디렉토리의 문서를 일괄 수집하겠습니다."
</example>

<example>
user: "/wiki-ingest https://example.com/guide --topic 인증"
assistant: "웹 문서를 가져와서 인증 주제로 위키에 통합하겠습니다."
</example>

<example>
user: "프로젝트 문서들 전부 위키로 통합해줘"
assistant: "프로젝트 내 문서를 탐색하고 일괄 수집하겠습니다."
</example>

<example>
user: "/wiki-ingest CHANGELOG.md"
assistant: "CHANGELOG.md를 읽고 위키에 통합하겠습니다. 기존 페이지와의 교차참조도 갱신합니다."
</example>

# Wiki Ingest

Read source documents, convert them into wiki pages, and integrate them into the existing wiki. This is the core operation of LLM Wiki.

> **Core principle**: Don't just copy the source — extract the key information and **integrate** it into the existing wiki structure. Update entity pages, refresh concept pages, and flag any new information that contradicts existing content.

Respond to the user in Korean.

## Argument interpretation

- `$ARGUMENTS` is a file path → ingest a single file
- `$ARGUMENTS` is a directory path → scan documents in the directory (recursive)
- `$ARGUMENTS` is a URL (`http://` or `https://`) → fetch a web document
- `--batch` → process all documents in the directory sequentially (default: confirm the list with the user first)
- `--topic <주제>` → focus ingestion on a specific topic
- No `$ARGUMENTS` → ask the user what to ingest

Special cases:
- "프로젝트 문서 전부", "기존 문서 통합", etc. → auto-discover project documents in Phase 1
- "API 동기화", "api-learn 동기화", "레퍼런스 동기화", etc. → auto-discover `.claude/references/` in Phase 1

## Execution Steps

### Phase 0: Verify the wiki exists

1. Check that the `.wiki/` directory exists.
   - If missing: respond "위키가 초기화되지 않았습니다. `/wiki-init`를 먼저 실행하세요." and stop.
2. Read `.wiki/schema.md` — understand the wiki structure, page types, and categories.
3. Read `.wiki/index.md` — understand the existing page list and current structure.

### Phase 1: Acquire the source

Acquire the source based on the argument type:

#### File path

1. Read the file content with `Read`.
2. Copy the original into `.wiki/sources/` (keep the filename; on conflict append a `-{N}` suffix).
3. Supported formats: `.md`, `.txt`, `.rst`, `.adoc`, `.pdf` (the Read tool supports PDF).

#### Directory path

1. Scan `{디렉토리}/**/*.{md,txt,rst,adoc}` with `Glob`.
2. Show the discovered file list to the user.
3. Without `--batch`, confirm which files to ingest.
4. Process the selected files sequentially (repeat Phase 1–4 for each file).

#### URL

1. Fetch the web document with `WebFetch`.
2. Save the fetched content to `.wiki/sources/{도메인}-{slug}.md`.
3. Record the original URL in the source file frontmatter.

#### api-learn reference sync (Pipeline)

When a `.claude/references/` path is given as an argument, or the user mentions "API 동기화", "레퍼런스 동기화", etc.:
1. `Read` `.claude/references/_index.md` to get the list of internalized libraries.
2. Scan `.claude/references/*.md` with `Glob` (excluding `_index.md`).
3. For each reference file:
   - Copy the original into `.wiki/sources/` (keep the filename).
   - **Set provenance metadata**:
     - `source_kind: api-learn`
     - `authority_path: .claude/references/{lib}.md`
     - Extract `library`, `version`, `collected` from the reference file's frontmatter and reflect them in the tags.
4. If a page for the same library already exists in the wiki and its `authority_path` matches → update mode (update the existing page).
5. **One-way sync principle**: do not sync in the wiki → api-learn direction.

> **An api-learn reference is the "authoritative document for API signatures"; a wiki page is "project-context knowledge."** When syncing, convert the reference's core API into a wiki page, and enrich it with project usage patterns and relationships via cross-references.

#### Project document auto-discovery

When the user mentions "전부", "모두", "기존 문서", etc.:
1. Scan `*.md` and `docs/**/*.md` from the project root with `Glob`.
2. Exclude files inside `.wiki/`.
3. Exclude `node_modules/`, `.git/`, `build/`, `DerivedData/`, etc.
4. If `.claude/references/` exists, include API references in the ingestion targets (mark them separately in the checklist).
5. Show the discovered document list to the user and confirm.

### Phase 2: Analyze & extract

For each source document:

1. **Extract key information**:
   - Defined entities (classes, modules, services, APIs, etc.)
   - Explained concepts (patterns, principles, architecture decisions, etc.)
   - Term definitions
   - Relationships (A uses B, A depends on B, etc.)

2. **Compare with the existing wiki**:
   - Cross-check against the existing page list in index.md.
   - `Read` the related existing pages (up to 10).
   - Check whether the new information **contradicts** existing content → when a contradiction is found, mark it in the page with a `> ⚠️ 모순` block.
   - Identify content to **add** to existing pages.

3. **Build the ingestion plan**:
   - List of pages to create (title, type, reason)
   - List of existing pages to update (what to add/modify)
   - Cross-reference additions

When the `--topic` option is present, focus on information related to that topic.

### Phase 3: Create/update wiki pages

Page authoring guide: see `references/page-format.md`.

#### Creating a new page

For each new page:
1. Decide the filename (kebab-case, max 64 chars).
2. Write the YAML frontmatter (title, type, created, updated, sources, tags).
3. Write the body:
   - Overview: 2–3 sentences of the core content, cross-referencing related pages with `[[wikilinks]]`
   - Detail: detailed information extracted from the source
   - Related items: list of related pages + relationship descriptions
   - Source: reference to the source file
4. Create the file in `.wiki/pages/`.

#### Updating an existing page

For each page to update:
1. `Read` `.wiki/pages/{page}.md`.
2. Update the `updated` date in the frontmatter.
3. Add the new source to the `sources` array in the frontmatter.
4. Integrate the new information into the body:
   - Add information while preserving the existing structure
   - If there is a contradiction, add a `> ⚠️ 모순: [설명]` block
   - Add new cross-references `[[wikilinks]]`
5. Refresh the related items section.

### Phase 4: Update index, cross-references, and log

1. **Update index.md**:
   - Add new pages to the appropriate category table.
   - Refresh the description/tags of existing pages (when changed).
   - Update `page_count`, `source_count`, and `last_updated` in the frontmatter.

2. **Check cross-reference consistency**:
   - For existing pages referenced by newly created pages, add the reverse reference too.
   - Example: if you added `[[B]]` in A, also add `[[A]]` to B's related items (when missing).

3. **Update log.md**:
   - Add an ingestion record:

   ```
   | {YYYY-MM-DD} | ingest | {소스 파일명} | {N}개 | {생성/업데이트된 페이지 요약} |
   ```

### Phase 5: Completion report

```
## 수집 완료

### 소스
- {소스 파일명} → .wiki/sources/{저장 파일명}

### 생성된 페이지 ({N}개)
- [[page-1]] — {설명}
- [[page-2]] — {설명}

### 업데이트된 페이지 ({N}개)
- [[page-3]] — {추가된 내용 요약}

### 새 교차참조
- [[page-1]] ↔ [[page-3]]
- [[page-2]] ↔ [[overview]]

### 모순 발견 ({N}건)
- [[page-3]]: {모순 설명}
```

## Batch processing behavior

When ingesting a directory or doing an "everything" ingestion:
1. First acquire all source files in Phase 1 (acquisition).
2. Run Phase 2–3 per source sequentially (each source's result feeds into the existing wiki for the next source).
3. Run Phase 4 (index/log) only once, after all sources are processed.
4. Report the overall summary in Phase 5.

## Rules

- Never modify the source originals — only copy them into `.wiki/sources/`.
- Follow the `references/page-format.md` guide when authoring pages.
- Use only the `[[wikilinks]]` format for cross-references.
- Preserve the existing structure as much as possible when updating existing pages.
- On a contradiction, don't delete — preserve both pieces of information in a `> ⚠️ 모순` block.
- Language: respond in Korean.
