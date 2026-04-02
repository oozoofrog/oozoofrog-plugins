# Slides (Marp) 출력 템플릿

yoda share 모드의 `--format slides` 출력을 위한 Marp 프레젠테이션 구조 템플릿.

---

## 15장 슬라이드 구조

| # | 슬라이드 | 내용 | 인지적 도제 단계 |
|---|---------|------|----------------|
| 1 | Hook | 도발적 질문 — 발표 전체를 관통 | — |
| 2-3 | Context | 배경 + 실제 코드 | 모델링 |
| 4-6 | Mental Model | 개념 점진적 구축 (1슬라이드=1개념) | 코칭 |
| 7-8 | Before | 문제 코드 + 문제 지점 하이라이트 | 비계 설정 |
| 9 | Why | 핵심 이유 집약 | 비계 설정 |
| 10 | After | 수정 코드 (핵심 변경만) | 비계 제거 |
| 11 | Aha Insight | 핵심 깨달음 한 문장 | 비계 제거 |
| 12-13 | Generalization | 패턴 일반화 + 원칙 정리 | 탐색 |
| 14 | CTA | 액션 아이템 3개 + Hook 답변 | 탐색 |
| 15 | Resources | 참고 자료 + 메타인지 질문 | 탐색 |

## 슬라이드 작성 규칙

- 1 슬라이드 = 1 개념 (텍스트 밀도 최소화)
- 코드 블록은 핵심 3-5줄만 발췌
- 문제 지점에 `// ⚠️`, 개선 지점에 `// ✅`
- Mermaid 다이어그램 노드는 5개 이내

## 저장 및 변환

```
docs/yoda/YYYY-MM-DD-{slug}-slides.md
```

```bash
npx @marp-team/marp-cli docs/yoda/YYYY-MM-DD-{slug}-slides.md --html
```
