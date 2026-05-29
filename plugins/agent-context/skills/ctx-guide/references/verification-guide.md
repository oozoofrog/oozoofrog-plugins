# 3-Stage Context Verification Guide

## Overview

To maintain the integrity of the hierarchical context architecture, run 3-stage verification periodically. Each stage can run independently; full verification runs the stages sequentially.

---

## Stage 1: Reference Integrity

### Purpose

Confirm that links between context files (CLAUDE.md, CONTEXT.md, `.claude/rules/`) are valid and that no files are orphaned.

### Checks

1. **Link validity**: Confirm that every `[text](path)` link inside context files points to an actual file
2. **`@` import validity**: Confirm that `@path/to/file` references inside CLAUDE.md point to actual files
3. **Orphan detection**: Detect context files not referenced by any parent file
4. **Circular reference detection**: Check for circular references between context files
5. **CLAUDE.md presence**: Confirm that CLAUDE.md exists at the project root

### Procedure

```
1. 프로젝트 전체에서 컨텍스트 파일 목록 수집 (CLAUDE.md, CONTEXT.md, .claude/rules/*.md)
2. 각 파일에서 마크다운 링크 및 @ import 추출
3. 링크된 파일의 실제 존재 여부 확인
4. 모든 컨텍스트 파일이 최소 하나의 상위 파일에서 참조되는지 확인
5. 링크 그래프에서 순환 탐지
```

### Report Format

```markdown
## 참조 무결성 검증 결과

### 깨진 링크 (Critical)
| 파일 | 링크 | 상태 |
|------|------|------|
| src/CONTEXT.md | ./api/CONTEXT.md | 파일 존재하지 않음 |

### 고립 파일 (Warning)
| 파일 | 설명 |
|------|------|
| src/legacy/CONTEXT.md | 어떤 상위 CONTEXT.md에서도 참조되지 않음 |

### 통계
- 전체 컨텍스트 파일 수: 12
- 유효 링크: 28/30
- 고립 파일: 1
```

---

## Stage 2: Code Reference Validation

### Purpose

Confirm that file paths, directory structures, and class/function names mentioned in context documents match the actual code.

### Checks

1. **File path validity**: Whether mentioned paths such as `handler.ts`, `middleware/` actually exist
2. **Directory structure consistency**: Whether the structure in the Key Files section matches reality
3. **Code identifier validity**: Whether mentioned function names and class names exist in the actual code

### Procedure

```
1. CONTEXT.md/CLAUDE.md에서 코드 블록, 파일 경로 패턴 추출
2. 백틱(`) 내 파일명/경로 추출
3. Key Files 섹션 파싱
4. 각 참조의 실제 존재 여부를 Glob/Grep으로 확인
5. 불일치 항목 리포트 생성
```

### Path Extraction Patterns

Extract code references from context documents using the following patterns:

- Path inside backticks: `` `src/api/handler.ts` ``
- Markdown link: `[handler](./handler.ts)`
- Key Files list: `- handler.ts — description`
- Import inside code block: `import { X } from './module'`

### Report Format

```markdown
## 코드 참조 검증 결과

### 존재하지 않는 참조 (Critical)
| 컨텍스트 파일 | 참조 | 유형 |
|--------------|------|------|
| src/CONTEXT.md | `router.ts` | 파일 삭제됨 |
| CLAUDE.md | `npm run lint:fix` | 스크립트 존재하지 않음 |

### 이동된 참조 (Warning)
| 컨텍스트 파일 | 참조 | 추정 위치 |
|--------------|------|-----------|
| src/api/CONTEXT.md | `utils.ts` | `src/shared/utils.ts`로 이동된 것으로 추정 |
```

---

## Stage 3: Content Accuracy

### Purpose

Verify that the technical claims in context documents match the actual implementation in the current code.

### Checks

1. **Architecture claim verification**: e.g., documented as "uses Redux" but actually Zustand
2. **Pattern claim verification**: e.g., documented as "follows the RORO pattern" but actually a different pattern
3. **Dependency claim verification**: Whether a stated library actually exists in the dependencies
4. **Command claim verification**: Whether build/test commands are actually runnable

### Procedure

```
1. 컨텍스트 문서에서 기술적 주장(claims) 추출
2. 주장 유형별 분류 (아키텍처, 패턴, 의존성, 명령어)
3. 각 주장에 대한 코드베이스 증거 수집
4. 주장과 증거 간의 불일치 탐지
5. 심각도 분류 (Critical: 완전 불일치, Warning: 부분 불일치, Info: 검증 불가)
```

### Automatically Verifiable Items

| Claim Type | Verification Method |
|-----------|-----------|
| Package dependency | Check in package.json, Cargo.toml, etc. |
| Build command | Check package.json scripts, Makefile targets |
| File structure | Compare with actual directory structure |
| Import pattern | Analyze actual import statements in code |

### Items Requiring Manual Verification

| Claim Type | Reason |
|-----------|------|
| Architecture pattern | Pattern interpretation requires judgment |
| Design intent | Intent cannot be determined from code alone |
| Performance characteristics | Benchmark required |

### Report Format

```markdown
## 내용 정확성 검증 결과

### 불일치 (Critical)
| 컨텍스트 파일 | 주장 | 실제 |
|--------------|------|------|
| CLAUDE.md | "Zustand 사용" | package.json에 zustand 없음, redux 발견 |

### 부분 불일치 (Warning)
| 컨텍스트 파일 | 주장 | 비고 |
|--------------|------|------|
| src/CONTEXT.md | "모든 API는 RORO 패턴" | 12/15 엔드포인트만 준수 |

### 검증 불가 (Info)
| 컨텍스트 파일 | 주장 | 이유 |
|--------------|------|------|
| src/api/CONTEXT.md | "P99 지연시간 < 100ms" | 벤치마크 데이터 없음 |
```

---

## Comprehensive Report

After completing all 3 stages of verification, generate a comprehensive report:

```markdown
# 컨텍스트 아키텍처 검증 종합 리포트

## 요약
- **검증 일시**: [YYYY-MM-DD]
- **전체 건전성**: 🟡 양호 (주의 필요)

## 검증 결과 요약
| 단계 | Critical | Warning | Info | 상태 |
|------|----------|---------|------|------|
| 참조 무결성 | 0 | 1 | 0 | 🟢 |
| 코드 참조 | 2 | 1 | 0 | 🔴 |
| 내용 정확성 | 1 | 1 | 2 | 🟡 |

## 우선 조치 항목
1. [Critical] CLAUDE.md의 "Zustand 사용" 주장 수정
2. [Critical] src/CONTEXT.md의 router.ts 참조 업데이트
3. [Warning] src/legacy/CONTEXT.md 고립 파일 정리
```
