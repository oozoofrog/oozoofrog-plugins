# Susan Kare -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1982-현재, 핵심기 1982-1986 (Apple Macintosh), 2015-현재 (Pinterest)
- **주요 소속**: Apple Computer(1982-1986), NeXT(1986-1989), Microsoft(Windows 3.0 카드놀이), Pinterest Creative Director
- **핵심 공헌**: Macintosh 시스템 아이콘(Happy Mac, Command, 폭탄, 휴지통), Chicago 폰트, Geneva/Monaco 폰트, Windows 솔리테어 카드, 픽셀 아트 아이콘 체계 확립
- **디자인 계보**: 모자이크/자수 기법 → 32×32 비트맵 그리드 → 현대 아이콘 디자인의 어머니

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 그리드 제약 = 창의성 | 32×32 = 1024 픽셀 내 표현 | 최소 해상도에서 인식 가능 |
| 1-bit 명확성 | 흑·백 2색으로 의미 전달 100% | 단색 아이콘 인식률 95%+ |
| 메타포 우선 | 실세계 대응물 있는 아이콘 80%+ | 사용자 학습 시간 최소화 |
| 인간적 따뜻함 | 곡선/유기적 형태 포함 | 차갑지 않은 친근한 인상 |
| 보편적 인식 | 문화 독립적 심볼 | 글로벌 인식률 90%+ |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| icon-grid-large | 32×32 픽셀 (표준 아이콘) | Macintosh System 1.0 아이콘 스펙 (1984) | S |
| icon-grid-small | 16×16 픽셀 (메뉴/커서) | Macintosh 메뉴 아이콘/커서 스펙 | S |
| icon-padding | 그리드 가장자리 1-2px 여백 | Macintosh 아이콘 실측 — 가장자리 터치 회피 | A |
| icon-centering | 시각적 중심 정렬 (수학적 중심 아닌) | Kare 아이콘 배치 분석 — 시각 보정 적용 | A |
| cursor-hotspot | 좌상단 꼭짓점 (1,1) | Macintosh 화살표 커서 핫스팟 위치 | S |
| desktop-icon-spacing | 가로 80px, 세로 64px 간격 | Macintosh Finder 아이콘 그리드 (System 1-6) | A |
| bit-depth | 1-bit (흑/백 2값) | Macintosh 128K 하드웨어 제약 | S |
| screen-resolution | 512×342 픽셀, 72dpi | Macintosh 128K 모니터 스펙 | S |
| grid-base-ui | 4pt (저해상도 디지털 변환) | 16px 기반 4배수 체계 | F |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-chicago | Chicago — 비트맵, 12pt 기본 | Macintosh 시스템 폰트 (1984) — Kare 설계 | S |
| font-geneva | Geneva — 비트맵, 산세리프, 9-12pt | Macintosh 보조 폰트 — Kare 설계 | S |
| font-monaco | Monaco — 비트맵, 고정폭, 9pt | Macintosh 고정폭 폰트 — Kare 설계 | S |
| pixel-grid-font | 글자 = 픽셀 그리드에 수동 배치 | Kare 비트맵 폰트 제작 방식 | S |
| chicago-x-height | 7px (12pt 기준) | Chicago 폰트 실측 | A |
| chicago-cap-height | 9px (12pt 기준) | Chicago 폰트 실측 | A |
| chicago-weight | Bold에 가까운 Medium (1-bit 가독성) | Chicago 획 두께 — 저해상도 보정 | A |
| line-height | 글자 높이 + 3-4px 행간 | Macintosh 시스템 텍스트 행간 | A |
| font-size-ui | 12-14pt (시스템 기본) | Macintosh 72dpi 기준 텍스트 크기 | S |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| palette-1bit | #000000 (흑), #FFFFFF (백) — 2색 | Macintosh 128K 1-bit 디스플레이 | S |
| dither-pattern | 50% 체커보드 = 회색 시뮬레이션 | Macintosh 1-bit 회색 표현 기법 | S |
| pattern-library | 38종 기본 패턴 (줄무늬, 점, 격자 등) | Macintosh System 패턴 팔레트 — Kare 설계 | S |
| highlight-color | 반전(Invert) — 흑↔백 전환 | Macintosh 선택 상태 표현 | S |
| background | #FFFFFF (순백 데스크톱) | Macintosh Finder 기본 배경 | S |
| contrast-ratio | 21:1 (순흑/순백 — 최대 대비) | 1-bit 디스플레이 물리적 제약 | S |
| surface-texture | 비트맵 패턴으로 텍스처 시뮬레이션 | Kare 패턴 시스템 | S |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| pixel-perfect | 모든 형태 = 정수 픽셀 좌표 | 1-bit 비트맵 그리드 제약 | S |
| corner-radius | 계단식 근사 (1px 단계) — 실제 곡선 불가 | 32×32 그리드에서 원형 근사 분석 | S |
| circle-approx | 지름 ≥ 8px에서 원형 인식 가능 | Kare 원형 아이콘 실측 (Happy Mac 얼굴) | A |
| line-weight | 1px (최소 단위) — 2px=굵은 선 | 1-bit 비트맵 선 두께 제약 | S |
| icon-metaphor | 실세계 물체 단순화 (휴지통, 폴더, 시계) | Macintosh 아이콘 메타포 분석 | S |
| happy-mac-face | 12×8px 얼굴 영역 (32×32 내) | Happy Mac 아이콘 실측 | A |
| command-symbol | 4개 루프 연결 — 스웨덴 관광 표지에서 차용 | ⌘ Command 키 심볼 (Kare 발견) | S |
| trash-icon | 32×32, 덮개+통 2단 구조 | Macintosh 휴지통 아이콘 실측 | S |
| form-warmth | 유기적 곡선 40%+ (직선만 60%) | Kare 아이콘 형태 분석 — 기계적 차가움 회피 | A |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| click-feedback | 아이콘 반전(Invert) — 즉시 | Macintosh 아이콘 클릭 피드백 | S |
| drag-feedback | 아이콘 외곽선만 이동 표시 | Macintosh Finder 드래그 표현 | S |
| cursor-blink | 삽입점 깜빡임 530ms on/530ms off | Macintosh 텍스트 커서 타이밍 | A |
| menu-highlight | 반전(흑배경+백텍스트) — 즉시 전환 | Macintosh 메뉴 하이라이트 | S |
| animation-frame | 2-4프레임 (시계 아이콘 = 4프레임 회전) | Macintosh 시스템 애니메이션 분석 | S |
| watch-cursor | 4프레임 회전 루프, 각 프레임 0.5s | Macintosh 대기 커서(손목시계) | A |
| transition | 없음 — 즉시 전환 (하드웨어 제약) | Macintosh 128K 처리 속도 | S |
| feedback-timing | ≤ 50ms (반전 피드백) | Macintosh 클릭 반응 시간 실측 | A |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1982-1984 | Macintosh 초기 개발 | 32×32 1-bit, Chicago 폰트, 핵심 아이콘 50개+ 설계 |
| 1984-1986 | Macintosh 출시 후 확장 | 패턴 라이브러리 38종, 커서 세트 완성 |
| 1986-1989 | NeXT 이동 | 고해상도 회색조 아이콘 도입, 48×48 그리드 |
| 1990-2010 | 프리랜서/다양한 클라이언트 | 컬러 아이콘, 벡터 전환, 해상도 독립 |
| 2015-현재 | Pinterest + 아트 활동 | 픽셀 아트를 순수 예술로 확장, 대형 캔버스 작업 |

## 영향 관계

- **모자이크/자수/점묘화 → Kare**: 그리드 기반 이미지 제작 전통
- **Kare → macOS/iOS 아이콘**: 메타포 기반 아이콘 디자인 DNA (폴더, 휴지통, 문서)
- **Kare → Windows**: Solitaire 카드 디자인, Windows 3.0 아이콘 체계
- **Kare → 이모지**: 32×32 비트맵 표현 기법이 초기 이모지 설계에 영향
- **Kare → 픽셀 아트 장르**: 제약 기반 디자인의 미학적 가치 입증
- **주요 참고 문헌**: "Susan Kare Icons" (MOMA 소장), Andy Hertzfeld "Revolution in the Valley" (2004)

## UI 적용 매핑

| Kare 원칙 | 현대 UI 토큰 변환 규칙 |
|----------|----------------------|
| 32×32 그리드 | SF Symbols 기준 — Small(20pt), Medium(25pt), Large(30pt) |
| 1-bit 명확성 | 아이콘 = 단색으로도 인식 가능, `currentColor` 활용 |
| 메타포 기반 | 아이콘 = 실세계 대응물, `accessibility-label` 필수 |
| 픽셀 퍼펙트 | `image-rendering: pixelated` (레트로), 현대는 벡터 SVG |
| 반전 피드백 | 선택 상태 = 배경색·전경색 반전, `.tint(.accentColor)` |
| 패턴 시스템 | 상태 구분 = 패턴(줄무늬=비활성, 단색=활성, 점=진행중) |
| 친근한 형태 | 아이콘 모서리 약간 둥글림, `border-radius: 4-8px` |
| 시각 보정 | 아이콘 정렬 시 수학적 중심이 아닌 시각적 중심 사용 |
| 제약=창의 | 아이콘 크기 제약 내 최대 표현력 추구, `@1x` 기준 설계 |
| 애니메이션 최소 | 상태 전환 = 2-4프레임, `prefers-reduced-motion` 존중 |
