---
name: apple-review
description: apple-craft 리뷰 전용 스킬 — Swift/SwiftUI/UIKit/AppKit 코드, 파일, 디렉토리, PR의 문제점·위험·개선점을 점검합니다. "리뷰", "코드 리뷰", "검토", "점검", "PR 리뷰", "코드 봐줘", "문제 있는지 확인해줘", "blocking issue 찾아줘", "코드 점검", "확인해", "체크", "살펴", "review", "check", "inspect", "analyze", "audit" 같은 요청에 사용합니다. 실제 구현/수정/작성 요청은 apple-craft, 처음부터/전체 구현은 apple-harness가 더 적합합니다.
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

Apple 에코시스템 참조 문서 기반의 심층 코드 리뷰를 수행합니다.
일반 코드 리뷰와 달리, 20개 Apple API 참조 문서 + Swift 6.3 보강 문서 + common-mistakes.md를 기준으로
Apple 플랫폼 고유의 문제를 발견하고 트리아지합니다.
이 스킬은 구현/수정 요청을 직접 수행하는 스킬이 아니라, 문제를 식별하고 우선순위를 정하는 **리뷰 전용 스킬**입니다.
실제 구현/수정은 `apple-craft`, 처음부터/전체 구현은 `apple-harness`가 더 적합합니다.

## Knowledge Authority

참조 문서는 `${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references/`에 위치합니다.
apple-craft 스킬과 동일한 참조 문서를 공유합니다.

- `references/common-mistakes.md` — 필수 로드 (안티패턴 체크리스트)
- `references/code-style.md` — 필수 로드 (Apple 코딩 컨벤션)
- 나머지 19개 참조 문서 — 대상 코드의 프레임워크에 따라 선택 로드

---

## Phase R0: 리뷰 범위 결정

1. AskUserQuestion으로 리뷰 대상 확인:
   - "현재 브랜치의 변경사항 (git diff)"
   - "특정 파일/디렉토리"
   - "PR #N"
2. 선택적: 리뷰 초점 확인 (전체 / Apple 에코시스템 / 보안 / 성능 / 스타일)
3. 대상 파일 목록 수집:
   - git diff: `git diff --name-only <base>..HEAD -- '*.swift'`
   - PR: `gh pr diff <N> --name-only`
   - 디렉토리: `Glob: pattern="**/*.swift" path=<경로>`

---

## Phase R0.5: Codex Cross-Review (선택적)

Codex 스킬이 사용 가능하면, harness-reviewer와 **병렬로** `/codex:review`를 background 실행하여 cross-model 검증을 수행합니다.

1. `/codex:review --background` 실행 — Phase R1과 동시 진행
2. Codex 리뷰 결과는 Phase R1.5에서 병합 (R1 완료 후)
3. `/codex:status`로 진행 상황 확인 가능

> **가드레일**: `/codex:review`는 read-only입니다. severity 판정과 auto-fix 결정 권한은 harness-reviewer가 소유합니다.
> Codex 스킬 미설치 시 이 단계를 건너뛰고 기존 workflow 그대로 진행합니다.

---

## Phase R1: 스캔 + 분류 + 수정

harness-reviewer 에이전트를 디스패치합니다:

```
Agent: harness-reviewer
  - 리뷰 대상 파일 목록
  - 리뷰 초점
```

에이전트가 수행하는 작업:
- common-mistakes.md + code-style.md + 매칭된 참조 문서 기반 정적 분석
- severity(critical/major/minor/suggestion) × complexity(simple-fix/needs-investigation/complex) 분류
- critical/major + simple-fix 항목 자동 수정 + git commit
- needs-investigation 항목 심층 분석
- `.claude/review/review-findings.json` + `.claude/review/review-report.md` 출력

---

## Phase R1.5: 에이전트 검증 요약 검토 + Codex 교차 대조

harness-reviewer가 반환한 결과를 오케스트레이터가 **회의적 관점**으로 검토한다.

### R1.5-A: Codex findings 병합 (R0.5 실행 시)

Phase R0.5에서 `/codex:review`가 background 실행되었으면:

1. `/codex:result`로 Codex 리뷰 결과 수집
2. harness-reviewer findings와 **blocking-level만** 교차 대조:
   - Codex가 발견했으나 harness-reviewer가 놓친 critical/major 항목 → `source: "codex-cross-review"` 추가
   - 양쪽 모두 발견한 항목 → confidence 보강 (별도 표기)
   - Codex-only minor/suggestion → 무시 (Apple 에코시스템 전문성은 harness-reviewer가 우선)
3. 병합 결과를 review-findings.json에 반영

> **원칙**: harness-reviewer가 severity/complexity 분류의 source of truth입니다. Codex는 blind spot 보완 역할만 합니다.

1. `.claude/review/review-findings.json` 읽기
2. **수정 완전성 검증**:
   - action="fixed" 항목의 `revalidated` 필드 확인
   - `revalidated: false`인 수정이 있으면 경고 표시
   - `revalidated` 필드 자체가 없는 fixed 항목 → 재검증 미실행 경고
3. **분류 일관성 검증**:
   - severity=critical인데 action=report-only → 에이전트 판단 오류 가능성, 재확인
   - severity=suggestion인데 action=issue → 과도한 이슈 생성 가능성, 재확인
4. **누락 가능성 검사**:
   - 로드된 참조 문서 목록 vs 실제 탐지 카테고리: 주요 참조 문서에서 발견 0건이면 경고
5. 검토 결과를 review-report.md 상단에 요약 추가:
   ```markdown
   ## 에이전트 검증 요약
   - 총 발견: {N}건
   - 자동 수정: {N}건 (재검증 통과: {N}건, 미통과: {N}건)
   - 재검증에서 추가 발견: {N}건
   - 분류 일관성 경고: {N}건
   ```

검토 결과 심각한 문제(revalidated:false 다수, 분류 불일치 다수)가 있으면:
- harness-reviewer를 해당 항목에 대해 재디스패치 고려
- 또는 사용자에게 "재검증 실패 항목이 있습니다" 안내 후 Phase R2 진행

---

## Phase R2: 트리아지

review-findings.json을 읽고 action별 처리:

1. **action=fixed**: 이미 수정 완료 → 보고만 (커밋 해시 포함)
2. **action=issue**: AskUserQuestion으로 GitHub Issue 생성 여부 확인
   - 승인 시 `mcp__plugin_github_github__issue_write` 사용
   - Title: `[apple-craft review] {description}`
   - Body: 발견 사항, 참조 문서 출처, 수정 방향 포함
   - Labels: `apple-craft-review` + severity 라벨
3. **action=user-decision**: AskUserQuestion으로 사용자 판단 요청
   - minor + simple-fix 항목을 일괄 제시: "다음 N건을 자동 수정할까요?"
   - 승인 시 Edit으로 수정 + git commit
4. **action=report-only**: 보고만 (suggestions)

---

## Phase R3: 최종 보고

review-report.md를 기반으로 사용자에게 요약 출력:
- severity별 건수 + 조치 현황 (수정됨/이슈 생성됨/보고만)
- 자동 수정된 커밋 목록
- 생성된 GitHub Issue 링크 목록
- 잔여 suggestions 요약

---

## Rules

- 한국어로 응답하되, 코드와 API명은 원문 유지
- 참조 문서 인용 시 **출처 파일명 + 섹션명** 반드시 명시
- 프로젝트 컨벤션이 있으면 (CLAUDE.md, .swiftlint.yml 등) 해당 컨벤션 존중
- Xcode MCP 미연결 시에도 코드 분석 기반 리뷰는 완전히 수행
- GitHub MCP 미연결 시 complex 항목은 review-report.md에만 기록 (이슈 생성 생략)
