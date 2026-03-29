# Design Spec: apple-harness Designer 2-Way Split

> design-architect + design-implementer로 분리

## Background

Codex Research (5 rounds, metric 4/4)에서 현재 단일 `harness-designer`의 병목이 Pencil 구현 자체가 아니라 **탐지·리서치·토큰 설계·문서화·상태 동기화의 책임 혼합**임을 확인했다. 최소 복잡성 원칙에 따라 `design-architect` + `design-implementer` 2-way split이 최적 조합으로 판정되었다.

### 연구 근거 요약

- RQ1: 190줄 중 순수 .pen 구현(Step 4)은 23줄(12.1%). 나머지 87.9%는 설계/문서/상태 관리.
- RQ2: 2-way split만이 Builder/Evaluator의 기존 `design-spec.md`/`.pen` 계약을 유지하면서 책임 혼합을 해소.
- RQ3: `pencil-to-code`는 Builder와 중복, `code-to-pencil`는 consumer 없음 → 기본 에이전트로 불채택.
- RQ4: Pencil 미연결 시에도 architect가 design-spec.md의 5/7 섹션을 단독 작성 가능.

## Architecture

### 에이전트 구조

```
Phase 2-A: DESIGN ARCHITECTURE (항상 실행)
  design-architect
    입력: harness-spec.md, features.json
    출력: design-spec.md (텍스트 완성, .pen 필드 pending)
    Pencil 의존: 없음

Phase 2-B: DESIGN IMPLEMENTATION (선택적, Pencil 연결 시)
  design-implementer
    입력: design-spec.md (architect 산출물), harness-spec.md, features.json
    출력: design-spec.md (pending → 완성), .pen 파일, features.json.design
    Pencil 의존: 필수
```

### 다운스트림 소비자

```
design-architect
  → design-spec.md ─┬─→ design-implementer (pending backfill)
                     ├─→ Builder (토큰 매핑 + 화면 구조 참조)
                     └─→ Evaluator (구조/토큰 대조 검증)

design-implementer (optional)
  → design-spec.md (완성) ─┬─→ Builder (.pen 화면 계층 추가 참조)
  → .pen 파일              └─→ Evaluator (시각 비교 + 디자인 토큰 검증)
  → features.json.design
```

Builder와 Evaluator는 `design-spec.md`를 이미 소비하는 계약이 확립되어 있으므로 변경 불필요.

### Phase 2 오케스트레이션 흐름

```
기존:
  Pencil 탐지 → 실패 → Phase 2 전체 스킵
             → 성공 → harness-designer 호출

변경 후:
  Phase 2-A: design-architect 호출 (항상, 사용자 확인 없이)
    → design-spec.md 산출
    → Phase 2-A 완료 검증: design-spec.md 존재 확인

  Phase 2-B: Pencil 탐지
    → 실패 → Phase 2-B 스킵 (architect 산출물 보존, Phase 3 진입)
    → 성공 → 맥락 분석 → 사용자 선택 (AskUserQuestion)
      → "디자인 구현 진행" → design-implementer 호출
      → "디자인 구현 스킵" → Phase 3 진입
```

핵심: Phase 2가 "전체 스킵"되는 상황이 없어짐. Pencil 없이도 Builder/Evaluator에게 구조적 handoff 제공.

## Components

### design-architect (신규)

```yaml
name: harness-design-architect
model: sonnet
color: purple
```

**절차:**
- Step 0: harness-design-principles.md + apple-hig-map.md 로드
- Step 1: harness-spec.md "사용자 맥락" 읽기 + features.json에서 UI 기능 식별 + HIG 조건부 조회
- Step 2: 디자인 토큰 체계 정의 (Apple HIG 기본 세트 — 색상, 타이포, 스페이싱, 라디우스)
- Step 3: design-spec.md 작성
  - 디자인 소스 (architect-only | architect + implementer)
  - 토큰 매핑 테이블 (Pencil 토큰 → SwiftUI 코드)
  - 화면별 구조 (View 계층, 핵심 컴포넌트, 사용 토큰)
  - HIG Foundation 체크리스트
  - .pen 관련 필드: `pending` 표기

**Design Philosophy 계승:**
기존 harness-designer의 "HIG Foundation + Free Expression" 2계층 철학을 그대로 계승.
- 1층 HIG Foundation (필수): Safe Area, 터치 영역, 시맨틱 색상, Dynamic Type, 접근성
- 2층 Free Expression (자유): 색상 팔레트, 카드 형태, 레이아웃, 애니메이션

### design-implementer (신규)

```yaml
name: harness-design-implementer
model: sonnet
color: violet
```

**절차:**
- Step 0: Pencil MCP 탐지 (get_editor_state) + apple-hig-map.md 로드 — 실패 시 종료
- Step 1: 기존 .pen 탐색 (Glob), 있으면 open_document → batch_get으로 구조 파악, get_variables로 토큰 읽기
- Step 2: design-spec.md의 화면 구조를 참조하여 .pen 프레임 생성/수정 (batch_design)
  - architect가 정의한 토큰을 set_variables로 Pencil에 반영
  - 화면별 구조를 .pen 프레임으로 실체화
- Step 3: 시각 검증 (get_screenshot) + design-spec.md pending 필드 backfill
  - .pen 경로, frameId 채움
  - 디자인 소스를 "architect + implementer"로 업데이트
- Step 4: features.json.design 반영 (penFile, frameId, tokens)

### harness-designer.md → 삭제

기존 파일을 완전 삭제. 2개의 새 에이전트가 완전 대체.

## design-spec.md pending 필드 규칙

architect가 작성 시 .pen 관련 필드 표기 방식:

```markdown
## 디자인 소스
- .pen 파일: pending (design-implementer 실행 시 채워짐)
- 소스: architect-only

## 화면별 구조

### Settings (features.json: F002)
- .pen Frame ID: pending
- 구조: NavigationStack > ScrollView > VStack(spacing: $spacing-lg)
- 핵심 컴포넌트:
  - 프로필 카드: HStack, $radius-card, $surface 배경
  - 설정 섹션: List > Section
- 사용 토큰: $bg, $surface, $accent, $radius-card, $font-headline
```

implementer backfill 후:

```markdown
## 디자인 소스
- .pen 파일: designs/app.pen
- 소스: architect + implementer

### Settings (features.json: F002)
- .pen Frame ID: screen-settings
- 구조: NavigationStack > ScrollView > VStack(spacing: $spacing-lg)
  (이하 동일 — architect 작성 부분은 수정하지 않음)
```

**섹션 소유권 규칙:**
- architect 소유: 토큰 매핑 테이블, 화면별 구조/컴포넌트/토큰, HIG 체크리스트 → implementer는 수정 금지
- implementer 소유: 디자인 소스, .pen Frame ID, features.json.design → architect 산출물에 추가만
- 공동: 없음 — 명확한 분리로 충돌 방지

## Files Changed

| 파일 | 액션 |
|------|------|
| `agents/harness-designer.md` | 삭제 |
| `agents/harness-design-architect.md` | 신규 생성 |
| `agents/harness-design-implementer.md` | 신규 생성 |
| `skills/apple-harness/SKILL.md` | Phase 2를 2-A/2-B로 분리, Architecture 다이어그램, Quick Reference 갱신 |
| `skills/apple-review/SKILL.md` | harness-designer 참조 확인 → 있으면 수정 |
| `skills/apple-craft/SKILL.md` | 동일 |
| `CLAUDE.md` (루트) | 플러그인 목록 에이전트 이름 갱신 |
| `plugin.json` | 1.11.0 → 1.12.0 |
| `marketplace.json` | 버전 + description 갱신 |

## Unchanged (연구 결론 준수)

- `agents/harness-builder.md` — design-spec.md 소비 방식 변경 없음
- `agents/harness-evaluator.md` — design-spec.md 소비 방식 변경 없음
- `agents/harness-planner.md` — 변경 없음
- `harness-design-principles.md` — Anthropic 원문

## Risks

1. **architect-only fallback 시 design-spec.md 품질**: .pen 시각 정보 없이 Builder가 충분히 정확한 UI를 구현할 수 있는지는 실전 검증 필요
2. **섹션 소유권 위반**: implementer가 architect 영역을 수정하면 일관성 깨짐 → 프롬프트에 명시적 금지 규칙
3. **Phase 2 분기 복잡도 증가**: 기존 1개 에이전트 호출에서 최대 2개로 증가 → 비용 약간 증가
