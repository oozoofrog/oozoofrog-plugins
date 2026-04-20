---
name: api-learn
description: 프로젝트 도메인 API 내재화 — 특정 라이브러리/프레임워크의 공식 문서 + 예제를 수집하여 프로젝트 내 .claude/references/에 저장하고 CLAUDE.md에 Knowledge Authority로 등록합니다. "API 학습", "api learn", "문서 내재화", "레퍼런스 수집", "라이브러리 학습", "API 문서 저장", "api-learn", "문서 수집", "내재화", "internalize", "learn api", "react-query 문서", "zod 학습", "라이브러리 문서화" 등의 요청에 사용하세요.
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

프로젝트에서 사용하는 라이브러리/프레임워크의 공식 문서를 수집·정제하여 프로젝트 내부에 참조 문서로 저장합니다.

## Workflow

### Phase 0 — Apple 플랫폼 감지

수집 시작 전, 대상 라이브러리가 Apple 자체 프레임워크인지 판별합니다.

**Apple 프레임워크 판별 기준:**
- 라이브러리 이름이 Apple 공식 프레임워크와 일치 (SwiftUI, UIKit, AppKit, Foundation, SwiftData, MapKit, StoreKit, WebKit, WidgetKit, CoreData, CoreML, ARKit, RealityKit, HealthKit, CloudKit, GameKit, AVFoundation, CoreBluetooth, CoreLocation, AlarmKit, FoundationModels, AppIntents 등)
- 또는 프로젝트에 `Package.swift`, `Podfile`, `*.xcodeproj`, `*.xcworkspace`가 존재하여 Apple 프로젝트로 판별됨

**결과에 따라:**
- **Apple 프레임워크** → Phase 1에서 Step 0 + Step 0.5를 추가 실행 후 기존 Step 1~2 진행
- **Apple 프로젝트의 서드파티 라이브러리** → 기존 외부 문서 수집 전략 그대로
- **비-Apple 프로젝트** → 기존 외부 문서 수집 전략 그대로

> **범위 정책**: 본 스킬은 **외부 공식 문서만** 내재화합니다. 프로젝트 로컬 코드의 사용 패턴은 수집/문서화하지 않습니다 — 코드 사용 분석이 필요하면 별도 도구(예: `Grep`, `apple-review`)를 사용하세요.

### Phase 1 — 수집 (복합 전략)

**인자로 받은 `<library-name>`에 대해 순차 실행:**

#### Step 0: Xcode Documentation 조회 (Apple 프레임워크만)

> Phase 0에서 Apple 프레임워크로 판별된 경우에만 실행합니다.

1. `mcp__xcode__DocumentationSearch`로 `{library}` 공식 문서 검색
2. 주요 타입, 프로토콜, 메서드의 시그니처와 설명 수집
3. Getting Started / Overview 문서가 있으면 함께 수집
4. Xcode MCP 미연결 시 건너뛰고 Step 0.5로 진행

#### Step 0.5: apple-craft 참조 문서 확인 (Apple 프레임워크만)

> Phase 0에서 Apple 프레임워크로 판별된 경우에만 실행합니다.

1. `Glob`으로 `**/apple-craft/skills/apple-craft/references/_index.md` 검색
2. 발견 시 `_index.md`를 Read하여 대상 라이브러리 관련 참조 파일 확인
3. 관련 참조 있으면 Read하여 수집 데이터에 추가 (출처: `apple-craft reference`)
4. `common-mistakes.md`도 Read하여 해당 라이브러리 안티패턴 정보 수집
5. apple-craft 미설치(Glob 결과 없음) 시 조용히 건너뛰기

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

#### Step 2.5: Codex 병렬 문서 수집 (선택적)

Codex 스킬이 사용 가능하면, Step 1~2와 병렬로 `/codex:rescue`를 활용하여 추가 문서를 수집합니다.

1. `codex:codex-rescue` 서브에이전트를 background로 디스패치 (read-only, `--write` 없이):
   - Task: "{library} API reference, best practices, migration guide, common patterns를 검색하고 핵심 API 시그니처를 정리하라."
2. Step 1~2 완료 후 `/codex:result`로 Codex 결과 수집
3. 기존 수집 데이터와 병합:
   - Step 1(context7) / Step 2(웹 검색)에서 이미 수집된 API → 중복 제거
   - Codex만 발견한 새로운 API/패턴 → sources에 `codex-research` 추가
4. Phase 2 정제 시 Codex 출처 표기: `sources: - codex-research: "{topic}"`

> **가드레일**: Apple 프레임워크는 Xcode DocumentationSearch + apple-craft references가 Codex보다 우선합니다. Codex 결과가 Xcode docs와 충돌하면 Xcode docs를 채택합니다.
> Codex 스킬 미설치 시 이 단계를 건너뜁니다.

> **로컬 코드 분석 금지**: 본 스킬은 외부 공식 문서만 수집합니다. 프로젝트 내 import/require 패턴 검색, 사용 빈도 집계, 실제 사용 예제 인용 등 **로컬 코드 사용 패턴 분석은 수행하지 않습니다**. 이는 의도적인 범위 제약이며, 코드 사용 분석이 필요하면 별도 도구를 사용하세요.

### Phase 2 — 정제·저장

수집된 원시 데이터를 아래 포맷의 단일 마크다운 파일로 정제합니다.

#### 출력 파일: `{project}/.claude/references/{library}.md`

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

**수집 깊이:** 포괄적 — 파일당 500~2000줄 목표. 공식 문서의 핵심 내용을 빠짐없이 포함.

**버전 감지:** 프로젝트 의존성 파일(package.json, Podfile, requirements.txt 등)에서 버전 추출. Apple 자체 프레임워크의 경우 최소 배포 타겟 또는 Xcode 버전을 기록 (예: "iOS 18+", "Xcode 26"). 감지 불가 시 "unknown"으로 기록.

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

### Phase 4 — 위키 동기화 제안 (Pipeline)

`.wiki/` 디렉토리가 프로젝트에 존재하는 경우에만 실행:

1. `.wiki/index.md`를 확인하여 해당 라이브러리의 위키 페이지 존재 여부 확인
2. 위키 페이지가 **없으면**: "위키에도 동기화하시겠습니까?" 제안
3. 위키 페이지가 **있으면**: "위키 페이지를 갱신하시겠습니까?" 제안
4. 사용자 승인 시 `/wiki-ingest .claude/references/{library}.md`와 동일한 흐름 실행
   - `source_kind: api-learn`, `authority_path: .claude/references/{library}.md` 메타데이터 자동 설정

> **Loose Coupling 원칙**: api-learn은 `.wiki/`가 없어도 완전히 독립 동작합니다. 위키 동기화는 순수한 제안이며, `.wiki/` 미존재 시 이 Phase는 조용히 건너뜁니다.

### 완료 보고

수집 완료 후 다음을 보고합니다:
- 저장 경로
- 수집 소스 (xcode-docs/apple-craft-ref/context7/web/codex-research 중 어떤 것이 사용됐는지)
- 총 줄 수
- CLAUDE.md 등록 여부
- 위키 동기화 여부 (`.wiki/` 존재 시)
