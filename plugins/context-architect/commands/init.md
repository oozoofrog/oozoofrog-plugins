---
name: init
description: 프로젝트를 분석하여 CLAUDE.md, CONTEXT.md, AGENTS.md로 구성되는 계층적 컨텍스트 아키텍처를 스캐폴딩합니다. 기존 파일이 있으면 보존하고 보강합니다.
argument-hint: "[대상 디렉토리 (생략 시 프로젝트 루트)]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

# Context Architecture Init

프로젝트의 계층적 컨텍스트 아키텍처를 초기화한다. 기존 파일이 있으면 보존하고 보강한다.

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
- [ ] /src/CONTEXT.md (신규 생성)
- [ ] /src/api/CONTEXT.md (신규 생성)
...

이 계획으로 진행할까요?
```

사용자 승인 후 다음 단계를 진행한다.

### Step 3: CLAUDE.md 생성/보강

**기존 파일이 없는 경우**: 새로 생성한다.

참조: `context-architecture` 스킬의 `references/file-standards.md`에서 CLAUDE.md 작성 표준을 확인한다.

핵심 규칙:
- **반드시 200라인 이내**
- 빌드/테스트 명령은 Step 1에서 감지한 결과 사용
- 아키텍처 결정은 코드 구조에서 추론
- 한국어로 작성 (주석, 설명)

**기존 파일이 있는 경우**: 기존 내용을 보존하되 다음을 보강한다:
- 누락된 빌드/테스트 명령 추가
- 라인 수가 200을 초과하면 경고하고 분리 대상 제안
- 서브시스템 CONTEXT.md 링크 추가

### Step 4: AGENTS.md 생성/보강

**기존 파일이 없는 경우**: CLAUDE.md의 핵심 내용을 범용 마크다운으로 변환하여 생성한다.

**기존 파일이 있는 경우**: 기존 내용 보존, 누락 섹션만 보강한다.

### Step 5: CONTEXT.md 계층 생성

식별된 각 서브시스템 디렉토리에 CONTEXT.md를 생성한다:
- 해당 디렉토리의 목적과 역할 기술
- Key Files 섹션에 주요 파일 나열
- 상위/하위 CONTEXT.md 링크 포함
- 고유 패턴이나 주의사항 기술

이미 CONTEXT.md가 존재하는 디렉토리는 건너뛴다.

### Step 6: 결과 요약

생성/보강된 파일 목록과 다음 단계 안내를 출력한다:

```
## 컨텍스트 아키텍처 초기화 완료

### 생성된 파일
- /CLAUDE.md (145라인)
- /AGENTS.md (89라인)
- /src/CONTEXT.md
- /src/api/CONTEXT.md
- /src/components/CONTEXT.md

### 다음 단계
1. 각 CONTEXT.md의 내용을 검토하고 프로젝트 특성에 맞게 수정하세요.
2. `/context-architect:verify`로 검증을 실행하세요.
3. `/context-architect:audit`로 토큰 효율성을 확인하세요.
```
