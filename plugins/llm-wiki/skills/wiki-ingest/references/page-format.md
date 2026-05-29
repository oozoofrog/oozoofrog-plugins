# Wiki Page Format

Format guide that wiki pages must follow.

## YAML Frontmatter

Required on every wiki page:

```yaml
---
title: "Page Title"
type: entity | concept | summary | glossary | analysis
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
sources:
  - source-filename.md
references:
  - other-wiki-page
authority_path: ".claude/references/library-name.md"
source_kind: api-learn | manual | web
tags:
  - lowercase-tag
aliases:
  - "Korean Alias"
  - "English Alias"
---
```

### Field descriptions

| Field | Required | Description |
|-------|----------|-------------|
| title | Y | Human-readable page title |
| type | Y | Page type (see schema.md) |
| created | Y | Initial creation date |
| updated | Y | Last update date |
| sources | N | List of original source files (filenames within `sources/`). Used for pages collected via ingest |
| references | N | List of referenced wiki pages (filenames within `pages/`, without extension). Mainly used for the analysis type |
| authority_path | N | Authority source path. Pages synced from api-learn record the `.claude/references/{lib}.md` path |
| source_kind | N | Source type: `api-learn` (synced from API reference), `manual` (collected directly), `web` (collected from a URL) |
| tags | N | List of lowercase tags (used for search and classification) |
| aliases | N | List of aliases (Korean/English etc., used for search) |

### Distinguishing sources vs references vs authority_path

- **`sources`**: Points to original files in the `.wiki/sources/` directory. Used by pages collected via `wiki-ingest`.
- **`references`**: Points to other wiki pages in the `.wiki/pages/` directory. Mainly used by analysis pages created via `wiki-query --save`.
- **`authority_path`**: Authority source path of a page synced from api-learn. `wiki-lint` compares against the file at this path to determine whether the page is stale.
- **`source_kind`**: Page source type. api-learn sync (`api-learn`), user direct collection (`manual`), URL collection (`web`).
- A single page may have all of `sources`, `references`, and `authority_path`.

## Body structure

```markdown
# {title}

## Overview
Summary of the core content (2-3 sentences). [[related-page]] cross-reference.

## Detail
Body content. Divide with subheadings (###) as needed.
Use code blocks, tables, and lists.

## Related items
- [[related-page-1]] — relationship description
- [[related-page-2]] — relationship description

## Sources
- sources/source-filename.md — source description
```

### Body differences by type

**entity** (concrete target):
- Overview: what this target is and what role it plays
- Detail: implementation details, interfaces, dependencies
- Related items: other entities/concepts this target uses or is used by

**concept** (abstract concept):
- Overview: what this concept is and why it matters
- Detail: how it works, pros and cons, application patterns
- Related items: entities to which this concept applies, related concepts

**summary** (area overview):
- Overview: the big picture of this area
- Detail: main components, data flow, architecture
- Related items: the main entities and concepts of this area

**glossary** (term definitions):
- Overview omitted
- Detail: a list of per-term definitions (each term as a ### subheading)
- Related items: related concept pages

**analysis** (analysis):
- Overview: analysis purpose and conclusion summary
- Detail: analysis process, comparisons, evidence
- Related items: pages being analyzed
- frontmatter: use `references` instead of `sources` (since it references wiki pages, not original sources)

## Cross-reference rules

1. **`[[page-name]]`** — basic cross-reference (Obsidian-compatible)
   - `page-name` is the filename minus the `.md` extension
   - Example: `pages/authentication-service.md` → `[[authentication-service]]`

2. **`[[page-name|display text]]`** — alias cross-reference
   - The link target is `page-name`, while `display text` is shown on screen
   - Example: `[[auth-service|Auth Service]]`

3. **Cross-reference authoring principles**:
   - Link only on first mention (no repeated links within the same section)
   - In the overview section, always link the key related pages
   - In the related items section, explicitly list all related pages
   - Non-existent pages may also be linked (red links — detected by lint)

## File naming rules

- kebab-case: `authentication-service.md`, `dependency-injection.md`
- Max 64 characters (including extension)
- Use only lowercase English letters + digits + hyphens
- Abbreviations in lowercase: `api-gateway.md`, `jwt-validation.md`
