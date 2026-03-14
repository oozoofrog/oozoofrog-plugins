# macos-release

macOS 앱의 전체 릴리스 수명주기를 자동화하는 Claude Code 스킬입니다.

## 기능

- **버전 범프**: Xcode 프로젝트의 `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` 자동 업데이트
- **빌드 & 패키징**: Release 빌드 → DMG/ZIP 생성
- **로컬 설치 검증**: 앱 종료 → 덮어쓰기 → 재실행으로 즉시 확인
- **GitHub Release**: 태그 생성, 릴리스 노트 자동 생성, 에셋 업로드
- **Homebrew Cask/Formula**: 개인 tap에 Cask 파일 자동 업데이트
- **GitHub Actions CI/CD**: 빌드+릴리스 워크플로우, Homebrew 자동 업데이트 워크플로우

## 사용법

Claude Code에서 다음과 같이 요청하세요:

```
새 버전 릴리스해주세요
릴리스 파이프라인 만들어주세요
홈브루 캐스크만 업데이트해주세요
배포 자동화 워크플로우 만들어주세요
```

## 설치

```bash
/plugin install macos-release@oozoofrog-plugins
```
