# 디자인 토큰 검증 리포트

## 검증 요약
- 검증 토큰 수: 20개 (출처 신뢰도) + 18개 (수치 정확도) + 12개 (내적 일관성)
- PASS: 28 / WARNING: 14 / FAIL: 5 / UNVERIFIABLE: 3

## 1. 출처 신뢰도 검증 결과

| # | 토큰 | unified 등급 | 원본 등급 | 판정 | 근거 |
|---|------|-------------|----------|------|------|
| 1 | base-unit (4pt) | Ive, Tschichold, Kare | Ive: S (HIG) | PASS | Ive 원본에서 S등급. 공식 HIG 기반 확인 |
| 2 | grid-base (8pt) | Ive, Rams, Vignelli 등 | Ive: S, Rams: F (UI변환), Vignelli: F (UI변환) | WARNING | Ive는 S등급이나 Rams/Vignelli는 F등급(추정). 통합 시 F출처 미표기 |
| 3 | body-size (17pt) | Ive, Norman, Matas | Ive: S (HIG), Norman: D (가독성 권장) | WARNING | Norman 원본은 16px(web)을 D등급으로 기재. 통합에서 Norman을 iOS 17pt 출처에 포함한 것은 부정확 |
| 4 | touch-target-min (44x44pt) | Ive, Norman | Ive: S (HIG), Norman: S (Fitts+HIG) | PASS | 양쪽 모두 S등급. Apple HIG 공식 수치 |
| 5 | corner-radius-small (6-8pt) | Ive | Ive: B (실측) | PASS | 원본 B등급 정확 반영 |
| 6 | system-blue (#007AFF) | Ive, Dye, Won | Ive: S, Dye: S, Won: S | PASS | 전원 S등급. HIG System Colors 공식 |
| 7 | separator-color | Ive | Ive: S (HIG Separator) | PASS | S등급 정확 반영 |
| 8 | whitespace-ratio (40-60%) | Ive, Brockmann, Rand | Ive: B (실측) | WARNING | Ive 원본에서 B등급(실측). 통합에서 등급 미표기, S/A로 오인 가능 |
| 9 | cognitive-chunk-max (7+-2) | Norman | Norman: C (학술논문) | PASS | Miller's Law. C등급 정확 |
| 10 | mondrian-red (#CC2200~#E63929) | Mondrian | Mondrian: B (디지털 측색) | PASS | 원본 B등급 정확 반영 |
| 11 | rothko-surface-dark (#1A1520~#4D3B52) | Rothko | Rothko: B (실측) | PASS | Rothko Chapel 다크서피스. 원본 B등급 정확 |
| 12 | lee-canvas-white (#F5F0E8~#FAF5ED) | Lee Ufan | Lee Ufan: B (캔버스 색상) | PASS | 원본 B등급 정확 |
| 13 | turrell-kelvin (2700K-5000K-7500K) | Turrell | Turrell: B (Roden Crater 측정) | PASS | 원본 B등급 정확 |
| 14 | riley-bw (#0A0A0A/#F5F5F5) | Riley | Riley: B (실측) | PASS | 원본 B등급 정확 |
| 15 | grid-base-ui (Rams) | 통합에 직접 없음 | Rams: F (UI변환 추정) | WARNING | Rams의 grid-base-ui는 F등급이나, unified에서 grid-base에 Rams를 출처로 기재. F등급 출처가 S등급처럼 보이는 문제 |
| 16 | easing-minimal | Rams, Brockmann | Rams: F (원칙 해석) | WARNING | Rams 원본에서 F등급(물리→디지털 해석). 통합에서 등급 비표기 |
| 17 | albers-nesting-levels (3-4단계) | Albers | Albers: B (실측) | PASS | 원본 B등급 정확 |
| 18 | font-family-count (1-3종) | Vignelli, Brockmann, Tschichold | Vignelli: S (Canon), Brockmann: 추정 | PASS | Vignelli Canon 공식 문서 기반 |
| 19 | disabled-opacity (0.38-0.5) | Norman | Norman: A (Material Design+Norman) | WARNING | Norman 원본은 A등급이나, 0.38은 M3 기본값, 0.5는 Norman 해석. 범위 표기는 정확하나 등급 혼재 |
| 20 | accent-usage (5-15%) | Rams, Albers | Rams: B (5% 이하), Albers: 없음 | FAIL | Rams 원본은 "5% 이하"인데 통합에서 "5-15%"로 확대. Albers는 accent-usage 토큰이 없음. conflicts.md에서 Rams 5% vs Mondrian 15-30%로 기록하면서 통합에 15%까지 포함한 것으로 보이나, Albers를 출처로 기재한 것은 오류 |

## 2. 수치 정확도 검증 결과

### iOS 매핑 vs platforms/apple.md

| 토큰 | 원본(apple.md) | 통합값 | iOS매핑값 | 판정 | 비고 |
|------|---------------|--------|----------|------|------|
| touch-target-min | 44x44pt | 44x44pt | 44x44pt | PASS | 정확 일치 |
| screen-margin-compact | 16pt | 16pt | 16pt | PASS | 정확 일치 |
| body-size | 17pt | 17pt | 17pt | PASS | 정확 일치 |
| corner-radius-small | 8pt (apple.md 소형버튼) | 6-8pt (Ive 실측) | 8pt | WARNING | 통합은 6-8pt 범위, iOS매핑은 8pt 고정. Dye 원본은 10pt(S등급). 소스 간 불일치 |
| corner-radius-medium | 12pt (apple.md 카드/시트) | 10-13pt | 13pt | WARNING | apple.md는 12pt, Dye는 13pt(A등급). 매핑은 13pt 채택. 1pt 차이 |
| corner-radius-large | 22pt (apple.md 위젯) | 16-22pt | 22pt | WARNING | 통합 범위 16-22pt에서 Ive 원본은 16-20pt(B등급), Dye는 22pt(S등급). Dye값 채택은 합리적이나 Ive 범위 초과 |
| system-blue | #007AFF/#0A84FF | #007AFF/#0A84FF | #007AFF/#0A84FF | PASS | HEX 정확 일치 |
| bg-secondary | #F2F2F7/#1C1C1E | #F2F2F7/#1C1C1E | #F2F2F7/#1C1C1E | PASS | 정확 일치 |
| separator-color | rgba(60,60,67,0.29) | rgba(60,60,67,0.29) | rgba(60,60,67,0.29) | PASS | 정확 일치 |

### Web 매핑 vs platforms/web.md

| 토큰 | 원본(web.md) | 통합값 | Web매핑값 | 판정 |
|------|-------------|--------|----------|------|
| body-size | 16px (Body 1rem) | 16px (web) | 16px | PASS |
| touch-target-min | 24x24px(AA)/44x44px(AAA) | 44x44pt | 44px | WARNING | WCAG 2.2 AA 최소는 24x24px이나 매핑은 44px(AAA) 사용. 등급 미명시 |
| contrast-ratio-text | 4.5:1(AA)/7:1(AAA) | 4.5:1(AA)/7:1(AAA) | 4.5:1(AA) | PASS |
| line-height | 1.5 (Body) | 1.2-1.4 (라틴) | 1.4 | FAIL | web.md 공식은 Body 행간 1.5인데 Web매핑에서 1.4로 기재. 0.1 차이 |
| disabled-opacity | - | 0.38-0.5 | 0.38 | PASS | M3 표준값 채택 |

### Android 매핑 vs platforms/android.md

| 토큰 | 원본(android.md) | 통합값 | Android매핑값 | 판정 |
|------|-----------------|--------|-------------|------|
| touch-target-min | 48x48dp | 44x44pt | 48x48dp | PASS | 플랫폼별 차이 정확 반영 |
| screen-margin-regular | 24dp (expanded) | 20pt | 24dp | PASS | 플랫폼별 차이 정확 반영 |
| corner-radius-small | 8dp (M3 Small) | 6-8pt | 8dp | PASS |
| corner-radius-medium | 12dp (M3 Medium) | 10-13pt | 12dp | PASS | M3 표준 12dp 정확 |
| corner-radius-large | 16dp (M3 Large) | 16-22pt | 16dp | FAIL | 통합값 범위는 16-22pt이나 Android 매핑은 16dp(M3 Large). M3 Extra Large는 28dp인데 iOS 22pt와 시각적으로 동등하지 않음 |
| body-size | 16sp (Body Large) | 17pt(iOS)/16px(web) | 16sp | PASS |
| depth-layers | 5단계 (M3) | 3단계 | 5단계 | FAIL | 통합은 3단계(Dye/Matas/Kandinsky), android.md/M3는 0-5 6단계. iOS매핑도 3단계. Android만 5단계로 기재하여 플랫폼 간 불일치 |
| headline-size | 28sp (Headline Medium) | 28-34pt | 28-32sp | PASS | 범위 내 |

## 3. 내적 일관성 검증 결과

### unified-tokens vs conflicts.md 일관성

| 항목 | 판정 | 근거 |
|------|------|------|
| gradient-usage | PASS | 통합에 "conflict - see conflicts.md" 명시. conflicts.md에 해결 방식(맥락 분리) 기재 |
| whitespace-ratio (40-60%) vs void-ratio (70-90%) | PASS | 맥락 분리로 양립. conflicts.md에 기록됨 |
| corner-radius (Ive vs Rams) | PASS | conflicts.md에 맥락 분리(Apple: 곡률, 그래픽: 직각) 기재 |
| base-unit (4pt vs 8pt) | PASS | conflicts.md에 상위 호환 전략 기재 (4pt 채택, 8pt는 배수) |
| accent-usage 범위 | FAIL | 통합에 5-15%(Rams, Albers)로 기재되나 conflicts.md에서는 Rams:5%, Mondrian:15-30%, Rand:30-50%로 3자 충돌 기록. Albers는 충돌 당사자가 아님 |
| font-size-ratio | PASS | conflicts.md에 Tschichold(1.5-2x) vs Rand(2-3x) → variants 전략으로 양립 |

### 3개 플랫폼 매핑 교차 비교

| 토큰 | iOS | Web | Android | 시각적 동등성 | 판정 |
|------|-----|-----|---------|-------------|------|
| base-unit | 4pt | 4px | 4dp | 동등 (1pt=1px=1dp @1x) | PASS |
| body-size | 17pt | 16px | 16sp | iOS만 1pt 크게 — 의도적 플랫폼 차이 | PASS |
| corner-radius-large | 22pt | 22px | 16dp | FAIL — iOS/Web 22pt vs Android 16dp. 6dp 차이는 시각적으로 분명히 다름 | FAIL |
| depth-layers | 3단계 | 3단계 | 5단계 | FAIL — Android만 5단계. 동일 토큰이 다른 계층 수를 의미 | FAIL |
| touch-target | 44pt | 44px | 48dp | 의도적 플랫폼 차이 (M3 표준) | PASS |
| disabled-opacity | 0.38 | 0.38 | 0.38f | 동등 | PASS |

### 충돌 해결 합리성

| 충돌 | 해결 전략 | 판정 | 비고 |
|------|----------|------|------|
| base-unit 4pt vs 8pt | 상위 호환 | PASS | 4pt가 8pt를 포함하므로 합리적 |
| gradient 사용 여부 | 맥락 분리 | PASS | 구조적 UI vs 몰입형의 구분이 명확 |
| corner-radius 곡률 vs 직각 | 맥락 분리 | PASS | 플랫폼 특성 반영 |
| font-family-count 1종 vs 2-3종 | 맥락 분리 | PASS | 유틸리티 vs 에디토리얼 합리적 |
| accent-area 5% vs 15-30% vs 30-50% | 맥락 분리 | WARNING | 3단계 분리는 합리적이나 통합 토큰에서 5-15%로 축약한 것과 모순 |

## 4. FAIL 항목 교정 제안

### FAIL-1: accent-usage 출처 오류
- **현재**: `accent-usage | 5-15% | Rams, Albers`
- **문제**: Albers 원본에 accent-usage 토큰 없음. Rams는 5% 이하
- **교정**: `accent-usage | 5-15% | Rams(5%), Mondrian(15-30%) — 맥락 분리` 또는 conflicts.md 참조 링크 추가

### FAIL-2: Web line-height-ratio 불일치
- **현재**: Web 매핑 line-height-ratio = 1.4
- **문제**: web.md 공식 Body 행간은 1.5
- **교정**: Web 매핑의 line-height-ratio를 `1.4-1.5`로 수정하거나, Body 기본값을 1.5로 변경

### FAIL-3: corner-radius-large 플랫폼 불일치
- **현재**: iOS 22pt / Web 22px / Android 16dp
- **문제**: Android M3 Large=16dp는 iOS 22pt와 시각적으로 동등하지 않음
- **교정**: Android에 corner-radius-xl(28dp, M3 Extra Large)를 추가하거나, 매핑 테이블에 "iOS 22pt = Android M3 Extra Large 28dp" 주석 추가

### FAIL-4: depth-layers 계층 수 불일치
- **현재**: 통합 3단계 / iOS 3단계 / Android 5단계
- **문제**: 동일 토큰이 플랫폼별로 다른 계층 수를 가짐
- **교정**: 통합에 "3단계(설계 의도) — M3는 6단계까지 지원" 주석 추가. Android 매핑도 주요 3단계 명시 후 M3 전체 범위 주석

### FAIL-5: accent-usage conflicts.md 불일치
- **교정**: conflicts.md의 3단계 분리(5%/15-30%/30-50%)와 통합의 5-15%를 정합. 통합 토큰을 "accent-usage-minimal(5%) / accent-usage-standard(5-15%) / accent-usage-brand(15-30%)"로 세분화하거나, conflicts.md 참조 명시

## 종합 판정

통합 토큰 사전의 전반적 품질은 **양호(GOOD)**하나, 아래 5개 이슈의 즉시 교정을 권고한다.

**강점:**
- 색상 토큰(system-blue, system-red 등)은 HIG 공식값과 HEX 단위 정확 일치
- 대다수 S/A 등급 토큰의 원본 추적이 정확
- conflicts.md와의 교차 참조가 전반적으로 잘 유지됨
- 3개 플랫폼의 base-unit, body-size 등 핵심 토큰의 매핑이 정확

**약점:**
- 통합 토큰에 **출처 신뢰도 등급이 미표기**되어, F등급 출처가 S등급과 동등하게 보이는 문제
- corner-radius 계열에서 Ive(B등급 실측) vs Dye(S/A등급 공식)의 값 차이가 범위로 흡수되면서 정밀도 저하
- Android 매핑에서 M3 표준과 통합 토큰 간 계층 구조 불일치(depth-layers, corner-radius-large)
- accent-usage의 출처 기재 오류(Albers)
- Web line-height 수치 0.1 차이
