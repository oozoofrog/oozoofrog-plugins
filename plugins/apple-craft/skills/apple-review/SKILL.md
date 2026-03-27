---
name: apple-review
description: apple-craft 리뷰 모드 — Apple 에코시스템 참조 문서 20개 + common-mistakes.md + code-style.md 기반 코드 리뷰 + 자동 수정 + GitHub Issue 생성. "리뷰", "코드 리뷰", "review", "검토", "점검", "PR 리뷰", "audit", "봐줘", "확인해", "체크", "살펴", "분석", "check", "analyze", "inspect", "코드 봐줘", "PR 확인", "코드 점검" 요청 시 활성화
argument-hint: "[file, directory, or PR number]"
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
  - mcp__xcode__XcodeRead
  - mcp__xcode__XcodeGrep
  - mcp__xcode__XcodeGlob
  - mcp__plugin_github_github__issue_write
  - mcp__plugin_github_github__search_issues
---

<example>
user: "이 코드 리뷰해줘"
assistant: "review 모드로 Apple 에코시스템 참조 문서 기반 코드 리뷰를 수행합니다. 리뷰 범위를 확인하겠습니다."
</example>

<example>
user: "PR #42 리뷰 부탁해"
assistant: "review 모드로 PR #42의 변경 파일을 분석합니다. common-mistakes.md와 관련 참조 문서를 기준으로 Apple 플랫폼 관점에서 리뷰합니다."
</example>

<example>
user: "SettingsView.swift 코드 점검"
assistant: "review 모드로 해당 파일을 분석합니다. Liquid Glass, FoundationModels 등 사용 중인 프레임워크의 참조 문서를 기준으로 검토합니다."
</example>

<example>
user: "이 프로젝트 전체 코드 봐줘"
assistant: "review 모드로 프로젝트의 Swift 파일을 전체 스캔합니다. Apple 에코시스템 참조 문서 기반으로 심층 리뷰를 진행합니다."
</example>

# apple-review

Apple 에코시스템 참조 문서 기반의 심층 코드 리뷰를 수행합니다.
일반 코드 리뷰와 달리, 20개 Apple API 참조 문서 + common-mistakes.md를 기준으로
Apple 플랫폼 고유의 문제를 발견하고 트리아지합니다.

## Knowledge Authority

참조 문서는 `${CLAUDE_PLUGIN_ROOT}/skills/apple-craft/references/`에 위치합니다.
apple-craft 스킬과 동일한 참조 문서를 공유합니다.

- `references/common-mistakes.md` — 필수 로드 (안티패턴 체크리스트)
- `references/code-style.md` — 필수 로드 (Apple 코딩 컨벤션)
- 나머지 18개 참조 문서 — 대상 코드의 프레임워크에 따라 선택 로드

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
