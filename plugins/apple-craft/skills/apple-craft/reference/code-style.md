# Apple Code Style & Xcode MCP Tool Integration

## Apple Code Style (Xcode Agent 가이드 기반)

Xcode의 내장 AI 에이전트가 사용하는 코드 스타일 규칙입니다:

- **Naming**: PascalCase(타입), camelCase(프로퍼티/메서드)
- **State**: `@State private var`(SwiftUI 상태), `let`(상수)
- **Indentation**: 4-space
- **Concurrency**: Swift Concurrency(async/await, actors) 우선, **Combine 지양**
- **Testing**: Swift Testing 프레임워크 (`@Test`, `#expect`, `try #require()`)
- **Preview**: `#Preview` 매크로 (PreviewProvider 아닌)
- **Types**: 강한 타입 시스템 활용, force unwrap 금지
- **Imports**: 파일 상단에 간결하게 (SwiftUI, Foundation)
- **Comments**: 복잡한 로직에만 설명 주석 추가

## Xcode MCP Tool Integration

Xcode MCP 서버가 연결되어 있으면 다음 도구를 활용하세요:

### 문서 & 탐색
- **`mcp__xcode__DocumentationSearch`**: 로컬 참조 20개에 없는 Apple API 검색. 최신 API는 여기서 찾기

### 빌드 & 실행
- **`mcp__xcode__BuildProject`**: 코드 작성 후 빌드 검증 (시간이 오래 걸릴 수 있음)
- **`mcp__xcode__XcodeRefreshCodeIssuesInFile`**: 특정 파일의 빠른 컴파일 진단 (2초 이내, 빌드보다 훨씬 빠름)
- **`mcp__xcode__GetBuildLog`**: 빌드 로그로 컴파일 에러 진단
- **`mcp__xcode__XcodeListNavigatorIssues`**: 현재 경고/에러 목록
- **`mcp__xcode__ExecuteSnippet`**: 소스 파일 컨텍스트에서 코드 스니펫 실행 (API 검증에 유용)

### 프리뷰 & UI
- **`mcp__xcode__RenderPreview`**: SwiftUI 프리뷰 렌더링 (Liquid Glass, Charts 3D, Toolbar 등 시각적 기능 검증 필수)

### 파일 탐색
- **`mcp__xcode__XcodeRead`** / **`XcodeWrite`** / **`XcodeUpdate`**: Xcode 프로젝트 내 파일 읽기/쓰기
- **`mcp__xcode__XcodeGrep`** / **`XcodeGlob`**: 프로젝트 검색

### 도구 선택 Quick Guide

```
검증 필요?
├─ 빠른 문법 체크 → XcodeRefreshCodeIssuesInFile (2초)
├─ 전체 빌드 → BuildProject (느림, 정확)
├─ 코드 실행 테스트 → ExecuteSnippet (빠름, 임시)
├─ UI 확인 → RenderPreview
└─ API 검색 → DocumentationSearch
```

> Xcode MCP 서버가 연결되지 않은 경우에도 참조 문서만으로 코딩 가이드를 제공하세요.
