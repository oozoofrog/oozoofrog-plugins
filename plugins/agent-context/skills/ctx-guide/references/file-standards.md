# File Standards Detailed Guide

## CLAUDE.md Authoring Standard

### Required Sections

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

### Conciseness Strategy

Keep CLAUDE.md concise. When content grows long, distribute it using these methods:

1. **Use `@` import** → reference external files from CLAUDE.md as `@src/API-GUIDE.md`
2. **Subdirectory CLAUDE.md** → create `src/CLAUDE.md`, `src/api/CLAUDE.md` (on-demand loading when that directory is accessed)
3. **Use `.claude/rules/`** → auto-apply per-path rules based on glob patterns (e.g., `src/api/**` pattern in `.claude/rules/api.md`)
4. **Style guide** → replace with linter config (remove)

> **Note**: CLAUDE.md is reloaded from disk after compaction, so it survives regardless of file length. The purpose of conciseness is to improve information density and adherence rate.

### Auto-Detectable Build Tools

The init command detects the following files to auto-extract build/test commands:

| File | Tool | Extraction Target |
|------|------|-----------|
| `package.json` | npm/yarn/pnpm | scripts section |
| `Makefile` | make | target list |
| `Cargo.toml` | Rust/cargo | cargo commands |
| `pyproject.toml` | Python/poetry | scripts section |
| `build.gradle` / `build.gradle.kts` | Gradle | task list |
| `CMakeLists.txt` | CMake | build commands |
| `Podfile` | CocoaPods | pod commands |
| `*.xcodeproj` | Xcode | xcodebuild commands |
| `go.mod` | Go | go commands |

---

## CONTEXT.md Authoring Standard

> **Claude Code caveat**: Claude Code does not auto-load CONTEXT.md. If auto-loading is needed, use a subdirectory CLAUDE.md or `.claude/rules/`. Keep CONTEXT.md for compatibility with other tools such as Cursor, or use it by importing it from CLAUDE.md as `@CONTEXT.md`.

### Purpose

Explain the **"Why"** of the directory. Describe not what the code does (What), but why this structure and these patterns were chosen.

### Recommended Structure

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

### Inter-Layer Links

CONTEXT.md includes links to parent/child CONTEXT.md files to provide navigation paths:

```markdown
## Related Contexts
- **상위**: [프로젝트 전체](../../CLAUDE.md)
- **동급**: [API 컨텍스트](../api/CONTEXT.md)
- **하위**: [인증 컨텍스트](./auth/CONTEXT.md)
```

---

## AGENTS.md Authoring Standard

> **Claude Code caveat**: Claude Code does not auto-load AGENTS.md. Importing it from CLAUDE.md as `@AGENTS.md` shares the content.

### Purpose

General-purpose guidance commonly referenced by various AI tools such as Cursor, Aider, and GitHub Copilot. Claude Code uses CLAUDE.md as its dedicated format.

### Recommended Structure

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

### CLAUDE.md vs AGENTS.md Differences

| Item | CLAUDE.md | AGENTS.md |
|------|-----------|-----------|
| Target | Claude Code only | All AI tools (Cursor, Aider, etc.) |
| Format | Claude-optimized | Plain markdown |
| Location | Project root + subdirectories | Project root |
| Auto-loading | ✅ Hierarchical auto-loading | ❌ Not auto-loaded by Claude Code (`@` import required) |
| Size | Conciseness recommended (no limit) | No limit (conciseness recommended) |
| Content | Tool-specific commands, env vars | General-purpose development guidance |
