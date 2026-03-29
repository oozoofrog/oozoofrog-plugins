---
name: codex-research
description: Codex CLI로 반복 연구 루프를 운영합니다 — 목표 지향 실험을 자동으로 반복하고 결과를 기록합니다. "codex 연구", "codex research", "반복 연구", "연구 루프", "research loop", "자율 연구", "codex로 연구", "깊이 연구", "반복 실험", "autoresearch", "codex 루프", "계속 연구", "overnight research", "연구 상태 확인", "연구 이어줘", "연구 재개", "research status", "resume research" 요청에 사용합니다. 단발 작업 위임은 hey-codex가 더 적합합니다.
argument-hint: "[objective 또는 workspace 경로]"
---

<example>
user: "codex로 이 스킬의 프롬프트 품질을 연구해줘"
assistant: "guided-loop 모드로 연구 루프를 시작하겠습니다. 먼저 .codex-research/ 상태를 확인합니다."
</example>

<example>
user: "codex 연구 루프 설계만 해줘"
assistant: "design 모드로 연구 계약을 작성하겠습니다. objective와 hard gate부터 정합니다."
</example>

<example>
user: "codex로 밤새 성능 개선 연구 돌려줘"
assistant: "autonomous-loop 모드입니다. --loop-forever는 중단 없이 실행됩니다. contract와 stop condition을 확인한 뒤 명령을 발행합니다."
</example>

<example>
user: "연구 상태 확인해줘"
assistant: "status 서브커맨드로 현재 연구 상태를 조회합니다."
</example>

<example>
user: "/codex-research 테스트 커버리지를 자동으로 개선해줘"
assistant: "guided-loop 모드로 테스트 커버리지 개선 연구를 시작합니다. .codex-research/가 없으면 init부터 진행합니다."
</example>

<example>
user: "codex 연구 계속 이어줘"
assistant: "기존 .codex-research/의 contract와 state_snapshot을 읽어 guided-loop를 재개합니다."
</example>

# Codex Research

Codex CLI를 반복 호출하여 **목표 지향 연구 루프**를 운영합니다. karpathy/autoresearch 패턴 기반.

매 라운드마다 Codex가 가설 선택 -> 변경 -> 검증 -> structured JSON 반환을 수행하고, 호스트 스크립트가 3-Layer 판단 -> git 관리 -> ledger 기록을 처리합니다.

## 실행 흐름

### Step 1: 사전 검증

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```
- exit 0: 통과
- exit 1: codex 미설치 -> 설치 안내 후 종료

### Step 2: 모드 판별

사용자 요청을 분석하여 모드를 결정합니다.

| 모드 | 키워드 | Claude 역할 | 스크립트 역할 |
|------|--------|------------|-------------|
| **design** | 설계, 계약, contract, 루프 설계 | 계약 작성 | init만 |
| **guided-loop** (기본) | 연구 시작, 루프 시작, N라운드, 연구해줘 | 스크립트 실행 -> 결과 보고 | run --max-rounds N |
| **autonomous-loop** | 계속 돌려, overnight, 자율, loop-forever | 명령 발행 + 주의사항 | run --loop-forever |

키워드가 불분명하면 **guided-loop**을 기본으로 사용합니다.

### Step 3: 상태 디렉토리 확인

workspace에 `.codex-research/` 디렉토리 존재 여부를 확인합니다.

- **없음** -> `init` 실행 + design 모드 전환 (계약 먼저 작성)
- **있음** -> `contract.md` 읽어서 hard gate/metric 확인 후 진행

### Step 4: 모드별 실행

**design 모드:**
1. 사용자 목표를 한 문장으로 압축
2. `codex-research.sh init` 실행
3. `contract.md`를 사용자와 함께 작성 (references/loop-contract.md 참조)
4. 계약 완성 후 guided-loop 전환 확인

**guided-loop 모드:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --max-rounds N --search --full-auto
```
실행 후 `ledger.tsv` + `state_snapshot.md`를 읽어 결과를 보고합니다.

**autonomous-loop 모드:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --loop-forever --search --full-auto
```
중단 없이 실행됩니다. 반드시 경고를 표시하고, contract의 stop condition과 budget을 재확인한 뒤 명령을 발행합니다.

### Step 5: 결과 보고

라운드 완료 후 다음을 보고합니다:
- 현재 best state와 metric 변화
- 최근 라운드의 hard gate / experiment status / control action
- 남은 budget과 다음 실험 후보
- 종료 시: 최종 delta summary + 남은 리스크

## 3-Layer 판단

hard gate result, experiment status, control action을 **한 칸에 섞어 쓰지 않습니다**.

| 층위 | 값 | 의미 |
|------|-----|------|
| **hard gate result** | pass / fail | 최소 통과선. fail이면 metric 개선과 무관하게 reject |
| **experiment status** | keep / discard / crash | best-known state 대비 이 라운드 결과를 유지할지 |
| **control action** | pass / refine / pivot / rescope / escalate / stop | 루프 전체 제어. 다음 라운드 방향 결정 |

루프 종료: control_action이 pass/stop/rescope/escalate이거나 max_rounds 도달.

## hey-codex와의 경계

| 기준 | hey-codex | codex-research |
|------|-----------|----------------|
| 목적 | 단발 작업 위임 | 반복 연구 루프 |
| 라운드 | 1회 | N회 |
| 상태 유지 | 없음 | program + contract + snapshot + ledger |
| 키워드 | "codex한테 시켜" | "codex로 연구해" |

**라우팅:** "연구/루프/반복/research/loop" 포함 -> codex-research. 없으면 -> hey-codex.

## CLI 사용법

> **주의**: `init`은 workspace 디렉토리가 **미리 존재**해야 합니다. 새 프로젝트라면 먼저 `mkdir -p <workspace>` 후 init하세요.

```bash
# 초기화 (workspace 디렉토리는 미리 존재해야 함)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" init <workspace> "objective"

# 상태 확인
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" status <workspace>

# 연구 실행
bash "${CLAUDE_PLUGIN_ROOT}/scripts/codex-research.sh" run <workspace> --max-rounds N --search --full-auto
```

### run 옵션

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| --max-rounds | 3 | 최대 라운드 수 |
| --loop-forever | false | 무한 실행 (autonomous-loop 전용) |
| --search | false | Codex --search (웹 검색) |
| --full-auto | false | Codex --full-auto |
| --model | - | Codex 모델 지정 |
| --timeout-seconds | 1800 | 라운드당 타임아웃 (초) |
| --no-commit-on-keep | false | keep 시 자동 commit 비활성화 |
| --allow-dirty | false | git dirty tree에서도 실행 허용 |
| --add-dir | - | Codex에 추가 참조 디렉토리 (반복 가능) |

## 상태 디렉토리 (.codex-research/)

```
.codex-research/
├── program.md            # objective + 연구 범위
├── contract.md           # 평가 계약 (loop-contract.md 형식)
├── state_snapshot.md     # baseline, best state, 다음 후보
├── ledger.tsv            # 라운드별 결과 기록
├── runtime/              # Codex 실행 중 임시 파일
└── rounds/
    ├── round-000/
    │   ├── prompt.md
    │   ├── last-message.json
    │   ├── response.json
    │   ├── codex-events.jsonl
    │   └── evidence.md
    └── round-001/...
```

## 규칙

- **Claude 사용 최소화**: design에서만 적극 참여. guided-loop에서는 스크립트 실행 + 결과 보고만. autonomous-loop에서는 경고 + 명령 발행만.
- **한국어 응답**: 사용자에게 보여주는 메시지는 한국어, 코드와 기술 용어는 원문 유지.
- **Codex 프롬프트는 원문 유지**: 사용자 입력 언어 그대로 Codex에 전달.
- **bounded가 기본**: 명시 요청 없으면 기본 3~5 라운드. 무한 루프는 사용자 명시 동의 필수.
- **같은 실패 2회 반복 시** `refine` 대신 `pivot`, `rescope`, `escalate` 우선 검토.
- **Git 관리**: keep -> 자동 commit, discard/crash -> git restore (.codex-research/ 제외).

## References

- `references/loop-contract.md` -- 연구 계약 작성 가이드
