# apple-craft

Apple 플랫폼 최신 API 통합 개발 가이드 — Xcode 26 번들 문서 기반.

## 포함 주제 (20개)

| Category | Topics |
|----------|--------|
| **Design** | Liquid Glass (SwiftUI, UIKit, AppKit, WidgetKit) |
| **AI** | FoundationModels (on-device LLM), Visual Intelligence, AppIntents |
| **Swift** | Swift 6.2 Concurrency, InlineArray & Span |
| **Data** | SwiftData Class Inheritance, AttributedString Updates |
| **UI** | WebKit+SwiftUI, Toolbar Features, Styled Text Editing, AlarmKit |
| **Commerce** | StoreKit Updates |
| **Maps** | MapKit GeoToolbox & PlaceDescriptors |
| **Charts** | Swift Charts 3D Visualization |
| **Accessibility** | Assistive Access |
| **Spatial** | visionOS Widgets |

## 사용법

스킬은 자연어 트리거로 자동 활성화됩니다:
- "Liquid Glass 적용 방법 알려줘"
- "FoundationModels로 온디바이스 LLM 사용하는 코드"
- "Swift 6.2 Concurrency 변경사항"
- `/apple-craft AlarmKit 반복 알람 구현`

## 문서 동기화

Xcode 업데이트 후 참조 문서를 갱신합니다:

```bash
zsh plugins/apple-craft/scripts/sync-docs.sh
```

| Option | Description |
|--------|-------------|
| `--xcode-path PATH` | Xcode.app 경로 직접 지정 |
| `--diff-only` | 변경 사항만 확인 |
| `--force` | 강제 복사 |
