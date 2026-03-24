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
