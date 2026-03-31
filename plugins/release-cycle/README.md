# release-cycle

GitHub 릴리스 라이프사이클 자동화 플러그인.

## 스킬

### `/plan-release`

릴리스 사이클 시작 — 다음 버전 마일스톤 생성, Backlog 이슈 할당, Projects 보드 설정.

**주요 기능:**
- Backlog 이슈 분석 → MAJOR/MINOR/PATCH 자동 제안
- GitHub Milestone 생성 + 이슈 할당
- Projects V2 보드 Target Version 연동 (선택)
- `version.json`으로 릴리스 상태 추적

### `/release`

릴리스 실행 — 마일스톤 검증 → 버전 범프 → 릴리스 노트 → 태그 → GitHub Release.

**주요 기능:**
- 마일스톤 미완료 이슈 자동 검증
- 프로젝트 유형별 버전 범프 (Xcode/npm/Cargo/pyproject)
- 이슈 기반 릴리스 노트 자동 생성
- 핫픽스 흐름 지원 (`/release hotfix`)

## 사전 요구

프로젝트 루트에 `version.json` 필요:

```json
{
  "current": "1.0.0",
  "milestone": null,
  "buildNumber": 1
}
```

## 라이프사이클

```
/plan-release → 개발 → /release → /plan-release → ...
```

## 설치

oozoofrog-plugins 마켓플레이스를 통해 설치됩니다.
