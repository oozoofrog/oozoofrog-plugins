---
name: ctx-init
description: Analyze the project and scaffold a layered context architecture made of CLAUDE.md, subdirectory CLAUDE.md, .claude/rules/, and AGENTS.md. Preserve and augment existing files. Triggers — 컨텍스트 초기화, 컨텍스트 아키텍처, CLAUDE.md 생성, 스캐폴딩.
argument-hint: "[target directory (defaults to project root if omitted)]"
---

# Context Architecture Init

Initialize the project's layered context architecture. Preserve and augment existing files.

> **Claude Code context loading model**: Claude Code auto-loads CLAUDE.md and `.claude/rules/`. The root CLAUDE.md loads at session start, subdirectory CLAUDE.md loads on-demand when files in that directory are accessed, and `.claude/rules/` applies automatically on glob-pattern match. CONTEXT.md and AGENTS.md are not auto-loaded.

## Execution Steps

### Step 1: Project analysis

Detect the following from the project root:

1. **Build tool detection** — scan these files in order:
   - `package.json` → extract npm/yarn/pnpm scripts
   - `Makefile` → extract make targets
   - `Cargo.toml` → extract cargo commands
   - `pyproject.toml` → extract poetry/pip scripts
   - `build.gradle` / `build.gradle.kts` → extract gradle tasks
   - `CMakeLists.txt` → extract cmake build commands
   - `*.xcodeproj` / `Package.swift` → extract xcodebuild/swift commands
   - `go.mod` → extract go commands

2. **Directory structure analysis** — survey the directory tree at 1–2 levels deep to identify subsystem candidates. Use these patterns as a guide:
   - `src/`, `lib/`, `app/` — source code root
   - `api/`, `server/`, `routes/` — API/server layer
   - `components/`, `pages/`, `views/` — frontend layer
   - `services/`, `domain/`, `core/` — business logic
   - `tests/`, `__tests__/`, `spec/` — tests
   - `infra/`, `deploy/`, `terraform/` — infrastructure

3. **Existing context files** — check whether CLAUDE.md, CONTEXT.md, AGENTS.md already exist.

### Step 2: User confirmation

Summarize the analysis for the user.

Respond to the user in Korean.

```
## 프로젝트 분석 결과

**빌드 도구**: [감지된 도구]
**주요 서브시스템**: [식별된 서브시스템 목록]
**기존 컨텍스트 파일**: [있음/없음]

### 생성 계획
- [ ] /CLAUDE.md (신규 생성 / 보강)
- [ ] /AGENTS.md (신규 생성 / 보강)
- [ ] 서브시스템 컨텍스트 (CLAUDE.md / .claude/rules/ / CONTEXT.md 중 선택)
...

이 계획으로 진행할까요?
```

Proceed to the next steps only after the user approves the plan.

### Step 3: Create/augment CLAUDE.md

**If no file exists**: create a new one.

Reference: check the CLAUDE.md authoring standard in the `guide` skill's `references/file-standards.md`.

Core rules:
- Keep it concise (split long content into `@` imports or subdirectory CLAUDE.md files)
- Use the build/test commands detected in Step 1
- Infer architecture decisions from the code structure
- Write in Korean (comments, descriptions)

**If a file exists**: preserve existing content and augment with:
- Missing build/test commands
- A suggestion to split long content into `@` imports or subdirectory CLAUDE.md

### Step 4: Create/augment AGENTS.md

> **Note**: Claude Code does not auto-load AGENTS.md. It is created for compatibility with other AI tools such as Cursor and Aider. To use it in Claude Code, add `@AGENTS.md` to CLAUDE.md.

**If no file exists**: convert the core content of CLAUDE.md into generic markdown and create it.

**If a file exists**: preserve existing content and augment only the missing sections.

### Step 5: Create subsystem context

Guide the user to choose how context is distributed.

**Option A: Subdirectory CLAUDE.md (recommended — Claude Code auto-loads)**
- Create a `CLAUDE.md` in each subsystem directory
- Loads on-demand when files in that directory are accessed

**Option B: `.claude/rules/` (recommended — glob-pattern-based auto-apply)**
- Create rule files under the `.claude/rules/` directory
- Applies automatically based on file path patterns

**Option C: CONTEXT.md (for other-tool compatibility)**
- Create a `CONTEXT.md` in each subsystem directory
- Not auto-loaded in Claude Code (requires explicit Read or `@` import)
- Compatible with tools that recognize CONTEXT.md, such as Cursor and Windsurf

Common content:
- Describe the purpose and role of the directory
- List key files in a Key Files section
- Describe unique patterns or caveats

Skip directories that already contain a context file.

### Step 6: Result summary

Output the list of created/augmented files and the next steps.

Respond to the user in Korean.

```
## 컨텍스트 아키텍처 초기화 완료

### 생성된 파일
- /CLAUDE.md
- /AGENTS.md
- /src/CLAUDE.md (또는 .claude/rules/src.md)
- /src/api/CLAUDE.md (또는 .claude/rules/api.md)

### 다음 단계
1. 생성된 컨텍스트 파일의 내용을 검토하고 프로젝트 특성에 맞게 수정하세요.
2. `/agent-context:verify`로 검증을 실행하세요.
3. `/agent-context:audit`로 토큰 효율성을 확인하세요.
```
