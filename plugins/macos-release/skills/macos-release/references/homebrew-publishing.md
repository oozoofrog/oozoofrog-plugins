# Homebrew publishing guide

## 1. Cask vs Formula
기본 판단 기준:
- GUI macOS 앱 (`.app`) → 대체로 `Cask`
- CLI 도구 → 대체로 `Formula`

보강 기준:
- 메뉴바 앱, 상태바 앱, 일반 GUI 앱은 Cask 우선
- `brew install user/tap/tool` 형태의 CLI 배포면 Formula 우선
- 애매하면 최종 산출물(`.app` vs CLI binary)과 사용자의 설치 기대치(`--cask` vs 일반 `brew install`)를 확인

## 2. 공용 tap 원칙
공용 tap(`homebrew-tap`)에서는 다음을 지킵니다.
- 대상 프로젝트의 formula/cask **한 파일만** 수정합니다.
- 다른 `Formula/` 나 `Casks/` 항목은 건드리지 않습니다.
- tap repo가 관련 없는 변경으로 dirty 하면 먼저 정리하거나 작업을 중단합니다.
- push 전에는 항상 현재 작업이 대상 파일 하나에만 국한되는지 확인합니다.

## 3. Formula 패턴
보통 다음을 확인합니다.
- source tarball URL 또는 릴리즈 바이너리 URL
- `sha256` 재계산
- `depends_on "go" => :build` 같은 build dependency
- `brew audit --strict --formula`
- `brew install --build-from-source`
- `brew test`

CLI는 source build Formula가 유지보수와 공용 tap 운영에 유리한 경우가 많습니다.

## 4. Cask 패턴
보통 다음을 확인합니다.
- DMG/ZIP URL
- 산출물 `sha256`
- `app` 경로
- 필요 시 `depends_on macos:`
- `zap` 경로
- 설치 후 앱이 정상 launch 되는지 최소 확인

예시 스켈레톤:
```ruby
cask "appname" do
  version "X.Y.Z"
  sha256 "..."

  url "https://github.com/USER/REPO/releases/download/v#{version}/App-#{version}.dmg"
  name "AppName"
  desc "App description"
  homepage "https://github.com/USER/REPO"

  app "AppName.app"
end
```

## 5. 공용 tap push 충돌
다른 프로젝트가 같은 tap을 갱신했을 수 있으므로 보통 아래가 필요합니다.

```bash
git pull --rebase origin main
git push origin main
```

관련 없는 local 변경이 있으면 rebase/push 전에 중단하는 편이 안전합니다.

## 6. 보고 항목
- 어떤 tap repo를 사용했는지
- 어떤 formula/cask 파일을 수정했는지
- URL/sha256/version 변경값
- audit/install/test 결과
- push 또는 rebase 충돌 여부
