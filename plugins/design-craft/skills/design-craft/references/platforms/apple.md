# Apple Platform Design Guidelines Summary

Default reference document for the ios-designer agent.

## Official Sources

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SF Pro Typography](https://developer.apple.com/fonts/)

## Core Quantitative Criteria

### Layout

| Item | Value | Source |
|------|-----|------|
| Minimum touch target | 44×44pt | HIG > Accessibility |
| Default margin | 16pt (compact), 20pt (regular) | HIG > Layout |
| Spacing grid | 8pt based | HIG > Layout |
| Safe Area (top) | 59pt (Dynamic Island), 47pt (notch) | iOS Safe Area Guide |
| Safe Area (bottom) | 34pt (home indicator) | iOS Safe Area Guide |

### Typography (SF Pro)

| Style | Size | Line height | Tracking |
|--------|------|------|------|
| Large Title | 34pt | 41pt | 0.37 |
| Title 1 | 28pt | 34pt | 0.36 |
| Title 2 | 22pt | 28pt | 0.35 |
| Title 3 | 20pt | 25pt | 0.38 |
| Headline | 17pt (Semi-Bold) | 22pt | -0.41 |
| Body | 17pt | 22pt | -0.41 |
| Callout | 16pt | 21pt | -0.32 |
| Subheadline | 15pt | 20pt | -0.24 |
| Footnote | 13pt | 18pt | -0.08 |
| Caption 1 | 12pt | 16pt | 0 |
| Caption 2 | 11pt | 13pt | 0.07 |

### Color

| Item | Light | Dark |
|------|-------|------|
| System background | #FFFFFF | #000000 |
| Secondary background | #F2F2F7 | #1C1C1E |
| Tertiary background | #FFFFFF | #2C2C2E |
| Label (primary) | #000000 | #FFFFFF |
| Label (secondary) | rgba(60,60,67,0.6) | rgba(235,235,245,0.6) |
| System blue | #007AFF | #0A84FF |
| Separator | rgba(60,60,67,0.29) | rgba(84,84,88,0.6) |

### Corner Radius

| Component | Value | Note |
|----------|-----|------|
| Small button | 8pt | |
| Text field | 10pt | |
| Card/sheet | 12pt | |
| App icon (home) | continuous curve, ~23.4% | superellipse |
| Modal sheet | 12pt (top) | |

### Liquid Glass (iOS 26+)

| Item | Value | Note |
|------|-----|------|
| Background blur radius | ~20pt | system material |
| Opacity (glass) | 0.7-0.85 | varies by background |
| Shadow | none (replaced by blur) | elevation → translucency |
| Border | 1px, rgba(255,255,255,0.2) | glass edge |

## SwiftUI Mapping Hints

```swift
// Spacing
.padding() // 16pt default
.padding(.horizontal, 20) // regular width

// Typography
.font(.body) // 17pt SF Pro
.font(.largeTitle) // 34pt SF Pro

// Color
Color(.systemBackground)
Color(.secondarySystemBackground)

// Corner Radius
.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

// Glass (iOS 26+)
.glassEffect()
```
