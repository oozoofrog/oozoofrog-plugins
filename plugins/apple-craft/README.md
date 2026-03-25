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

### 단발성 작업 (apple-craft 스킬)
- "Liquid Glass 적용 방법 알려줘" → explore 모드
- "FoundationModels로 세션 만드는 코드" → implement 모드
- "빌드 에러 glassEffect 관련" → troubleshoot 모드

### 장기 개발 작업 (apple-craft-harness 스킬)
- "처음부터 Liquid Glass 설정 화면 만들어줘" → harness 모드
- "전체 UI를 Liquid Glass로 리팩토링해줘" → harness 모드

## Harness Mode

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) V2 패턴 기반.

| Agent | Role | Color |
|-------|------|-------|
| `harness-planner` | 제품 스펙 + JSON 기능 목록 생성 | 🔵 |
| `harness-builder` | Swift 코드 작성 + Xcode 빌드 + Git 커밋 | 🟢 |
| `harness-evaluator` | 회의적 QA 검증 (PASS/PARTIAL/FAIL) | 🔴 |

```
Plan(스펙) → Build(코드+빌드) → Evaluate(검증) → 최대 3 라운드
```

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
