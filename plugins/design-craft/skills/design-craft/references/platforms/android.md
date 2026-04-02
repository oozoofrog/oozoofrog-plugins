# Android 플랫폼 디자인 가이드라인 요약

android-designer 에이전트의 기본 참조 문서.

## 공식 출처

- [Material Design 3](https://m3.material.io/)
- [Android Developers — Design](https://developer.android.com/design)

## 핵심 정량 기준

### 레이아웃

| 항목 | 값 | 출처 |
|------|-----|------|
| 최소 터치 타겟 | 48×48dp | M3 Accessibility |
| 기본 margin (compact) | 16dp | M3 Layout |
| 기본 margin (expanded) | 24dp | M3 Layout |
| 간격 그리드 | 4dp 기반 | M3 Layout |
| 기본 gutter | 8dp | M3 Layout |

### 타이포그래피 (M3 Type Scale)

| 스타일 | 크기 | 행간 | 자간 | Weight |
|--------|------|------|------|--------|
| Display Large | 57sp | 64sp | -0.25 | 400 |
| Display Medium | 45sp | 52sp | 0 | 400 |
| Display Small | 36sp | 44sp | 0 | 400 |
| Headline Large | 32sp | 40sp | 0 | 400 |
| Headline Medium | 28sp | 36sp | 0 | 400 |
| Headline Small | 24sp | 32sp | 0 | 400 |
| Title Large | 22sp | 28sp | 0 | 400 |
| Title Medium | 16sp | 24sp | 0.15 | 500 |
| Title Small | 14sp | 20sp | 0.1 | 500 |
| Body Large | 16sp | 24sp | 0.5 | 400 |
| Body Medium | 14sp | 20sp | 0.25 | 400 |
| Body Small | 12sp | 16sp | 0.4 | 400 |
| Label Large | 14sp | 20sp | 0.1 | 500 |
| Label Medium | 12sp | 16sp | 0.5 | 500 |
| Label Small | 11sp | 16sp | 0.5 | 500 |

### Shape (Corner Radius)

| 크기 | 값 | 사용처 |
|------|-----|--------|
| Extra Small | 4dp | Chip |
| Small | 8dp | TextInput |
| Medium | 12dp | Card, Dialog |
| Large | 16dp | FAB, Sheet |
| Extra Large | 28dp | Large FAB |
| Full | 50% | Badge, Toggle |

### Elevation (Tonal + Shadow)

| 레벨 | Shadow | Tonal Overlay |
|------|--------|--------------|
| Level 0 | 0dp | 0% |
| Level 1 | 1dp | 5% |
| Level 2 | 3dp | 8% |
| Level 3 | 6dp | 11% |
| Level 4 | 8dp | 12% |
| Level 5 | 12dp | 14% |

### Dynamic Color

| 역할 | Light | Dark |
|------|-------|------|
| Primary | tone(40) | tone(80) |
| OnPrimary | tone(100) | tone(20) |
| PrimaryContainer | tone(90) | tone(30) |
| Surface | tone(99) | tone(10) |
| OnSurface | tone(10) | tone(90) |
| SurfaceVariant | tone(90) | tone(30) |
| Outline | tone(50) | tone(60) |

### Motion

| 유형 | Duration | Easing |
|------|----------|--------|
| Enter (fade in) | 200ms | EmphasizedDecelerate |
| Exit (fade out) | 150ms | EmphasizedAccelerate |
| Expand | 300ms | Emphasized |
| Collapse | 250ms | Emphasized |
| Shared Axis | 300ms | Emphasized |

## Compose 매핑 힌트

```kotlin
// 타이포
MaterialTheme.typography.bodyLarge // 16sp

// 색상
MaterialTheme.colorScheme.primary // Dynamic Color

// Shape
MaterialTheme.shapes.medium // 12dp corner

// 간격
Modifier.padding(16.dp)

// Elevation
ElevatedCard(elevation = CardDefaults.elevatedCardElevation(defaultElevation = 1.dp))
```
