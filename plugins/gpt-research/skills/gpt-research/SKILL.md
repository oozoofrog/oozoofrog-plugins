---
name: gpt-research
description: 프로젝트 컨텍스트를 GPT-PRO 리서치용 구조화된 프롬프트로 추출하여 클립보드에 복사합니다. "GPT에 물어봐", "GPT 리서치", "GPT-PRO", "리서치 위임", "컨텍스트 추출", "gpt research", "GPT에게 넘겨", "GPT한테 질문", "GPT 프롬프트", "research prompt", "컨텍스트 뽑아줘", "GPT용 프롬프트", "외부 리서치", "프롬프트 생성", "GPT 위임" 등 GPT에게 리서치를 위임하거나 프로젝트 맥락을 구조화된 프롬프트로 추출하는 요청에 사용하세요.
argument-hint: "[module|arch|issue|custom] [대상 경로 또는 설명]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

<example>
user: "이 모듈에 대해 GPT에 물어보게 컨텍스트 뽑아줘 src/auth/"
assistant: "module 모드로 src/auth/ 디렉토리의 소스, 의존성, 인터페이스를 추출하여 GPT-PRO 리서치 프롬프트를 생성하겠습니다."
</example>

<example>
user: "프로젝트 아키텍처를 GPT-PRO한테 분석시키고 싶어"
assistant: "arch 모드로 프로젝트 전체 구조, 의존성 그래프, 빌드 시스템을 요약하여 리서치 프롬프트를 클립보드에 복사하겠습니다."
</example>

<example>
user: "이 에러 GPT한테 넘겨서 원인 분석 받자: TypeError: Cannot read properties of undefined"
assistant: "issue 모드로 에러 관련 소스, 콜체인, git 히스토리를 추출하여 GPT-PRO 리서치 프롬프트를 구성하겠습니다."
</example>

<example>
user: "GPT 리서치용 프롬프트 만들어줘, 내가 범위 지정할게"
assistant: "custom 모드로 진행합니다. 어떤 파일이나 주제를 포함할지 알려주세요."
</example>

# GPT-PRO Research Prompt Generator

프로젝트의 특정 부분(모듈, 아키텍처, 이슈)을 GPT-PRO에게 위임할 **구조화된 리서치 프롬프트**로 추출하여 클립보드(`pbcopy`)에 복사합니다.

## 4가지 모드

### 1. `module` — 모듈/파일 분석

특정 모듈이나 파일을 중심으로 맥락을 수집합니다.

**수집 대상:**
- 대상 소스 파일 전체 내용
- 임포트/의존성 파일 (1단계 깊이)
- 프로토콜/인터페이스/타입 정의
- 관련 테스트 파일
- 패키지/모듈 선언 (Package.swift, package.json, Cargo.toml 등)

**탐지 전략:**
1. 대상 경로의 모든 소스 파일 Glob
2. 각 파일에서 임포트 문 파싱 → 의존 파일 Glob
3. 프로토콜/인터페이스 키워드 Grep
4. 테스트 파일 매칭: `*Test*`, `*Spec*`, `*_test*` 패턴

### 2. `arch` — 아키텍처 분석

프로젝트 전체 구조와 설계를 요약합니다.

**수집 대상:**
- 디렉토리 트리 (깊이 3, 제외: node_modules, .git, build, .build, DerivedData, Pods, venv, __pycache__)
- CLAUDE.md, README.md, ARCHITECTURE.md 등 프로젝트 문서
- 의존성 파일 (Package.swift, package.json, Podfile, Cargo.toml, go.mod, requirements.txt 등)
- 빌드 시스템 설정 (Makefile, Tuist, *.xcodeproj 구성 등)
- 핵심 설정 파일 (.env.example, tsconfig.json, .swiftlint.yml 등)

### 3. `issue` — 이슈/에러 분석

에러나 버그의 맥락을 수집합니다.

**수집 대상:**
- 에러 메시지 또는 스택 트레이스에서 언급된 소스 파일
- 에러 문자열 Grep 결과 (파일 + 주변 컨텍스트)
- 콜체인 추적 (호출자/피호출자)
- 관련 테스트 파일
- 최근 git 히스토리 (관련 파일의 최근 10 커밋)
- 환경 정보 (OS, 런타임 버전, 의존성 버전)

### 4. `custom` — 사용자 지정

사용자가 대화형으로 범위를 지정합니다.

**흐름:**
1. 사용자에게 포함할 파일/디렉토리/주제 질문
2. 선택된 범위의 파일 내용 수집
3. 사용자가 리서치 질문 직접 입력
4. 프롬프트 구성 후 클립보드 복사

## 출력 형식

생성되는 프롬프트는 4섹션 구조입니다:

```
# GPT-PRO Research Request

## Role
[모드에 따른 역할 지정]

## Context
[추출된 프로젝트 맥락 — 파일 경로 헤더 + 코드 블록]

## Research Request
[구체적 리서치 질문]

## Expected Output
[기대하는 출력 형식]
```

상세 템플릿은 `references/output-templates.md`를 참조하세요.

## 실행 흐름

```
1. 모드 결정
   ├─ 인자로 지정됨 → 해당 모드
   ├─ 인자 없음 + 에러 메시지 포함 → issue
   ├─ 인자 없음 + 파일/디렉토리 지정 → module
   └─ 인자 없음 + 범위 불명확 → 사용자에게 모드 질문

2. 대상 탐지
   ├─ module: 경로 → Glob → 소스 파일 목록
   ├─ arch: 프로젝트 루트 → 디렉토리 트리 + 핵심 파일
   ├─ issue: 에러 메시지 파싱 → 관련 파일 탐색
   └─ custom: 사용자 입력 대기

3. 컨텍스트 수집
   ├─ 각 모드별 전략에 따라 파일 읽기
   └─ 참조: references/context-extraction-guide.md

4. 크기 검증
   ├─ < 100K 문자: 정상 진행
   ├─ 100K~200K 문자: 경고 표시 + 트리밍 제안
   └─ > 200K 문자: 하드 리밋 → 자동 트리밍 또는 청킹
   └─ 참조: references/size-limits-and-chunking.md

5. 프롬프트 구성
   ├─ 4섹션 구조로 조립
   ├─ 참조: references/output-templates.md
   └─ 참조: references/prompting-best-practices.md

6. 클립보드 복사
   └─ echo "..." | pbcopy

7. 결과 보고
   ├─ 포함된 파일 목록
   ├─ 총 문자 수 / 예상 토큰 수
   ├─ 청킹 여부 (해당 시)
   └─ "클립보드에 복사되었습니다. GPT-PRO에 붙여넣기 하세요."
```

## 크기 관리

| 티어 | 크기 | 처리 |
|------|------|------|
| Small | < 30K 문자 | 그대로 사용 |
| Medium | 30K~100K 문자 | 그대로 사용 |
| Large | 100K~200K 문자 | 경고 + 트리밍 제안 |
| Oversized | > 200K 문자 | 자동 트리밍 또는 청킹 |

**트리밍 우선순위** (높은 것부터 유지):
1. 핵심 소스 코드
2. 인터페이스/프로토콜 정의
3. 에러 로그/스택 트레이스
4. 설정 파일
5. 테스트 코드
6. 문서
7. 의존성 파일

상세 전략은 `references/size-limits-and-chunking.md`를 참조하세요.

## 중요 규칙

- **읽기 전용**: 프로젝트 파일을 수정하지 않습니다. 읽기와 검색만 수행합니다.
- **pbcopy 필수**: 결과는 반드시 `pbcopy`로 클립보드에 복사합니다.
- **한국어 설명**: 프롬프트의 설명 부분은 한국어로, 코드와 기술 용어는 원문 유지합니다.
- **단방향**: 컨텍스트 추출 및 프롬프트 생성까지만 담당합니다. GPT 응답 처리는 범위 밖입니다.

## References

- `references/output-templates.md` — 출력 포맷 템플릿
- `references/context-extraction-guide.md` — 모드별 컨텍스트 추출 전략
- `references/prompting-best-practices.md` — GPT-PRO 프롬프팅 모범 사례
- `references/size-limits-and-chunking.md` — 크기 관리 및 청킹 가이드
