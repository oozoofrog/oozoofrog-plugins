---
name: harness
description: apple-craft 하네스 모드 — Plan→Build→Evaluate 에이전트 루프로 장기 개발 작업 자동화. Anthropic V2 간소화 패턴 기반. "처음부터", "전체", "기능 개발", "feature development", "앱 만들어", "프로젝트 생성", "리팩토링", "대규모 변경", "harness", "하네스", "처음부터 만들어", "전체 구현", "새 앱", "new app", "full implementation", "from scratch" 요청 시 활성화
argument-hint: "[feature description or project idea]"
allowed-tools:
  - Agent
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__xcode__DocumentationSearch
  - mcp__xcode__BuildProject
  - mcp__xcode__GetBuildLog
  - mcp__xcode__XcodeRefreshCodeIssuesInFile
  - mcp__xcode__XcodeListNavigatorIssues
  - mcp__xcode__ExecuteSnippet
  - mcp__xcode__RenderPreview
  - mcp__xcode__XcodeRead
  - mcp__xcode__XcodeWrite
  - mcp__xcode__XcodeUpdate
  - mcp__xcode__XcodeGrep
  - mcp__xcode__XcodeGlob
---

<example>
user: "처음부터 Liquid Glass를 적용한 설정 화면을 만들어줘"
assistant: "harness 모드로 Plan→Build→Evaluate 루프를 시작합니다. 먼저 Planner 에이전트로 스펙을 작성하겠습니다."
</example>

<example>
user: "FoundationModels로 온디바이스 AI 채팅 기능을 전체적으로 구현해줘"
assistant: "harness 모드로 FoundationModels 기반 채팅 기능의 스펙을 작성하고, 빌드/검증 루프로 구현하겠습니다."
</example>

<example>
user: "SwiftUI 앱을 처음부터 만들어줘. 3D Charts와 WebKit 웹뷰를 포함해야 해"
assistant: "harness 모드로 다중 프레임워크를 통합한 앱의 스펙을 작성합니다. Planner → Builder → Evaluator 순서로 진행합니다."
</example>

<example>
user: "이 앱의 전체 UI를 Liquid Glass 디자인으로 리팩토링해줘"
assistant: "harness 모드로 Liquid Glass 리팩토링 스펙을 작성하고, 기능별로 빌드/검증 루프를 실행합니다."
</example>

# apple-craft-harness

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) V2 간소화 패턴 기반.
3개 에이전트(Planner→Builder→Evaluator)로 장기 Apple 플랫폼 개발 작업을 자동화합니다.

## Architecture

```
사용자 요청
    │
    ▼
┌─────────────────────────────┐
│  Phase 1: PLAN              │  harness-planner 에이전트
│  제품 스펙 + features.json   │  AskUserQuestion으로 맥락 수집
│  사용자 확인 (마지막 확인점)  │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  Phase 1.5: VERIFY CRITERIA │  harness-evaluator (VERIFICATION_REVIEW 모드)
│  검증 기준 리뷰 + 보강       │  자율 진행 (사용자 확인 없음)
│  verification_steps 작성     │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  Phase 2: BUILD             │  harness-builder 에이전트
│  기능별 코드 작성 + 빌드     │  ◄── EVALUATE 피드백 (자동)
│  기능별 git 커밋             │
└────────┬────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│  Phase 3: EVALUATE          │  harness-evaluator 에이전트
│  Step 0: 도구 탐색           │  baepsae/axe → Xcode MCP → static
│  4축 다차원 검증             │  evaluation-round-{N}.md 생성
│  80% 통과 → 완료             │
│  미달 → BUILD 자동 재실행    │
└────────┬────────────────────┘
         │
    자동 루프 (최대 3 라운드)
    3회 실패 시에만 사용자 확인
```

> **설계 원칙**: 이 하네스는 Anthropic의 Harness Design 블로그에 기반합니다.
> 모든 에이전트는 시작 시 다음 문서를 참조합니다:
> `${CLAUDE_PLUGIN_ROOT}/skills/harness/references/harness-design-principles.md`

## 환경 도구 활용

apple-craft 하네스는 Claude Code 환경의 모든 스킬/MCP/도구를 적극 활용합니다.
하네스가 항상 오케스트레이션을 주도하며, 외부 도구는 하네스의 지휘 하에 동작합니다.

### 핵심 도구 (Evaluator가 최우선 확인)
- **mcp-baepsae** (app-automation 플러그인): iOS Simulator + macOS 앱 런타임 인터랙션
- **axe-simulator**: iOS Simulator 접근성 기반 자동화

### 빌드/검증 도구
- **Xcode MCP**: BuildProject, RenderPreview, RunAllTests

### 보조 도구 (있으면 활용)
- safe-design-advisor, code-review, swift-master 등 환경의 기타 스킬

### 동적 도구 탐색
각 에이전트는 시작 시 Step 0에서 사용 가능한 도구를 탐색합니다.
특정 도구에 의존하지 않으며, 환경에 따라 최적의 도구 조합을 자동 구성합니다.

## Orchestration Flow

### Phase 1: PLAN

harness-planner 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-planner: 제품 스펙 작성"
  prompt: |
    사용자 요구사항: {사용자의 원래 요청}
    프로젝트 경로: {현재 작업 디렉토리}
    플랫폼: {감지된 플랫폼 또는 사용자 지정}

    harness-spec.md와 features.json을 생성해주세요.
    apple-craft 참조 문서 라우팅 테이블을 참조하세요:
    ${CLAUDE_PLUGIN_ROOT}/skills/craft/SKILL.md
```

**Phase 1 완료 검증 (필수):**
Planner 에이전트 완료 후, 다음을 검증합니다:
1. `harness-spec.md` 파일이 존재하는지 Read로 확인
2. `features.json` 파일이 존재하고 유효한 JSON인지 Read로 확인
3. 모든 기능의 status가 "pending"인지 확인
**검증 실패 시**: 사용자에게 "Planner가 파일을 올바르게 생성하지 못했습니다"라고 보고하고 Phase 2로 진행하지 않음.

**사용자 확인**: Planner 결과를 사용자에게 보여주고 "이 스펙으로 진행할까요?"라고 확인.
사용자가 수정 요청 시 → Planner를 다시 호출하여 수정.

**Agent 실패 처리**: Planner 에이전트가 오류로 종료되면, 에러 내용을 사용자에게 보고하고 재시도 여부를 확인합니다.

### Phase 1.5: VERIFICATION REVIEW

Phase 1에서 충분한 맥락을 수집했으므로, 이 단계는 **사용자 확인 없이 자율 진행**합니다.

harness-evaluator 에이전트를 "VERIFICATION_REVIEW 모드"로 호출합니다:

```
Agent 도구 호출:
  description: "harness-evaluator: 검증 기준 리뷰"
  subagent_type: "apple-craft:harness-evaluator"
  prompt: |
    모드: VERIFICATION_REVIEW
    기능 목록: features.json
    제품 스펙: harness-spec.md

    각 기능의 verification 필드를 검토하고 보강하세요:
    1. 검증 가능성 — "이 기준으로 실제로 PASS/FAIL 판단 가능한가?"
    2. 누락된 관점 — 접근성, 에러 상태, 엣지 케이스
    3. verification_steps 배열 작성 (시뮬레이터/macOS 인터랙션 시나리오)
    기능 삭제 금지, verification/verification_steps만 수정.
```

**Phase 1.5 완료 처리:**
- 수정된 features.json의 변경 사항만 간략히 보고
- 사용자 확인 없이 Phase 2로 자동 진행

### Phase 2: BUILD

harness-builder 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-builder: 기능별 코드 작성 + 빌드"
  prompt: |
    제품 스펙: harness-spec.md
    기능 목록: features.json
    라운드: {현재 라운드 번호}/3
    {Evaluator 피드백이 있으면 포함}

    features.json에서 status=pending 또는 status=failed인 기능을
    priority 순서대로 하나씩 구현해주세요.
    각 기능 완료 시 git 커밋하세요.
```

**Phase 2 완료 검증 (필수):**
Builder 에이전트 완료 후:
1. `features.json`을 Read하여 status 변경 확인
2. pending/failed가 남아있으면 Builder가 일부만 완료한 것 → 사용자에게 보고
3. `built_unverified` 상태가 있으면 Xcode MCP 미연결 경고 표시

**Agent 실패 처리**: Builder가 중간에 실패하면, features.json의 현재 상태를 확인하여 완료된 기능과 미완료 기능을 사용자에게 보고합니다.

### Phase 3: EVALUATE

harness-evaluator 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-evaluator: QA 검증"
  prompt: |
    기능 목록: features.json
    제품 스펙: harness-spec.md
    라운드: {현재 라운드 번호}/3

    status=built인 기능을 회의적으로 검증하고,
    PASS/PARTIAL/FAIL 점수를 부여해주세요.

    evaluation-round-{N}.md 파일을 프로젝트 루트에 작성하세요.
    Step 0에서 baepsae/axe 도구를 최우선 탐지하세요.
    4축 다차원 점수를 부여하세요:
    - 기능완성(functionality), 코드품질(codeQuality),
      UI품질(designQuality), 인터랙션(interactionQuality)
    - 가중 평균(weightedAverage)으로 PASS/PARTIAL/FAIL 판정
```

**Phase 3 결과 처리:**
- 판정 PASS (80%+ 기능 통과) → **하네스 완료**
- 판정 NEED_REVISION → Evaluator의 FAIL 피드백을 Builder에게 전달 → Phase 2 재실행

### Loop Control (자율 진행)

```
라운드 1: BUILD → EVALUATE
  PASS → 완료, 사용자에게 최종 보고
  NEED_REVISION → 자동으로 라운드 2 진행 (중간 보고만)

라운드 2: BUILD (evaluation-round-1.md 참조) → EVALUATE
  PASS → 완료
  NEED_REVISION → 자동으로 라운드 3 진행

라운드 3: BUILD (evaluation-round-2.md 참조) → EVALUATE
  PASS → 완료
  NEED_REVISION → 사용자에게 상황 보고 + 선택:
    a) 계속 → 라운드 4 (최종, 추가 1회만 허용)
    b) 중단 → 현재 상태로 종료, features.json과 커밋 히스토리 보고
    c) 수동 수정 → 사용자가 직접 수정 후 Evaluate만 재실행
```

Builder 재실행 시 프롬프트에 반드시 포함:
- `evaluation-round-{N-1}.md를 참조하여 FAIL/PARTIAL 항목의 구체적 수정 지침을 확인하세요`

## features.json Schema

```json
[
  {
    "id": "F001",
    "category": "ui|data|logic|test|config",
    "description": "기능 설명",
    "verification": "텍스트 검증 기준 (기존, 유지)",
    "verification_steps": [
      {"action": "launch_app", "expect": "앱 실행 성공"},
      {"action": "tap", "target": "설정 버튼", "expect": "설정 화면 전환"},
      {"action": "screenshot", "expect": "Liquid Glass 효과 표시"}
    ],
    "status": "pending|built|built_unverified|verified|partial|failed",
    "reference": "references/<doc>.md",
    "priority": 1,
    "scores": {
      "functionality": null,
      "codeQuality": null,
      "designQuality": null,
      "interactionQuality": null,
      "weightedAverage": null
    }
  }
]
```

- `verification_steps`: Planner가 초기 생성, Evaluator가 Phase 1.5에서 보강. optional — 없으면 verification 텍스트로 폴백
- `scores`: Evaluator가 평가 시 기록. optional — 기존 PASS/PARTIAL/FAIL 상태와 호환

**상태 전이:**
```
pending → built (Builder 완료, Xcode MCP 연결)
pending → built_unverified (Builder 완료, Xcode MCP 미연결)
built → verified (Evaluator PASS)
built → partial (Evaluator PARTIAL — 소폭 수정 필요)
built → failed (Evaluator FAIL — 재구현 필요)
built_unverified → verified/partial/failed (Evaluator 검증)
partial → built (Builder 소폭 수정)
failed → built (Builder 재구현)
```

**불변 규칙:**
- 기능을 삭제하거나 기준을 완화하는 것은 **절대 금지**
- status와 priority만 업데이트 가능
- JSON 형식 유지 (마크다운이 아닌 JSON — 모델의 부적절한 편집 방지)

## Git Integration

- Builder가 각 기능 완료 시 **설명적 커밋 메시지**로 커밋
- 커밋 형식: `feat(F001): <기능 설명>`
- Evaluator 피드백 후 수정 시: `fix(F001): <수정 내용>`
- 하네스 실패 시 사용자에게 롤백 옵션 안내: "하네스 시작 전 커밋으로 되돌리려면 `git log`에서 시작 커밋을 확인하고 `git reset --hard <commit>`을 실행하세요. **주의: 이 명령은 모든 변경을 삭제합니다.**"

## Context Management

- 각 에이전트는 **독립 서브에이전트**로 실행 → 자연스러운 컨텍스트 격리
- 에이전트 간 통신은 **파일 기반** (harness-spec.md, features.json)
- 대규모 프로젝트의 경우 Builder가 자동 컴팩션 활용

## Response Templates

### 하네스 시작 알림
```markdown
## 🔨 apple-craft harness 시작

**요청**: <사용자 요구사항>
**모드**: Plan → Build → Evaluate (최대 3 라운드)

Phase 1: PLAN 시작 — Planner 에이전트가 스펙을 작성합니다...
```

### 라운드 결과
```markdown
## 📊 Evaluate Round <N>/3

### 기능별 검증 결과

| ID | 기능 | 기능완성 | 코드품질 | UI품질 | 인터랙션 | 가중평균 | 판정 |
|----|------|---------|---------|--------|---------|---------|------|
| F001 | <설명> | 8 | 9 | 7 | 8 | 8.1 | PASS |

**총점**: <PASS 수>/<전체> (임계값: 80%)
**검증 도구**: <baepsae | axe | static>
**판정**: PASS / NEED_REVISION
**상세 로그**: evaluation-round-<N>.md
```

### 완료 보고
```markdown
## ✅ apple-craft harness 완료

| 항목 | 값 |
|------|-----|
| 기능 수 | <N>개 |
| 라운드 | <N>/3 |
| PASS | <N>개 |
| 변경 파일 | <N>개 |
| 커밋 수 | <N>개 |
| 참조 문서 | <사용된 참조 목록> |

### 변경 사항 요약
<주요 변경 내용>

### Git 히스토리
<커밋 목록>
```

## Limitations

1. **Xcode MCP 권장**: Builder의 빌드 검증과 Evaluator의 품질 검증에 Xcode MCP 도구가 필요합니다. 미연결 시 코드는 `built_unverified` 상태로 마킹되며, 검증 신뢰도가 낮아집니다. 가능하면 Xcode MCP 서버를 연결하세요.

2. **비용**: 3 라운드 × 3 에이전트 = 최대 9개 에이전트 호출. 간단한 작업은 기존 `apple-craft` implement 모드가 효율적입니다.

3. **런타임 검증 도구 권장**: 런타임 인터랙션 검증을 위해 `app-automation` 플러그인(mcp-baepsae) 설치를 권장합니다. 미설치 시 정적 검증 모드로 동작합니다.

4. **프로젝트 생성 한계**: 새 Xcode 프로젝트를 생성하는 것(xcodegen, Tuist 등)은 이 하네스의 범위 밖입니다. 기존 프로젝트에 기능을 추가하는 것이 주 용도입니다.

5. **자기평가 한계**: Evaluator도 LLM이므로 완벽한 QA는 아닙니다. 최종 결과는 반드시 사람이 검토해야 합니다.

## Quick Reference

```
apple-craft-harness 실행 흐름
├─ Phase 1: PLAN (harness-planner)
│   ├─ 참조 문서 식별 + harness-design-principles.md 숙지
│   ├─ AskUserQuestion으로 맥락 수집
│   ├─ harness-spec.md 생성 (사용자 맥락 포함)
│   ├─ features.json 생성
│   └─ 사용자 확인 (마지막 확인점)
├─ Phase 1.5: VERIFICATION REVIEW (harness-evaluator)
│   ├─ verification 필드 검토/보강
│   ├─ verification_steps 작성
│   └─ 자동 진행 (사용자 확인 없음)
├─ Phase 2: BUILD (harness-builder)
│   ├─ Step 0: 환경 도구 탐색
│   ├─ features.json에서 pending/failed 기능 선택
│   ├─ 참조 문서 Read
│   ├─ Swift 코드 작성
│   ├─ 빌드 검증 (내부 3회 재시도)
│   ├─ features.json status → built
│   └─ git commit
├─ Phase 3: EVALUATE (harness-evaluator)
│   ├─ Step 0: baepsae/axe 최우선 탐지 + 보조 도구 탐색
│   ├─ 4축 다차원 검증 (기능완성/코드품질/UI품질/인터랙션)
│   ├─ evaluation-round-{N}.md 상세 로그 생성
│   ├─ PASS/PARTIAL/FAIL 점수 + 가중 평균
│   └─ 80% 통과 → 완료 / 미달 → BUILD 자동 재실행
└─ 자율 루프 (최대 3 라운드), 3회 실패 시에만 사용자 확인
```

## Walkthrough Example

실제 하네스 실행의 전체 과정을 보려면 참조 문서를 읽으세요:

```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/harness/references/walkthrough-liquid-glass-settings.md
```

이 워크스루는 "Liquid Glass 설정 화면 구현"의 Phase 1→2→3 전체 과정을 보여줍니다:
- harness-spec.md와 features.json 예시
- 5개 기능의 순차 구현 코드
- Evaluator의 다차원 검증 결과 (PASS 4개 + PARTIAL 1개)
- 1라운드에서 90% 통과한 실제 흐름
