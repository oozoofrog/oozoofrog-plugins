---
name: audit
description: 컨텍스트 아키텍처의 토큰 효율성을 감사합니다 — CLAUDE.md 간결성, 계층 구조 깊이, 정보 중복, 컨텍스트 분산 활용도를 분석하여 개선 제안을 제공합니다.
allowed-tools: Read, Glob, Grep, Bash
---

# Context Architecture Audit

컨텍스트 아키텍처의 토큰 효율성을 종합 감사한다. 상세 최적화 기법은 `context-architecture` 스킬의 `references/token-optimization.md`를 참조한다.

## Execution Steps

### Step 1: CLAUDE.md 간결성 감사

1. 프로젝트 루트의 CLAUDE.md를 읽고 정보 밀도를 분석한다
2. 확인 사항:
   - 빈번히 변경되는 정보가 포함되어 있는지
   - 상세 문서가 `@` import, 서브디렉토리 CLAUDE.md, `.claude/rules/`로 적절히 분산되었는지
   - 린터로 자동화 가능한 스타일 규칙이 남아있는지
   - 표준 라이브러리 설명 같은 노이즈가 있는지
3. 내용이 장문이면 분산 방법을 구체적으로 제안한다

출력 예:
```markdown
## CLAUDE.md 간결성 감사

**현재**: 285라인 — 분산 권장

### 분산 권장 섹션
| 섹션 | 라인 수 | 분산 방법 |
|------|---------|-----------|
| API 명세 | 42라인 | → `@src/api/API-GUIDE.md` import 또는 `src/api/CLAUDE.md` |
| 테스트 전략 | 28라인 | → `.claude/rules/testing.md` (glob: `tests/**`) |
| 스타일 가이드 | 15라인 | → 린터 설정으로 대체 (삭제) |
```

### Step 2: 계층 구조 분석

1. 프로젝트 전체에서 컨텍스트 파일을 수집한다:
   - `**/CLAUDE.md` (Claude Code 자동 로딩)
   - `.claude/rules/*.md` (경로별 규칙)
   - `**/CONTEXT.md` (수동 참조용)
   - `/AGENTS.md` (타 도구 호환용)
2. 디렉토리 깊이별로 분류한다:
   - Layer 0: `/CLAUDE.md`, `/AGENTS.md`, `.claude/rules/`
   - Layer 1: `/src/CLAUDE.md` 등 1단계 하위
   - Layer 2: `/src/api/CLAUDE.md` 등 2단계 하위
   - Layer 3+: 더 깊은 계층
3. 판정:
   - ✅ **≤3 레벨**: 최적
   - ⚠️ **4 레벨**: 주의 — 복잡도 증가
   - ❌ **>4 레벨**: 과도 — 병합 검토 필요

출력 예:
```markdown
## 계층 구조 분석

**계층 깊이**: 3 레벨 ✅

| 레이어 | 파일 수 | 파일 목록 |
|--------|---------|-----------|
| Layer 0 | 2 | CLAUDE.md, AGENTS.md |
| Layer 1 | 3 | src/, tests/, docs/ |
| Layer 2 | 5 | src/api/, src/components/, ... |
| Layer 3 | 2 | src/api/auth/, src/api/users/ |
```

### Step 3: 정보 중복 탐지

1. 각 컨텍스트 파일의 주요 키워드/문구를 추출한다
2. 파일 간 중복 내용을 탐지한다:
   - 동일한 빌드 명령이 여러 파일에 있는 경우
   - 동일한 아키텍처 설명이 반복되는 경우
   - 상위 파일과 하위 파일에 같은 내용이 있는 경우
3. 중복 제거 방안을 제안한다

### Step 4: 컨텍스트 커버리지 분석

1. 프로젝트의 주요 디렉토리 목록을 수집한다
2. 각 디렉토리에 컨텍스트 파일(CLAUDE.md, `.claude/rules/` 매칭 규칙, 또는 CONTEXT.md)이 있는지 확인한다
3. 컨텍스트가 없지만 있어야 할 디렉토리를 식별한다:
   - 10개 이상의 소스 파일이 있는 디렉토리
   - 독립적 도메인 로직을 포함하는 디렉토리
4. 불필요하게 컨텍스트 파일이 있는 디렉토리도 식별:
   - 파일이 1~2개뿐인 디렉토리
   - 상위 컨텍스트로 충분한 경우

### Step 5: 종합 감사 리포트

```markdown
# 컨텍스트 아키텍처 토큰 효율성 감사 리포트

## 요약 점수
| 항목 | 점수 | 상태 |
|------|------|------|
| CLAUDE.md 간결성 | 양호 | ✅ |
| 계층 깊이 | 최적 | ✅ |
| 정보 중복 | 2건 발견 | ⚠️ |
| 커버리지 | 80% | 🟡 |

## 전체 효율성 등급: B+ (양호)

## 개선 제안 (우선순위순)
1. CLAUDE.md의 API 명세를 `@` import 또는 `src/api/CLAUDE.md`로 분산
2. CLAUDE.md와 서브디렉토리 CLAUDE.md의 빌드 명령 중복 제거
3. src/services/ 디렉토리에 CLAUDE.md 또는 `.claude/rules/` 규칙 추가 권장
```
