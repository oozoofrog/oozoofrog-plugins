---
name: hey-codex
description: Codex CLI에 작업을 위임합니다. "codex", "codex한테", "codex로", "코덱스", "codex 시켜", "codex에게", "codex delegate" 등 Codex CLI에 작업을 넘기거나 위임하는 요청에 사용하세요.
argument-hint: "[작업 설명]"
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
user: "/hey-codex 이 함수의 성능 개선점 분석해줘"
assistant: "read 모드로 Codex CLI에 성능 분석을 요청하겠습니다."
</example>

# Hey Codex

OpenAI Codex CLI에 작업을 위임하고 결과를 처리합니다.

## 실행 흐름

### 1. 사전 검증

헬퍼 스크립트로 codex CLI 설치 여부를 확인합니다:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```
- exit 0: 통과, 다음 단계 진행
- exit 1: codex 미설치 → 스크립트 출력 메시지를 사용자에게 표시 후 종료

### 2. 프롬프트 준비

**트리거 문구 제거:**
자연어 트리거인 경우 다음 패턴을 프롬프트에서 제거합니다:
`codex(한테|에게|로|가)?\s*(시켜|해줘|해봐|부탁)?`

슬래시 커맨드(`/hey-codex`)인 경우 인자를 그대로 사용합니다.

**작업 디렉토리 지정:**
Codex CLI의 `--cd` 플래그로 작업 디렉토리를 지정합니다. 프롬프트에 텍스트로 주입하지 않습니다.

### 3. 모드 판별

프롬프트를 분석하여 실행 모드를 결정합니다.

| 모드 | Codex 명령어 | 설명 |
|------|------------|------|
| **read** | `codex exec` | 분석, 리뷰, 설명 (읽기 전용) |
| **review** | `codex review` | 코드 리뷰 전용 (리뷰 키워드 감지 시) |
| **suggest** | `codex exec` | 제안/조언 요청 (Claude Code가 적용) |
| **write** | `codex exec --full-auto` | 파일 생성/수정/삭제 (Codex가 직접 수정) |

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
codex exec --cd "$(pwd)" "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 120000 (120초)

**review 모드 (리뷰 키워드 감지 시):**
```bash
codex review --cd "$(pwd)" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 120000 (120초)

**write 모드 (git 저장소):**
```bash
git status --short
codex exec --full-auto --cd "$(pwd)" "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
bash "${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh" /tmp/codex-raw-output.txt
```
Bash tool timeout: 600000 (600초)

**write 모드 (non-git):**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh" pre .
codex exec --full-auto --skip-git-repo-check --cd "$(pwd)" "프롬프트" 2>&1 > /tmp/codex-raw-output.txt
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
| API 인증 실패 (stderr에 auth/key 에러) | "API 키를 확인해주세요" 안내 |
| 타임아웃 | "Codex 실행이 시간 초과되었습니다" 안내 |
| 비정상 종료 (exit code ≠ 0) | stderr 표시 + 재시도 여부 확인 |
| 빈 출력 | "Codex가 결과를 반환하지 않았습니다" 안내 |
| write 모드 대량 변경 (6개+ 파일) | `git diff --stat` 요약 + 롤백 옵션 |

## 중요 규칙

- **한국어 응답**: 사용자에게 보여주는 메시지는 한국어로, 코드와 기술 용어는 원문 유지
- **Codex 프롬프트는 원문 유지**: 사용자가 입력한 프롬프트 언어 그대로 Codex에 전달
- **exec 모드 전용**: `codex exec` 서브커맨드만 사용 (인터랙티브 모드는 Bash 도구에서 사용 불가)

## References

- `references/mode-detection.md` — 모드 판별 키워드 테이블 (LLM이 참조)
- `references/output-handling.md` — 결과 처리 전략

## Scripts

- `${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh` — codex CLI 설치 확인
- `${CLAUDE_PLUGIN_ROOT}/scripts/process-output.sh` — ANSI 스트립 + 줄 수 측정 + 대용량 저장
- `${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-diff.sh` — non-git 디렉토리 스냅샷 생성/비교
