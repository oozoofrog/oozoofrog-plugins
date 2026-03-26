# apple-craft v2: Apple 플랫폼 통합 개발 어시스턴트

**Date**: 2026-03-26
**Status**: Approved
**Branch**: feature/apple-craft-v2

## Problem

apple-craft 스킬의 description이 "Xcode 26 최신 API 개발 가이드 (20개 주제)"로 정의되어 있어, 일반 Swift/Xcode 프로젝트 작업에서 Claude가 스킬 사용을 거부한다. 사용자가 `/apple-craft`를 직접 호출해도 "이 스킬은 Xcode 26 최신 API 전용입니다"라고 안내하는 상황.

## Goal

apple-craft를 **모든 Apple 플랫폼 개발 작업**에서 활성화되는 통합 개발 어시스턴트로 확장한다. Xcode 26 참조 문서 20개는 보너스 지식으로 유지하되, 스킬의 정체성을 "API 가이드"에서 "개발 어시스턴트"로 승격시킨다.

## References

- [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) — V2 간소화 패턴, "every component encodes an assumption"
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — 기능 목록 추적, 브라우저 자동화 테스팅
- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents) — "do the simplest thing", ACI 설계
- [Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Progressive Disclosure, Just-in-Time 로드

## Design Validation

| Anthropic 원칙 | 설계 부합 여부 |
|---|---|
| "Do the simplest thing that works" | 범위를 넓혀서 진입 장벽을 낮추는 것이 더 단순 |
| Progressive Disclosure | 참조 문서를 키워드 매칭 시에만 Just-in-Time 로드 (기존 패턴 유지) |
| "Every component encodes an assumption" | "사용자가 최신 API만 필요하다"는 잘못된 가정 제거 |
| ACI 설계 | description = 활성화 인터페이스, 범용 키워드로 재설계 |

## Architecture: 2계층 구조

### Layer 1: 범용 Apple 개발 어시스턴트 (Primary)

모든 Swift/Xcode 작업을 처리하는 기본 워크플로우.

- 프로젝트 컨텍스트 파악 (Glob/Grep으로 구조 분석)
- Xcode MCP 도구 활용 (빌드, 프리뷰, 문서 검색, 코드 진단)
- 코드 작성/리뷰/리팩토링/디버깅
- Swift 언어, SwiftUI, UIKit, AppKit 등 Apple 프레임워크 전반

### Layer 2: Xcode 26 참조 문서 (Bonus)

사용자 쿼리의 키워드가 Document Routing Table과 매칭될 때만 자동 로드.

- 20개 참조 문서 (Liquid Glass, FoundationModels, Swift 6.2 등)
- 매칭 없으면 참조 문서 없이 일반 지식으로 대응
- 기존 Document Routing Table 및 Reference Loading Strategy 그대로 유지

## Changes

### 1. SKILL.md Description (Frontmatter)

**Before:**
```yaml
description: Xcode 26 최신 API 개발 가이드 (20개 주제). Liquid Glass/리퀴드 글라스/...
```

**After:**
```yaml
description: >
  Apple 플랫폼 통합 개발 어시스턴트 — Swift, SwiftUI, UIKit, AppKit,
  Xcode 빌드/프리뷰/디버깅, 코드 작성/리뷰/리팩토링, Xcode MCP 연동.
  Xcode 26 최신 API 참조 문서 내장 (Liquid Glass, FoundationModels,
  Swift 6.2 등 20개 주제). iOS, macOS, watchOS, visionOS.
  swift, swiftui, uikit, appkit, xcode, 빌드, 프리뷰, 코드 리뷰,
  리팩토링, 아키텍처, 디버깅, SPM, CocoaPods, xcodeproj,
  swift concurrency, combine, swiftdata, coredata, objective-c.
```

### 2. SKILL.md 본문 구조

```
1. Knowledge Authority            ← 유지
2. Mode Selection                  ← 유지, 범위 확장
3. ★ Core Workflow (신규)           ← 모든 모드의 공통 워크플로우
   - Phase 0: 프로젝트 컨텍스트 파악
   - Xcode MCP 도구 활용 전략
   - 참조 문서 자동 로드 조건
4. Document Routing Table          ← 유지 (보너스 지식으로 위치 재정의)
5. Reference Loading Strategy      ← 유지
6. Mode: implement                 ← 확장: 모든 코드 작성
7. Mode: explore                   ← 확장: 모든 API/코드 설명
8. Mode: troubleshoot              ← 확장: 모든 빌드 에러/이슈
9. Mode: harness                   ← 유지 (apple-craft-harness 전환)
10. Rules                          ← 유지 + 일반 규칙 추가
```

### 3. Core Workflow 상세 (신규 섹션)

**Phase 0: 프로젝트 컨텍스트 파악**
1. Glob으로 프로젝트 구조 파악 (`.xcodeproj`, `Package.swift`, `Podfile`, `.swift` 등)
2. 대상 플랫폼 및 최소 배포 타겟 확인
3. 기존 코드 패턴/아키텍처 파악 (MVVM, TCA, Clean Architecture 등)

**Xcode MCP 도구 활용 우선순위**

| 목적 | 도구 | 우선순위 |
|------|------|---------|
| 빠른 코드 진단 | `XcodeRefreshCodeIssuesInFile` | 1순위 |
| 전체 빌드 | `BuildProject` + `GetBuildLog` | 2순위 |
| UI 확인 | `RenderPreview` | UI 작업 시 |
| API 검색 | `DocumentationSearch` | 모르는 API 시 |
| 코드 실행 | `ExecuteSnippet` | 동작 확인 시 |

**참조 문서 자동 로드 조건**
- 사용자 쿼리 키워드 ↔ Document Routing Table 매칭 시 → Read로 참조 문서 로드
- 매칭 없음 → 참조 문서 없이 일반 지식 + Xcode MCP 도구로 대응

### 4. 각 모드 확장

**implement:**
- 기존: 참조 문서 기반 코드 작성
- 확장: 모든 Swift/Xcode 코드 작성. Phase 0 → 코드 작성 → 빌드 검증 → (매칭 시) 참조 문서 활용

**explore:**
- 기존: 참조 문서 기반 API 설명
- 확장: 모든 Apple 프레임워크 API/코드 설명. `DocumentationSearch`로 공식 문서 검색 + (매칭 시) 참조 문서 보충

**troubleshoot:**
- 기존: 참조 문서 관련 에러만
- 확장: 모든 빌드 에러, 런타임 크래시, 코드 이슈. `GetBuildLog`, `XcodeListNavigatorIssues` 활용 + (매칭 시) common-mistakes.md 참조

**harness:**
- 변경 없음. apple-craft-harness 스킬로 전환.

### 5. plugin.json

```json
{
  "name": "apple-craft",
  "description": "Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit 코드 작성·리뷰·디버깅 + Xcode MCP 연동 + Xcode 26 최신 API 참조 문서 20개 내장",
  "version": "1.3.0"
}
```

## Files Changed

| 파일 | 변경 유형 |
|------|----------|
| `skills/apple-craft/SKILL.md` | 재작성 (description + 본문 구조) |
| `.claude-plugin/plugin.json` | 수정 (description + version) |
| `README.md` | 수정 (플러그인 설명 업데이트) |

## Files NOT Changed

| 파일/디렉토리 | 이유 |
|------|------|
| `references/` (20개 문서) | 유지 — 보너스 지식으로 역할만 재정의 |
| `reference/` (code-style, common-mistakes, response-templates) | 유지 |
| `skills/apple-craft-harness/` | 변경 없음 |
| `agents/` (3개 에이전트) | 변경 없음 |
| `scripts/` | 변경 없음 |

## Success Criteria

1. 일반 Swift/Xcode 작업 요청 시 apple-craft 스킬이 **활성화 거부 없이** 동작
2. Xcode 26 API 관련 쿼리 시 기존과 동일하게 참조 문서가 로드됨
3. harness 모드가 기존과 동일하게 apple-craft-harness로 전환됨
4. Xcode MCP 도구가 모든 모드에서 자연스럽게 활용됨
