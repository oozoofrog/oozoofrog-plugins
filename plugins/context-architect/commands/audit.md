---
name: audit
description: 컨텍스트 아키텍처의 토큰 효율성을 감사합니다 — CLAUDE.md 라인 수, 계층 구조 깊이, 정보 중복, XML 태깅 활용도를 분석하여 개선 제안을 제공합니다.
allowed-tools: Read, Glob, Grep, Bash
---

# Context Architecture Audit

컨텍스트 아키텍처의 토큰 효율성을 종합 감사한다. 상세 최적화 기법은 `context-architecture` 스킬의 `references/token-optimization.md`를 참조한다.

## Execution Steps

### Step 1: CLAUDE.md 라인 수 감사

1. 프로젝트 루트의 CLAUDE.md를 읽고 라인 수를 계산한다
2. 판정 기준:
   - ✅ **≤150라인**: 최적 — 충분한 여유
   - ⚠️ **151~200라인**: 주의 — 한계에 근접
   - ❌ **>200라인**: 초과 — 즉시 분리 필요
3. 200라인 초과 시, 어떤 섹션을 CONTEXT.md로 분리할 수 있는지 구체적으로 제안한다

출력 예:
```markdown
## CLAUDE.md 라인 수 감사

**현재**: 187라인 ⚠️ (한계 200라인의 93.5%)

### 분리 권장 섹션
| 섹션 | 라인 수 | 분리 대상 |
|------|---------|-----------|
| API 명세 | 42라인 | → src/api/CONTEXT.md |
| 테스트 전략 | 28라인 | → tests/CONTEXT.md |
| 스타일 가이드 | 15라인 | → 린터 설정으로 대체 (삭제) |
```

### Step 2: 계층 구조 분석

1. 프로젝트 전체에서 `**/CONTEXT.md` 파일을 수집한다
2. 디렉토리 깊이별로 분류한다:
   - Layer 0: `/CLAUDE.md`, `/AGENTS.md`
   - Layer 1: `/src/CONTEXT.md` 등 1단계 하위
   - Layer 2: `/src/api/CONTEXT.md` 등 2단계 하위
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
2. 각 디렉토리에 CONTEXT.md가 있는지 확인한다
3. CONTEXT.md가 없지만 있어야 할 디렉토리를 식별한다:
   - 10개 이상의 소스 파일이 있는 디렉토리
   - 독립적 도메인 로직을 포함하는 디렉토리
4. 불필요하게 CONTEXT.md가 있는 디렉토리도 식별:
   - 파일이 1~2개뿐인 디렉토리
   - 상위 CONTEXT.md로 충분한 경우

### Step 5: 종합 감사 리포트

```markdown
# 컨텍스트 아키텍처 토큰 효율성 감사 리포트

## 요약 점수
| 항목 | 점수 | 상태 |
|------|------|------|
| CLAUDE.md 크기 | 93.5% | ⚠️ |
| 계층 깊이 | 최적 | ✅ |
| 정보 중복 | 2건 발견 | ⚠️ |
| 커버리지 | 80% | 🟡 |

## 전체 효율성 등급: B+ (양호)

## 개선 제안 (우선순위순)
1. CLAUDE.md에서 API 명세 42라인을 src/api/CONTEXT.md로 분리
2. CLAUDE.md와 src/CONTEXT.md의 빌드 명령 중복 제거
3. src/services/ 디렉토리에 CONTEXT.md 추가 권장
```
