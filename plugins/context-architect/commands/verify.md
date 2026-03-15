---
name: verify
description: 계층적 컨텍스트 아키텍처의 3단계 검증을 실행합니다 — 참조 무결성, 코드 참조 유효성, 내용 정확성을 순차적으로 검사하여 리포트를 생성합니다.
argument-hint: "[stage 번호: 1|2|3|all (기본: all)]"
allowed-tools: Read, Glob, Grep, Bash
---

# Context Architecture Verify

계층적 컨텍스트 아키텍처의 3단계 검증을 수행한다. 상세 검증 절차는 `context-architecture` 스킬의 `references/verification-guide.md`를 참조한다.

## Execution Steps

### Step 0: 컨텍스트 파일 수집

프로젝트 전체에서 다음 파일을 수집한다:
- `CLAUDE.md` (프로젝트 루트)
- `AGENTS.md` (프로젝트 루트)
- `**/CONTEXT.md` (전체 디렉토리)

파일이 하나도 없으면 "컨텍스트 아키텍처가 아직 초기화되지 않았습니다. `/context-architect:init`을 먼저 실행하세요."를 출력하고 종료한다.

인자로 stage 번호가 지정된 경우 해당 단계만 실행한다. 기본값은 `all` (전체 실행).

### Stage 1: 참조 무결성 (Reference Integrity)

1. 모든 CONTEXT.md에서 마크다운 링크 `[텍스트](경로)` 추출
2. 각 링크의 대상 파일 존재 여부 확인 (Glob 사용)
3. 모든 CONTEXT.md가 최소 하나의 상위 파일에서 참조되는지 확인
4. CLAUDE.md 존재 여부 확인
5. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 1: 참조 무결성 ✅/❌

| 상태 | 파일 | 항목 | 설명 |
|------|------|------|------|
| ❌ | src/CONTEXT.md | ./old/CONTEXT.md 링크 | 파일 존재하지 않음 |
| ⚠️ | tests/CONTEXT.md | (고립) | 상위에서 참조 없음 |
| ✅ | 전체 | 순환 참조 | 없음 |
```

### Stage 2: 코드 참조 검증 (Code Reference Validation)

1. CLAUDE.md와 모든 CONTEXT.md에서 코드 참조 추출:
   - 백틱 내 파일 경로: `` `src/handler.ts` ``
   - Key Files 리스트 항목
   - 코드 블록 내 import/require 구문
2. 각 참조가 실제 파일시스템에 존재하는지 Glob으로 확인
3. 존재하지 않는 참조에 대해 유사 파일명 탐색 (이동 추정)
4. CLAUDE.md의 빌드/테스트 명령이 유효한지 확인 (package.json scripts 등과 대조)
5. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 2: 코드 참조 검증 ✅/❌

| 상태 | 컨텍스트 파일 | 참조 | 비고 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | `npm run lint:fix` | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | `utils.ts` | src/shared/utils.ts로 이동 추정 |
| ✅ | src/api/CONTEXT.md | `handler.ts` | 존재 확인 |
```

### Stage 3: 내용 정확성 (Content Accuracy)

1. 컨텍스트 문서에서 기술적 주장(claims) 추출:
   - "X 라이브러리 사용" → package.json/Cargo.toml 등에서 검증
   - "Y 패턴 준수" → 코드 구조에서 검증 시도
   - "Z 명령으로 빌드" → 실제 실행 가능성 확인
2. 자동 검증 가능한 항목만 검증 수행
3. 수동 검증 필요 항목은 Info로 분류
4. 결과를 마크다운 테이블로 출력:

```markdown
## Stage 3: 내용 정확성 ✅/❌

| 상태 | 컨텍스트 파일 | 주장 | 실제 |
|------|--------------|------|------|
| ❌ | CLAUDE.md | "Zustand 사용" | package.json에 없음 |
| ⚠️ | src/CONTEXT.md | "RORO 패턴 준수" | 12/15 엔드포인트만 준수 |
| ℹ️ | src/api/CONTEXT.md | "P99 < 100ms" | 자동 검증 불가 |
```

### Final: 종합 리포트

```markdown
# 컨텍스트 아키텍처 검증 종합 리포트

## 요약
| 단계 | Critical | Warning | Info | 상태 |
|------|----------|---------|------|------|
| 참조 무결성 | 0 | 1 | 0 | 🟢 |
| 코드 참조 | 2 | 1 | 0 | 🔴 |
| 내용 정확성 | 1 | 1 | 2 | 🟡 |

## 전체 건전성: 🟡 양호 (주의 필요)

## 우선 조치 항목
1. [Critical] ...
2. [Critical] ...
3. [Warning] ...
```
