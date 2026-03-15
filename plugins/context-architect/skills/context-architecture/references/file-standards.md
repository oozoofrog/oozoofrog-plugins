# 파일 표준 상세 가이드

## CLAUDE.md 작성 표준

### 필수 섹션

```markdown
# 프로젝트명

## Build & Test
- `npm run build` — 프로덕션 빌드
- `npm test` — 전체 테스트 실행
- `npm run test:unit -- path/to/file` — 단일 파일 테스트

## Architecture Decisions
- 모노레포 구조: Turborepo 기반
- 상태관리: Zustand 사용 (Redux 대신)
- API: tRPC를 통한 end-to-end 타입 안전성

## Environment
- Node.js 20+
- pnpm 9+

## Key Conventions
- 커밋 메시지: Conventional Commits 형식
- 브랜치: feature/*, fix/*, chore/*
```

### 200라인 제한 전략

CLAUDE.md가 200라인을 초과하면:

1. **상세 아키텍처 문서** → `src/CONTEXT.md`로 이동
2. **API 명세** → `src/api/CONTEXT.md`로 이동
3. **테스트 전략** → `tests/CONTEXT.md`로 이동
4. **스타일 가이드** → 린터 설정으로 대체 (제거)

### 자동 감지 가능한 빌드 도구

init 명령은 다음 파일을 감지하여 빌드/테스트 명령을 자동 추출한다:

| 파일 | 도구 | 추출 대상 |
|------|------|-----------|
| `package.json` | npm/yarn/pnpm | scripts 섹션 |
| `Makefile` | make | 타겟 목록 |
| `Cargo.toml` | Rust/cargo | cargo 명령 |
| `pyproject.toml` | Python/poetry | scripts 섹션 |
| `build.gradle` / `build.gradle.kts` | Gradle | 태스크 목록 |
| `CMakeLists.txt` | CMake | 빌드 명령 |
| `Podfile` | CocoaPods | pod 명령 |
| `*.xcodeproj` | Xcode | xcodebuild 명령 |
| `go.mod` | Go | go 명령 |

---

## CONTEXT.md 작성 표준

### 목적

해당 디렉토리의 **"왜(Why)"**를 설명한다. 코드가 무엇을 하는지(What)가 아니라, 왜 이런 구조와 패턴을 선택했는지를 기술한다.

### 권장 구조

```markdown
# [디렉토리명] Context

## Purpose
이 디렉토리의 존재 이유와 역할.

## Architecture
핵심 설계 결정과 그 이유.

## Key Files
- `handler.ts` — 요청 처리 진입점
- `middleware/` — 인증, 로깅 등 미들웨어 체인
- `types.ts` — 도메인 타입 정의

## Patterns
이 디렉토리에서만 적용되는 고유 패턴.

## Dependencies
- 상위: `../CONTEXT.md` 참조
- 하위: `./auth/CONTEXT.md`, `./users/CONTEXT.md`

## Gotchas
주의할 점, 함정, 비직관적 동작.
```

### 계층 간 링크

CONTEXT.md는 상위/하위 CONTEXT.md로의 링크를 포함하여 탐색 경로를 제공한다:

```markdown
## Related Contexts
- **상위**: [프로젝트 전체](../../CLAUDE.md)
- **동급**: [API 컨텍스트](../api/CONTEXT.md)
- **하위**: [인증 컨텍스트](./auth/CONTEXT.md)
```

---

## AGENTS.md 작성 표준

### 목적

Cursor, Aider, GitHub Copilot, Claude Code 등 다양한 AI 도구가 공통으로 참조하는 범용 지침.

### 권장 구조

```markdown
# Agent Guidelines

## Project Overview
프로젝트 개요 (1-2 문단)

## Development Setup
환경 구성 명령

## Code Style
핵심 코딩 규칙 (린터로 자동화되지 않는 것만)

## Testing
테스트 실행 방법과 핵심 원칙

## Architecture
고수준 아키텍처 개요

## Common Tasks
자주 수행하는 작업의 절차
```

### CLAUDE.md vs AGENTS.md 차이

| 항목 | CLAUDE.md | AGENTS.md |
|------|-----------|-----------|
| 대상 | Claude Code 전용 | 모든 AI 도구 |
| 형식 | Claude 최적화 | 순수 마크다운 |
| 위치 | 프로젝트 루트 | 프로젝트 루트 |
| 크기 | ≤200라인 | 제한 없음 (간결 권장) |
| 내용 | 도구별 명령, 환경변수 | 범용 개발 지침 |
