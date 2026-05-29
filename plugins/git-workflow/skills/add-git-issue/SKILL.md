---
name: add-git-issue
description: "Turns a request into a structured GitHub issue and creates a matching branch. Handles all issue types — bug, feature, design, refactor — by investigating the codebase to include relevant files and root cause. 사용자가 '이슈 생성', '이슈 만들어', '깃 이슈', 'git issue', '버그 등록', '기능 요청', 'bug report', 'feature request' 등을 언급할 때 사용하세요."
---

# Git Issue Creation + Branch

Turn the user's request into a structured GitHub issue and create a matching branch.

Respond to the user in Korean.

## Core Principles

- Make the issue body detailed enough that someone else can read it and start working right away.
- Investigate the codebase and include relevant files and line numbers.
- Branch names reflect the issue type and number.

## Pre-detection: Project Settings

Detect these values automatically at run time rather than hardcoding them.

```bash
# 1. 리포지토리 식별
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')

# 2. 기본 브랜치 확인
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')

# 3. version.json 존재 여부 (릴리스 연동용)
test -f version.json && MILESTONE=$(jq -r '.milestone // empty' version.json)

# 4. GitHub Projects V2 연결 여부 (선택)
# Projects가 있으면 Target Version/Status 필드 연동 가능
PROJECTS=$(gh api graphql -f query='{
  repository(owner: "'"${REPO%%/*}"'", name: "'"${REPO##*/}"'") {
    projectsV2(first: 5) { nodes { id title number } }
  }
}' --jq '.data.repository.projectsV2.nodes[]? | "\(.number) \(.title) \(.id)"' 2>/dev/null)
```

If Projects info is detected, offer to link the issue to the board after creation.

## Execution Flow

### 1. Determine Issue Type

Determine the type from the user's request:

| Type | Prefix | Branch pattern | Example |
|------|--------|------------|------|
| Bug | `bug:` | `fix/<number>-<description>` | `fix/248-indoor-badge` |
| Feature | `feat:` | `feat/<number>-<description>` | `feat/244-mission-board` |
| Design | `design:` | `design/<number>-<description>` | `design/237-running-timer` |
| Refactor | `refactor:` | `refactor/<number>-<description>` | `refactor/250-cleanup` |
| Enhancement | `enhance:` | `feat/<number>-<description>` | `feat/243-workout-view` |

### 2. Investigate the Codebase

Explore the code related to the issue:
- Search for relevant files with Grep/Glob.
- Read the key files to understand current behavior.
- For a bug, trace the cause; for a feature, identify the files to change.

### 3. Build the Issue Body

Pick the appropriate sections per type:

#### 버그 이슈

```markdown
## 증상
[사용자가 관찰한 현상]

## 원인 분석
[코드 조사 결과 — 파일명:라인 포함]

## 수정 방안
[구체적인 수정 방향]

## 관련 파일
- `경로/파일` — 역할 설명
```

#### 기능/개선 이슈

```markdown
## 배경
[왜 이 기능이 필요한지]

## 요구사항
[구체적인 변경 사항]

## 변경 대상 파일
- `경로/파일` — 변경 내용

## 참조
[기획서 섹션, 디자인 문서 등]
```

#### 디자인 이슈

```markdown
## 배경
[디자인 변경 이유]

## 현재 코드 구현
[코드에서 구현된 내용]

## 디자인 작업
[변경할 내용]
```

### 4. Create the Issue

```bash
gh issue create --title "<접두사> <제목>" --body "<본문>" --repo "$REPO"
```

### 5. Create the Branch

```bash
git checkout "$DEFAULT_BRANCH" && git pull --rebase origin "$DEFAULT_BRANCH"
git checkout -b <브랜치패턴>
```

Include the issue number in the branch name once the issue is created.

### 6. Version Linking (optional)

If `version.json` exists and the `milestone` field is set, offer to link automatically.

```bash
MILESTONE=$(jq -r '.milestone // empty' version.json 2>/dev/null)
```

If `milestone` is not empty:
> "이 이슈를 **v{MILESTONE}**에 포함할까요? (Y/n)"

**Y 선택 시:**

```bash
# 1. Milestone 설정
gh issue edit <NUMBER> --milestone "v{MILESTONE}" --repo "$REPO"
```

**GitHub Projects V2가 연결되어 있으면 추가:**

```bash
# 2. Projects 보드 Target Version 설정 (GraphQL)
# 탐지된 PROJECT_ID, FIELD_ID 사용

# 3. Status를 Ready로 이동
```

**n 선택 시:** Backlog에 유지.

## Label Rules

Add labels by issue type (only labels that already exist):

| Type | Label |
|------|------|
| Bug | `bug` |
| Feature | `enhancement` |

Also add any platform/module labels identified during code investigation.

## Multiple Issues

When the user requests several issues at once:
1. Create each issue independently.
2. Note dependencies in the body if any exist.
3. Create a branch only for the first (or specified) issue.

## What to Confirm with the User

- Ask if the issue type is ambiguous.
- Whether to create a branch (default: yes).
- Whether to add labels (default: auto-determine).
