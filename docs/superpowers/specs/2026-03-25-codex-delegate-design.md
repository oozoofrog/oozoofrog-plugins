# Codex Delegate Plugin — Design Spec

## Overview

Claude Code 안에서 OpenAI Codex CLI를 호출하여 작업을 위임하고, 결과를 처리하는 단일 스킬 플러그인.

## Plugin Structure

```
plugins/codex-delegate/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── codex-delegate/
│       ├── SKILL.md
│       └── references/
│           ├── mode-detection.md      ← 프롬프트→모드 매핑 규칙
│           └── output-handling.md     ← 결과 처리 전략
└── README.md
```

## Execution Modes

프롬프트를 분석하여 3가지 모드 중 하나를 자동 선택:

| 모드 | Codex 플래그 | 판별 기준 | 예시 |
|------|-------------|----------|------|
| **read** | `-q` | 분석, 리뷰, 설명, 검색 키워드 | "이 코드 리뷰해줘", "버그 찾아줘" |
| **suggest** | `-q` | 제안, 개선안 요청이지만 직접 수정은 아닌 것 | "리팩토링 방법 알려줘" |
| **write** | `-q --full-auto` | 생성, 수정, 리팩토링, 삭제 등 파일 변경 의도 | "테스트 작성해줘" |

### Mode Detection Flow

1. 프롬프트에서 동사/키워드 추출
2. 쓰기 의도 키워드 매칭 → `write`
3. 제안 의도 키워드 매칭 → `suggest`
4. 그 외 → `read` (안전한 기본값)

상세 키워드 목록은 `references/mode-detection.md`에 정의.

## Safety

```
실행 전:
  ├─ 현재 디렉토리에 .git 존재?
  │   ├─ Yes → 제한 없이 실행
  │   └─ No → write 모드일 경우 사용자 확인 요청
  │           read/suggest는 그대로 실행
```

## Execution Flow

```
1. 트리거
   ├─ 슬래시 커맨드: /codex-delegate "프롬프트"
   └─ 자연어: "codex한테 시켜", "codex로 해줘" 등

2. 사전 검증
   ├─ codex CLI 설치 확인 (which codex)
   ├─ .git 존재 여부 확인
   └─ write 모드 + non-git → 사용자 확인

3. 프롬프트 구성
   ├─ 사용자 원문 프롬프트
   ├─ 현재 작업 디렉토리 정보 주입
   └─ 필요시 파일 컨텍스트 추가 (사용자가 파일을 언급한 경우)

4. Codex 실행
   ├─ read/suggest: codex -q "프롬프트"
   └─ write:        codex -q --full-auto "프롬프트"

5. 결과 수신
   └─ stdout + stderr 캡처

6. 결과 처리 (단방향/양방향 분기)
   ├─ 단방향: 결과를 사용자에게 표시하고 종료
   └─ 양방향: Claude Code가 결과를 후처리
```

## One-way vs Two-way Processing

| 조건 | 처리 방식 |
|------|----------|
| `read` 모드 | 단방향 — 결과 표시 후 종료 |
| `suggest` 모드 | 양방향 — Codex 제안을 Claude Code가 검토 후 적용 여부 판단 |
| `write` 모드 | 양방향 — Codex가 변경한 파일의 diff를 Claude Code가 리뷰 |

### Two-way Post-processing

**suggest 모드:**
- Codex의 제안을 파싱하여 요약
- 사용자에게 "이 제안을 적용할까요?" 확인
- 승인 시 Claude Code가 코드에 반영

**write 모드:**
- `git diff`로 Codex가 변경한 내용 캡처
- 변경 사항 요약 제시
- 문제 발견 시 사용자에게 알림 (예: 의도하지 않은 파일 삭제)

## Output Display Strategy

| 출력 크기 | 처리 |
|----------|------|
| < 50줄 | 원문 그대로 표시 |
| 50~200줄 | 요약 + "전체 출력을 보시겠습니까?" |
| > 200줄 | 요약만 표시 + 임시 파일 저장 경로 안내 |

## Error Handling

| 상황 | 처리 |
|------|------|
| `codex` 미설치 | 설치 안내 메시지 출력 후 종료 |
| Codex 실행 타임아웃 | 2분 기본, 대규모 작업은 10분까지 허용 |
| Codex 비정상 종료 (exit code ≠ 0) | stderr 표시 + 재시도 여부 확인 |
| 빈 출력 | "Codex가 결과를 반환하지 않았습니다" 안내 |
| write 모드에서 의도치 않은 대량 변경 | `git diff --stat` 요약 후 `git checkout .` 롤백 옵션 제공 |

## Skill Interface

**SKILL.md frontmatter:**
```yaml
name: codex-delegate
description: Codex CLI에 작업을 위임합니다. "codex", "codex한테", "codex로", "코덱스" 등
argument-hint: "[작업 설명]"
allowed-tools: [Bash, Read, Glob, Grep]
```

**Natural language triggers:** `codex`, `코덱스`, `codex한테`, `codex로`, `codex에게`, `codex 시켜`, `codex delegate`

## Design Decisions

1. **단일 스킬 구조** — 흐름이 선형적이라 분리 불필요. 필요시 에이전트로 확장 가능.
2. **quiet 모드 전용** — Bash 도구에서 인터랙티브 입력 불가.
3. **Git 기반 안전장치** — Git 저장소 내에서는 자유롭게, 외부에서는 write 시 확인.
4. **자동 모드 판별** — 사용자가 매번 모드를 지정할 필요 없이 프롬프트 분석으로 결정.
