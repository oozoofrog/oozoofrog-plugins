---
name: ctx-guide
description: Guidance on designing hierarchical context architecture for large-scale projects — structuring CLAUDE.md, CONTEXT.md, AGENTS.md to maximize agent reasoning precision and token efficiency. Use when the user asks about "컨텍스트 아키텍처", "context architecture", "계층적 컨텍스트", "CONTEXT.md 설계", "주의력 예산", "attention budget", "컨텍스트 엔지니어링", "context engineering", "토큰 효율성", "컨텍스트 부패", "context rot", "점진적 노출", "progressive disclosure". Common requests include "CLAUDE.md가 너무 길어요", "프로젝트 컨텍스트 파일을 어떻게 구성하죠?", "My CLAUDE.md is too long", "Set up context architecture for my project".
---

# Hierarchical Context Architecture Guide

Design a hierarchical context architecture that maximizes an AI agent's reasoning precision in large-scale projects.

Respond to the user in Korean.

## Quick Start

To introduce context architecture into a project, follow these three steps:

1. **Initialize**: Run `/agent-context:ctx-init` — analyzes the project and generates CLAUDE.md, subdirectory CLAUDE.md, `.claude/rules/`, and AGENTS.md.
2. **Verify**: Run `/agent-context:ctx-verify` — validates reference integrity, code references, and content accuracy in three stages.
3. **Maintain**: Update context documents alongside code changes. Use `/agent-context:ctx-audit` to periodically audit token efficiency.

## Core Problem

LLMs operate under an **Attention Budget** constraint. As tokens grow, recall ability degrades — a phenomenon called **Context Rot**. The key is to structure information strategically so that only high-signal tokens are exposed.

## Two Fundamental Principles

### 1. Locality

Place information physically as close as possible to the code it describes. This is called **Structural Siloing**. Isolating a directory's context at that location keeps the AI focused on the current working domain.

### 2. Progressive Disclosure

Instead of injecting all data at once, use a **just-in-time (JIT) context strategy**. Keep only lightweight identifiers (file paths, metadata) initially, and load detailed context only when it is actually needed.

## Three-Tier File Standard

### CLAUDE.md — Project Root & Subdirectories (Layer 0-2)

The top-level persistent context at the project root. Keep it concise.

- **Compaction survival**: When conversation history is summarized, it is re-read from disk and re-injected (independent of file length).
- **Hierarchical loading**: Claude Code auto-loads the root CLAUDE.md at session start; subdirectory CLAUDE.md files are loaded on-demand when files in that directory are accessed.
- **`@` import**: Reference external files with the `@path/to/file` syntax (e.g., `@src/api/API-GUIDE.md`).
- **Include**: Build/test commands, architecture decisions, environment variables.
- **Exclude**: Frequently changing information, detailed API docs, style guides.

### `.claude/rules/` — Path-Specific Rules (Layer 1-2)

A native Claude Code feature. Rule files applied automatically via glob patterns when working on files at specific paths.

- **Auto-loading**: When a file path matches a glob pattern, the corresponding rule applies automatically.
- **Example**: `.claude/rules/api-rules.md` (pattern: `src/api/**`) → auto-loaded when working on API-related files.
- Can natively replace CONTEXT.md's "path-specific context" role.

### CONTEXT.md — Subsystem Context (for manual reference)

A hierarchical knowledge tree holding detailed per-subsystem domain knowledge.

> **Note**: Claude Code does **not auto-load** CONTEXT.md. It is loaded only when the agent explicitly Reads it, or when CLAUDE.md imports it via `@CONTEXT.md`. If auto-loading is needed, use a subdirectory CLAUDE.md or `.claude/rules/`.

- **Include**: The intent behind domain logic (Why), subsystem-specific patterns, links to lower-level knowledge.
- **Exclude**: Style rules a linter can handle, standard library explanations.
- **Cross-tool compatibility**: Maintains compatibility with tools that recognize CONTEXT.md, such as Cursor and Windsurf.

### AGENTS.md — Universal Portability (for cross-tool compatibility)

A universal standard referenced by various AI tools such as Cursor, Aider, and GitHub Copilot.

> **Note**: Claude Code does **not auto-load** AGENTS.md. Importing it from CLAUDE.md via `@AGENTS.md` shares its content.

- **Include**: General agent instructions, markdown-based collaboration rules.
- **Exclude**: Complex metadata, tool-specific configuration values.

## Layered Discovery Mechanism

Claude Code discovers CLAUDE.md files hierarchically. More specific lower-level guidance takes precedence over more general higher-level guidance.

**Claude Code's actual auto-loading behavior:**

```
e.g. when working on src/api/auth.ts

[auto-loaded at session start]
Layer 0: /CLAUDE.md              ← architecture standards, tool commands

[on-demand loading when the file is accessed]
Layer 1: /src/CLAUDE.md          ← source folder structure, data flow
Layer 2: /src/api/CLAUDE.md      ← API spec, auth logic specifics

[auto-loaded on glob pattern match]
Rules:  .claude/rules/api.md     ← rule matching the src/api/** pattern

[always accessible]
Layer 3: src/api/auth.ts         ← code, diff, test results
```

> **Note**: CONTEXT.md and AGENTS.md are not auto-loaded. Access them via `@` import or an explicit Read.

## Token Optimization Techniques

### Prevent Instruction Leakage with XML Tagging

XML tags make the boundary between data and instructions clear, improving instruction-following precision. This prevents Instruction Leakage, where data is mistaken for instructions:

```xml
<instructions>
  Place core guidelines here
</instructions>
<data>
  Isolate tool outputs, logs, etc. here
</data>
```

### Prompt Caching (Prefix Preservation)

> **Note**: The Claude Code CLI manages prompt caching internally. The following applies when using the Claude API directly.

Place static instructions (such as CLAUDE.md) at the front of the prompt to maximize cache hits. Place dynamic questions and real-time logs at the end.

### Anchored Recurring Summaries

When the conversation history limit is reached, anchor key architecture decisions and unresolved bug status, and compress tool execution results.

## Fix the Rules Loop

When an agent makes a mistake, update the context document that caused the error rather than fixing only the code, since unfixed rules cause the same mistake to repeat. Context is a compile-time dependency on par with source code.

**Example**: If an agent wrote Redux code in a project where CLAUDE.md states "use Zustand", then after fixing the code, also update that statement in CLAUDE.md to "Redux → Zustand migration in progress".

## Three-Stage Verification

Run the following verification periodically to maintain knowledge-tree integrity:

1. **Reference integrity**: Whether linked context files (CLAUDE.md, CONTEXT.md, `.claude/rules/`) actually exist, validity of `@` imports, detection of orphaned files.
2. **Code reference validation**: Confirm that file paths in the context match the actual implementation.
3. **Content accuracy**: Verify that technical claims match the actual patterns in the current codebase.

## Available Skills

This plugin provides the following skills:

- **`/agent-context:ctx-init`** — Use when introducing context architecture into a new project, or augmenting context files in an existing one. Auto-detects build tools and generates CLAUDE.md, subdirectory CLAUDE.md, `.claude/rules/`, and AGENTS.md.
- **`/agent-context:ctx-verify`** — Use to confirm that context documents are in sync with the code. Run after refactoring, file moves, or dependency changes. Passing a stage number (1/2/3) as an argument runs only that stage.
- **`/agent-context:ctx-audit`** — Use when CLAUDE.md has grown bloated or the hierarchy has become complex. Detects lack of conciseness, information duplication, and coverage gaps, and proposes improvements.

## Additional Resources

### Reference Files

For detailed guides, see the following reference files:

- **`references/file-standards.md`** — Authoring standards and templates for CLAUDE.md, CONTEXT.md, AGENTS.md.
- **`references/token-optimization.md`** — Details on XML tagging, prompt caching, and summarization strategies.
- **`references/verification-guide.md`** — The three-stage verification procedure and automation script guide.
