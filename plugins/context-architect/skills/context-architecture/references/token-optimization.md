# 토큰 효율성 최적화 상세 가이드

## XML 구조적 태깅

### 왜 XML인가?

마크다운은 구조적 경계가 모호하여, 대규모 데이터를 포함할 때 LLM이 데이터를 지침으로 오인하는 **지침 누출(Instruction Leakage)** 현상이 발생한다. XML 태그는 명확한 경계를 제공하여 지시 이행 정밀도를 향상시킨다.

### 태깅 패턴

#### 패턴 1: 지침과 데이터 분리

```xml
<instructions>
  ## 핵심 규칙
  - 모든 API 엔드포인트는 RORO(Receive an Object, Return an Object) 패턴 준수
  - 에러 응답은 RFC 7807 (Problem Details) 형식
  - 인증 미들웨어를 모든 라우트에 적용
</instructions>

<data>
  [BUILD_LOG]
  src/api/handler.ts:45 - TypeError: Cannot read property 'id' of undefined
  src/api/handler.ts:78 - Warning: Unused variable 'tempResult'

  [TEST_RESULTS]
  Tests: 142 passed, 3 failed
  Failed: auth.test.ts, user.test.ts, api.test.ts
</data>
```

#### 패턴 2: 컨텍스트 메타데이터 격리

```xml
<context>
  현재 작업 경로: src/api/
  참조 컨텍스트: ../../CONTEXT.md
  최근 변경: auth.ts (3시간 전), middleware.ts (1일 전)
  관련 이슈: #142 (인증 토큰 갱신 로직 버그)
</context>

<instructions>
  위 컨텍스트를 참고하여 인증 토큰 갱신 로직을 수정한다.
  기존 세션 관리 방식은 유지하되, 토큰 만료 시 자동 갱신을 추가한다.
</instructions>
```

#### 패턴 3: 다중 소스 데이터 구분

```xml
<source name="current_code">
  // auth.ts 현재 구현
  export function validateToken(token: string) { ... }
</source>

<source name="test_output">
  FAIL src/auth.test.ts
  ✕ should refresh expired token (45ms)
</source>

<instructions>
  current_code의 validateToken 함수를 수정하여
  test_output의 실패 테스트를 통과시킨다.
</instructions>
```

---

## 프롬프트 캐싱 전략

> **참고**: 이 섹션은 Claude API를 직접 사용하는 경우에 해당한다. Claude Code CLI는 프롬프트 캐싱을 내부적으로 관리하므로 사용자가 직접 제어할 수 없다.

### Prefix Preservation 원칙

LLM API의 프롬프트 캐싱은 **접두사(Prefix)** 기반으로 작동한다. 동일한 접두사를 가진 요청은 캐시를 재사용할 수 있다.

```
[캐시 가능 영역 - 변경 없음]
├── System Prompt
├── CLAUDE.md 내용
└── 정적 지침

[캐시 불가 영역 - 매번 변경]
├── 사용자 질문
├── 실시간 로그
└── 도구 실행 결과
```

### 실무 적용 (API 사용 시)

1. **정적 지침을 프롬프트 앞부분에 배치** — 최대 캐시 재사용
2. **컨텍스트 파일은 관련 작업 시에만 로드** — 불필요한 캐시 무효화 방지
3. **동적 데이터는 항상 마지막에 배치** — 캐시 히트율 극대화

---

## 고정된 반복 요약 (Anchored Iterative Summarization)

### 보존 대상 (Anchor)

컴팩션 시 반드시 보존해야 할 정보:

- 아키텍처 결정 사항 및 그 이유
- 미해결 버그/이슈 상태
- 현재 작업의 목표와 제약 조건
- 합의된 구현 방향

### 압축 대상

안전하게 압축 가능한 정보:

- 도구 실행의 전체 출력 → 핵심 결과만 보존
- 탐색적 코드 읽기 결과 → 발견된 패턴만 보존
- 디버깅 과정의 시행착오 → 최종 원인과 해결책만 보존

### CLAUDE.md의 컴팩션 생존

CLAUDE.md는 고유한 특성을 가진다:

1. 컨텍스트 윈도우가 가득 차면 대화 이력이 요약됨
2. 이때 에이전트는 CLAUDE.md를 디스크에서 다시 읽음
3. 신선한 상태로 컨텍스트에 재주입
4. 이 생존은 **파일 길이와 무관**하게 작동함 — 간결하게 유지하는 것은 정보 밀도와 준수율을 위함

> **참고**: Claude Code의 Auto Memory 시스템(v2.1.59+)도 세션 간 빌드 명령, 디버깅 패턴, 아키텍처 결정 등을 자동 기록한다. CLAUDE.md와 Auto Memory는 상호보완적이다.

---

## 토큰 효율성 감사 체크리스트

### CLAUDE.md 감사

- [ ] 간결하고 높은 정보 밀도를 유지하는가?
- [ ] 빈번히 변경되는 정보가 포함되어 있지 않은가?
- [ ] 상세 문서는 `@` import, 서브디렉토리 CLAUDE.md, 또는 `.claude/rules/`로 분산했는가?
- [ ] 린터로 자동화 가능한 스타일 규칙이 제거되었는가?

### 서브디렉토리 CLAUDE.md / `.claude/rules/` 감사

- [ ] Why(의도)에 집중하고 있는가? (What은 코드가 설명)
- [ ] 상위/하위 파일 간 링크가 유효한가?
- [ ] 표준 라이브러리 설명 같은 노이즈가 없는가?

### CONTEXT.md 감사 (사용하는 경우)

- [ ] Claude Code 사용자에게 자동 로딩 안 됨을 인지했는가?
- [ ] CLAUDE.md에서 `@` import 또는 타 도구 호환용으로 명확히 구분했는가?

### 전체 계층 감사

- [ ] 고립된(Orphaned) 컨텍스트 파일이 없는가?
- [ ] 깊이가 4레벨을 초과하지 않는가? (Layer 0~3 권장)
- [ ] 중복된 정보가 여러 파일에 걸쳐 있지 않은가?
