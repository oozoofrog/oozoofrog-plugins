---
name: wiki-ingest
description: "문서를 위키에 수집·통합합니다 — 마크다운, 텍스트, 코드 문서, 웹 문서를 읽어 위키 페이지로 변환하고 교차 참조를 업데이트합니다. \"위키 수집\", \"wiki ingest\", \"위키에 추가\", \"wiki add\", \"문서 통합\", \"위키 업데이트\", \"wiki update\", \"지식 추가\", \"ingest\", \"위키에 넣어\", \"소스 추가\", \"add source\", \"문서 수집\", \"wiki import\", \"위키 임포트\" 등의 요청에 사용하세요."
argument-hint: "<파일|디렉토리|URL> [--batch] [--topic <주제>]"
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

소스 문서를 읽어 위키 페이지로 변환하고, 기존 위키에 통합한다. LLM Wiki의 핵심 동작.

> **핵심 원칙**: 소스를 단순히 복사하는 것이 아니라, 핵심 정보를 추출하여 기존 위키 구조에 **통합**한다. 엔티티 페이지를 업데이트하고, 개념 페이지를 갱신하며, 새 정보가 기존 내용과 모순되면 이를 표시한다.

## 인자 해석

- `$ARGUMENTS`가 파일 경로 → 단일 파일 수집
- `$ARGUMENTS`가 디렉토리 경로 → 디렉토리 내 문서 탐색 (재귀)
- `$ARGUMENTS`가 URL (`http://` 또는 `https://`) → 웹 문서 가져오기
- `--batch` → 디렉토리 내 모든 문서를 순차 처리 (기본: 사용자에게 목록 확인 후 처리)
- `--topic <주제>` → 수집 시 특정 주제에 초점
- `$ARGUMENTS` 없음 → 사용자에게 수집 대상 질문

특수 케이스:
- "프로젝트 문서 전부", "기존 문서 통합" 등 → Phase 1에서 프로젝트 문서 자동 탐색

## Execution Steps

### Phase 0: 위키 존재 확인

1. `.wiki/` 디렉토리 존재 확인
   - 없으면: "위키가 초기화되지 않았습니다. `/wiki-init`를 먼저 실행하세요." 안내 후 중단
2. `.wiki/schema.md` 읽기 — 위키 구조, 페이지 타입, 카테고리 파악
3. `.wiki/index.md` 읽기 — 기존 페이지 목록, 현재 구조 파악

### Phase 1: 소스 획득

인자 유형에 따라 소스를 획득한다:

#### 파일 경로

1. `Read`로 파일 내용 읽기
2. `.wiki/sources/`에 원본 복사 (파일명 유지, 충돌 시 `-{N}` 접미사)
3. 지원 형식: `.md`, `.txt`, `.rst`, `.adoc`, `.pdf` (Read 도구가 PDF 지원)

#### 디렉토리 경로

1. `Glob`으로 `{디렉토리}/**/*.{md,txt,rst,adoc}` 탐색
2. 발견된 파일 목록을 사용자에게 표시
3. `--batch` 없으면 수집할 파일 선택 확인
4. 선택된 파일을 순차 처리 (각 파일에 대해 Phase 1~4 반복)

#### URL

1. `WebFetch`로 웹 문서 가져오기
2. 가져온 내용을 `.wiki/sources/{도메인}-{slug}.md`로 저장
3. 원본 URL을 소스 파일 frontmatter에 기록

#### 프로젝트 문서 자동 탐색

사용자가 "전부", "모두", "기존 문서" 등을 언급한 경우:
1. 프로젝트 루트에서 `Glob`으로 `*.md`, `docs/**/*.md` 탐색
2. `.wiki/` 내부 파일은 제외
3. `node_modules/`, `.git/`, `build/`, `DerivedData/` 등 제외
4. 발견된 문서 목록을 사용자에게 표시하고 확인

### Phase 2: 분석·추출

각 소스 문서에 대해:

1. **핵심 정보 추출**:
   - 정의되는 엔티티 (클래스, 모듈, 서비스, API 등)
   - 설명되는 개념 (패턴, 원칙, 아키텍처 결정 등)
   - 용어 정의
   - 관계 (A가 B를 사용, A가 B에 의존 등)

2. **기존 위키와 비교**:
   - index.md의 기존 페이지 목록과 대조
   - 관련 기존 페이지를 `Read`로 읽기 (최대 10개)
   - 새 정보가 기존 내용과 **모순**되는지 확인 → 모순 발견 시 페이지에 `> ⚠️ 모순` 블록으로 표시
   - 기존 페이지에 **추가**할 내용 식별

3. **수집 계획 수립**:
   - 새로 생성할 페이지 목록 (제목, 타입, 이유)
   - 업데이트할 기존 페이지 목록 (무엇을 추가/수정할지)
   - 교차참조 추가 계획

`--topic` 옵션이 있으면 해당 주제와 관련된 정보에 집중한다.

### Phase 3: 위키 페이지 생성/업데이트

페이지 작성 가이드: `references/page-format.md` 참조.

#### 새 페이지 생성

각 새 페이지에 대해:
1. 파일명 결정 (kebab-case, 최대 64자)
2. YAML frontmatter 작성 (title, type, created, updated, sources, tags)
3. 본문 작성:
   - 개요: 핵심 내용 2-3문장, `[[wikilinks]]`로 관련 페이지 교차참조
   - 상세: 소스에서 추출한 상세 정보
   - 관련 항목: 관련 페이지 목록 + 관계 설명
   - 출처: 소스 파일 참조
4. `.wiki/pages/`에 파일 생성

#### 기존 페이지 업데이트

각 업데이트 대상 페이지에 대해:
1. `.wiki/pages/{page}.md`를 `Read`로 읽기
2. frontmatter의 `updated` 날짜 갱신
3. frontmatter의 `sources` 배열에 새 소스 추가
4. 본문에 새 정보 통합:
   - 기존 구조를 유지하면서 정보 추가
   - 모순이 있으면 `> ⚠️ 모순: [설명]` 블록 추가
   - 새 교차참조 `[[wikilinks]]` 추가
5. 관련 항목 섹션 갱신

### Phase 4: 인덱스·교차참조·로그 갱신

1. **index.md 갱신**:
   - 새 페이지를 적절한 카테고리 테이블에 추가
   - 기존 페이지의 설명/태그 갱신 (변경된 경우)
   - frontmatter의 `page_count`, `source_count`, `last_updated` 갱신

2. **교차참조 일관성 확인**:
   - 새로 생성된 페이지에서 참조하는 기존 페이지에도 역방향 참조 추가
   - 예: A에서 `[[B]]`를 추가했으면, B의 관련 항목에도 `[[A]]` 추가 (없는 경우)

3. **log.md 갱신**:
   - 수집 기록 추가:

   ```
   | {YYYY-MM-DD} | ingest | {소스 파일명} | {N}개 | {생성/업데이트된 페이지 요약} |
   ```

### Phase 5: 완료 보고

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

## 배치 처리 시 동작

디렉토리 수집 또는 "전부" 수집 시:
1. 모든 소스 파일을 먼저 Phase 1(획득)에서 수집
2. 소스별로 Phase 2~3를 순차 실행 (이전 소스의 결과가 다음 소스의 기존 위키에 반영)
3. Phase 4(인덱스/로그)는 모든 소스 처리 후 한 번만 실행
4. Phase 5에서 전체 요약 보고

## 규칙

- 소스 원본은 **절대 수정하지 않음** — `.wiki/sources/`에 복사만
- 페이지 작성 시 `references/page-format.md` 가이드 준수
- 교차참조는 `[[wikilinks]]` 형식만 사용
- 기존 페이지 업데이트 시 기존 구조를 최대한 보존
- 모순 발견 시 삭제하지 않고 `> ⚠️ 모순` 블록으로 양쪽 정보 보존
- 언어: 한국어로 출력
