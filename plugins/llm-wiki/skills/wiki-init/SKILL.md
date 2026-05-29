---
name: wiki-init
description: "Initialize a project wiki — create the .wiki/ directory, set up the schema, and generate the initial index. Use for requests like \"위키 초기화\", \"wiki init\", \"위키 시작\", \"wiki setup\", \"wiki 만들기\", \"create wiki\", \"위키 생성\", \"knowledge base 초기화\", \"지식 베이스\", \"위키 세팅\"."
argument-hint: "[project path (defaults to current directory if omitted)]"
---

<example>
user: "/wiki-init"
assistant: "현재 프로젝트를 분석하여 위키를 초기화하겠습니다."
</example>

<example>
user: "위키 만들어줘"
assistant: "프로젝트를 분석한 후 .wiki/ 디렉토리를 생성하겠습니다."
</example>

<example>
user: "/wiki-init ~/projects/my-app"
assistant: "~/projects/my-app 프로젝트에 위키를 초기화하겠습니다."
</example>

<example>
user: "이 프로젝트에 knowledge base 초기화해줘"
assistant: "프로젝트 구조를 분석하고 .wiki/ 지식 베이스를 생성하겠습니다."
</example>

# Wiki Init

Initialize a project-specific LLM wiki. Scaffold the 3-Layer structure (Sources → Wiki Pages → Schema) following Karpathy's LLM Wiki pattern.

> **LLM Wiki core principle**: the wiki is a persistent artifact the LLM creates and maintains. Each time a source is added, integrate it into the existing wiki, update cross-references, and let knowledge accumulate. The human sources material and asks questions; the LLM handles all maintenance — summarizing, cross-referencing, and cleanup.

Respond to the user in Korean.

## Execution Steps

### Phase 1: Project Analysis

In the target directory (`$ARGUMENTS`, or the current working directory), detect the following:

1. **Check for an existing wiki** — check whether a `.wiki/` directory already exists.
   - If it exists, confirm with the user: "이미 위키가 있습니다. 재초기화하시겠습니까?"
   - On reinitialization, back up the existing `.wiki/` to `.wiki.backup.{timestamp}/`.

2. **Detect project type** — detect build tools and languages:
   - `package.json` → Node.js/TypeScript
   - `Package.swift` / `*.xcodeproj` → Swift/Apple
   - `Cargo.toml` → Rust
   - `pyproject.toml` / `requirements.txt` → Python
   - `go.mod` → Go
   - `build.gradle` → Kotlin/Java
   - `Makefile` / `CMakeLists.txt` → C/C++

3. **Detect existing docs** — search for collectible documents:
   - `README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`
   - `docs/`, `documentation/`, `wiki/` directories
   - `*.md` files (project root and 1-depth)
   - `CHANGELOG.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`
   - `.claude/references/` (api-learn internalized docs)

4. **Analyze directory structure** — identify major subsystems (candidate categories):
   - `src/`, `lib/`, `app/` → source code
   - `api/`, `server/` → API/server
   - `components/`, `pages/` → frontend
   - `tests/`, `__tests__/` → tests

### Phase 2: User Confirmation

Show a summary of the analysis:

```
## 프로젝트 분석 결과

**프로젝트 유형**: [감지된 언어/프레임워크]
**기존 위키**: [없음 / 있음 (백업 예정)]
**수집 가능 문서**: [발견된 문서 목록]
**API 레퍼런스**: [.claude/references/ 존재 여부, 내재화된 라이브러리 수]
**서브시스템**: [식별된 주요 디렉토리]

### 위키 설정
- **위키 이름**: [프로젝트 이름 기반 제안]
- **초기 카테고리**: [서브시스템 기반 제안]
- **자동 수집할 문서**: [체크리스트]
- **API 레퍼런스 동기화**: [.claude/references/ 발견 시 체크박스 — 내재화된 API 문서를 위키에 동기화]

이 설정으로 위키를 초기화할까요?
```

Proceed to the next step only after the user approves.

### Phase 3: .wiki/ Scaffolding

Create the following files and directories:

#### 3.1 Create directories

```
.wiki/
├── sources/
└── pages/
```

#### 3.2 Create schema.md

```markdown
---
wiki: "{위키 이름}"
project: "{프로젝트 이름}"
created: "{YYYY-MM-DD}"
version: 1
---

# Wiki Schema

## 프로젝트 컨텍스트
- **프로젝트**: {프로젝트 이름}
- **언어**: {감지된 언어}
- **프레임워크**: {감지된 프레임워크}

## 페이지 타입

| 타입 | 설명 | 예시 |
|------|------|------|
| entity | 구체적 대상 (클래스, 모듈, 서비스, 도구) | `authentication-service.md` |
| concept | 추상적 아이디어나 패턴 | `dependency-injection.md` |
| summary | 영역 전체 개요 | `overview.md` |
| glossary | 용어 정의 | `glossary-api.md` |
| analysis | 질의 결과로 생성된 분석 | `auth-flow-comparison.md` |

## 카테고리
{프로젝트 분석에서 식별된 카테고리 목록}

## 규칙
- **페이지 이름**: kebab-case, 최대 64자, `.md` 확장자
- **교차참조**: `[[page-name]]` 형식 (Obsidian 호환)
- **소스**: `.wiki/sources/`에 저장, 불변 (LLM은 읽기만)
- **Frontmatter 출처 구분**:
  - `sources`: 원본 소스 파일 참조 (`sources/` 내 파일명). ingest된 페이지에 사용
  - `references`: 위키 페이지 참조 (`pages/` 내 파일명, 확장자 제외). analysis 페이지에 주로 사용
- **태그**: 소문자, frontmatter의 tags 배열에 기록
- **별칭**: frontmatter의 aliases 배열에 기록 (한국어/영어 등)
```

#### 3.3 Create index.md

```markdown
---
page_count: 0
source_count: 0
last_updated: "{YYYY-MM-DD}"
---

# Wiki Index

## 개요 (Summary)

| 페이지 | 설명 | 태그 |
|--------|------|------|

## 엔티티 (Entity)

| 페이지 | 설명 | 태그 |
|--------|------|------|

## 개념 (Concept)

| 페이지 | 설명 | 태그 |
|--------|------|------|

## 용어 (Glossary)

| 페이지 | 설명 | 태그 |
|--------|------|------|

## 분석 (Analysis)

| 페이지 | 설명 | 태그 |
|--------|------|------|
```

#### 3.4 Create log.md

```markdown
# Wiki Log

| 날짜 | 작업 | 대상 | 영향 페이지 | 요약 |
|------|------|------|------------|------|
| {YYYY-MM-DD} | init | — | 0 | 위키 초기화 |
```

### Phase 4: Initial Page Generation

Generate the initial wiki pages based on the documents the user selected in Phase 2.

1. **Always create overview.md** — if README.md or CLAUDE.md exists, base the project overview page on it.
   - Otherwise, write a basic overview from the directory structure analysis.

2. **Collect the selected existing docs** — for each document the user checked in Phase 2:
   - Copy the original into `.wiki/sources/` (immutable layer).
   - Generate a wiki page from each source (same logic as `/wiki-ingest`).
   - During init, keep it simple: one summary page per source plus integration into overview.

3. **Sync api-learn references** (if selected in Phase 2):
   - Process `.claude/references/*.md` through `/wiki-ingest`'s api-learn pipeline.
   - Set `source_kind: api-learn` and `authority_path` metadata on each reference.
   - Add a "API 레퍼런스는 `.claude/references/_index.md` 참조" link to overview.md.

3. **Update index.md** — register the generated pages in the index.

4. **Update log.md** — append the initial collection record.

### Phase 5: CLAUDE.md Registration

Check the project root `CLAUDE.md`:

1. **If CLAUDE.md does not exist**: create a new file containing only the Wiki block.
2. **If CLAUDE.md has no Wiki block**: append the block at the end of the file.
3. **If a Wiki block already exists**: leave it untouched.

Block to add:

```markdown

## Wiki (.wiki/)

프로젝트 지식 베이스. LLM이 생성·유지합니다.
인덱스: .wiki/index.md 참조

- 프로젝트 관련 질문 → 위키에서 먼저 검색
- 위키와 학습 데이터 충돌 시 → 위키 우선
- 위키에 없는 경우 → 소스 문서 또는 웹 검색 폴백
```

### Phase 6: Completion Report

```
## 위키 초기화 완료

### 생성된 파일
- .wiki/schema.md (위키 설정)
- .wiki/index.md (마스터 인덱스)
- .wiki/log.md (운영 로그)
- .wiki/pages/overview.md (프로젝트 개요)
- .wiki/sources/ (원본 저장소)
[추가 생성된 페이지 목록]

### 다음 단계
1. `/wiki-ingest <파일|디렉토리>` — 기존 문서를 위키에 수집
2. `/wiki-query <질문>` — 위키에서 검색·답변
3. `/wiki-lint` — 위키 건강 점검
```

## Rules

- Output language: Korean.
- If a `.wiki/` directory already exists, confirm with the user before proceeding, since reinitialization overwrites it.
- Never modify source originals — they are the immutable layer.
- Use `[[wikilinks]]` for cross-references in wiki pages.
- Preserve existing CLAUDE.md content when registering (api-learn pattern).
