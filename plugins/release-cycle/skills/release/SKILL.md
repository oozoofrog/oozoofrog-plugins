---
name: release
description: "Execute a release — verify milestone completion, bump version, auto-generate release notes, tag, and create a GitHub Release. Use for: '릴리스', 'release', '배포', '버전 출시', '릴리스 노트', 'release notes', '버전 업데이트', 'version bump'."
---

# 릴리스 실행 (Release)

The final stage of the release cycle.
Verify milestone → bump version → release notes → tag → GitHub Release.

Respond to the user in Korean.

## Arguments

| Command | Action |
|---|---|
| `/release` | Normal release — milestone-based |
| `/release hotfix` | Hotfix — PATCH +1 from the current version |

## Prerequisites

`version.json` must exist at the project root (created by `/plan-release`).

## Project auto-detection

```bash
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')
```

---

## Normal release flow — 6 Phases

### Phase 0: Verify release readiness

```bash
cat version.json
```

- If `milestone` is null: print "계획된 릴리스가 없습니다. /plan-release를 먼저 실행하세요." and STOP. Do not proceed without a planned milestone.
- Check for open issues on the milestone:

```bash
# 열린 마일스톤에서 번호 조회
MILESTONE_NUM=$(gh api "repos/$REPO/milestones?state=open" --jq '.[] | select(.title == "v'"$VERSION"'") | .number')
gh api "repos/$REPO/issues?milestone=$MILESTONE_NUM&state=open" --jq '.[] | "#\(.number) \(.title)"'
```

- If open issues remain, present a choice to the user:
  - **(A) Backlog으로 이동 후 계속**: remove the milestone from those issues, then continue the release
  - **(B) 중단**: cancel the release

- Check git state: must be on the default branch with no uncommitted changes.

```bash
git branch --show-current
git status --porcelain
```

---

### Phase 1: Version bump

Bump according to the project's version management style.

**Detection order:**

1. `*.xcodeproj/project.pbxproj` exists → Xcode project version bump (MARKETING_VERSION)
2. `package.json` exists → npm version bump
3. `Cargo.toml` exists → Cargo version bump
4. `pyproject.toml` exists → Python version bump
5. None of the above → update version.json only

**Common:**
- Update version.json: `current`=new version, `buildNumber`=1
- Commit:

```bash
git add -A && git commit -m "release: v{VERSION} 버전 범프"
```

---

### Phase 2: Auto-generate release notes

Query the closed issues on the milestone:

```bash
gh api "repos/$REPO/issues?milestone=$MILESTONE_NUM&state=closed" --jq '.[] | "\(.number) \(.title) \([.labels[].name])"'
```

**Classify by label:**

| Label | Section |
|------|------|
| `feat`, `enhancement` | New features |
| `enhance` | Improvements |
| `bug`, `fix` | Bug fixes |

- Write user-facing descriptions, not technical jargon.
- Have the user review before confirming.

**Save release notes (depending on project):**

1. `fastlane/metadata/` exists → update per-locale `release_notes.txt`
2. `CHANGELOG.md` exists → add a new version section
3. None of the above → use only as the GitHub Release body

---

### Phase 3: Tag + GitHub Release

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

### Phase 4: Close the milestone

```bash
gh api -X PATCH "repos/$REPO/milestones/$MILESTONE_NUM" -f state=closed
```

- Update version.json: `milestone`=null
- Commit + push:

```bash
git add version.json
git commit -m "chore: v{VERSION} 릴리스 완료, 마일스톤 close"
git push origin "$DEFAULT_BRANCH"
```

---

### Phase 5: Next cycle

"v{VERSION} 릴리스가 완료되었습니다! /plan-release를 실행하여 다음 버전을 계획하세요."

---

## Hotfix flow (`/release hotfix`)

1. Compute PATCH +1 from the current version (e.g. 2.1.0 → 2.1.1)
2. Create a hotfix milestone on GitHub
3. Set version.json `milestone` to the hotfix version
4. Confirm the issues to include with the user
5. Assign the issues to the hotfix milestone
6. Run Phases 1–5 normally

---

## Error handling

| Situation | Response |
|---|---|
| version.json missing | Explain the schema + guide to /plan-release |
| milestone is null | Print "/plan-release를 먼저 실행하세요." and stop |
| Tag already exists | Ask the user whether to bump only buildNumber |
| GitHub Release failed | Show the error + guide to the manual gh command |
| push failed | Try `git pull --rebase` → on conflict, guide the user to resolve manually |
