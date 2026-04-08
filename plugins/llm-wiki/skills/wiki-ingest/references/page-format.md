# Wiki Page Format

위키 페이지 작성 시 준수해야 하는 포맷 가이드.

## YAML Frontmatter

모든 위키 페이지에 필수:

```yaml
---
title: "페이지 제목"
type: entity | concept | summary | glossary | analysis
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
sources:
  - source-filename.md
references:
  - other-wiki-page
tags:
  - lowercase-tag
aliases:
  - "한국어 별칭"
  - "English Alias"
---
```

### 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| title | Y | 사람이 읽기 좋은 페이지 제목 |
| type | Y | 페이지 유형 (schema.md 참조) |
| created | Y | 최초 생성 날짜 |
| updated | Y | 마지막 갱신 날짜 |
| sources | N | 원본 소스 파일 목록 (`sources/` 내 파일명). ingest로 수집된 페이지에 사용 |
| references | N | 참조한 위키 페이지 목록 (`pages/` 내 파일명, 확장자 제외). analysis 타입에 주로 사용 |
| tags | N | 소문자 태그 목록 (검색·분류에 활용) |
| aliases | N | 별칭 목록 (한국어/영어 등, 검색에 활용) |

### sources vs references 구분

- **`sources`**: `.wiki/sources/` 디렉토리의 원본 파일을 가리킴. `wiki-ingest`로 수집된 페이지가 사용.
- **`references`**: `.wiki/pages/` 디렉토리의 다른 위키 페이지를 가리킴. `wiki-query --save`로 생성된 analysis 페이지가 주로 사용.
- 하나의 페이지가 둘 다 가질 수 있음 (예: 소스에서 수집했지만 다른 위키 페이지도 참조하는 경우).

## 본문 구조

```markdown
# {title}

## 개요
핵심 내용 요약 (2-3문장). [[관련-페이지]] 교차참조.

## 상세
본문 내용. 필요에 따라 소제목(###)으로 구분.
코드 블록, 표, 목록 활용.

## 관련 항목
- [[related-page-1]] — 관계 설명
- [[related-page-2]] — 관계 설명

## 출처
- sources/source-filename.md — 소스 설명
```

### 타입별 본문 차이

**entity** (구체적 대상):
- 개요: 이 대상이 무엇인지, 어떤 역할을 하는지
- 상세: 구현 세부사항, 인터페이스, 의존성
- 관련 항목: 이 대상이 사용하거나 사용되는 다른 엔티티/개념

**concept** (추상 개념):
- 개요: 이 개념이 무엇인지, 왜 중요한지
- 상세: 동작 원리, 장단점, 적용 패턴
- 관련 항목: 이 개념이 적용되는 엔티티, 관련 개념

**summary** (영역 개요):
- 개요: 이 영역의 전체 그림
- 상세: 주요 구성요소, 데이터 흐름, 아키텍처
- 관련 항목: 이 영역의 주요 엔티티와 개념

**glossary** (용어 정의):
- 개요 생략
- 상세: 용어별 정의 목록 (### 소제목으로 각 용어)
- 관련 항목: 관련 개념 페이지

**analysis** (분석):
- 개요: 분석 목적과 결론 요약
- 상세: 분석 과정, 비교, 근거
- 관련 항목: 분석 대상 페이지
- frontmatter: `sources` 대신 `references`를 사용 (원본 소스가 아닌 위키 페이지 참조이므로)

## 교차참조 규칙

1. **`[[page-name]]`** — 기본 교차참조 (Obsidian 호환)
   - `page-name`은 파일명에서 `.md` 확장자를 뺀 것
   - 예: `pages/authentication-service.md` → `[[authentication-service]]`

2. **`[[page-name|표시 텍스트]]`** — 별칭 교차참조
   - 링크 대상은 `page-name`, 화면에는 `표시 텍스트` 표시
   - 예: `[[auth-service|인증 서비스]]`

3. **교차참조 작성 원칙**:
   - 처음 언급할 때만 링크 (같은 섹션 내 반복 링크 금지)
   - 개요 섹션에서 핵심 관련 페이지를 반드시 링크
   - 관련 항목 섹션에서 모든 관련 페이지를 명시적으로 나열
   - 존재하지 않는 페이지도 링크 가능 (빨간 링크 — lint에서 탐지)

## 파일 이름 규칙

- kebab-case: `authentication-service.md`, `dependency-injection.md`
- 최대 64자 (확장자 포함)
- 영문 소문자 + 숫자 + 하이픈만 사용
- 약어는 소문자: `api-gateway.md`, `jwt-validation.md`
