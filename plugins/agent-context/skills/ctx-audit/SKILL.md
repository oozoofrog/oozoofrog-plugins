---
name: ctx-audit
description: Audits token efficiency of a context architecture — analyzes CLAUDE.md conciseness, hierarchy depth, information duplication, and context distribution, then suggests improvements. 컨텍스트 감사, 토큰 효율성, CLAUDE.md 간결성, 계층 구조, 정보 중복, 컨텍스트 분산.
---

# Context Architecture Audit

Audit the token efficiency of a context architecture end to end. For detailed optimization techniques, see the `guide` skill's `references/token-optimization.md`.

Respond to the user in Korean.

## Execution Steps

### Step 1: CLAUDE.md conciseness audit

1. Read the project root CLAUDE.md and analyze its information density.
2. Check for:
   - Frequently changing information
   - Whether detailed docs are properly distributed via `@` import, subdirectory CLAUDE.md, or `.claude/rules/`
   - Style rules that a linter could automate instead
   - Noise such as standard-library explanations
3. If the content is long, propose concrete ways to distribute it.

Example output:
```markdown
## CLAUDE.md 간결성 감사

**현재**: 285라인 — 분산 권장

### 분산 권장 섹션
| 섹션 | 라인 수 | 분산 방법 |
|------|---------|-----------|
| API 명세 | 42라인 | → `@src/api/API-GUIDE.md` import 또는 `src/api/CLAUDE.md` |
| 테스트 전략 | 28라인 | → `.claude/rules/testing.md` (glob: `tests/**`) |
| 스타일 가이드 | 15라인 | → 린터 설정으로 대체 (삭제) |
```

### Step 2: Hierarchy analysis

1. Collect context files across the whole project:
   - `**/CLAUDE.md` (auto-loaded by Claude Code)
   - `.claude/rules/*.md` (path-scoped rules)
   - `**/CONTEXT.md` (for manual reference)
   - `/AGENTS.md` (for other-tool compatibility)
2. Classify by directory depth:
   - Layer 0: `/CLAUDE.md`, `/AGENTS.md`, `.claude/rules/`
   - Layer 1: one level down, e.g. `/src/CLAUDE.md`
   - Layer 2: two levels down, e.g. `/src/api/CLAUDE.md`
   - Layer 3+: deeper layers
3. Verdict:
   - ✅ **≤3 levels**: optimal
   - ⚠️ **4 levels**: caution — rising complexity
   - ❌ **>4 levels**: excessive — consider merging

Example output:
```markdown
## 계층 구조 분석

**계층 깊이**: 3 레벨 ✅

| 레이어 | 파일 수 | 파일 목록 |
|--------|---------|-----------|
| Layer 0 | 2 | CLAUDE.md, AGENTS.md |
| Layer 1 | 3 | src/, tests/, docs/ |
| Layer 2 | 5 | src/api/, src/components/, ... |
| Layer 3 | 2 | src/api/auth/, src/api/users/ |
```

### Step 3: Information duplication detection

1. Extract key keywords/phrases from each context file.
2. Detect duplicated content across files:
   - The same build command appearing in multiple files
   - The same architecture description repeated
   - Identical content in both a parent and a child file
3. Propose how to deduplicate.

### Step 4: Context coverage analysis

1. Collect the project's main directories.
2. For each directory, check whether a context file exists (CLAUDE.md, a matching `.claude/rules/` rule, or CONTEXT.md).
3. Identify directories that lack context but should have it:
   - Directories with 10+ source files
   - Directories holding independent domain logic
4. Also identify directories that carry an unnecessary context file:
   - Directories with only 1–2 files
   - Cases where the parent context is sufficient

### Step 5: Comprehensive audit report

```markdown
# 컨텍스트 아키텍처 토큰 효율성 감사 리포트

## 요약 점수
| 항목 | 점수 | 상태 |
|------|------|------|
| CLAUDE.md 간결성 | 양호 | ✅ |
| 계층 깊이 | 최적 | ✅ |
| 정보 중복 | 2건 발견 | ⚠️ |
| 커버리지 | 80% | 🟡 |

## 전체 효율성 등급: B+ (양호)

## 개선 제안 (우선순위순)
1. CLAUDE.md의 API 명세를 `@` import 또는 `src/api/CLAUDE.md`로 분산
2. CLAUDE.md와 서브디렉토리 CLAUDE.md의 빌드 명령 중복 제거
3. src/services/ 디렉토리에 CLAUDE.md 또는 `.claude/rules/` 규칙 추가 권장
```
