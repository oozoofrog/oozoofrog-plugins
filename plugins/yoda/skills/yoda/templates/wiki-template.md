# Wiki Output Template

Structure template for the `--format wiki` output of yoda share mode. If a Confluence MCP server is connected, publish directly; otherwise generate as markdown.

---

## Content Structure (4-act narrative structure)

```
┌─────────────────────────────────────────┐
│ 제목 + TL;DR                            │
├─────────────────────────────────────────┤
│ Context: 배경 설명                       │
├─────────────────────────────────────────┤
│ The Story                               │
│  ├─ 발단: 문제 발생 상황                  │
│  ├─ 전개: 원인 탐색 과정                  │
│  ├─ 절정: Before/After/Why 핵심 발견     │
│  └─ 결말: 해결과 교훈                    │
├─────────────────────────────────────────┤
│ 핵심 교훈 + Gotchas + 토론 질문          │
└─────────────────────────────────────────┘
```

### 4-act detail

| Act | Purpose | Learning-science principle |
|----|------|-------------|
| 발단 | Build rapport, spark interest | Storytelling (Zak oxytocin/narrative) |
| 전개 | Model analytical thinking | Cognitive apprenticeship (Collins et al.) |
| 절정 | Deliver the learning core | Before/After/Why triple + adjacent principles |
| 결말 | Drive practice, team discussion | Social constructivism (Vygotsky) |

### Discussion questions (social constructivism)

Three questions to elicit comments/feedback from teammates:

1. **정교화 질문** — "이 패턴을 우리 프로젝트의 {구체적 모듈}에 적용한다면?"
2. **대안 질문** — "이 문제에 대해 다른 접근법을 경험해보신 분이 있다면 공유해주세요."
3. **확장 질문** — "이 원칙이 깨지는 정당한 예외 상황은 언제일까요?"

---

## Storage path

```
docs/yoda/YYYY-MM-DD-{slug}-wiki.md
```
