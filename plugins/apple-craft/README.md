# apple-craft

Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit/AppKit 코드 작성·리뷰·디버깅 + Xcode MCP 연동.

Xcode 26 번들 문서 기반 최신 API 참조 문서 20개 내장.

## 핵심 기능

| 기능 | 설명 |
|------|------|
| **코드 작성** | Swift/SwiftUI/UIKit/AppKit 코드 작성, 리팩토링, 마이그레이션 |
| **빌드 & 디버깅** | Xcode MCP 연동으로 빌드, 프리뷰, 에러 진단 |
| **API 탐색** | DocumentationSearch + 20개 최신 API 참조 문서 |
| **코드 리뷰** | 코드 스타일, 아키텍처, 성능 검토 |
| **Harness 모드** | Plan→Build→Evaluate 에이전트 루프로 장기 개발 자동화 |

## 내장 참조 문서 (20개)

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

### 일반 개발 작업
- "이 SwiftUI 뷰 성능 개선해줘" → troubleshoot 모드
- "MVVM으로 네트워크 레이어 리팩토링" → implement 모드
- "async/await 사용법 알려줘" → explore 모드

### 최신 API 작업
- "Liquid Glass 적용 방법 알려줘" → explore 모드 + 참조 문서 로드
- "FoundationModels로 세션 만드는 코드" → implement 모드 + 참조 문서 로드

### 장기 개발 작업 (Harness 모드)
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
