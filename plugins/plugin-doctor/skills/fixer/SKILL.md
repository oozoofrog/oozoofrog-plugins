---
name: fixer
description: 마켓플레이스 내 모든 플러그인을 Claude Code 공식 표준에 맞게 점검·수정·개선합니다. 자기 자신(plugin-doctor)도 점검 대상에 포함됩니다. "플러그인 점검", "plugin doctor", "플러그인 검증", "plugin validate", "플러그인 수정", "plugin fix", "마켓플레이스 검증", "플러그인 건강 검진" 등의 요청 시 사용하세요.
argument-hint: "[플러그인 이름 (생략 시 전체 점검)] [--update-spec: 공식 문서 최신화]"
---

# Plugin Doctor

마켓플레이스 내 모든 플러그인을 Claude Code 공식 표준에 맞게 진단하고, 자동 수정 가능한 문제는 즉시 수정한다. 자기 자신(plugin-doctor)도 점검 대상에 포함된다.

## 공식 스펙 참조

검증 기준은 `references/official-spec.md`에 정리되어 있다. Stage 0에서 자동 갱신된다.

## 실행 인자

- `$ARGUMENTS` 없음 → 전체 마켓플레이스 점검
- `$ARGUMENTS`에 플러그인 이름 → 해당 플러그인만 점검
- `--update-spec` → Stage 0 강제 실행

## 진단 프로세스

### Stage 0: 공식 스펙 최신화 (Self-Update)

`--update-spec` 인자가 있거나 `references/official-spec.md`의 `Last updated` 날짜가 30일 이상 경과한 경우에만 실행한다.

1. `references/official-spec.md`를 읽어 `Last updated` 날짜를 확인
2. 갱신이 필요하면 WebFetch로 공식 문서 조회:
   - `https://docs.anthropic.com/en/docs/claude-code/plugins`
   - `https://docs.anthropic.com/en/docs/claude-code/skills`
   - `https://docs.anthropic.com/en/docs/claude-code/agents`
   - `https://docs.anthropic.com/en/docs/claude-code/hooks`
3. 새로운 필드, 변경된 규칙, 추가된 이벤트 등을 감지
4. 변경사항이 있으면 `references/official-spec.md`를 업데이트하고 `Last updated` 갱신
5. 변경사항이 없으면 날짜만 갱신

### Stage 1: 마켓플레이스 검증

`.claude-plugin/marketplace.json`을 검증한다.

**검증 항목:**
1. JSON 유효성 파싱
2. 필수 필드 존재: `name`, `owner.name`
3. `version` 필드 SemVer 형식 검증 (정규식: `^\d+\.\d+\.\d+$`)
4. `plugins[]` 배열 내 각 엔트리:
   - `name` 필드 존재 + kebab-case 검증 (정규식: `^[a-z][a-z0-9]*(-[a-z0-9]+)*$`)
   - `source` 필드 존재
   - 상대 경로 source인 경우 `./`로 시작하는지 확인
   - source 경로가 실제 디렉토리로 존재하는지 Glob 확인
5. 중복 플러그인 이름 검출

### Stage 2: plugin.json 검증

각 플러그인의 `.claude-plugin/plugin.json`을 검증한다.

**검증 항목:**
1. 파일 존재 여부 (없으면 Warning)
2. JSON 유효성 파싱
3. `name` 필드: 존재 + kebab-case
4. `version` 필드: 존재 (없으면 Warning) + SemVer 형식
5. `description` 필드: 존재 (없으면 Info)
6. `author` 필드: 존재 (없으면 Info)
7. **버전 동기화**: marketplace.json의 version과 일치하는지 확인 (불일치 시 Critical)
8. 커스텀 경로 (commands, agents, skills, hooks 등)가 설정된 경우 해당 경로 존재 확인

### Stage 3: 스킬 검증

각 플러그인의 `skills/*/SKILL.md`를 검증한다.

**검증 항목:**
1. YAML frontmatter 파싱 유효성
2. `name` 필드: kebab-case, 최대 64자
3. `description` 필드: 존재 여부 (없으면 Warning)
   - 트리거 키워드가 포함되어 있는지 체크 (한국어/영어 혼용 권장)
4. `allowed-tools` 필드:
   - 존재 여부 (없으면 Warning)
   - YAML 리스트 형식인지 확인 (콤마 구분 문자열이면 Warning + 자동 수정 제안)
   - 각 도구 이름 유효성: 기본 도구 (Bash, Read, Write, Edit, Glob, Grep, Agent, WebFetch, WebSearch, NotebookEdit, NotebookRead) 또는 `mcp__*` 패턴
5. `model` 필드: 유효값 (sonnet, haiku, opus, 또는 전체 모델 ID)
6. `effort` 필드: 유효값 (low, medium, high, max)
7. `context` 필드: `fork` 사용 시 `agent` 필드도 설정되었는지 확인
8. **deprecated commands/ 감지**: `commands/` 디렉토리가 존재하면 Critical + skills 승격 가이드 제공

### Stage 4: 에이전트 검증

각 플러그인의 `agents/*.md`를 검증한다.

**검증 항목:**
1. YAML frontmatter 파싱 유효성
2. 필수 필드: `name` (kebab-case), `description`
3. `tools` 필드: 도구 이름 유효성 (Stage 3과 동일 기준)
4. `model` 필드: 유효값 (sonnet, haiku, opus, inherit)
5. `maxTurns` 필드: 양의 정수인지 확인
6. **플러그인 에이전트 제한**: `hooks`, `mcpServers`, `permissionMode` 필드가 있으면 Warning (플러그인 에이전트에서 무시됨)
7. `whenToUse` 필드: `<example>` 태그가 포함되어 있는지 확인 (없으면 Info)
8. `color` 필드: 존재 여부 (없으면 Info)

### Stage 5: 훅 검증

각 플러그인의 `hooks/hooks.json` 또는 `plugin.json` 내 `hooks` 필드를 검증한다.

**검증 항목:**
1. JSON 유효성 파싱
2. 이벤트 이름이 공식 25개 이벤트 중 하나인지 확인:
   `SessionStart, InstructionsLoaded, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, TeammateIdle, Stop, StopFailure, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd`
3. 매처(matcher) 패턴이 유효한 정규식인지 확인
4. 훅 타입: `command`, `http`, `prompt`, `agent` 중 하나인지 확인
5. `command` 타입 훅:
   - 스크립트 파일 경로가 존재하는지 확인
   - 실행 권한(+x)이 있는지 확인
   - `$CLAUDE_PLUGIN_ROOT` 사용이 올바른지 확인
6. `timeout` 필드: 양의 정수인지 확인

### Stage 6: 구조 검증

각 플러그인의 전체 디렉토리 구조를 검증한다.

**검증 항목:**
1. `README.md` 존재 여부 (없으면 Warning)
2. 빈 디렉토리 감지: 내용 없는 `commands/`, `agents/`, `skills/` 등 (Warning)
3. 네이밍 통일: `reference/` vs `references/` 디렉토리가 동일 스킬 내 공존하면 Warning
4. `.claude-plugin/` 디렉토리 내에 `plugin.json` 외 다른 컴포넌트(commands, agents 등)가 있으면 Critical (잘못된 위치)
5. 파일 경로에 `../` 포함 여부 (경로 탈출 감지)

### Stage 7: 자기 진단 (Self-Diagnosis)

plugin-doctor 자체를 Stage 1~6과 동일한 기준으로 검증한다.

**추가 검증:**
1. `references/official-spec.md`가 존재하고 내용이 비어있지 않은지 확인
2. 이 SKILL.md의 frontmatter가 최신 공식 스펙에 맞는지 확인
3. `allowed-tools`에 WebFetch, WebSearch가 포함되어 있는지 확인 (Stage 0 실행에 필요)
4. 검증 로직에서 참조하는 이벤트 목록이 `official-spec.md`와 일치하는지 확인
5. 문제 발견 시 자동 수정 제안 출력

### Stage 8: 자동 수정 & 리포트

모든 진단 결과를 종합하여 리포트를 생성한다.

**심각도 분류:**
- **Critical**: 플러그인 동작에 영향을 줄 수 있는 문제 (예: 필수 필드 누락, 잘못된 경로)
- **Warning**: 공식 표준 미준수이나 동작에는 영향 없음 (예: version 불일치, README 누락)
- **Info**: 개선 권장 사항 (예: description 키워드 부족, color 미설정)

**자동 수정 가능 항목** (사용자 확인 후 실행):
- 빈 deprecated `commands/` 디렉토리 삭제
- 누락된 `version` 필드 추가 (marketplace.json에서 가져옴)
- `allowed-tools` 콤마 구분 문자열 → YAML 리스트 변환
- marketplace.json ↔ plugin.json 버전 동기화
- plugin-doctor 자체 스펙 불일치 수정

**리포트 출력 형식:**

```markdown
# Plugin Doctor Report

## 스펙 상태
- official-spec.md: [날짜] ([갱신 여부])

## 요약
| 플러그인 | Critical | Warning | Info | 상태 |
|----------|----------|---------|------|------|
| plugin-a | 0 | 1 | 2 | 🟡 |
| plugin-b | 1 | 0 | 0 | 🔴 |
| plugin-doctor (self) | 0 | 0 | 0 | 🟢 |

## 상세 진단

### plugin-a
| 심각도 | Stage | 항목 | 현재 상태 | 권장 조치 |
|--------|-------|------|----------|----------|
| ⚠️ | 6 | README.md | 누락 | 생성 필요 |
| ℹ️ | 4 | agent color | 미설정 | color 필드 추가 권장 |

## 자동 수정 제안
다음 항목을 자동 수정할까요?
- [ ] plugin-a/commands/ 빈 디렉토리 삭제
- [ ] plugin-b/.claude-plugin/plugin.json에 version: "1.0.0" 추가

## 수동 조치 필요
1. [Critical] plugin-b: ...
```

사용자가 자동 수정을 승인하면 해당 항목을 즉시 수정한다.

### Stage 9: 적대적 재검증 루프 (Adversarial Re-verification)

> 프로토콜 참조: `references/evaluation-protocol.md`

Stage 8에서 자동 수정을 실행한 후, 수정이 올바르게 적용되었는지 **재검증**한다.

**재검증 범위 결정:**
수정한 항목의 Stage만 재실행한다:
- plugin.json 수정 → Stage 2 재실행
- version 동기화 → Stage 1 + Stage 2 재실행
- SKILL.md 수정 → Stage 3 재실행
- 에이전트 수정 → Stage 4 재실행
- 디렉토리 삭제 → Stage 6 재실행

**루프 제어:**
```
Round 1: Stage 1~8 (최초 진단 + 수정)
Round 2: 수정 항목 관련 Stage만 재검증
  → CLEAN (Critical+Warning=0) → 완료
  → 잔여 findings → 추가 수정 + Round 3
Round 3: 재검증 (최종)
  → CLEAN → 완료
  → 잔여 → "수동 조치 필요" 리포트 출력 후 종료
```

**종료 조건 (하나라도 충족 시):**
1. Critical + Warning findings = 0 → **CLEAN**
2. 이번 라운드 findings ≥ 이전 라운드 → **CONVERGED** (수렴 실패)
3. 라운드 3 완료 → **MAX_ROUNDS**

**최종 리포트에 루프 이력 추가:**
```markdown
## 검증 루프 이력
| 라운드 | findings | 수정 | 잔여 | 판정 |
|--------|----------|------|------|------|
| 1 | 5 | 4 | 1 | CONTINUE |
| 2 | 1 | 1 | 0 | CLEAN |
```
