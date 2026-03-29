# Claude Code 자연어 스킬 라우팅 연구

이 디렉토리는 **이 저장소의 스킬들을 Claude Code가 자연어 프롬프트만으로도 더 자연스럽게, 더 정확하게 선택하도록 개선하는 연구**를 정리합니다.

## 연구 목표

- 사용자가 슬래시 커맨드 없이 자연어로 요청해도 적절한 스킬이 활성화되게 한다.
- 여러 스킬이 겹치는 영역에서 **가장 적합한 스킬**이 선택되게 한다.
- description / examples / boundary wording / plugin 설명이 실제 선택률에 어떤 영향을 주는지 검증한다.

## 범위

포함:
- `plugins/*/skills/*/SKILL.md`의 frontmatter와 본문 wording
- plugin `description`과 README wording
- 스킬 간 경계 정의
- 자연어 테스트 코퍼스와 평가 기준

제외:
- 실제 스킬 내부 로직의 품질 자체
- Claude Code 외 런타임의 일반적인 LLM 성능 비교
- 도구 실행 성공률 자체

## 현재 연구 대상

- 플러그인: 7개
- 스킬: 13개
- 핵심 충돌군:
  - `ctx-guide` / `ctx-init` / `ctx-verify` / `ctx-audit`
  - `apple-craft` / `apple-harness` / `apple-review`
  - `app-automation` / `os-log`
  - `gpt-research` / `hey-codex`

## 문서 맵

1. `01-problem-framing.md`
   - 문제 정의, 비목표, 성공 기준
2. `02-skill-inventory.md`
   - 현재 스킬 인벤토리와 충돌 구간
3. `03-hypotheses-and-design.md`
   - 개선 가설과 실험 설계
4. `04-prompt-corpus.md`
   - 자연어 테스트 세트
5. `05-evaluation-rubric.md`
   - 채점 기준과 오류 분류
6. `06-experiment-log.md`
   - 실험 결과 기록
7. `batches/01-apple-family.md`
   - `apple-craft` / `apple-review` / `apple-harness` 1차 개선 초안
8. `batches/01-apple-family-baseline-template.md`
   - Batch 1 수정 전/후 비교용 측정표 템플릿
9. `batches/01-apple-family-baseline-2026-03-29.md`
   - Batch 1 수정 전 baseline 측정 기록
10. `batches/01-apple-family-postpatch-2026-03-29.md`
    - Batch 1 수정 후 post-patch 측정 기록

## 권장 진행 순서

1. `02-skill-inventory.md`로 현재 wording과 충돌 지점을 정리
2. `04-prompt-corpus.md`로 베이스라인 평가 세트 확정
3. `05-evaluation-rubric.md` 기준으로 현재 상태를 점수화
4. `03-hypotheses-and-design.md`의 후보 수정안을 하나씩 적용
   - 첫 대상은 `batches/01-apple-family.md`
5. 각 실험 결과를 `06-experiment-log.md`에 누적

## 기대 산출물

- 어떤 스킬은 **description 확장**이 필요한지
- 어떤 스킬은 **예시 다양화**가 필요한지
- 어떤 스킬은 **“언제 쓰지 말아야 하는지”**를 더 명확히 해야 하는지
- 어떤 충돌군은 **상위/하위 라우팅 구조**가 필요한지
