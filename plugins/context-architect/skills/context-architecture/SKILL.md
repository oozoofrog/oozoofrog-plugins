---
name: Context Architecture
description: This skill should be used when the user asks about "컨텍스트 아키텍처", "context architecture", "계층적 컨텍스트", "CONTEXT.md 설계", "주의력 예산", "attention budget", "컨텍스트 엔지니어링", "context engineering", "토큰 효율성", "컨텍스트 부패", "context rot", "점진적 노출", "progressive disclosure", or wants guidance on structuring CLAUDE.md, CONTEXT.md, AGENTS.md for large-scale projects. Common requests include "CLAUDE.md가 너무 길어요", "프로젝트 컨텍스트 파일을 어떻게 구성하죠?", "My CLAUDE.md is too long", "Set up context architecture for my project".
version: 1.0.0
---

# Hierarchical Context Architecture Guide

대규모 프로젝트에서 AI 에이전트의 추론 정밀도를 극대화하기 위한 계층적 컨텍스트 아키텍처를 설계한다.

## Quick Start

프로젝트에 컨텍스트 아키텍처를 도입하려면 다음 3단계를 따른다:

1. **초기화**: `/context-architect:init` 실행 — 프로젝트를 분석하여 CLAUDE.md(≤200라인), 서브시스템별 CONTEXT.md, AGENTS.md를 자동 생성한다.
2. **검증**: `/context-architect:verify` 실행 — 참조 무결성, 코드 참조, 내용 정확성을 3단계로 검증한다.
3. **유지**: 코드 변경 시 컨텍스트 문서도 함께 업데이트한다. `/context-architect:audit`로 주기적으로 토큰 효율성을 감사한다.

## Core Problem

LLM은 **주의력 예산(Attention Budget)** 제약 하에 작동한다. 토큰 증가 시 O(n²) 연산 복잡도로 인해 정보 회상 능력이 저하되는 **컨텍스트 부패(Context Rot)** 현상이 발생한다. 정보를 전략적으로 구조화하여 고신호 토큰만 선별 노출하는 것이 핵심이다.

## Two Fundamental Principles

### 1. 국소성 (Locality)

정보는 그것이 설명하는 코드와 물리적으로 가장 인접하게 배치한다. 이를 **구조적 사일로화(Structural Siloing)**라 한다. 특정 디렉토리의 컨텍스트를 해당 위치에 격리하여 AI가 현재 작업 도메인에만 집중하게 한다.

### 2. 점진적 노출 (Progressive Disclosure)

모든 데이터를 한 번에 주입하지 않고 **적시(JIT) 컨텍스트 전략**을 사용한다. 초기에는 가벼운 식별자(파일 경로, 메타데이터)만 유지하고, 실제 필요 시점에만 상세 컨텍스트를 로드한다.

## Three-Tier File Standard

### CLAUDE.md — Project Root (Layer 0)

프로젝트 루트의 최상위 지속적 컨텍스트. **반드시 200라인 이내**를 유지한다.

- **컴팩션 생존**: 대화 이력 요약 시 디스크에서 다시 읽어 재주입됨
- **포함**: 빌드/테스트 명령, 아키텍처 결정, 환경 변수
- **제외**: 빈번히 변경되는 정보, 상세 API 문서, 스타일 가이드

### CONTEXT.md — Subsystem (Layer 1-2)

서브시스템별 상세 도메인 지식을 담은 계층적 지식 트리.

- **포함**: 도메인 로직의 의도(Why), 서브시스템 고유 패턴, 하위 지식 링크
- **제외**: 린터가 처리 가능한 스타일 규칙, 표준 라이브러리 설명

### AGENTS.md — Universal Portability (Layer 0)

Cursor, Aider, GitHub Copilot 등 20,000+ 프로젝트가 채택한 범용 표준.

- **포함**: 범용 에이전트 지침, 마크다운 기반 협업 규칙
- **제외**: 복잡한 메타데이터, 도구 전용 설정값

## Layered Discovery Mechanism

에이전트는 작업 대상 파일(Leaf)에서 루트까지 거슬러 올라가며 컨텍스트를 수집한다. 하위의 구체적 지침이 상위의 일반 지침보다 우선한다.

```
예: src/api/auth.ts 작업 시
Layer 0: /CLAUDE.md          ← 아키텍처 표준, 도구 명령
Layer 1: /src/CONTEXT.md     ← 소스 폴더 구조, 데이터 흐름
Layer 2: /src/api/CONTEXT.md ← API 명세, 인증 로직 특이사항
Layer 3: src/api/auth.ts     ← 코드, Diff, 테스트 결과
```

## Token Optimization Techniques

### XML 태깅으로 지침 누출 방지

마크다운보다 XML 태그 사용 시 지시 이행 정밀도 15% 향상. 데이터가 지침으로 오인되는 지침 누출(Instruction Leakage) 방지:

```xml
<instructions>
  핵심 가이드라인을 여기에 배치
</instructions>
<data>
  도구 출력물, 로그 등을 여기에 격리
</data>
```

### 프롬프트 캐싱 (Prefix Preservation)

정적 지침(CLAUDE.md 등)을 프롬프트 앞부분에 배치하여 캐시 히트를 극대화한다. 동적 질문과 실시간 로그는 뒤에 배치한다.

### 고정된 반복 요약

대화 이력 한계 도달 시 핵심 아키텍처 결정과 미해결 버그 상태를 보존(Anchor)하고 도구 실행 결과를 압축한다.

## Fix the Rules Loop

에이전트 실수 발생 시 코드만 수정하지 말고 해당 오류를 유발한 컨텍스트 문서도 함께 업데이트한다. 컨텍스트는 소스코드와 동일한 컴파일 타임 의존성이다.

**예시**: 에이전트가 CLAUDE.md에 "Zustand 사용"이라 기술된 프로젝트에서 Redux 코드를 작성했다면, 코드 수정 후 CLAUDE.md의 해당 기술도 "Redux → Zustand 마이그레이션 진행 중"으로 업데이트한다. 규칙을 수정하지 않으면 동일한 실수가 반복된다.

## Three-Stage Verification

주기적으로 다음 검증을 실행하여 지식 트리 무결성을 유지한다:

1. **참조 무결성**: 링크된 CONTEXT.md 파일의 실제 존재 여부, 고립 파일 탐지
2. **코드 참조 검증**: 컨텍스트 내 파일 경로가 실제 구현과 일치하는지 확인
3. **내용 정확성**: 기술적 주장이 현재 코드베이스의 실제 패턴과 일치하는지 검증

## Available Commands

이 플러그인은 다음 명령을 제공한다:

- **`/context-architect:init`** — 새 프로젝트에 컨텍스트 아키텍처를 도입하거나, 기존 프로젝트의 컨텍스트 파일을 보강할 때 사용. 빌드 도구를 자동 감지하여 CLAUDE.md, CONTEXT.md, AGENTS.md를 생성한다.
- **`/context-architect:verify`** — 컨텍스트 문서가 코드와 동기화되어 있는지 확인할 때 사용. 리팩토링, 파일 이동, 의존성 변경 후에 실행한다. 인자로 stage 번호(1/2/3)를 지정하면 특정 단계만 실행 가능하다.
- **`/context-architect:audit`** — CLAUDE.md가 비대해지거나 계층 구조가 복잡해졌을 때 사용. 라인 수 초과, 정보 중복, 커버리지 부족을 감지하고 개선안을 제시한다.

## Additional Resources

### Reference Files

상세 가이드는 다음 참조 파일을 확인한다:

- **`references/file-standards.md`** — CLAUDE.md, CONTEXT.md, AGENTS.md 작성 표준 및 템플릿
- **`references/token-optimization.md`** — XML 태깅, 프롬프트 캐싱, 요약 전략 상세
- **`references/verification-guide.md`** — 3단계 검증 절차 및 자동화 스크립트 가이드
