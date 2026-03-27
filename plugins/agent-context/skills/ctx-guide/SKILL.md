---
name: ctx-guide
description: This skill should be used when the user asks about "컨텍스트 아키텍처", "context architecture", "계층적 컨텍스트", "CONTEXT.md 설계", "주의력 예산", "attention budget", "컨텍스트 엔지니어링", "context engineering", "토큰 효율성", "컨텍스트 부패", "context rot", "점진적 노출", "progressive disclosure", or wants guidance on structuring CLAUDE.md, CONTEXT.md, AGENTS.md for large-scale projects. Common requests include "CLAUDE.md가 너무 길어요", "프로젝트 컨텍스트 파일을 어떻게 구성하죠?", "My CLAUDE.md is too long", "Set up context architecture for my project".
version: 1.3.0
---

# Hierarchical Context Architecture Guide

대규모 프로젝트에서 AI 에이전트의 추론 정밀도를 극대화하기 위한 계층적 컨텍스트 아키텍처를 설계한다.

## Quick Start

프로젝트에 컨텍스트 아키텍처를 도입하려면 다음 3단계를 따른다:

1. **초기화**: `/agent-context:init` 실행 — 프로젝트를 분석하여 CLAUDE.md, 서브디렉토리 CLAUDE.md, `.claude/rules/`, AGENTS.md를 자동 생성한다.
2. **검증**: `/agent-context:verify` 실행 — 참조 무결성, 코드 참조, 내용 정확성을 3단계로 검증한다.
3. **유지**: 코드 변경 시 컨텍스트 문서도 함께 업데이트한다. `/agent-context:audit`로 주기적으로 토큰 효율성을 감사한다.

## Core Problem

LLM은 **주의력 예산(Attention Budget)** 제약 하에 작동한다. 토큰이 증가하면 정보 회상 능력이 저하되는 **컨텍스트 부패(Context Rot)** 현상이 발생할 수 있다. 정보를 전략적으로 구조화하여 고신호 토큰만 선별 노출하는 것이 핵심이다.

## Two Fundamental Principles

### 1. 국소성 (Locality)

정보는 그것이 설명하는 코드와 물리적으로 가장 인접하게 배치한다. 이를 **구조적 사일로화(Structural Siloing)**라 한다. 특정 디렉토리의 컨텍스트를 해당 위치에 격리하여 AI가 현재 작업 도메인에만 집중하게 한다.

### 2. 점진적 노출 (Progressive Disclosure)

모든 데이터를 한 번에 주입하지 않고 **적시(JIT) 컨텍스트 전략**을 사용한다. 초기에는 가벼운 식별자(파일 경로, 메타데이터)만 유지하고, 실제 필요 시점에만 상세 컨텍스트를 로드한다.

## Three-Tier File Standard

### CLAUDE.md — Project Root & Subdirectories (Layer 0-2)

프로젝트 루트의 최상위 지속적 컨텍스트. 간결하게 유지하는 것을 권장한다.

- **컴팩션 생존**: 대화 이력 요약 시 디스크에서 다시 읽어 재주입됨 (파일 길이와 무관)
- **계층적 로딩**: Claude Code는 세션 시작 시 루트 CLAUDE.md를 자동 로딩하고, 서브디렉토리의 CLAUDE.md는 해당 디렉토리 파일 접근 시 on-demand 로딩
- **`@` import**: `@path/to/file` 구문으로 외부 파일 참조 가능 (예: `@src/api/API-GUIDE.md`)
- **포함**: 빌드/테스트 명령, 아키텍처 결정, 환경 변수
- **제외**: 빈번히 변경되는 정보, 상세 API 문서, 스타일 가이드

### `.claude/rules/` — Path-Specific Rules (Layer 1-2)

Claude Code 네이티브 기능. glob 패턴으로 특정 경로의 파일 작업 시 자동 적용되는 규칙 파일.

- **자동 로딩**: 파일 경로가 glob 패턴에 매칭되면 해당 규칙이 자동 적용됨
- **예시**: `.claude/rules/api-rules.md` (패턴: `src/api/**`) → API 관련 파일 작업 시 자동 로딩
- CONTEXT.md의 "경로별 컨텍스트" 역할을 네이티브로 대체 가능

### CONTEXT.md — Subsystem Context (수동 참조용)

서브시스템별 상세 도메인 지식을 담은 계층적 지식 트리.

> **주의**: Claude Code는 CONTEXT.md를 **자동 로딩하지 않는다**. 에이전트가 명시적으로 Read하거나, CLAUDE.md에서 `@CONTEXT.md`로 import해야 로딩된다. 자동 로딩이 필요하면 서브디렉토리 CLAUDE.md 또는 `.claude/rules/`를 사용한다.

- **포함**: 도메인 로직의 의도(Why), 서브시스템 고유 패턴, 하위 지식 링크
- **제외**: 린터가 처리 가능한 스타일 규칙, 표준 라이브러리 설명
- **타 도구 호환**: Cursor, Windsurf 등 CONTEXT.md를 인식하는 도구와의 호환성 유지

### AGENTS.md — Universal Portability (타 도구 호환용)

Cursor, Aider, GitHub Copilot 등 다양한 AI 도구가 참조하는 범용 표준.

> **주의**: Claude Code는 AGENTS.md를 **자동 로딩하지 않는다**. CLAUDE.md에서 `@AGENTS.md`로 import하면 내용을 공유할 수 있다.

- **포함**: 범용 에이전트 지침, 마크다운 기반 협업 규칙
- **제외**: 복잡한 메타데이터, 도구 전용 설정값

## Layered Discovery Mechanism

Claude Code는 CLAUDE.md 파일을 계층적으로 탐색한다. 하위의 구체적 지침이 상위의 일반 지침보다 우선한다.

**Claude Code의 실제 자동 로딩 동작:**

```
예: src/api/auth.ts 작업 시

[세션 시작 시 자동 로딩]
Layer 0: /CLAUDE.md              ← 아키텍처 표준, 도구 명령

[해당 파일 접근 시 on-demand 로딩]
Layer 1: /src/CLAUDE.md          ← 소스 폴더 구조, 데이터 흐름
Layer 2: /src/api/CLAUDE.md      ← API 명세, 인증 로직 특이사항

[glob 패턴 매칭 시 자동 로딩]
Rules:  .claude/rules/api.md     ← src/api/** 패턴에 매칭되는 규칙

[항상 접근 가능]
Layer 3: src/api/auth.ts         ← 코드, Diff, 테스트 결과
```

> **참고**: CONTEXT.md와 AGENTS.md는 자동 로딩 대상이 아니다. `@` import 또는 명시적 Read로 접근해야 한다.

## Token Optimization Techniques

### XML 태깅으로 지침 누출 방지

XML 태그를 사용하면 데이터와 지침 사이의 경계가 명확해져 지시 이행 정밀도가 향상된다. 데이터가 지침으로 오인되는 지침 누출(Instruction Leakage) 방지:

```xml
<instructions>
  핵심 가이드라인을 여기에 배치
</instructions>
<data>
  도구 출력물, 로그 등을 여기에 격리
</data>
```

### 프롬프트 캐싱 (Prefix Preservation)

> **참고**: Claude Code CLI는 프롬프트 캐싱을 내부적으로 관리한다. 아래 내용은 Claude API를 직접 사용하는 경우에 해당한다.

정적 지침(CLAUDE.md 등)을 프롬프트 앞부분에 배치하여 캐시 히트를 극대화한다. 동적 질문과 실시간 로그는 뒤에 배치한다.

### 고정된 반복 요약

대화 이력 한계 도달 시 핵심 아키텍처 결정과 미해결 버그 상태를 보존(Anchor)하고 도구 실행 결과를 압축한다.

## Fix the Rules Loop

에이전트 실수 발생 시 코드만 수정하지 말고 해당 오류를 유발한 컨텍스트 문서도 함께 업데이트한다. 컨텍스트는 소스코드와 동일한 컴파일 타임 의존성이다.

**예시**: 에이전트가 CLAUDE.md에 "Zustand 사용"이라 기술된 프로젝트에서 Redux 코드를 작성했다면, 코드 수정 후 CLAUDE.md의 해당 기술도 "Redux → Zustand 마이그레이션 진행 중"으로 업데이트한다. 규칙을 수정하지 않으면 동일한 실수가 반복된다.

## Three-Stage Verification

주기적으로 다음 검증을 실행하여 지식 트리 무결성을 유지한다:

1. **참조 무결성**: 링크된 컨텍스트 파일(CLAUDE.md, CONTEXT.md, `.claude/rules/`)의 실제 존재 여부, `@` import 유효성, 고립 파일 탐지
2. **코드 참조 검증**: 컨텍스트 내 파일 경로가 실제 구현과 일치하는지 확인
3. **내용 정확성**: 기술적 주장이 현재 코드베이스의 실제 패턴과 일치하는지 검증

## Available Skills

이 플러그인은 다음 스킬을 제공한다:

- **`/agent-context:init`** — 새 프로젝트에 컨텍스트 아키텍처를 도입하거나, 기존 프로젝트의 컨텍스트 파일을 보강할 때 사용. 빌드 도구를 자동 감지하여 CLAUDE.md, 서브디렉토리 CLAUDE.md, `.claude/rules/`, AGENTS.md를 생성한다.
- **`/agent-context:verify`** — 컨텍스트 문서가 코드와 동기화되어 있는지 확인할 때 사용. 리팩토링, 파일 이동, 의존성 변경 후에 실행한다. 인자로 stage 번호(1/2/3)를 지정하면 특정 단계만 실행 가능하다.
- **`/agent-context:audit`** — CLAUDE.md가 비대해지거나 계층 구조가 복잡해졌을 때 사용. 간결성 부족, 정보 중복, 커버리지 부족을 감지하고 개선안을 제시한다.

## Additional Resources

### Reference Files

상세 가이드는 다음 참조 파일을 확인한다:

- **`references/file-standards.md`** — CLAUDE.md, CONTEXT.md, AGENTS.md 작성 표준 및 템플릿
- **`references/token-optimization.md`** — XML 태깅, 프롬프트 캐싱, 요약 전략 상세
- **`references/verification-guide.md`** — 3단계 검증 절차 및 자동화 스크립트 가이드
