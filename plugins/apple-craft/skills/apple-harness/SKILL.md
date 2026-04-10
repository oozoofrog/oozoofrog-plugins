---
name: apple-harness
description: apple-craft 장기 구현 하네스 — 처음부터 새 앱/새 기능을 만들거나, 앱 전체 구조를 바꾸는 대규모 Apple 개발 작업을 Plan→Design→Build→Evaluate 루프로 진행합니다. "처음부터", "새 앱", "전체 구현", "앱 전체", "전면 리팩토링", "대규모 기능 개발", "멀티스텝 장기 작업", "harness", "하네스", "feature development", "new app", "full implementation", "from scratch" 요청 시 활성화합니다. 단일 파일 수정, 작은 리팩토링, 코드 리뷰는 apple-craft 또는 apple-review가 더 적합합니다.
argument-hint: "[feature description or project idea]"
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
user: "이 앱 전체 구조를 TCA로 전면 리팩토링해줘"
assistant: "harness 모드로 앱 전반의 구조 전환 스펙을 작성하고, 단계별 빌드/검증 루프로 진행하겠습니다."
</example>

# apple-harness

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) V2 간소화 패턴 기반.
4개 에이전트(Planner→Designer→Builder→Evaluator)로 장기 Apple 플랫폼 개발 작업을 자동화합니다.

이 스킬은 단일 파일 수정이나 작은 리팩토링이 아니라, **처음부터/전체/전면/장기** 범위의 작업을 다룹니다.
작은 구현·수정은 `apple-craft`, 리뷰·점검은 `apple-review`가 더 적합합니다.

## Architecture

```
사용자 요청
    │
    ▼
┌─────────────────────────────────┐
│  Phase 1: PLAN                  │  harness-planner 에이전트
│  제품 스펙 + {HARNESS_DIR}/features.json │  AskUserQuestion으로 맥락 수집
│  사용자 확인 (마지막 확인점)     │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Phase 1.5: VERIFY CRITERIA    │  harness-evaluator (VERIFICATION_REVIEW)
│  검증 기준 리뷰 + 보강          │  자율 진행
└────────┬────────────────────────┘
         │
         ▼
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
         │
         ▼
┌─────────────────────────────────┐
│  Phase 2.5: BUILD STYLE 선택   │  AskUserQuestion
│  autonomous | agent-led | user-led │
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Phase 3: BUILD                 │
│  ┌ autonomous: harness-builder  │  서브에이전트 자율 구현
│  ├ agent-led: 메인 대화         │  에이전트 코드 작성, 사용자 기술 선택 참여
│  └ user-led: 메인 대화          │  에이전트 가이드 생성, 사용자 코드 작성, 에이전트 리뷰
│  기능별 코드 작성 + 빌드        │  {HARNESS_DIR}/design-spec.md 참조 (있으면)
│  기능별 git 커밋                │  ◄── EVALUATE 피드백 (자동)
└────────┬────────────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Phase 4: EVALUATE              │  harness-evaluator 에이전트
│  Step 0: 도구 탐색              │  baepsae/axe + Pencil + Xcode MCP
│  4축 다차원 검증 + 디자인 비교  │  {HARNESS_DIR}/evaluation-round-{N}.md 생성
│  80% 통과 → 완료                │
│  미달 → BUILD 자동 재실행       │
└────────┬────────────────────────┘
         │
    자동 루프 (최대 3 라운드)
    3회 실패 시에만 사용자 확인
```

> **설계 원칙**: 이 하네스는 Anthropic의 Harness Design 블로그에 기반합니다.
> 모든 에이전트는 시작 시 다음 문서를 참조합니다:
> `${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/harness-design-principles.md`

## 환경 도구 활용

apple-craft 하네스는 Claude Code 환경의 모든 스킬/MCP/도구를 적극 활용합니다.
하네스가 항상 오케스트레이션을 주도하며, 외부 도구는 하네스의 지휘 하에 동작합니다.

### 런타임 검증 도구 (Evaluator가 최우선 확인)
- **mcp-baepsae** (app-automation 플러그인): iOS Simulator + macOS 앱 런타임 인터랙션
- **axe-simulator**: iOS Simulator 접근성 기반 자동화

### 빌드/검증 도구 — 폴백 체인

빌드 검증은 다음 우선순위로 사용 가능한 도구를 탐지하여 자동 결정합니다:

```
BUILD_TOOL 탐지 순서:
1. Xcode MCP (mcp__xcode__BuildProject)  — 최우선, 가장 풍부한 피드백
   ↓ 미연결
2. xcodebuild CLI + xcsift               — CLI 폴백, 구조화된 빌드 검증
   ↓ xcodebuild 실패 또는 프로젝트 탐지 불가
3. swift build + xcsift                   — SPM 프로젝트 전용 폴백
   ↓ 모두 실패
4. static                                 — 코드 검토만 (built_unverified)
```

| BUILD_TOOL | 탐지 방법 | 빌드 명령 | status |
|------------|----------|----------|--------|
| `xcode-mcp` | `mcp__xcode__BuildProject` 호출 성공 | BuildProject MCP 도구 | `built` |
| `xcodebuild` | `which xcodebuild` + `.xcworkspace`/`.xcodeproj` 존재 | `xcodebuild build ... 2>&1 \| xcsift -E` | `built` |
| `swift-build` | `Package.swift` 존재 | `swift build 2>&1 \| xcsift -E` | `built` |
| `static` | 위 모두 실패 | 없음 (코드 리뷰만) | `built_unverified` |

#### xcodebuild 핵심 옵션 (하네스에서 사용)

**프로젝트 탐지 순서:**
```bash
# 1. workspace 우선 (.xcworkspace)
xcodebuild -workspace <name>.xcworkspace -scheme <scheme> build 2>&1 | xcsift -E

# 2. project (.xcodeproj)
xcodebuild -project <name>.xcodeproj -scheme <scheme> build 2>&1 | xcsift -E

# 3. scheme 자동 탐지
xcodebuild -list [-workspace <name> | -project <name>] -json
```

**빌드 옵션:**
| 옵션 | 용도 | 예시 |
|------|------|------|
| `-workspace NAME` | 워크스페이스 지정 | `-workspace App.xcworkspace` |
| `-project NAME` | 프로젝트 지정 | `-project App.xcodeproj` |
| `-scheme NAME` | 스킴 지정 (필수) | `-scheme MyApp` |
| `-configuration NAME` | 빌드 구성 | `-configuration Debug` |
| `-destination SPEC` | 빌드 대상 디바이스 | `-destination 'platform=iOS Simulator,name=iPhone 16'` |
| `-sdk SDK` | SDK 지정 | `-sdk iphonesimulator` |
| `-quiet` | 경고/에러만 출력 | 단독 사용 시 |
| `-parallelizeTargets` | 병렬 빌드 | 빌드 속도 향상 |
| `-derivedDataPath PATH` | 빌드 산출물 경로 | 격리된 빌드 |
| `-showBuildTimingSummary` | 빌드 타이밍 리포트 | 성능 분석 |

**테스트 옵션:**
| 옵션 | 용도 | 예시 |
|------|------|------|
| `test` (build action) | 테스트 실행 | `xcodebuild test -scheme ...` |
| `-enableCodeCoverage YES` | 코드 커버리지 | `xcodebuild test -enableCodeCoverage YES` |
| `-parallel-testing-enabled YES` | 병렬 테스트 | 테스트 속도 향상 |
| `-only-testing:TARGET/CLASS/METHOD` | 특정 테스트만 | 타겟 테스트 |

#### xcsift 옵션 (빌드 출력 파싱)

xcsift는 xcodebuild/swift build 출력을 구조화된 JSON으로 변환합니다.

**필수 패턴:** `xcodebuild ... 2>&1 | xcsift [옵션]` (항상 `2>&1`로 stderr 리다이렉트)

| 옵션 | 축약 | 용도 | 하네스 활용 |
|------|------|------|-----------|
| `--exit-on-failure` | `-E` | 빌드 실패 시 exit code 반환 | **필수** — 빌드 성공/실패 판정 |
| `--warnings` | `-w` | 경고 상세 목록 표시 | Evaluator 코드품질 축 |
| `--Werror` | `-W` | 경고를 에러로 처리 | 엄격 모드 |
| `--quiet` | `-q` | 성공 시 출력 억제 | 빌드 루프 간소화 |
| `--coverage` | `-c` | 코드 커버리지 데이터 | 테스트 검증 |
| `--coverage-details` | — | 파일별 상세 커버리지 | 심층 테스트 분석 |
| `--executable` | `-e` | 생성된 실행 파일 경로 | 시뮬레이터 배포 |
| `--build-info` | — | 타겟별 빌드 단계/타이밍 | 빌드 성능 분석 |
| `--slow-threshold N` | — | 느린 테스트 탐지 (초) | 테스트 품질 |
| `--format json` | `-f json` | JSON 출력 (기본값) | LLM 파싱용 |
| `--format toon` | `-f toon` | TOON 출력 (토큰 30-60% 절약) | 컨텍스트 절약 |

**xcsift JSON 출력 구조 (빌드):**
```json
{
  "result": "success" | "failure",
  "errors": [{"file": "...", "line": 42, "message": "..."}],
  "warnings": [{"file": "...", "line": 10, "message": "..."}],
  "errorCount": 0,
  "warningCount": 2
}
```

#### swift build 핵심 옵션 (SPM 프로젝트)

| 옵션 | 용도 |
|------|------|
| `--package-path PATH` | 패키지 경로 지정 |
| `-c debug\|release` | 빌드 구성 |
| `--verbose` / `-v` | 상세 출력 |
| `--quiet` / `-q` | 에러만 출력 |

### 보조 도구 (있으면 활용)
- safe-design-advisor, code-review, swift-master 등 환경의 기타 스킬

### 디자인 도구
- **Pencil MCP**: .pen 디자인 생성/읽기/스크린샷/토큰 관리
  → Phase 2 DESIGN에서 활용, Phase 4 EVALUATE의 디자인-코드 비교에도 활용
  → 기존 .pen 파일이 있으면 읽기 우선, 없으면 새로 생성

### 동적 도구 탐색
각 에이전트는 시작 시 Step 0에서 사용 가능한 도구를 탐색합니다.
특정 도구에 의존하지 않으며, 환경에 따라 최적의 도구 조합을 자동 구성합니다.

## Orchestration Flow

### Phase 0: SESSION SETUP (하네스 시작 시 필수)

하네스 시작 시, 사용자 요청에서 **세션 이름**을 생성하여 독립 작업 디렉토리를 만듭니다.
이를 통해 여러 하네스 세션의 산출물이 충돌하지 않습니다.

**세션 이름 생성 규칙:**
1. 사용자 요청에서 핵심 키워드를 추출하여 kebab-case 슬러그 생성 (영문, 2-4 단어)
   - 예: "Liquid Glass 설정 화면" → `liquid-glass-settings`
   - 예: "FoundationModels 채팅 기능" → `foundation-models-chat`
   - 예: "전체 UI 리팩토링" → `ui-refactoring`
2. 동일 이름의 디렉토리가 이미 존재하면 `-2`, `-3` 등 접미사 추가

**HARNESS_DIR 설정:**
```
HARNESS_DIR = {HARNESS_DIR}/{session-name}
```
예: `{HARNESS_DIR}/liquid-glass-settings/`

**디렉토리 생성:**
```bash
mkdir -p {HARNESS_DIR}
```

이후 모든 Phase에서 `{HARNESS_DIR}`을 사용합니다:
- `{HARNESS_DIR}/harness-spec.md`
- `{HARNESS_DIR}/features.json`
- `{HARNESS_DIR}/design-spec.md`
- `{HARNESS_DIR}/evaluation-round-{N}.md`
- `{HARNESS_DIR}/session.json` — 세션 메타데이터 (build_style, 현재 라운드 등)

모든 에이전트 호출 시 프롬프트에 `HARNESS_DIR: {HARNESS_DIR}` 경로를 반드시 전달합니다.

**재진입 감지 (새 대화에서 하네스 호출 시):**

**Step 1: 산출물 존재 확인**
HARNESS_DIR에서 다음 파일을 확인합니다:
- `session.json` 존재 → Step 2(session 기반 재진입)로 진행
- `session.json` 없음 + `features.json` 존재 → **features.json의 status를 분석하여 분류**:

  ```
  모든 기능이 pending인가?
  ├─ 예 → Phase 1~2 중단 (Plan/Design 완료, Build 시작 전).
  │   사용자에게 "이전 Plan/Design 산출물이 있습니다. 이어서 진행할까요?"
  │   확인 후 Phase 2.5(BUILD STYLE 선택)부터 재개.
  │
  └─ 아니오 (built/verified/failed/partial 존재):
      모든 기능이 verified인가?
      ├─ 예 → 성공 완료 세션 (session.json 유실).
      │   "이전 하네스가 성공적으로 완료된 상태입니다" 안내.
      │   완료 보고 또는 새 하네스 시작 선택.
      │
      └─ 아니오 → 중간 세션 중단 (session.json 유실).
          사용자에게 features.json 현재 상태를 요약하고,
          build_style을 AskUserQuestion으로 선택한 뒤
          Phase 3에서 pending/failed/partial 기능부터 재개.
  ```

- `session.json` 없음 + `harness-spec.md`만 존재 (features.json 없음) → Phase 1 Planner 중간 중단. harness-spec.md를 확인하고 Phase 1부터 재개.
- 아무 파일도 없음 → 새 세션 시작 (Phase 0)

**Step 2: session.json 기반 재진입**
1. `session.json`을 Read하여 `build_style`, `current_round`, `current_feature_id`, `batch_features`, `phase`를 복구
2. `features.json`을 Read하여 각 기능의 현재 status를 확인
3. **session.json과 features.json을 cross-validation**하여 실제 재개 지점을 결정:

```
# 0. 공통 보정: evaluate 단계에서 current_feature_id는 항상 null이어야 함
if phase == "evaluate" && current_feature_id != null:
    current_feature_id를 null로 보정

# 1. current_round 보정: evaluation 보고서와 동기화
if evaluation-round-{current_round}.md가 이미 존재:
    current_round를 current_round+1로 보정
    (이전 라운드 evaluate는 완료되었지만 다음 build 전이 전에 중단된 것)

# 2. current_round 상한 검증
if current_round > 4:
    → 하네스 최대 라운드 초과. 현재 상태로 강제 종료, 결과 보고.

# 3. phase별 재개 지점 결정
if phase == "complete":
    → 하네스 이미 완료. "이전 세션이 완료되었습니다" 안내 후 완료 보고 재표시 또는 새 하네스 시작.

if phase == "evaluate":
    features에 built 상태가 존재하는가?
    ├─ 예 → Phase 4(EVALUATE)에서 재개 (아직 평가되지 않은 built 기능이 있음)
    └─ 아니오 (모두 verified/failed/partial):
        failed/partial이 존재하는가?
        ├─ 예 → phase를 "build"로 보정, build_style에 따라 Phase 3-A/B/C에서 재개
        │       (NEED_REVISION 후 중단된 것. 아래 `if phase == "build"` 분기로 폴스루)
        └─ 아니오 (모두 verified) → phase를 "complete"로 보정, 완료 보고

if phase == "build":
    build_style 확인:
    ├─ "autonomous" → Phase 3-A 재개:
    │   current_feature_id는 항상 null (Builder 서브에이전트 관리)
    │   → 다음 pending/failed/partial 기능부터 Builder 재호출
    │
    ├─ "collaborative" → Phase 3-B 재개:
    │   current_feature_id가 non-null인가?
    │   ├─ 예 → 해당 기능의 features.json status 확인:
    │   │   ├─ pending → git log --oneline --grep="feat(FID):" 로 커밋 존재 확인:
    │   │   │   ├─ 커밋 있음 → status를 built로 보정, current_feature_id → null
    │   │   │   └─ 커밋 없음 → 해당 기능부터 재시작 (구현 중 중단)
    │   │   ├─ failed/partial → 해당 기능의 수정부터 재개.
    │   │   │   evaluation-round-{N-1}.md 존재 시 피드백 포함, 빌드 에러 이력도 함께 참조.
    │   │   └─ built → current_feature_id를 null로 보정, 다음 pending/failed/partial 기능으로 이동
    │   └─ 아니오 → 다음 pending/failed/partial 기능부터 재개
    │
    └─ "user-led" → Phase 3-C 재개:
        batch_features가 non-null인가?
        ├─ 예 → 배치 모드 재진입
        │   current_feature_id가 non-null인가?
        │   ├─ 예 → 해당 기능의 features.json status 확인:
        │   │   ├─ built → 커밋 완료 후 중단. current_feature_id → null로 보정
        │   │   ├─ pending → git log --oneline --grep="feat(FID):" 로 커밋 존재 확인:
        │   │   │   ├─ 커밋 있음 → status를 built로 보정, current_feature_id → null
        │   │   │   └─ 커밋 없음 → 실제 미커밋. 해당 기능은 재커밋 필요로 표시
        │   │   └─ failed/partial → 수정 재처리 필요 표시 (eval 피드백 + 빌드 에러 이력 모두 참조)
        │   └─ 아니오 → 배치 대기/리뷰 중 중단 (정상)
        │   batch_features의 각 FID에 대해 features.json status를 확인
        │   "이전에 배치 작업 중이었습니다: [FID 목록]
        │    [완료: F002, F003] [미완료: F004]
        │    작업을 계속하시겠습니까, 아니면 리뷰를 진행할까요?"
        └─ 아니오 →
            current_feature_id가 non-null인가?
            ├─ 예 → 해당 기능의 features.json status 확인:
            │   ├─ pending → git log --oneline --grep="feat(FID):" 로 커밋 존재 확인:
            │   │   ├─ 커밋 있음 → status를 built로 보정, current_feature_id → null
            │   │   └─ 커밋 없음 → "이전에 [FID] 구현 가이드를 드렸습니다.
            │   │                    작업 중이셨나요? 리뷰를 진행할까요?"
            │   ├─ failed/partial → 수정 가이드 재생성.
            │   │   evaluation-round-{N-1}.md 존재 시 Evaluator 피드백 포함,
            │   │   빌드 에러 이력도 함께 참조 (두 원인이 동시 존재 가능).
            │   │   "이전에 [FID] 작업 중이었습니다. (status: [FAIL/PARTIAL])
            │   │    수정을 계속하시겠습니까?"
            │   └─ built → current_feature_id를 null로 보정, 다음 pending/failed/partial 기능으로 이동
            └─ 아니오 → 다음 pending/failed/partial 기능을 확인하여 status별 가이드 생성:
                ├─ pending → 구현 가이드 생성 (초회 구현)
                └─ failed/partial → 수정 가이드 생성.
                    evaluation-round-{N-1}.md 존재 시 Evaluator 피드백 포함,
                    빌드 에러 이력도 함께 참조 (두 원인이 동시 존재 가능).
```

4. 사용자에게 현재 상태를 요약하고, 재개할 Phase를 안내
5. 사용자가 다른 Phase부터 시작하고 싶으면 허용

### Phase 1: PLAN

harness-planner 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-planner: 제품 스펙 작성"
  prompt: |
    사용자 요구사항: {사용자의 원래 요청}
    프로젝트 경로: {현재 작업 디렉토리}
    플랫폼: {감지된 플랫폼 또는 사용자 지정}
    HARNESS_DIR: {HARNESS_DIR}

    {HARNESS_DIR}/harness-spec.md와 {HARNESS_DIR}/features.json을 생성해주세요.
    apple-craft 참조 문서 라우팅 테이블을 참조하세요:
    ${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/SKILL.md
```

**Phase 1 완료 검증 (필수):**
Planner 에이전트 완료 후, 다음을 검증합니다:
1. `{HARNESS_DIR}/harness-spec.md` 파일이 존재하는지 Read로 확인
2. `{HARNESS_DIR}/features.json` 파일이 존재하고 유효한 JSON인지 Read로 확인
3. 모든 기능의 status가 "pending"인지 확인
**검증 실패 시**: 사용자에게 "Planner가 파일을 올바르게 생성하지 못했습니다"라고 보고하고 Phase 2로 진행하지 않음.

**문서 직접 오픈 (검증 통과 후):**
검증을 통과하면, 생성된 문서를 사용자의 에디터에서 직접 엽니다:
```bash
open "{HARNESS_DIR}/harness-spec.md"
open "{HARNESS_DIR}/features.json"
```
사용자가 에디터에서 전체 스펙을 상세 확인할 수 있도록 합니다.

**사용자 확인**: "문서를 열었습니다. 스펙과 기능 목록을 확인하시고, 수정 사항이 있으면 알려주세요. 이대로 진행할까요?"라고 확인.
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
    HARNESS_DIR: {HARNESS_DIR}
    기능 목록: {HARNESS_DIR}/features.json
    제품 스펙: {HARNESS_DIR}/harness-spec.md

    각 기능의 verification 필드를 검토하고 보강하세요:
    1. 검증 가능성 — "이 기준으로 실제로 PASS/FAIL 판단 가능한가?"
    2. 누락된 관점 — 접근성, 에러 상태, 엣지 케이스
    3. verification_steps 배열 작성 (시뮬레이터/macOS 인터랙션 시나리오)
    기능 삭제 금지, verification/verification_steps만 수정.
```

**Phase 1.5 완료 처리:**
- 수정된 {HARNESS_DIR}/features.json의 변경 사항만 간략히 보고
- 사용자 확인 없이 Phase 2로 자동 진행

### Phase 2-A: DESIGN ARCHITECTURE (항상 실행)

Phase 1에서 충분한 맥락을 수집했으므로, 이 단계는 **사용자 확인 없이 자율 진행**합니다.

harness-design-architect 에이전트를 호출합니다:

```
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
```

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

```
AskUserQuestion:
  question: "Phase 2-B 디자인 구현을 진행할까요?"
  header: "Design Implementation"
  options:
    - label: "디자인 구현 진행 (권장)"
      description: "Pencil MCP로 .pen 파일을 생성하고, design-spec.md의 pending 필드를 채웁니다."
    - label: "디자인 구현 스킵"
      description: "architect의 design-spec.md만으로 Phase 3에 진입합니다."
```

**사용자 선택 결과:**
- "디자인 구현 진행" → harness-design-implementer 에이전트 호출
- "디자인 구현 스킵" → Phase 3(BUILD)로 직행

```
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
```

**Phase 2-B 완료 처리:**
- {HARNESS_DIR}/design-spec.md에서 pending 필드가 채워졌는지 확인
- {HARNESS_DIR}/features.json의 design 필드 업데이트 확인
- Phase 3(BUILD)로 자동 진행

**Agent 실패 처리**: "디자인 구현 실패, architect 산출물만으로 진행합니다"로 보고하고 Phase 3 진행 (graceful degradation).

### Phase 2.5: BUILD STYLE 선택

Phase 2 완료 후, Phase 3 진입 전에 빌드 스타일을 선택합니다:

```
AskUserQuestion:
  question: "Build 스타일을 선택해주세요"
  header: "Phase 3"
  options:
    - label: "자율 모드 (Autonomous)"
      description: "Builder 에이전트가 모든 기능을 자율적으로 구현합니다. 빠르지만 세부 결정에 참여할 수 없습니다."
    - label: "협업 모드 — 에이전트 주도 (Agent-led Collaborative)"
      description: "에이전트가 코드를 작성하고, 기술적 선택에 사용자가 참여합니다. 느리지만 세부 설계를 직접 결정합니다."
    - label: "협업 모드 — 사용자 주도 (User-led Collaborative)"
      description: "에이전트가 기능별 구현 가이드를 작성하고, 사용자가 직접 코드를 작성합니다. 에이전트는 리뷰어 역할."
```

선택 결과를 `{HARNESS_DIR}/session.json`에 기록합니다:

```json
{
  "build_style": "autonomous" | "collaborative" | "user-led",
  "current_round": 1,
  "current_feature_id": null,
  "batch_features": null,
  "phase": "build"
}
```

이 파일은 세션 중단/재진입 시 상태 복구에 사용됩니다.

### Phase 3: BUILD

`build_style`에 따라 분기합니다: `"autonomous"` → Phase 3-A, `"collaborative"` → Phase 3-B, `"user-led"` → Phase 3-C.

#### Phase 3-A: Autonomous Build (build_style = "autonomous")

기존과 동일하게 harness-builder 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-builder: 기능별 코드 작성 + 빌드"
  prompt: |
    HARNESS_DIR: {HARNESS_DIR}
    제품 스펙: {HARNESS_DIR}/harness-spec.md
    기능 목록: {HARNESS_DIR}/features.json
    라운드: {현재 라운드 번호}/3
    {Evaluator 피드백이 있으면 포함}

    {HARNESS_DIR}/features.json에서 status=pending, status=failed, 또는 status=partial인 기능을
    priority 순서대로 하나씩 구현해주세요.
    각 기능 완료 시 git 커밋하세요.
    {HARNESS_DIR}/design-spec.md가 존재하면 디자인 명세를 참조하여 코드를 작성하세요.
    .pen 파일의 화면 구조와 디자인 토큰을 SwiftUI 코드에 반영하세요.
```

**Phase 3-A 완료 검증 (필수):**
Builder 에이전트 완료 후:
1. `{HARNESS_DIR}/features.json`을 Read하여 status 변경 확인
2. pending/failed/partial가 남아있으면 Builder가 일부만 완료한 것 → 사용자에게 보고
3. `built_unverified` 상태가 있으면 Xcode MCP 미연결 경고 표시

**Agent 실패 처리**: Builder가 중간에 실패하면, {HARNESS_DIR}/features.json의 현재 상태를 확인하여 완료된 기능과 미완료 기능을 사용자에게 보고합니다.

#### Phase 3-B: Collaborative Build (build_style = "collaborative")

서브에이전트를 호출하지 않고, **메인 대화에서 직접 실행**합니다.
사용자와 기능별로 대화하며 구현합니다.

**Step 0: 빌드 도구 탐지**
Autonomous Build의 Builder와 동일한 폴백 체인으로 빌드 도구를 탐지합니다:
```
BUILD_TOOL 탐지: Xcode MCP → xcodebuild+xcsift → swift build+xcsift → static
```

**기능 루프:**
`{HARNESS_DIR}/features.json`에서 `status=pending|failed|partial`인 기능을 priority 순서대로 하나씩 진행합니다:

```
for each feature (priority 순서):

  ┌─ Step 1: 기능 시작 기록 ─────────────────────┐
  │ session.json의 current_feature_id를 업데이트  │
  │ → 중단 시 어느 기능에서 멈췄는지 복구 가능    │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 2: 기능 카드 ─────────────────────────┐
  │ 기능 정보를 카드 형식으로 표시                │
  │                                              │
  │ ## 🎯 [F001] 앱 구조 설정                    │
  │ **설명**: 기본 App 구조와 NavigationStack     │
  │ **검증**: 앱 실행 시 메인 화면 표시           │
  │ **의존성**: 없음                              │
  │ **디자인 토큰**: $bg, $accent (있으면)        │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 3: 구현 계획 ─────────────────────────┐
  │ • 생성/수정할 파일 목록과 각 파일의 역할      │
  │ • 사용할 패턴/프레임워크                      │
  │ • design-spec.md의 토큰 매핑 참조            │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 4: 기술적 선택지 (해당 시) ────────────┐
  │ 트레이드오프가 존재하는 결정에만 제시          │
  │ "명백한 최선"이 있으면 Claude가 결정          │
  │                                              │
  │ 예: "NavigationStack vs NavigationSplitView?" │
  │ - Option A: NavigationStack — iOS 16+, 단순  │
  │ - Option B: NavigationSplitView — iPad 대응  │
  │                                              │
  │ 판단 기준: "두 선택지의 결과가 사용자에게      │
  │ 체감 가능하게 다른가?" → 아니면 Claude 결정   │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 5: 외부 편집 감지 ─────────────────────┐
  │ git diff로 사용자의 외부 편집을 확인          │
  │ 변경이 있으면 인지하고 이후 코드에 반영       │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 6: 코드 작성 ─────────────────────────┐
  │ 합의된 계획에 따라 Write/Edit 도구로 구현     │
  │ design-spec.md의 토큰 매핑 참조              │
  │ category="ui" 시 뷰 연결 검증               │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 7: 빌드 검증 + 상태 기록 + 커밋 ──────┐
  │ BUILD_TOOL로 빌드 검증 (폴백 체인 동일)       │
  │ 실패 시 사용자와 함께 에러 분석/수정 (최대 3회)│
  │                                              │
  │ ✅ 빌드 성공 시 (이 순서대로 실행):           │
  │   1. git commit: "feat(F001): <설명>"        │
  │   2. features.json status → built            │
  │   3. session.json current_feature_id → null  │
  │   (커밋 후 status 변경 → built=커밋완료 보장) │
  │                                              │
  │ ❌ 빌드 3회 실패 시:                          │
  │   1. features.json status → failed           │
  │   2. session.json current_feature_id → null  │
  │   3. 사용자에게 스킵/재시도 선택 제시         │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 8: 진행 상황 표시 ─────────────────────┐
  │ | ID   | 기능        | 상태      |           │
  │ |------|------------|----------|            │
  │ | F001 | 앱 구조    | ✅ 완료   |           │
  │ | F002 | 설정 화면  | 🔧 진행중 |           │
  │ | F003 | 데이터 모델 | ⏳ 대기   |           │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 9: 모드 전환 체크 ─────────────────────┐
  │ 사용자가 "나머지는 자율로" → autonomous 전환  │
  │ 남은 기능이 7개 이상 → 자율 전환 제안         │
  │                                              │
  │ 전환 시 session.json build_style 업데이트     │
  └──────────────────────────────────────────────┘
```

**사용자 역할 분담:**
- 사용자가 "이 부분은 내가 직접 할게" → **대기 + 보조** (기본). 사용자가 완료하면 Read로 확인 후 리뷰/보완.
- 사용자 요청 시 **병렬 작업** 가능 (사용자: A 파일, Claude: B 파일).

**모드 전환 (3방향):**
- collaborative → autonomous: 사용자 요청 또는 남은 기능이 많을 때 제안. 남은 기능을 harness-builder 서브에이전트에 위임. `session.json`의 `build_style`을 `"autonomous"`로 업데이트.
- collaborative → user-led: 사용자가 "내가 직접 할게" / "가이드만 줘"라고 요청 시 전환. `session.json`의 `build_style`을 `"user-led"`로 업데이트.
- autonomous → collaborative: Evaluator 피드백 후 사용자가 함께 수정하고 싶을 때 전환 가능. `session.json`의 `build_style`을 `"collaborative"`로 업데이트.

**컨텍스트 관리:**
- 메인 대화에서 실행되므로 컨텍스트 누적에 주의.
- 기능 완료마다 이전 기능의 구현 세부사항을 요약하고, 다음 기능에 필요한 인터페이스 정보만 유지.
- features.json의 진행 상태가 파일에 기록되므로, compaction 발생 시에도 현재 상태 복구 가능.

#### Phase 3-C: User-led Collaborative Build (build_style = "user-led")

서브에이전트를 호출하지 않고, **메인 대화에서 직접 실행**합니다.
에이전트가 기능별 구현 가이드를 생성하고, 사용자가 직접 코드를 작성합니다.
에이전트는 리뷰어 역할로, 사용자 승인 없이 코드를 수정하지 않습니다.

**Step 0: 빌드 도구 탐지**
Phase 3-B와 동일한 폴백 체인으로 빌드 도구를 탐지합니다:
```
BUILD_TOOL 탐지: Xcode MCP → xcodebuild+xcsift → swift build+xcsift → static
```

**기능 루프:**
`{HARNESS_DIR}/features.json`에서 `status=pending|failed|partial`인 기능을 priority 순서대로 하나씩 진행합니다:

```
for each feature (priority 순서):

  ┌─ Step 1: 기능 시작 기록 ─────────────────────┐
  │ session.json의 current_feature_id를 업데이트  │
  │ → 중단 시 어느 기능에서 멈췄는지 복구 가능    │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 2: 구현 가이드 생성 ───────────────────┐
  │ 기능 카드 + 상세 구현 가이드를 작성하여 표시   │
  │                                              │
  │ ## [FID] 기능명                               │
  │ **설명**: features.json의 description         │
  │ **검증 기준**: features.json의 verification   │
  │ **의존성**: 의존하는 기능 목록                 │
  │ **디자인 토큰**: design 필드의 tokens (있으면) │
  │                                              │
  │ ### 구현 가이드                               │
  │ **생성/수정 파일:**                           │
  │ - `경로/파일.swift` — 역할 설명               │
  │                                              │
  │ **구현 패턴:**                                │
  │ - 사용할 패턴/프레임워크 설명                  │
  │                                              │
  │ **코드 스니펫 예시:**                          │
  │ ```swift                                     │
  │ // 핵심 구조의 코드 예시                       │
  │ ```                                          │
  │                                              │
  │ **디자인 토큰 매핑:** (design-spec.md 참조)    │
  │ - $token → SwiftUI 매핑                      │
  │                                              │
  │ **주의사항:**                                  │
  │ - 구현 시 유의할 점                            │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 3: 사용자 작업 대기 ───────────────────┐
  │ "구현 가이드를 확인하시고 작업해주세요.         │
  │  완료되면 '완료' 또는 '다음'이라고 알려주세요. │
  │  질문이 있으면 언제든 물어보세요."             │
  │                                              │
  │ 사용자 메시지 유형에 따른 분기:               │
  │ "완료"/"다음"/"done" → Step 4 리뷰 진입      │
  │ "질문: ..."          → 질문에 답변 후 계속 대기│
  │ "이건 에이전트가 해줘" → 부분 위임 (아래 참조)│
  │ "N개 먼저 할게"      → 배치 모드 (current_feature_id→null)│
  │                                              │
  │ ⚠️ 사용자 응답 전까지 Write/Edit 도구 사용 금지│
  └──────────────────────────────────────────────┘
       │
       ▼ (사용자: "완료" / "다음")
  ┌─ Step 4: 변경사항 감지 + 리뷰 ──────────────┐
  │ git diff로 사용자 변경사항 수집               │
  │                                              │
  │ 리뷰 리포트:                                  │
  │ ✅ 구현 가이드 대비 완료 항목                  │
  │ ⚠️ 누락/개선 사항                             │
  │ 🐛 잠재 버그/이슈                             │
  │                                              │
  │ 수정 제안이 있으면:                            │
  │ "다음 수정을 적용할까요?"                      │
  │ - 제안 N: ... (diff 형태)                    │
  │ 사용자 승인 시에만 에이전트가 코드 수정        │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 5: 빌드 검증 + 상태 기록 + 커밋 ──────┐
  │ BUILD_TOOL로 빌드 검증 (폴백 체인 동일)       │
  │ 실패 시 에러 분석 리포트 + 수정 제안           │
  │   사용자 승인 시에만 에이전트가 수정           │
  │                                              │
  │ ✅ 빌드 성공 시 (이 순서대로 실행):           │
  │   1. git commit: "feat(FID): <설명>"         │
  │   2. features.json status → built            │
  │   3. session.json current_feature_id → null  │
  │   (커밋 후 status 변경 → built=커밋완료 보장) │
  │                                              │
  │ ❌ 빌드 3회 실패 시:                          │
  │   1. features.json status → failed           │
  │   2. session.json current_feature_id → null  │
  │   3. 사용자에게 스킵/재시도 선택 제시         │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 6: 진행 상황 표시 ─────────────────────┐
  │ | ID   | 기능        | 상태      |           │
  │ |------|------------|----------|            │
  │ | F001 | 앱 구조    | ✅ 완료   |           │
  │ | F002 | 설정 화면  | 🔧 진행중 |           │
  │ | F003 | 데이터 모델 | ⏳ 대기   |           │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 7: 모드 전환 체크 ─────────────────────┐
  │ 사용자가 "나머지는 자율로" → autonomous 전환  │
  │ 사용자가 "에이전트가 짜줘" → collaborative    │
  │ 남은 기능이 7개 이상 → 전환 제안              │
  │                                              │
  │ 전환 시 session.json build_style 업데이트     │
  └──────────────────────────────────────────────┘
```

**코드 수정 권한 규칙:**

Phase 3-C에서 에이전트의 Write/Edit 도구 사용 조건:

| 조건 | Write/Edit 허용 |
|------|----------------|
| HARNESS_DIR 내 메타파일 (session.json, features.json) | ✅ 항상 |
| 리뷰에서 제안한 코드 수정 → 사용자 "적용해줘" 승인 | ✅ 승인 후 |
| 빌드 에러 수정 → 사용자 "수정해줘" 승인 | ✅ 승인 후 |
| 사용자 "이것도 에이전트가 해줘" 위임 | ✅ 위임 시 |
| 가이드 제시 후 사용자 응답 없이 코드 작성 | ❌ 금지 |
| 리뷰 피드백을 사용자 승인 없이 자동 적용 | ❌ 금지 |
| "명백한 수정"이라는 판단으로 자율 수정 | ❌ 금지 |

**부분 위임:**
사용자가 특정 기능만 에이전트에게 위임할 수 있습니다:
- 사용자: "F003은 에이전트가 해줘" → F003만 Phase 3-B 방식으로 에이전트가 구현
- `session.json`의 `build_style`은 `"user-led"` 유지
- F003 완료 후 다음 기능은 다시 user-led 가이드 모드로 복귀
- **재진입 시**: 부분 위임된 기능이 `pending` 상태로 재진입되면, 위임 컨텍스트는 유실되므로 user-led 기본 흐름(구현 가이드 생성)으로 복구. 사용자가 다시 위임 요청 가능

**배치 모드:**
사용자가 여러 기능을 한꺼번에 작업할 때:

1. **진입**: 사용자가 "F002, F003, F004 먼저 할게" 또는 "3개 먼저 할게" 등 명시적 요청. 단건 기능 루프의 Step 3에서 진입 가능 — 이 경우 현재 기능의 `current_feature_id`를 `null`로 초기화 (해당 기능은 배치에 포함됨)
2. **가이드 생성**: 해당 기능들의 구현 가이드를 연속 출력. `session.json` 업데이트: `batch_features`에 기능 ID 목록 기록, `current_feature_id` → `null`
3. **대기**: "N개 기능의 구현 가이드를 작성했습니다. 작업 완료 후 알려주세요. 개별 기능 완료 시에도 중간 리뷰 가능합니다."
4. **리뷰**: `git diff`로 전체 변경사항을 기능별로 분류하여 리뷰. 수정 제안은 사용자 승인 후에만 적용
5. **빌드 검증**: 전체 빌드 1회 실행. 성공 → step 6으로 진행 (이 시점에서 status는 아직 `pending` 유지). 실패 시 에러를 기능별로 매핑하여 리포트
6. **커밋**: 기능별로 순차 처리 — 각 기능마다: `current_feature_id` 설정 → git commit → `features.json` status → `built` → `current_feature_id` → `null`. status를 커밋 이후에 변경하므로, `built` = "커밋 완료"가 보장됨
7. **해제**: `session.json`의 `batch_features` → `null`, `current_feature_id` → `null`. 단건 모드로 복귀

**배치 + 부분 위임 조합:** 배치 모드 중 사용자가 "F004는 에이전트가 짜줘" → F004만 Phase 3-B 방식으로 에이전트가 구현. 나머지 배치 기능은 사용자가 계속 작업. `batch_features`와 `build_style`은 유지.

**모드 전환 (3방향):**
- user-led → autonomous: 사용자 "나머지는 자율로" 또는 남은 기능 ≥7개 시 제안. `session.json`의 `build_style`을 `"autonomous"`로 업데이트.
- user-led → collaborative: 사용자 "나머지는 에이전트가 짜줘". `session.json`의 `build_style`을 `"collaborative"`로 업데이트.
- autonomous/collaborative → user-led: 사용자 "내가 직접 할게" / "가이드만 줘". `session.json`의 `build_style`을 `"user-led"`로 업데이트.

**모드 전환 시 배치 상태 처리:** 모드 전환 시 `batch_features`가 non-null이면 `null`로 클리어합니다. 배치 내 이미 `built` 상태인 기능은 보존되며, `pending` 상태인 기능은 새 모드에서 개별 처리됩니다.

**컨텍스트 관리:**
- 메인 대화에서 실행되므로 컨텍스트 누적에 주의.
- 기능 완료마다 이전 기능의 구현 가이드와 리뷰를 요약하고, 다음 기능에 필요한 인터페이스 정보만 유지.
- features.json의 진행 상태가 파일에 기록되므로, compaction 발생 시에도 현재 상태 복구 가능.

### Phase 4: EVALUATE

**Phase 4 진입 시 session.json 업데이트:**
```json
{ "phase": "evaluate", "current_round": N, "current_feature_id": null, "batch_features": null }
```

harness-evaluator 에이전트를 호출합니다:

```
Agent 도구 호출:
  description: "harness-evaluator: QA 검증"
  prompt: |
    HARNESS_DIR: {HARNESS_DIR}
    기능 목록: {HARNESS_DIR}/features.json
    제품 스펙: {HARNESS_DIR}/harness-spec.md
    라운드: {현재 라운드 번호}/3

    status=built인 기능을 회의적으로 검증하고,
    PASS/PARTIAL/FAIL 점수를 부여해주세요.

    {HARNESS_DIR}/evaluation-round-{N}.md 파일을 작성하세요.
    Step 0에서 baepsae/axe 도구를 최우선 탐지하세요.
    4축 다차원 점수를 부여하세요:
    - 기능완성(functionality), 코드품질(codeQuality),
      UI품질(designQuality), 인터랙션(interactionQuality)
    - 가중 평균(weightedAverage)으로 PASS/PARTIAL/FAIL 판정
    {HARNESS_DIR}/design-spec.md와 .pen 파일이 존재하면:
    - 디자인 구조와 코드 View 계층을 대조하세요
    - 디자인 토큰이 SwiftUI 코드에 올바르게 반영되었는지 검증하세요
```

**Phase 4 결과 처리 + session.json 상태 전이:**

- 판정 **PASS** (80%+ 기능 통과):
  1. `session.json` → `{ "phase": "complete", "current_round": N }`
  2. **하네스 완료** — 최종 보고 출력

- 판정 **NEED_REVISION**:
  1. `session.json` → `{ "phase": "build", "current_round": N+1 }` ← 즉시 build로 전이 + 라운드 증가
  2. `build_style = "autonomous"` → Evaluator의 FAIL/PARTIAL 피드백을 Builder에게 전달 → Phase 3-A에서 failed/partial 기능 재실행
  3. `build_style = "collaborative"` → FAIL/PARTIAL 항목을 사용자와 함께 분석하고 수정 → Phase 3-B로 failed/partial 기능만 재진행. 이 시점에서 사용자가 autonomous 또는 user-led 전환을 요청할 수 있음.
  4. `build_style = "user-led"` → Evaluator의 FAIL/PARTIAL 피드백을 **수정 가이드** 형태로 변환하여 제시 → Phase 3-C로 복귀하여 사용자 주도 수정. 이 시점에서 사용자가 autonomous 또는 collaborative 전환을 요청할 수 있음.

### Loop Control

#### Autonomous 모드 (자율 진행)

```
라운드 1: BUILD(3-A) → EVALUATE
  PASS → 완료, 사용자에게 최종 보고
  NEED_REVISION → 자동으로 라운드 2 진행 (중간 보고만)

라운드 2: BUILD(3-A) ({HARNESS_DIR}/evaluation-round-1.md 참조) → EVALUATE
  PASS → 완료
  NEED_REVISION → 자동으로 라운드 3 진행

라운드 3: BUILD(3-A) ({HARNESS_DIR}/evaluation-round-2.md 참조) → EVALUATE
  PASS → 완료
  NEED_REVISION → 사용자에게 상황 보고 + 선택:
    a) 계속 → 라운드 4 (최종, 추가 1회만 허용)
    b) 중단 → 현재 상태로 종료, {HARNESS_DIR}/features.json과 커밋 히스토리 보고
    c) 수동 수정 → 사용자가 직접 수정 후 Evaluate만 재실행
```

#### Collaborative 모드 (에이전트 주도)

```
라운드 1: BUILD(3-B, 사용자와 협업) → EVALUATE
  PASS → 완료, 사용자에게 최종 보고
  NEED_REVISION → FAIL/PARTIAL 항목을 사용자와 함께 분석, 수정 방향 토론 후 재구현

라운드 2: BUILD(3-B, FAIL/PARTIAL만) → EVALUATE
  PASS → 완료
  NEED_REVISION → 라운드 3 진행

라운드 3: BUILD(3-B) → EVALUATE
  PASS → 완료
  NEED_REVISION → 사용자에게 상황 보고 + 선택:
    a) 계속 (collaborative) → 라운드 4
    b) 자율 전환 → 남은 FAIL/PARTIAL 항목을 autonomous로 전환
    c) 중단 → 현재 상태로 종료

모드 전환: 어느 라운드에서든 사용자가 요청하면 autonomous ↔ collaborative ↔ user-led 전환 가능
```

#### User-led 모드 (사용자 주도)

```
라운드 1: BUILD(3-C, 사용자 구현 + 에이전트 리뷰) → EVALUATE
  PASS → 완료, 사용자에게 최종 보고
  NEED_REVISION → FAIL/PARTIAL 항목에 대해 수정 가이드 재생성
    사용자가 수정 후 리뷰 → 재빌드

라운드 2: BUILD(3-C, FAIL/PARTIAL만) → EVALUATE
  PASS → 완료
  NEED_REVISION → 라운드 3 진행

라운드 3: BUILD(3-C) → EVALUATE
  PASS → 완료
  NEED_REVISION → 사용자에게 상황 보고 + 선택:
    a) 계속 (user-led) → 라운드 4
    b) 에이전트 주도 협업 전환 → Phase 3-B로 남은 FAIL/PARTIAL 항목 처리
    c) 자율 전환 → Phase 3-A로 위임
    d) 중단 → 현재 상태로 종료

모드 전환: 어느 라운드에서든 사용자가 요청하면 autonomous ↔ collaborative ↔ user-led 전환 가능
```

**NEED_REVISION 시 user-led 특화:**
- Evaluator의 FAIL/PARTIAL 피드백을 **수정 가이드** 형태로 변환하여 제시
- 기존 구현 가이드 + "Evaluator 피드백 요약 + 구체적 수정 포인트" 포맷
- 사용자가 수정 후 리뷰 → 빌드 검증 → 다음 라운드

NEED_REVISION 후 Phase 3 재진입 시 반드시 포함 (모든 라운드에서 동일하게 적용):
- **autonomous/collaborative**: Builder 프롬프트에 `{HARNESS_DIR}/evaluation-round-{N-1}.md를 참조하여 FAIL/PARTIAL 항목의 구체적 수정 지침을 확인하세요` 포함
- **user-led**: 수정 가이드(Step 2) 생성 시 `{HARNESS_DIR}/evaluation-round-{N-1}.md`의 FAIL/PARTIAL 피드백을 요약하여 "Evaluator 피드백 + 구체적 수정 포인트" 형태로 가이드에 반영. 재진입 시에도 Step 1에서 `current_feature_id`를 설정합니다.
- ※ Phase 3-B의 Step 번호(9 Step)와 Phase 3-C의 Step 번호(7 Step)는 상이합니다. 각 Phase의 Step 정의를 참조하세요.

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
    "design": {
      "penFile": "designs/app.pen",
      "frameId": "screen-settings",
      "tokens": ["$bg", "$accent", "$radius-card"]
    },
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
- `design`: Designer가 Phase 2에서 작성. optional — Pencil 미사용 시 없음.
- `scores`: Evaluator가 평가 시 기록. optional — 기존 PASS/PARTIAL/FAIL 상태와 호환

**상태 전이:**
```
pending → built (Builder 완료, 빌드 검증 성공 — Xcode MCP 또는 xcodebuild+xcsift 또는 swift build+xcsift)
pending → built_unverified (Builder 완료, 빌드 도구 없음 — static 모드)
built → verified (Evaluator PASS)
built → partial (Evaluator PARTIAL — 소폭 수정 필요)
built → failed (Evaluator FAIL — 재구현 필요)
built_unverified → verified/partial/failed (Evaluator 검증)
partial → built (소폭 수정 — autonomous/collaborative: Builder, user-led: 사용자)
failed → built (재구현 또는 빌드 실패 재시도 — autonomous/collaborative: Builder, user-led: 사용자)
```

**불변 규칙:**
- 기능을 삭제하거나 기준을 완화하는 것은 **절대 금지**
- status와 priority만 업데이트 가능
- JSON 형식 유지 (마크다운이 아닌 JSON — 모델의 부적절한 편집 방지)

## session.json Schema

```json
{
  "build_style": "autonomous | collaborative | user-led",
  "current_round": 1,
  "current_feature_id": "F003 | null",
  "batch_features": ["F002", "F003"] | null,
  "phase": "build | evaluate | complete"
}
```

- `build_style`: Phase 2.5에서 설정, 모드 전환 시 업데이트. `"autonomous"` → Phase 3-A, `"collaborative"` → Phase 3-B, `"user-led"` → Phase 3-C
- `current_round`: 1에서 시작. NEED_REVISION 판정 시 N+1로 증가. **최대값: 4** (라운드 3 + 추가 1회). 재진입 시 `current_round > 4`이면 강제 종료.
- `current_feature_id`: collaborative/user-led 모드에서 기능 시작 시 설정, 완료/실패 시 null로 초기화. autonomous 모드에서는 항상 null (Builder 서브에이전트가 관리하지 않음). 재진입 시 non-null이면 해당 기능이 중단된 것으로 판단.
- `batch_features`: user-led 모드 배치 작업 시 대기 중인 기능 ID 목록. 배치 완료 시 `null`로 클리어. user-led 외 모드에서는 항상 `null`.
- `phase`: `build`, `evaluate`, `complete` 3개 값만 사용. Phase 0~2 단계에서는 session.json이 존재하지 않으므로 `plan`/`verify`/`design` 값은 사용하지 않음.

**phase 상태 전이 다이어그램:**
```
build_style 선택 → "build" (current_round=1)
  │
  ├─ autonomous  → Phase 3-A (Builder 서브에이전트)
  ├─ collaborative → Phase 3-B (에이전트 주도, 메인 대화)
  └─ user-led    → Phase 3-C (사용자 주도, 메인 대화)
  │
  ▼
Phase 3 완료 → "evaluate"
  │
  ├─ PASS → "complete" (최종)
  └─ NEED_REVISION → "build" (current_round +1, build_style 유지하여 동일 Phase 3 변형으로 재진입)
                        │
                        └─ current_round > 4 → 강제 종료
```

**생성 시점:** Phase 2.5에서 build_style 선택 시 최초 생성. 이전 Phase(0~2)에서는 존재하지 않음 — Phase 1~2 중단 시에는 harness-spec.md/features.json 존재 여부로 재진입 감지.
**업데이트 시점:** Phase 전환(build↔evaluate↔complete), 기능 시작/완료, 모드 전환, NEED_REVISION 시 라운드 증가.

## Git Integration

- Builder가 각 기능 완료 시 **설명적 커밋 메시지**로 커밋
- 커밋 형식: `feat(F001): <기능 설명>`
- Evaluator 피드백 후 수정 시: `fix(F001): <수정 내용>`
- 하네스 실패 시 사용자에게 롤백 옵션 안내: "하네스 시작 전 커밋으로 되돌리려면 `git log`에서 시작 커밋을 확인하고 `git reset --hard <commit>`을 실행하세요. **주의: 이 명령은 모든 변경을 삭제합니다.**"

## Context Management

- 각 에이전트는 **독립 서브에이전트**로 실행 → 자연스러운 컨텍스트 격리
- 에이전트 간 통신은 **파일 기반** ({HARNESS_DIR}/harness-spec.md, {HARNESS_DIR}/features.json)
- 대규모 프로젝트의 경우 Builder가 자동 컴팩션 활용
- **Collaborative 모드 주의**: 메인 대화에서 실행되므로 컨텍스트 누적이 발생함. 기능 완료마다 이전 기능의 구현 세부사항을 요약하고, 다음 기능에 필요한 인터페이스 정보만 유지. 남은 기능이 7개 이상이면 autonomous 전환을 제안.

## Response Templates

### 하네스 시작 알림
```markdown
## 🔨 apple-craft harness 시작

**요청**: <사용자 요구사항>
**모드**: Plan → Design → Build(<build_style>) → Evaluate (최대 3 라운드)

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
**상세 로그**: {HARNESS_DIR}/evaluation-round-<N>.md
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

1. **빌드 검증 도구**: Xcode MCP가 가장 풍부한 빌드 피드백을 제공합니다. 미연결 시 `xcodebuild` CLI + `xcsift`로 폴백하여 빌드 검증을 수행합니다. SPM 프로젝트는 `swift build` + `xcsift`도 지원합니다. 모든 빌드 도구가 없을 때만 `built_unverified`로 마킹됩니다. `xcsift` 설치: `brew install xcsift`.

2. **비용**: 3 라운드 × 3 에이전트 = 최대 9개 에이전트 호출. 간단한 작업은 기존 `apple-craft` implement 모드가 효율적입니다.

3. **런타임 검증 도구 권장**: 런타임 인터랙션 검증을 위해 `app-automation` 플러그인(mcp-baepsae) 설치를 권장합니다. 미설치 시 정적 검증 모드로 동작합니다.

4. **프로젝트 생성 한계**: 새 Xcode 프로젝트를 생성하는 것(xcodegen, Tuist 등)은 이 하네스의 범위 밖입니다. 기존 프로젝트에 기능을 추가하는 것이 주 용도입니다.

5. **자기평가 한계**: Evaluator도 LLM이므로 완벽한 QA는 아닙니다. 최종 결과는 반드시 사람이 검토해야 합니다.

6. **Pencil MCP 선택적**: Phase 2-A(디자인 설계)는 Pencil 없이도 항상 실행되어 Builder/Evaluator에게 토큰 매핑과 화면 구조를 제공합니다. Phase 2-B(디자인 구현)만 Pencil MCP 연결 시 실행됩니다. Pencil이 SwiftUI 코드를 직접 생성하지 않으므로, 디자인→코드 변환은 Builder가 수행합니다.

7. **Collaborative 모드 컨텍스트**: Collaborative 모드는 메인 대화에서 실행되므로, 기능 수가 많은 프로젝트에서는 컨텍스트 윈도우가 빠르게 소모됩니다. 10개 이상의 기능이 있는 프로젝트에서는 autonomous 모드를 권장하거나, collaborative로 핵심 기능만 진행한 후 나머지를 autonomous로 전환하세요.

## Quick Reference

```
apple-harness 실행 흐름
├─ Phase 1: PLAN (harness-planner)
│   ├─ 참조 문서 식별 + harness-design-principles.md 숙지
│   ├─ AskUserQuestion으로 맥락 수집
│   ├─ {HARNESS_DIR}/harness-spec.md 생성 (사용자 맥락 포함)
│   ├─ {HARNESS_DIR}/features.json 생성
│   └─ 사용자 확인 (마지막 확인점)
├─ Phase 1.5: VERIFICATION REVIEW (harness-evaluator)
│   ├─ verification 필드 검토/보강
│   ├─ verification_steps 작성
│   └─ 자동 진행 (사용자 확인 없음)
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
├─ Phase 2.5: BUILD STYLE 선택 (AskUserQuestion)
│   ├─ autonomous | agent-led collaborative | user-led collaborative 선택
│   └─ {HARNESS_DIR}/session.json 생성 (build_style, phase, round 기록)
├─ Phase 3: BUILD
│   ├─ [autonomous] harness-builder 서브에이전트 호출
│   │   ├─ Step 0: 빌드 도구 탐지
│   │   ├─ pending/failed/partial 기능 자율 구현 + 빌드 검증 + 커밋
│   │   └─ features.json status → built
│   ├─ [agent-led collaborative] 메인 대화에서 직접 실행
│   │   ├─ Step 0: 빌드 도구 탐지 (동일 폴백 체인)
│   │   ├─ 기능별: 카드 표시 → 구현 계획 → 기술적 선택지 → 코드 작성 → 빌드 → 커밋
│   │   ├─ 외부 편집 감지 (git diff)
│   │   ├─ 모드 전환 가능 (autonomous ↔ collaborative ↔ user-led)
│   │   ├─ session.json에 current_feature_id 기록 (재진입 대비)
│   │   └─ features.json status → built
│   └─ [user-led collaborative] 메인 대화에서 직접 실행
│       ├─ Step 0: 빌드 도구 탐지 (동일 폴백 체인)
│       ├─ 기능별: 구현 가이드 생성 → 사용자 작업 대기 → 변경사항 리뷰 → 빌드 → 커밋
│       ├─ 사용자 승인 없이 코드 수정 금지
│       ├─ 배치 모드 지원 (batch_features)
│       ├─ 부분 위임 가능 (개별 기능만 에이전트에게 위임)
│       ├─ 모드 전환 가능 (autonomous ↔ collaborative ↔ user-led)
│       ├─ session.json에 current_feature_id + batch_features 기록
│       └─ features.json status → built
├─ Phase 4: EVALUATE (harness-evaluator)
│   ├─ session.json phase → "evaluate" 업데이트
│   ├─ Step 0: baepsae/axe 최우선 탐지 + Pencil + 보조 도구 탐색
│   ├─ 4축 다차원 검증 (기능완성/코드품질/UI품질/인터랙션)
│   ├─ 디자인-코드 비교 ({HARNESS_DIR}/design-spec.md 존재 시)
│   ├─ {HARNESS_DIR}/evaluation-round-{N}.md 상세 로그 생성
│   ├─ PASS/PARTIAL/FAIL 점수 + 가중 평균
│   └─ 80% 통과 → 완료 / 미달 → BUILD 재실행 (build_style 유지)
├─ 자율 루프 (최대 3 라운드), 3회 실패 시에만 사용자 확인
└─ 재진입: session.json 존재 시 → 상태 복구 후 해당 Phase에서 재개
```

## Walkthrough Example

실제 하네스 실행의 전체 과정을 보려면 참조 문서를 읽으세요:

```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/walkthrough-liquid-glass-settings.md
```

이 워크스루는 "Liquid Glass 설정 화면 구현"의 Phase 1→1.5→3→4 전체 과정을 보여줍니다
(Phase 2 DESIGN은 Pencil MCP 미연결으로 자동 스킵된 시나리오):
- {HARNESS_DIR}/harness-spec.md와 {HARNESS_DIR}/features.json 예시 (10개 기능)
- Evaluator의 4축 다차원 검증 결과
- 1라운드에서 80% 통과한 실제 흐름
