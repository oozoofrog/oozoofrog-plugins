# 통합 디자인 토큰 사전

19명의 디자이너/화가 연구에서 추출한 정규화된 토큰 체계.

## Layout & Spacing

| 토큰명 | 값 | 출처 |
|--------|---|------|
| base-unit | 4pt | Ive, Tschichold, Kare |
| grid-base | 8pt | Ive, Rams, Vignelli, Brockmann, Dye, Matas, Won |
| spacing-scale | 4, 8, 12, 16, 20, 24, 32, 40, 48pt | Ive |
| ma-spacing | 8-16-32-64-128px (지수 증가) | Lee Ufan |
| screen-margin-compact | 16pt | Ive, Won |
| screen-margin-regular | 20pt | Ive, Won |
| margin-ratio | 전체 면적의 10-20% | Rams, Vignelli, Tschichold |
| tschichold-margin | inner:top:outer:bottom = 2:3:4:6 | Tschichold |
| content-width-max | 672pt (readable) | Ive |
| content-area-ratio | 85-95% | Rams, Vignelli |
| whitespace-ratio | 40-60% | Ive, Brockmann, Rand |
| void-ratio | 70-90% (극단적 여백) | Lee Ufan |
| grid-columns | 2, 3, 4, 6, 12열 | Vignelli, Brockmann |
| grid-gutter | 8pt 또는 컬럼 폭의 1/10-1/6 | Ive, Brockmann |
| alignment-axes | 최대 3개/면 | Rams, Vignelli |
| hierarchy-levels | 최대 3단계 | Rams, Vignelli, Norman |
| cognitive-chunk-max | 7 +-2개 | Norman |
| nav-depth-max | 3단계 이하 | Norman |
| touch-target-min | 44x44pt | Ive, Norman |
| golden-ratio | 1:1.618 | Rams |
| sqrt2-ratio | 1:1.414 (A 시리즈) | Vignelli, Brockmann |
| nav-bar-height | 44pt (compact) / 96pt (large) | Ive, Dye |
| tab-bar-height | 49pt / 83pt | Ive |
| mondrian-grid-cell-range | 5-55% 불균등 분할 | Mondrian |
| rothko-field-count | 2-3개 수직 적층 | Rothko |
| albers-nesting-levels | 3-4단계 중첩 | Albers |
| malevich-shape-count | 1-12개/화면 | Malevich |

## Typography

| 토큰명 | 값 | 출처 |
|--------|---|------|
| font-system | SF Pro / SF Compact | Ive, Dye, Won |
| font-classic-sans | Helvetica, Akzidenz-Grotesk | Rams, Vignelli, Brockmann |
| font-classic-serif | Bodoni, Garamond, Sabon | Vignelli, Tschichold |
| font-family-count | 1-3종 제한 | Vignelli, Brockmann, Tschichold |
| type-scale | 11, 12, 13, 15, 17, 20, 22, 28, 34pt | Ive, Dye, Won |
| body-size | 17pt (iOS), 16px (web) | Ive, Norman, Matas |
| headline-size | 28-34pt | Ive, Dye |
| caption-size | 11-12pt | Ive, Dye |
| font-size-ratio | 제목:본문 = 1.5:1 ~ 3:1 | Tschichold, Rand |
| line-height-ratio | 1.2-1.4x (라틴) | Ive, Vignelli, Brockmann |
| line-height-korean | 1.4-1.6x | Won |
| line-length | 45-75자 (최적 60자) | Norman, Tschichold |
| letter-spacing-body | 0pt (기본) | Ive |
| letter-spacing-title | -0.4 ~ -1.6pt (타이트닝) | Ive |
| letter-spacing-caps | +5-10% | Tschichold, Rams |
| korean-tracking | -0.01em ~ -0.02em | Won |
| font-weight-range | Ultralight(100)-Black(900) | Ive, Dye, Won |
| text-align | 좌측 정렬 기본 | Tschichold, Brockmann, Norman |
| contrast-ratio-text | 최소 4.5:1 (AA), 7:1 (AAA) | Norman, Rams |
| dynamic-type-range | xSmall(14pt) ~ AX5(60pt) | Ive, Dye |
| readable-line-length | max-width: 65ch | Tschichold, Norman |
| text-transform-sign | uppercase (사인/제목) | Vignelli |

## Color & Surface

| 토큰명 | 값 | 출처 |
|--------|---|------|
| system-blue | #007AFF / #0A84FF (dark) | Ive, Dye, Won |
| system-red | #FF3B30 / #FF453A (dark) | Ive |
| system-green | #34C759 / #30D158 (dark) | Ive |
| bg-primary | #FFFFFF / #000000 (dark) | Ive, Dye |
| bg-secondary | #F2F2F7 / #1C1C1E (dark) | Ive, Dye |
| palette-neutral | #E0E0E0 ~ #F5F5F5 | Rams |
| palette-primary-3color | 흑-백-악센트 1색 | Rams, Tschichold, Rand |
| accent-usage | 화면의 5% 이하 (미니멀) / 15-30% (표준) / 30-50% (브랜드) | Rams, Mondrian, Rand — conflicts.md 참조 |
| color-count-per-layout | 3-4색 (흑-백 포함) | Rams, Vignelli, Brockmann |
| mondrian-red | #CC2200 ~ #E63929 | Mondrian |
| mondrian-blue | #1B3B8C ~ #2040A0 | Mondrian |
| mondrian-yellow | #F2D516 ~ #FFE135 | Mondrian |
| rothko-surface-dark | #1A1520 ~ #4D3B52 (4단계) | Rothko |
| rothko-warm-white | #F0E8D8 ~ #FAF2E6 | Rothko |
| malevich-surface-light | #F0EDE5 ~ #FFFFFF (4단계) | Malevich |
| kandinsky-blue-deep | #1A237E ~ #283593 | Kandinsky |
| lee-canvas-white | #F5F0E8 ~ #FAF5ED (생지색) | Lee Ufan |
| turrell-kelvin | 2700K-5000K-7500K | Turrell |
| turrell-warm-glow | #FF8C42 ~ #FFAA5C | Turrell |
| turrell-blue-deep | #1A2060 ~ #2A3080 | Turrell |
| blur-material | thin/regular/thick (5종) | Ive, Dye |
| blur-radius | 20-40pt | Ive, Matas |
| separator-color | rgba(60,60,67,0.29) | Ive |
| surface-texture | 없음 (단색 flat) | Rams, Vignelli, Brockmann |
| gradient-usage | 없음 (Rams, Mondrian) / 수직만 (Rothko) | conflict - see conflicts.md |
| disabled-opacity | 0.38-0.5 | Norman |
| dark-elevation | z-축 상승 시 밝기 +4-8% | Dye, Rothko |
| riley-bw | #0A0A0A / #F5F5F5 (최대 대비) | Riley |
| color-functional | 색상 = 의미/카테고리 (장식 금지) | Vignelli, Norman, Tschichold |

## Shape & Geometry

| 토큰명 | 값 | 출처 |
|--------|---|------|
| corner-radius-small | 6-8pt | Ive |
| corner-radius-medium | 10-13pt | Ive, Dye |
| corner-radius-large | 16-22pt | Ive, Dye |
| corner-style | .continuous (squircle, G2) | Ive, Dye |
| corner-radius-zero | 0px (직각 선호) | Rams, Vignelli, Tschichold, Brockmann, Mondrian |
| corner-radius-logo | 0px 또는 50% (극단 선택) | Rand |
| form-vocabulary | 사각형, 원, 삼각형 (3종) | Vignelli, Brockmann, Rand, Malevich |
| icon-stroke | 1.5-2pt @1x | Ive, Rams |
| icon-style | 선형(outline), 균일 두께 | Rams, Matas |
| aspect-ratio-device | 19.5:9 (iPhone), 4:3 (iPad) | Ive |
| aspect-ratio-golden | 1:1.618 | Rams, Rand |
| aspect-ratio-a-series | 1:1.414 | Vignelli, Brockmann |
| depth-layers | iOS: 3단계 (base-raised-overlay), Android: 5단계 (M3 elevation 0-5) — 플랫폼별 별도 정의 | Dye, Matas, Kandinsky |
| sf-symbol-rendering | mono/hierarchical/palette/multicolor | Ive |
| pill-shape | height/2 radius (알약형) | Matas |
| mondrian-line-weight | 3-8px | Mondrian |
| kandinsky-color-form | 삼각형=노랑, 원=파랑, 사각형=빨강 | Kandinsky |
| albers-nesting-scale | 내부 = 외부의 70-80% | Albers |
| riley-stripe-width | 2-20px | Riley |
| turrell-aperture-ratio | 개구부 15-30% : 주변 70-85% | Turrell |

## Motion & Interaction

| 토큰명 | 값 | 출처 |
|--------|---|------|
| duration-fast | 0.15-0.2s | Ive, Rams |
| duration-standard | 0.25-0.35s | Ive, Dye |
| duration-slow | 0.4-0.5s | Ive, Matas |
| duration-immersive | 2-5s (몰입형 전환) | Turrell, Rothko |
| spring-damping | 0.7-0.85 | Ive, Matas |
| spring-response | 0.3-0.5s | Ive, Matas, Dye |
| easing-default | ease-in-out | Ive |
| easing-minimal | ease-out 또는 linear | Rams, Brockmann |
| gesture-velocity | 500pt/s (스와이프 임계) | Ive, Matas |
| haptic-feedback | light/medium/heavy | Ive, Dye |
| response-instant | 100ms 이내 | Norman, Rams |
| response-seamless | 1s 이내 | Norman |
| loading-feedback | 1s 초과 시 스피너 | Norman |
| reduce-motion | crossfade 0.3s 대체 | Ive |
| animation-purpose | 상태 전환용만 (장식 금지) | Norman, Rams |
| frame-rate | 60fps 필수 | Matas |
| rubber-band | 오버스크롤 시 1/3 감속 | Dye, Matas |
| lee-fade-curve | ease-out (급시작-부드러운 끝) | Lee Ufan |
| lee-opacity-decay | 100% -> 5% 선형 감소 | Lee Ufan |
| riley-repetition-threshold | 7-10회 반복 시 진동 시작 | Riley |
| turrell-breath | 밝기 +-5%, 주기 4-8s | Turrell |
| turrell-color-cycle | 풀사이클 10-60분 (UI: 2-10s) | Turrell |
| rothko-slow-transition | 500ms-2000ms 색면 전환 | Rothko |
| kare-click-feedback | 반전(Invert), 50ms 이내 | Kare |
