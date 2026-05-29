# Size Management and Chunking Guide

## GPT-PRO Practical Context Limits

GPT-PRO can process large contexts, but for practical quality the following limits are recommended:

| Limit | Characters | Approx. tokens | Notes |
|------|---------|---------------|------|
| Optimal | ~50K | ~15K tokens | Most accurate analysis |
| Good | ~100K | ~30K tokens | Analysis quality maintained |
| Warning | ~150K | ~45K tokens | May miss details |
| Hard limit | 200K | ~60K tokens | Must trim or chunk if exceeded |

---

## Character-to-Token Conversion Approximation

| Content type | Chars/token ratio | Description |
|-------------|---------------|------|
| English text | ~4 chars/token | Typical English prose |
| Korean text | ~2 chars/token | Hangul uses fewer chars per token |
| Source code | ~3.5 chars/token | Mix of keywords, identifiers, symbols |
| Mixed (code + Korean description) | ~3 chars/token | Typical output of this skill |

**Quick estimate**: total characters ÷ 3 ≈ expected tokens

---

## Processing by Size Tier

### Small (< 30K chars, ~10K tokens)

- Processing: use as-is
- Message: none

### Medium (30K ~ 100K chars, ~10K~30K tokens)

- Processing: use as-is
- Message: show size info in result report

### Large (100K ~ 200K chars, ~30K~60K tokens)

- Processing: warning + trimming suggestion
- Message:

```
⚠️ 컨텍스트 크기: {N}K 문자 (약 {M}K 토큰)
GPT-PRO의 분석 정확도를 위해 트리밍을 권장합니다.

제거 후보:
- {파일명} ({크기}K) — {제거 이유}
- {파일명} ({크기}K) — {제거 이유}

트리밍 없이 진행하시겠습니까? (y/n)
```

### Oversized (> 200K chars, ~60K+ tokens)

- Processing: auto-trim or chunk (user choice)
- Options offered:

```
🚫 컨텍스트 크기 초과: {N}K 문자 (약 {M}K 토큰)
200K 문자 하드 리밋을 초과했습니다.

옵션:
1. 자동 트리밍 — 우선순위에 따라 {제거 대상 크기}K 문자 제거
2. 청킹 — {청크 수}개의 프롬프트로 분할
3. 수동 조정 — 포함할 파일을 직접 선택

어떤 옵션으로 진행하시겠습니까?
```

---

## Trimming Priority

From highest priority (keep) to lowest priority (removable):

| Rank | Category | Description | Impact if removed |
|------|----------|------|-------------|
| 1 | Core source code | Direct target of the question/issue | Critical — analysis impossible |
| 2 | Interface/protocol | Contract the target implements/uses | High — context loss |
| 3 | Error log/stack trace | Direct evidence of the error (issue mode) | High — hard to trace cause |
| 4 | Config files | Build/environment settings | Medium — environment context loss |
| 5 | Test code | Evidence of current behavior | Medium — reduced behavior understanding |
| 6 | Project docs | README, ARCHITECTURE, etc. | Low — can be explained otherwise |
| 7 | Dependency files | package.json, Podfile, etc. | Low — a list alone suffices |

### Trimming Strategies

1. **Summarize dependency files**: remove lock files, list package names only
2. **Condense docs**: first 1K chars + "... (truncated)"
3. **Signaturize tests**: keep test function signatures only, remove bodies
4. **Config essentials only**: extract only relevant config keys
5. **Signaturize code**: last resort — keep function/class signatures only

---

## Chunking Strategy

### Self-Contained Chunk Principle

Each chunk should be understandable as independently as possible:

- Do not split a single module/file
- Place related files (interface + implementation) in the same chunk
- Place tests in the same chunk as their target code

### Chunk Size

- Target: 100K~150K chars per chunk
- Minimum: 30K chars (too small lacks context)
- Maximum: 180K chars (keep headroom)

### Chunk Splitting Algorithm

```
1. 모든 파일을 카테고리별로 그룹화
   (핵심 소스 / 인터페이스 / 테스트 / 설정 / 문서)

2. 관련 파일끼리 묶기
   (같은 모듈, import 관계, 클래스-테스트 쌍)

3. 묶음 단위로 청크에 배치
   - 첫 번째 청크: 핵심 소스 + 직접 인터페이스
   - 두 번째 청크: 의존 모듈 + 테스트
   - 세 번째 청크: 설정 + 문서 + 나머지

4. 각 청크에 교차참조 헤더 추가
```

### Cross-Reference Header

Specifies relationships between chunks:

```
> 📎 이 파트에서 참조되는 파일 중 다른 파트에 포함된 것:
> - `AuthManager.swift` → Part 1 참조
> - `TokenStore.swift` → Part 1 참조
```

---

## Size Measurement Method

After assembling the prompt, measure with Bash:

```bash
# 변수에 프롬프트가 저장된 경우
echo -n "$PROMPT" | wc -c

# 파일에 저장된 경우
wc -c < /tmp/gpt-research-prompt.txt
```

Show in result report:

```
📋 클립보드에 복사되었습니다.
   크기: {N}K 문자 (약 {M}K 토큰)
   파일 {F}개 포함
   {청킹 여부 메시지}
```
