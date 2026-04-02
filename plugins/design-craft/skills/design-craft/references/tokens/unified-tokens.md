# 통합 디자인 토큰 사전

19명의 디자이너/화가 연구에서 추출한 정규화된 토큰 체계.

> `출처 등급(최저)`는 각 통합 행에 반영된 원본 토큰들 중 **가장 낮은 신뢰도 등급**을 표시한다. 즉 `S`와 `F`가 혼합된 행은 `F`로 표기하며, 세부 근거는 개별 designer/artist 원본 문서와 `references/verification/report.md`를 따른다.

## Layout & Spacing

| 토큰명 | 값 | 출처 | 출처 등급(최저) |
|--------|---|------|----------------|
| base-unit | 4pt | Ive, Tschichold, Kare | F |
| grid-base | 8pt | Ive, Rams, Vignelli, Brockmann, Dye, Matas, Won | F |
| spacing-scale | 4, 8, 12, 16, 20, 24, 32, 40, 48pt | Ive | S |
| ma-spacing | 8-16-32-64-128px (지수 증가) | Lee Ufan | C |
| screen-margin-compact | 16pt | Ive, Won | S |
| screen-margin-regular | 20pt | Ive, Won | S |
| margin-ratio | 전체 면적의 10-20% | Rams, Vignelli, Tschichold | B |
| tschichold-margin | inner:top:outer:bottom = 2:3:4:6 | Tschichold | S |
| content-width-max | 672pt (readable) | Ive | S |
| content-area-ratio | 85-95% | Rams, Vignelli | B |
| whitespace-ratio | 40-60% | Ive, Brockmann, Rand | B |
| void-ratio | 70-90% (극단적 여백) | Lee Ufan | B |
| grid-columns | 2, 3, 4, 6, 12열 | Vignelli, Brockmann | S |
| grid-gutter | 8pt 또는 컬럼 폭의 1/10-1/6 | Ive, Brockmann | S |
| alignment-axes | 최대 3개/면 | Rams, Vignelli | B |
| hierarchy-levels | 최대 3단계 | Rams, Vignelli, Norman | D |
| cognitive-chunk-max | 7 +-2개 | Norman | C |
| nav-depth-max | 3단계 이하 | Norman | D |
| touch-target-min | 44x44pt | Ive, Norman | S |
| golden-ratio | 1:1.618 | Rams | B |
| sqrt2-ratio | 1:1.414 (A 시리즈) | Vignelli, Brockmann | S |
| nav-bar-height | 44pt (compact) / 96pt (large) | Ive, Dye | A |
| tab-bar-height | 49pt / 83pt | Ive | A |
| mondrian-grid-cell-range | 5-55% 불균등 분할 | Mondrian | B |
| rothko-field-count | 2-3개 수직 적층 | Rothko | B |
| albers-nesting-levels | 3-4단계 중첩 | Albers | B |
| malevich-shape-count | 1-12개/화면 | Malevich | B |

## Typography

| 토큰명 | 값 | 출처 | 출처 등급(최저) |
|--------|---|------|----------------|
| font-system | SF Pro / SF Compact | Ive, Dye, Won | S |
| font-classic-sans | Helvetica, Akzidenz-Grotesk | Rams, Vignelli, Brockmann | B |
| font-classic-serif | Bodoni, Garamond, Sabon | Vignelli, Tschichold | S |
| font-family-count | 1-3종 제한 | Vignelli, Brockmann, Tschichold | S |
| type-scale | 11, 12, 13, 15, 17, 20, 22, 28, 34pt | Ive, Dye, Won | S |
| body-size | 17pt (iOS), 16px (web) | Ive, Norman, Matas | D |
| headline-size | 28-34pt | Ive, Dye | A |
| caption-size | 11-12pt | Ive, Dye | S |
| font-size-ratio | 제목:본문 = 1.5:1 ~ 3:1 | Tschichold, Rand | A |
| line-height-ratio | 1.2-1.4x (라틴) | Ive, Vignelli, Brockmann | B |
| line-height-korean | 1.4-1.6x | Won | A |
| line-length | 45-75자 (최적 60자) | Norman, Tschichold | C |
| letter-spacing-body | 0pt (기본) | Ive | A |
| letter-spacing-title | -0.4 ~ -1.6pt (타이트닝) | Ive | A |
| letter-spacing-caps | +5-10% | Tschichold, Rams | B |
| korean-tracking | -0.01em ~ -0.02em | Won | B |
| font-weight-range | Ultralight(100)-Black(900) | Ive, Dye, Won | A |
| text-align | 좌측 정렬 기본 | Tschichold, Brockmann, Norman | C |
| contrast-ratio-text | 최소 4.5:1 (AA), 7:1 (AAA) | Norman, Rams | B |
| dynamic-type-range | xSmall(14pt) ~ AX5(60pt) | Ive, Dye | S |
| readable-line-length | max-width: 65ch | Tschichold, Norman | C |
| text-transform-sign | uppercase (사인/제목) | Vignelli | S |

## Color & Surface

| 토큰명 | 값 | 출처 | 출처 등급(최저) |
|--------|---|------|----------------|
| system-blue | #007AFF / #0A84FF (dark) | Ive, Dye, Won | S |
| system-red | #FF3B30 / #FF453A (dark) | Ive | S |
| system-green | #34C759 / #30D158 (dark) | Ive | S |
| bg-primary | #FFFFFF / #000000 (dark) | Ive, Dye | S |
| bg-secondary | #F2F2F7 / #1C1C1E (dark) | Ive, Dye | S |
| palette-neutral | #E0E0E0 ~ #F5F5F5 | Rams | B |
| palette-primary-3color | 흑-백-악센트 1색 | Rams, Tschichold, Rand | B |
| accent-usage | 화면의 5% 이하 (미니멀) / 15-30% (표준) / 30-50% (브랜드) | Rams, Mondrian, Rand — conflicts.md 참조 | D |
| color-count-per-layout | 3-4색 (흑-백 포함) | Rams, Vignelli, Brockmann | B |
| mondrian-red | #CC2200 ~ #E63929 | Mondrian | B |
| mondrian-blue | #1B3B8C ~ #2040A0 | Mondrian | B |
| mondrian-yellow | #F2D516 ~ #FFE135 | Mondrian | B |
| rothko-surface-dark | #1A1520 ~ #4D3B52 (4단계) | Rothko | B |
| rothko-warm-white | #F0E8D8 ~ #FAF2E6 | Rothko | C |
| malevich-surface-light | #F0EDE5 ~ #FFFFFF (4단계) | Malevich | C |
| kandinsky-blue-deep | #1A237E ~ #283593 | Kandinsky | B |
| lee-canvas-white | #F5F0E8 ~ #FAF5ED (생지색) | Lee Ufan | B |
| turrell-kelvin | 2700K-5000K-7500K | Turrell | B |
| turrell-warm-glow | #FF8C42 ~ #FFAA5C | Turrell | B |
| turrell-blue-deep | #1A2060 ~ #2A3080 | Turrell | B |
| blur-material | thin/regular/thick (5종) | Ive, Dye | A |
| blur-radius | 20-40pt | Ive, Matas | B |
| separator-color | rgba(60,60,67,0.29) | Ive | S |
| surface-texture | 없음 (단색 flat) | Rams, Vignelli, Brockmann | D |
| gradient-usage | 없음 (Rams, Mondrian) / 수직만 (Rothko) | conflict - see conflicts.md | F |
| disabled-opacity | 0.38-0.5 | Norman | A |
| dark-elevation | z-축 상승 시 밝기 +4-8% | Dye, Rothko | B |
| riley-bw | #0A0A0A / #F5F5F5 (최대 대비) | Riley | B |
| color-functional | 색상 = 의미/카테고리 (장식 금지) | Vignelli, Norman, Tschichold | D |

### 접근성 경고 주석 — Color & Surface
- `riley-bw`: 고대비 흑백 패턴은 장식/로딩/분리선처럼 **콘텐츠와 분리된 영역**에만 사용한다. 텍스트·입력 필드·포커스 대상 뒤 배경으로는 금지하고, 화면 점유율은 50% 이하로 제한한다.
- `turrell-kelvin`: 2700K↔5000K↔7500K 자동 색온도 변화는 몰입/웰니스 모드에서만 opt-in으로 사용한다. 기본 읽기/업무 화면은 고정 색온도를 우선하고, 자동 변화에는 항상 opt-out이 있어야 한다.
- `rothko-surface-dark`: 색조 있는 다크 서피스는 허용하지만, 본문 텍스트는 최소 WCAG AA 4.5:1, 대형 텍스트·아이콘·구분선·입력 경계는 최소 3:1 대비를 유지해야 한다. pure black로 내려앉히지 말고 필요시 별도 패널·보조 surface·미세 경계 처리로 읽기층을 분리한다.

## Shape & Geometry

| 토큰명 | 값 | 출처 | 출처 등급(최저) |
|--------|---|------|----------------|
| corner-radius-small | 6-8pt | Ive | B |
| corner-radius-medium | 10-13pt | Ive, Dye | B |
| corner-radius-large | 16-22pt | Ive, Dye | B |
| corner-style | .continuous (squircle, G2) | Ive, Dye | S |
| corner-radius-zero | 0px (직각 선호) | Rams, Vignelli, Tschichold, Brockmann, Mondrian | B |
| corner-radius-logo | 0px 또는 50% (극단 선택) | Rand | S |
| form-vocabulary | 사각형, 원, 삼각형 (3종) | Vignelli, Brockmann, Rand, Malevich | B |
| icon-stroke | 1.5-2pt @1x | Ive, Rams | F |
| icon-style | 선형(outline), 균일 두께 | Rams, Matas | B |
| aspect-ratio-device | 19.5:9 (iPhone), 4:3 (iPad) | Ive | S |
| aspect-ratio-golden | 1:1.618 | Rams, Rand | B |
| aspect-ratio-a-series | 1:1.414 | Vignelli, Brockmann | S |
| depth-layers | iOS: 3단계 (base-raised-overlay), Android: 5단계 (M3 elevation 0-5) — 플랫폼별 별도 정의 | Dye, Matas, Kandinsky | C |
| sf-symbol-rendering | mono/hierarchical/palette/multicolor | Ive | S |
| pill-shape | height/2 radius (알약형) | Matas | A |
| mondrian-line-weight | 3-8px | Mondrian | B |
| kandinsky-color-form | 삼각형=노랑, 원=파랑, 사각형=빨강 | Kandinsky | B |
| albers-nesting-scale | 내부 = 외부의 70-80% | Albers | B |
| riley-stripe-width | 2-20px | Riley | B |
| turrell-aperture-ratio | 개구부 15-30% : 주변 70-85% | Turrell | C |

### 접근성 경고 주석 — Shape & Geometry
- `riley-stripe-width`: 줄무늬는 1x 기준 최소 2px를 유지하고, 서로 다른 반복 패턴을 한 화면에 겹치지 않는다. 반복 줄무늬는 콘텐츠 배경이 아니라 분리된 장식면/로딩면에서만 사용한다.

## Motion & Interaction

| 토큰명 | 값 | 출처 | 출처 등급(최저) |
|--------|---|------|----------------|
| duration-fast | 0.15-0.2s | Ive, Rams | F |
| duration-standard | 0.25-0.35s | Ive, Dye | A |
| duration-slow | 0.4-0.5s | Ive, Matas | B |
| duration-immersive | 2-5s (몰입형 전환) | Turrell, Rothko | F |
| spring-damping | 0.7-0.85 | Ive, Matas | A |
| spring-response | 0.3-0.5s | Ive, Matas, Dye | A |
| easing-default | ease-in-out | Ive | A |
| easing-minimal | ease-out 또는 linear | Rams, Brockmann | F |
| gesture-velocity | 500pt/s (스와이프 임계) | Ive, Matas | A |
| haptic-feedback | light/medium/heavy | Ive, Dye | S |
| response-instant | 100ms 이내 | Norman, Rams | C |
| response-seamless | 1s 이내 | Norman | C |
| loading-feedback | 1s 초과 시 스피너 | Norman | C |
| reduce-motion | crossfade 0.3s 대체 | Ive | S |
| animation-purpose | 상태 전환용만 (장식 금지) | Norman, Rams | D |
| frame-rate | 60fps 필수 | Matas | S |
| rubber-band | 오버스크롤 시 1/3 감속 | Dye, Matas | A |
| lee-fade-curve | ease-out (급시작-부드러운 끝) | Lee Ufan | C |
| lee-opacity-decay | 100% -> 5% 선형 감소 | Lee Ufan | B |
| riley-repetition-threshold | 7-10회 반복 시 진동 시작 | Riley | C |
| turrell-breath | 밝기 +-5%, 주기 4-8s | Turrell | C |
| turrell-color-cycle | 풀사이클 10-60분 (UI: 2-10s) | Turrell | B |
| rothko-slow-transition | 500ms-2000ms 색면 전환 | Rothko | F |
| kare-click-feedback | 반전(Invert), 50ms 이내 | Kare | S |

### 접근성 경고 주석 — Motion & Interaction
- `turrell-breath`: 밝기 호흡 애니메이션은 `reduce-motion` 또는 동급 접근성 설정이 켜지면 정지/크로스페이드로 대체한다. 자동 반복 시 진폭은 ±5%, 주기는 4-8초 범위를 넘지 않으며 flash/flicker 조건을 만들면 안 된다.

## Token-level accessibility usage envelope (round-004)

| 토큰 | 허용 (allow) | 조건부 허용 (conditional) | 금지 (prohibit) | 근거 결합 |
|------|---------------|---------------------------|-----------------|-----------|
| `riley-bw`, `riley-stripe-width` | 로딩 바, 분리선, 장식 패널처럼 **콘텐츠와 분리된 1차원 패턴 면**. 줄무늬는 1x 기준 2-20px 유지. | 히어로/전환 패널은 일시적 노출이고 `reduce-motion`이 꺼져 있으며 flash/flicker를 만들지 않을 때만 허용한다. 패턴 면은 화면의 50% 이하로 제한하고, 비패턴 휴식면을 함께 둔다. | 텍스트·입력·포커스 요소 뒤 배경, 정적 고대비 패턴의 상시 대면적 노출, 서로 다른 주기의 반복 패턴 중첩. | `bridget-riley.md`의 stripe-width 2-20px, breathing-contrast 50% 여백, 대면적/콘텐츠 배경 금지 + `platforms/web.md`의 WCAG 2.2 대비·focus 기준을 결합한 보수적 운영 규칙. |
| `turrell-kelvin` | 몰입/웰니스/미디어처럼 화면의 30% 이상을 차지하는 ambient surface에서 2700K·5000K·7500K **고정 preset**으로 사용. | 자동 색온도 전환은 opt-in + opt-out이 모두 있을 때만 허용한다. 전환 시간은 2초 이상 유지하고, 읽기 콘텐츠는 중립 surface 또는 별도 패널로 분리한다. | 기본 읽기/업무 흐름의 상시 자동 색온도 변화, 30% 미만 소형 요소/컨트롤, 2초 미만 급격한 점프 전환. | `james-turrell.md`의 small element 부적합·2-5초 점진 전환·opt-out 주의 + `platforms/apple.md`/`platforms/android.md`의 기본 surface 체계를 합쳤다. |
| `turrell-breath` | 배경 또는 ambient overlay처럼 화면의 30% 이상을 차지하는 큰 면에서만 사용. 진폭은 ±5%, 주기는 4-8초 유지. | `reduce-motion`이 꺼져 있고, 상태 변화 피드백이 아니라 분위기 레이어일 때만 반복 허용. 필요한 경우 정적 crossfade로 대체한다. | 버튼·입력·포커스 링 등 상호작용 요소 자체의 애니메이션, 전경 텍스트를 직접 싣는 바탕, `reduce-motion`이 켜진 상태에서의 반복 재생. | `james-turrell.md`의 breath-animation 4-8초·small element 부적합 + 기존 `reduce-motion` 토큰을 결합했다. |
| `rothko-surface-dark` | `surface-0`~`surface-3`처럼 색조가 있는 다크 배경/패널/몰입 섹션. 배경과 패널을 2-3면으로 제한해 감정 톤을 유지한다. | 본문 텍스트는 4.5:1, 대형 텍스트·아이콘·구분선·입력 경계는 3:1 이상일 때만 직접 배치한다. 장문 텍스트는 분리된 secondary surface/overlay 위에 올리고, gradient·blur는 적용 후에도 대비 기준을 유지해야 한다. | pure black 대체, texture/pattern overlay, 원색/neon accent 남용, raw dark surface 위 장문 밀집 본문, 500ms 미만 빠른 색면 전환. | `rothko.md`의 surface-0~3, pure black 금지, texture 금지, slow transition 500-2000ms + `platforms/web.md`의 WCAG AA 텍스트 4.5:1 / non-text 3:1 기준을 결합했다. |
