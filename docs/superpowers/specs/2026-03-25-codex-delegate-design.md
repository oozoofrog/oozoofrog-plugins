# Codex Delegate Plugin — Design Spec

## Overview

Claude Code 안에서 OpenAI Codex CLI(`codex`, npm: `@openai/codex`)를 호출하여 작업을 위임하고, 결과를 처리하는 단일 스킬 플러그인.

**Codex CLI 설치:** `npm install -g @openai/codex`
**필수 환경변수:** `OPENAI_API_KEY`

## Plugin Structure

```
plugins/codex-delegate/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── codex-delegate/
│       ├── SKILL.md
│       └── references/
│           ├── mode-detection.md      ← 프롬프트→모드 매핑 규칙 (키워드 테이블)
│           └── output-handling.md     ← 결과 처리 전략
└── README.md
```

### plugin.json

```json
{
  "name": "codex-delegate",
  "description": "Codex CLI에 작업을 위임하여 코드 생성, 분석, 리팩토링 등을 수행",
  "author": { "name": "oozoofrog" },
  "version": "0.1.0"
}
```

## Execution Modes

프롬프트를 분석하여 3가지 모드 중 하나를 자동 선택:

| 모드 | Codex 플래그 | 판별 기준 | 예시 |
|------|-------------|----------|------|
| **read** | `-q` | 분석, 리뷰, 설명, 검색 키워드 | "이 코드 리뷰해줘", "버그 찾아줘" |
| **suggest** | `-q` | 제안, 개선안 요청이지만 직접 수정은 아닌 것 | "리팩토링 방법 알려줘" |
| **write** | `-q --full-auto` | 생성, 수정, 리팩토링, 삭제 등 파일 변경 의도 | "테스트 작성해줘" |

### Mode Detection Keywords

**write 키워드 (우선순위 최고 — 먼저 매칭):**
- 한국어: 작성, 생성, 만들어, 수정, 변경, 리팩토링해, 삭제, 추가, 구현, 고쳐, 바꿔
- 영어: create, write, modify, fix, refactor, delete, add, implement, change, update

**suggest 키워드:**
- 한국어: 제안, 개선점, 방법, 어떻게, 알려줘, 추천, 대안
- 영어: suggest, recommend, how to, alternative, approach, advice

**read 키워드 (기본값 — 위 두 모드에 해당하지 않으면 read):**
- 한국어: 분석, 리뷰, 설명, 검색, 찾아, 보여줘, 확인
- 영어: analyze, review, explain, search, find, show, check

**모호한 경우의 우선순위:** write > suggest > read

예시: "리팩토링 방법 알려줘" → "방법" + "알려줘" = suggest (쓰기 동사 없음)
예시: "리팩토링해줘" → "리팩토링해" = write (쓰기 동사 있음)

### Trigger Phrase Stripping

자연어 트리거 시 트리거 문구를 제거하고 순수 프롬프트만 Codex에 전달:
- "codex한테 이 코드 리뷰해줘" → Codex 프롬프트: "이 코드 리뷰해줘"
- "codex로 테스트 작성해줘" → Codex 프롬프트: "테스트 작성해줘"
- 슬래시 커맨드: `/codex-delegate "프롬프트"` → 인자 그대로 전달

제거 대상 패턴: `codex(한테|에게|로|가)?\s*(시켜|해줘|해봐|부탁)?`

## Safety

```
실행 전:
  ├─ OPENAI_API_KEY 설정 여부 확인
  │   └─ 미설정 → "OPENAI_API_KEY 환경변수를 설정해주세요" 안내 후 종료
  ├─ 현재 디렉토리에 .git 존재?
  │   ├─ Yes → 제한 없이 실행
  │   └─ No + write 모드 →
  │       "현재 디렉토리는 Git 저장소가 아닙니다.
  │        Codex가 파일을 직접 수정합니다. 롤백이 불가능할 수 있습니다.
  │        계속하시겠습니까? (y/N)"
  │       ├─ y → 실행
  │       └─ N 또는 무응답 → 취소
  │   └─ No + read/suggest → 그대로 실행
```

## Execution Flow

```
1. 트리거
   ├─ 슬래시 커맨드: /codex-delegate "프롬프트"
   └─ 자연어: "codex한테 시켜", "codex로 해줘" 등

2. 사전 검증
   ├─ codex CLI 설치 확인 (which codex)
   │   └─ 미설치 → "npm install -g @openai/codex 로 설치해주세요" 안내
   ├─ OPENAI_API_KEY 확인
   ├─ .git 존재 여부 확인
   └─ write 모드 + non-git → 사용자 확인

3. 프롬프트 구성
   ├─ 트리거 문구 제거
   ├─ 현재 작업 디렉토리 정보 주입
   └─ 파일 컨텍스트: 프롬프트에 파일 경로가 포함된 경우
       해당 파일이 존재하면 Codex가 알아서 접근 (같은 cwd)

4. Codex 실행
   ├─ read/suggest: codex -q "프롬프트"
   └─ write:        codex -q --full-auto "프롬프트"
   ├─ 타임아웃: Bash tool timeout 파라미터 사용
   │   ├─ read/suggest: timeout: 120000 (120초)
   │   └─ write: timeout: 600000 (600초)

5. 결과 수신
   └─ stdout + stderr 캡처 (ANSI escape 코드 strip)

6. 결과 처리 (단방향/양방향 분기)
   ├─ 단방향: 결과를 사용자에게 표시하고 종료
   └─ 양방향: Claude Code가 결과를 후처리
```

## One-way vs Two-way Processing

| 조건 | 처리 방식 |
|------|----------|
| `read` 모드 | 단방향 — Codex stdout을 사용자에게 표시 후 종료 |
| `suggest` 모드 | 양방향 — Codex가 텍스트로 출력한 제안을 Claude Code가 읽고, 사용자에게 적용 여부 확인 후 Claude Code의 Edit/Write 도구로 반영 |
| `write` 모드 | 양방향 — Codex가 파일을 직접 수정 → Claude Code가 `git diff` 리뷰 |

### Two-way Post-processing

**suggest 모드:**
Codex는 `-q` 모드에서 텍스트(prose + 코드 블록)를 stdout으로 출력합니다. Codex가 파일을 수정하지 않으므로:
1. Codex stdout을 사용자에게 요약 표시
2. "이 제안을 적용할까요?" 확인
3. 승인 시 **Claude Code가** Edit/Write 도구로 코드에 반영 (Codex 출력을 참고하여)

**write 모드 (git 저장소):**
1. Codex 실행 전 현재 상태 기억 (git status)
2. Codex 실행 (`--full-auto`로 파일 직접 수정)
3. `git diff`로 변경 내용 캡처
4. 변경 파일 수 기준 알림:
   - 1~5개 파일: 변경 요약 표시
   - 6개 이상: `git diff --stat` 표시 + 상세 리뷰 제안
5. 문제 발견 시 사용자에게 `git checkout .` 롤백 옵션 제공

**write 모드 (non-git 디렉토리):**
사용자가 확인 후 실행된 경우:
1. Codex 실행 전 대상 디렉토리의 파일 목록 스냅샷 (`ls -laR`)
2. Codex 실행
3. 실행 후 파일 목록 비교하여 변경/생성/삭제된 파일 보고
4. 롤백 불가 안내 (git이 없으므로)

## Output Display Strategy

출력 크기는 ANSI escape 코드 제거 후 줄 수 기준:

| 출력 크기 | 처리 |
|----------|------|
| < 50줄 | 원문 그대로 표시 |
| 50~200줄 | 요약 + "전체 출력을 보시겠습니까?" |
| > 200줄 | 요약만 표시 + `/tmp/codex-output-{timestamp}.txt` 저장 경로 안내 |

## Error Handling

| 상황 | 처리 |
|------|------|
| `codex` 미설치 | `npm install -g @openai/codex` 안내 후 종료 |
| `OPENAI_API_KEY` 미설정 | 환경변수 설정 안내 후 종료 |
| API 키 인증 실패 (stderr에 auth/key 에러) | "API 키를 확인해주세요" 안내 |
| Codex 실행 타임아웃 | read/suggest: 120초, write: 600초. 초과 시 타임아웃 안내 |
| Codex 비정상 종료 (exit code ≠ 0) | stderr 표시 + 재시도 여부 확인 |
| 빈 출력 | "Codex가 결과를 반환하지 않았습니다" 안내 |
| write 모드 대량 변경 (6개+ 파일) | `git diff --stat` 요약 후 롤백 옵션 제공 |

## Skill Interface

**SKILL.md frontmatter:**
```yaml
name: codex-delegate
description: Codex CLI에 작업을 위임합니다. "codex", "codex한테", "codex로", "코덱스", "codex 시켜", "codex에게", "codex delegate" 등 Codex CLI에 작업을 넘기거나 위임하는 요청에 사용하세요.
argument-hint: "[작업 설명]"
allowed-tools: [Bash, Read, Write, Edit, Glob, Grep]
```

**Natural language triggers:** `codex`, `코덱스`, `codex한테`, `codex로`, `codex에게`, `codex 시켜`, `codex delegate`

## Design Decisions

1. **단일 스킬 구조** — 흐름이 선형적이라 분리 불필요. 필요시 에이전트로 확장 가능.
2. **quiet 모드 전용** — Bash 도구에서 인터랙티브 입력 불가.
3. **Git 기반 안전장치** — Git 저장소 내에서는 자유롭게, 외부에서는 write 시 확인.
4. **자동 모드 판별** — 사용자가 매번 모드를 지정할 필요 없이 프롬프트 분석으로 결정.
5. **suggest 모드에서 Claude Code가 적용** — Codex는 텍스트 제안만 출력, 실제 파일 수정은 Claude Code가 담당. Codex와 Claude Code의 역할이 명확히 분리됨.
6. **non-git write 모드** — ls 스냅샷 비교로 변경 추적, 롤백 불가 사전 경고.
