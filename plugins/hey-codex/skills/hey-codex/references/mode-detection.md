# 모드 판별 규칙

## 판별 우선순위

write > suggest > read (기본값)

프롬프트에서 아래 키워드를 순서대로 매칭합니다. 먼저 매칭되는 모드가 선택됩니다.

## write 키워드 (파일 변경 의도)

| 한국어 | 영어 |
|--------|------|
| 작성, 생성, 만들어 | create, write |
| 수정, 변경, 바꿔 | modify, change, update |
| 리팩토링해, 리팩터링해 | refactor |
| 삭제, 제거 | delete, remove |
| 추가, 구현, 고쳐 | add, implement, fix |

**핵심 판별 기준:** 동사가 파일 수정 행위를 직접 지시하는지 여부.
- "리팩토링해줘" → write (직접 행위 지시)
- "리팩토링 방법 알려줘" → suggest (방법 질문)

## suggest 키워드 (제안/조언 요청)

| 한국어 | 영어 |
|--------|------|
| 제안, 개선점, 추천, 대안 | suggest, recommend, alternative |
| 방법, 어떻게, 알려줘 | how to, approach, advice |

## read 키워드 (기본값)

write/suggest 어디에도 매칭되지 않으면 read 모드입니다.

참고 키워드 (확인용):

| 한국어 | 영어 |
|--------|------|
| 분석, 리뷰, 설명 | analyze, review, explain |
| 검색, 찾아, 보여줘, 확인 | search, find, show, check |

## 모호한 경우 예시

| 프롬프트 | 모드 | 이유 |
|----------|------|------|
| "이 코드 리뷰해줘" | read | 리뷰 = 읽기 |
| "버그 찾아줘" | read | 찾아 = 읽기 |
| "리팩토링 방법 알려줘" | suggest | 방법 + 알려줘 |
| "개선점 추천해줘" | suggest | 추천 |
| "리팩토링해줘" | write | 직접 행위 지시 |
| "테스트 작성해줘" | write | 작성 |
| "이 함수 고쳐줘" | write | 고쳐 |
| "이 코드 어떻게 개선할 수 있을까?" | suggest | 어떻게 |
