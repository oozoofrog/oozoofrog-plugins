# Experiment Log

이 문서는 라우팅 개선 실험의 변경점과 결과를 순차적으로 기록합니다.

## 기록 템플릿

```markdown
## YYYY-MM-DD / Batch 이름

- 대상 스킬:
- 가설:
- 수정 파일:
- 수정 요약:
- 사용 코퍼스:
- 결과 요약:
- 관찰:
- 다음 액션:
```

## Planned Batches

### Batch 1 — apple-craft family boundary 정리

- 대상 스킬:
  - `plugins/apple-craft/skills/apple-craft/SKILL.md`
  - `plugins/apple-craft/skills/apple-harness/SKILL.md`
  - `plugins/apple-craft/skills/apple-review/SKILL.md`
- 목표:
  - 개발 / 리뷰 / 대규모 구현 경계 선명화
- 초안:
  - `batches/01-apple-family.md`
- 측정 템플릿:
  - `batches/01-apple-family-baseline-template.md`
- 실행 파일:
  - `batches/01-apple-family-baseline-2026-03-29.md`
  - `batches/01-apple-family-postpatch-2026-03-29.md`
- 현재 상태: **PATCHED** — 측정 대기
- 설계 노트:
  - apple-craft Mode Selection 테이블의 review/harness 행은 **의도적 handoff 메커니즘**으로 유지 (review example은 제거, 키워드 라우팅 행은 보존)
  - apple-review description에 `코드 리뷰`, `확인해`, `체크`, `살펴` 복원하여 직접 활성화 recall 확보

### Batch 2 — agent-context family action verb 정리

- 대상 스킬:
  - `plugins/agent-context/skills/ctx-guide/SKILL.md`
  - `plugins/agent-context/skills/ctx-init/SKILL.md`
  - `plugins/agent-context/skills/ctx-verify/SKILL.md`
  - `plugins/agent-context/skills/ctx-audit/SKILL.md`
- 목표:
  - guide / init / verify / audit 구분 강화

### Batch 3 — delegation pair wording 정리

- 대상 스킬:
  - `plugins/gpt-research/skills/gpt-research/SKILL.md`
  - `plugins/hey-codex/skills/hey-codex/SKILL.md`
- 목표:
  - “외부 모델에 넘기기” vs “Codex에 실제 작업 위임” 구분

### Batch 4 — automation pair wording 정리

- 대상 스킬:
  - `plugins/app-automation/skills/app-automation/SKILL.md`
  - `plugins/app-automation/skills/os-log/SKILL.md`
- 목표:
  - UI 조작 vs 로그 조회 분리

## Notes

- 한 번에 여러 family를 동시에 바꾸지 않는다.
- 가능하면 한 실험에서 한 종류의 wording만 바꾼다.
- 결과가 좋아도 실패 케이스를 같이 기록한다.
