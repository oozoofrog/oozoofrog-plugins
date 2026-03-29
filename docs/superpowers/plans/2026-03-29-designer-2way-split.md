# Designer 2-Way Split Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `harness-designer`를 `design-architect` + `design-implementer`로 분리하여 Pencil 미연결 시에도 Builder/Evaluator에게 구조적 handoff를 제공한다.

**Architecture:** Phase 2를 2-A(항상 실행, Pencil 불필요)와 2-B(선택적, Pencil 필수)로 분리. design-spec.md는 단일 파일 2-pass — architect가 텍스트 완성, implementer가 .pen 필드 backfill.

**Tech Stack:** Markdown agent definitions, SKILL.md orchestration prompts

**Spec:** `docs/superpowers/specs/2026-03-29-designer-2way-split-design.md`

---

### Task 1: design-architect 에이전트 생성

**Files:**
- Create: `plugins/apple-craft/agents/harness-design-architect.md`

- [ ] **Step 1: harness-designer.md에서 설계 관련 Step 추출 확인**

Read `plugins/apple-craft/agents/harness-designer.md`의 다음 구간을 확인:
- Step 2 (76-98): 사용자 맥락/HIG 조사
- Step 3 (99-137): 디자인 토큰 체계 정의
- Step 5 (161-213): design-spec.md 생성 (문서화 블록)
- Design Philosophy (25-36): HIG Foundation + Free Expression

이 구간들이 design-architect의 핵심 내용.

- [ ] **Step 2: harness-design-architect.md 작성**

`plugins/apple-craft/agents/harness-design-architect.md` 파일을 생성. 내용 구조:

```markdown
---
name: harness-design-architect
description: "apple-craft harness 전용 — 사용자 맥락과 Apple HIG 기반으로 화면 구조, 토큰 체계, 컴포넌트 계층을 설계하고 design-spec.md를 작성하는 디자인 설계 에이전트. Pencil MCP 불필요. harness 모드에서만 호출됩니다."
model: sonnet
color: purple
whenToUse: |
  이 에이전트는 apple-harness 스킬의 Phase 2-A(DESIGN ARCHITECTURE)에서 호출됩니다.
  Pencil MCP 연결 여부와 무관하게 항상 실행됩니다.
  직접 호출하지 마세요. apple-harness 스킬이 오케스트레이션합니다.
---
```

본문은 다음 절차를 포함:

**Core Principle:** "Builder/Evaluator가 즉시 소비 가능한 구조적 명세를 Pencil 없이 작성한다."

**Design Philosophy 계승:** (기존 harness-designer에서 가져옴)
- 1층 HIG Foundation (필수): Safe Area, 터치 영역, 시맨틱 색상, Dynamic Type, 접근성
- 2층 Free Expression (자유): 색상 팔레트, 카드/섹션 형태, 레이아웃, 애니메이션

**입력:** 오케스트레이터가 `{HARNESS_DIR}/harness-spec.md`, `{HARNESS_DIR}/features.json`을 전달.

**Step 0: 참조 문서 로드**
- harness-design-principles.md 읽기 (`${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/harness-design-principles.md`)
- apple-hig-map.md 읽기 (`${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/apple-hig-map.md`)
- Pencil MCP 탐지는 하지 않음 (이 에이전트는 Pencil 불필요)

**Step 1: 맥락 분석 + HIG 조사** (기존 Designer Step 2 기반)
- `{HARNESS_DIR}/harness-spec.md` "사용자 맥락" 섹션 읽기
- `{HARNESS_DIR}/features.json`에서 `category: "ui"` 기능 식별
- apple-craft 참조 문서 라우팅으로 관련 참조 문서 1-3개 Read
- Apple HIG 조건부 조회 (apple-hig-map.md 전략에 따라):
  - Liquid Glass 관련 → `DocumentationSearch("Liquid Glass materials design")`
  - iOS 26 마이그레이션 → `DocumentationSearch("Adopting Liquid Glass visual refresh")`
  - 그 외 → apple-hig-map.md 빠른 참조로 충분

**Step 2: 디자인 토큰 체계 정의** (기존 Designer Step 3 기반)
- Apple HIG 기본 토큰 세트 정의 (색상, 타이포, 스페이싱, 라디우스)
- 기존 harness-designer.md의 Step 3 토큰 목록을 그대로 사용:
  - 색상: $bg, $surface, $accent, $text-primary, $text-secondary, $separator, $error, $success
  - 타이포: $font-largeTitle ~ $font-footnote (HIG Text Style 기준)
  - 스페이싱: $spacing-xs(4) ~ $spacing-xxl(32)
  - 라디우스: $radius-card(16), $radius-button(12), $radius-input(10)

**Step 3: design-spec.md 작성** (기존 Designer Step 5 문서화 블록 기반)
`{HARNESS_DIR}/design-spec.md` 생성. 템플릿:

```markdown
# Design Specification

## 디자인 소스
- .pen 파일: pending (design-implementer 실행 시 채워짐)
- 소스: architect-only
- 스타일 가이드: {HIG 기반 + 사용자 맥락에서 파악한 방향}

## 디자인 토큰 → SwiftUI 매핑

| Pencil 토큰 | 값 | SwiftUI 코드 |
|-------------|-----|-------------|
| $bg | #FFFFFF | Color(.systemBackground) |
| ... (전체 토큰 매핑) |

## 화면별 구조

### {화면명} ({HARNESS_DIR}/features.json: {F00X})
- .pen Frame ID: pending
- 구조: {View 계층 — NavigationStack > ScrollView > VStack 등}
- 핵심 컴포넌트:
  - {컴포넌트}: {구성, 토큰}
- 사용 토큰: {$bg, $surface, ...}

## HIG Foundation 체크리스트
- [ ] Safe Area 준수
- [ ] 터치 타겟 최소 44×44pt
- [ ] 시맨틱 색상 사용
- [ ] Dark Mode 대응
- [ ] Dynamic Type 지원
- [ ] accessibilityLabel 인터랙티브 요소 전체
- [ ] 네비게이션 Back 제스처 동작
- [ ] 키보드 dismiss 처리
- [ ] 대비율 4.5:1 이상 (WCAG AA)
- [ ] Liquid Glass 컨트롤/네비게이션 레이어만
```

**섹션 소유권 규칙 (프롬프트에 명시):**
- architect 소유: 토큰 매핑 테이블, 화면별 구조/컴포넌트/토큰, HIG 체크리스트
- implementer는 이 섹션들을 수정하지 않음 — 추가만 가능 (.pen Frame ID, 디자인 소스)

**출력:**
1. `{HARNESS_DIR}/design-spec.md` — 구조적 설계 문서 (텍스트 완성, .pen 필드 pending)

**주의사항:**
- 구현 세부사항(코드, 파일 구조)은 Builder의 몫
- 참조 문서 API를 학습 데이터보다 우선
- harness-spec.md "사용자 맥락" 섹션 반드시 참조
- 한국어로 작성, 코드/API명은 원문 유지

- [ ] **Step 3: Commit**

```bash
git add plugins/apple-craft/agents/harness-design-architect.md
git commit -m "feat(apple-craft): design-architect 에이전트 생성"
```

---

### Task 2: design-implementer 에이전트 생성

**Files:**
- Create: `plugins/apple-craft/agents/harness-design-implementer.md`

- [ ] **Step 1: harness-designer.md에서 Pencil 구현 관련 Step 추출 확인**

Read `plugins/apple-craft/agents/harness-designer.md`의 다음 구간:
- Step 0 (47-58): Pencil MCP 탐지
- Step 1 (59-75): 기존 .pen 탐색/재사용
- Step 4 (138-160): 화면별 .pen 구현
- Step 5 (161-165): 시각 검증 부분
- Step 6 (214-236): features.json.design 반영

- [ ] **Step 2: harness-design-implementer.md 작성**

`plugins/apple-craft/agents/harness-design-implementer.md` 파일을 생성. 내용 구조:

```markdown
---
name: harness-design-implementer
description: "apple-craft harness 전용 — design-architect의 design-spec.md를 기반으로 Pencil MCP에서 .pen 파일을 생성/수정하고, pending 필드를 backfill하는 디자인 구현 에이전트. Pencil MCP 필수. harness 모드에서만 호출됩니다."
model: sonnet
color: violet
whenToUse: |
  이 에이전트는 apple-harness 스킬의 Phase 2-B(DESIGN IMPLEMENTATION)에서 호출됩니다.
  Pencil MCP가 연결되었을 때만 호출됩니다.
  직접 호출하지 마세요. apple-harness 스킬이 오케스트레이션합니다.
---
```

본문은 다음 절차를 포함:

**Core Principle:** "architect가 정의한 구조를 Pencil .pen 파일로 실체화하고, design-spec.md의 pending 필드를 채운다."

**입력:** `{HARNESS_DIR}/design-spec.md` (architect 산출물), `{HARNESS_DIR}/harness-spec.md`, `{HARNESS_DIR}/features.json`

**Step 0: Pencil MCP 탐지** (기존 Designer Step 0 기반)
- `get_editor_state` 호출 시도
- 성공 → Step 1로 진행
- 실패 → "Pencil MCP가 연결되지 않았습니다" 보고 후 종료
- apple-hig-map.md 읽기: `${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/apple-hig-map.md`

**Step 1: 기존 디자인 탐색** (기존 Designer Step 1 기반)
- `Glob: **/*.pen` → 프로젝트 내 .pen 파일 탐색
- 기존 .pen이 있으면:
  - `open_document`로 열기
  - `batch_get`으로 최상위 프레임 구조 파악 (readDepth: 2)
  - `get_variables`로 기존 디자인 토큰 읽기
  - → Step 2로 진행 (기존 토큰 활용)
- 없으면:
  - `{HARNESS_DIR}/design-spec.md`의 토큰 매핑 읽기
  - `open_document("new")` → 새 .pen 파일 생성
  - architect가 정의한 토큰을 `set_variables`로 Pencil에 반영

**Step 2: 화면별 .pen 프레임 생성/수정** (기존 Designer Step 4 기반)
- `{HARNESS_DIR}/design-spec.md`의 "화면별 구조" 섹션 참조
- `{HARNESS_DIR}/features.json`에서 `category: "ui"` 기능별 화면 결정
- `batch_design`으로 화면 생성:
  - iPhone 프레임 기본 구조 (393x852)
  - architect의 화면 구조를 .pen 프레임으로 실체화
  - 모든 값은 $토큰 변수 참조, 하드코딩 금지
  - 최대 25 ops/call
- Apple HIG 조건부 조회 (필요 시):
  - Liquid Glass 기능이 있으면 → `DocumentationSearch("Liquid Glass materials design")`

**Step 3: 시각 검증 + design-spec.md backfill** (기존 Designer Step 5 일부)
- 각 화면 `get_screenshot(nodeId)` → 시각적 확인
- 문제 있으면 `batch_design`으로 수정
- `{HARNESS_DIR}/design-spec.md` pending 필드 backfill:
  - "디자인 소스" → `.pen 파일: {실제 경로}`, `소스: architect + implementer`
  - 각 화면의 `.pen Frame ID: pending` → `.pen Frame ID: {실제 ID}`

**Step 4: features.json.design 반영** (기존 Designer Step 6 기반)
- UI 기능에 `design` 필드 추가:
  ```json
  {
    "id": "F002",
    "design": {
      "penFile": "designs/app.pen",
      "frameId": "settings-glass-section",
      "tokens": ["$bg", "$accent", "$radius-card"]
    }
  }
  ```

**섹션 소유권 규칙 (프롬프트에 명시):**
- 수정 가능: 디자인 소스 (.pen 경로, 소스 표기), .pen Frame ID
- 수정 금지: 토큰 매핑 테이블, 화면별 구조/컴포넌트/토큰, HIG 체크리스트 (architect 소유)

**출력:**
1. `{HARNESS_DIR}/design-spec.md` — pending 필드 완성
2. `.pen` 파일
3. `{HARNESS_DIR}/features.json` — design 필드 업데이트

**주의사항:**
- 기존 .pen 파일 우선: 있으면 읽기, 없을 때만 생성
- $토큰 필수: 하드코딩된 색상/크기 절대 금지
- 사용자 질문 없음: architect가 작성한 design-spec.md와 harness-spec.md "사용자 맥락" 활용
- Pencil MCP 도구명: 환경에 따라 접두사가 다를 수 있음, 동적 탐지
- 한국어로 작성, 토큰명/코드는 원문 유지

- [ ] **Step 3: Commit**

```bash
git add plugins/apple-craft/agents/harness-design-implementer.md
git commit -m "feat(apple-craft): design-implementer 에이전트 생성"
```

---

### Task 3: harness-designer.md 삭제

**Files:**
- Delete: `plugins/apple-craft/agents/harness-designer.md`

- [ ] **Step 1: harness-designer.md 삭제**

```bash
git rm plugins/apple-craft/agents/harness-designer.md
```

- [ ] **Step 2: Commit**

```bash
git commit -m "refactor(apple-craft): harness-designer 삭제 — design-architect + design-implementer로 대체"
```

---

### Task 4: SKILL.md Phase 2 오케스트레이션 갱신

**Files:**
- Modify: `plugins/apple-craft/skills/apple-harness/SKILL.md`

이 Task에서 수정할 섹션들:
1. Architecture 다이어그램 (Phase 2 부분)
2. Phase 2: DESIGN 섹션 전체 → Phase 2-A + Phase 2-B로 분리
3. Quick Reference의 Phase 2 부분
4. Limitations 섹션의 Pencil MCP 관련 항목

- [ ] **Step 1: Architecture 다이어그램 수정**

SKILL.md의 Architecture 다이어그램에서 Phase 2 블록을 찾아 수정:

기존:
```
┌─────────────────────────────────┐
│  Phase 2: DESIGN (선택적)       │  harness-designer 에이전트
│  기존 .pen 읽기 또는 새로 생성  │  Apple HIG + 스타일 가이드
│  디자인 토큰 + {HARNESS_DIR}/design-spec.md │  Pencil 미연결→자동 스킵 / 연결→유저 선택
└────────┬────────────────────────┘
```

변경:
```
┌─────────────────────────────────┐
│  Phase 2-A: DESIGN ARCHITECTURE │  harness-design-architect 에이전트
│  (항상 실행)                    │  Apple HIG + 토큰 체계 설계
│  {HARNESS_DIR}/design-spec.md 작성 (pending 필드) │  Pencil 불필요
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Phase 2-B: DESIGN IMPLEMENTATION │  harness-design-implementer 에이전트
│  (선택적, Pencil 연결 시)       │  .pen 생성 + backfill
│  design-spec.md pending→완성    │  Pencil 미연결→자동 스킵
└────────┬────────────────────────┘
```

- [ ] **Step 2: Phase 2 섹션 전체 교체**

SKILL.md에서 `### Phase 2: DESIGN (선택적)`부터 `**Agent 실패 처리**` 끝까지를 다음으로 교체:

```markdown
### Phase 2-A: DESIGN ARCHITECTURE (항상 실행)

Phase 1에서 충분한 맥락을 수집했으므로, 이 단계는 **사용자 확인 없이 자율 진행**합니다.

harness-design-architect 에이전트를 호출합니다:

\```
Agent 도구 호출:
  description: "harness-design-architect: 디자인 설계"
  subagent_type: "apple-craft:harness-design-architect"
  prompt: |
    HARNESS_DIR: {HARNESS_DIR}
    제품 스펙: {HARNESS_DIR}/harness-spec.md
    기능 목록: {HARNESS_DIR}/features.json

    Apple HIG 기반으로 화면 구조, 토큰 체계를 설계하고
    {HARNESS_DIR}/design-spec.md를 작성하세요.
    .pen 관련 필드는 "pending"으로 표기하세요.
\```

**Phase 2-A 완료 검증 (필수):**
1. `{HARNESS_DIR}/design-spec.md` 파일이 존재하는지 Read로 확인
2. 토큰 매핑 테이블과 화면별 구조가 포함되어 있는지 확인
**검증 실패 시**: 사용자에게 보고하고 Phase 3으로 진행 (graceful degradation).

**다운스트림 소비자:**
- `design-spec.md`는 Phase 2-B(design-implementer), Phase 3(Builder), Phase 4(Evaluator)가 모두 소비
- Pencil 미연결이어도 Builder/Evaluator에게 토큰 매핑 + 화면 구조 + HIG 체크리스트를 제공

**Agent 실패 처리**: 에러 시 "디자인 설계 실패"로 보고하고 Phase 3으로 진행.

### Phase 2-B: DESIGN IMPLEMENTATION (선택적)

Pencil MCP 사용 가능 여부와 작업 맥락에 따라 실행 여부를 결정합니다.

**Step 1: Pencil 탐지** — get_editor_state 호출 시도
- 실패 → Phase 2-B 자동 스킵, Phase 3(BUILD)로 직행 (architect 산출물 보존, 사용자 알림만)

**Step 2: 맥락 기반 자동 선택 권장** — Pencil 연결 시, 작업 맥락을 분석하여 권장 옵션을 결정:

| 맥락 신호 | 권장 |
|----------|------|
| UI/화면/레이아웃/디자인 관련 키워드 포함 | Design 구현 진행 권장 |
| 기존 .pen 파일이 프로젝트에 존재 | Design 구현 진행 권장 |
| features.json에 category:"ui" 기능이 50% 이상 | Design 구현 진행 권장 |
| 로직/데이터/API/백엔드 중심 작업 | Design 구현 스킵 권장 |
| 리팩토링/성능 최적화 작업 | Design 구현 스킵 권장 |

**Step 3: 사용자 선택** — AskUserQuestion으로 확인:

\```
AskUserQuestion:
  question: "Phase 2-B 디자인 구현을 진행할까요?"
  header: "Design Implementation"
  options:
    - label: "디자인 구현 진행 (권장)"
      description: "Pencil MCP로 .pen 파일을 생성하고, design-spec.md의 pending 필드를 채웁니다."
    - label: "디자인 구현 스킵"
      description: "architect의 design-spec.md만으로 Phase 3에 진입합니다."
\```

**사용자 선택 결과:**
- "디자인 구현 진행" → harness-design-implementer 에이전트 호출
- "디자인 구현 스킵" → Phase 3(BUILD)로 직행

\```
Agent 도구 호출:
  description: "harness-design-implementer: .pen 생성 + backfill"
  subagent_type: "apple-craft:harness-design-implementer"
  prompt: |
    HARNESS_DIR: {HARNESS_DIR}
    제품 스펙: {HARNESS_DIR}/harness-spec.md
    기능 목록: {HARNESS_DIR}/features.json
    디자인 명세: {HARNESS_DIR}/design-spec.md

    design-spec.md를 참조하여 .pen 파일을 생성/수정하고,
    pending 필드를 채우세요.
\```

**Phase 2-B 완료 처리:**
- {HARNESS_DIR}/design-spec.md에서 pending 필드가 채워졌는지 확인
- {HARNESS_DIR}/features.json의 design 필드 업데이트 확인
- Phase 3(BUILD)로 자동 진행

**Agent 실패 처리**: "디자인 구현 실패, architect 산출물만으로 진행합니다"로 보고하고 Phase 3 진행 (graceful degradation).
```

- [ ] **Step 3: Quick Reference 갱신**

SKILL.md Quick Reference에서 Phase 2 부분을 찾아 수정:

기존:
```
├─ Phase 2: DESIGN (harness-designer, 선택적)
│   ├─ Pencil MCP 탐지 (미연결 → 자동 스킵)
│   ├─ 맥락 분석 → 자동 선택 권장 (UI 작업→권장, 로직 작업→스킵 권장)
│   ├─ AskUserQuestion으로 사용자 선택 확인
│   ├─ 기존 .pen 읽기 또는 새 디자인 생성
│   ├─ 디자인 토큰 정의 (Apple HIG 기반)
│   ├─ {HARNESS_DIR}/design-spec.md 생성 (토큰 매핑 + 화면 구조)
│   └─ Phase 3으로 진행
```

변경:
```
├─ Phase 2-A: DESIGN ARCHITECTURE (harness-design-architect, 항상 실행)
│   ├─ HIG/사용자 맥락 조사 + 토큰 체계 정의
│   ├─ {HARNESS_DIR}/design-spec.md 작성 (토큰 매핑 + 화면 구조 + HIG 체크리스트, .pen 필드 pending)
│   └─ 다운스트림 소비자: design-implementer, Builder, Evaluator
├─ Phase 2-B: DESIGN IMPLEMENTATION (harness-design-implementer, 선택적)
│   ├─ Pencil MCP 탐지 (미연결 → 자동 스킵, architect 산출물 보존)
│   ├─ 맥락 분석 → 자동 선택 권장 (UI 작업→권장, 로직 작업→스킵 권장)
│   ├─ AskUserQuestion으로 사용자 선택 확인
│   ├─ 기존 .pen 읽기 또는 새 디자인 생성 + design-spec.md pending backfill
│   └─ Phase 3으로 진행
```

- [ ] **Step 4: Limitations 섹션 수정**

SKILL.md Limitations에서 Pencil MCP 관련 항목(6번)을 수정:

기존:
```
6. **Pencil MCP 선택적**: 디자인 단계(Phase 2)는 Pencil MCP 연결 시에만 실행됩니다. 미연결 시 기존 코드 기반 방식으로 진행합니다. Pencil이 SwiftUI 코드를 직접 생성하지 않으므로, 디자인→코드 변환은 Builder가 수행합니다.
```

변경:
```
6. **Pencil MCP 선택적**: Phase 2-A(디자인 설계)는 Pencil 없이도 항상 실행되어 Builder/Evaluator에게 토큰 매핑과 화면 구조를 제공합니다. Phase 2-B(디자인 구현)만 Pencil MCP 연결 시 실행됩니다. Pencil이 SwiftUI 코드를 직접 생성하지 않으므로, 디자인→코드 변환은 Builder가 수행합니다.
```

- [ ] **Step 5: Commit**

```bash
git add plugins/apple-craft/skills/apple-harness/SKILL.md
git commit -m "refactor(apple-craft): Phase 2를 2-A(architect) + 2-B(implementer)로 분리"
```

---

### Task 5: apple-hig-map.md 참조 갱신

**Files:**
- Modify: `plugins/apple-craft/skills/apple-harness/references/apple-hig-map.md`

- [ ] **Step 1: harness-designer 참조를 갱신**

apple-hig-map.md 3행:
```
> harness-designer가 Apple HIG를 참조할 때 사용하는 가이드.
```
→
```
> harness-design-architect / harness-design-implementer가 Apple HIG를 참조할 때 사용하는 가이드.
```

- [ ] **Step 2: Commit**

```bash
git add plugins/apple-craft/skills/apple-harness/references/apple-hig-map.md
git commit -m "docs(apple-craft): apple-hig-map.md의 harness-designer 참조 갱신"
```

---

### Task 6: CLAUDE.md 플러그인 목록 갱신

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: 에이전트 목록 수정**

CLAUDE.md의 플러그인 목록 테이블에서 apple-craft 행:

기존:
```
| apple-craft | apple-craft, apple-harness, apple-review | harness-planner, harness-builder, harness-designer, harness-evaluator, harness-reviewer | — |
```

변경:
```
| apple-craft | apple-craft, apple-harness, apple-review | harness-planner, harness-builder, harness-design-architect, harness-design-implementer, harness-evaluator, harness-reviewer | — |
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: CLAUDE.md apple-craft 에이전트 목록 갱신"
```

---

### Task 7: 버전 범프 및 최종 커밋

**Files:**
- Modify: `plugins/apple-craft/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: plugin.json 버전 범프**

`plugins/apple-craft/.claude-plugin/plugin.json`:
- `"version": "1.11.0"` → `"version": "1.12.0"`

- [ ] **Step 2: marketplace.json 버전 범프**

`.claude-plugin/marketplace.json`:
- 루트 `"version": "1.25.0"` → `"version": "1.26.0"`
- apple-craft 항목:
  - `"version": "1.11.0"` → `"version": "1.12.0"`

- [ ] **Step 3: Commit**

```bash
git add plugins/apple-craft/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore(apple-craft): v1.12.0 — Designer 2-way split (design-architect + design-implementer)"
```

- [ ] **Step 4: Push**

```bash
git push origin main
```
