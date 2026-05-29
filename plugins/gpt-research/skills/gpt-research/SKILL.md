---
name: gpt-research
description: Extracts project context into a structured research prompt for GPT-PRO and copies it to the clipboard. Use for requests that delegate research to GPT or extract project context as a structured prompt, such as "GPT에 물어봐", "GPT 리서치", "GPT-PRO", "리서치 위임", "컨텍스트 추출", "gpt research", "GPT에게 넘겨", "GPT한테 질문", "GPT 프롬프트", "research prompt", "컨텍스트 뽑아줘", "GPT용 프롬프트", "외부 리서치", "프롬프트 생성", "GPT 위임".
argument-hint: "[module|arch|issue|custom] [target path or description]"
---

<example>
user: "이 모듈에 대해 GPT에 물어보게 컨텍스트 뽑아줘 src/auth/"
assistant: "module 모드로 src/auth/ 디렉토리의 소스, 의존성, 인터페이스를 추출하여 GPT-PRO 리서치 프롬프트를 생성하겠습니다."
</example>

<example>
user: "프로젝트 아키텍처를 GPT-PRO한테 분석시키고 싶어"
assistant: "arch 모드로 프로젝트 전체 구조, 의존성 그래프, 빌드 시스템을 요약하여 리서치 프롬프트를 클립보드에 복사하겠습니다."
</example>

<example>
user: "이 에러 GPT한테 넘겨서 원인 분석 받자: TypeError: Cannot read properties of undefined"
assistant: "issue 모드로 에러 관련 소스, 콜체인, git 히스토리를 추출하여 GPT-PRO 리서치 프롬프트를 구성하겠습니다."
</example>

<example>
user: "GPT 리서치용 프롬프트 만들어줘, 내가 범위 지정할게"
assistant: "custom 모드로 진행합니다. 어떤 파일이나 주제를 포함할지 알려주세요."
</example>

# GPT-PRO Research Prompt Generator

Extract a specific part of the project (module, architecture, or issue) into a **structured research prompt** to delegate to GPT-PRO, and copy it to the clipboard (`pbcopy`).

Respond to the user in Korean.

## The Four Modes

### 1. `module` — Module/File Analysis

Collect context centered on a specific module or file.

**What to collect:**
- Full contents of the target source files
- Imported/dependency files (1 level deep)
- Protocol/interface/type definitions
- Related test files
- Package/module declarations (Package.swift, package.json, Cargo.toml, etc.)

**Detection strategy:**
1. Glob all source files under the target path
2. Parse import statements in each file → Glob the dependency files
3. Grep for protocol/interface keywords
4. Match test files with the patterns `*Test*`, `*Spec*`, `*_test*`

### 2. `arch` — Architecture Analysis

Summarize the overall project structure and design.

**What to collect:**
- Directory tree (depth 3, excluding: node_modules, .git, build, .build, DerivedData, Pods, venv, __pycache__)
- Project docs such as CLAUDE.md, README.md, ARCHITECTURE.md
- Dependency files (Package.swift, package.json, Podfile, Cargo.toml, go.mod, requirements.txt, etc.)
- Build system config (Makefile, Tuist, *.xcodeproj configuration, etc.)
- Key config files (.env.example, tsconfig.json, .swiftlint.yml, etc.)

### 3. `issue` — Issue/Error Analysis

Collect the context around an error or bug.

**What to collect:**
- Source files referenced in the error message or stack trace
- Grep results for the error string (file + surrounding context)
- Call chain tracing (callers/callees)
- Related test files
- Recent git history (last 10 commits for the relevant files)
- Environment info (OS, runtime version, dependency versions)

### 4. `custom` — User-Specified

The user specifies the scope interactively.

**Flow:**
1. Ask the user which files/directories/topics to include
2. Collect file contents for the selected scope
3. Have the user enter the research question directly
4. Assemble the prompt, then copy to clipboard

## Output Format

The generated prompt has a four-section structure:

```
# GPT-PRO Research Request

## Role
[모드에 따른 역할 지정]

## Context
[추출된 프로젝트 맥락 — 파일 경로 헤더 + 코드 블록]

## Research Request
[구체적 리서치 질문]

## Expected Output
[GPT-PRO 응답 envelope 포맷 지정]
```

### GPT-PRO Response Envelope

In the Expected Output section, request the following **structured response format** from GPT-PRO:

| Section | Required | Content |
|------|------|------|
| **Summary** | O | Key summary of the analysis in 3 lines or fewer |
| **Findings** | O | Per-mode analysis body (including file paths + line numbers) |
| **Code Suggestions** | △ | Code change suggestions — file path, line, change type, code block |
| **Action Items** | O | P0-Critical / P1-Important / P2-Suggestion priority checklist |
| **References** | △ | External reference material |

This format is designed so that pasting the GPT-PRO response into Claude Code lets follow-up work begin immediately.

See `references/output-templates.md` for the detailed template.

## Execution Flow

```
1. Determine mode
   ├─ Specified via argument → that mode
   ├─ No argument + error message present → issue
   ├─ No argument + file/directory specified → module
   └─ No argument + scope unclear → ask the user for the mode

2. Detect target
   ├─ module: path → Glob → source file list
   ├─ arch: project root → directory tree + core files
   ├─ issue: parse error message → locate related files
   └─ custom: wait for user input

3. Collect context
   ├─ Read files per each mode's strategy
   └─ Reference: references/context-extraction-guide.md

4. Validate size
   ├─ < 100K chars: proceed normally
   ├─ 100K~200K chars: show warning + suggest trimming
   └─ > 200K chars: hard limit → auto-trim or chunk
   └─ Reference: references/size-limits-and-chunking.md

5. Build prompt
   ├─ Assemble into the four-section structure
   ├─ Reference: references/output-templates.md
   └─ Reference: references/prompting-best-practices.md

6. Copy to clipboard
   └─ echo "..." | pbcopy

7. Report result
   ├─ List of included files
   ├─ Total char count / estimated token count
   ├─ Whether chunked (if applicable)
   └─ "클립보드에 복사되었습니다. GPT-PRO에 붙여넣기 하세요."
```

## Size Management

| Tier | Size | Handling |
|------|------|------|
| Small | < 30K chars | Use as-is |
| Medium | 30K~100K chars | Use as-is |
| Large | 100K~200K chars | Warning + suggest trimming |
| Oversized | > 200K chars | Auto-trim or chunk |

**Trimming priority** (keep the highest first):
1. Core source code
2. Interface/protocol definitions
3. Error logs/stack traces
4. Config files
5. Test code
6. Documentation
7. Dependency files

See `references/size-limits-and-chunking.md` for the detailed strategy.

## Codex Research Sidecar (Optional)

Only when the Codex skill is installed and the user explicitly asks for it, you may run `/codex:rescue` **in parallel** with GPT-PRO prompt generation.

### When to Use
- The user explicitly asks, e.g. "codex도 같이 돌려줘", "codex로도 확인해줘"
- Or propose it as a fallback when GPT-PRO is unavailable

### How to Run
1. After the existing prompt generation (pbcopy) completes
2. Dispatch the `codex:codex-rescue` subagent in the background (read-only, without `--write`):
   - Task: pass along the prompt's Expected Output summary as-is
3. Check progress with `/codex:status`, collect results with `/codex:result`
4. Report the Codex result to the user separately (do not mix it with the existing pbcopy prompt)

> **Guardrail**: The essence of this skill is GPT-PRO handoff + pbcopy. Codex is a **sidecar/fallback, not a full replacement**. Do not run Codex automatically without an explicit user request.

## Key Rules

- **Read-only**: Do not modify project files. Only read and search.
- **pbcopy**: Copy the result to the clipboard with `pbcopy` — this is the skill's delivery contract.
- **Korean explanations**: Write the prompt's explanatory parts in Korean, and keep code and technical terms in their original form.
- **One-way**: Scope ends at context extraction and prompt generation. Handling the GPT response is out of scope.

## References

- `references/output-templates.md` — Output format templates
- `references/context-extraction-guide.md` — Per-mode context extraction strategies
- `references/prompting-best-practices.md` — GPT-PRO prompting best practices
- `references/size-limits-and-chunking.md` — Size management and chunking guide
