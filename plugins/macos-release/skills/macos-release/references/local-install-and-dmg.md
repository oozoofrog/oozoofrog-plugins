# Local install and DMG verification

GUI macOS 앱 릴리스에서는 DMG/ZIP를 만든 뒤 **로컬 설치 검증**을 먼저 거치는 것이 안전합니다.

## 목표
- 빌드는 성공했지만 실제 설치 결과가 깨진 경우를 publish 전에 발견
- 올바른 앱 번들이 덮어써졌는지 확인
- 잘못된 빌드 경로나 오래된 앱 실행 문제를 조기에 차단

## 기본 순서
1. 실행 중인 앱 종료
2. DMG 마운트 또는 ZIP 추출
3. 기존 설치 앱 제거/덮어쓰기
4. 새 앱 실행
5. 최소 smoke test 확인
6. publish 단계로 진행

## 앱 종료 절차
보통 다음 순서가 안전합니다.
- `pkill -x "$APP_NAME"` 로 정상 종료 시도
- 몇 초 대기 후 살아 있으면 재시도
- 정말 남아 있으면 마지막 수단으로 강제 종료

예시:
```bash
pkill -x "$APP_NAME" || true
sleep 1
for i in {1..5}; do pgrep -x "$APP_NAME" || break; sleep 1; done
pgrep -x "$APP_NAME" && pkill -9 -x "$APP_NAME"
```

## DMG 설치 예시
```bash
DMG_MOUNT=$(hdiutil attach "$DMG" -nobrowse -noverify -noautoopen | grep "/Volumes/" | awk '{print $NF}')
rm -rf "$INSTALLED_APP"
ditto "$DMG_MOUNT/$APP.app" "$INSTALLED_APP"
hdiutil detach "$DMG_MOUNT" -quiet
open "$INSTALLED_APP"
```

주의:
- 이미 같은 볼륨명이 마운트돼 있지 않은지 확인
- `ditto` 또는 동등한 복사 수단으로 번들 구조를 유지
- 설치 대상 경로와 빌드 산출물 경로를 혼동하지 않기

## ZIP 기반 검증
- 임시 디렉터리에 압축 해제
- `.app` 번들 존재 확인
- 기존 설치 위치에 복사
- launch 후 기본 기능 확인

## CLI 배포와의 차이
CLI는 보통 DMG 로컬 설치보다 아래가 더 중요합니다.
- binary 실행 확인
- `--help` / version 출력 확인
- Homebrew Formula install/test 확인

## 최소 검증 예시
- 앱 실행 여부
- 메뉴바/기본 창 표시 여부
- 크래시 없이 초기화되는지
- 버전 표기가 기대값인지
