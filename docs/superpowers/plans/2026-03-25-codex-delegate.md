# Codex Delegate Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Claude Code 안에서 Codex CLI를 호출하여 작업을 위임하고 결과를 처리하는 플러그인 구현

**Architecture:** 단일 스킬(SKILL.md) + 2개 reference 파일 + 3개 헬퍼 스크립트로 구성된 Claude Code 플러그인. 모드 판별은 LLM이 담당하고, 결정적(deterministic) 작업은 셸 스크립트로 분리. 프롬프트 분석 → 모드 판별(LLM) → Codex 실행 → 결과 처리(스크립트)의 흐름.

**Tech Stack:** Claude Code plugin (SKILL.md markdown), Bash (codex CLI 호출, 헬퍼 스크립트), Git (안전장치/diff)

**Spec:** `docs/superpowers/specs/2026-03-25-codex-delegate-design.md`

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `plugins/codex-delegate/.claude-plugin/plugin.json` | 플러그인 매니페스트 |
| Create | `plugins/codex-delegate/skills/codex-delegate/SKILL.md` | 핵심 스킬 로직 |
| Create | `plugins/codex-delegate/skills/codex-delegate/references/mode-detection.md` | 모드 판별 키워드 테이블 |
| Create | `plugins/codex-delegate/skills/codex-delegate/references/output-handling.md` | 결과 처리 전략 |
| Create | `plugins/codex-delegate/scripts/preflight.sh` | codex 설치 + API 키 검증 |
| Create | `plugins/codex-delegate/scripts/process-output.sh` | ANSI 스트립 + 줄 수 측정 + 대용량 저장 |
| Create | `plugins/codex-delegate/scripts/snapshot-diff.sh` | non-git 디렉토리 스냅샷 생성/비교 |
| Create | `plugins/codex-delegate/README.md` | 플러그인 설명 |
| Modify | `README.md` | 마켓플레이스 목록에 추가 |

---

### Task 1: 플러그인 스캐폴딩

**Files:**
- Create: `plugins/codex-delegate/.claude-plugin/plugin.json`
- Create: `plugins/codex-delegate/README.md`

- [ ] **Step 1: 디렉토리 구조 생성**

```bash
mkdir -p plugins/codex-delegate/.claude-plugin
mkdir -p plugins/codex-delegate/skills/codex-delegate/references
mkdir -p plugins/codex-delegate/scripts
```

- [ ] **Step 2: plugin.json 작성**

Create `plugins/codex-delegate/.claude-plugin/plugin.json`:
```json
{
  "name": "codex-delegate",
  "description": "Codex CLI에 작업을 위임하여 코드 생성, 분석, 리팩토링 등을 수행",
  "author": { "name": "oozoofrog" },
  "version": "0.1.0"
}
```

- [ ] **Step 3: README.md 작성**

Create `plugins/codex-delegate/README.md`:
```markdown
# codex-delegate

Claude Code에서 OpenAI Codex CLI에 작업을 위임하는 플러그인입니다.

## 설치

\`\`\`bash
/plugin install codex-delegate@oozoofrog-plugins
\`\`\`

## 사전 요구사항

- Codex CLI: `npm install -g @openai/codex`
- 환경변수: `OPENAI_API_KEY`

## 사용법

슬래시 커맨드:
\`\`\`
/codex-delegate "이 코드 리뷰해줘"
/codex-delegate "테스트 작성해줘"
\`\`\`

자연어:
\`\`\`
codex한테 이 함수 리팩토링해달라고 해줘
codex로 버그 찾아줘
\`\`\`

## 실행 모드

| 모드 | 설명 | 예시 |
|------|------|------|
| read | 분석/리뷰 (읽기 전용) | "이 코드 설명해줘" |
| suggest | 제안 (Claude Code가 적용) | "개선 방법 알려줘" |
| write | 직접 수정 (full-auto) | "테스트 작성해줘" |

모드는 프롬프트 내용에 따라 자동 선택됩니다.
```

- [ ] **Step 4: Commit**

```bash
git add plugins/codex-delegate/
git commit -m "scaffold codex-delegate plugin structure"
```

---

### Task 2: mode-detection.md 레퍼런스 작성

**Files:**
- Create: `plugins/codex-delegate/skills/codex-delegate/references/mode-detection.md`

- [ ] **Step 1: mode-detection.md 작성**

Create `plugins/codex-delegate/skills/codex-delegate/references/mode-detection.md`:
```markdown
# 모드 판별 규칙

## 판별 우선순위

write > suggest > read (기본값)

프롬프트에서 아래 키워드를 순서대로 매칭합니다. 먼저 매칭되는 모드가 선택됩니다.

## write 키워드 (파일 변경 의도)

| 한국어 | 영어 |
|--------|------|
| 작성, 생성, 만들어 | create, write |
| 수정, 변경, 바꿔 | modify, change, update |
| 리팩토링해, 리팩터링해 | refactor |
| 삭제, 제거 | delete, remove |
| 추가, 구현, 고쳐 | add, implement, fix |

**핵심 판별 기준:** 동사가 파일 수정 행위를 직접 지시하는지 여부.
- "리팩토링해줘" → write (직접 행위 지시)
- "리팩토링 방법 알려줘" → suggest (방법 질문)

## suggest 키워드 (제안/조언 요청)

| 한국어 | 영어 |
|--------|------|
| 제안, 개선점, 추천, 대안 | suggest, recommend, alternative |
| 방법, 어떻게, 알려줘 | how to, approach, advice |

## read 키워드 (기본값)

write/suggest 어디에도 매칭되지 않으면 read 모드입니다.

참고 키워드 (확인용):

| 한국어 | 영어 |
|--------|------|
| 분석, 리뷰, 설명 | analyze, review, explain |
| 검색, 찾아, 보여줘, 확인 | search, find, show, check |

## 모호한 경우 예시

| 프롬프트 | 모드 | 이유 |
|----------|------|------|
| "이 코드 리뷰해줘" | read | 리뷰 = 읽기 |
| "버그 찾아줘" | read | 찾아 = 읽기 |
| "리팩토링 방법 알려줘" | suggest | 방법 + 알려줘 |
| "개선점 추천해줘" | suggest | 추천 |
| "리팩토링해줘" | write | 직접 행위 지시 |
| "테스트 작성해줘" | write | 작성 |
| "이 함수 고쳐줘" | write | 고쳐 |
| "이 코드 어떻게 개선할 수 있을까?" | suggest | 어떻게 |
```

- [ ] **Step 2: Commit**

```bash
git add plugins/codex-delegate/skills/codex-delegate/references/mode-detection.md
git commit -m "add mode detection keyword reference for codex-delegate"
```

---

### Task 3: output-handling.md 레퍼런스 작성

**Files:**
- Create: `plugins/codex-delegate/skills/codex-delegate/references/output-handling.md`

- [ ] **Step 1: output-handling.md 작성**

Create `plugins/codex-delegate/skills/codex-delegate/references/output-handling.md` with the following content.

**Note:** The file uses inline code instead of fenced code blocks to avoid markdown nesting issues.

````markdown
# 결과 처리 전략

## ANSI Escape 코드 제거

Codex CLI 출력에서 ANSI escape 시퀀스를 제거합니다:

    codex -q "프롬프트" 2>&1 | sed 's/\x1b\[[0-9;]*m//g'

## 출력 크기별 표시 전략

출력 줄 수는 ANSI 제거 후 측정합니다.

| 크기 | 처리 |
|------|------|
| < 50줄 | 원문 그대로 표시 |
| 50~200줄 | 핵심 내용 요약 + "전체 출력을 보시겠습니까?" 확인 |
| > 200줄 | 요약만 표시 + `/tmp/codex-output-$(date +%s).txt`에 저장 후 경로 안내 |

## 모드별 후처리

### read 모드 (단방향)
1. Codex stdout 표시
2. 종료

### suggest 모드 (양방향)
1. Codex stdout 요약 표시
2. 사용자에게 "이 제안을 적용할까요?" 확인
3. 승인 시: Claude Code가 Edit/Write 도구로 코드에 반영
4. 거부 시: "제안을 적용하지 않았습니다" 안내 후 종료

### write 모드 — git 저장소 (양방향)
1. Codex 실행 전 `git status` 기록
2. Codex 실행 (`--full-auto`)
3. `git diff`로 변경 캡처
4. 변경 파일 수 기준:
   - 1~5개: 변경 요약 표시
   - 6개+: `git diff --stat` 표시 + 상세 리뷰 제안
5. 문제 시 `git checkout .` 롤백 옵션

### write 모드 — non-git 디렉토리 (양방향)
1. 실행 전 스냅샷: `find . -type f -exec stat -f '%m %N' {} \; | sort > /tmp/codex-pre-snapshot.txt`
   (파일 경로 + 수정 시간을 함께 기록하여 변경 감지 가능)
2. Codex 실행
3. 실행 후 동일 명령으로 스냅샷: `/tmp/codex-post-snapshot.txt`
4. `diff /tmp/codex-pre-snapshot.txt /tmp/codex-post-snapshot.txt`로 변경/생성/삭제/수정된 파일 보고
5. 롤백 불가 안내
````

- [ ] **Step 2: Commit**

```bash
git add plugins/codex-delegate/skills/codex-delegate/references/output-handling.md
git commit -m "add output handling reference for codex-delegate"
```

---

### Task 4: 헬퍼 스크립트 작성

**Files:**
- Create: `plugins/codex-delegate/scripts/preflight.sh`
- Create: `plugins/codex-delegate/scripts/process-output.sh`
- Create: `plugins/codex-delegate/scripts/snapshot-diff.sh`

- [ ] **Step 1: preflight.sh 작성**

Create `plugins/codex-delegate/scripts/preflight.sh`:
```bash
#!/bin/bash
# codex-delegate preflight check
# Usage: preflight.sh
# Exit codes: 0=OK, 1=codex not installed, 2=API key missing
# stdout: "ok" on success, error message on failure

if ! command -v codex &>/dev/null; then
    echo "codex CLI가 설치되어 있지 않습니다. npm install -g @openai/codex 로 설치해주세요."
    exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY 환경변수가 설정되어 있지 않습니다."
    exit 2
fi

echo "ok"
exit 0
```

- [ ] **Step 2: process-output.sh 작성**

Create `plugins/codex-delegate/scripts/process-output.sh`:
```bash
#!/bin/bash
# codex-delegate output processor
# Usage: process-output.sh [raw_output_file]
# - Strips ANSI escape codes
# - Counts lines
# - If >200 lines, saves to /tmp and outputs path
# stdout format:
#   Line 1: line_count
#   Line 2: "inline" | "/tmp/codex-output-XXXX.txt"
#   Line 3+: cleaned output (if inline)

INPUT="${1:--}"
CLEANED=$(cat "$INPUT" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed 's/\x1b\([0-9;]*[a-zA-Z]//g')
LINE_COUNT=$(echo "$CLEANED" | wc -l | tr -d ' ')

echo "$LINE_COUNT"

if [ "$LINE_COUNT" -gt 200 ]; then
    OUTFILE="/tmp/codex-output-$(date +%s).txt"
    echo "$CLEANED" > "$OUTFILE"
    echo "$OUTFILE"
else
    echo "inline"
    echo "$CLEANED"
fi
```

- [ ] **Step 3: snapshot-diff.sh 작성**

Create `plugins/codex-delegate/scripts/snapshot-diff.sh`:
```bash
#!/bin/bash
# codex-delegate snapshot diff for non-git directories
# Usage:
#   snapshot-diff.sh pre [directory]   — take pre-execution snapshot
#   snapshot-diff.sh post [directory]  — take post-execution snapshot and diff
# stdout: diff output showing added/removed/modified files

DIR="${2:-.}"
PRE_SNAP="/tmp/codex-snapshot-pre.txt"
POST_SNAP="/tmp/codex-snapshot-post.txt"

take_snapshot() {
    find "$DIR" -type f -not -path '*/\.*' -exec stat -f '%m %N' {} \; 2>/dev/null | sort
}

case "$1" in
    pre)
        take_snapshot > "$PRE_SNAP"
        echo "스냅샷 저장: $(wc -l < "$PRE_SNAP" | tr -d ' ')개 파일"
        ;;
    post)
        take_snapshot > "$POST_SNAP"
        if [ ! -f "$PRE_SNAP" ]; then
            echo "ERROR: pre 스냅샷이 없습니다. 먼저 'snapshot-diff.sh pre'를 실행하세요."
            exit 1
        fi
        # Extract just filenames for add/delete detection
        PRE_FILES=$(awk '{print $2}' "$PRE_SNAP" | sort)
        POST_FILES=$(awk '{print $2}' "$POST_SNAP" | sort)

        ADDED=$(comm -13 <(echo "$PRE_FILES") <(echo "$POST_FILES"))
        DELETED=$(comm -23 <(echo "$PRE_FILES") <(echo "$POST_FILES"))
        # Modified: same file, different mtime
        MODIFIED=$(comm -12 <(echo "$PRE_FILES") <(echo "$POST_FILES") | while read f; do
            pre_mtime=$(grep " ${f}$" "$PRE_SNAP" | awk '{print $1}')
            post_mtime=$(grep " ${f}$" "$POST_SNAP" | awk '{print $1}')
            if [ "$pre_mtime" != "$post_mtime" ]; then
                echo "$f"
            fi
        done)

        [ -n "$ADDED" ] && echo "추가된 파일:" && echo "$ADDED" | sed 's/^/  + /'
        [ -n "$DELETED" ] && echo "삭제된 파일:" && echo "$DELETED" | sed 's/^/  - /'
        [ -n "$MODIFIED" ] && echo "수정된 파일:" && echo "$MODIFIED" | sed 's/^/  ~ /'
        [ -z "$ADDED" ] && [ -z "$DELETED" ] && [ -z "$MODIFIED" ] && echo "변경 없음"

        # Cleanup
        rm -f "$PRE_SNAP" "$POST_SNAP"
        ;;
    *)
        echo "Usage: snapshot-diff.sh [pre|post] [directory]"
        exit 1
        ;;
esac
```

- [ ] **Step 4: 실행 권한 부여**

```bash
chmod +x plugins/codex-delegate/scripts/*.sh
```

- [ ] **Step 5: Commit**

```bash
git add plugins/codex-delegate/scripts/
git commit -m "add helper scripts for codex-delegate: preflight, output processing, snapshot diff"
```

---

### Task 5: SKILL.md 핵심 스킬 작성

**Files:**
- Create: `plugins/codex-delegate/skills/codex-delegate/SKILL.md`

- [ ] **Step 1: SKILL.md frontmatter + examples 작성**

Create `plugins/codex-delegate/skills/codex-delegate/SKILL.md`:

````markdown
---
name: codex-delegate
description: Codex CLI에 작업을 위임합니다. "codex", "codex한테", "codex로", "코덱스", "codex 시켜", "codex에게", "codex delegate" 등 Codex CLI에 작업을 넘기거나 위임하는 요청에 사용하세요.
argument-hint: "[작업 설명]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

<example>
user: "codex한테 이 코드 리뷰해달라고 해줘"
assistant: "read 모드로 Codex CLI에 코드 리뷰를 요청하겠습니다."
</example>

<example>
user: "codex로 테스트 작성해줘"
assistant: "write 모드로 Codex CLI에 테스트 작성을 위임하겠습니다. --full-auto 모드로 실행합니다."
</example>

<example>
user: "codex에게 리팩토링 방법 물어봐"
assistant: "suggest 모드로 Codex CLI에 리팩토링 제안을 요청하겠습니다."
</example>

<example>
user: "/codex-delegate 이 함수의 성능 개선점 분석해줘"
assistant: "read 모드로 Codex CLI에 성능 분석을 요청하겠습니다."
</example>

# Codex Delegate

OpenAI Codex CLI에 작업을 위임하고 결과를 처리합니다.

## 실행 흐름

### 1. 사전 검증

헬퍼 스크립트로 codex 설치 및 API 키를 한 번에 확인합니다:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```
- exit 0: 통과, 다음 단계 진행
- exit 1: codex 미설치 → 스크립트 출력 메시지를 사용자에게 표시 후 종료
- exit 2: API 키 미설정 → 스크립트 출력 메시지를 사용자에게 표시 후 종료

### 2. 프롬프트 준비

**트리거 문구 제거:**
자연어 트리거인 경우 다음 패턴을 프롬프트에서 제거합니다:
`codex(한테|에게|로|가)?\s*(시켜|해줘|해봐|부탁)?`

슬래시 커맨드(`/codex-delegate`)인 경우 인자를 그대로 사용합니다.

**작업 디렉토리 정보 주입:**
Codex 프롬프트 앞에 현재 작업 디렉토리 정보를 주입합니다:
`"Working directory: $(pwd)\n\n" + 사용자 프롬프트`

### 3. 모드 판별

프롬프트를 분석하여 실행 모드를 결정합니다.

| 모드 | Codex 플래그 | 설명 |
|------|-------------|------|
| **read** | `-q` | 분석, 리뷰, 설명 (읽기 전용) |
| **suggest** | `-q` | 제안/조언 요청 (Claude Code가 적용) |
| **write** | `-q --full-auto` | 파일 생성/수정/삭제 (Codex가 직접 수정) |

**판별 우선순위:** write > suggest > read (기본값)

상세 키워드 테이블: `references/mode-detection.md`

### 4. 안전 검증

```
.git 존재 여부 확인 (Bash: test -d .git)
├─ Yes → 제한 없이 실행
└─ No + write 모드 →
    사용자에게 확인 요청:
    "현재 디렉토리는 Git 저장소가 아닙니다.
     Codex가 파일을 직접 수정합니다. 롤백이 불가능할 수 있습니다.
     계속하시겠습니까? (y/N)"
    ├─ y → 실행
    └─ N 또는 무응답 → 취소
└─ No + read/suggest → 그대로 실행
```

### 5. Codex 실행

**read/suggest 모드:**
```bash
codex -q "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 120000 (120초)

**write 모드 (git 저장소):**
```bash
git status --short
codex -q --full-auto "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 600000 (600초)

**write 모드 (non-git):**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" pre .
codex -q --full-auto "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 600000 (600초)

### 6. 결과 처리

모드별 후처리 전략: `references/output-handling.md`

**read 모드:** Codex 출력을 사용자에게 표시하고 종료 (단방향).

**suggest 모드:**
1. Codex 출력을 요약하여 사용자에게 표시
2. "이 제안을 적용할까요?" 확인
3. 승인 시 Claude Code의 Edit/Write 도구로 코드에 반영
4. 거부 시 종료

**write 모드 (git):**
1. `git diff`로 변경 내용 캡처
2. 변경 파일 수에 따라 요약 또는 `git diff --stat` 표시
3. 문제 발견 시 `git checkout .` 롤백 옵션 제공

**write 모드 (non-git):**
1. 실행 후 스냅샷 비교:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" post .
   ```
2. 스크립트가 추가/삭제/수정 파일을 분류하여 출력
3. 롤백 불가 안내

### 7. 출력 표시

| 출력 크기 | 처리 |
|----------|------|
| < 50줄 | 원문 그대로 표시 |
| 50~200줄 | 요약 + 전체 출력 확인 제안 |
| > 200줄 | 요약 + `/tmp/codex-output-$(date +%s).txt` 저장 |

## 에러 처리

| 상황 | 처리 |
|------|------|
| Codex 미설치 | `npm install -g @openai/codex` 안내 |
| API 키 미설정 | `OPENAI_API_KEY` 설정 안내 |
| API 인증 실패 (stderr에 auth/key 에러) | "API 키를 확인해주세요" 안내 |
| 타임아웃 | "Codex 실행이 시간 초과되었습니다" 안내 |
| 비정상 종료 (exit code ≠ 0) | stderr 표시 + 재시도 여부 확인 |
| 빈 출력 | "Codex가 결과를 반환하지 않았습니다" 안내 |
| write 모드 대량 변경 (6개+ 파일) | `git diff --stat` 요약 + 롤백 옵션 |

## 중요 규칙

- **한국어 응답**: 사용자에게 보여주는 메시지는 한국어로, 코드와 기술 용어는 원문 유지
- **Codex 프롬프트는 원문 유지**: 사용자가 입력한 프롬프트 언어 그대로 Codex에 전달
- **quiet 모드 전용**: 인터랙티브 모드 사용 불가 (Bash 도구 제약)

## References

- `references/mode-detection.md` — 모드 판별 키워드 테이블 (LLM이 참조)
- `references/output-handling.md` — 결과 처리 전략

## Scripts

- `${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh` — codex 설치 + API 키 검증
- `${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh` — ANSI 스트립 + 줄 수 측정 + 대용량 저장
- `${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh` — non-git 디렉토리 스냅샷 생성/비교
````

- [ ] **Step 2: Commit**

```bash
git add plugins/codex-delegate/skills/codex-delegate/SKILL.md
git commit -m "add core SKILL.md for codex-delegate plugin"
```

---

### Task 6: 마켓플레이스 README 업데이트

**Files:**
- Modify: `README.md` (프로젝트 루트)

- [ ] **Step 1: README.md 포함 플러그인 테이블에 codex-delegate 추가**

`README.md`의 포함 플러그인 테이블에서 `gpt-research` 행 다음에 새 행을 삽입합니다:

After (기존):
```
| [gpt-research](plugins/gpt-research/) | GPT-PRO 리서치 위임용 구조화된 프롬프트 생성 (module/arch/issue/custom) | `/plugin install gpt-research@oozoofrog-plugins` |
```

Insert:
```markdown
| [codex-delegate](plugins/codex-delegate/) | Codex CLI에 작업 위임 (코드 생성, 분석, 리팩토링) | `/plugin install codex-delegate@oozoofrog-plugins` |
```

- [ ] **Step 2: README.md 디렉토리 트리에 codex-delegate 추가**

플러그인 구조 섹션에서 `gpt-research/` 블록 다음에 추가:
```
│   └── codex-delegate/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── scripts/
│       │   ├── preflight.sh
│       │   ├── process-output.sh
│       │   └── snapshot-diff.sh
│       ├── skills/
│       │   └── codex-delegate/
│       │       ├── SKILL.md
│       │       └── references/
│       │           ├── mode-detection.md
│       │           └── output-handling.md
│       └── README.md
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "add codex-delegate to marketplace README"
```

---

### Task 7: 통합 검증

- [ ] **Step 1: 파일 구조 검증**

```bash
find plugins/codex-delegate -type f | sort
```

Expected output:
```
plugins/codex-delegate/.claude-plugin/plugin.json
plugins/codex-delegate/README.md
plugins/codex-delegate/scripts/preflight.sh
plugins/codex-delegate/scripts/process-output.sh
plugins/codex-delegate/scripts/snapshot-diff.sh
plugins/codex-delegate/skills/codex-delegate/SKILL.md
plugins/codex-delegate/skills/codex-delegate/references/mode-detection.md
plugins/codex-delegate/skills/codex-delegate/references/output-handling.md
```

- [ ] **Step 2: plugin.json JSON 유효성 확인**

```bash
python3 -c "import json; json.load(open('plugins/codex-delegate/.claude-plugin/plugin.json'))"
```

Expected: no output (success)

- [ ] **Step 3: SKILL.md frontmatter 확인**

```bash
head -10 plugins/codex-delegate/skills/codex-delegate/SKILL.md
```

Expected: YAML frontmatter with `name: codex-delegate`

- [ ] **Step 4: 기존 플러그인과 구조 일관성 확인**

```bash
# gpt-research와 구조 비교
diff <(find plugins/gpt-research -type f | sed 's/gpt-research/PLUGIN/g' | sort) \
     <(find plugins/codex-delegate -type f | sed 's/codex-delegate/PLUGIN/g' | sort)
```

Expected: 구조가 유사함을 확인 (완전 동일하지 않아도 됨)

- [ ] **Step 5: Commit (필요한 경우에만)**

모든 검증 통과 후, 수정이 필요했다면 수정된 파일만 개별 지정:
```bash
git add plugins/codex-delegate/ README.md && git commit -m "fix codex-delegate plugin structure issues"
```
