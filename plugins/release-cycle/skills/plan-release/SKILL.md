---
name: plan-release
description: "릴리스 사이클 시작 — 다음 버전 마일스톤 생성, Backlog 이슈 할당, Projects 보드 설정. '릴리스 계획', '다음 버전', 'plan release', '버전 계획', '새 마일스톤', 'next version', '릴리스 시작' 요청 시 사용하세요."
---

# 릴리스 계획 (Plan Release)

이전 릴리스 완료 후 다음 버전의 작업을 계획합니다.
GitHub Milestone + Projects 보드를 설정하고, Backlog 이슈를 새 버전에 할당합니다.

## 사전 요구

### version.json

프로젝트 루트에 `version.json`이 필요합니다. 없으면 생성을 안내합니다:

```json
{
  "current": "1.0.0",
  "milestone": null,
  "buildNumber": 1
}
```

| 필드 | 용도 |
|------|------|
| `current` | 현재 배포된 버전 |
| `milestone` | 진행 중인 다음 버전 (null이면 계획 없음) |
| `buildNumber` | 현재 빌드 번호 |

## 프로젝트 자동 탐지

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

Projects가 탐지되면 Target Version 필드 연동을 활성화합니다.

## 실행 흐름

### Step 1: 현재 상태 분석

```bash
# version.json 읽기
cat version.json

# 최근 git 태그 확인
git tag --sort=-v:refname | head -3

# 열린 마일스톤 확인
gh api "repos/$REPO/milestones?state=open" --jq '.[] | "\(.title) (open:\(.open_issues) closed:\(.closed_issues))"'
```

열린 마일스톤이 이미 존재하면 사용자에게 물어봅니다:
"v{X} 마일스톤이 이미 존재합니다. 이 버전에 이슈를 추가할까요, 아니면 새 버전을 계획할까요?"

---

### Step 2: Backlog 이슈 수집

```bash
gh issue list --repo "$REPO" --state open --json number,title,labels --limit 50
```

Projects가 연결되어 있으면 GraphQL로 Backlog 항목도 조회합니다:

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

Status=Backlog이거나 Target Version이 설정되지 않은 OPEN 이슈를 필터링합니다.

---

### Step 3: 다음 버전 제안

Backlog 이슈의 라벨/접두사를 분석하여 버전 유형을 결정합니다:

| 조건 | 버전 타입 |
|------|----------|
| feat/enhancement 이슈 있음 | MINOR (x.**Y**.0) |
| bug/fix 이슈만 있음 | PATCH (x.y.**Z**) |
| 대규모 재설계 | MAJOR (**X**.0.0) |

사용자에게 제안합니다:
"Backlog에 feat N개, fix N개가 있습니다. **v{next}**를 제안합니다. 이 버전 번호로 진행할까요?"

---

### Step 4: 마일스톤 + 보드 설정

사용자가 버전을 확정하면:

**1. GitHub 마일스톤 생성:**

```bash
gh api "repos/$REPO/milestones" -f title="v{VERSION}" -f state=open
```

**2. version.json 업데이트:**

`milestone` 필드를 새 버전 문자열로 설정합니다.

**3. 커밋:**

```bash
git add version.json && git commit -m "chore: v{VERSION} 릴리스 계획 시작"
```

**4. Projects 보드 연동 (탐지된 경우):**

Target Version 필드가 있으면 새 버전 옵션을 추가합니다.
필드 ID와 옵션은 GraphQL로 동적 탐지합니다.

---

### Step 5: 이슈 할당 가이드 (대화형)

Backlog 이슈를 Priority별로 그룹화하여 보여줍니다 (P0/P1/P2/미분류).

사용자에게 물어봅니다:
"포함할 이슈 번호를 알려주세요 (예: 'all', '123, 456', 'P0과 P1만')"

선택된 각 이슈에 대해:

```bash
# 마일스톤 설정
gh issue edit <N> --milestone "v{VERSION}" --repo "$REPO"
```

Projects가 연결되어 있으면:
- Target Version 필드 설정 (GraphQL mutation)
- Status를 Ready로 변경 (GraphQL mutation)

---

### Step 6: 요약 출력

작업 완료 후 표 형태로 요약을 출력합니다:

| 분류 | 이슈 수 |
|------|--------|
| feat | N |
| enhance | N |
| fix | N |
| 기타 | N |

"모든 이슈가 완료되면 `/release`를 실행하세요."

## 에러 처리

| 상황 | 대응 |
|---|---|
| version.json 없음 | 스키마 안내 + 생성 제안 |
| gh CLI 미인증 | `gh auth login` 안내 |
| Projects 미연결 | 마일스톤만으로 동작 (Projects 연동 스킵) |
