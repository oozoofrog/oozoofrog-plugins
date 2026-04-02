# Jony Ive -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1992-2019 (Apple), 핵심기 1996-2019 (CDO 역임)
- **주요 소속**: Apple Inc. — Industrial Design Group 수석 → CDO
- **핵심 공헌**: iMac G3(1998), iPod(2001), iPhone(2007), iPad(2010), MacBook Unibody(2008), Apple Watch(2015), iOS 7 플랫 리디자인(2013)
- **디자인 계보**: Dieter Rams의 영향을 공식 인정, Braun 미학을 디지털로 번역

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | 비고 |
|------|----------|------|
| 극단적 단순화 | UI 요소 수 ≤ 5개/화면 (iOS 7 기준) | 스큐어모피즘 제거 후 레이어 60% 감소 |
| 재질의 정직성 | 표면 텍스처 0개 (iOS 7+), 실제 재질 1종/제품 | 알루미늄·유리·세라믹 |
| 곡률의 연속성 | G2 연속(squircle) 곡선, 비원형 둥글림 | iOS 7 앱 아이콘 슈퍼엘립스 |
| 공백이 곧 기능 | 콘텐츠 대비 여백 비율 40-60% | HIG 마진 기준 |
| 정밀한 그리드 | 4pt/8pt 기반 간격 체계 | iOS/macOS 공통 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| base-unit | 4pt | Apple HIG (2013-2019) | S |
| spacing-scale | 4, 8, 12, 16, 20, 24, 32, 40, 48pt | Apple HIG 간격 체계 | S |
| screen-margin-compact | 16pt (좌우) | HIG Layout Margins | S |
| screen-margin-regular | 20pt (좌우) | HIG Layout Margins | S |
| content-width-max | 672pt (readable content) | HIG Readable Width | S |
| nav-bar-height | 44pt (compact) / 96pt (large title) | UIKit 기본값 | A |
| tab-bar-height | 49pt (compact) / 83pt (home indicator 포함) | UIKit 기본값 | A |
| status-bar-height | 20pt (pre-X) / 44pt (notch) / 54pt (dynamic island) | iOS 측정값 | B |
| grid-column-gutter | 8pt | HIG 그리드 가이드 | S |
| whitespace-ratio | 40-60% (화면 대비) | iOS 기본 앱 실측 | B |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family-system | San Francisco (SF Pro/SF Compact) | Apple 공식 서체 (2015-) | S |
| font-family-pre-2015 | Helvetica Neue | iOS 7-8 시스템 서체 | S |
| type-scale | 11, 12, 13, 15, 17, 20, 22, 28, 34pt | HIG Dynamic Type | S |
| body-size | 17pt | HIG 기본 본문 | S |
| headline-size | 28-34pt | HIG Large Title | S |
| caption-size | 11-12pt | HIG Caption | S |
| line-height-ratio | 1.2-1.4x (font-size 대비) | SF Pro 메트릭 실측 | B |
| font-weight-range | Ultralight(100)-Black(900), 9단계 | SF Pro 가변 축 | S |
| letter-spacing-body | 0pt (tracking) | SF Pro 기본 | A |
| letter-spacing-title | -0.4 ~ -1.6pt (negative tracking) | HIG 대형 텍스트 권장 | A |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| system-blue | #007AFF (light) / #0A84FF (dark) | HIG System Colors | S |
| system-red | #FF3B30 (light) / #FF453A (dark) | HIG System Colors | S |
| system-green | #34C759 (light) / #30D158 (dark) | HIG System Colors | S |
| background-primary | #FFFFFF (light) / #000000 (dark, OLED) | HIG Backgrounds | S |
| background-secondary | #F2F2F7 (light) / #1C1C1E (dark) | HIG Grouped Background | S |
| background-tertiary | #FFFFFF (light) / #2C2C2E (dark) | HIG Elevated Surface | S |
| separator-color | rgba(60,60,67,0.29) light | HIG Separator | S |
| blur-material | UIBlurEffect.Style — thin/regular/thick | UIKit Vibrancy | A |
| blur-radius | 20-40pt (frosted glass 효과) | iOS 실측 | B |
| surface-material | 알루미늄 7000 시리즈, 유리(Ceramic Shield) | Apple 제품 스펙 | S |
| palette-saturation | 채도 70-90% (시스템 컬러), 저채도 10-20% (배경) | HIG 컬러 실측 | B |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius-small | 6-8pt (버튼, 텍스트필드) | HIG 컴포넌트 실측 | B |
| corner-radius-medium | 10-13pt (카드, 모달) | HIG 실측 | B |
| corner-radius-large | 16-20pt (시트, 위젯) | HIG 실측 | B |
| corner-radius-app-icon | 연속 곡률(squircle), iOS 아이콘 마스크 | Apple 아이콘 그리드 스펙 | S |
| corner-style | .continuous (SwiftUI) — G2 연속 곡선 | RoundedRectangle 문서 | S |
| device-edge-radius | 39pt (iPhone 14 Pro), 55pt (iPad Pro) | 디바이스 스펙 실측 | B |
| icon-grid | 60x60pt @2x (앱 아이콘 기본) | HIG App Icon Spec | S |
| icon-optical-weight | 선 두께 1.5-2pt @1x | SF Symbols 가이드 | S |
| aspect-ratio-device | 19.5:9 (iPhone), 4:3 (iPad), 16:10 (Mac) | 디바이스 스펙 | S |
| bezel-to-screen | ≥ 90% 화면 비율 (2017+) | Apple 스펙 | S |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| animation-duration-fast | 0.15-0.2s | UIKit 기본 애니메이션 | A |
| animation-duration-standard | 0.25-0.35s | UIKit/SwiftUI 전환 | A |
| animation-duration-slow | 0.4-0.5s (모달 등장/퇴장) | iOS 실측 | B |
| spring-damping | 0.7-0.85 (약간 바운스) | UIView.animate 기본값 | A |
| spring-response | 0.3-0.5s | SwiftUI .spring() | A |
| easing-default | ease-in-out (cubic-bezier(0.42, 0, 0.58, 1)) | Core Animation | A |
| gesture-velocity-threshold | 500pt/s (스와이프 인식) | UIKit gesture 기본 | A |
| haptic-feedback | light/medium/heavy (UIImpactFeedbackGenerator) | HIG Haptics | S |
| parallax-depth | 10-20pt 시차 (홈 화면 월페이퍼) | iOS 실측 | B |
| touch-target-min | 44x44pt | HIG 터치 타겟 | S |

### 접근성 & 적응형

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| dynamic-type-range | xSmall(14pt) ~ AX5(60pt), 12단계 | HIG Dynamic Type | S |
| bold-text-weight | .regular → .semibold 자동 변환 | iOS 접근성 설정 | A |
| reduce-motion | crossfade 0.3s로 대체 (spring 애니메이션 비활성) | iOS 동작 줄이기 | S |
| reduce-transparency | blur 제거, 불투명 배경 대체 | iOS 투명도 줄이기 | S |
| increase-contrast | separator 1pt → 2pt, 대비 +20% | iOS 대비 증가 | A |
| color-filter | 그레이스케일/적-녹 필터 지원 | iOS 색상 필터 | S |
| smart-invert | 이미지·미디어 제외 색상 반전 | iOS 스마트 반전 | S |
| minimum-text-size | 11pt (접근성 최소 — 캡션2) | HIG 최소 텍스트 | S |

### 아이콘 & SF Symbols

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| sf-symbol-scale | small/medium/large (기본 medium) | SF Symbols 3.0+ | S |
| sf-symbol-weight | 텍스트 weight와 자동 매칭 | SF Symbols 문서 | S |
| sf-symbol-rendering | monochrome/hierarchical/palette/multicolor | SF Symbols 4.0 | S |
| sf-symbol-size | 텍스트 point size에 비례 (자동) | SF Symbols 가이드 | S |
| app-icon-size-iphone | 60x60pt @2x/@3x (120/180px) | HIG 앱 아이콘 스펙 | S |
| app-icon-size-ipad | 76x76pt @2x (152px), 83.5x83.5pt @2x (167px) | HIG 앱 아이콘 스펙 | S |
| app-icon-padding | 아이콘 내부 안전 영역 — 외곽에서 10% 마진 | Apple 아이콘 그리드 | S |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1998-2006 | 반투명 플라스틱 → 알루미늄 | 소재 투과율 70% → 0%, 표면 반사율 감소 |
| 2007-2012 | 스큐어모피즘 전성기 | 텍스처 레이어 3-5개/화면, 그림자 depth 5-15pt |
| 2013 (iOS 7) | 플랫 디자인 전환 | 텍스처 0개, 그림자 → blur, 서체 Helvetica Neue Light |
| 2014 (iPhone 6) | 화면 크기 다변화 | size class 도입, 375pt/414pt 너비 추가 |
| 2015 | SF Pro 도입 + 3D Touch | 압력 3단계(peek/pop), 가변 서체 전환 |
| 2017 (iPhone X) | 노치 + 홈 인디케이터 | safe area 도입, 상단 44pt/하단 34pt 인셋 |
| 2019 | Ive 퇴사, 다크모드 도입 | 이중 컬러 시스템 (#FFFFFF/#000000 기반) |

## 영향 관계

- **Dieter Rams → Jony Ive**: Braun SK4의 그리드 → iPod 인터페이스, ET66 계산기 → iOS 계산기 앱 (거의 1:1 번역)
- **Jony Ive → Material Design**: 플랫 디자인 전환이 Google Material Design(2014) 촉발
- **Jony Ive → 산업 전반**: 유니바디 알루미늄 공법이 노트북 산업 표준화
- **참고 운동**: 바우하우스(기능주의), De Stijl(기하학적 순수성)
- **주요 참고 문헌**: "Jony Ive: The Genius Behind Apple's Greatest Products" (Leander Kahney, 2013)

## 핵심 제품 토큰 스냅샷

| 제품 | 핵심 토큰 | 값 |
|------|----------|---|
| iPod Classic | 클릭휠 지름 | 38mm, 원형 |
| iPhone (2007) | 스크린 corner-radius | 10pt, 3.5인치 |
| MacBook Unibody (2008) | 알루미늄 두께 | 0.3mm 쉘 |
| iPad (2010) | 베젤 너비 | 좌우 25mm, 상하 20mm |
| Apple Watch (2015) | 디지털 크라운 지름 | 5.3mm |
| iPhone X (2017) | 노치 너비 | 209pt (전체 375pt 대비 55.7%) |
| AirPods Pro (2019) | 이어팁 3단계 | S/M/L |

## UI 적용 매핑

| Ive 원칙 | 현대 UI 토큰 변환 규칙 |
|----------|----------------------|
| 4pt 그리드 | 모든 간격을 4의 배수로 설정, 최소 단위 4pt |
| 연속 곡률 | SwiftUI `.cornerRadius` 대신 `RoundedRectangle(cornerRadius:, style: .continuous)` 사용 |
| 시스템 컬러 | 시맨틱 컬러 사용 (Color.primary, .secondary, .accentColor) |
| blur 표면 | `.background(.ultraThinMaterial)` ~ `.background(.thickMaterial)` 계층 |
| 대형 제목 | `.navigationBarTitleDisplayMode(.large)` — 34pt Bold |
| 터치 영역 | `.frame(minWidth: 44, minHeight: 44)` 보장 |
| 모션 | `.animation(.spring(response: 0.35, dampingFraction: 0.8))` 기본 적용 |
| 다크모드 | 순수 black(#000000) 배경으로 OLED 최적화 |
| 여백 | `.padding()` 기본값 16pt, 콘텐츠 영역 여백 비율 40% 이상 유지 |
| 접근성 | Dynamic Type 필수 지원, `.font(.body)` 사용, 고정 pt 금지 |
| SF Symbols | 텍스트와 동일 weight 자동 매칭, `.symbolRenderingMode(.hierarchical)` |
| Safe Area | `.ignoresSafeArea()` 최소 사용, 콘텐츠는 항상 safe area 내부 |
