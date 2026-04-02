# iOS 플랫폼 매핑 (SwiftUI / UIKit)

통합 토큰을 iOS 구현값으로 변환한다.

## Layout & Spacing

| 통합 토큰 | iOS 값 | SwiftUI API | 비고 |
|----------|--------|-------------|------|
| base-unit | 4pt | 직접 수치 사용 | HIG 최소 단위 |
| grid-base | 8pt | `.padding(8)` | 모든 간격 8의 배수 |
| spacing-scale | 4-48pt | `.padding()`, `Spacer(minLength:)` | 4pt 단위 스케일 |
| screen-margin-compact | 16pt | `.padding(.horizontal, 16)` | size class compact |
| screen-margin-regular | 20pt | `.padding(.horizontal, 20)` | size class regular |
| content-width-max | 672pt | `.frame(maxWidth: 672)` | readableContentGuide |
| touch-target-min | 44x44pt | `.frame(minWidth: 44, minHeight: 44)` | HIG 필수 |
| nav-bar-height | 44/96pt | `.navigationBarTitleDisplayMode(.large)` | UIKit 자동 관리 |
| tab-bar-height | 49/83pt | `TabView` | home indicator 포함 |
| golden-ratio | 1:1.618 | `GeometryReader` 비율 계산 | Rams 비례 체계 |
| hierarchy-levels | 3단계 | `.font(.title)/.body/.caption` | 시각 위계 제한 |
| void-ratio | 70-90% | `Spacer()` 다수 배치 | Lee Ufan 미니멀 |
| albers-nesting | 3-4단계 | 중첩 `ZStack` / `overlay` | 컨테이너 깊이 제한 |

## Typography

| 통합 토큰 | iOS 값 | SwiftUI API | 비고 |
|----------|--------|-------------|------|
| font-system | SF Pro / SF Compact | `.font(.system(size:weight:))` | 시스템 기본 |
| body-size | 17pt | `.font(.body)` | Dynamic Type 기본 |
| headline-size | 28-34pt | `.font(.largeTitle)` / `.title` | Large Title |
| caption-size | 11-12pt | `.font(.caption)` / `.caption2` | 최소 가독 크기 |
| type-scale | 11-34pt 8단계 | `.font(.caption2)` ~ `.font(.largeTitle)` | Dynamic Type |
| dynamic-type-range | 14-60pt | `.dynamicTypeSize(...)` | 접근성 전체 범위 |
| line-height-ratio | 1.2-1.4x | `.lineSpacing()` | SF Pro 기본 메트릭 |
| line-height-korean | 1.4-1.6x | `.lineSpacing(font * 0.5)` | 한글 행간 보정 |
| letter-spacing-title | -0.4~-1.6pt | `.tracking(-0.4)` | 대형 텍스트 타이트닝 |
| korean-tracking | -0.01em | `.tracking(-0.2)` (17pt 기준) | 한글 자간 보정 |
| font-weight-range | 100-900 | `.fontWeight(.ultraLight)` ~ `.black` | 9단계 |
| text-align | 좌측 정렬 | `.multilineTextAlignment(.leading)` | 기본값 |
| readable-line-length | 65ch | `.frame(maxWidth: .readableContentWidth)` | 가독성 최대폭 |

## Color & Surface

| 통합 토큰 | iOS 값 | SwiftUI API | 비고 |
|----------|--------|-------------|------|
| system-blue | #007AFF/#0A84FF | `Color.blue` / `.tint(.blue)` | 시맨틱 컬러 |
| system-red | #FF3B30/#FF453A | `Color.red` | 시맨틱 컬러 |
| system-green | #34C759/#30D158 | `Color.green` | 시맨틱 컬러 |
| bg-primary | #FFF/#000 | `Color(.systemBackground)` | 라이트/다크 자동 |
| bg-secondary | #F2F2F7/#1C1C1E | `Color(.secondarySystemBackground)` | 그룹 배경 |
| blur-material | 5종 | `.background(.ultraThinMaterial)` ~ `.thick` | 반투명 블러 |
| separator-color | rgba(60,60,67,0.29) | `Color(.separator)` | 시스템 구분선 |
| disabled-opacity | 0.38 | `.opacity(0.38)` + `.disabled(true)` | 비활성 상태 |
| dark-elevation | +4-8% 밝기 | `Color(.tertiarySystemBackground)` | 깊이별 밝기 |
| accent-usage | 5-15% | `.tint(.accentColor)` | 포인트 컬러 제한 |
| rothko-surface-dark | #1A1520~#4D3B52 | `Color(red:0.1, green:0.08, blue:0.12)` | 색조 다크 서피스 |

## Shape & Geometry

| 통합 토큰 | iOS 값 | SwiftUI API | 비고 |
|----------|--------|-------------|------|
| corner-radius-small | 8pt | `.clipShape(.rect(cornerRadius: 8, style: .continuous))` | 버튼/필드 |
| corner-radius-medium | 13pt | `.clipShape(.rect(cornerRadius: 13, style: .continuous))` | 카드/셀 |
| corner-radius-large | 22pt | `.clipShape(.rect(cornerRadius: 22, style: .continuous))` | 위젯/모달 |
| corner-style | squircle (G2) | `RoundedRectangle(cornerRadius:, style: .continuous)` | Apple 독자 곡선 |
| pill-shape | height/2 | `Capsule()` | 알약형 버튼 |
| depth-layers | 3단계 | `.shadow(radius:)` 단계별 | base/raised/overlay |
| sf-symbol | 9 weight x 3 scale | `Image(systemName:).symbolRenderingMode(.hierarchical)` | 자동 매칭 |
| icon-stroke | 1.5-2pt | SF Symbols 기본 | 텍스트 weight 연동 |

## Motion & Interaction

| 통합 토큰 | iOS 값 | SwiftUI API | 비고 |
|----------|--------|-------------|------|
| duration-fast | 0.15-0.2s | `.animation(.easeOut(duration: 0.2))` | 미세 피드백 |
| duration-standard | 0.25-0.35s | `.animation(.spring(response: 0.35, dampingFraction: 0.8))` | 표준 전환 |
| duration-slow | 0.4-0.5s | `.animation(.spring(response: 0.5, dampingFraction: 0.7))` | 모달 등장 |
| spring-damping | 0.7-0.85 | `dampingFraction: 0.8` | 약간 탄성 |
| spring-response | 0.3-0.5s | `response: 0.35` | 스프링 반응 |
| easing-default | ease-in-out | `.easeInOut` | Core Animation |
| haptic-feedback | 3종+6종 | `UIImpactFeedbackGenerator(style: .medium)` | 촉각 피드백 |
| reduce-motion | crossfade 0.3s | `.animation(reduceMotion ? .easeOut(0.3) : .spring())` | 접근성 대응 |
| gesture-velocity | 500pt/s | `DragGesture.Value.velocity` | 스와이프 임계 |
| rubber-band | 1/3 감속 | `ScrollView` 기본 내장 | 오버스크롤 |
| frame-rate | 60fps | `CADisplayLink` / Metal | 최소 성능 기준 |
