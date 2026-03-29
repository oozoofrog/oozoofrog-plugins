# Problem Framing

## 문제 정의

현재 저장소에는 여러 스킬이 존재하지만, 사용자가 자연어로 요청했을 때 Claude Code가 항상 최적 스킬을 고른다는 보장은 없다. 특히 다음 문제가 예상된다.

1. **동일 도메인 내 근접 스킬 충돌**
   - 예: `apple-craft` vs `apple-review` vs `apple-harness`
2. **단계형 워크플로우 스킬의 역할 경계 불명확**
   - 예: `ctx-guide` / `ctx-init` / `ctx-verify` / `ctx-audit`
3. **동일한 “외부 위임” 계열 스킬 간 경쟁**
   - 예: `gpt-research` vs `hey-codex`
4. **한국어 구어체/명령형/완곡 표현 다양성 부족**
   - 예: “봐줘”, “한번 돌려봐”, “넘겨서 물어보자”, “전체적으로 손봐줘”

## 핵심 질문

1. 어떤 wording이 자연어 활성화에 가장 큰 영향을 주는가?
2. description과 examples 중 무엇이 더 큰 차이를 만드는가?
3. 스킬 간 충돌은 키워드 확장보다 **경계 문장 개선**이 더 중요한가?
4. 플러그인 설명과 스킬 설명의 정렬 여부가 활성화 품질에 영향을 주는가?
5. 한국어 구어체 표현을 얼마나 많이 예시에 넣어야 충분한가?

## 비목표

- 이번 연구에서 바로 모든 스킬 구현을 리팩토링하지는 않는다.
- 실제 tool execution 성공률은 1차 연구 대상이 아니다.
- “정답 스킬이 없는 요청”을 모두 자동화하려 하지 않는다.

## 성공 기준

최소 목표:
- 명확한 단일 의도를 가진 프롬프트에서 **Top-1 정확도**가 높아진다.
- 충돌군 프롬프트에서 잘못된 sibling skill 선택 비율이 줄어든다.
- 사용자가 `/skill-name`을 직접 입력해야 하는 빈도가 줄어든다.

권장 목표:
- 한국어 구어체와 영어 혼합 프롬프트 모두에서 안정적으로 동작한다.
- “큰 작업”과 “리뷰/분석”과 “가이드/설계”가 서로 덜 충돌한다.

## 연구 단위

이번 연구는 아래 세 레이어로 나누어 본다.

### Layer 1. Activation Surface

- `SKILL.md` frontmatter `description`
- `argument-hint`
- example phrasing
- plugin.json `description`

### Layer 2. Boundary Design

- “이럴 때 사용” 문장
- “이럴 때는 다른 스킬” 문장
- sibling skill 간 역할 분리

### Layer 3. Evaluation Harness

- 자연어 prompt corpus
- 정답 라벨
- 허용 가능한 차선 선택 기준
- 오류 taxonomy

## 첫 번째 연구 가설

> 이 저장소에서는 “키워드 추가”보다 **충돌군 내부의 경계 문장과 예시 다양화**가 라우팅 품질을 더 크게 좌우할 가능성이 높다.
