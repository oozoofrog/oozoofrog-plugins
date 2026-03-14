# Release troubleshooting

## 자주 만나는 증상

| 증상 | 흔한 원인 | 우선 확인/해결 |
|------|----------|----------------|
| 빌드 성공인데 앱이 안 바뀜 | 다른 빌드 경로의 앱 또는 기존 설치 앱이 계속 실행 중 | 앱 종료 → clean build → 실제 설치 경로 재확인 |
| DMG 생성 실패 | 디스크 공간 부족, 동일 볼륨명 마운트, 권한 문제 | 공간 확인, 기존 마운트 detach, 출력 경로 재확인 |
| 로컬 설치 후 실행이 안 됨 | 잘못된 번들 복사, 오래된 앱 덮어쓰기 실패, signing 문제 | 마운트 경로/복사 경로 확인, 기존 앱 제거 후 재설치 |
| Homebrew tap push 거부 | remote에 새 커밋 존재 | `git pull --rebase origin main` 후 재시도 |
| `gh release create` 실패 | 같은 태그/릴리즈가 이미 존재 | 기존 릴리즈 삭제 또는 새 버전/태그 사용 |
| 버전이 pbxproj에서 안 바뀜 | `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` 갱신 패턴 불일치 | 실제 파일 형식 확인 후 source of truth를 다시 고정 |
| Formula/Cask 검증 실패 | URL, sha256, install path, app path, zap 경로 오류 | 대상 파일 한 개만 수정했는지 확인 후 audit/install/test 재실행 |
| workflow에서 Homebrew update 실패 | secret 누락, token 권한 부족, tap repo 충돌 | secret 이름/권한 확인, 수동 스크립트로 복구 |

## 문제를 보고할 때 포함할 것
- 어느 단계에서 실패했는지
- 마지막으로 성공한 단계
- 실행한 명령
- 관련 로그 또는 에러 메시지
- 자동화 대신 수동 복구 가능한 다음 명령

## 복구 기본 원칙
- build/package 실패 시 publish 단계로 넘어가지 않기
- Homebrew만 실패했으면 release와 tap 반영을 분리해서 정리하기
- 이미 외부 publish가 된 상태면 rollback 대신 후속 수정/재배포 경로를 먼저 정리하기
