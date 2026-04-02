# 디자인 토큰 검증 리포트

## 검증 요약
- sync 기준: `unified-tokens.md`, `conflicts.md`, `platform-ios.md`, `platform-web.md`, `platform-android.md`, `platforms/*.md`, 관련 designer/artist 원본 문서
- audited corpus: 결정적 체크 59개 (`출처 신뢰도 20 + 수치 정확도 22 + 내적 일관성 17`) + round-001 기준 `UNVERIFIABLE` inventory 3개 (round-004에서 0개 잔여로 환원)
- PASS: 52 / WARNING: 7 / FAIL: 0 / UNVERIFIABLE: 0
- baseline note: round-001에서 기존 드리프트를 제거하고 현재 문서 기준 baseline(PASS 44 / WARNING 15 / FAIL 0 / UNVERIFIABLE 3)을 고정했다.
- round-002 delta: `unified-tokens.md`에 `출처 등급(최저)` 컬럼을 추가해 출처 신뢰도 WARNING 8개를 모두 해소했다. primary metric은 WARNING 15 → 7로 감소했다.
- round-003 delta: `unified-tokens.md`와 `platform-{ios,web,android}.md`에 Riley·Turrell·Rothko 접근성 경고 주석을 추가해 hard gate 2를 닫았다. WARNING 총계는 7로 유지됐다.
- round-004 delta: `unified-tokens.md`의 token-level accessibility usage envelope와 `platform-{ios,web,android}.md`의 구현 체크리스트로 Riley·Turrell·Rothko의 `UNVERIFIABLE` 3건을 허용/조건부/금지 규칙으로 환원했다. WARNING 총계는 7로 유지됐고 `UNVERIFIABLE`은 3 → 0이 되었다.

## 1. 출처 신뢰도 검증 (20 checks → PASS 20 / WARNING 0 / FAIL 0)

### 유지 PASS inventory
- `touch-target-min`
- `corner-radius-small`
- `system-blue`
- `separator-color`
- `cognitive-chunk-max`
- `mondrian-red`
- `rothko-surface-dark`
- `lee-canvas-white`
- `turrell-kelvin`
- `riley-bw`
- `albers-nesting-levels`
- `font-family-count`

### round-002에서 해소된 mixed-grade inventory
| 토큰 | round-001 이슈 | round-002 해소 방식 |
|---|---|---|
| `base-unit` | `Ive(S)`와 `Tschichold/Kare(F)` 기여가 한 행에서 구분되지 않았다. | `출처 등급(최저)=F`를 명시해 저신뢰 기여가 숨지 않게 했다. |
| `grid-base` | `Dye/Won(S)`, `Matas(B)`, `Rams/Vignelli/Brockmann(F)`가 혼합되어 있었다. | `출처 등급(최저)=F`를 표기해 8pt UI 변환 출처가 공식값처럼 보이지 않게 했다. |
| `body-size` | `Ive(S)`, `Norman(D/C)`, `Matas(A)` 혼합 근거가 한 행에서 등급 없이 병기되었다. | `출처 등급(최저)=D`를 표기해 플랫폼 혼합 근거의 강도를 드러냈다. |
| `whitespace-ratio` | `Ive(B)`, `Rand(A)`, `Brockmann(A)`가 같은 확신도로 보였다. | `출처 등급(최저)=B`를 표기해 실측/해석 혼합을 노출했다. |
| `accent-usage` | `Rams(B)`, `Mondrian(C)`, `Rand(D)`가 충돌 해결 행에서 동급처럼 보였다. | `출처 등급(최저)=D`를 표기해 맥락 분리 규칙이 고신뢰 단일값이 아님을 명시했다. |
| `disabled-opacity` | `Norman(A)` 기반이지만 해석 범위가 토큰 표에서 숨겨졌다. | `출처 등급(최저)=A`로 근거 강도를 고정해 재사용시 해석 여지를 줄였다. |
| `easing-minimal` | `Rams`, `Brockmann`의 해석형 UI 변환(F)이 기본값처럼 보였다. | `출처 등급(최저)=F`를 명시해 보조적 참조임을 드러냈다. |
| `gradient-usage` | conflict 해소 행이었지만 구조적 UI와 몰입형 배경 규칙의 신뢰도 차이가 표에 없었다. | `출처 등급(최저)=F`를 표기해 해석/맥락 분리 성격을 노출했다. |

## 2. 수치 정확도 검증 (22 checks → PASS 17 / WARNING 5 / FAIL 0)

### PASS inventory
- iOS: `touch-target-min`, `screen-margin-compact`, `body-size`, `system-blue`, `bg-secondary`, `separator-color`
- Web: `body-size`, `contrast-ratio-text`, `line-height-ratio`, `disabled-opacity`
- Android: `touch-target-min`, `screen-margin-regular`, `corner-radius-small`, `corner-radius-medium`, `body-size`, `depth-layers`, `headline-size`

### WARNING inventory
| 영역 | 토큰 | 현재 판정 | 근거 |
|---|---|---|---|
| iOS | `corner-radius-small` | WARNING | unified `6-8pt` 범위를 `platform-ios`는 8pt로 고정한다. Apple 공식 요약은 8pt, `Ive` 실측은 6-8pt라서 수치 폭이 남는다. |
| iOS | `corner-radius-medium` | WARNING | unified `10-13pt` 범위를 `platform-ios`는 13pt로 채택한다. Apple 공식 요약의 카드/시트 12pt와 `Alan Dye` 13pt가 1pt 차이로 공존한다. |
| iOS | `corner-radius-large` | WARNING | unified `16-22pt`와 `platform-ios` 22pt는 일치 가능하지만, Apple 공식 요약에는 12pt 시트 중심 값만 있어 large radius 근거가 designer doc 쪽으로 기운다. |
| Web | `touch-target-min` | WARNING | `platform-web`은 44px를 채택한다. 이는 WCAG 2.2 AA 최소 24px보다 보수적이며 AAA 성격의 선택이므로, 기준 수준을 명시해야 한다. |
| Android | `corner-radius-large` | WARNING | `platform-android`는 M3 `16.dp`를 기본으로 두고, iOS 시각 동등성이 필요하면 `corner-radius-xl 28.dp`를 쓰라고 주석 처리했다. 스펙 우선/시각 동등성 우선 전략이 아직 하나로 수렴되지 않았다. |

## 3. 내적 일관성 검증 (17 checks → PASS 15 / WARNING 2 / FAIL 0)

### PASS inventory
- unified vs conflicts: `gradient-usage`, `whitespace-ratio vs void-ratio`, `corner-radius`, `base-unit`, `accent-usage`, `font-size-ratio`
- cross-platform: `base-unit`, `body-size`, `touch-target`, `disabled-opacity`
- conflict resolution: `base-unit`, `gradient`, `corner-radius`, `font-family-count`, `accent-area`

### WARNING inventory
| 항목 | 현재 판정 | 근거 |
|---|---|---|
| `corner-radius-large` 교차 플랫폼 동등성 | WARNING | iOS/Web는 22pt·22px, Android는 기본값 16dp다. `platform-android`에 보정 주석이 추가되어 FAIL은 아니지만, 하나의 토큰 이름이 두 가지 시각 전략을 동시에 가리킨다. |
| `depth-layers` 교차 플랫폼 동등성 | WARNING | unified는 `iOS 3단계 / Android 5단계`로 분기해 기존 FAIL은 해소했지만, 동일 토큰명이 여전히 서로 다른 계층 cardinality를 숨긴다. 별도 alias 또는 platform suffix가 필요하다. |

## 4. UNVERIFIABLE inventory (0 remaining)

round-004에서는 round-001~003에서 남겨 둔 3건을 **새 empirical study**가 아니라, 원본 artist 문서 + `platforms/*.md`의 접근성 기준을 결합한 **보수적 token-level usage envelope**로 환원했다. 즉 `UNVERIFIABLE` 항목을 없앴지만, 이는 제품 적용 시 허용/조건부/금지 규칙을 명시한 운영 해소이며 원본 예술 연구를 덮어쓴 것은 아니다.

| 항목 | round-004 해소 규칙 | 근거 묶음 | 잔여 판정 |
|---|---|---|---|
| `Riley` 고대비 줄무늬 (`riley-bw`, `riley-stripe-width`)의 접근성 안전 범위 | `unified-tokens.md`에 로딩/분리선/장식 패널만 허용, 패턴 면 50% 이하, 2px 이상 유지, 콘텐츠 배경/다중 주기 중첩 금지 규칙을 추가했다. `platform-web.md` 등에는 reduce-motion·focus 배경 금지 체크리스트를 보강했다. | `bridget-riley.md`의 stripe-width 2-20px, breathing-contrast 50% 여백, 대면적/콘텐츠 배경 금지 + `platforms/web.md` WCAG 2.2 대비·focus 기준 | resolved (보수적 envelope) |
| `Turrell` 색온도/호흡 (`turrell-kelvin`, `turrell-breath`)의 접근성 안전 범위 | ambient surface 30% 이상, 고정 preset 우선, 자동 변화는 opt-in + opt-out, 전환 2초 이상, 호흡 ±5%/4-8초, reduce-motion에서는 정지/크로스페이드 규칙으로 환원했다. | `james-turrell.md`의 small element 부적합, 2-5초 점진 전환, breath 4-8초, opt-out 주의 + `platforms/apple.md`/`platforms/android.md` surface/motion 기준 | resolved (보수적 envelope) |
| `Rothko` 다크 서피스 (`rothko-surface-dark`)의 텍스트/경계 가독성 범위 | body text 4.5:1, large text·icon·separator·input border 3:1, long-form text는 분리된 패널, pure black/texture 금지, 500ms 미만 빠른 전환 금지 규칙을 문서화했다. | `rothko.md`의 surface-0~3, pure black 금지, texture 금지, slow transition 500-2000ms + `platforms/web.md` WCAG AA 텍스트/non-text 기준 | resolved (contrast matrix + surface rule) |

## 5. 현재 기준의 hard-gate 관련 메모
- hard gate 1 (`unified-tokens.md` 모든 토큰에 출처 등급 표기): **충족** — `출처 등급(최저)` 컬럼이 122/122 토큰에 채워졌다.
- hard gate 2 (Riley/Turrell/Rothko 위험 토큰에 접근성 경고 주석): **충족** — `unified-tokens.md`와 `platform-{ios,web,android}.md`에 `riley-bw`, `riley-stripe-width`, `turrell-kelvin`, `turrell-breath`, `rothko-surface-dark` 경고 주석을 추가했다.
- hard gate 3 (`UNVERIFIABLE` 3건에 대안 검증 결과 또는 범위 추정치): **충족** — round-004에서 `unified-tokens.md`와 `platform-{ios,web,android}.md`에 token-level usage envelope/구현 체크리스트를 추가해 3건 모두를 허용/조건부/금지 규칙으로 환원했다.

## 6. 우선순위 제안
1. **stop condition 충족**: WARNING 7, UNVERIFIABLE 0, hard gates pass 상태이므로 본 contract 범위에서는 loop 종료(`control_action=stop`)가 적절하다.
2. 후속 선택 과제(계약 외 최적화): `corner-radius-large`, `depth-layers`를 token split 또는 platform alias로 재정리해 남은 cross-platform WARNING 2개를 줄인다.
