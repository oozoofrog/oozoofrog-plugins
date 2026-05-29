---
name: api-learn
description: Internalize project-domain APIs — collect official docs + examples for a given library/framework, store them in the project's .claude/references/, and register them in CLAUDE.md as the Knowledge Authority. Use for requests like "API 학습", "api learn", "문서 내재화", "레퍼런스 수집", "라이브러리 학습", "API 문서 저장", "api-learn", "문서 수집", "내재화", "internalize", "learn api", "react-query 문서", "zod 학습", "라이브러리 문서화".
argument-hint: "<library-name>"
---

<example>
user: "/api-learn react-query"
assistant: "react-query 문서를 수집합니다. context7 → 웹 검색 순으로 진행하겠습니다."
</example>

<example>
user: "zod API 학습시켜줘"
assistant: "zod 라이브러리 문서를 수집하여 .claude/references/zod.md에 저장하겠습니다."
</example>

<example>
user: "/api-learn drizzle-orm"
assistant: "drizzle-orm 문서를 수집합니다. 이미 내재화된 문서가 있으므로 갱신 모드로 진행합니다."
</example>

<example>
user: "tanstack router 내재화해줘"
assistant: "tanstack-router 문서를 context7 + 웹 검색으로 수집하여 저장하겠습니다."
</example>

<example>
user: "/api-learn SwiftData"
assistant: "SwiftData는 Apple 프레임워크입니다. DocumentationSearch + apple-craft 참조 확인 → context7 → 웹 검색 순으로 수집하겠습니다."
</example>

<example>
user: "/api-learn Alamofire"
assistant: "Alamofire은 Swift 서드파티 라이브러리입니다. context7 → 웹 검색으로 수집합니다."
</example>

# api-learn

Collect and refine the official documentation for libraries/frameworks used in a project, and store it as reference documents inside the project.

Respond to the user in Korean.

## Workflow

### Phase 0 — Apple platform detection

Before collecting, determine whether the target library is a first-party Apple framework.

**Criteria for an Apple framework:**
- The library name matches an official Apple framework (SwiftUI, UIKit, AppKit, Foundation, SwiftData, MapKit, StoreKit, WebKit, WidgetKit, CoreData, CoreML, ARKit, RealityKit, HealthKit, CloudKit, GameKit, AVFoundation, CoreBluetooth, CoreLocation, AlarmKit, FoundationModels, AppIntents, etc.)
- Or the project contains `Package.swift`, `Podfile`, `*.xcodeproj`, or `*.xcworkspace`, identifying it as an Apple project

**Based on the result:**
- **Apple framework** → run Step 0 + Step 0.5 in Phase 1, then proceed with the existing Step 1~2
- **Third-party library in an Apple project** → use the existing external-doc collection strategy as-is
- **Non-Apple project** → use the existing external-doc collection strategy as-is

> **Scope policy**: This skill internalizes **external official docs only**. It does not collect or document local code usage patterns — if you need code-usage analysis, use a separate tool (e.g. `Grep`, `apple-review`).

### Phase 1 — Collection (composite strategy)

**Run sequentially for the `<library-name>` passed as the argument:**

#### Step 0: Xcode Documentation lookup (Apple frameworks only)

> Run only when Phase 0 identified an Apple framework.

1. Search official docs for `{library}` with `mcp__xcode__DocumentationSearch`
2. Collect signatures and descriptions for the main types, protocols, and methods
3. If a Getting Started / Overview doc exists, collect it too
4. If Xcode MCP is not connected, skip and proceed to Step 0.5

#### Step 0.5: apple-craft reference check (Apple frameworks only)

> Run only when Phase 0 identified an Apple framework.

1. Search for `**/apple-craft/skills/apple-craft/references/_index.md` with `Glob`
2. If found, Read `_index.md` to find reference files related to the target library
3. If a relevant reference exists, Read it and add to the collected data (source: `apple-craft reference`)
4. Also Read `common-mistakes.md` to collect anti-pattern info for the library
5. If apple-craft is not installed (no Glob result), skip silently

#### Step 1: context7 lookup

1. Resolve the library ID with `resolve-library-id`
2. Query core docs with `query-docs` (topic: per major API, tokens: max)
3. On lookup failure, skip and proceed to Step 2

#### Step 2: Web search supplement

1. Search "{library} official documentation site" with `WebSearch`
2. Identify the official docs URL, then collect these pages with `WebFetch`:
   - Getting Started / Quick Start
   - API Reference (core APIs)
   - Migration Guide (if any)
   - Examples / Recipes
3. Remove parts that duplicate content already collected from context7

#### Step 2.5: Codex parallel doc collection (optional)

If the Codex skill is available, use `/codex:rescue` to collect additional docs in parallel with Step 1~2.

1. Dispatch the `codex:codex-rescue` subagent in the background (read-only, without `--write`):
   - Task: "{library} API reference, best practices, migration guide, common patterns를 검색하고 핵심 API 시그니처를 정리하라."
2. After Step 1~2 complete, collect the Codex result with `/codex:result`
3. Merge with the existing collected data:
   - APIs already collected in Step 1 (context7) / Step 2 (web search) → remove duplicates
   - New APIs/patterns found only by Codex → add `codex-research` to sources
4. When refining in Phase 2, mark the Codex source: `sources: - codex-research: "{topic}"`

> **Guardrail**: For Apple frameworks, Xcode DocumentationSearch + apple-craft references take priority over Codex. If a Codex result conflicts with the Xcode docs, adopt the Xcode docs.
> If the Codex skill is not installed, skip this step.

### Phase 2 — Refine and store

Refine the collected raw data into a single Markdown file in the format below.

#### Output file: `{project}/.claude/references/{library}.md`

```
---
library: {library-name}
version: {detected-version}
collected: "{YYYY-MM-DD}"
sources:
  - xcode-docs  (Apple 프레임워크, DocumentationSearch 사용된 경우)
  - apple-craft-ref: "{참조파일명}"  (apple-craft 참조 사용된 경우)
  - context7  (사용된 경우)
  - web: "{공식문서URL}"  (사용된 경우)
  - codex-research: "{topic}"  (Codex 사용된 경우)
---

# {Library Display Name}

## Overview
[라이브러리 소개: 목적, 핵심 컨셉, 언제 사용하는지]

## Core APIs
### {API 1}
**시그니처:**
[함수/클래스/훅 시그니처]

**파라미터:**
[각 파라미터 설명]

**반환값:**
[반환 타입 및 설명]

**예제:**
[공식 문서 예제 코드]

### {API 2}
[동일 구조 반복]

## Common Pitfalls & Migration Notes
[주의사항, 흔한 실수, 버전별 주요 변경점]

## Source URLs
- [각 출처 URL 나열]
```

**Collection depth:** comprehensive — target 500~2000 lines per file. Include the core content of the official docs without omission.

**Version detection:** Extract the version from the project's dependency files (package.json, Podfile, requirements.txt, etc.). For first-party Apple frameworks, record the minimum deployment target or Xcode version (e.g. "iOS 18+", "Xcode 26"). If undetectable, record "unknown".

#### `_index.md` update

If `.claude/references/_index.md` does not exist, create it; if it exists, add/update the row for the library:

```
---
project: {project-name from nearest package.json/Package.swift/etc or directory name}
scan_date: "{YYYY-MM-DD}"
doc_count: {총 문서 수}
---

# API References Index

| Library | Version | Collected | Lines | Sources |
|---------|---------|-----------|-------|---------|
| {library} | {version} | {date} | {lines} | {sources} |
```

### Phase 3 — Register in CLAUDE.md

Check the project root `CLAUDE.md`:

1. **No CLAUDE.md:** create it with the API References block only
2. **CLAUDE.md exists but has no API References block:** append the block at the end
3. **CLAUDE.md exists and already has an API References block:** do nothing (skip)

Block to add:

```markdown

## API References (.claude/references/)

아래 라이브러리 작업 시 해당 참조 문서를 학습 데이터보다 우선하세요.
목록: .claude/references/_index.md 참조

- 모르는 API → 참조 문서에서 먼저 검색
- 참조 문서와 학습 데이터 충돌 시 → 참조 문서 우선
- 참조 문서에 없는 경우 → context7 또는 웹 검색 폴백
```

### Update mode

If `.claude/references/{library}.md` already exists:
- Confirm with the user: "이미 내재화된 문서가 있습니다. 갱신하시겠습니까?"
- On approval, overwrite the existing file and update the date/line count in `_index.md`
- Leave the CLAUDE.md block alone, since it already exists

### Phase 4 — Wiki sync proposal (Pipeline)

Run only when a `.wiki/` directory exists in the project:

1. Check `.wiki/index.md` for whether a wiki page exists for the library
2. If the wiki page is **missing**: propose "위키에도 동기화하시겠습니까?"
3. If the wiki page **exists**: propose "위키 페이지를 갱신하시겠습니까?"
4. On user approval, run the same flow as `/wiki-ingest .claude/references/{library}.md`
   - Automatically set the metadata `source_kind: api-learn`, `authority_path: .claude/references/{library}.md`

> **Loose Coupling principle**: api-learn works fully standalone even without `.wiki/`. Wiki sync is purely a proposal; if `.wiki/` is absent, this phase is skipped silently.

### Completion report

After collection completes, report the following:
- Storage path
- Collected sources (which of xcode-docs/apple-craft-ref/context7/web/codex-research were used)
- Total line count
- Whether registered in CLAUDE.md
- Whether synced to the wiki (when `.wiki/` exists)
