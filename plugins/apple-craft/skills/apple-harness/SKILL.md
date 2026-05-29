---
name: apple-harness
description: apple-craft long-running implementation harness — builds new apps/features from scratch or runs large-scale Apple development work that reshapes the whole app, via a Plan→Design→Build→Evaluate loop. Activates on requests like "처음부터", "새 앱", "전체 구현", "앱 전체", "전면 리팩토링", "대규모 기능 개발", "멀티스텝 장기 작업", "harness", "하네스", "feature development", "new app", "full implementation", "from scratch". For single-file edits, small refactors, or code review, apple-craft or apple-review is a better fit.
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

Based on the V2 simplification pattern of Anthropic's [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps).
Automates long-running Apple platform development with four agents (Planner→Designer→Builder→Evaluator).

This skill handles **from-scratch / full / whole-app / long-running** scope, not single-file edits or small refactors.
For small implementations or fixes use `apple-craft`; for review or inspection use `apple-review`.

Respond to the user in Korean.

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

> **Design principle**: This harness is based on Anthropic's Harness Design blog.
> At startup every agent reads:
> `${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/harness-design-principles.md`

## Environment Tools

The apple-craft harness actively uses all skills/MCP/tools in the Claude Code environment.
The harness always drives orchestration; external tools operate under its direction.

### Runtime verification tools (Evaluator checks first)
- **mcp-baepsae** (app-automation plugin): iOS Simulator + macOS app runtime interaction
- **axe-simulator**: iOS Simulator accessibility-based automation

### Build/verification tools — fallback chain

Build verification auto-selects an available tool in this priority order:

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

| BUILD_TOOL | Detection | Build command | status |
|------------|-----------|---------------|--------|
| `xcode-mcp` | `mcp__xcode__BuildProject` call succeeds | BuildProject MCP tool | `built` |
| `xcodebuild` | `which xcodebuild` + `.xcworkspace`/`.xcodeproj` present | `xcodebuild build ... 2>&1 \| xcsift -E` | `built` |
| `swift-build` | `Package.swift` present | `swift build 2>&1 \| xcsift -E` | `built` |
| `static` | all above fail | none (code review only) | `built_unverified` |

#### Core xcodebuild options (used by the harness)

**Project detection order:**
```bash
# 1. workspace 우선 (.xcworkspace)
xcodebuild -workspace <name>.xcworkspace -scheme <scheme> build 2>&1 | xcsift -E

# 2. project (.xcodeproj)
xcodebuild -project <name>.xcodeproj -scheme <scheme> build 2>&1 | xcsift -E

# 3. scheme 자동 탐지
xcodebuild -list [-workspace <name> | -project <name>] -json
```

**Build options:**
| Option | Purpose | Example |
|--------|---------|---------|
| `-workspace NAME` | Specify workspace | `-workspace App.xcworkspace` |
| `-project NAME` | Specify project | `-project App.xcodeproj` |
| `-scheme NAME` | Specify scheme (required) | `-scheme MyApp` |
| `-configuration NAME` | Build configuration | `-configuration Debug` |
| `-destination SPEC` | Build target device | `-destination 'platform=iOS Simulator,name=iPhone 16'` |
| `-sdk SDK` | Specify SDK | `-sdk iphonesimulator` |
| `-quiet` | Warnings/errors only | when used alone |
| `-parallelizeTargets` | Parallel build | faster builds |
| `-derivedDataPath PATH` | Build artifact path | isolated build |
| `-showBuildTimingSummary` | Build timing report | performance analysis |

**Test options:**
| Option | Purpose | Example |
|--------|---------|---------|
| `test` (build action) | Run tests | `xcodebuild test -scheme ...` |
| `-enableCodeCoverage YES` | Code coverage | `xcodebuild test -enableCodeCoverage YES` |
| `-parallel-testing-enabled YES` | Parallel tests | faster tests |
| `-only-testing:TARGET/CLASS/METHOD` | Specific tests only | targeted test |

#### xcsift options (build output parsing)

xcsift converts xcodebuild/swift build output into structured JSON.

**Required pattern:** `xcodebuild ... 2>&1 | xcsift [options]` — always redirect stderr with `2>&1`, since errors arrive on stderr.

| Option | Short | Purpose | Harness use |
|--------|-------|---------|-------------|
| `--exit-on-failure` | `-E` | Return exit code on build failure | build success/failure decision |
| `--warnings` | `-w` | Show detailed warning list | Evaluator code-quality axis |
| `--Werror` | `-W` | Treat warnings as errors | strict mode |
| `--quiet` | `-q` | Suppress output on success | simplify build loop |
| `--coverage` | `-c` | Code coverage data | test verification |
| `--coverage-details` | — | Per-file coverage detail | deep test analysis |
| `--executable` | `-e` | Built executable path | simulator deploy |
| `--build-info` | — | Per-target build phases/timing | build perf analysis |
| `--slow-threshold N` | — | Detect slow tests (seconds) | test quality |
| `--format json` | `-f json` | JSON output (default) | LLM parsing |
| `--format toon` | `-f toon` | TOON output (saves 30-60% tokens) | context saving |

**xcsift JSON output structure (build):**
```json
{
  "result": "success" | "failure",
  "errors": [{"file": "...", "line": 42, "message": "..."}],
  "warnings": [{"file": "...", "line": 10, "message": "..."}],
  "errorCount": 0,
  "warningCount": 2
}
```

#### Core swift build options (SPM projects)

| Option | Purpose |
|--------|---------|
| `--package-path PATH` | Specify package path |
| `-c debug\|release` | Build configuration |
| `--verbose` / `-v` | Verbose output |
| `--quiet` / `-q` | Errors only |

### Auxiliary tools (use if present)
- safe-design-advisor, code-review, swift-master, and other environment skills

### Design tools
- **Pencil MCP**: create/read/screenshot .pen designs, manage tokens
  → used in Phase 2 DESIGN, and in the Phase 4 EVALUATE design-vs-code comparison
  → read existing .pen files first; create new only if none exist

### Dynamic tool discovery
Each agent discovers available tools in Step 0 at startup.
It does not depend on a specific tool, and auto-assembles the best tool combination for the environment.

## Orchestration Flow

### Phase 0: SESSION SETUP (run at harness start)

At harness start, derive a **session name** from the user request and create an isolated working directory.
This keeps artifacts from multiple harness sessions from colliding.

**Session name rules:**
1. Extract core keywords from the request into a kebab-case slug (English, 2-4 words)
   - e.g. "Liquid Glass 설정 화면" → `liquid-glass-settings`
   - e.g. "FoundationModels 채팅 기능" → `foundation-models-chat`
   - e.g. "전체 UI 리팩토링" → `ui-refactoring`
2. If a directory of the same name already exists, append `-2`, `-3`, etc.

**HARNESS_BASE / HARNESS_DIR setup:**

The base path is fixed at **the project root's `.apple-harness/`** (same hidden-dir convention as `.codex-research/`, `.claude/`).

```
HARNESS_BASE = {project-root}/.apple-harness
HARNESS_DIR  = {HARNESS_BASE}/{session-name}
```

- `{project-root}` = current working directory at harness invocation (CWD). Confirm with `pwd` and store as an absolute path, since subagent CWDs may differ.
- e.g. project root `/Users/me/app` and session name `liquid-glass-settings` → `HARNESS_DIR = /Users/me/app/.apple-harness/liquid-glass-settings`
- `.apple-harness/` holds local work artifacts, so add `.apple-harness/` to `.gitignore` to keep it out of version control (if it's missing at session start, notify the user).

**Directory creation:**
```bash
# 프로젝트 루트 기준 베이스 + 세션 디렉토리 생성
mkdir -p "{HARNESS_BASE}/{session-name}"
# 이후 HARNESS_DIR 변수에 절대 경로를 저장하여 모든 Phase에서 재사용
```

**Collision rule:** If `{HARNESS_BASE}/{session-name}` already exists and contains `session.json`/`features.json`, it is a **re-entry target** (go to Step 1). If it collides but is not a re-entry and a fresh session is wanted, append `-2`, `-3` for a new directory.

All later phases use `{HARNESS_DIR}` (always an **absolute path**):
- `{HARNESS_DIR}/harness-spec.md`
- `{HARNESS_DIR}/features.json`
- `{HARNESS_DIR}/design-spec.md`
- `{HARNESS_DIR}/evaluation-round-{N}.md`
- `{HARNESS_DIR}/session.json` — session metadata (build_style, current round, etc.)
- `{HARNESS_DIR}/guides/`, `{HARNESS_DIR}/reviews/`, `{HARNESS_DIR}/build-errors/`, `{HARNESS_DIR}/worst-cases.md` (created in Phase 3 collaborative/user-led modes)

Pass `HARNESS_DIR: {absolute path}` in every agent prompt — use an absolute path, not a relative one, because subagent CWDs may differ.

**Re-entry detection (harness invoked in a new conversation):**

**Step 1: Check for existing artifacts**
Check HARNESS_DIR for these files:
- `session.json` present → go to Step 2 (session-based re-entry)
- `session.json` absent + `features.json` present → **classify by analyzing features.json status**:

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

- `session.json` absent + only `harness-spec.md` present (no features.json) → Planner interrupted mid-Phase 1. Check harness-spec.md and resume from Phase 1.
- No files at all → new session (Phase 0)

**Step 2: session.json-based re-entry**
1. Read `session.json` to recover `build_style`, `current_round`, `current_feature_id`, `batch_features`, `phase`
2. Read `features.json` to check each feature's current status
3. **Cross-validate session.json against features.json** to decide the actual resume point:

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
            │   │   └─ 커밋 없음 → guides/{FID}-guide.md 존재 확인:
            │   │       ├─ 존재 → 파일 open + "이전에 [FID] 가이드를 열어드렸습니다.
            │   │       │          작업 중이셨나요? 리뷰를 진행할까요?" (재생성 안 함)
            │   │       └─ 없음 → 새 가이드 파일 생성 + open (Step 2부터 재진입)
            │   ├─ failed/partial → 수정 가이드 재생성.
            │   │   guides/{FID}-guide.md 덮어쓰기 (기존 사용자 편집 백업은
            │   │   guides/{FID}-guide.backup-r{N-1}.md로 보존).
            │   │   evaluation-round-{N-1}.md 존재 시 Evaluator 피드백 포함,
            │   │   build-errors/{FID}-build-attempt-*.md 존재 시 빌드 에러 이력
            │   │   참조 (두 원인이 동시 존재 가능). worst-cases.md 관련 엔트리
            │   │   도 추출하여 "피해야 할 패턴" 섹션 갱신.
            │   │   open 후 "이전에 [FID] 작업 중이었습니다. (status: [FAIL/PARTIAL])
            │   │    수정 가이드를 새로 열어드렸습니다. 확인 후 계속하시겠습니까?"
            │   └─ built → current_feature_id를 null로 보정, 다음 pending/failed/partial 기능으로 이동
            └─ 아니오 → 다음 pending/failed/partial 기능을 확인하여 status별 가이드 생성:
                ├─ pending → guides/{FID}-guide.md 존재 여부 확인:
                │   ├─ 존재 → 파일 open만 수행 (재생성 금지, 사용자 편집 보존)
                │   └─ 없음 → 구현 가이드 생성 + open (초회 구현)
                └─ failed/partial → 수정 가이드 재생성 (덮어쓰기 + backup 보존).
                    evaluation-round-{N-1}.md 존재 시 Evaluator 피드백 포함,
                    build-errors/{FID}-build-attempt-*.md 및 worst-cases.md
                    참조 (두 원인이 동시 존재 가능).
```

4. Summarize the current state for the user and tell them which Phase will resume.
5. Allow the user to start from a different Phase if they want.

### Phase 1: PLAN

Call the harness-planner agent:

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

**Phase 1 completion check (required — do not proceed without it):**
After the Planner finishes, verify:
1. Read to confirm `{HARNESS_DIR}/harness-spec.md` exists
2. Read to confirm `{HARNESS_DIR}/features.json` exists and is valid JSON
3. Confirm every feature's status is "pending"
**On check failure**: report to the user "Planner가 파일을 올바르게 생성하지 못했습니다" and do not proceed to Phase 2.

**Open the documents directly (after the check passes):**
Once the check passes, open the generated documents directly in the user's editor:
```bash
open "{HARNESS_DIR}/harness-spec.md"
open "{HARNESS_DIR}/features.json"
```
This lets the user review the full spec in their editor.

**User confirmation**: confirm with "문서를 열었습니다. 스펙과 기능 목록을 확인하시고, 수정 사항이 있으면 알려주세요. 이대로 진행할까요?".
If the user requests changes → call the Planner again to revise.

**Agent failure handling**: If the Planner agent exits with an error, report the error to the user and confirm whether to retry.

### Phase 1.5: VERIFICATION REVIEW

Since Phase 1 collected enough context, this step **runs autonomously without user confirmation**.

Call the harness-evaluator agent in "VERIFICATION_REVIEW mode":

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

**Phase 1.5 completion handling:**
- Briefly report only the changes made to {HARNESS_DIR}/features.json
- Proceed to Phase 2 automatically, without user confirmation

### Phase 2-A: DESIGN ARCHITECTURE (always runs)

Since Phase 1 collected enough context, this step **runs autonomously without user confirmation**.

Call the harness-design-architect agent:

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

**Phase 2-A completion check (required):**
1. Read to confirm `{HARNESS_DIR}/design-spec.md` exists
2. Confirm it includes the token mapping table and per-screen structure
**On check failure**: report to the user and proceed to Phase 3 (graceful degradation).

**Downstream consumers:**
- `design-spec.md` is consumed by Phase 2-B (design-implementer), Phase 3 (Builder), and Phase 4 (Evaluator)
- Even without Pencil, it provides Builder/Evaluator with the token mapping + screen structure + HIG checklist

**Agent failure handling**: on error, report "디자인 설계 실패" and proceed to Phase 3.

### Phase 2-B: DESIGN IMPLEMENTATION (optional)

Whether this runs depends on Pencil MCP availability and the work context.

**Step 1: Detect Pencil** — try calling get_editor_state
- Fails → auto-skip Phase 2-B and go straight to Phase 3 (BUILD), preserving the architect's artifacts (notify the user only)

**Step 2: Context-based recommendation** — when Pencil is connected, analyze the work context to pick a recommended option:

| Context signal | Recommendation |
|----------------|----------------|
| UI/screen/layout/design keywords present | Recommend running design implementation |
| Existing .pen files in the project | Recommend running design implementation |
| 50%+ of features.json entries are category:"ui" | Recommend running design implementation |
| Logic/data/API/backend-centric work | Recommend skipping design implementation |
| Refactoring/performance optimization work | Recommend skipping design implementation |

**Step 3: User choice** — confirm via AskUserQuestion:

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

**User choice result:**
- "디자인 구현 진행" → call the harness-design-implementer agent
- "디자인 구현 스킵" → go straight to Phase 3 (BUILD)

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

**Phase 2-B completion handling:**
- Confirm the pending fields in {HARNESS_DIR}/design-spec.md are filled
- Confirm the design fields in {HARNESS_DIR}/features.json are updated
- Proceed to Phase 3 (BUILD) automatically

**Agent failure handling**: report "디자인 구현 실패, architect 산출물만으로 진행합니다" and proceed to Phase 3 (graceful degradation).

### Phase 2.5: BUILD STYLE selection

After Phase 2 and before entering Phase 3, select the build style:

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

Record the choice in `{HARNESS_DIR}/session.json`:

```json
{
  "build_style": "autonomous" | "collaborative" | "user-led",
  "current_round": 1,
  "current_feature_id": null,
  "batch_features": null,
  "phase": "build"
}
```

This file is used to recover state on session interruption/re-entry.

### Phase 3: BUILD

Branch on `build_style`: `"autonomous"` → Phase 3-A, `"collaborative"` → Phase 3-B, `"user-led"` → Phase 3-C.

#### Phase 3-A: Autonomous Build (build_style = "autonomous")

Call the harness-builder agent as before:

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

**Phase 3-A completion check (required):**
After the Builder finishes:
1. Read `{HARNESS_DIR}/features.json` to confirm status changes
2. If pending/failed/partial remain, the Builder only partially completed → report to the user
3. If any `built_unverified` status exists, show an Xcode-MCP-not-connected warning

**Agent failure handling**: If the Builder fails midway, check the current state in {HARNESS_DIR}/features.json and report completed vs. incomplete features to the user.

#### Phase 3-B: Collaborative Build (build_style = "collaborative")

Does not call a subagent; **runs directly in the main conversation**.
Implements feature by feature in dialogue with the user.

**Step 0: Detect build tool**
Detect the build tool with the same fallback chain as the Autonomous Build's Builder:
```
BUILD_TOOL 탐지: Xcode MCP → xcodebuild+xcsift → swift build+xcsift → static
```

**Feature loop:**
Process features with `status=pending|failed|partial` from `{HARNESS_DIR}/features.json` one at a time, in priority order:

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

Step 8 shows progress to the user; keep the features.json state record current so it stays the source of truth for re-entry.

**User role split:**
- If the user says "this part I'll do myself" → **wait + assist** (default). When they finish, Read to confirm, then review/supplement.
- **Parallel work** is possible on request (user: file A, Claude: file B).

**Mode switching (3-way):**
- collaborative → autonomous: on user request, or proposed when many features remain. Delegate remaining features to the harness-builder subagent. Update `session.json` `build_style` to `"autonomous"`.
- collaborative → user-led: switch when the user says "내가 직접 할게" / "가이드만 줘". Update `session.json` `build_style` to `"user-led"`.
- autonomous → collaborative: switchable when, after Evaluator feedback, the user wants to fix things together. Update `session.json` `build_style` to `"collaborative"`.

**Context management:**
- This runs in the main conversation, so watch context accumulation.
- After each feature, summarize the prior feature's implementation detail and keep only the interface info the next feature needs.
- features.json records progress to file, so the current state is recoverable even if compaction happens.

#### Phase 3-C: User-led Collaborative Build (build_style = "user-led")

Does not call a subagent; **runs directly in the main conversation**.
The agent generates per-feature implementation guides **as document files**, and the user writes the code.
The agent acts as a reviewer and does not modify code without user approval, since this is a user-driven mode.

**Core principle — documents are primary, conversation is the approval signal:**

In Phase 3-C, all context transfer (guides, reviews, build errors) is **generated as files** and opened in the editor with `open`.
The chat exchanges only short approval signals (AskUserQuestion).

- **User edits take precedence**: when the user edits a guide/review file, that change carries into later work
- **Artifacts accumulate**: all guides/reviews/build errors stay in HARNESS_DIR for re-entry/retrospective
- **Context savings**: long guides do not pile up in the chat

**File layout:**

```
{HARNESS_DIR}/
├── guides/
│   ├── F001-guide.md              ← Step 2 구현 가이드 (기능별 1개)
│   └── F002-guide.md
├── reviews/
│   ├── F001-review-r1.md          ← Step 4 리뷰 리포트 (라운드별)
│   └── F001-review-r2.md
├── build-errors/
│   ├── F001-build-attempt-1.md    ← Step 5 빌드 실패 리포트 (시도별)
│   └── F001-build-attempt-2.md
└── worst-cases.md                  ← 누적 안티패턴 카탈로그
```

**Step 0: Detect build tool + prepare directories**
Detect the build tool with the same fallback chain as Phase 3-B:
```
BUILD_TOOL 탐지: Xcode MCP → xcodebuild+xcsift → swift build+xcsift → static
```

Also prepare the Phase 3-C file directories:
```bash
mkdir -p {HARNESS_DIR}/guides {HARNESS_DIR}/reviews {HARNESS_DIR}/build-errors
```

If worst-cases.md does not exist, create an empty file; if it exists, Read it to inform later guide generation.

**Feature loop:**
Process features with `status=pending|failed|partial` from `{HARNESS_DIR}/features.json` one at a time, in priority order:

```
for each feature (priority 순서):

  ┌─ Step 1: 기능 시작 기록 ─────────────────────┐
  │ session.json의 current_feature_id를 업데이트  │
  │ → 중단 시 어느 기능에서 멈췄는지 복구 가능    │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 2: 가이드 문서 생성 + open ───────────┐
  │ worst-cases.md Read → 관련 안티패턴 추출      │
  │                                              │
  │ Write: {HARNESS_DIR}/guides/{FID}-guide.md   │
  │ 템플릿: "가이드 파일 템플릿" 섹션 참조       │
  │                                              │
  │ Bash: open {HARNESS_DIR}/guides/{FID}-guide.md│
  │                                              │
  │ 대화 응답 (짧게):                             │
  │ "[FID] 가이드를 열었습니다.                   │
  │  파일을 확인하시고 작업해주세요. 필요하면      │
  │  가이드 내용을 직접 편집하셔도 됩니다."       │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 3: 사용자 작업 대기 + 파일 편집 감지 ──┐
  │ AskUserQuestion:                              │
  │   question: "[FID] 작업 상태를 알려주세요"    │
  │   options:                                    │
  │   - "완료 — 리뷰 진행"                         │
  │   - "질문 있음 — 논의 후 재개"                 │
  │   - "에이전트에게 위임 (부분 위임)"            │
  │   - "N개 먼저 하고 싶음 — 배치 모드"           │
  │                                              │
  │ 사용자가 응답 전에 가이드 파일을 편집하면     │
  │ "완료" 선택 시 Claude가 다음을 수행:         │
  │   1. Read: guides/{FID}-guide.md             │
  │   2. 편집 diff 분석 ("사용자 문서 편집 감지"  │
  │      섹션의 판단 기준 적용)                  │
  │   3. 의미 있는 변경 → Step 4 리뷰/이후 가이드 │
  │      에 반영 + features.json/design-spec.md  │
  │      /harness-spec.md 필요 시 즉시 업데이트  │
  │                                              │
  │ ⚠️ 사용자 응답 전까지 Write/Edit 도구 사용 금지│
  │   (HARNESS_DIR 내 메타파일은 예외)            │
  └──────────────────────────────────────────────┘
       │
       ▼ (사용자: "완료")
  ┌─ Step 4: 리뷰 문서 생성 + open ─────────────┐
  │ git diff로 사용자 변경사항 수집               │
  │ 현재 라운드 번호 N을 session.json에서 읽음    │
  │                                              │
  │ Write: {HARNESS_DIR}/reviews/{FID}-review-  │
  │        r{N}.md                               │
  │ 내용: ✅ 완료 / ⚠️ 누락·개선 / 🐛 잠재 이슈   │
  │       + 수정 제안 (diff 형태)                 │
  │                                              │
  │ Bash: open {HARNESS_DIR}/reviews/{FID}-...   │
  │                                              │
  │ AskUserQuestion:                              │
  │   question: "[FID] 리뷰 리포트 확인 결과"    │
  │   options:                                    │
  │   - "모든 제안 적용 — Claude가 수정"          │
  │   - "일부만 적용 — 번호 알려주세요"            │
  │   - "제안 스킵 — 빌드 검증 바로 진행"         │
  │   - "직접 수정하겠음 — 잠시 대기"              │
  │                                              │
  │ 사용자 승인 시에만 Claude가 코드 수정          │
  │ 리뷰 파일을 사용자가 편집했다면 Read로 반영    │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 5: 빌드 검증 + 상태 기록 + 커밋 ──────┐
  │ BUILD_TOOL로 빌드 검증                        │
  │                                              │
  │ ❌ 빌드 실패 시 (각 시도마다):                 │
  │   attempt 번호 K를 증분                       │
  │   Write: build-errors/{FID}-build-attempt-  │
  │          {K}.md                              │
  │   내용: 에러 요약 + 문제 코드 스냅샷 + 원인   │
  │         분석 + 수정 제안                      │
  │   Bash: open build-errors/{FID}-...          │
  │                                              │
  │   AskUserQuestion:                            │
  │   - "제안대로 수정 — Claude 적용"              │
  │   - "내가 직접 수정하겠음"                     │
  │   - "이 기능 스킵 (failed로 표시)"             │
  │                                              │
  │   수정 후 재빌드 (최대 3회 시도)              │
  │                                              │
  │ ✅ 빌드 성공 시 (이 순서대로 실행):           │
  │   1. git commit: "feat(FID): <설명>"         │
  │   2. features.json status → built            │
  │   3. session.json current_feature_id → null  │
  │   (커밋 후 status 변경 → built=커밋완료 보장) │
  │                                              │
  │ ❌ 빌드 3회 실패 시:                          │
  │   1. features.json status → failed           │
  │   2. 모든 build-errors/{FID}-build-attempt-* │
  │      를 worst-cases.md에 엔트리로 누적        │
  │      (Worst Case 기록 섹션 참조)             │
  │   3. session.json current_feature_id → null  │
  │   4. 사용자에게 스킵/재시도 선택 제시         │
  └──────────────────────────────────────────────┘
       │
       ▼
  ┌─ Step 6: 진행 상황 표시 ─────────────────────┐
  │ | ID   | 기능        | 상태      | 가이드      │
  │ |------|------------|----------|------------│
  │ | F001 | 앱 구조    | ✅ 완료   | ✔ r1 PASS │
  │ | F002 | 설정 화면  | 🔧 진행중 | guides/... │
  │ | F003 | 데이터 모델 | ⏳ 대기   | -          │
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

Step 6 shows progress to the user; keep the features.json state record current as the source of truth for re-entry.

**Guide file template ({HARNESS_DIR}/guides/{FID}-guide.md):**

```markdown
# [FID] 기능명

> 생성: {ISO timestamp}
> 라운드: {current_round}
> 이 문서는 Claude가 생성한 구현 가이드입니다.
> 자유롭게 편집하세요. 편집 내용은 다음 단계(리뷰/빌드)에 반영됩니다.

## 기능 카드

- **설명**: features.json의 description
- **검증 기준**: features.json의 verification
- **의존성**: 의존하는 기능 목록
- **디자인 토큰**: design 필드의 tokens (있으면)

## 구현 가이드

### 생성/수정 파일
- `경로/파일.swift` — 역할 설명

### 구현 패턴
- 사용할 패턴/프레임워크 설명

### 코드 스니펫 예시
```swift
// 핵심 구조의 코드 예시
```

### 디자인 토큰 매핑 (design-spec.md 참조)
- $token → SwiftUI 매핑

### 주의사항
- 구현 시 유의할 점

## 피해야 할 패턴 (worst-cases.md 추출)
{worst-cases.md에서 이 FID 또는 관련 카테고리의 교훈을 추출하여 삽입.
없으면 이 섹션 전체 생략.}

## Evaluator 피드백 (NEED_REVISION 후 재진입 시)
{evaluation-round-{N-1}.md에서 이 FID의 FAIL/PARTIAL 피드백을 삽입.
초회 구현 시 이 섹션 전체 생략.}
```

**Code-modification permission rules:**

When the agent may use Write/Edit in Phase 3-C:

| Condition | Write/Edit allowed |
|-----------|-------------------|
| Meta files inside HARNESS_DIR (session.json, features.json, design-spec.md, harness-spec.md) | ✅ always |
| Artifact files inside HARNESS_DIR (guides/, reviews/, build-errors/, worst-cases.md) | ✅ always |
| Code fix proposed in a review → AskUserQuestion "모든 제안 적용" or "일부 적용" chosen | ✅ after approval |
| Build-error fix → AskUserQuestion "제안대로 수정" chosen | ✅ after approval |
| User delegates "이것도 에이전트가 해줘" | ✅ on delegation |
| Writing code after a guide without a user response | ❌ not allowed — wait for the approval signal |
| Auto-applying review feedback without user approval | ❌ not allowed — approval is required because this is a user-driven mode |
| Self-judged "obvious fix" applied autonomously | ❌ not allowed — confirm first; this is a user-driven mode |

**Worst Case logging (worst-cases.md):**

When a build error marks a feature `failed`, or a serious error repeats during rebuilds, add an entry to `{HARNESS_DIR}/worst-cases.md`. This is the source for the "피해야 할 패턴" section in later guides.

**Entry template:**

```markdown
## [{ISO timestamp}] [{FID}] {에러 한 줄 요약}

**맥락**: 어떤 가이드(guides/{FID}-guide.md)의 어떤 지시를 따랐는가 / 사용자가 어떤 방식으로 구현했는가
**문제 코드**:
```swift
// 실제로 빌드 실패를 유발한 코드 스니펫 (context 10-20줄)
```
**빌드 에러**: `error: ...` (xcsift JSON의 message 필드)
**원인 분석**: 왜 실패했는가 (1-3줄)
**수정**: 어떻게 해결했는가 / 대안 코드 스니펫
**교훈**: 이후 가이드에 반영할 규칙 1줄 (예: "NavigationStack에서 value-based navigation 사용 시 Hashable 준수 필요")
**카테고리**: `ui` / `data` / `logic` / `test` / `config` (features.json의 category와 매칭)
```

**When to log:**
1. When a feature is marked `failed` (3 build failures) — synthesize all build-attempt-*.md into one entry
2. When the same pattern recurs 2+ times across Evaluator NEED_REVISION verdicts (cross-round learning)

**When to reference:**
- During Step 2 guide generation, Read it → extract "교훈" from same-category entries into the "피해야 할 패턴" section
- Not read at new-session start (per-session isolation is the rule), except when the user explicitly requests it

**Detecting and reflecting user document edits:**

When the user edits `guides/{FID}-guide.md` in Step 3, or `reviews/{FID}-review-r{N}.md` in Step 4, Claude reads the file, detects the edits, and reflects them by these principles.

**Reflect (meaningful changes):**
- **File path/structure change**: edit the "생성/수정 파일" section → reflect into the review/build steps and into later related-feature guides
- **Framework/pattern swap**: a core technical-choice change in "구현 패턴" or a code snippet → propagate to every later feature using the same tech
- **Design token/style convention redefinition**: edit "디자인 토큰 매핑" → update design-spec.md (Claude reflects immediately)
- **Verification criteria tightening/loosening**: edit the "검증 기준" section → update verification in features.json (but loosening conflicts with the no-relaxation rule, so re-confirm with the user)
- **New caveat added**: user adds a constraint → propagate into the "주의사항" of later same-category guides
- **Review proposal edited**: if the user edited a review proposal, apply the edited content

**Do not reflect (mere notes):**
- Comments/checkbox marks (`- [x]`, `// TODO`, `<!-- memo -->`)
- Typo fixes, whitespace/formatting changes
- Notes the user wrote in a "thinking" area (outside an explicit section)

**Scope-of-reflection rules:**
- **Only into the current feature's later steps (review/build)**: implementation detail changes confined to one feature
- **Into all later features (update design-spec.md/harness-spec.md + propose regenerating pending features' guides)**:
  - project-wide changes such as design token / framework / architecture choices
  - on detection, confirm with AskUserQuestion: "이 변경을 이후 모든 기능에도 적용할까요?"

**When the call is ambiguous:** use AskUserQuestion to let the user choose the reflection scope. Claude does not modify the global documents (design-spec.md/harness-spec.md) on its own, since those changes affect every feature.

**Partial delegation:**
The user can delegate just specific features to the agent:
- user: "F003은 에이전트가 해줘" → the agent implements only F003 in the Phase 3-B style
- keep `session.json` `build_style` at `"user-led"`
- after F003, the next feature returns to user-led guide mode
- **On re-entry**: if a partially-delegated feature re-enters in `pending` status, the delegation context is lost, so recover into the user-led default flow (generate an implementation guide). The user can request delegation again.

**Batch mode:**
When the user works on several features at once:

1. **Enter**: user explicitly requests "F002, F003, F004 먼저 할게" or "3개 먼저 할게" (also reachable via the Step 3 AskUserQuestion "N개 먼저 하고 싶음"). On entering from the single-feature loop, reset the current feature's `current_feature_id` to `null` (that feature is now part of the batch)
2. **Generate guides**: create `guides/{FID}-guide.md` **individually, N files** (not a single file). Update `session.json`: record the feature ID list in `batch_features`, set `current_feature_id` → `null`
3. **Open all**: `open guides/F002-guide.md guides/F003-guide.md guides/F004-guide.md` to open all guides in the editor at once
4. **Wait**: short chat reply — "N개 기능의 구현 가이드를 모두 열었습니다. 작업 완료 후 알려주세요." + collect a completion signal via AskUserQuestion (options: "모두 완료 — 일괄 리뷰" / "개별 리뷰 원함 — FID 지정" / "추가 논의 필요")
5. **Generate reviews**: classify all changes by feature via `git diff`. For each feature, create `reviews/{FID}-review-r{N}.md` **individually** + `open` all. Apply fix proposals only after AskUserQuestion approval
6. **Build verify**: run the full build once. On failure, create `build-errors/{FID}-build-attempt-{K}.md` per feature + `open` all
7. **Commit**: process feature by feature in sequence — for each: set `current_feature_id` → git commit → `features.json` status → `built` → `current_feature_id` → `null`. Changing status after the commit guarantees `built` = "committed"
8. **Release**: `session.json` `batch_features` → `null`, `current_feature_id` → `null`. Return to single-feature mode

**Batch-mode file edit detection:** if the user edited several guide files in the batch, after the completion signal Read each file to detect "meaningful changes". Process per feature, but for common-rule changes (design tokens/framework, etc.) confirm with AskUserQuestion whether to reflect into all later features.

**Batch + partial delegation combo:** during batch mode the user can say "F004는 에이전트가 짜줘" → the agent implements only F004 in the Phase 3-B style. The user keeps working the remaining batch features. `batch_features` and `build_style` are retained.

**Mode switching (3-way):**
- user-led → autonomous: user "나머지는 자율로", or proposed when remaining features ≥7. Update `session.json` `build_style` to `"autonomous"`.
- user-led → collaborative: user "나머지는 에이전트가 짜줘". Update `session.json` `build_style` to `"collaborative"`.
- autonomous/collaborative → user-led: user "내가 직접 할게" / "가이드만 줘". Update `session.json` `build_style` to `"user-led"`.

**Batch state on mode switch:** if `batch_features` is non-null on a mode switch, clear it to `null`. Features already `built` in the batch are preserved; `pending` features are processed individually in the new mode.

**Context management:**
- This runs in the main conversation, so watch context accumulation.
- After each feature, summarize the prior feature's guide and review and keep only the interface info the next feature needs.
- features.json records progress to file, so the current state is recoverable even if compaction happens.

### Phase 4: EVALUATE

**Update session.json on entering Phase 4:**
```json
{ "phase": "evaluate", "current_round": N, "current_feature_id": null, "batch_features": null }
```

Call the harness-evaluator agent:

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

**Phase 4 result handling + session.json state transition:**

- Verdict **PASS** (80%+ features pass):
  1. `session.json` → `{ "phase": "complete", "current_round": N }`
  2. **Harness complete** — print the final report

- Verdict **NEED_REVISION**:
  1. `session.json` → `{ "phase": "build", "current_round": N+1 }` ← transition to build immediately + increment round
  2. `build_style = "autonomous"` → pass the Evaluator's FAIL/PARTIAL feedback to the Builder → re-run failed/partial features in Phase 3-A
  3. `build_style = "collaborative"` → analyze and fix the FAIL/PARTIAL items together with the user → re-run only failed/partial features in Phase 3-B. At this point the user may request switching to autonomous or user-led.
  4. `build_style = "user-led"` → convert the Evaluator's FAIL/PARTIAL feedback into a **revision guide** and present it → return to Phase 3-C for user-driven fixes. At this point the user may request switching to autonomous or collaborative.

### Loop Control

#### Autonomous mode (runs autonomously)

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

#### Collaborative mode (agent-led)

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

#### User-led mode (user-driven)

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

**User-led specifics on NEED_REVISION:**
- Convert the Evaluator's FAIL/PARTIAL feedback into a **revision guide** and present it
- Format: existing implementation guide + "Evaluator feedback summary + concrete revision points"
- User fixes → review → build verify → next round

Always include when re-entering Phase 3 after NEED_REVISION (the same in every round):
- **autonomous/collaborative**: include in the Builder prompt `{HARNESS_DIR}/evaluation-round-{N-1}.md를 참조하여 FAIL/PARTIAL 항목의 구체적 수정 지침을 확인하세요`
- **user-led**: when generating the revision guide (Step 2), summarize the FAIL/PARTIAL feedback from `{HARNESS_DIR}/evaluation-round-{N-1}.md` into the guide as "Evaluator feedback + concrete revision points". On re-entry, set `current_feature_id` in Step 1 as well.
- Note: Phase 3-B step numbers (9 steps) and Phase 3-C step numbers (7 steps) differ. Refer to each Phase's step definitions.

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

- `verification_steps`: created initially by the Planner, augmented by the Evaluator in Phase 1.5. optional — falls back to the verification text if absent
- `design`: written by the Designer in Phase 2. optional — absent when Pencil is unused
- `scores`: recorded by the Evaluator. optional — compatible with the existing PASS/PARTIAL/FAIL status

**State transitions:**
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

**Invariants:**
- Deleting a feature or relaxing its criteria is **strictly forbidden** — these are the contract the whole loop is judged against
- Only status and priority may be updated
- Keep JSON format (JSON, not markdown — prevents the model from making inappropriate edits)

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

- `build_style`: set in Phase 2.5, updated on mode switch. `"autonomous"` → Phase 3-A, `"collaborative"` → Phase 3-B, `"user-led"` → Phase 3-C
- `current_round`: starts at 1. Increments to N+1 on a NEED_REVISION verdict. **Max: 4** (round 3 + one extra). On re-entry, if `current_round > 4`, force-terminate.
- `current_feature_id`: set at feature start in collaborative/user-led modes, reset to null on completion/failure. Always null in autonomous mode (not managed by the Builder subagent). On re-entry, non-null means that feature was interrupted.
- `batch_features`: in user-led batch mode, the list of pending feature IDs. Cleared to `null` on batch completion. Always `null` outside user-led mode.
- `phase`: uses only the 3 values `build`, `evaluate`, `complete`. In Phase 0~2 session.json does not exist, so `plan`/`verify`/`design` values are not used.

**phase state transition diagram:**
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

**When created:** first created when build_style is chosen in Phase 2.5. It does not exist in earlier phases (0~2) — for Phase 1~2 interruptions, re-entry is detected via the presence of harness-spec.md/features.json.
**When updated:** on phase transitions (build↔evaluate↔complete), feature start/completion, mode switches, and round increment on NEED_REVISION.

## Git Integration

- The Builder commits on each feature completion with a **descriptive commit message**
- Commit format: `feat(F001): <기능 설명>`
- After Evaluator-feedback fixes: `fix(F001): <수정 내용>`
- On harness failure, tell the user the rollback option: "하네스 시작 전 커밋으로 되돌리려면 `git log`에서 시작 커밋을 확인하고 `git reset --hard <commit>`을 실행하세요. **주의: 이 명령은 모든 변경을 삭제합니다.**"

## Context Management

- Each agent runs as an **independent subagent** → natural context isolation
- Inter-agent communication is **file-based** ({HARNESS_DIR}/harness-spec.md, {HARNESS_DIR}/features.json)
- For large projects, the Builder uses auto-compaction
- **Collaborative-mode note**: this runs in the main conversation, so context accumulates. After each feature, summarize the prior feature's implementation detail and keep only the interface info the next feature needs. If 7+ features remain, propose switching to autonomous.

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

1. **Build verification tools**: Xcode MCP gives the richest build feedback. When not connected, fall back to `xcodebuild` CLI + `xcsift` for build verification. SPM projects also support `swift build` + `xcsift`. Only when no build tool is available is a feature marked `built_unverified`. Install xcsift: `brew install xcsift`.

2. **Cost**: 3 rounds × 3 agents = up to 9 agent calls. For simple tasks the existing `apple-craft` implement mode is more efficient.

3. **Runtime verification tools recommended**: for runtime interaction verification, install the `app-automation` plugin (mcp-baepsae). Without it, the harness runs in static verification mode.

4. **Project-creation limit**: creating a new Xcode project (xcodegen, Tuist, etc.) is out of scope for this harness. Its main use is adding features to an existing project.

5. **Self-evaluation limit**: the Evaluator is also an LLM, so it is not perfect QA. A human must review the final result.

6. **Pencil MCP optional**: Phase 2-A (design architecture) always runs even without Pencil, providing Builder/Evaluator with the token mapping and screen structure. Only Phase 2-B (design implementation) requires a Pencil MCP connection. Pencil does not generate SwiftUI code directly, so the Builder performs the design→code conversion.

7. **Collaborative-mode context**: collaborative mode runs in the main conversation, so projects with many features consume the context window quickly. For projects with 10+ features, prefer autonomous mode, or run only core features in collaborative and switch the rest to autonomous.

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
│   └─ [user-led collaborative] 메인 대화에서 직접 실행 (문서 기반 소통)
│       ├─ Step 0: 빌드 도구 탐지 + guides/reviews/build-errors 디렉토리 준비
│       ├─ 기능별 파일 플로우:
│       │   Step 2: guides/{FID}-guide.md 생성 + open (worst-cases.md 참조)
│       │   Step 3: AskUserQuestion 대기 + 가이드 파일 편집 감지
│       │   Step 4: reviews/{FID}-review-r{N}.md 생성 + open + AskUserQuestion
│       │   Step 5: 실패 시 build-errors/{FID}-build-attempt-{K}.md 생성 + open
│       │           3회 실패 시 worst-cases.md에 엔트리 누적
│       ├─ 사용자 파일 편집 반영: 의미 있는 변경 감지 → 이후 단계/기능에 전파
│       ├─ 사용자 승인 없이 코드 수정 금지
│       ├─ 배치 모드 지원 (batch_features, 개별 가이드 파일 N개 일괄 open)
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

To see the full course of an actual harness run, read the reference doc:

```
Read: ${CLAUDE_PLUGIN_ROOT}/skills/apple-harness/references/walkthrough-liquid-glass-settings.md
```

This walkthrough shows the full Phase 1→1.5→3→4 course of "Liquid Glass 설정 화면 구현"
(a scenario where Phase 2 DESIGN was auto-skipped due to no Pencil MCP connection):
- {HARNESS_DIR}/harness-spec.md and {HARNESS_DIR}/features.json examples (10 features)
- the Evaluator's 4-axis multidimensional verification results
- the actual flow of passing 80% in round 1
