# Apple 플랫폼 디자인 가이드라인 요약

ios-designer 에이전트의 기본 참조 문서.

## 공식 출처

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SF Pro Typography](https://developer.apple.com/fonts/)

## 핵심 정량 기준

### 레이아웃

| 항목 | 값 | 출처 |
|------|-----|------|
| 최소 터치 타겟 | 44×44pt | HIG > Accessibility |
| 기본 margin | 16pt (compact), 20pt (regular) | HIG > Layout |
| 간격 그리드 | 8pt 기반 | HIG > Layout |
| Safe Area (상단) | 59pt (Dynamic Island), 47pt (노치) | iOS Safe Area Guide |
| Safe Area (하단) | 34pt (홈 인디케이터) | iOS Safe Area Guide |

### 타이포그래피 (SF Pro)

| 스타일 | 크기 | 행간 | 자간 |
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

### 색상

| 항목 | Light | Dark |
|------|-------|------|
| 시스템 배경 | #FFFFFF | #000000 |
| 2차 배경 | #F2F2F7 | #1C1C1E |
| 3차 배경 | #FFFFFF | #2C2C2E |
| 라벨 (1차) | #000000 | #FFFFFF |
| 라벨 (2차) | rgba(60,60,67,0.6) | rgba(235,235,245,0.6) |
| 시스템 블루 | #007AFF | #0A84FF |
| 구분선 | rgba(60,60,67,0.29) | rgba(84,84,88,0.6) |

### Corner Radius

| 컴포넌트 | 값 | 비고 |
|----------|-----|------|
| 소형 버튼 | 8pt | |
| 텍스트 필드 | 10pt | |
| 카드/시트 | 12pt | |
| 앱 아이콘 (홈) | continuous 곡선, ~23.4% | 슈퍼엘립스 |
| 모달 시트 | 12pt (상단) | |

### Liquid Glass (iOS 26+)

| 항목 | 값 | 비고 |
|------|-----|------|
| 배경 블러 반경 | ~20pt | 시스템 material |
| 투명도 (glass) | 0.7-0.85 | 배경에 따라 가변 |
| 그림자 | 없음 (블러로 대체) | elevation → translucency |
| 경계선 | 1px, rgba(255,255,255,0.2) | 글래스 엣지 |

## SwiftUI 매핑 힌트

```swift
// 간격
.padding() // 16pt 기본
.padding(.horizontal, 20) // regular width

// 타이포
.font(.body) // 17pt SF Pro
.font(.largeTitle) // 34pt SF Pro

// 색상
Color(.systemBackground)
Color(.secondarySystemBackground)

// Corner Radius
.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

// Glass (iOS 26+)
.glassEffect()
```
