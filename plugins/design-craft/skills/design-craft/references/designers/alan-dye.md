# Alan Dye -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 2006-현재, 핵심기 2014-현재 (VP of Human Interface Design)
- **주요 소속**: Apple VP of Human Interface Design (2015-현재), Apple 마케팅 그래픽 디자인 팀 (2006-2014)
- **핵심 공헌**: watchOS UI 설계, iOS 14+ 위젯 시스템, Apple 마케팅 비주얼 아이덴티티, Dynamic Island(iPhone 14 Pro), visionOS 공간 인터페이스, iOS 후기 시각 언어 총괄
- **디자인 계보**: Apple 마케팅 디자인 → Jony Ive 하 HI 디자인 → 포스트-Ive 독자 비전 (물리-디지털 통합)

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 글랜스 가능성 (Glanceability) | 핵심 정보 인식 ≤ 2초 | watchOS complication 데이터 포인트 ≤ 3 |
| 물리-디지털 연속성 | 물리 입력 → 디지털 반응 ≤ 16ms | Digital Crown 회전 → UI 스크롤 1:1 매핑 |
| 적응형 레이아웃 | 디바이스 크기별 자동 리플로우 | 40mm/44mm/45mm/49mm 4종 대응 |
| 진입점 단순화 | 핵심 기능 도달 ≤ 1탭 | 위젯 → 앱 = 1탭, complication → 앱 = 1탭 |
| 깊이와 계층 | z-축 레이어 명확 구분 | 최대 3단계 깊이 (배경-콘텐츠-오버레이) |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| watchos-screen-40mm | 162×197pt (394×484px @2x) | watchOS HIG — 40mm 화면 스펙 | S |
| watchos-screen-44mm | 184×224pt (448×544px @2x) | watchOS HIG — 44mm 화면 스펙 | S |
| watchos-screen-45mm | 198×242pt (396×484px @2x) | watchOS HIG — 45mm 화면 스펙 | S |
| watchos-screen-49mm | 205×251pt (410×502px @2x) | watchOS HIG — 49mm Ultra 화면 스펙 | S |
| watchos-margin | 좌우 각 8.5pt (40mm), 9pt (44mm) | watchOS HIG — 화면 마진 | S |
| widget-small | 169×169pt (@2x iPhone 15 Pro) | iOS HIG — Small 위젯 크기 | S |
| widget-medium | 360×169pt (@2x iPhone 15 Pro) | iOS HIG — Medium 위젯 크기 | S |
| widget-large | 360×379pt (@2x iPhone 15 Pro) | iOS HIG — Large 위젯 크기 | S |
| widget-padding | 16pt (기본 내부 여백) | iOS HIG — 위젯 패딩 | S |
| widget-corner-radius | 22pt (continuous corner) | iOS HIG — 위젯 곡률 | S |
| dynamic-island-min | 126×37pt (축소 상태) | iPhone 14 Pro Dynamic Island 실측 | A |
| dynamic-island-max | 371×160pt (확장 상태) | iPhone 14 Pro Dynamic Island 실측 | A |
| grid-base | 8pt (Apple 표준) | Apple HIG — 기본 그리드 단위 | S |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-system | SF Pro (iOS/macOS), SF Compact (watchOS) | Apple 시스템 서체 체계 | S |
| font-rounded | SF Pro Rounded (친근한 컨텍스트) | Apple HIG — 둥근 서체 변형 | S |
| watchos-title | 17pt Bold (SF Compact) | watchOS HIG — 제목 크기 | S |
| watchos-body | 15pt Regular (SF Compact) | watchOS HIG — 본문 크기 | S |
| watchos-caption | 12pt Regular (SF Compact) | watchOS HIG — 캡션 크기 | S |
| widget-title | 16-20pt Semibold (SF Pro) | iOS HIG — 위젯 제목 | A |
| widget-body | 13-15pt Regular (SF Pro) | iOS HIG — 위젯 본문 | A |
| dynamic-type-range | 11pt (xSmall) ~ 53pt (AX5) | iOS HIG — Dynamic Type 전체 범위 | S |
| font-weight-range | Ultralight(100) ~ Black(900), 9종 | SF Pro 웨이트 스펙 | S |
| line-height | 1.2 (제목), 1.35-1.4 (본문) | Apple HIG 타이포 가이드라인 | A |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| system-colors | 12색 시맨틱 팔레트 (red~brown) | Apple HIG — 시스템 컬러 12종 | S |
| tint-color | systemBlue #007AFF (기본 악센트) | Apple HIG — 기본 틴트 | S |
| background-primary | systemBackground (#FFF / #000) | Apple HIG — 1차 배경 | S |
| background-secondary | secondarySystemBackground (#F2F2F7 / #1C1C1E) | Apple HIG — 2차 배경 | S |
| material-blur | 5종 (ultra-thin~ultra-thick) | Apple HIG — 반투명 블러 재질 | S |
| vibrancy | 4종 (label, secondaryLabel, fill, separator) | Apple HIG — 진동 효과 | S |
| watchos-background | 순흑 #000000 (OLED 최적화) | watchOS HIG — 배경 = 순흑 | S |
| dark-mode-elevation | z-축 상승 시 밝기 +4-8% | Apple HIG — 다크모드 깊이 표현 | A |
| contrast-ratio | 최소 4.5:1 (본문), 3:1 (대형) | Apple 접근성 가이드라인 | S |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius-small | 10pt (버튼, 텍스트 필드) | Apple HIG — 소형 요소 곡률 | S |
| corner-radius-medium | 13pt (카드, 셀) | Apple HIG — 중형 요소 곡률 | A |
| corner-radius-large | 22pt (위젯, 모달) | Apple HIG — 대형 요소 곡률 | S |
| continuous-corner | squircle (superellipse) 곡선 | Apple 독자 곡률 수식 — CSS에 없음 | S |
| watchos-corner | 화면 곡률 따라감 (전체 화면) | watchOS — 화면 = 둥근 사각형 | S |
| icon-size | 29, 40, 60, 76, 83.5, 1024pt (앱 아이콘) | Apple HIG — 앱 아이콘 크기 체계 | S |
| icon-corner-ratio | 아이콘 크기의 22.37% (iOS) | Apple 앱 아이콘 곡률 공식 | S |
| sf-symbol-weight | 9종 웨이트 × 3종 스케일 | SF Symbols — 웨이트·스케일 매트릭스 | S |
| depth-layers | 3단계 (base, raised, overlay) | Apple HIG — 깊이 체계 | S |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| spring-animation | mass:1, stiffness:100-300, damping:10-20 | Apple 스프링 애니메이션 기본값 분석 | A |
| transition-push | 0.35s (네비게이션 푸시 전환) | iOS UINavigationController 기본값 | S |
| transition-modal | 0.4s (모달 프레젠테이션) | iOS 모달 전환 시간 실측 | A |
| haptic-feedback | 3종 (light, medium, heavy) + 6종 notify | Apple Haptic 엔진 피드백 체계 | S |
| digital-crown | 1회전 = 콘텐츠 높이의 100% 스크롤 | watchOS Digital Crown 매핑 | A |
| scroll-deceleration | fast(0.99) / normal(0.998) | UIScrollView decelerationRate | S |
| long-press-duration | 0.5s (기본), 0.12s (3D Touch) | iOS 롱프레스 인식 시간 | S |
| rubber-band | 오버스크롤 시 1/3 비율 감속 | iOS 러버밴드 효과 비율 | A |
| dynamic-island-morph | 0.3-0.5s 형태 변환 애니메이션 | Dynamic Island 전환 시간 실측 | A |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 2006-2013 | Apple 마케팅 디자인 | 스큐어모피즘 → 플랫 전환기, 마케팅 비주얼 총괄 |
| 2014-2016 | watchOS 1.0 + VP 취임 | 38/42mm 화면 레이아웃, 글랜스 UI 개념 확립 |
| 2017-2019 | watchOS 성숙 + iOS 리파인 | Series 4 둥근 화면 도입, complication 체계 확장 |
| 2020-2022 | 위젯 시스템 + Dynamic Island | iOS 14 위젯 그리드, iPhone 14 Pro Dynamic Island |
| 2023-현재 | visionOS + Vision Pro | 공간 UI 3D 깊이 체계, 시선 추적 기반 인터랙션 |

## 영향 관계

- **Jony Ive → Dye**: Ive의 플랫 디자인/물성 원칙을 HI 디자인에 적용
- **스위스 타이포그래피 → Dye**: SF Pro의 그리드 기반 서체 체계
- **Dye → watchOS 생태계**: 초소형 화면 UI 패러다임 확립
- **Dye → 위젯 경제**: iOS 위젯이 안드로이드·웹 위젯 디자인에 영향
- **Dye → 공간 컴퓨팅**: visionOS가 XR UI 디자인의 새 표준
- **주요 참고**: Apple HIG (developer.apple.com/design), WWDC 디자인 세션

## UI 적용 매핑

| Dye 원칙 | 현대 UI 토큰 변환 규칙 |
|---------|----------------------|
| 글랜스 가능성 | 위젯/complication = 데이터 포인트 ≤ 3, 텍스트 ≤ 2줄 |
| 연속 곡률 | SwiftUI `.clipShape(.rect(cornerRadius:, style: .continuous))` |
| 시맨틱 컬러 | `.foregroundStyle(.primary)`, `.tint(.accentColor)` — 하드코딩 금지 |
| 반투명 재질 | `.background(.ultraThinMaterial)` — 깊이와 컨텍스트 동시 표현 |
| 스프링 모션 | `.animation(.spring(response: 0.35, dampingFraction: 0.7))` |
| 적응형 레이아웃 | `@Environment(\.horizontalSizeClass)` + ViewThatFits |
| 햅틱 피드백 | `UIImpactFeedbackGenerator(style: .medium)` — 물리 입력과 1:1 |
| Dynamic Type | `.font(.body)` + `.dynamicTypeSize(...)` 전체 범위 지원 |
| 깊이 3단계 | `base` → `raised`(+shadow) → `overlay`(+blur) |
| OLED 최적화 | watchOS/다크모드에서 순흑(#000) 배경, 전력 절약 |
