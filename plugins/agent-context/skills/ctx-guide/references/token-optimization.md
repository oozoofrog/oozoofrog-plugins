# Token Efficiency Optimization Detailed Guide

## XML Structural Tagging

### Why XML?

Markdown has ambiguous structural boundaries, so when large amounts of data are included, the LLM may mistake data for instructions — a phenomenon called **Instruction Leakage**. XML tags provide clear boundaries, improving instruction-following precision.

### Tagging Patterns

#### Pattern 1: Separate Instructions from Data

```xml
<instructions>
  ## 핵심 규칙
  - 모든 API 엔드포인트는 RORO(Receive an Object, Return an Object) 패턴 준수
  - 에러 응답은 RFC 7807 (Problem Details) 형식
  - 인증 미들웨어를 모든 라우트에 적용
</instructions>

<data>
  [BUILD_LOG]
  src/api/handler.ts:45 - TypeError: Cannot read property 'id' of undefined
  src/api/handler.ts:78 - Warning: Unused variable 'tempResult'

  [TEST_RESULTS]
  Tests: 142 passed, 3 failed
  Failed: auth.test.ts, user.test.ts, api.test.ts
</data>
```

#### Pattern 2: Isolate Context Metadata

```xml
<context>
  현재 작업 경로: src/api/
  참조 컨텍스트: ../../CONTEXT.md
  최근 변경: auth.ts (3시간 전), middleware.ts (1일 전)
  관련 이슈: #142 (인증 토큰 갱신 로직 버그)
</context>

<instructions>
  위 컨텍스트를 참고하여 인증 토큰 갱신 로직을 수정한다.
  기존 세션 관리 방식은 유지하되, 토큰 만료 시 자동 갱신을 추가한다.
</instructions>
```

#### Pattern 3: Distinguish Multi-Source Data

```xml
<source name="current_code">
  // auth.ts 현재 구현
  export function validateToken(token: string) { ... }
</source>

<source name="test_output">
  FAIL src/auth.test.ts
  ✕ should refresh expired token (45ms)
</source>

<instructions>
  current_code의 validateToken 함수를 수정하여
  test_output의 실패 테스트를 통과시킨다.
</instructions>
```

---

## Prompt Caching Strategy

> **Note**: This section applies when using the Claude API directly. The Claude Code CLI manages prompt caching internally, so users cannot control it directly.

### Prefix Preservation Principle

Prompt caching in LLM APIs operates on a **prefix** basis. Requests sharing the same prefix can reuse the cache.

```
[캐시 가능 영역 - 변경 없음]
├── System Prompt
├── CLAUDE.md 내용
└── 정적 지침

[캐시 불가 영역 - 매번 변경]
├── 사용자 질문
├── 실시간 로그
└── 도구 실행 결과
```

### Practical Application (When Using the API)

1. **Place static instructions at the front of the prompt** — maximizes cache reuse
2. **Load context files only for relevant tasks** — prevents unnecessary cache invalidation
3. **Always place dynamic data last** — maximizes cache hit rate

---

## Anchored Iterative Summarization

### Preservation Targets (Anchor)

Information that must be preserved during compaction:

- Architectural decisions and their rationale
- Unresolved bug/issue status
- Goals and constraints of the current task
- Agreed-upon implementation direction

### Compression Targets

Information that can be safely compressed:

- Full output of tool executions → preserve only key results
- Exploratory code-reading results → preserve only discovered patterns
- Trial and error during debugging → preserve only the final cause and solution

### CLAUDE.md Compaction Survival

CLAUDE.md has a unique characteristic:

1. When the context window fills up, the conversation history is summarized
2. At this point the agent re-reads CLAUDE.md from disk
3. It is re-injected into the context in a fresh state
4. This survival works **independently of file length** — keeping it concise is for information density and compliance rate

> **Note**: Claude Code's Auto Memory system (v2.1.59+) also automatically records build commands, debugging patterns, architectural decisions, etc. across sessions. CLAUDE.md and Auto Memory are complementary.

---

## Token Efficiency Audit Checklist

### CLAUDE.md Audit

- [ ] Is it concise and high in information density?
- [ ] Does it avoid including frequently-changing information?
- [ ] Has detailed documentation been distributed to `@` imports, subdirectory CLAUDE.md, or `.claude/rules/`?
- [ ] Have style rules that can be automated by a linter been removed?

### Subdirectory CLAUDE.md / `.claude/rules/` Audit

- [ ] Does it focus on Why (intent)? (What is explained by the code)
- [ ] Are links between parent/child files valid?
- [ ] Is it free of noise such as standard library explanations?

### CONTEXT.md Audit (If Used)

- [ ] Is it acknowledged that it is not auto-loaded for Claude Code users?
- [ ] Is it clearly distinguished in CLAUDE.md as an `@` import or for compatibility with other tools?

### Full Hierarchy Audit

- [ ] Are there no orphaned context files?
- [ ] Does the depth not exceed 4 levels? (Layer 0–3 recommended)
- [ ] Is duplicated information not spread across multiple files?
