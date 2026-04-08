# hey-codex 재검증 5건 이슈 연구 요약

- 날짜: 2026-04-02
- 대상 워크스페이스: `/Volumes/eyedisk/develop/oozoofrog/oozoofrog-plugins`
- 연구 상태 디렉터리: `.codex-research/`
- 최종 HEAD: `96dd920`
- 최종 control action: `pass`

## 1. 목적

PR 재검증에서 제기된 5건의 이슈가 실제 환경에서 문제를 일으키는지 검증하고,
실제로 재현되는 이슈만 수정 대상으로 유지한다.

## 2. 계약 요약

- mode: guided-loop
- mutable surface:
  - `plugins/hey-codex/scripts/codex-research.py`
  - `plugins/hey-codex/scripts/snapshot-diff.sh`
- immutable constraints:
  - `round-result.schema.json`, `preflight.sh`, `plugin.json`, `marketplace.json`
  - CLI 서브커맨드 시그니처
- hard gates:
  1. `python3 -m py_compile plugins/hey-codex/scripts/codex-research.py`
  2. `bash -n plugins/hey-codex/scripts/snapshot-diff.sh`
  3. 수정이 기존 동작을 깨뜨리지 않을 것
- primary metric:
  - `reproduced_count / total_issues`
- budget:
  - 최초 max 3 rounds
  - 2026-04-02 재개 시 remaining issue3/5 검증을 위해 max 5 rounds로 연장

## 3. 연구 진행 개요

이 연구는 원래 budget 소진으로 중단되었고, 2026-04-02에 재개했다.
재개 시점 기준으로 이미 issue1, issue2, issue4는 재현 및 수정 완료 상태였고,
issue3, issue5만 미검증 상태로 남아 있었다.

### 재개 전 상태

- reproduced=3
- fixed=3
- remaining_unverified=2
- 남은 항목:
  - issue3: `should_stop(loop_forever)` 파라미터 제거 안전성
  - issue5: `report_diff()` temp file 이중 삭제 판정

### 재개 후 실행 라운드

- round 004: issue3 판정
- round 005: issue5 판정

## 4. 이슈별 최종 판정

| 이슈 | 설명 | 최종 판정 | 결과 |
|---|---|---|---|
| issue1 | `snapshot-diff.sh` unreadable subdir에서 pipefail 조기 종료 | 재현 성공 | 수정 완료 |
| issue2 | `decode_json_object()`가 non-object JSON을 내부 dict로 오복구 | 재현 성공 | 수정 완료 |
| issue3 | `should_stop(loop_forever)` 파라미터 제거 안전성 | 재현 대상 아님 | discard |
| issue4 | Phase 3 offset-scan이 wrapped array 내부 dict를 잘못 복구 | 재현 성공 | 수정 완료 |
| issue5 | `report_diff()` temp file 이중 삭제 | current HEAD에서 비재현 | discard |

## 5. round 004 요약 — issue3

### 가설

`should_stop()`에서 `loop_forever` 파라미터를 제거해도 실제 동작 차이는 없다.

### 근거

- 현재 구현은 이미 3인자 시그니처만 사용한다.
- 호출 전 `max_rounds = None if args.loop_forever else args.max_rounds` 정규화가 적용된다.
- 초기 구현의 `if loop_forever: return False`는 최종 `return False`와 동일한 dead branch였다.
- 히스토리상 관련 정리는 이미 `0bf21c0`에서 반영되어 있었다.
- focused equivalence check에서 mismatch 0건을 확인했다.

### 판정

- hard gates: `pass`
- experiment status: `keep`
- control action: `refine`
- issue-level verdict: **discard**
  - current HEAD 기준 live bug가 아니라 이미 안전하게 정리된 stale 항목

## 6. round 005 요약 — issue5

### 가설

`report_diff()` temp file 이중 삭제는 current HEAD 기준 live bug가 아니다.

### 근거

- 정적 분석상 `report_diff()`는 temp file들을 `_CLEANUP_FILES`에만 등록하고,
  함수 내부에서 별도 수동 삭제를 수행하지 않는다.
- `bash -x` trace에서 `report_diff()` temp file은 각 1회만 정리되었다.
- 2회 삭제로 보이는 항목은 `take_snapshot()`의 scratch file(`find_err`, `snapshot_rows`)뿐이었다.
- 이 scratch file 중복 cleanup도 `rm -f` 기반이라 동작상 무해하다.
- smoke test에서 diff 출력은 정상이고 `leaked=[]`로 temp 누수도 없었다.

### 판정

- hard gates: `pass`
- experiment status: `keep`
- control action: `pass`
- issue-level verdict: **discard**
  - 원문 주장인 “`report_diff()` temp file 이중 삭제”는 current HEAD와 trace에 부합하지 않음

## 7. 최종 메트릭

- reproduced_count = 3/5
- fixed_count = 3/5
- discarded_count = 2/5
- remaining_unverified = 0

즉, **5건 모두 판정 완료**되었다.

## 8. 최종 best-known state

- 수정 유지:
  - issue1
  - issue2
  - issue4
- discard:
  - issue3 — stale 항목
  - issue5 — misframed / non-repro 항목

현재 연구 범위 내에서 추가 검증이 필요한 미해결 항목은 없다.

## 9. 후속 권고

### 필수 후속 작업

- 없음

### 선택적 리팩터링 후보

- `snapshot-diff.sh`의 `take_snapshot()` scratch file cleanup 중복은 정리할 수 있으나,
  이번 연구 기준 live bug는 아니므로 우선순위는 낮다.

## 10. 관련 산출물

### 상태 파일

- `.codex-research/contract.md`
- `.codex-research/state_snapshot.md`
- `.codex-research/ledger.tsv`

### 라운드 근거 문서

- `.codex-research/rounds/round-003/evidence.md`
- `.codex-research/rounds/round-004/evidence.md`
- `.codex-research/rounds/round-005/evidence.md`

### 응답 JSON

- `.codex-research/rounds/round-004/response.json`
- `.codex-research/rounds/round-005/response.json`

## 11. 결론

이 연구는 최종적으로 `pass`로 종료되었다.

핵심 결론은 다음과 같다.

1. 실제 수정이 필요했던 이슈는 3건(issue1, issue2, issue4)이었다.
2. issue3은 이미 코드베이스에 반영된 정리 사항이라 별도 수정 대상이 아니었다.
3. issue5는 `report_diff()`의 live bug가 아니라, 관찰 대상을 잘못 특정한 비재현 항목이었다.
4. 따라서 이번 재검증 트랙은 **재현 기반 필터링이 유효하게 작동한 사례**로 볼 수 있다.
