# Mode Detection Rules

## Priority

write > suggest > review > read (default)

Match the keywords below against the prompt in order. The first matching mode wins.

## write keywords (intent to change files)

| Korean | English |
|--------|---------|
| 작성, 생성, 만들어 | create, write |
| 수정, 변경, 바꿔 | modify, change, update |
| 리팩토링해, 리팩터링해 | refactor |
| 삭제, 제거 | delete, remove |
| 추가, 구현, 고쳐 | add, implement, fix |

**Core criterion:** whether the verb directly commands a file-modifying action.
- "리팩토링해줘" → write (direct action command)
- "리팩토링 방법 알려줘" → suggest (question about method)

## suggest keywords (request for proposal/advice)

| Korean | English |
|--------|---------|
| 제안, 개선점, 추천, 대안 | suggest, recommend, alternative |
| 방법, 어떻게, 알려줘 | how to, approach, advice |

## review keywords (code review only — uses `codex review`)

| Korean | English |
|--------|---------|
| 리뷰, 코드 리뷰, 코드리뷰 | review, code review |

**review vs read:** if "리뷰" explicitly refers to a code review, use review mode; otherwise read.

## read keywords (default)

If nothing matches write/suggest/review, the mode is read.

Reference keywords (for confirmation):

| Korean | English |
|--------|---------|
| 분석, 설명 | analyze, explain |
| 검색, 찾아, 보여줘, 확인 | search, find, show, check |

## Ambiguous case examples

| Prompt | Mode | Reason |
|--------|------|--------|
| "이 코드 리뷰해줘" | review | code review → `codex review` |
| "버그 찾아줘" | read | 찾아 = read |
| "리팩토링 방법 알려줘" | suggest | 방법 + 알려줘 |
| "개선점 추천해줘" | suggest | 추천 |
| "리팩토링해줘" | write | direct action command |
| "테스트 작성해줘" | write | 작성 |
| "이 함수 고쳐줘" | write | 고쳐 |
| "이 코드 어떻게 개선할 수 있을까?" | suggest | 어떻게 |
