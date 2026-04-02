# Web 플랫폼 디자인 가이드라인 요약

web-designer 에이전트의 기본 참조 문서.

## 공식 출처

- [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [MDN Web Docs](https://developer.mozilla.org/)

## 핵심 정량 기준

### 접근성 (WCAG 2.2)

| 항목 | AA 기준 | AAA 기준 |
|------|---------|---------|
| 텍스트 대비비 | 4.5:1 | 7:1 |
| 대형 텍스트 대비비 (≥18pt/14pt bold) | 3:1 | 4.5:1 |
| UI 컴포넌트 대비비 | 3:1 | — |
| 최소 터치 타겟 | 24×24px (2.5.8) | 44×44px |
| 포커스 표시기 두께 | 2px 이상 | — |

### 반응형 Breakpoints

| 이름 | 범위 | 용도 |
|------|------|------|
| mobile | 0-639px | 세로 모바일 |
| tablet | 640-1023px | 태블릿/가로 모바일 |
| desktop | 1024-1279px | 일반 데스크톱 |
| wide | 1280px+ | 넓은 모니터 |

### 타이포그래피 (Modular Scale)

| 스타일 | 크기 | 행간 | 비고 |
|--------|------|------|------|
| Display | clamp(2rem, 5vw, 3.5rem) | 1.1 | 히어로 영역 |
| H1 | clamp(1.75rem, 4vw, 2.5rem) | 1.2 | |
| H2 | clamp(1.5rem, 3vw, 2rem) | 1.25 | |
| H3 | 1.25rem | 1.3 | |
| Body | 1rem (16px) | 1.5 | 최소 본문 크기 |
| Small | 0.875rem (14px) | 1.4 | 보조 텍스트 |
| Caption | 0.75rem (12px) | 1.3 | 캡션/라벨 |

### 간격 (4px 기반)

| 토큰 | 값 |
|------|-----|
| spacing-xs | 4px |
| spacing-sm | 8px |
| spacing-md | 16px |
| spacing-lg | 24px |
| spacing-xl | 32px |
| spacing-2xl | 48px |
| spacing-3xl | 64px |

### 색상

| 항목 | Light | Dark |
|------|-------|------|
| 배경 (1차) | #FFFFFF | #121212 |
| 배경 (2차) | #F5F5F5 | #1E1E1E |
| 텍스트 (1차) | #1A1A1A | #E0E0E0 |
| 텍스트 (2차) | #666666 | #A0A0A0 |
| 구분선 | #E0E0E0 | #333333 |

### Z-Index 체계

| 레이어 | 값 |
|--------|-----|
| 기본 | 0 |
| 드롭다운 | 100 |
| 스티키 | 200 |
| 오버레이 | 300 |
| 모달 | 400 |
| 토스트 | 500 |

### Elevation (Box Shadow)

| 레벨 | 값 |
|------|-----|
| level-1 | 0 1px 2px rgba(0,0,0,0.05) |
| level-2 | 0 2px 4px rgba(0,0,0,0.1) |
| level-3 | 0 4px 8px rgba(0,0,0,0.12) |
| level-4 | 0 8px 16px rgba(0,0,0,0.15) |

## CSS 매핑 힌트

```css
/* 타이포 — fluid */
font-size: clamp(1rem, 0.5rem + 1vw, 1.25rem);
line-height: 1.5;

/* 간격 — CSS custom properties */
--spacing-unit: 4px;
gap: calc(var(--spacing-unit) * 4); /* 16px */

/* 반응형 */
@media (min-width: 640px) { /* tablet */ }
@media (min-width: 1024px) { /* desktop */ }

/* 다크모드 */
@media (prefers-color-scheme: dark) { }
```
