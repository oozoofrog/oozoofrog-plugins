---
name: release
description: "릴리스 실행 — 마일스톤 완료 검증, 버전 범프, 릴리스 노트 자동 생성, 태그, GitHub Release. '릴리스', 'release', '배포', '버전 출시', '릴리스 노트', 'release notes', '버전 업데이트', 'version bump' 요청 시 사용하세요."
---

# 릴리스 실행 (Release)

릴리스 사이클의 마무리 단계.
마일스톤 검증 → 버전 범프 → 릴리스 노트 → 태그 → GitHub Release.

## 인자 (Arguments)

| 명령 | 동작 |
|---|---|
| `/release` | 정상 릴리스 — 마일스톤 기반 |
| `/release hotfix` | 핫픽스 — 현재 버전에서 PATCH +1 |

## 사전 요구

`version.json`이 프로젝트 루트에 있어야 합니다 (`/plan-release`로 생성).

## 프로젝트 자동 탐지

```bash
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')
```

---

## 정상 릴리스 흐름 — 6 Phases

### Phase 0: 릴리스 준비 검증

```bash
cat version.json
```

- `milestone`이 null이면: "계획된 릴리스가 없습니다. /plan-release를 먼저 실행하세요." 출력 후 중단
- 마일스톤 미완료 이슈 확인:

```bash
# 열린 마일스톤에서 번호 조회
MILESTONE_NUM=$(gh api "repos/$REPO/milestones?state=open" --jq '.[] | select(.title == "v'"$VERSION"'") | .number')
gh api "repos/$REPO/issues?milestone=$MILESTONE_NUM&state=open" --jq '.[] | "#\(.number) \(.title)"'
```

- 미완료 이슈가 있으면 사용자에게 선택 제시:
  - **(A) Backlog으로 이동 후 계속**: 해당 이슈의 마일스톤 제거 후 릴리스 계속
  - **(B) 중단**: 릴리스 취소

- Git 상태 확인: 기본 브랜치여야 하고 uncommitted changes가 없어야 함

```bash
git branch --show-current
git status --porcelain
```

---

### Phase 1: 버전 범프

프로젝트의 버전 관리 방식에 따라 범프합니다:

**탐지 순서:**

1. `*.xcodeproj/project.pbxproj` 존재 → Xcode 프로젝트 버전 범프 (MARKETING_VERSION)
2. `package.json` 존재 → npm version 범프
3. `Cargo.toml` 존재 → Cargo version 범프
4. `pyproject.toml` 존재 → Python version 범프
5. 위 모두 없으면 → version.json만 업데이트

**공통:**
- version.json 업데이트: `current`=새 버전, `buildNumber`=1
- 커밋:

```bash
git add -A && git commit -m "release: v{VERSION} 버전 범프"
```

---

### Phase 2: 릴리스 노트 자동 생성

마일스톤에 포함된 closed 이슈를 조회합니다:

```bash
gh api "repos/$REPO/issues?milestone=$MILESTONE_NUM&state=closed" --jq '.[] | "\(.number) \(.title) \([.labels[].name])"'
```

**라벨별 분류:**

| 라벨 | 섹션 |
|------|------|
| `feat`, `enhancement` | 새 기능 |
| `enhance` | 개선 |
| `bug`, `fix` | 버그 수정 |

- 기술 용어가 아닌 사용자 관점의 설명 작성
- 사용자가 검토 후 확인

**릴리스 노트 저장 (프로젝트에 따라):**

1. `fastlane/metadata/` 존재 → 로케일별 `release_notes.txt` 업데이트
2. `CHANGELOG.md` 존재 → 새 버전 섹션 추가
3. 위 모두 없으면 → GitHub Release 본문으로만 사용

---

### Phase 3: 태그 + GitHub Release

```bash
git tag v{VERSION}
git push origin "$DEFAULT_BRANCH"
git push origin v{VERSION}
gh release create v{VERSION} \
  --title "v{VERSION}" \
  --notes "<릴리스 노트>" \
  --repo "$REPO"
```

---

### Phase 4: 마일스톤 정리

```bash
gh api -X PATCH "repos/$REPO/milestones/$MILESTONE_NUM" -f state=closed
```

- version.json 업데이트: `milestone`=null
- 커밋 + 푸시:

```bash
git add version.json
git commit -m "chore: v{VERSION} 릴리스 완료, 마일스톤 close"
git push origin "$DEFAULT_BRANCH"
```

---

### Phase 5: 다음 사이클 안내

"v{VERSION} 릴리스가 완료되었습니다! /plan-release를 실행하여 다음 버전을 계획하세요."

---

## 핫픽스 흐름 (`/release hotfix`)

1. 현재 버전에서 PATCH +1 계산 (예: 2.1.0 → 2.1.1)
2. GitHub에 핫픽스 마일스톤 생성
3. version.json의 `milestone`을 핫픽스 버전으로 설정
4. 포함할 이슈를 사용자에게 확인
5. 이슈를 핫픽스 마일스톤에 할당
6. Phase 1~5 정상 실행

---

## 에러 처리

| 상황 | 대응 |
|---|---|
| version.json 없음 | 스키마 안내 + /plan-release 가이드 |
| milestone이 null | "/plan-release를 먼저 실행하세요." 안내 후 중단 |
| 태그 이미 존재 | buildNumber만 올릴지 사용자에게 확인 |
| GitHub Release 실패 | 에러 표시 + 수동 gh 명령 안내 |
| push 실패 | `git pull --rebase` 시도 → 충돌 시 사용자에게 수동 해결 안내 |
