---
name: plan-release
description: "Start a release cycle — create the next version milestone, assign backlog issues, set up the Projects board. Use for '릴리스 계획', '다음 버전', 'plan release', '버전 계획', '새 마일스톤', 'next version', '릴리스 시작' requests."
---

# 릴리스 계획 (Plan Release)

Plan the next version's work after the previous release is complete.
Set up a GitHub Milestone + Projects board and assign backlog issues to the new version.

Respond to the user in Korean.

## Prerequisites

### version.json

The project root needs a `version.json`. If it is missing, guide the user to create it:

```json
{
  "current": "1.0.0",
  "milestone": null,
  "buildNumber": 1
}
```

| Field | Purpose |
|------|------|
| `current` | Currently released version |
| `milestone` | Next version in progress (null if no plan) |
| `buildNumber` | Current build number |

## Project auto-detection

```bash
# 리포지토리 식별
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
OWNER="${REPO%%/*}"

# GitHub Projects V2 탐지 (선택 — 없어도 마일스톤만으로 동작)
PROJECTS=$(gh api graphql -f query='{
  repository(owner: "'"$OWNER"'", name: "'"${REPO##*/}"'") {
    projectsV2(first: 5) { nodes { id title number } }
  }
}' --jq '.data.repository.projectsV2.nodes[]? | "\(.number) \(.title) \(.id)"' 2>/dev/null)
```

If Projects is detected, enable Target Version field integration.

## Execution flow

### Step 1: Analyze current state

```bash
# version.json 읽기
cat version.json

# 최근 git 태그 확인
git tag --sort=-v:refname | head -3

# 열린 마일스톤 확인
gh api "repos/$REPO/milestones?state=open" --jq '.[] | "\(.title) (open:\(.open_issues) closed:\(.closed_issues))"'
```

If an open milestone already exists, ask the user:
"v{X} 마일스톤이 이미 존재합니다. 이 버전에 이슈를 추가할까요, 아니면 새 버전을 계획할까요?"

---

### Step 2: Collect backlog issues

```bash
gh issue list --repo "$REPO" --state open --json number,title,labels --limit 50
```

If Projects is connected, also query backlog items via GraphQL:

```bash
gh api graphql -f query='
{
  repository(owner: "'"$OWNER"'", name: "'"${REPO##*/}"'") {
    projectsV2(first: 1) {
      nodes {
        items(first: 100) {
          nodes {
            content {
              ... on Issue { number title state labels(first: 5) { nodes { name } } }
            }
            fieldValues(first: 10) {
              nodes {
                ... on ProjectV2ItemFieldSingleSelectValue {
                  name
                  field { ... on ProjectV2SingleSelectField { name } }
                }
              }
            }
          }
        }
      }
    }
  }
}
'
```

Filter to OPEN issues with Status=Backlog or no Target Version set.

---

### Step 3: Propose the next version

Analyze the labels/prefixes of backlog issues to decide the version type:

| Condition | Version type |
|------|----------|
| feat/enhancement issues present | MINOR (x.**Y**.0) |
| bug/fix issues only | PATCH (x.y.**Z**) |
| Large-scale redesign | MAJOR (**X**.0.0) |

Propose to the user:
"Backlog에 feat N개, fix N개가 있습니다. **v{next}**를 제안합니다. 이 버전 번호로 진행할까요?"

---

### Step 4: Set up milestone + board

Once the user confirms the version:

**1. Create the GitHub milestone:**

```bash
gh api "repos/$REPO/milestones" -f title="v{VERSION}" -f state=open
```

**2. Update version.json:**

Set the `milestone` field to the new version string.

**3. Commit:**

```bash
git add version.json && git commit -m "chore: v{VERSION} 릴리스 계획 시작"
```

**4. Link the Projects board (if detected):**

If a Target Version field exists, add the new version option.
Discover field IDs and options dynamically via GraphQL.

---

### Step 5: Issue assignment guide (interactive)

Show backlog issues grouped by Priority (P0/P1/P2/unclassified).

Ask the user:
"포함할 이슈 번호를 알려주세요 (예: 'all', '123, 456', 'P0과 P1만')"

For each selected issue:

```bash
# 마일스톤 설정
gh issue edit <N> --milestone "v{VERSION}" --repo "$REPO"
```

If Projects is connected:
- Set the Target Version field (GraphQL mutation)
- Change Status to Ready (GraphQL mutation)

---

### Step 6: Summary output

After the work is done, print a summary as a table:

| Category | Issue count |
|------|--------|
| feat | N |
| enhance | N |
| fix | N |
| Other | N |

"모든 이슈가 완료되면 `/release`를 실행하세요."

## Error handling

| Situation | Response |
|---|---|
| version.json missing | Explain schema + propose creation |
| gh CLI not authenticated | Guide to `gh auth login` |
| Projects not connected | Operate with milestone only (skip Projects integration) |
