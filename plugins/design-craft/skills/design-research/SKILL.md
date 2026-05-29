---
name: design-research
description: "Design research orchestrator — study famous designers/artists and codify their design traits into quantitative tokens. Use for '디자인 리서치', '디자이너 연구', '디자인 토큰 생성', '화가 분석', '디자인 시스템 구축' requests. Auto-triggers before the design-craft skill when no reference exists."
model: opus
---

<example>
user: "Dieter Rams와 Jony Ive의 디자인 원칙을 정량적 토큰으로 정리해줘"
assistant: "design-research 모드로 리서치 팀 4명을 구성합니다. design-historian + art-aesthetics가 병렬 연구 → token-architect 통합 → verification-scientist 검증 순서로 진행합니다."
</example>

<example>
user: "Mondrian과 Rothko의 시각 언어를 UI에 적용할 수 있게 토큰화해줘"
assistant: "design-research 모드로 art-aesthetics가 두 화가의 색상/구성/공간 토큰을 추출하고, design-historian이 관련 디자이너 영향 관계를 병렬 조사합니다."
</example>

<example>
user: "디자인 시스템에 사용할 레퍼런스 토큰을 만들어줘"
assistant: "design-research 모드로 디자이너/화가 범위를 먼저 확인한 뒤, 리서치 팀을 구성하여 정량적 토큰 사전을 생성합니다."
</example>

# design-research

A research orchestrator that studies the design traits of famous designers/artists and codifies them into quantitative tokens.
Run this skill first: without design tokens the design-craft skill has nothing to operate on.

Respond to the user in Korean.

## Output base path

Store all output in the design-craft skill's references directory. Abbreviate this path as `$REF`:

```
$REF = plugins/design-craft/skills/design-craft/references
```

This skill and the design-craft skill must reference the same path for the harness to work. Use the `$REF`-based path rather than a relative path (`references/`), since the two skills resolve from different working directories.

## Research team

| Agent | Role | Phase |
|----------|------|------|
| design-historian | Extract UI/UX designer principles + quantitative figures | Fan-out (parallel) |
| art-aesthetics | Extract painter/artist visual-language tokens | Fan-out (parallel) |
| token-architect | Merge collected tokens + normalize schema + platform mapping | Fan-in (integration) |
| verification-scientist | Source validation + numeric accuracy + hypothesis report | Verification |

## Workflow

### Phase 1: Determine research scope

Confirm the following with the user:

1. **Subjects**: specific designer/artist names, or "전체" (all) — see the agent files for the default list
2. **Focus domain**: typography, color, layout, all, etc.
3. **Use case**: which project/app this will be applied to

If the user names clear subjects, proceed directly without further questions.
If they specify "전체" (all), proceed with the default list (P0 + P1 designers/artists).

### Phase 2: Team setup

Use TeamCreate to set up the 4-member research team. Use model: "opus" for every agent invocation.

```
TeamCreate:
  team_name: "design-research-team"
  agents:
    - design-historian (model: opus)
    - art-aesthetics (model: opus)
    - token-architect (model: opus)
    - verification-scientist (model: opus)
```

### Phase 3: Research execution — fan-out (parallel)

Use TaskCreate to assign work to design-historian and art-aesthetics at the same time.

#### design-historian task
- Create `$REF/designers/{name}.md` per target designer
- Extract core principles + quantitative figures + changes across periods + influence relationships
- On completion, SendMessage the file path + summary to token-architect

#### art-aesthetics task
- Create `$REF/artists/{name}.md` per target artist
- Extract color theory + composition principles + spatial use + visual rhythm + UI-application mapping
- On completion, SendMessage the file path + summary to token-architect

**Run in parallel**: issue both agents' TaskCreate at the same time so the two studies overlap rather than run sequentially.

**Progress monitoring**: use TaskGet to check the two agents' progress as work proceeds. When one finishes, you may have token-architect start partial integration.

### Phase 4: Integration — fan-in

Once **both** design-historian and art-aesthetics studies complete, assign work to token-architect.

#### token-architect task
- Normalize all designer/artist tokens into a unified schema
- Generate per-platform mapping tables (iOS pt / Web rem / Android dp)
- Resolve conflicts (upward compatibility → context separation → weighted average → variants)
- Build a search index

**Output:**
- `$REF/tokens/unified-tokens.md` — unified token dictionary
- `$REF/tokens/platform-{ios|web|android}.md` — platform mappings
- `$REF/tokens/index.md` — search index
- `$REF/tokens/conflicts.md` — conflict report

On completion, SendMessage all file paths + conflict summary to verification-scientist.

### Phase 5: Verification

Once token-architect's integration completes, assign work to verification-scientist.

#### verification-scientist task
- Assign source-reliability grades (S/A/B/C/D/F)
- Verify numeric accuracy (cross-check official guidelines + internal consistency)
- Form falsifiable hypotheses
- Render PASS / WARNING / FAIL / UNVERIFIABLE verdicts

**Output:**
- `$REF/verification/report.md` — verification report
- `$REF/verification/hypotheses.md` — hypothesis list
- `$REF/verification/token-validation.md` — heuristic evaluation rubric

**If any token is FAIL**: run a token-architect correction → verification-scientist re-verification loop. Repeat at most 3 times. If still FAIL after 3 rounds, mark it `unresolved` and report to the user. Re-verification must re-read the corrected file rather than trust the prior verdict — a FAIL stays FAIL until the file actually shows the fix.

### Phase 6: Output confirmation

Once all verification completes, confirm the following:

1. `$REF/designers/` — per-designer quantitative token dictionaries exist
2. `$REF/artists/` — per-artist visual-language tokens exist
3. `$REF/tokens/unified-tokens.md` — unified token dictionary exists
4. `$REF/tokens/platform-{ios|web|android}.md` — platform mappings exist
5. `$REF/verification/report.md` — verification report exists

If any output is missing, ask the responsible agent to supply it.

Once all output is confirmed, report a result summary to the user:
- 연구 대상 수 (디자이너 N명, 화가 N명)
- 총 토큰 수
- 검증 결과 요약 (PASS / WARNING / FAIL / UNVERIFIABLE 비율)
- 충돌 해결 요약
- design-craft 스킬 사용 준비 완료 여부

## Output directory structure

```
$REF (= plugins/design-craft/skills/design-craft/references/)
├── designers/
│   └── {name}.md              ← 디자이너별 정량 토큰 사전
├── artists/
│   └── {name}.md              ← 화가별 시각 언어 토큰
├── tokens/
│   ├── unified-tokens.md      ← 통합 토큰 사전
│   ├── platform-ios.md        ← iOS 매핑
│   ├── platform-web.md        ← Web 매핑
│   ├── platform-android.md    ← Android 매핑
│   ├── index.md               ← 통합 검색 인덱스
│   └── conflicts.md           ← 충돌 리포트
└── verification/
    ├── report.md              ← 검증 리포트
    ├── hypotheses.md          ← 가설 목록
    └── token-validation.md    ← 평가 루브릭
```

## Data-transfer protocol

### File-based (_workspace/)
- Each agent's intermediate output: `_workspace/{phase}_{agent}_{artifact}.md`
- Example: `_workspace/phase3_design-historian_rams.md`

### Message-based (SendMessage)
- Used for inter-agent completion notices, conflict warnings, supplement requests
- Include the file path + a key summary in SendMessage; keep full content in the file rather than the message

## Error handling

| Situation | Response |
|------|------|
| Agent not responding | Check status with TaskGet. Reassign if still no response after 30s |
| Only one side of parallel research finished | Pass the finished side to token-architect first; integrate the rest progressively as it arrives |
| FAIL rate exceeds 50% in verification | Propose narrowing the research scope or re-researching from primary sources only |
| Excessive token conflicts (10+) | Ask the user to re-confirm designer/artist priorities |
| references/ directory missing | Create it automatically and proceed |
| User did not specify scope | Propose a minimal scope of P0 designers + P0 artists |

## Test scenarios

### Normal scenario: "Single-designer research on Dieter Rams"
1. User requests "Dieter Rams 디자인 토큰을 만들어줘"
2. Phase 1: scope = Dieter Rams (1 designer)
3. Phase 2: team setup (4 agents)
4. Phase 3: design-historian creates `$REF/designers/dieter-rams.md`. art-aesthetics studies related artists (Mondrian, etc.)
5. Phase 4: token-architect builds the unified token dictionary
6. Phase 5: verification-scientist cross-checks against the original Rams "10 Principles" text and figures → PASS
7. Phase 6: confirm output → report completion

### Error scenario: "Verification failure on an unsourced token"
1. design-historian records Susan Kare's bitmap-icon spacing as "8px" (source: a blog)
2. verification-scientist grades the source D (community interpretation) → confidence: 0.30
3. Numeric-accuracy check: cannot cross-check the actual icon grid of the original Mac 128K → UNVERIFIABLE
4. Ask token-architect to keep it with a `needs-verification: true` flag but correct it to a range estimate (6-10px)
5. Report to user: "Susan Kare 토큰 1건이 검증 불가 — 범위 추정치로 기록됨"
