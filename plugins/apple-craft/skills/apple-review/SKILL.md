---
name: apple-review
description: apple-craft review-only skill — inspects Swift/SwiftUI/UIKit/AppKit code, files, directories, or PRs for problems, risks, and improvements. Triggers on "리뷰", "코드 리뷰", "검토", "점검", "PR 리뷰", "코드 봐줘", "문제 있는지 확인해줘", "blocking issue 찾아줘", "코드 점검", "확인해", "체크", "살펴", "review", "check", "inspect", "analyze", "audit". For actual implementation/modification/writing use apple-craft; for from-scratch/full implementation use apple-harness.
argument-hint: "[file, directory, or PR number]"
---

<example>
user: "이 코드 리뷰해줘"
assistant: "review 모드로 Apple 에코시스템 참조 문서 기반 코드 리뷰를 수행합니다. 리뷰 범위를 확인하겠습니다."
</example>

<example>
user: "PR #42에서 blocking issue만 골라줘"
assistant: "review 모드로 PR #42의 변경 파일을 분석하고, blocking issue 중심으로 우선순위를 정리하겠습니다."
</example>

<example>
user: "SettingsView.swift 문제 있는지 한번 봐줘"
assistant: "review 모드로 해당 파일을 분석합니다. 사용 중인 Apple 프레임워크와 common-mistakes.md를 기준으로 문제점을 점검하겠습니다."
</example>

<example>
user: "이 SwiftUI 화면 성능/동시성 관점에서 점검해줘"
assistant: "review 모드로 해당 화면을 분석하고, 성능 및 Swift Concurrency 관점의 위험 요소를 정리하겠습니다."
</example>

# apple-review

Perform a deep code review grounded in Apple ecosystem reference docs.
Unlike a generic code review, this finds and triages Apple-platform-specific issues using 20 Apple API reference docs + the Swift 6.3 supplement + common-mistakes.md.
This is a **review-only skill** that identifies and prioritizes problems, not one that performs implementation/fixes directly.
For actual implementation/fixes use `apple-craft`; for from-scratch/full implementation use `apple-harness`.

Respond to the user in Korean.

## Knowledge Authority

Reference docs live in `${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references/`.
They are the same reference docs shared with the apple-craft skill.

- `references/common-mistakes.md` — always load (antipattern checklist)
- `references/code-style.md` — always load (Apple coding conventions)
- The remaining 19 reference docs — load selectively based on the target code's framework

---

## Phase R0: Decide review scope

1. Confirm the review target with AskUserQuestion:
   - "현재 브랜치의 변경사항 (git diff)"
   - "특정 파일/디렉토리"
   - "PR #N"
2. Optional: confirm the review focus (전체 / Apple 에코시스템 / 보안 / 성능 / 스타일)
3. Collect the target file list:
   - git diff: `git diff --name-only <base>..HEAD -- '*.swift'`
   - PR: `gh pr diff <N> --name-only`
   - directory: `Glob: pattern="**/*.swift" path=<경로>`

---

## Phase R0.5: Codex Cross-Review (optional)

If the Codex skill is available, run `/codex:review` in the background **in parallel** with harness-reviewer for cross-model verification.

1. Run `/codex:review --background` — concurrent with Phase R1
2. Merge the Codex review results in Phase R1.5 (after R1 completes)
3. Check progress with `/codex:status`

> **Guardrail**: `/codex:review` is read-only. harness-reviewer owns the authority over severity judgments and auto-fix decisions.
> If the Codex skill is not installed, skip this phase and proceed with the existing workflow unchanged.

---

## Phase R1: Scan + classify + fix

Dispatch the harness-reviewer agent:

```
Agent: harness-reviewer
  - 리뷰 대상 파일 목록
  - 리뷰 초점
```

What the agent does:
- Static analysis based on common-mistakes.md + code-style.md + matched reference docs
- Classify by severity(critical/major/minor/suggestion) × complexity(simple-fix/needs-investigation/complex)
- Auto-fix critical/major + simple-fix items + git commit
- Deep analysis of needs-investigation items
- Output `.claude/review/review-findings.json` + `.claude/review/review-report.md`

---

## Phase R1.5: Review the agent's verification summary + cross-check against Codex

The orchestrator reviews the harness-reviewer results with a **skeptical lens**. If in doubt, flag it rather than assuming the fix is sound.

### R1.5-A: Merge Codex findings (when R0.5 ran)

If `/codex:review` ran in the background during Phase R0.5:

1. Collect the Codex review results with `/codex:result`
2. Cross-check against the harness-reviewer findings, **blocking-level only**:
   - critical/major items Codex found but harness-reviewer missed → add `source: "codex-cross-review"`
   - items both found → reinforce confidence (note separately)
   - Codex-only minor/suggestion → ignore (harness-reviewer takes priority on Apple ecosystem expertise)
3. Reflect the merged result in review-findings.json

> **Principle**: harness-reviewer is the source of truth for severity/complexity classification. Codex only fills in blind spots.

1. Read `.claude/review/review-findings.json`
2. **Verify fix completeness**:
   - Check the `revalidated` field of action="fixed" items
   - If any fix has `revalidated: false`, surface a warning
   - A fixed item missing the `revalidated` field entirely → warn that revalidation was not run
3. **Verify classification consistency**:
   - severity=critical but action=report-only → possible agent misjudgment, re-confirm
   - severity=suggestion but action=issue → possible over-issuing, re-confirm
4. **Check for possible omissions**:
   - Loaded reference doc list vs actually detected categories: if a major reference doc yields 0 findings, warn
5. Add the review summary to the top of review-report.md:
   ```markdown
   ## 에이전트 검증 요약
   - 총 발견: {N}건
   - 자동 수정: {N}건 (재검증 통과: {N}건, 미통과: {N}건)
   - 재검증에서 추가 발견: {N}건
   - 분류 일관성 경고: {N}건
   ```

If the review surfaces serious problems (many revalidated:false, many classification mismatches):
- Consider re-dispatching harness-reviewer for those items
- Or notify the user "재검증 실패 항목이 있습니다" and then proceed to Phase R2

---

## Phase R2: Triage

Read review-findings.json and handle by action:

1. **action=fixed**: already fixed → report only (include commit hash)
2. **action=issue**: confirm GitHub Issue creation with AskUserQuestion
   - On approval, use `mcp__plugin_github_github__issue_write`
   - Title: `[apple-craft review] {description}`
   - Body: findings, reference doc source, suggested fix direction
   - Labels: `apple-craft-review` + severity label
3. **action=user-decision**: request the user's judgment with AskUserQuestion
   - Present minor + simple-fix items in a batch: "다음 N건을 자동 수정할까요?"
   - On approval, fix with Edit + git commit
4. **action=report-only**: report only (suggestions)

---

## Phase R3: Final report

Based on review-report.md, output a summary to the user:
- counts per severity + action status (수정됨/이슈 생성됨/보고만)
- list of auto-fixed commits
- list of created GitHub Issue links
- summary of remaining suggestions

---

## Rules

- Respond in Korean, but keep code and API names in their original form
- When citing a reference doc, state the **source filename + section name** so the basis is traceable
- If project conventions exist (CLAUDE.md, .swiftlint.yml, etc.), respect those conventions
- Even when Xcode MCP is not connected, perform the code-analysis-based review fully
- When GitHub MCP is not connected, record complex items only in review-report.md (skip issue creation)
