---
name: ctx-init
description: 프로젝트를 분석하여 CLAUDE.md, 서브디렉토리 CLAUDE.md, .claude/rules/, AGENTS.md로 구성되는 계층적 컨텍스트 아키텍처를 스캐폴딩합니다. 기존 파일이 있으면 보존하고 보강합니다.
argument-hint: "[대상 디렉토리 (생략 시 프로젝트 루트)]"
---

# Context Architecture Init

프로젝트의 계층적 컨텍스트 아키텍처를 초기화한다. 기존 파일이 있으면 보존하고 보강한다.

> **Claude Code 컨텍스트 로딩 원칙**: Claude Code는 CLAUDE.md와 `.claude/rules/`를 자동 로딩한다. 루트 CLAUDE.md는 세션 시작 시, 서브디렉토리 CLAUDE.md는 해당 디렉토리 파일 접근 시 on-demand 로딩되며, `.claude/rules/`는 glob 패턴 매칭 시 자동 적용된다. CONTEXT.md와 AGENTS.md는 자동 로딩되지 않는다.

## Execution Steps

### Step 1: 프로젝트 분석

프로젝트 루트에서 다음을 탐지한다:

1. **빌드 도구 감지** — 다음 파일을 순서대로 탐색:
   - `package.json` → npm/yarn/pnpm scripts 추출
   - `Makefile` → make 타겟 추출
   - `Cargo.toml` → cargo 명령 추출
   - `pyproject.toml` → poetry/pip scripts 추출
   - `build.gradle` / `build.gradle.kts` → gradle 태스크 추출
   - `CMakeLists.txt` → cmake 빌드 명령 추출
   - `*.xcodeproj` / `Package.swift` → xcodebuild/swift 명령 추출
   - `go.mod` → go 명령 추출

2. **디렉토리 구조 분석** — 1~2 depth 수준의 디렉토리 구조를 파악하여 서브시스템 후보를 식별한다. 다음 패턴을 기준으로 판단:
   - `src/`, `lib/`, `app/` — 소스 코드 루트
   - `api/`, `server/`, `routes/` — API/서버 레이어
   - `components/`, `pages/`, `views/` — 프론트엔드 레이어
   - `services/`, `domain/`, `core/` — 비즈니스 로직
   - `tests/`, `__tests__/`, `spec/` — 테스트
   - `infra/`, `deploy/`, `terraform/` — 인프라

3. **기존 컨텍스트 파일 확인** — CLAUDE.md, CONTEXT.md, AGENTS.md가 이미 존재하는지 확인한다.

### Step 2: 사용자 확인

분석 결과를 요약하여 사용자에게 보여준다:

```
## 프로젝트 분석 결과

**빌드 도구**: [감지된 도구]
**주요 서브시스템**: [식별된 서브시스템 목록]
**기존 컨텍스트 파일**: [있음/없음]

### 생성 계획
- [ ] /CLAUDE.md (신규 생성 / 보강)
- [ ] /AGENTS.md (신규 생성 / 보강)
- [ ] 서브시스템 컨텍스트 (CLAUDE.md / .claude/rules/ / CONTEXT.md 중 선택)
...

이 계획으로 진행할까요?
```

사용자 승인 후 다음 단계를 진행한다.

### Step 3: CLAUDE.md 생성/보강

**기존 파일이 없는 경우**: 새로 생성한다.

참조: `guide` 스킬의 `references/file-standards.md`에서 CLAUDE.md 작성 표준을 확인한다.

핵심 규칙:
- 간결하게 유지 (장문이면 `@` import나 서브디렉토리 CLAUDE.md로 분산)
- 빌드/테스트 명령은 Step 1에서 감지한 결과 사용
- 아키텍처 결정은 코드 구조에서 추론
- 한국어로 작성 (주석, 설명)

**기존 파일이 있는 경우**: 기존 내용을 보존하되 다음을 보강한다:
- 누락된 빌드/테스트 명령 추가
- 내용이 길면 `@` import 또는 서브디렉토리 CLAUDE.md로 분산 제안

### Step 4: AGENTS.md 생성/보강

> **참고**: Claude Code는 AGENTS.md를 자동 로딩하지 않는다. Cursor, Aider 등 타 AI 도구와의 호환성을 위해 생성한다. Claude Code에서 사용하려면 CLAUDE.md에 `@AGENTS.md`를 추가한다.

**기존 파일이 없는 경우**: CLAUDE.md의 핵심 내용을 범용 마크다운으로 변환하여 생성한다.

**기존 파일이 있는 경우**: 기존 내용 보존, 누락 섹션만 보강한다.

### Step 5: 서브시스템 컨텍스트 생성

사용자에게 컨텍스트 분산 방식을 선택하도록 안내한다:

**옵션 A: 서브디렉토리 CLAUDE.md (권장 — Claude Code 자동 로딩)**
- 각 서브시스템 디렉토리에 `CLAUDE.md`를 생성
- 해당 디렉토리 파일 접근 시 on-demand 자동 로딩

**옵션 B: `.claude/rules/` (권장 — glob 패턴 기반 자동 적용)**
- `.claude/rules/` 디렉토리에 규칙 파일 생성
- 파일 경로 패턴에 따라 자동 적용

**옵션 C: CONTEXT.md (타 도구 호환용)**
- 각 서브시스템 디렉토리에 `CONTEXT.md`를 생성
- Claude Code에서는 자동 로딩 안 됨 (명시적 Read 또는 `@` import 필요)
- Cursor, Windsurf 등 CONTEXT.md를 인식하는 도구와 호환

공통 내용:
- 해당 디렉토리의 목적과 역할 기술
- Key Files 섹션에 주요 파일 나열
- 고유 패턴이나 주의사항 기술

이미 컨텍스트 파일이 존재하는 디렉토리는 건너뛴다.

### Step 6: 결과 요약

생성/보강된 파일 목록과 다음 단계 안내를 출력한다:

```
## 컨텍스트 아키텍처 초기화 완료

### 생성된 파일
- /CLAUDE.md
- /AGENTS.md
- /src/CLAUDE.md (또는 .claude/rules/src.md)
- /src/api/CLAUDE.md (또는 .claude/rules/api.md)

### 다음 단계
1. 생성된 컨텍스트 파일의 내용을 검토하고 프로젝트 특성에 맞게 수정하세요.
2. `/agent-context:verify`로 검증을 실행하세요.
3. `/agent-context:audit`로 토큰 효율성을 확인하세요.
```
