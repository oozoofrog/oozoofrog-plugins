---
name: api-learn
description: 프로젝트 도메인 API 내재화 — 특정 라이브러리/프레임워크의 공식 문서 + 예제를 수집하여 프로젝트 내 .claude/references/에 저장하고 CLAUDE.md에 Knowledge Authority로 등록합니다. "API 학습", "api learn", "문서 내재화", "레퍼런스 수집", "라이브러리 학습", "API 문서 저장", "api-learn", "문서 수집", "내재화", "internalize", "learn api", "react-query 문서", "zod 학습", "라이브러리 문서화" 등의 요청에 사용하세요.
argument-hint: "<library-name>"
---

<example>
user: "/api-learn react-query"
assistant: "react-query 문서를 수집합니다. context7 → 웹 검색 → 프로젝트 코드 분석 순으로 진행하겠습니다."
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
assistant: "tanstack-router 문서를 context7 + 웹 검색 + 프로젝트 코드 분석으로 수집하여 저장하겠습니다."
</example>

# api-learn

프로젝트에서 사용하는 라이브러리/프레임워크의 공식 문서를 수집·정제하여 프로젝트 내부에 참조 문서로 저장합니다.

## Workflow

### Phase 1 — 수집 (3단 복합 전략)

**인자로 받은 `<library-name>`에 대해 순차 실행:**

#### Step 1: context7 조회

1. `resolve-library-id`로 라이브러리 ID 해석
2. `query-docs`로 핵심 문서 조회 (topic: 주요 API별, tokens: 최대)
3. 조회 실패 시 건너뛰고 Step 2로 진행

#### Step 2: 웹 검색 보충

1. `WebSearch`로 "{library} official documentation site" 검색
2. 공식 문서 URL 식별 후 `WebFetch`로 다음 페이지 수집:
   - Getting Started / Quick Start
   - API Reference (핵심 API들)
   - Migration Guide (있는 경우)
   - Examples / Recipes
3. context7에서 이미 수집된 내용과 중복되는 부분은 제거

#### Step 3: 프로젝트 코드 분석

1. `Grep`으로 프로젝트 내 import/require 패턴 검색:
   - `import.*from.*{library}` 또는 `require.*{library}`
   - Swift: `import {library}`, Python: `import {library}` / `from {library}`
2. 사용 중인 API 목록 추출 (함수명, 클래스명, 훅 이름 등)
3. 사용 빈도 집계 — 빈도 높은 API에 더 상세한 문서 수집

### Phase 2 — 정제·저장

수집된 원시 데이터를 아래 포맷의 단일 마크다운 파일로 정제합니다.

#### 출력 파일: `{project}/.claude/references/{library}.md`

```
---
library: {library-name}
version: {detected-version}
collected: "{YYYY-MM-DD}"
sources:
  - context7  (사용된 경우)
  - web: "{공식문서URL}"  (사용된 경우)
  - code: {N} usages found  (사용된 경우)
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

## Project Usage Patterns
프로젝트에서 실제 사용 중인 패턴:

[Grep으로 발견한 실제 사용 코드를 파일 경로와 함께 인용]

## Common Pitfalls & Migration Notes
[주의사항, 흔한 실수, 버전별 주요 변경점]

## Source URLs
- [각 출처 URL 나열]
```

**수집 깊이:** 포괄적 — 파일당 500~2000줄 목표. 공식 문서의 핵심 내용을 빠짐없이 포함.

**버전 감지:** 프로젝트 의존성 파일(package.json, Podfile, requirements.txt 등)에서 버전 추출. 감지 불가 시 "unknown"으로 기록.

#### `_index.md` 업데이트

`.claude/references/_index.md`가 없으면 새로 생성, 있으면 해당 라이브러리 행을 추가/갱신합니다:

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

### Phase 3 — CLAUDE.md 등록

프로젝트 루트의 `CLAUDE.md`를 확인합니다:

1. **CLAUDE.md가 없는 경우:** 새로 생성하되 API References 블록만 포함
2. **CLAUDE.md가 있고 API References 블록이 없는 경우:** 파일 끝에 블록 추가
3. **CLAUDE.md가 있고 API References 블록이 이미 있는 경우:** 아무것도 하지 않음 (스킵)

추가할 블록:

```markdown

## API References (.claude/references/)

아래 라이브러리 작업 시 해당 참조 문서를 학습 데이터보다 우선하세요.
목록: .claude/references/_index.md 참조

- 모르는 API → 참조 문서에서 먼저 검색
- 참조 문서와 학습 데이터 충돌 시 → 참조 문서 우선
- 참조 문서에 없는 경우 → context7 또는 웹 검색 폴백
```

### 갱신 모드

이미 `.claude/references/{library}.md`가 존재하는 경우:
- 사용자에게 "이미 내재화된 문서가 있습니다. 갱신하시겠습니까?" 확인
- 승인 시 기존 파일 덮어쓰기, `_index.md` 날짜/줄수 갱신
- CLAUDE.md 블록은 이미 있으므로 건드리지 않음

### 완료 보고

수집 완료 후 다음을 보고합니다:
- 저장 경로
- 수집 소스 (context7/web/code 중 어떤 것이 사용됐는지)
- 총 줄 수
- 감지된 프로젝트 사용 패턴 수
- CLAUDE.md 등록 여부
