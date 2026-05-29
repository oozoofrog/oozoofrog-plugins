---
name: design-craft
description: "Multi-platform design generation — produce platform-optimized design specs and token mappings for iOS/Web/Android. '디자인 만들어', '디자인 스펙', 'UI 설계', '화면 디자인', '디자인 시스템', '디자인 토큰 적용' 요청 시 사용. 특정 플랫폼만 요청해도 사용 (예: 'iOS 디자인', '웹 디자인', '안드로이드 디자인')."
model: opus
argument-hint: "[<target> --platform ios|web|android|all --style <designer-name>]"
---

<example>
user: "로그인 화면 디자인 스펙 만들어줘"
assistant: "design-craft 모드로 전체 플랫폼(iOS/Web/Android) 로그인 화면 디자인 스펙을 생성합니다. references/ 토큰을 참조하여 플랫폼별 디자이너 팀을 구성합니다."
</example>

<example>
user: "iOS 설정 화면을 Dieter Rams 스타일로 디자인해줘"
assistant: "design-craft --platform ios --style dieter-rams 모드로 Rams 토큰을 우선 적용한 iOS 설정 화면 스펙을 생성합니다."
</example>

<example>
user: "웹 대시보드 디자인을 Mondrian 스타일로 만들어줘"
assistant: "design-craft --platform web --style mondrian 모드로 Mondrian 직교 그리드 + 3원색 토큰을 적용한 웹 대시보드 스펙을 생성합니다."
</example>

# design-craft

Multi-platform design orchestrator — generates platform-optimized design specs for iOS/Web/Android based on the quantitative tokens produced by the research team.

Respond to the user in Korean.

## Reference base path

Reference path shared with the design-research skill. Abbreviated as `$REF`:

```
$REF = plugins/design-craft/skills/design-craft/references
```

## Platform designer team

| Agent | Role | Invocation condition |
|----------|------|----------|
| ios-designer | Generate Apple HIG + SwiftUI/UIKit spec | --platform ios or all |
| web-designer | Generate WCAG + responsive CSS/HTML spec | --platform web or all |
| android-designer | Generate M3 + Jetpack Compose spec | --platform android or all |
| design-qa | Cross-platform consistency + token value verification | Always included |

## Workflow

### Phase 0: Pre-checks

Run these checks before generating any design.

#### 1. Verify the token dictionary exists
Check whether a token dictionary exists under `$REF/`:
- whether `$REF/tokens/unified-tokens.md` exists
- whether `$REF/designers/` contains at least one file

**If the token dictionary is missing**, show the user this message and stop. Do not generate a design without tokens, since the platform specs depend on those token values.
```
"디자인 토큰 레퍼런스가 없습니다.
design-research 스킬을 먼저 실행하여 디자이너/화가 토큰을 생성하세요.
예: /design-research Dieter Rams, Jony Ive"
```

#### 2. Parse parameters

| Parameter | Default | Description |
|----------|--------|------|
| --platform | all | Choose one of ios, web, android, all |
| --style | (none) | Apply a specific designer/artist style first |

**--platform parsing rules:**
- "iOS 디자인" → `--platform ios`
- "웹 디자인", "반응형 디자인" → `--platform web`
- "안드로이드 디자인", "Material 디자인" → `--platform android`
- no platform specified → `--platform all`

**--style parsing rules:**
- "Rams 스타일로" → `--style dieter-rams`
- "Mondrian 느낌으로" → `--style mondrian`
- no style specified → reference all available tokens evenly

#### 3. Verify the --style token exists
If --style is given, check that the designer/artist token file exists under `$REF/designers/` or `$REF/artists/`. If it is missing, point the user to run design-research.

### Phase 1: Requirements analysis

Determine the following from the user's input:

1. **Design target**: which screen/component/feature
2. **Design purpose**: new design / redesign / design system extension
3. **Constraints**: compatibility with the existing design system, brand guidelines, accessibility requirements
4. **Priorities**: balance of aesthetics vs usability vs accessibility

Ask the user about anything unclear. Batch all questions into a single round rather than asking across multiple turns.

### Phase 2: Team setup

Use TeamCreate to assemble the needed platform designers + QA. Use model: "opus" for all agent calls.

**Team composition per --platform:**

| --platform | Team members |
|------------|------|
| ios | ios-designer + design-qa |
| web | web-designer + design-qa |
| android | android-designer + design-qa |
| all | ios-designer + web-designer + android-designer + design-qa |

```
TeamCreate:
  team_name: "design-craft-team"
  agents: [list of required agents] (model: opus)
```

### Phase 3: Design generation — parallel execution

Assign work to each platform designer with TaskCreate. Run the platform designers in parallel.

#### Information to pass to each designer
Send the following via SendMessage:

1. **Design brief**: the target/purpose/constraints from Phase 1
2. **Reference token paths**: `$REF/designers/{name}.md`, `$REF/artists/{name}.md`
3. **When --style is set**: instruction to apply the given designer/artist tokens first
4. **Unified token path**: `$REF/tokens/unified-tokens.md`

#### Each designer's output
- `_workspace/phase3_{agent}_{component}.md` — platform-specific design spec
- token mapping table (source token → platform implementation value)
- color palette (Light/Dark mode)
- spacing/layout values
- interaction spec
- implementation hints (SwiftUI / CSS / Compose)

**Completion check**: proceed to the next Phase once each designer reports completion to the orchestrator via SendMessage.

### Phase 4: QA verification

Once all platform designer specs are complete, assign the verification task to design-qa with TaskCreate.

#### Information to pass to design-qa
Send the following via SendMessage:

1. each platform designer's spec file path
2. the research team's source token file paths
3. verification requirements (accessibility criteria, cross-platform consistency criteria)

#### design-qa verification items
1. **Accessibility check**: contrast ratio, touch target size, minimum font size
2. **Match against source tokens**: whether the platform spec values match the research team tokens
3. **Cross-platform consistency**: visual equivalence of shared tokens + appropriateness of platform-specific choices
4. **Spacing grid compliance**: whether every spacing value is a multiple of 4

#### Handling verification results

**PASS**: proceed to Phase 5
**NEED_REVISION**:
1. Send FAIL items to the relevant platform designer via SendMessage
2. The designer revises, then requests re-verification from design-qa
3. Up to 3 revise-reverify loops. Escalate to the user if it exceeds 3.

### Phase 5: Output

After QA PASS, organize the final artifacts and present them to the user.

#### Artifact structure

**Intermediate artifacts** (kept):
```
_workspace/
├── phase3_ios-designer_{component}.md
├── phase3_web-designer_{component}.md
├── phase3_android-designer_{component}.md
└── phase4_design-qa_report.md
```

**Final output** (presented to the user):

Output each platform's design spec as markdown. Include:

1. **토큰 매핑 테이블**: 원본 토큰 → 플랫폼별 구현값
2. **컴포넌트 구조**: View 계층 트리 + 각 노드별 적용 토큰
3. **색상 팔레트**: Light/Dark 모드 대응 쌍 + contrast ratio
4. **간격/레이아웃**: 그리드 기반 수치 + safe area/breakpoint 대응
5. **인터랙션**: 터치 타겟, 제스처, 애니메이션 duration
6. **구현 힌트**: 핵심 API/modifier/class 참조

Also output a **QA report summary**:
- 접근성 판정 (PASS/FAIL per platform)
- 교차 플랫폼 일관성 판정
- 토큰 원본 일치율

## Data transfer protocol

### File-based (_workspace/)
- intermediate artifacts: `_workspace/{phase}_{agent}_{artifact}.md`
- each agent creates files and shares the paths via SendMessage

### Message-based (SendMessage)
- orchestrator → designer: design brief + token paths
- designer → orchestrator: completion report + spec file path
- orchestrator → design-qa: verification request + all spec file paths
- design-qa → orchestrator: QA report
- design-qa → designer: FAIL items + revision instructions (on NEED_REVISION)

## Error handling

| Situation | Response |
|------|------|
| references/ tokens missing | Stop design-craft and direct the user to run the design-research skill |
| --style designer token missing | Inform the user that the designer token is missing. Suggest running design-research |
| Platform designer unresponsive | Check status with TaskGet. Reassign if unresponsive |
| QA FAILs 3 times in a row | Root cause analysis + escalate to the user |
| Token source mismatch found | Assume the research team source is correct and correct the platform spec |
| Cross-platform shared token conflict | design-qa presents both rationales, and the orchestrator delegates the decision to the user |
| Unrecognized --platform value | Show "지원 플랫폼: ios, web, android, all" and request re-input |

## Test scenarios

### Normal scenario: "iOS login screen, Dieter Rams style"
1. User: "iOS 로그인 화면을 Rams 스타일로 디자인해줘"
2. Phase 0: confirm `$REF/designers/dieter-rams.md` exists → OK. Parse --platform ios, --style dieter-rams
3. Phase 1: target=login screen, purpose=new, constraint=follow Rams principles
4. Phase 2: assemble ios-designer + design-qa team
5. Phase 3: ios-designer generates the iOS login spec applying Rams tokens first
   - spacing-base: 8pt, corner-radius: 8pt (Rams minimal), contrast: 4.5:1+
6. Phase 4: design-qa verifies → accessibility PASS, token match 100%, cross-platform consistency N/A (single platform)
7. Phase 5: output the iOS login design spec + token mapping table

### Error scenario: "design request without tokens"
1. User: "대시보드 디자인 스펙 만들어줘"
2. Phase 0: confirm `$REF/tokens/unified-tokens.md` does not exist
3. Stop immediately:
   ```
   "디자인 토큰 레퍼런스가 없습니다.
   design-research 스킬을 먼저 실행하여 디자이너/화가 토큰을 생성하세요.
   예: /design-research Dieter Rams, Jony Ive"
   ```
4. Halt the design-craft workflow. Tell the user to run design-research and retry.
