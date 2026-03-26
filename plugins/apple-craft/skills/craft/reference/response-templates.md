# Response Templates

## implement 모드 응답 템플릿

```markdown
## <Feature Name> 구현

### 개요
<1-2문장으로 구현할 기능 설명>

### 코드
`<FileName.swift>` 참조: `references/<doc>.md`

\```swift:<FileName.swift>
// 구현 코드
\```

### 핵심 포인트
- <API 사용 시 주의할 점 1>
- <API 사용 시 주의할 점 2>

### 검증
- [ ] 빌드 성공
- [ ] 프리뷰 확인 (UI 관련 시)
```

## explore 모드 응답 템플릿

```markdown
## <API/Feature Name>

> <1줄 요약> — `references/<doc>.md` 참조

### Overview
<이 API가 무엇이고, 어떤 문제를 해결하는지 2-3문장>

### 주요 API
- `TypeName` — <역할 설명>
- `methodName()` — <역할 설명>

### 코드 예시
\```swift
// 기본 사용법
\```

### Before/After (해당 시)
\```swift
// Before (기존 방식)
\```
\```swift
// After (새 API)
\```

### 플랫폼 지원
| 플랫폼 | 지원 | 최소 버전 |
|--------|------|----------|
| iOS | ✅ | 26.0 |
| macOS | ✅ | 26.0 |

### 관련 API
- `RelatedType` — <관계 설명>
```

## troubleshoot 모드 응답 템플릿

```markdown
## 에러 분석

### 에러
\```
<에러 메시지>
\```

### 원인
<참조 문서 기반 원인 설명> — `references/<doc>.md` 참조

### 수정

**Before:**
\```swift
// 에러가 발생하는 코드
\```

**After:**
\```swift
// 수정된 코드
\```

### 설명
<왜 이 수정이 올바른지 참조 문서에서 근거 인용>
```
