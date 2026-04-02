# 토큰 검증 루브릭

디자인 토큰의 정확성과 유효성을 검증하는 체크리스트.

## 필수 검증 항목

### 1. 수치 정확도

| 검증 대상 | 방법 | 통과 기준 |
|----------|------|----------|
| 간격/여백 (spacing) | 공식 가이드라인 대조 | 가이드라인 ±2pt 이내 |
| 곡률 (corner-radius) | 공식 앱 실측 | 실측값 ±1pt 이내 |
| 색상 (color) | 공식 팔레트 대조 | HEX/HSL 정확 일치 |
| 타이포 (typography) | SDK 기본값 대조 | 정확 일치 |
| 투명도 (opacity) | 공식 문서 / 실측 | ±0.05 이내 |

### 2. 플랫폼 호환성

| 검증 대상 | iOS | Web | Android |
|----------|-----|-----|---------|
| 최소 터치 타겟 | 44×44pt | 44×44px | 48×48dp |
| 최소 본문 폰트 | 17pt (SF Pro) | 16px | 14sp (M3) |
| 색상 대비 (AA) | 4.5:1 / 3:1 | 4.5:1 / 3:1 | 4.5:1 / 3:1 |
| 기본 간격 단위 | 8pt 그리드 | 4/8px 그리드 | 4dp 그리드 |

### 3. 교차 플랫폼 일관성

동일한 디자인 의도를 표현할 때 플랫폼별 토큰이 시각적으로 동등한지 검증:

- `spacing.md` → iOS 16pt = Web 16px = Android 16dp (밀도 보정)
- `corner-radius.lg` → iOS 16pt ≈ Web 16px ≈ Android 16dp
- `elevation.card` → iOS shadow(0,2,8,0.15) ≈ Web box-shadow ≈ Android elevation 2dp

### 4. 출처 추적성

모든 토큰에 출처가 명시되어야 한다:

```
✅ corner-radius: 12pt (출처: HIG Components > Buttons, 등급: S)
❌ corner-radius: 12pt (출처 없음)
```
