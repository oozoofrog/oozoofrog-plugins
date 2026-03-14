# macOS release checklist

## 1. 릴리스 범위 고정
먼저 아래 중 무엇인지 고정합니다.
- 전체 릴리스
- dry-run / 사전 점검
- Homebrew만
- workflow/CI만
- 버전만 업데이트
- 패키징만

사용자가 특정 단계만 원하면 전체 파이프라인을 강제하지 않습니다.

## 2. 시작 전 점검
### 필수 도구
- `gh` CLI 설치 및 인증: `gh auth status`
- Xcode/Swift build 가능 여부 (`xcodebuild`, `swift`, 필요한 toolchain)
- Git 작업 트리 상태가 안전한지 (`git status --short`)
- Homebrew tap 로컬 clone 또는 remote push 가능 여부

### 프로젝트 탐지
우선 탐색 대상:
- `scripts/release.sh`
- `fastlane/Fastfile`
- `.github/workflows/`
- `*.xcodeproj`, `*.xcworkspace`
- `Formula/*.rb`, `Casks/*.rb`, `homebrew-*`
- 버전/빌드 번호 소스 파일 (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`, plist 등)

탐지표:

| 항목 | 보통 찾는 위치 | 없으면 |
|------|----------------|--------|
| release script | `scripts/release.sh` | 새 스크립트 생성 대신 기존 흐름 유무부터 다시 확인 |
| Xcode project/workspace | `*.xcodeproj`, `*.xcworkspace` | 수동 경로 지정 또는 SwiftPM/CLI 구조로 분류 |
| Homebrew tap | `../homebrew-tap`, `../homebrew-*` | 새 tap 생성 여부를 마지막에 판단 |
| 현재 버전 | pbxproj / plist / manifest | 사용 중인 단일 source of truth를 먼저 확정 |

## 3. 기존 구조 우선 원칙
- `scripts/release.sh` 가 있으면 **반드시 dry-run부터** 시도합니다.
- 예: `./scripts/release.sh --dry-run [version]`
- 기존 tap/workflow가 있으면 그 구조를 유지합니다.
- 릴리스 구조가 이미 있는데 병렬 구조를 추가하지 않습니다.

## 4. 안전한 기본 순서
1. 버전 확인/증가
2. 빌드
3. 패키징(DMG/ZIP/tarball)
4. 로컬 검증
5. GitHub Release 또는 tag push
6. Homebrew 반영

원칙:
- 빌드/패키징 실패면 publish 단계 중단
- 로컬 설치 또는 smoke test 없이 외부 publish로 넘어가지 않기
- Homebrew만 실패한 경우에도 release와 tap 문제를 분리해서 보고하기

## 5. 앱/CLI 분기
- GUI macOS 앱 → DMG/ZIP + Cask 중심
- CLI → source tarball / binary / Formula 중심

판단이 애매하면 최종 산출물이 `.app` 인지부터 확인합니다.

## 6. 결과 보고 필수 항목
- 어떤 범위의 릴리스였는지
- 재사용한 기존 스크립트/워크플로/탭
- 변경 파일 목록
- 실행한 명령
- 생성된 버전/산출물
- 남은 수동 단계
- 실패 시 복구 명령
