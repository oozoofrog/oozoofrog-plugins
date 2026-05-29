# Token Validation Rubric

Checklist for verifying the accuracy and validity of design tokens.

## Required Checks

### 1. Numeric Accuracy

| Target | Method | Pass Criterion |
|----------|------|----------|
| spacing | Compare against official guidelines | Within ±2pt of guideline |
| corner-radius | Measure official app | Within ±1pt of measured value |
| color | Compare against official palette | Exact HEX/HSL match |
| typography | Compare against SDK defaults | Exact match |
| opacity | Official docs / measurement | Within ±0.05 |

### 2. Platform Compatibility

| Target | iOS | Web | Android |
|----------|-----|-----|---------|
| Minimum touch target | 44×44pt | 44×44px | 48×48dp |
| Minimum body font | 17pt (SF Pro) | 16px | 14sp (M3) |
| Color contrast (AA) | 4.5:1 / 3:1 | 4.5:1 / 3:1 | 4.5:1 / 3:1 |
| Base spacing unit | 8pt grid | 4/8px grid | 4dp grid |

### 3. Cross-Platform Consistency

When expressing the same design intent, verify that per-platform tokens are visually equivalent:

- `spacing.md` → iOS 16pt = Web 16px = Android 16dp (density-corrected)
- `corner-radius.lg` → iOS 16pt ≈ Web 16px ≈ Android 16dp
- `elevation.card` → iOS shadow(0,2,8,0.15) ≈ Web box-shadow ≈ Android elevation 2dp

### 4. Source Traceability

Every token must declare its source:

```
✅ corner-radius: 12pt (출처: HIG Components > Buttons, 등급: S)
❌ corner-radius: 12pt (출처 없음)
```
