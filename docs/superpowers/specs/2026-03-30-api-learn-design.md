# api-learn — 도메인 API 내재화 플러그인 설계

**Date:** 2026-03-30
**Status:** Approved
**Plugin:** `plugins/api-learn/`
**Skills:** `/api-learn`, `/api-scan`

---

## 목적

프로젝트에서 사용하는 특정 라이브러리/프레임워크의 공식 문서 + 코드 예제를 수집하여 프로젝트 내부 `.claude/references/`에 저장하고, 해당 프로젝트 작업 시 항상 참조하게 하는 플러그인.

## 플러그인 구조

```
plugins/api-learn/
├── .claude-plugin/plugin.json
├── skills/
│   ├── api-learn/SKILL.md      ← 특정 라이브러리 문서 수집·저장·등록
│   └── api-scan/SKILL.md       ← 프로젝트 의존성 스캔 → 미내재화 목록 제안
└── README.md
```

### 출력 위치 (대상 프로젝트 내)

```
{project}/
├── .claude/
│   └── references/
│       ├── _index.md            ← 내재화된 문서 인덱스
│       ├── react-query.md       ← 수집된 API 문서
│       ├── zod.md
│       └── ...
└── CLAUDE.md                    ← Knowledge Authority 지시 자동 추가
```

---

## 스킬 1: `/api-learn <library>`

특정 라이브러리의 문서를 수집·정제·저장·등록하는 수동 호출 스킬.

### Phase 1 — 수집 (3단 복합 전략)

```
1. context7 조회
   └─ resolve-library-id("react-query") → query-docs(topic, tokens)

2. 웹 검색 보충
   └─ 공식 문서 사이트 크롤링 (WebSearch → WebFetch)
   └─ API 레퍼런스, 가이드, 마이그레이션 문서

3. 프로젝트 코드 분석
   └─ Grep으로 import/사용 패턴 수집
   └─ 실제 사용 중인 API 목록 추출
   └─ 사용 빈도 높은 API에 가중치
```

### Phase 2 — 정제·저장

1. 수집 결과를 단일 마크다운으로 정제
   - API 시그니처 + 설명
   - 코드 예제 (공식 + 프로젝트 사용 패턴)
   - 주의사항 / 마이그레이션 노트
   - 출처 URL 명시
2. `{project}/.claude/references/{library}.md`로 저장
3. `_index.md` 업데이트 (라이브러리명, 버전, 수집일, 줄 수, 소스)

### Phase 3 — CLAUDE.md 등록

CLAUDE.md에 Knowledge Authority 블록 추가/갱신:

```markdown
## API References (.claude/references/)

아래 라이브러리 작업 시 해당 참조 문서를 학습 데이터보다 우선하세요.
목록: .claude/references/_index.md 참조

- 모르는 API → 참조 문서에서 먼저 검색
- 참조 문서와 학습 데이터 충돌 시 → 참조 문서 우선
- 참조 문서에 없는 경우 → context7 또는 웹 검색 폴백
```

- 개별 라이브러리마다 CLAUDE.md에 한 줄씩 추가하지 않음
- `_index.md`를 참조하는 단일 블록만 유지하여 CLAUDE.md 비대화 방지
- 블록이 이미 있으면 스킵, 없을 때만 추가

### 갱신 모드

이미 내재화된 라이브러리를 다시 호출하면:
- 기존 문서를 덮어쓰고 `_index.md`의 수집일 갱신
- CLAUDE.md 항목은 유지 (중복 추가 안 함)

---

## 스킬 2: `/api-scan`

프로젝트 의존성을 자동 스캔하여 미내재화 라이브러리를 식별하고 내재화를 제안하는 스킬.

### Phase 1 — 의존성 파일 감지

프로젝트 루트에서 자동 탐지:

| 파일 | 생태계 |
|------|--------|
| `package.json` | npm/yarn/pnpm |
| `requirements.txt` | pip |
| `pyproject.toml` | Poetry/PDM |
| `Podfile` | CocoaPods |
| `Package.swift` | SPM |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `build.gradle(.kts)` | Gradle |
| `pom.xml` | Maven |
| `Gemfile` | Ruby |
| `pubspec.yaml` | Flutter/Dart |

### Phase 2 — 비교·분류

1. 의존성 목록 추출
2. `.claude/references/_index.md`와 대조
3. 3가지로 분류:
   - ✅ **내재화 완료** — 버전 일치
   - ⚠️ **갱신 필요** — 내재화 버전 < 현재 버전
   - ❌ **미내재화** — 참조 문서 없음

### Phase 3 — 사용자에게 제안

```
📋 API 내재화 현황 (12개 의존성)

  ✅ 3개 완료: react-query, zod, zustand
  ⚠️ 1개 갱신 필요: axios (v0.27 → v1.6)
  ❌ 8개 미내재화: tanstack-router, drizzle-orm, ...

내재화할 라이브러리를 선택하세요:
  (1) 미내재화 전체
  (2) 갱신 필요 포함 전체
  (3) 직접 선택
```

### Phase 4 — 위임

사용자 선택에 따라 각 라이브러리마다 `/api-learn {library}`와 동일한 수집 로직 실행. 병렬 에이전트 활용 가능.

---

## 데이터 포맷

### `_index.md`

```markdown
---
project: my-app
scan_date: "2026-03-30"
doc_count: 5
---

# API References Index

| Library | Version | Collected | Lines | Sources |
|---------|---------|-----------|-------|---------|
| react-query | v5.28 | 2026-03-30 | 1420 | context7, web |
| zod | v3.23 | 2026-03-30 | 890 | context7, web, code |
| zustand | v4.5 | 2026-03-30 | 650 | web, code |
```

apple-craft `_index.md` 패턴을 따르되, `Sources` 컬럼으로 수집 전략 추적.

### `references/{library}.md`

```markdown
---
library: react-query
version: v5.28
collected: "2026-03-30"
sources:
  - context7
  - web: "https://tanstack.com/query/latest/docs"
  - code: 14 usages found
---

# React Query (TanStack Query)

## Overview
[라이브러리 소개 및 핵심 컨셉]

## Core APIs
### useQuery
[시그니처 + 파라미터 설명 + 반환값 + 코드 예제]

### useMutation
[...]

## Project Usage Patterns
프로젝트에서 실제 사용 중인 패턴 (코드 분석 결과):
[프로젝트 코드에서 추출한 실제 사용 예제]

## Common Pitfalls & Migration Notes
[주의사항, 버전별 변경점]

## Source URLs
- https://tanstack.com/query/latest/docs/...
- context7://tanstack-query/...
```

특징:
- frontmatter로 메타데이터 관리 (버전 비교, 갱신 판단에 활용)
- **Project Usage Patterns** 섹션으로 프로젝트 맞춤 예제 제공
- **Source URLs**로 출처 추적
- **수집 깊이:** 포괄적 — 공식 문서 전체 + 다수 예제 + 마이그레이션 가이드 포함 (파일당 500~2000줄 목표)

---

## 마켓플레이스 등록

`marketplace.json`에 추가:

```json
{
  "name": "api-learn",
  "description": "프로젝트 도메인 API 내재화 — 라이브러리/프레임워크 공식 문서 + 예제를 수집하여 프로젝트별 참조 문서로 저장, CLAUDE.md 자동 등록",
  "version": "1.0.0",
  "author": { "name": "oozoofrog" },
  "source": "./plugins/api-learn",
  "category": "development"
}
```

`CLAUDE.md` 플러그인 목록 테이블에 추가:

| 플러그인 | 스킬 | 에이전트 | 훅 |
|----------|------|---------|-----|
| api-learn | api-learn, api-scan | — | — |
