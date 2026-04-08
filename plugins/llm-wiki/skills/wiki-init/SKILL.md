---
name: wiki-init
description: "프로젝트 위키를 초기화합니다 — .wiki/ 디렉토리 생성, 스키마 설정, 초기 인덱스 생성. \"위키 초기화\", \"wiki init\", \"위키 시작\", \"wiki setup\", \"wiki 만들기\", \"create wiki\", \"위키 생성\", \"knowledge base 초기화\", \"지식 베이스\", \"위키 세팅\" 등의 요청에 사용하세요."
argument-hint: "[프로젝트 경로 (생략 시 현재 디렉토리)]"
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

프로젝트별 LLM 위키를 초기화한다. Karpathy의 LLM Wiki 패턴에 따라 3-Layer 구조(Sources → Wiki Pages → Schema)를 스캐폴딩한다.

> **LLM Wiki 핵심 원칙**: 위키는 LLM이 생성·유지하는 영속적 산출물이다. 소스를 추가할 때마다 기존 위키에 통합하고, 교차참조를 갱신하며, 지식이 누적된다. 사람은 소싱과 질문을 담당하고, LLM이 요약/교차참조/정리 등 모든 유지보수를 수행한다.

## Execution Steps

### Phase 1: 프로젝트 분석

대상 디렉토리(`$ARGUMENTS` 또는 현재 작업 디렉토리)에서 다음을 탐지한다:

1. **기존 위키 확인** — `.wiki/` 디렉토리가 이미 존재하는지 확인
   - 존재하면 사용자에게 "이미 위키가 있습니다. 재초기화하시겠습니까?" 확인
   - 재초기화 시 기존 `.wiki/`를 `.wiki.backup.{timestamp}/`로 백업

2. **프로젝트 유형 감지** — 빌드 도구·언어 감지:
   - `package.json` → Node.js/TypeScript
   - `Package.swift` / `*.xcodeproj` → Swift/Apple
   - `Cargo.toml` → Rust
   - `pyproject.toml` / `requirements.txt` → Python
   - `go.mod` → Go
   - `build.gradle` → Kotlin/Java
   - `Makefile` / `CMakeLists.txt` → C/C++

3. **기존 문서 탐지** — 수집 가능한 문서 탐색:
   - `README.md`, `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`
   - `docs/`, `documentation/`, `wiki/` 디렉토리
   - `*.md` 파일 (프로젝트 루트 및 1-depth)
   - `CHANGELOG.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`
   - `.claude/references/` (api-learn 내재화 문서)

4. **디렉토리 구조 분석** — 주요 서브시스템 식별 (카테고리 후보로 활용):
   - `src/`, `lib/`, `app/` → 소스 코드
   - `api/`, `server/` → API/서버
   - `components/`, `pages/` → 프론트엔드
   - `tests/`, `__tests__/` → 테스트

### Phase 2: 사용자 확인

분석 결과를 요약하여 보여준다:

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

사용자 승인 후 다음 단계를 진행한다.

### Phase 3: .wiki/ 스캐폴딩

다음 파일과 디렉토리를 생성한다:

#### 3.1 디렉토리 생성

```
.wiki/
├── sources/
└── pages/
```

#### 3.2 schema.md 생성

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

#### 3.3 index.md 생성

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

#### 3.4 log.md 생성

```markdown
# Wiki Log

| 날짜 | 작업 | 대상 | 영향 페이지 | 요약 |
|------|------|------|------------|------|
| {YYYY-MM-DD} | init | — | 0 | 위키 초기화 |
```

### Phase 4: 초기 페이지 생성

Phase 2에서 사용자가 선택한 문서를 기반으로 초기 위키 페이지를 생성한다.

1. **overview.md 필수 생성** — README.md 또는 CLAUDE.md가 있으면 이를 기반으로 프로젝트 개요 페이지 생성
   - 없으면 프로젝트 구조 분석 결과로 기본 개요 작성

2. **선택된 기존 문서 수집** — Phase 2에서 사용자가 체크한 문서를:
   - `.wiki/sources/`에 원본 복사 (불변 레이어)
   - 각 소스에서 위키 페이지 생성 (`/wiki-ingest`와 동일한 로직)
   - 단, 초기화 시에는 간소화: 소스당 1개 요약 페이지 + overview에 통합

3. **api-learn 레퍼런스 동기화** (Phase 2에서 선택된 경우):
   - `.claude/references/*.md`를 `/wiki-ingest`의 api-learn 파이프라인으로 처리
   - 각 레퍼런스에 `source_kind: api-learn`, `authority_path` 메타데이터 설정
   - overview.md에 "API 레퍼런스는 `.claude/references/_index.md` 참조" 링크 추가

3. **index.md 갱신** — 생성된 페이지를 인덱스에 등록

4. **log.md 갱신** — 초기 수집 기록 추가

### Phase 5: CLAUDE.md 등록

프로젝트 루트의 `CLAUDE.md`를 확인한다:

1. **CLAUDE.md가 없는 경우**: Wiki 블록만 포함한 새 파일 생성
2. **CLAUDE.md에 Wiki 블록이 없는 경우**: 파일 끝에 블록 추가
3. **이미 Wiki 블록이 있는 경우**: 건드리지 않음

추가할 블록:

```markdown

## Wiki (.wiki/)

프로젝트 지식 베이스. LLM이 생성·유지합니다.
인덱스: .wiki/index.md 참조

- 프로젝트 관련 질문 → 위키에서 먼저 검색
- 위키와 학습 데이터 충돌 시 → 위키 우선
- 위키에 없는 경우 → 소스 문서 또는 웹 검색 폴백
```

### Phase 6: 완료 보고

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

## 규칙

- 언어: 한국어로 출력
- `.wiki/` 디렉토리가 이미 있으면 반드시 사용자 확인 후 진행
- 소스 원본은 **절대 수정하지 않음** (불변 레이어)
- 위키 페이지는 `[[wikilinks]]` 교차참조 사용
- CLAUDE.md 등록 시 기존 내용 보존 (api-learn 패턴)
