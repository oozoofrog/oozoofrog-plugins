# codex-research 스킬 설계

## 개요

hey-codex 플러그인에 `codex-research` 스킬을 추가합니다. Codex CLI를 반복 호출하여 목표 지향 연구 루프를 운영하는 도구입니다. karpathy/autoresearch 패턴에서 영감을 받았으며, 기존 codex-skills-project의 goal-research-loop 스크립트를 oozoofrog-plugins 구조에 맞게 포팅·간소화합니다.

## 핵심 원칙

- **Claude 최소화**: design 모드에서만 Claude가 적극 참여 (계약 설계). guided-loop/autonomous-loop에서는 스크립트 실행 명령만 발행하고 결과를 보고.
- **Codex CLI가 실제 연구 수행**: 매 라운드마다 Codex가 가설 선택 → 변경 → 검증 → structured JSON 반환
- **파일 기반 상태**: program.md, contract.md, state_snapshot.md, ledger.tsv — 세션 간 연속성 보장
- **3-Layer 판단 분리**: hard gate / experiment status / control action

## 아키텍처

```
사용자 → Claude Code (/codex-research)
              │
         ┌────┼────┐
         ▼    ▼    ▼
      design  guided  autonomous
      (Claude) (Script→Claude) (Script only)
              │
         codex-research.sh run
              │
         ┌────────────┐
         │ 라운드 루프  │
         │  Codex CLI  │  ← stdin 프롬프트 + JSON schema
         │  3-layer 판단│  hard gate / experiment / control
         │  git manage  │  keep=commit, discard=restore
         │  ledger 기록 │
         └────────────┘
```

## 파일 구조

```
plugins/hey-codex/
├── .claude-plugin/plugin.json       ← 1.1.1 → 1.2.0
├── skills/
│   ├── hey-codex/SKILL.md           ← 기존 유지
│   └── codex-research/
│       ├── SKILL.md                 ← 새 스킬
│       └── references/
│           └── loop-contract.md     ← 계약 작성 가이드
├── scripts/
│   ├── preflight.sh                 ← 기존 (공유)
│   ├── process-output.sh            ← 기존 (공유)
│   ├── codex-research.sh            ← shell wrapper (init/status/run)
│   └── codex-research.py            ← Python runner (~800줄)
└── templates/
    └── codex-research/
        ├── program.md
        ├── contract.md
        ├── state_snapshot.md
        └── round-result.schema.json
```

## SKILL.md 모드 판별

| 모드 | 키워드 | Claude 역할 | 스크립트 역할 |
|------|--------|------------|-------------|
| design | 설계, 계약, contract, 루프 설계 | 계약 작성 | init만 |
| guided-loop (기본) | 연구 시작, 루프 시작, N라운드, 연구해줘 | 스크립트 실행→결과 보고 | run --max-rounds N |
| autonomous-loop | 계속 돌려, overnight, 자율, loop-forever | 명령 발행+주의사항 | run --loop-forever |

### 기본 흐름 (guided-loop)

1. preflight.sh로 codex 설치 확인
2. workspace에 .codex-research/ 존재 확인
   - 없으면 → init + design 모드 전환 (계약 먼저)
   - 있으면 → contract.md 읽어서 hard gate/metric 확인
3. codex-research.sh run <workspace> --max-rounds N
4. 완료 후 ledger.tsv + state_snapshot.md 읽어서 결과 보고

### design 모드 Claude 작업

1. 사용자 목표를 한 문장으로 압축
2. codex-research.sh init 실행
3. contract.md를 사용자와 함께 작성 (mutable surface, hard gates, metric, budget, stop condition)
4. 계약 완성 후 guided-loop 전환 확인

## CLI 인터페이스

```bash
codex-research.sh init <workspace> "objective"
codex-research.sh status <workspace>
codex-research.sh run <workspace> [options]
```

### run 옵션

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| --max-rounds | 3 | 최대 라운드 수 |
| --loop-forever | false | 무한 실행 (Python 직접 호출만) |
| --search | false | Codex --search (웹 검색) |
| --full-auto | false | Codex --full-auto |
| --model | - | Codex 모델 |
| --sandbox | - | read-only / workspace-write / danger-full-access |
| --add-dir | - | 추가 참조 디렉토리 (반복 가능) |
| --timeout-seconds | 1800 | 라운드당 타임아웃 (초) |
| --allow-dirty | false | git dirty tree 허용 |
| --no-commit-on-keep | false | keep 시 자동 commit 비활성화 |

## Codex 프롬프트 구조

```markdown
# Codex Research Loop — Round {N}

## Objective
{program.md에서 추출}

## Contract
{contract.md 전문}

## Current State
{state_snapshot.md 전문}

## Recent Ledger (최근 8줄)
{ledger.tsv 발췌}

## Rules
1. 가설 하나만 선택하고 실행
2. state_snapshot.md 갱신
3. evidence.md에 근거 기록
4. JSON schema에 맞는 structured result 반환

## Response Schema
{round-result.schema.json}
```

## round-result.schema.json (14개 필드)

```json
{
  "round": 0,
  "objective": "...",
  "hypothesis": "이번 라운드의 가설",
  "change_summary": "변경 요약",
  "hard_gates": { "result": "pass|fail", "details": "..." },
  "metric": "측정값",
  "evidence_summary": "근거 요약",
  "experiment_status": "keep|discard|crash",
  "control_action": "pass|refine|pivot|rescope|escalate|stop",
  "best_state_summary": "현재 best state",
  "next_step": "다음 라운드 계획",
  "notes": "기타",
  "updated_files": ["..."],
  "evidence_files": ["..."]
}
```

## 3-Layer 판단

| 층위 | 값 | 의미 |
|------|-----|------|
| hard gate result | pass / fail | 최소 통과선 |
| experiment status | keep / discard / crash | best-known 대비 |
| control action | pass / refine / pivot / rescope / escalate / stop | 루프 제어 |

루프 종료: control_action이 pass/stop/rescope/escalate이거나 max_rounds 도달.

## 상태 디렉토리 (.codex-research/)

```
.codex-research/
├── program.md
├── contract.md
├── state_snapshot.md
├── ledger.tsv
├── runtime/
└── rounds/
    ├── round-000/
    │   ├── prompt.md
    │   ├── last-message.json
    │   ├── response.json
    │   ├── codex-events.jsonl
    │   └── evidence.md
    └── round-001/...
```

## Git 관리

- keep + commit → 자동 commit (메시지: "codex-research round 001: [hypothesis]")
- keep + no-commit → 루프 중단 (dirty 방지)
- discard / crash → git restore + git clean (.codex-research/ 제외)

## hey-codex와의 경계

| 기준 | hey-codex | codex-research |
|------|-----------|----------------|
| 목적 | 단발 작업 위임 | 반복 연구 루프 |
| 라운드 | 1회 | N회 |
| 상태 유지 | 없음 | program+contract+snapshot+ledger |
| 키워드 | "codex한테 시켜" | "codex로 연구해" |

라우팅: "연구/루프/반복/research/loop" 포함 → codex-research. 없으면 → hey-codex.

## 기존 대비 간소화

| 항목 | goal-research-loop (842줄) | codex-research (~800줄) |
|------|--------------------------|------------------------|
| prompt_profile | standard + lightweight | standard만 |
| references | 10개 | 2개 (SKILL.md + loop-contract.md) |
| --extra-instruction | 있음 | 제거 (contract.md에 통합) |
| --dangerously-bypass | 있음 | 제거 |
| schema 필드 | 18개 | 14개 |
| 상태 디렉토리 | .goal-research-loop/ | .codex-research/ |

## 버전 범프

- hey-codex plugin.json: 1.1.1 → 1.2.0
- marketplace.json: hey-codex 1.1.1 → 1.2.0, root version bump
- CLAUDE.md 플러그인 테이블: `hey-codex | hey-codex, codex-research | — | —`

## 셀프 개선 루프

구현 완료 후 codex-research 스킬로 자체 개선:

1. `codex-research.sh init . "codex-research 스킬의 프롬프트 품질과 라운드 완주율을 개선한다"`
2. contract: hard gate = "codex-research.sh run이 1라운드 이상 완주"
3. `codex-research.sh run . --max-rounds 3 --search --full-auto`
4. 결과 반영 후 최종 커밋

## 성공 기준

1. `codex-research.sh init/status/run` 3개 서브커맨드 정상 동작
2. Codex CLI 반복 호출 + JSON schema 검증 + ledger 기록
3. git keep/discard 자동 관리
4. SKILL.md가 3개 모드(design/guided-loop/autonomous-loop) 올바르게 라우팅
5. 셀프 개선 루프 1회 완주
