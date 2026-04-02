# Web 플랫폼 매핑 (CSS)

통합 토큰을 Web CSS 구현값으로 변환한다.

## Layout & Spacing

| 통합 토큰 | Web 값 | CSS Property | 비고 |
|----------|--------|-------------|------|
| base-unit | 4px | `--space-1: 4px` | CSS 변수 기본 단위 |
| grid-base | 8px | `--space-2: 8px` | 모든 간격 8px 배수 |
| spacing-scale | 4-48px | `--space-{1..12}: calc(var(--base) * N)` | 4px 단위 스케일 |
| screen-margin-compact | 16px | `padding-inline: 16px` | 모바일 마진 |
| screen-margin-regular | 20px | `padding-inline: clamp(16px, 4vw, 40px)` | 데스크탑 유동 마진 |
| content-width-max | 672px | `max-width: 672px; margin-inline: auto` | 읽기 최적 폭 |
| touch-target-min | 44px | `min-height: 44px; min-width: 44px` | 모바일 터치 영역 |
| golden-ratio | 1:1.618 | `grid-template-columns: 1fr 1.618fr` | 또는 38.2%/61.8% |
| sqrt2-ratio | 1:1.414 | `aspect-ratio: 1 / 1.414` | A 시리즈 비율 |
| grid-columns | 12열 | `grid-template-columns: repeat(12, 1fr)` | 표준 그리드 |
| grid-gutter | 8-16px | `gap: 16px` | 컬럼 간격 |
| alignment-axes | 3개 이하 | `align-items`, `justify-content` | 정렬축 제한 |
| hierarchy-levels | 3단계 | `<h1>/<h2>/<p>` | 시각 위계 |
| void-ratio | 70-90% | `max-width: 30%` (콘텐츠) | Lee Ufan 미니멀 |
| mondrian-grid | 비균등 분할 | `grid-template-columns: 1fr 2.5fr 0.8fr` | 불균등 fr 단위 |
| tschichold-margin | 2:3:4:6 비율 | `padding: 3vw 4vw 6vw 2vw` | 비례 마진 |

## Typography

| 통합 토큰 | Web 값 | CSS Property | 비고 |
|----------|--------|-------------|------|
| font-system | system-ui | `font-family: system-ui, -apple-system, sans-serif` | 시스템 서체 |
| font-classic-sans | Helvetica | `font-family: 'Helvetica Neue', Arial, sans-serif` | 클래식 대안 |
| font-classic-serif | Georgia | `font-family: Georgia, 'Times New Roman', serif` | 세리프 대안 |
| body-size | 16px | `font-size: 1rem` (16px 기본) | WCAG 권장 최소 |
| headline-size | 28-34px | `font-size: clamp(1.75rem, 3vw, 2.125rem)` | 반응형 제목 |
| caption-size | 11-12px | `font-size: 0.75rem` | 보조 텍스트 |
| type-scale | 1.2-1.5 비율 | `--step-N: calc(1rem * pow(1.25, N))` | 모듈 스케일 |
| line-height-ratio | 1.4-1.5 | `line-height: 1.5` | WCAG 1.4.12 기준 (1.5 이상 권장) |
| line-height-korean | 1.5-1.6 | `line-height: 1.6` (`:lang(ko)`) | 한글 행간 보정 |
| letter-spacing-title | -0.02em | `letter-spacing: -0.02em` | 대형 텍스트 |
| letter-spacing-caps | +0.05em | `letter-spacing: 0.05em; text-transform: uppercase` | 대문자 자간 |
| korean-tracking | -0.01em | `letter-spacing: -0.01em` (`:lang(ko)`) | 한글 자간 |
| font-weight-range | 100-900 | `font-weight: 100` ~ `900` | 가변 폰트 |
| text-align | left | `text-align: left` | LTR 기본 |
| readable-line-length | 65ch | `max-width: 65ch` | 가독성 줄 길이 |
| contrast-ratio-text | 4.5:1 (AA) | `color: #1a1a1a; background: #fff` | WCAG 준수 |
| orphan-widow | 최소 2줄 | `orphans: 2; widows: 2` | 고아줄 방지 |
| korean-word-break | 어절 단위 | `word-break: keep-all` | 한글 줄바꿈 |

## Color & Surface

| 통합 토큰 | Web 값 | CSS Property | 비고 |
|----------|--------|-------------|------|
| system-blue | #007AFF | `--color-primary: #007AFF` | 기본 액센트 |
| system-red | #FF3B30 | `--color-destructive: #FF3B30` | 경고/삭제 |
| system-green | #34C759 | `--color-success: #34C759` | 성공 상태 |
| bg-primary-light | #FFFFFF | `--bg-primary: #FFFFFF` | 라이트 배경 |
| bg-primary-dark | #000000 | `--bg-primary: #000000` | 다크 배경 (OLED) |
| bg-secondary | #F2F2F7 / #1C1C1E | `--bg-secondary: #F2F2F7` | 그룹 배경 |
| palette-3color | 흑-백-악센트 | `--text, --bg, --accent` 3개 변수 | 최소 테마 |
| accent-usage | 5-15% 면적 | 포인트 컬러 사용 제한 | 면적 가이드 |
| blur-backdrop | 20-40px | `backdrop-filter: blur(20px)` | 반투명 블러 |
| separator | rgba(60,60,67,0.29) | `border-bottom: 1px solid rgba(60,60,67,0.29)` | 구분선 |
| surface-flat | 텍스처 없음 | `background-image: none` | 단색 표면 |
| disabled-opacity | 0.38 | `opacity: 0.38` | 비활성 상태 |
| dark-elevation | +4-8% 밝기 | `--surface-1: hsl(0,0%,11%)` ~ `--surface-3` | 깊이별 밝기 |
| rothko-dark-surface | 색조 있는 어둠 | `--surface-0: #1A1520` ~ `--surface-3: #4D3B52` | 색조 다크모드 |
| gradient-vertical | 수직 그라디언트 | `background: linear-gradient(180deg, ...)` | Rothko 배경 |
| mondrian-gap-as-line | 갭 = 선 역할 | `gap: 4px; background: #1A1A1A` | 그리드 선 |
| color-functional | 의미 기반 | `--info, --success, --warning, --error` | 시맨틱 변수 |

## Shape & Geometry

| 통합 토큰 | Web 값 | CSS Property | 비고 |
|----------|--------|-------------|------|
| corner-radius-small | 8px | `border-radius: 8px` | 버튼/필드 |
| corner-radius-medium | 13px | `border-radius: 13px` | 카드/셀 |
| corner-radius-large | 22px | `border-radius: 22px` | 모달/위젯 |
| corner-radius-zero | 0px | `border-radius: 0` | 직각 스타일 |
| pill-shape | 9999px | `border-radius: 9999px` | 알약형 |
| form-vocabulary | 3종 | `clip-path: circle()`, `polygon()`, rect | 기본 형태 |
| icon-stroke | 1.5-2px | `stroke-width: 1.5px` (SVG) | 아이콘 두께 |
| depth-layers | 3단계 | `box-shadow: 0 1px 3px`, `0 4px 12px`, `0 8px 24px` | elevation |
| mondrian-border | 3-8px 실선 | `border: 4px solid #1A1A1A` | 격자선 |
| riley-stripe | 2-20px | `repeating-linear-gradient(...)` | 줄무늬 패턴 |

## Motion & Interaction

| 통합 토큰 | Web 값 | CSS Property | 비고 |
|----------|--------|-------------|------|
| duration-fast | 150ms | `transition-duration: 150ms` | 호버/클릭 |
| duration-standard | 300ms | `transition-duration: 300ms` | 표준 전환 |
| duration-slow | 450ms | `transition-duration: 450ms` | 모달 등장 |
| duration-immersive | 2-5s | `transition-duration: 3s` | 모드 전환 |
| easing-default | ease-in-out | `transition-timing-function: ease-in-out` | 기본 |
| easing-minimal | ease-out | `transition-timing-function: ease-out` | 절제 모션 |
| spring-css | spring-like | `transition: 300ms cubic-bezier(0.34, 1.56, 0.64, 1)` | 스프링 근사 |
| reduce-motion | 대체 | `@media (prefers-reduced-motion: reduce) { * { transition-duration: 0.01ms !important; } }` | 접근성 |
| hover-subtle | opacity 0.85 | `&:hover { opacity: 0.85 }` | Rams 절제 |
| hover-bold | 색상 반전 | `&:hover { filter: invert(1) }` | Rand 극적 |
| animation-purpose | 기능적만 | 장식 애니메이션 0개 | Norman 원칙 |
| scroll-behavior | smooth | `scroll-behavior: smooth` | 부드러운 스크롤 |
| loading-stripe | 줄무늬 애니메이션 | `background: repeating-linear-gradient(-45deg, ...)` | Riley 패턴 |
| breath-animation | 밝기 +-5% | `@keyframes breathe { 50% { opacity: 0.95 } }` | Turrell 호흡 |
| focus-visible | 2px 외곽선 | `&:focus-visible { outline: 2px solid var(--accent) }` | WCAG 2.2 |
