# apple-craft v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** apple-craft를 "Xcode 26 API 가이드"에서 "Apple 플랫폼 통합 개발 어시스턴트"로 확장하여, 모든 Swift/Xcode 프로젝트에서 활성화되도록 한다.

**Architecture:** 2계층 구조 — Layer 1(범용 Apple 개발 어시스턴트)이 모든 작업을 처리하고, Layer 2(Xcode 26 참조 문서 20개)는 키워드 매칭 시에만 Just-in-Time 로드되는 보너스 지식.

**Tech Stack:** Claude Code Plugin (SKILL.md, plugin.json), Markdown

**Worktree:** `/Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2`

**Plugin base:** `plugins/apple-craft/`

---

### Task 1: SKILL.md Frontmatter 재작성

**Files:**
- Modify: `plugins/apple-craft/skills/apple-craft/SKILL.md:1-24` (frontmatter)

- [ ] **Step 1: description 필드 변경**

기존 description을 범용 Apple 개발 어시스턴트로 재작성합니다. `argument-hint`와 `allowed-tools`는 그대로 유지합니다.

```yaml
---
name: apple-craft
description: Apple 플랫폼 통합 개발 어시스턴트 — Swift, SwiftUI, UIKit, AppKit, Xcode 빌드/프리뷰/디버깅, 코드 작성/리뷰/리팩토링, Xcode MCP 연동. Xcode 26 최신 API 참조 문서 내장 (Liquid Glass, FoundationModels, Swift 6.2 등 20개 주제). iOS, macOS, watchOS, visionOS. swift, swiftui, uikit, appkit, xcode, 빌드, 프리뷰, 코드 리뷰, 리팩토링, 아키텍처, 디버깅, SPM, CocoaPods, xcodeproj, swift concurrency, combine, swiftdata, coredata, objective-c, swift package, 테스트, unit test, 시뮬레이터, instruments, 성능, 메모리, 앱 개발, Apple 플랫폼 코딩, iOS 26, macOS 26, WWDC, 최신 API, 새 프레임워크.
argument-hint: "[topic, question, or task]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Write
  - Edit
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
```

Edit 도구로 frontmatter 전체를 교체합니다.

- [ ] **Step 2: examples 업데이트**

기존 5개 예시를 유지하되, **일반 Swift/Xcode 작업 예시 3개를 추가**합니다. 기존 예시 블록 바로 아래에 추가:

```markdown
<example>
user: "이 SwiftUI 뷰에서 리스트 성능이 느린데 개선해줘"
assistant: "troubleshoot 모드로 프로젝트 코드를 분석하고, LazyVStack 전환 및 id 최적화를 적용하겠습니다."
</example>

<example>
user: "MVVM 패턴으로 네트워크 레이어 리팩토링해줘"
assistant: "implement 모드로 프로젝트 구조를 파악하고, async/await 기반 네트워크 레이어를 MVVM으로 리팩토링하겠습니다."
</example>

<example>
user: "Swift Testing으로 기존 XCTest를 마이그레이션하고 싶어"
assistant: "implement 모드로 기존 테스트 파일을 분석하고, @Test와 #expect 기반으로 마이그레이션 코드를 작성하겠습니다."
</example>
```

- [ ] **Step 3: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add plugins/apple-craft/skills/apple-craft/SKILL.md
git commit -m "refactor(apple-craft): broaden SKILL.md frontmatter and examples

Expand description from 'Xcode 26 API guide' to 'Apple platform
integrated development assistant'. Add general Swift/Xcode examples.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: SKILL.md 본문 — 헤더 및 Core Workflow 신규 섹션

**Files:**
- Modify: `plugins/apple-craft/skills/apple-craft/SKILL.md:51-77` (헤더 + Mode Selection)

- [ ] **Step 1: 스킬 헤더 변경**

기존 헤더:
```markdown
# apple-craft

Xcode 26 번들 문서(20개 주제, ~6,300줄) 기반 Apple 플랫폼 통합 개발 어시스턴트.
```

변경:
```markdown
# apple-craft

Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit/AppKit 코드 작성·리뷰·디버깅 + Xcode MCP 연동.
Xcode 26 참조 문서(20개 주제) 내장으로 최신 API도 정확하게 지원합니다.
```

- [ ] **Step 2: Mode Selection 테이블 설명 확장**

기존 모드 테이블의 **설명 열**을 범용으로 수정합니다:

```markdown
## Mode Selection

사용자 메시지를 분석하여 아래 모드 중 하나를 선택합니다.

| 모드 | 키워드 | 설명 |
|------|--------|------|
| **implement** | 만들어, 작성, 적용, 구현, 추가, 코드, 리팩토링, 마이그레이션, build, create, add, apply, refactor | 코드 작성 + 빌드 검증. 참조 문서 매칭 시 최신 API 활용 |
| **explore** | 알려줘, 설명, 뭐가 바뀌었어, 차이, 어떻게, 비교, 추천, what, how, explain, diff, compare | API/코드 설명 + 코드 예시. `DocumentationSearch`로 공식 문서 검색 |
| **troubleshoot** | 에러, 오류, 안돼, 크래시, 빌드 실패, 느려, 성능, 메모리, error, crash, fix, debug, slow | 빌드 로그/코드 분석 + 수정. `GetBuildLog`, `XcodeListNavigatorIssues` 활용 |
| **harness** | 처음부터, 전체, 기능 개발, 대규모, 리팩토링, harness | → `apple-craft-harness` 스킬로 전환 |

**자동 선택**: 키워드가 불명확하면 사용자 의도를 추론합니다. 코드 파일이 언급되면 implement, 질문형이면 explore, 에러 메시지가 포함되면 troubleshoot.
```

- [ ] **Step 3: Core Workflow 신규 섹션 삽입**

Mode Selection과 Document Routing Table 사이에 새 섹션을 삽입합니다:

```markdown
---

## Core Workflow

모든 모드에 공통으로 적용되는 워크플로우입니다. 참조 문서 매칭 여부와 관계없이 모든 Apple 플랫폼 작업에 적용합니다.

### Phase 0: 프로젝트 컨텍스트 파악

1. Glob으로 프로젝트 구조 파악 (`*.xcodeproj`, `Package.swift`, `Podfile`, `*.swift`)
2. 대상 플랫폼 및 최소 배포 타겟 확인
3. 기존 코드 패턴/아키텍처 파악 (MVVM, TCA, Clean Architecture 등)
4. CLAUDE.md / CONTEXT.md가 있으면 프로젝트 규칙 확인

### Xcode MCP 도구 활용 전략

Xcode MCP 서버가 연결되어 있으면 적극 활용합니다. 미연결 시에도 일반 도구(Bash, Read, Grep 등)로 대응합니다.

| 목적 | 도구 | 언제 사용 |
|------|------|----------|
| 빠른 코드 진단 | `XcodeRefreshCodeIssuesInFile` | 코드 수정 후 즉시 (2초 이내) |
| 전체 빌드 | `BuildProject` + `GetBuildLog` | 변경 완료 후 검증 |
| UI 확인 | `RenderPreview` | SwiftUI 뷰 수정 시 |
| API 검색 | `DocumentationSearch` | 모르는 API, 시그니처 확인 |
| 코드 실행 | `ExecuteSnippet` | 동작 확인, 로직 검증 |
| 에러 목록 | `XcodeListNavigatorIssues` | troubleshoot 시작 시 |

### 참조 문서 자동 로드 조건

- 사용자 쿼리 키워드가 아래 Document Routing Table과 **매칭되면** → Read로 참조 문서를 로드하여 최신 API 정보 제공
- **매칭되지 않으면** → 참조 문서 없이 일반 Swift/Apple 프레임워크 지식 + Xcode MCP 도구로 대응
- 코드 스타일은 `reference/code-style.md`를 참조
- 흔한 실수 방지는 `reference/common-mistakes.md`를 참조
```

- [ ] **Step 4: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add plugins/apple-craft/skills/apple-craft/SKILL.md
git commit -m "refactor(apple-craft): add Core Workflow and expand Mode Selection

Add Phase 0 (project context), Xcode MCP tool strategy, and
reference doc auto-load conditions as shared workflow for all modes.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 3: SKILL.md 본문 — 모드별 확장

**Files:**
- Modify: `plugins/apple-craft/skills/apple-craft/SKILL.md:121-194` (3개 모드 섹션)

- [ ] **Step 1: implement 모드 확장**

기존 implement 모드를 범용 코드 작성으로 확장합니다:

```markdown
## Mode: implement

Swift/Xcode 프로젝트에서 코드를 작성하거나 수정할 때 사용합니다.

### Phase 1: 컨텍스트 수집
1. Core Workflow의 Phase 0 실행
2. Document Routing Table에서 키워드 매칭 → 매칭 시 관련 참조 파일을 Read
3. 사용자 프로젝트의 기존 코드 파악 (Grep/Glob으로 관련 파일 검색)

### Phase 2: 코드 작성
1. 매칭된 참조 문서가 있으면 코드 예시를 기반으로 작성, 없으면 일반 Swift 지식으로 작성
2. Write/Edit 도구로 파일에 적용
3. 코드 스타일은 `reference/code-style.md`를 Read하여 참조
4. 참조 문서 매칭 시 `reference/common-mistakes.md`를 Read하여 흔한 실수 방지

### Phase 3: 빌드 검증 (Xcode MCP 연결 시)
1. `mcp__xcode__XcodeRefreshCodeIssuesInFile`로 빠른 진단 (1순위)
2. 필요 시 `mcp__xcode__BuildProject`로 전체 빌드
3. 에러 발생 시 → `mcp__xcode__GetBuildLog`로 로그 확인 → 수정 → 재빌드

### Phase 4: 시각적 검증 (UI 관련 시)
1. `mcp__xcode__RenderPreview`로 SwiftUI 프리뷰 확인
2. Liquid Glass, Charts 3D, Toolbar 등 시각적 기능은 프리뷰 검증 필수

응답 형식은 `reference/response-templates.md`를 참조하세요.
```

- [ ] **Step 2: explore 모드 확장**

```markdown
## Mode: explore

Apple 프레임워크 API 설명, 변경 사항 비교, 사용법 안내를 할 때 사용합니다.

### Phase 1: 문서 조회
1. Document Routing Table에서 키워드 매칭 → 매칭 시 관련 참조 파일을 Read
2. `mcp__xcode__DocumentationSearch`로 공식 문서 검색 (매칭 여부와 무관하게 활용)
3. 사용자 프로젝트의 관련 코드가 있으면 Grep/Glob으로 파악

### Phase 2: 구조화된 설명
1. Apple DocC 패턴(Summary → Overview → Code Example → Details)으로 구성
2. 핵심 API 타입/메서드를 코드 블록으로 제시
3. Before/After 비교가 필요하면 두 코드 블록을 순서대로 제시

### Phase 3: 실행 확인 (선택)
1. `mcp__xcode__ExecuteSnippet`으로 API 동작 확인 가능
2. 사용자가 원하면 실행 결과를 보여줌

응답 형식은 `reference/response-templates.md`를 참조하세요.
```

- [ ] **Step 3: troubleshoot 모드 확장**

```markdown
## Mode: troubleshoot

빌드 에러, 런타임 크래시, 성능 이슈, API 사용 오류를 해결할 때 사용합니다.

### Phase 1: 에러 수집
1. `mcp__xcode__GetBuildLog` 또는 `mcp__xcode__XcodeListNavigatorIssues`로 에러 확인
2. Xcode MCP 미연결 시 사용자가 제공한 에러 메시지/로그를 분석
3. 에러 메시지에서 관련 API/프레임워크 식별

### Phase 2: 원인 분석
1. Document Routing Table에서 키워드 매칭 → 매칭 시 참조 파일 검색
2. 매칭 시 `reference/common-mistakes.md`를 Read하여 알려진 패턴 확인
3. 매칭 없으면 일반 Swift/Xcode 디버깅 지식으로 원인 분석
4. 사용자 코드와 올바른 패턴 비교

### Phase 3: 수정 적용
1. Before(현재 에러 코드) / After(수정 코드) 형태로 변경 제안
2. Edit 도구로 수정 적용
3. 매칭된 참조 문서가 있으면 수정 근거를 인용

### Phase 4: 재검증
1. `mcp__xcode__XcodeRefreshCodeIssuesInFile`로 빠른 진단
2. 필요 시 `mcp__xcode__BuildProject`로 재빌드
3. 에러 해소 및 추가 경고 없는지 확인

응답 형식은 `reference/response-templates.md`를 참조하세요.
```

- [ ] **Step 4: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add plugins/apple-craft/skills/apple-craft/SKILL.md
git commit -m "refactor(apple-craft): expand implement/explore/troubleshoot modes

Each mode now handles all Swift/Xcode tasks as primary workflow,
with reference docs as bonus when keywords match routing table.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: SKILL.md 본문 — Rules 및 한계사항 업데이트

**Files:**
- Modify: `plugins/apple-craft/skills/apple-craft/SKILL.md:197-216` (Rules + 한계사항)

- [ ] **Step 1: Rules 확장**

기존 Rules에 범용 규칙을 추가합니다:

```markdown
## Rules

- 한국어로 응답하되, 코드와 API명은 원문 유지
- **모든 Apple 플랫폼 Swift/Xcode 작업**을 지원 (참조 문서 매칭과 무관)
- 참조 문서가 매칭되면 해당 정보를 학습 데이터보다 **항상** 우선
- 참조 문서 인용 시 **출처 파일명** 반드시 명시
- 플랫폼을 공식 명칭으로 표기 (iOS, iPadOS, macOS, watchOS, visionOS)
- Swift Concurrency(async/await) 우선, Combine 지양
- 테스트는 Swift Testing 프레임워크 (`@Test`, `#expect`) 사용
- 프리뷰는 `#Preview` 매크로 사용
- Force unwrap 금지, 강한 타입 시스템 활용
- 프로젝트의 기존 패턴과 코드 스타일을 존중 — 프로젝트 컨벤션이 있으면 우선
- Xcode MCP 도구가 사용 가능하면 **적극 활용** (빌드, 프리뷰, 문서 검색)
```

- [ ] **Step 2: 한계사항 업데이트**

```markdown
## 한계 및 주의사항

1. **참조 문서 범위**: 20개 참조 문서는 Xcode 26.4 시점의 특정 주제만 다룹니다. 참조 문서에 없는 프레임워크/API도 일반 지식과 `DocumentationSearch`로 지원합니다.
2. **베타 API 변동**: 참조 문서의 코드가 컴파일되지 않으면 `mcp__xcode__DocumentationSearch`로 최신 시그니처를 확인하세요.
3. **컨텍스트 관리**: 참조 문서는 200-800줄입니다. 복합 주제에서 3개 이상을 동시에 로드하면 컨텍스트가 커지므로 가장 관련도 높은 1-2개를 우선 로드하세요.
4. **Xcode MCP 미연결**: Xcode MCP 서버가 없으면 빌드 검증, 프리뷰를 사용할 수 없습니다. 일반 도구(Bash, Read 등)로 가능한 범위까지 지원하되, "Xcode에서 빌드하여 검증해주세요"라고 안내하세요.
```

- [ ] **Step 3: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add plugins/apple-craft/skills/apple-craft/SKILL.md
git commit -m "refactor(apple-craft): update Rules and limitations for broader scope

Add general Apple platform rules, emphasize Xcode MCP tool usage,
and clarify that reference docs cover specific topics not all APIs.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 5: plugin.json 및 README.md 업데이트

**Files:**
- Modify: `plugins/apple-craft/.claude-plugin/plugin.json`
- Modify: `plugins/apple-craft/README.md`

- [ ] **Step 1: plugin.json 수정**

```json
{
  "name": "apple-craft",
  "description": "Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit 코드 작성·리뷰·디버깅 + Xcode MCP 연동 + Xcode 26 최신 API 참조 문서 20개 내장",
  "author": { "name": "oozoofrog" },
  "version": "1.3.0"
}
```

- [ ] **Step 2: README.md 업데이트**

헤더와 설명을 범용 어시스턴트에 맞게 수정합니다:

```markdown
# apple-craft

Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit/AppKit 코드 작성·리뷰·디버깅 + Xcode MCP 연동.

Xcode 26 번들 문서 기반 최신 API 참조 문서 20개 내장.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **코드 작성** | Swift/SwiftUI/UIKit/AppKit 코드 작성, 리팩토링, 마이그레이션 |
| **빌드 & 디버깅** | Xcode MCP 연동으로 빌드, 프리뷰, 에러 진단 |
| **API 탐색** | DocumentationSearch + 20개 최신 API 참조 문서 |
| **코드 리뷰** | 코드 스타일, 아키텍처, 성능 검토 |
| **Harness 모드** | Plan→Build→Evaluate 에이전트 루프로 장기 개발 자동화 |

## 내장 참조 문서 (20개)

| Category | Topics |
|----------|--------|
| **Design** | Liquid Glass (SwiftUI, UIKit, AppKit, WidgetKit) |
| **AI** | FoundationModels (on-device LLM), Visual Intelligence, AppIntents |
| **Swift** | Swift 6.2 Concurrency, InlineArray & Span |
| **Data** | SwiftData Class Inheritance, AttributedString Updates |
| **UI** | WebKit+SwiftUI, Toolbar Features, Styled Text Editing, AlarmKit |
| **Commerce** | StoreKit Updates |
| **Maps** | MapKit GeoToolbox & PlaceDescriptors |
| **Charts** | Swift Charts 3D Visualization |
| **Accessibility** | Assistive Access |
| **Spatial** | visionOS Widgets |

## 사용법

### 일반 개발 작업
- "이 SwiftUI 뷰 성능 개선해줘" → troubleshoot 모드
- "MVVM으로 네트워크 레이어 리팩토링" → implement 모드
- "async/await 사용법 알려줘" → explore 모드

### 최신 API 작업
- "Liquid Glass 적용 방법 알려줘" → explore 모드 + 참조 문서 로드
- "FoundationModels로 세션 만드는 코드" → implement 모드 + 참조 문서 로드

### 장기 개발 작업 (Harness 모드)
- "처음부터 Liquid Glass 설정 화면 만들어줘" → harness 모드
- "전체 UI를 Liquid Glass로 리팩토링해줘" → harness 모드

## Harness Mode

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) V2 패턴 기반.

| Agent | Role | Color |
|-------|------|-------|
| `harness-planner` | 제품 스펙 + JSON 기능 목록 생성 | 🔵 |
| `harness-builder` | Swift 코드 작성 + Xcode 빌드 + Git 커밋 | 🟢 |
| `harness-evaluator` | 회의적 QA 검증 (PASS/PARTIAL/FAIL) | 🔴 |

```
Plan(스펙) → Build(코드+빌드) → Evaluate(검증) → 최대 3 라운드
```

## 문서 동기화

Xcode 업데이트 후 참조 문서를 갱신합니다:

```bash
zsh plugins/apple-craft/scripts/sync-docs.sh
```

| Option | Description |
|--------|-------------|
| `--xcode-path PATH` | Xcode.app 경로 직접 지정 |
| `--diff-only` | 변경 사항만 확인 |
| `--force` | 강제 복사 |
```

- [ ] **Step 3: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add plugins/apple-craft/.claude-plugin/plugin.json plugins/apple-craft/README.md
git commit -m "refactor(apple-craft): update plugin.json and README for v1.3.0

Bump version to 1.3.0 with broadened description and updated README
reflecting the integrated development assistant identity.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 6: marketplace.json 버전 범프

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: marketplace.json 확인 및 수정**

marketplace.json에서 apple-craft 항목의 버전을 `1.3.0`으로 범프하고, marketplace 전체 버전도 범프합니다.

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
cat .claude-plugin/marketplace.json
```

apple-craft의 `version` 필드를 `1.3.0`으로, marketplace `version`을 다음 마이너 버전으로 수정합니다.

- [ ] **Step 2: 커밋**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git add .claude-plugin/marketplace.json
git commit -m "chore: bump apple-craft to 1.3.0 in marketplace

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

### Task 7: 검증

- [ ] **Step 1: SKILL.md 전체 읽기로 구조 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
cat plugins/apple-craft/skills/apple-craft/SKILL.md | head -5
# description 첫 줄이 "Apple 플랫폼 통합 개발 어시스턴트"로 시작하는지 확인
```

- [ ] **Step 2: description에 범용 키워드 포함 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
grep -c "swift\|xcode\|빌드\|코드 리뷰\|리팩토링\|디버깅" plugins/apple-craft/skills/apple-craft/SKILL.md
# 최소 10개 이상 매칭 예상
```

- [ ] **Step 3: 기존 Document Routing Table 보존 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
grep -c "references/" plugins/apple-craft/skills/apple-craft/SKILL.md
# 20개 참조 파일이 모두 라우팅 테이블에 존재하는지 확인 (20 이상)
```

- [ ] **Step 4: harness 모드 전환 로직 보존 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
grep "apple-craft-harness" plugins/apple-craft/skills/apple-craft/SKILL.md
# "apple-craft-harness 스킬로 전환" 텍스트가 존재해야 함
```

- [ ] **Step 5: plugin.json 버전 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
cat plugins/apple-craft/.claude-plugin/plugin.json
# version: "1.3.0", description이 "통합 개발 어시스턴트"로 시작해야 함
```

- [ ] **Step 6: 전체 diff 확인**

```bash
cd /Users/jaychoi/develop/tools/oozoofrog-plugins/.worktrees/feature/apple-craft-v2
git diff main...HEAD --stat
```
