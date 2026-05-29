# Web Report Output Template

Structure template for the `--format web` output of yoda share mode. Generate the interactive HTML page directly or delegate to the `frontend-design` skill.

---

## Page Structure

### 1. Header Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  🧘 Yoda Review                                              │
│                                                             │
│  {주제 제목}                                                 │
│  {생성 날짜} | {대상 파일/디렉토리 경로}                        │
│                                                             │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │ 🔴 2  │ │ 🟡 3  │ │ 🔵 1  │ │ 🟢 2  │ │ 💡 1  │              │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘              │
│                                                             │
│  한 줄 요약: {핵심 상태를 한 문장으로}                         │
└─────────────────────────────────────────────────────────────┘
```

### 2. Tab Navigation

Split into 4 tabs so readers can selectively explore only the areas they care about:

| 탭 | 내용 |
|----|------|
| 📊 개요 | 심각도별 요약 테이블, 전체 결론, 핵심 액션 아이템 |
| 🔍 발견사항 | 접이식 카드로 Before/After/Why + 인출 연습 |
| 📖 딥다이브 | Praise, Insight, 아키텍처 시각화, 메타인지 질문 |
| 🧩 패턴 | 일반화된 패턴, 설계 원칙 카드, 레퍼런스 링크 |

### 3. Finding Card (collapsible)

Each finding is rendered as a collapsed/expanded card (progressive disclosure).

- Collapsed: severity icon + title + location + one-line summary
- Expanded: Before (red border) + Why + After (green border)

### 4. Retrieval Practice Section

Code block + question → reveals Why/After on click.

---

## Technical Requirements

| Item | Requirement |
|------|---------|
| File format | Single HTML file (external dependencies loaded via CDN) |
| Syntax highlighting | highlight.js, target language support required |
| Responsive | Mobile / tablet / desktop, 3 breakpoints |
| Theme | Dark/light mode toggle, auto-detect OS setting |

---

## Save Path

```
docs/yoda/YYYY-MM-DD-{slug}.html
```
