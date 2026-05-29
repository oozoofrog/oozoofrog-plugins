---
name: wiki-query
description: "Search the wiki and synthesize an answer — index-based page discovery, reading related pages, generating cited answers. Use for requests like \"위키 검색\", \"wiki query\", \"위키에서 찾아\", \"wiki search\", \"위키 질문\", \"지식 검색\", \"wiki ask\", \"위키에 물어봐\", \"knowledge query\", \"위키 조회\", \"wiki find\"."
argument-hint: "<question> [--save: save the answer as a wiki page]"
---

<example>
user: "/wiki-query 인증 흐름이 어떻게 동작하나?"
assistant: "위키에서 인증 관련 페이지를 검색하겠습니다."
</example>

<example>
user: "위키에서 API 게이트웨이에 대해 찾아줘"
assistant: "인덱스를 검색하여 API 게이트웨이 관련 페이지를 찾겠습니다."
</example>

<example>
user: "/wiki-query 데이터 흐름 --save"
assistant: "데이터 흐름을 검색하고, 답변을 위키 페이지로 저장하겠습니다."
</example>

<example>
user: "위키에 캐싱 전략에 대한 내용 있어?"
assistant: "인덱스에서 캐싱 관련 페이지를 검색하겠습니다."
</example>

<example>
user: "/wiki-query JWT와 세션 인증의 차이점은? --save"
assistant: "두 인증 방식을 비교 분석하고 결과를 위키에 저장하겠습니다."
</example>

# Wiki Query

Search the wiki and synthesize a cited answer from related pages.

> **Core principle**: The wiki is a knowledge base where cross-referencing and synthesis are already done. Answer from the wiki's accumulated knowledge instead of re-deriving from the source each time. Save good answers back to the wiki so discovery accumulates.

Respond to the user in Korean.

## Argument Parsing

- Remove `--save` from `$ARGUMENTS` → the rest is the question
- If `--save` is present, run Phase 4 (save answer)
- If `$ARGUMENTS` is empty, ask the user for the question

## Execution Steps

### Phase 0: Wiki Existence Check

1. Check that the `.wiki/` directory exists
   - If missing: print "위키가 초기화되지 않았습니다. `/wiki-init`를 먼저 실행하세요." and stop
2. Read `.wiki/schema.md` — understand the wiki structure
3. Read `.wiki/index.md` — get the full page list

### Phase 1: Discovery

Analyze the question to find related pages:

1. **Index-based matching**:
   - Extract the key terms from the question
   - Match against page titles, descriptions, and tags in `index.md`
   - Sort candidate pages by relevance

2. **Alias matching**:
   - Check whether terms in the question match a page's `aliases`
   - Match Korean and English in both directions

3. **Read candidate pages**:
   - `Read` the top candidate pages (up to 10)
   - Evaluate each page's relevance

4. **Cross-reference chain traversal**:
   - Follow `[[wikilinks]]` in the pages you read to find more related pages
   - Traverse 1-hop links (from A → B, also read B)
   - `Read` the additional related pages found (up to 5 more)

5. **Grep fallback search** (when index matching is insufficient):
   - Search keywords directly in `.wiki/pages/` with `Grep`
   - Find pages the index missed

### Phase 2: Answer Synthesis

Combine the pages found into an answer:

1. **Answer structure**:
   ```markdown
   ## 답변

   [질문에 대한 종합 답변]

   ### 근거

   [답변을 뒷받침하는 위키 페이지 인용]
   - [[page-1]]: [인용 내용 요약]
   - [[page-2]]: [인용 내용 요약]

   ### 참고
   - [[추가 관련 페이지]]
   ```

2. **Answer quality rules**:
   - **Cite every claim**: include a wiki page reference for each claim, so the answer stays traceable to the wiki and the user can verify it.
   - **Confidence**: high confidence when multiple pages support a claim; flag single-source claims.
   - **Gap flagging + api-learn fallback**: when the wiki lacks needed information:
     1. Check whether `.claude/references/` exists
     2. If it exists, search that directory for relevant references with `Grep`
     3. If found in the references, cite that content and mark it "📚 출처: `.claude/references/{lib}.md` (api-learn)"
     4. If not in the references either, print "위키와 API 레퍼런스 모두에 해당 정보가 없습니다. `/wiki-ingest`로 소스를 추가하세요."
   - **Contradiction flagging**: if wiki pages contradict each other, cite both and state the contradiction.
   - **Query Precedence** (priority by question type):
     - API signature/parameter/usage questions → `.claude/references/` first, wiki secondary
     - Project context/architecture/relationship/comparison questions → `.wiki/` first, references secondary
     - Mixed questions → synthesize from both

3. **Answer format adaptation**:
   - Comparison question → comparison table
   - "How" question → step-by-step explanation
   - "Why" question → cause-effect explanation
   - List question → bulleted list

### Phase 3: Answer Output

Output the synthesized answer to the user.

If `--save` is **not** present, stop here.

### Phase 4: Save Answer (--save)

Run only when `--save` is present:

1. **Create the page**:
   - Type: `analysis`
   - Filename: question converted to kebab-case (max 64 chars)
   - frontmatter: title (question summary), type (analysis), references (list of wiki pages referenced, without extensions), tags
   - **Note**: analysis pages use `references` (wiki page references), not `sources` (original source files)
   - Body: the answer synthesized in Phase 2, formatted to the page format

2. **Update the index**:
   - Add the new page to the "분석 (Analysis)" category in `index.md`
   - Update the frontmatter counts

3. **Update cross-references**:
   - Add a back-reference to the new analysis page in the related sections of the pages you referenced

4. **Log**:
   - Append a query + save entry to `log.md`

5. **Save confirmation**:
   ```
   답변을 [[{page-name}]]으로 저장했습니다.
   ```

## Rules

- Do not pretend to know information that is not in the wiki — provide only wiki-based answers, and guide the user to add sources (`/wiki-ingest`) when external knowledge is needed.
- Always cite at least one wiki page, so every answer is traceable to the wiki and the user can verify it.
- Analysis pages saved with `--save` also accumulate as part of the wiki.
- Language: respond in Korean.
