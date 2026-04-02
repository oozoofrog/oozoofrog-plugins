# Android 플랫폼 매핑 (Jetpack Compose)

통합 토큰을 Android Compose 구현값으로 변환한다.

## Layout & Spacing

| 통합 토큰 | Android 값 | Compose API | 비고 |
|----------|-----------|-------------|------|
| base-unit | 4.dp | 직접 수치 사용 | Material 최소 단위 |
| grid-base | 8.dp | `Modifier.padding(8.dp)` | M3 기본 간격 단위 |
| spacing-scale | 4-48.dp | `Spacer(Modifier.height(N.dp))` | 4dp 단위 스케일 |
| screen-margin-compact | 16.dp | `Modifier.padding(horizontal = 16.dp)` | 모바일 마진 |
| screen-margin-regular | 24.dp | `Modifier.padding(horizontal = 24.dp)` | 태블릿 마진 |
| content-width-max | 672.dp | `Modifier.widthIn(max = 672.dp)` | 읽기 최적 폭 |
| touch-target-min | 48x48.dp | `Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)` | M3 터치 타겟 (48dp) |
| golden-ratio | 1:1.618 | `BoxWithConstraints` 비율 계산 | Rams 비례 체계 |
| sqrt2-ratio | 1:1.414 | `Modifier.aspectRatio(1f / 1.414f)` | A 시리즈 비율 |
| grid-columns | 12열 | `LazyVerticalGrid(columns = GridCells.Fixed(12))` | 표준 그리드 |
| grid-gutter | 8-16.dp | `Arrangement.spacedBy(16.dp)` | 컬럼 간격 |
| hierarchy-levels | 3단계 | `Typography.titleLarge/bodyLarge/labelSmall` | M3 위계 |
| void-ratio | 70-90% | `Modifier.fillMaxWidth(0.3f)` | Lee Ufan 미니멀 |
| albers-nesting | 3-4단계 | 중첩 `Box` / `Surface` | 컨테이너 깊이 제한 |

## Typography

| 통합 토큰 | Android 값 | Compose API | 비고 |
|----------|-----------|-------------|------|
| font-system | Roboto / Noto Sans | `FontFamily.Default` | 시스템 기본 |
| body-size | 16sp | `MaterialTheme.typography.bodyLarge` | M3 본문 |
| headline-size | 28-32sp | `MaterialTheme.typography.headlineLarge` | M3 제목 |
| caption-size | 11-12sp | `MaterialTheme.typography.labelSmall` | 보조 텍스트 |
| type-scale | M3 15단계 | `Typography(displayLarge..labelSmall)` | Material Type Scale |
| line-height-ratio | 1.25-1.5 | `lineHeight = (fontSize * 1.4).sp` | 라틴 행간 |
| line-height-korean | 1.5-1.6 | `lineHeight = (fontSize * 1.6).sp` | 한글 행간 보정 |
| letter-spacing-title | -0.02em | `letterSpacing = (-0.02).em` | 대형 텍스트 |
| korean-tracking | -0.01em | `letterSpacing = (-0.01).em` | 한글 자간 |
| font-weight-range | Thin-Black | `FontWeight.Thin` ~ `FontWeight.Black` | 9단계 |
| text-align | Start | `textAlign = TextAlign.Start` | LTR 기본 |
| readable-line-length | 약 60자 | `Modifier.widthIn(max = 580.dp)` | 가독성 최대폭 |
| contrast-ratio-text | 4.5:1 | M3 시맨틱 컬러 자동 보장 | WCAG AA |
| korean-word-break | 어절 단위 | `LineBreak.Heading` / 커스텀 | keep-all 동등 |

## Color & Surface

| 통합 토큰 | Android 값 | Compose API | 비고 |
|----------|-----------|-------------|------|
| system-blue | #007AFF 근사 | `MaterialTheme.colorScheme.primary` | M3 primary |
| system-red | #FF3B30 근사 | `MaterialTheme.colorScheme.error` | M3 error |
| system-green | #34C759 근사 | 커스텀 `Color(0xFF34C759)` | M3에 green 없음 |
| bg-primary | surface/background | `MaterialTheme.colorScheme.background` | 라이트/다크 자동 |
| bg-secondary | surfaceVariant | `MaterialTheme.colorScheme.surfaceVariant` | 보조 배경 |
| palette-3color | primary, background, onBackground | `ColorScheme(primary=, background=, ...)` | M3 최소 테마 |
| accent-usage | 5-15% | `MaterialTheme.colorScheme.primary` 포인트만 | 면적 제한 |
| surface-flat | 텍스처 없음 | `Surface(color = ...)` | 단색 표면 |
| disabled-opacity | 0.38f | `Modifier.alpha(0.38f)` | M3 비활성 기준 |
| dark-elevation | tonal elevation | `Surface(tonalElevation = 3.dp)` | M3 톤 엘리베이션 |
| rothko-dark-surface | 색조 있는 어둠 | `darkColorScheme(surface = Color(0xFF1A1520))` | 색조 다크모드 |
| blur-backdrop | - | `Modifier.blur(20.dp)` (API 31+) | Android 12+ |
| separator | M3 outline | `MaterialTheme.colorScheme.outlineVariant` | 구분선 |
| color-functional | 시맨틱 | `primary/error/tertiary` 매핑 | 의미 기반 색상 |

## Shape & Geometry

| 통합 토큰 | Android 값 | Compose API | 비고 |
|----------|-----------|-------------|------|
| corner-radius-small | 8.dp | `RoundedCornerShape(8.dp)` | M3 small |
| corner-radius-medium | 12.dp | `RoundedCornerShape(12.dp)` | M3 medium |
| corner-radius-large | 16.dp | `RoundedCornerShape(16.dp)` | M3 large — iOS 22pt와 시각적 비동등, M3 스펙 우선 (iOS 동등성이 필요하면 corner-radius-xl 28.dp 사용) |
| corner-radius-xl | 28.dp | `RoundedCornerShape(28.dp)` | M3 extra-large |
| corner-radius-zero | 0.dp | `RectangleShape` | 직각 스타일 |
| pill-shape | 50% | `CircleShape` 또는 `RoundedCornerShape(50)` | 알약형 |
| form-vocabulary | 3종 | `RectangleShape`, `CircleShape`, 커스텀 | 기본 형태 |
| icon-size | 24.dp | `Icon(modifier = Modifier.size(24.dp))` | M3 기본 |
| depth-layers | 5단계 | `Surface(shadowElevation = 0/1/3/6/12.dp)` | M3 elevation |
| mondrian-border | 4.dp 실선 | `Modifier.border(4.dp, Color.Black)` | 격자선 |

## Motion & Interaction

| 통합 토큰 | Android 값 | Compose API | 비고 |
|----------|-----------|-------------|------|
| duration-fast | 150ms | `tween(durationMillis = 150)` | 호버/클릭 |
| duration-standard | 300ms | `tween(durationMillis = 300, easing = EaseInOut)` | 표준 전환 |
| duration-slow | 450ms | `tween(durationMillis = 450)` | 모달/시트 |
| duration-immersive | 2-5s | `tween(durationMillis = 3000)` | 모드 전환 |
| spring-damping | 0.7-0.85 | `spring(dampingRatio = 0.8f, stiffness = Spring.StiffnessMedium)` | 탄성 피드백 |
| spring-response | 0.3-0.5s | `spring(stiffness = Spring.StiffnessLow)` | 스프링 반응 |
| easing-default | EaseInOut | `FastOutSlowInEasing` | M3 기본 |
| easing-minimal | EaseOut | `FastOutLinearInEasing` | 절제 모션 |
| reduce-motion | 대체 | `LocalReduceMotion.current` 체크 | 접근성 대응 |
| haptic-feedback | 3종 | `HapticFeedbackType.LongPress/TextHandleMove` | 촉각 피드백 |
| gesture-velocity | 500.dp/s | `detectDragGestures` velocity 임계 | 스와이프 인식 |
| scroll-overscroll | glow/stretch | `Modifier.verticalScroll()` 기본 내장 | M3 오버스크롤 |
| frame-rate | 60/90/120fps | `setFrameRate()` API | 가변 주사율 |
| animation-purpose | 기능적만 | 장식 애니메이션 0개 | Norman 원칙 |
| loading-indicator | M3 LinearProgressIndicator | `LinearProgressIndicator()` | 진행률 표시 |
| breath-animation | 밝기 +-5% | `infiniteTransition.animateFloat(0.95f, 1f, ...)` | Turrell 호흡 |
| focus-indicator | 외곽선 | `Modifier.focusable()` + `indication` | 접근성 포커스 |
