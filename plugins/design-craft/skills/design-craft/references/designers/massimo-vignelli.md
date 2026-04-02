# Massimo Vignelli -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1954-2014, 핵심기 1965-1990 (Vignelli Associates)
- **주요 소속**: Unimark International 공동 창립(1965), Vignelli Associates(1971-2014)
- **핵심 공헌**: NYC 지하철 사인 시스템(1972), American Airlines 로고(1967), Knoll 가구 아이덴티티, IBM 그래픽 표준, National Park Service Unigrid 시스템, Bloomingdale's 쇼핑백
- **디자인 계보**: 밀라노 폴리테크니코 → 스위스 모더니즘 → 미국 기업 아이덴티티 체계화

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 서체는 6개면 충분 | 서체 수 ≤ 6종 (실제 사용 3종 이하) | 앱 전체 폰트 패밀리 ≤ 3 |
| 그리드는 절대적 | 모든 요소 그리드 정렬률 100% | 비정렬 요소 0개 |
| 의미 있는 형태 (Semantics) | 형태-기능 일치율 100% | 장식 전용 요소 0개 |
| 시각적 힘 (Visual Power) | 대비 비율 최소 4.5:1 | WCAG AA 이상 |
| 영속성 (Timelessness) | 트렌드 의존 요소 0% | 5년 후 시각 노후화 0% |
| 질서 (Discipline) | 정렬축 일관성 100% | 수직·수평축 최대 3개/화면 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| grid-system | 2열, 3열, 6열 분할 (6의 배수 기반) | "The Vignelli Canon" (2010) p.44 | S |
| unigrid | 12-unit 그리드, 10개 기본 포맷 | National Park Service Unigrid System (1977) | S |
| margin-ratio | 전체 면적의 10-15% | Vignelli Canon 레이아웃 분석 | A |
| column-gutter | 컬럼 폭의 1/12 ~ 1/8 | Vignelli Canon 그리드 시스템 | A |
| content-area | 85-90% (마진 제외 콘텐츠 영역) | Vignelli Associates 프로젝트 실측 | B |
| alignment-axes | 수직·수평 정렬축 최대 3개/면 | Vignelli Canon p.36 | S |
| modular-scale | 기본 단위의 정수배만 허용 | Vignelli Canon 그리드 원칙 | S |
| grid-base-ui | 8pt (디지털 변환) | Vignelli 6단위 그리드의 UI 스케일링 | F |
| hierarchy-levels | 최대 3단계 (대제목-소제목-본문) | Vignelli Canon p.52 타이포 위계 | S |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family-primary | Helvetica (산세리프 기본) | Vignelli Canon p.54 "6 typefaces" | S |
| font-family-serif | Bodoni (세리프 기본), Garamond | Vignelli Canon p.54 | S |
| font-family-count | ≤ 6종 (실무 2-3종) | "The Vignelli Canon" 선언 | S |
| font-weight | Light(300), Regular(400), Bold(700) — 3종 | Vignelli 타이포 체계 | A |
| font-size-scale | 기본 크기의 1.5배, 2배, 3배 (단순 정수배) | Vignelli Canon p.56 | A |
| line-height | 1.2-1.4 (타이트한 행간) | NYC 지하철 사인 실측 | B |
| letter-spacing | 표준 (0) ~ 약간 넓음 (+2%) | Vignelli 인쇄물 분석 | B |
| text-transform | 대문자(uppercase) 선호 — 사인 시스템 | NYC 지하철 사인 분석 (Helvetica 대문자) | S |
| subway-sign-size | 역명 높이 4인치(10.2cm), 방향 표시 2인치 | NYC Transit Authority 매뉴얼 (1970) | S |
| font-size-ui | 14-16pt (본문), 24-32pt (제목) | 8pt 그리드 기반 UI 변환 | F |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| palette-subway | 흑(#000), 백(#FFF), 빨강·파랑·녹색·노랑·주황·갈색·보라·회색 | NYC 지하철 노선 컬러 체계 (1972) | S |
| color-functional | 색상 = 노선/카테고리 구분 용도 | NYC 지하철 컬러 코딩 시스템 | S |
| accent-count | 카테고리당 1색, 전체 ≤ 8색 | NYC 지하철 노선 컬러 분석 | S |
| background | 순백(#FFFFFF) 또는 순흑(#000000) | Vignelli 포스터/인쇄물 배경 | A |
| contrast-ratio | 최소 7:1 (사인 시스템) | NYC 지하철 사인 가독성 기준 | A |
| color-count-per-layout | 3-4색 (흑·백 + 악센트 1-2) | Vignelli Canon 컬러 원칙 | A |
| surface | 무광 단색, 텍스처 없음 | Vignelli "flat color" 원칙 | A |
| gradient | 사용 안 함 — 단색 면 분할 | Vignelli 포스터 분석 | A |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius | 0px (완전 직각) | Vignelli 그리드 기반 직선 형태 | A |
| form-geometry | 직사각형 95%+, 원형 ≤ 5% | Vignelli 포스터/사인 형태 분석 | A |
| icon-style | 기하학적 단순 형태, 최소 선 | NYC 지하철 픽토그램 | A |
| line-weight | 균일 두께, 1-2pt @1x | Vignelli 사인 시스템 선 분석 | B |
| shape-vocabulary | 사각형, 원, 삼각형 — 3종 기본 형태만 | Vignelli Canon p.30 | S |
| aspect-ratio | A 시리즈(1:√2 = 1:1.414) 선호 | Vignelli Canon p.44 "A paper sizes" | S |
| border | 0px 또는 1px 실선 — 2종만 | Vignelli 레이아웃 경계 분석 | A |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| transition-duration | 0.15-0.2s (절제된 전환) | Vignelli "영속적 디자인" 원칙 UI 해석 | F |
| animation | 없음 — 정적 레이아웃 우선 | Vignelli 인쇄 매체 기반 철학 | D |
| hover-feedback | 색상 반전 (흑↔백) | Vignelli 고대비 원칙의 인터랙션 변환 | F |
| state-indicator | 색상 변경만 — 형태 변형 없음 | Vignelli "형태 일관성" 원칙 해석 | F |
| scroll-behavior | 페이지 단위 스냅 스크롤 | 그리드 기반 페이지 레이아웃 해석 | F |
| wayfinding | 색상 코딩 + 방향 화살표 | NYC 지하철 사인 시스템 | S |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1954-1964 | 밀라노 교육기 → 미국 이주 | 유럽 스위스 스타일 흡수, Helvetica 채택 |
| 1965-1970 | Unimark International 창립 | 기업 아이덴티티 체계 확립, NYC 지하철 프로젝트 착수 |
| 1971-1980 | Vignelli Associates 독립 | Unigrid 시스템, 12단위 그리드 확립, 대문자 사용 일관화 |
| 1981-2000 | 성숙기 — 가구·제품까지 확장 | 3D 영역으로 그리드 확장, 형태 어휘 3종 고정 |
| 2001-2014 | 디지털 전환기 + Canon 발표(2010) | 원칙을 디지털 매체로 재해석, 2010 Vignelli Canon 공개 |

## 영향 관계

- **스위스 타이포그래피 → Vignelli**: Max Miedinger(Helvetica), Emil Ruder(타이포그래피 교육)
- **Müller-Brockmann → Vignelli**: 스위스 그리드 체계를 미국 기업 환경에 이식
- **Vignelli → NYC 지하철**: 세계 최대 규모 공공 사인 시스템 표준화
- **Vignelli → Michael Bierut**: Pentagram 파트너로서 Vignelli 방법론 계승
- **Vignelli → Material Design**: 그리드 엄수, 제한된 서체, 기능적 색상 체계의 DNA
- **주요 참고 문헌**: "The Vignelli Canon" (Massimo Vignelli, 2010), "Design: Vignelli" (2014)

## UI 적용 매핑

| Vignelli 원칙 | 현대 UI 토큰 변환 규칙 |
|--------------|----------------------|
| 6 서체 법칙 | `font-family` 변수 ≤ 3개, 시스템 서체 + 1 웹폰트 |
| 절대적 그리드 | `display: grid`, 12-column 레이아웃, 모든 요소 그리드 스냅 |
| A 비율 선호 | 카드/모달 비율 `1:1.414`, `aspect-ratio: 1 / 1.414` |
| 기능적 색상 | 색상 = 카테고리/상태 의미, 장식적 색상 0개 |
| 고대비 텍스트 | `color: #000; background: #FFF` — 대비 21:1, WCAG AAA |
| 완전 직각 | `border-radius: 0`, 둥글림 일체 없음 |
| 대문자 제목 | `text-transform: uppercase` + `letter-spacing: 0.05em` |
| Unigrid 시스템 | 반응형 12-column 그리드, 브레이크포인트 3단계 |
| 정적 레이아웃 | 불필요한 애니메이션 0개, `prefers-reduced-motion` 존중 |
| 웨이파인딩 | 탭바·사이드바에 컬러 코딩 적용, 아이콘+텍스트 병용 |
