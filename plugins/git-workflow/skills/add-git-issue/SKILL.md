---
name: add-git-issue
description: "Git 이슈를 구조화하여 생성하고 대응 브랜치를 만듭니다. 사용자가 '이슈 생성', '이슈 만들어', '깃 이슈', 'git issue', '버그 등록', '기능 요청', 'bug report', 'feature request' 등을 언급할 때 사용하세요. 버그, 기능, 디자인, 리팩터링 등 모든 유형의 이슈에 대응합니다. 코드베이스를 조사하여 관련 파일과 원인을 포함한 상세한 이슈를 생성합니다."
---

# Git 이슈 생성 + 브랜치

사용자의 요청을 구조화된 GitHub 이슈로 변환하고, 대응 브랜치를 생성합니다.

## 핵심 원칙

- 이슈 본문은 **다른 사람이 읽고 바로 작업할 수 있을 정도로** 상세해야 합니다
- 코드베이스를 조사하여 **관련 파일과 라인 번호**를 포함합니다
- 브랜치 이름은 이슈 유형과 번호를 반영합니다

## 사전 탐지: 프로젝트 설정

스킬 실행 시 아래 값을 자동으로 탐지합니다. 하드코딩하지 않습니다.

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

탐지된 Projects 정보가 있으면 이슈 생성 후 자동으로 보드 연동을 제안합니다.

## 실행 흐름

### 1. 이슈 유형 판별

사용자 요청에서 유형을 판별합니다:

| 유형 | 접두사 | 브랜치 패턴 | 예시 |
|------|--------|------------|------|
| 버그 | `bug:` | `fix/<번호>-<설명>` | `fix/248-indoor-badge` |
| 기능 | `feat:` | `feat/<번호>-<설명>` | `feat/244-mission-board` |
| 디자인 | `design:` | `design/<번호>-<설명>` | `design/237-running-timer` |
| 리팩터링 | `refactor:` | `refactor/<번호>-<설명>` | `refactor/250-cleanup` |
| 개선 | `enhance:` | `feat/<번호>-<설명>` | `feat/243-workout-view` |

### 2. 코드베이스 조사

이슈와 관련된 코드를 탐색합니다:
- Grep/Glob으로 관련 파일 검색
- 핵심 파일을 읽어서 현재 동작 파악
- 버그라면 원인 추적, 기능이라면 변경 대상 파일 식별

### 3. 이슈 본문 구성

유형에 따라 적절한 섹션을 선택합니다:

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

### 4. 이슈 생성

```bash
gh issue create --title "<접두사> <제목>" --body "<본문>" --repo "$REPO"
```

### 5. 브랜치 생성

```bash
git checkout "$DEFAULT_BRANCH" && git pull --rebase origin "$DEFAULT_BRANCH"
git checkout -b <브랜치패턴>
```

이슈 번호가 생성된 후 브랜치 이름에 포함합니다.

### 6. 버전 연동 (선택)

`version.json`이 존재하고 `milestone` 필드가 설정되어 있으면 자동으로 연결을 제안합니다.

```bash
MILESTONE=$(jq -r '.milestone // empty' version.json 2>/dev/null)
```

`milestone`이 비어 있지 않으면:
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

## 라벨 규칙

이슈 유형에 따라 자동으로 라벨을 추가합니다 (존재하는 라벨만):

| 유형 | 라벨 |
|------|------|
| 버그 | `bug` |
| 기능 | `enhancement` |

추가로 코드 조사에서 파악된 플랫폼/모듈 관련 라벨이 있으면 추가합니다.

## 다중 이슈

사용자가 여러 이슈를 한번에 요청하면:
1. 각 이슈를 독립적으로 생성
2. 의존성이 있으면 본문에 명시
3. 브랜치는 첫 번째(또는 지정된) 이슈에 대해서만 생성

## 사용자에게 확인할 것

- 이슈 유형이 모호하면 물어보기
- 브랜치 생성 여부 (기본: 생성)
- 라벨 추가 여부 (기본: 자동 판별)
