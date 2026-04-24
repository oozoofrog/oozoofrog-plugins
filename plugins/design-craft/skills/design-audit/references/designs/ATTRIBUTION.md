# Attribution — awesome-design-md 내재화 출처

이 디렉토리(`references/designs/`)에 포함된 69개 `.md` 파일과 `manifest.json`은 MIT 라이선스 하에 VoltAgent 팀의 공개 자료로부터 복제·재배포된 것이다.

## 원본 출처

| 항목 | 경로 |
|------|------|
| GitHub | <https://github.com/VoltAgent/awesome-design-md> |
| 홈페이지 | <https://getdesign.md> |
| npm 패키지 | `getdesign@0.6.8` — <https://www.npmjs.com/package/getdesign> |
| 저작자 | VoltAgent 팀 (omerfarukaplak, necatiozmen) |
| 라이선스 | MIT License — Copyright (c) 2026 VoltAgent |
| 스냅샷 일시 | 2026-04-24 (npm `getdesign@0.6.8` tarball 기준) |

원본 `templates/*.md` 파일은 바이트 수준으로 동일하게 복제되었다(sha256 해시는 `manifest.json`에 보존). 파일 이름·디렉토리 구조도 원본과 동일하다.

## 라이선스 전문

```
MIT License

Copyright (c) 2026 VoltAgent

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 브랜드 자산의 소유권

`*.md` 파일들은 공개 웹사이트로부터 추출한 디자인 토큰의 기록이며, 각 브랜드(Stripe, Linear, Apple 등)의 상표·로고·시각 정체성은 각 회사에 귀속된다. VoltAgent 원본 리포 README에 다음 문구가 명시되어 있다:

> "This repository is a curated collection of design system documents extracted from public websites. All DESIGN.md files are provided 'as is' without warranty. The extracted design tokens represent publicly visible CSS values. We do not claim ownership of any site's visual identity."

이 스킬은 동일한 조건을 승계한다. 각 `.md` 파일의 사용은 해당 브랜드의 트레이드마크·저작권 규정을 준수하는 범위에서만 이루어져야 한다.

## 동기화

원본이 갱신되면 `scripts/fetch-catalog-diff.sh` 실행으로 신규·변경·삭제된 브랜드를 감지하고, `scripts/sync-designs.sh`로 새 npm tarball을 내려받아 `references/designs/`를 갱신할 수 있다. 동기화 시 `manifest.json`의 `sourceCommit`·`templateHash`를 기준으로 변경 여부를 판정한다.

## 기여 또는 이의 제기

원본 저장소의 콘텐츠에 대한 수정·삭제 요청은 상류(upstream)로 직접 제기한다:

- <https://github.com/VoltAgent/awesome-design-md/issues>

이 스킬의 내재화 스냅샷과 관련된 이슈는 `oozoofrog-plugins` 저장소에서 처리한다.
