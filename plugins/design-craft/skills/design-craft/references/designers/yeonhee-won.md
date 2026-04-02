# 원연희 (Yeonhee Won) -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 2000s-현재, 핵심기 2010s-현재 (Apple 한글 타이포그래피)
- **주요 소속**: Apple Korea 타이포그래피 팀, Apple 글로벌 폰트 엔지니어링
- **핵심 공헌**: SF Pro 한글 적용 및 최적화, Apple 플랫폼 한글 타이포그래피 가이드라인 수립, 한글 자간·행간 보정 체계, Apple 생태계 한글 렌더링 품질 표준화
- **디자인 계보**: 한글 타이포그래피 전통 → Apple Human Interface Guidelines 한글 현지화 → SF Pro 한글 확장

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 한글-라틴 조화 | 한글/라틴 혼조 시 시각 크기 일치 | x-height 대비 한글 중성 높이 매칭 |
| 시스템 일관성 | 모든 Apple 플랫폼 동일 렌더링 | iOS/macOS/watchOS 한글 토큰 통일 |
| 가독성 최우선 | 소형 디스플레이에서 한글 판독률 99%+ | 38mm watchOS에서도 본문 판독 가능 |
| 자간 정밀 보정 | 한글 고유 자간 테이블 적용 | 조합형 한글 11,172자 커닝 최적화 |
| 문화적 적합성 | 한글 타이포그래피 전통 존중 | 세로쓰기·혼용 조판 규칙 반영 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| korean-body-size | 17pt (iOS 기본 본문) | Apple HIG — Dynamic Type 기본 크기 | S |
| korean-minimum-size | 11pt (iOS 최소 가독 크기) | Apple HIG — 한글 최소 크기 권장 | A |
| watchos-body | 16pt (40mm), 17pt (44mm) | watchOS HIG — 한글 본문 크기 | A |
| line-height-korean | 1.4-1.6 (라틴 1.2 대비 넓은 행간) | Apple HIG — 한글 행간 보정 가이드 | A |
| paragraph-spacing | 본문 크기의 60-80% | Apple HIG — 한글 문단 간격 | B |
| margin-horizontal | 16pt (컴팩트), 20pt (레귤러) | Apple HIG — iOS 수평 마진 | S |
| text-container-ratio | 한글 텍스트 영역 = 라틴 대비 5-10% 넓게 | 한글 글자 폭이 라틴 대비 넓은 보정 | B |
| grid-base | 8pt (Apple 표준 그리드) | Apple HIG — 기본 그리드 단위 | S |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-sf-korean | Apple SD Gothic Neo → SF Pro 한글 | Apple 시스템 폰트 변천 | S |
| font-weight-korean | Ultralight-Black (9종 웨이트) | SF Pro 한글 웨이트 체계 | A |
| korean-tracking | -0.01em ~ -0.02em (기본 대비 약간 좁힘) | Apple 한글 트래킹 보정값 | B |
| korean-x-height-match | 한글 중성 높이 = 라틴 cap-height의 80-85% | SF Pro 한영 혼조 시각 매칭 분석 | B |
| korean-ascender | 라틴 ascender의 95-100% | SF Pro 한글 상단 정렬 분석 | B |
| korean-descender | 라틴 descender의 80-90% (한글은 하단 돌출 적음) | SF Pro 한글 하단 정렬 분석 | B |
| font-size-scale | 11, 13, 15, 17, 20, 22, 28, 34pt (Dynamic Type) | Apple HIG — Dynamic Type 7단계 | S |
| line-break-rule | 한글 어절 단위 줄바꿈, 음절 단위 허용 | Apple 한글 줄바꿈 규칙 | A |
| word-spacing | 한글 띄어쓰기 = 한글 폭의 25-33% | Apple 한글 워드 스페이싱 분석 | B |
| mixed-script-baseline | 한글·라틴 기준선 정렬 보정 +1-2pt | SF Pro 한영 혼조 기준선 보정 | B |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| text-primary | label 시맨틱 컬러 (라이트: #000000, 다크: #FFFFFF) | Apple HIG — 시맨틱 텍스트 컬러 | S |
| text-secondary | secondaryLabel (라이트: 60% opacity) | Apple HIG — 보조 텍스트 컬러 | S |
| text-tertiary | tertiaryLabel (라이트: 30% opacity) | Apple HIG — 3차 텍스트 컬러 | S |
| korean-rendering | 서브픽셀 안티앨리어싱 → 그레이스케일 AA | Apple Retina 디스플레이 한글 렌더링 | A |
| contrast-ratio | 최소 4.5:1 (본문), 3:1 (대형 텍스트) | Apple 접근성 가이드라인 | S |
| tint-color | systemBlue (#007AFF) 기본 악센트 | Apple HIG — 기본 틴트 컬러 | S |
| background | systemBackground (라이트: #FFFFFF, 다크: #000000) | Apple HIG — 시맨틱 배경 컬러 | S |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| korean-em-square | 1000 UPM (units per em) | SF Pro 폰트 메트릭스 | S |
| stroke-contrast | 한글 세로획:가로획 = 1.1-1.3:1 (저대비) | SF Pro 한글 획 대비 분석 | B |
| corner-radius-glyph | 글리프 모서리 미세 둥글림 (CFF2 힌팅) | SF Pro 한글 글리프 형태 분석 | B |
| hangul-structure | 정사각형 em-box 내 초·중·종성 배치 | 한글 조합형 구조 — 글자 폭 = 높이 | S |
| button-radius | 10pt (iOS 기본), continuous corner | Apple HIG — 버튼 곡률 | S |
| text-field-height | 34pt (컴팩트), 44pt (레귤러) | Apple HIG — 한글 입력 필드 높이 | A |
| glyph-width | 전각(em) 너비 — 한글은 모노스페이스 기본 | SF Pro 한글 글리프 너비 분석 | A |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| keyboard-input | 두벌식/세벌식 입력 → 실시간 조합 표시 | iOS/macOS 한글 입력기 | S |
| composition-feedback | 조합 중 밑줄 표시, 완성 후 제거 | Apple 한글 인라인 입력 UX | S |
| autocorrect-delay | 한글 자동수정 = 어절 완성 후 0.5-1s | iOS 한글 자동수정 타이밍 | B |
| text-selection | 한글 음절 단위 선택 (더블탭 = 어절) | iOS 한글 텍스트 선택 규칙 | A |
| dynamic-type-animation | 크기 변경 시 0.3s ease-in-out 전환 | iOS Dynamic Type 전환 애니메이션 | A |
| font-smoothing | 서브픽셀 → 그레이스케일 AA (Retina) | Apple 텍스트 렌더링 전환 | A |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 2000s 초반 | Apple Korea 한글화 기초 | Lucida Grande 한글 보완, 기본 자간 설정 |
| 2007-2012 | iPhone/iPad 한글 최적화 | Apple SD Gothic Neo 도입, iOS 한글 렌더링 체계 수립 |
| 2013-2015 | iOS 7 플랫 디자인 전환 | Helvetica Neue 한글 페어링 최적화, Dynamic Type 한글 지원 |
| 2015-2019 | SF Pro 한글 통합 | SF Pro 한글 웨이트 9종 확장, watchOS 한글 최적화 |
| 2020-현재 | SF Pro Rounded/한글 확장 | 가변 폰트(Variable Font) 한글 적용, 접근성 강화 |

## 영향 관계

- **한글 타이포그래피 전통 → 원연희**: 세종대왕 훈민정음 기하학, 최정호 명조체 체계
- **Apple SF 디자인 팀 → 원연희**: SF Pro 라틴 디자인 원칙을 한글에 적용
- **원연희 → Apple 한글 생태계**: iOS/macOS/watchOS/visionOS 한글 타이포그래피 품질 표준
- **원연희 → 한글 웹 타이포그래피**: Apple 한글 가이드라인이 웹/앱 한글 조판의 사실상 표준
- **주요 참고**: Apple Human Interface Guidelines — Typography, SF Pro 폰트 릴리스 노트

## UI 적용 매핑

| 원연희 원칙 | 현대 UI 토큰 변환 규칙 |
|------------|----------------------|
| 한영 시각 매칭 | `font-size` 동일해도 한글 시각 크기 보정 — `font-size-adjust` 활용 |
| 넓은 한글 행간 | `line-height: 1.5` (한글), `line-height: 1.3` (라틴) — 언어별 분리 |
| 자간 보정 | `letter-spacing: -0.01em` (한글 기본), 라틴은 표준 |
| Dynamic Type | `.font(.body)` — 사용자 설정 크기 자동 반영, 한글 최소 11pt 보장 |
| 어절 줄바꿈 | `word-break: keep-all` (한글), 음절 분리 최소화 |
| 조합 입력 UX | 한글 입력 중 `compositionupdate` 이벤트 처리, 조합 상태 시각 표시 |
| 접근성 대비 | 한글 본문 대비 4.5:1+, 시맨틱 컬러 사용 `.foregroundStyle(.primary)` |
| 시스템 폰트 | `-apple-system, BlinkMacSystemFont` → SF Pro 한글 자동 적용 |
| em-box 정사각 | 한글 가로:세로 = 1:1, 고정폭 → 테이블/그리드에서 정렬 유리 |
| 다크모드 한글 | 한글 획 두께 보정 — 다크모드에서 `font-weight` +50 시각 보정 |
