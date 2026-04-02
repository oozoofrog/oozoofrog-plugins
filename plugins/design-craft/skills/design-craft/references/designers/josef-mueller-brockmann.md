# Josef Müller-Brockmann -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1950-1996, 핵심기 1955-1980
- **주요 소속**: 취리히 응용미술학교 교수, Müller-Brockmann & Co., IBM 유럽 디자인 컨설턴트
- **핵심 공헌**: "Grid Systems in Graphic Design"(1981), Musica Viva 콘서트 포스터(1950s-70s), Zurich Tonhalle 포스터 시리즈, "The Graphic Artist and His Design Problems"(1961)
- **디자인 계보**: 바우하우스 구성주의 → 스위스 인터내셔널 타이포그래피 스타일 확립 → 현대 그리드 시스템의 아버지

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 수학적 그리드 | 모든 요소 그리드 교차점 배치 100% | 비정렬 요소 0개 |
| 객관적 커뮤니케이션 | 장식 요소 0%, 정보 밀도 극대화 | 장식 전용 요소 0개 |
| 기하학적 추상 | 원·사각·삼각 3종 기본 형태 | 유기적 형태 0개 |
| 산세리프 전용 | 세리프 서체 사용 0% | 서체 1종(Akzidenz-Grotesk/Helvetica) |
| 비대칭 균형 | 중심축 대칭 0%, 그리드 기반 비대칭 100% | 좌측/좌상단 정렬 기본 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| grid-columns | 2, 3, 4, 6열 (2·3의 배수) | "Grid Systems" (1981) p.58-74 | S |
| grid-rows | 4, 6, 8행 (2의 배수) | "Grid Systems" p.76-88 | S |
| grid-field | 열×행 교차 = 필드(기본 단위) | "Grid Systems" p.52 | S |
| gutter-width | 필드 폭의 1/10 ~ 1/6 | "Grid Systems" p.62 | S |
| margin-top | 전체 높이의 1/10 ~ 1/8 | "Grid Systems" 마진 규칙 | A |
| margin-bottom | margin-top의 1.5-2배 | "Grid Systems" 하단 여백 규칙 | A |
| margin-outer | 전체 폭의 1/12 ~ 1/8 | "Grid Systems" 측면 여백 | A |
| modular-unit | 텍스트 행 높이(본문 크기 + 행간) = 기본 모듈 | "Grid Systems" p.46 | S |
| multi-grid | 동일 페이지에 2-3종 그리드 중첩 가능 | "Grid Systems" p.90-104 | S |
| poster-ratio | 128×90.5cm (SBB 표준) → 1:1.414 (√2) | 스위스 연방철도 포스터 표준 크기 | S |
| grid-base-ui | 8pt (디지털 변환) | Brockmann 모듈 단위의 UI 스케일링 | F |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family | Akzidenz-Grotesk (1950-60s), Helvetica (1960s-) | Musica Viva 포스터 서체 분석 | S |
| font-family-count | 1종 (단일 서체 패밀리) | Brockmann 단일 서체 원칙 | S |
| font-weight | Light(300), Regular(400), Bold(700) | Musica Viva 포스터 웨이트 분석 | A |
| font-size-scale | 6, 7, 8, 9, 10, 11, 12, 14, 16, 20, 24, 36, 48, 60, 72pt | "Grid Systems" p.42 표준 크기 목록 | S |
| line-height | 본문 크기의 120% (auto) | "Grid Systems" 행간 = 1행의 기본 단위 | S |
| line-length | 7-10단어/줄 (영문), 50-60자/줄 | "Grid Systems" 가독성 규칙 | A |
| text-align | 좌측 정렬(flush left) — 양쪽 정렬 회피 | Brockmann 비대칭 타이포 원칙 | S |
| paragraph-spacing | 1행 높이(=1 모듈 단위) | "Grid Systems" 문단 간격 규칙 | S |
| text-transform | 소문자 기본, 대문자 = 제목/강조 | Musica Viva 포스터 분석 | A |
| font-size-ui | 14-16pt (본문), 24-36pt (제목) | 8pt 그리드 기반 변환 | F |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| palette-poster | 흑, 백, 단색 악센트 1-2색 | Musica Viva 포스터 컬러 분석 | S |
| color-functional | 색상 = 시각적 위계/영역 구분 | Brockmann 포스터 컬러 기능 분석 | A |
| background | 순백(#FFFFFF) 또는 단색 배경 | Brockmann 포스터 기본 배경 | A |
| accent-area | 악센트 색상 면적 ≤ 30% (기하학적 영역) | Musica Viva 포스터 컬러 면적 분석 | A |
| contrast-ratio | 최소 7:1 (텍스트/배경) | 포스터 가독성 — 원거리 판독 기준 | A |
| gradient | 없음 — 단색 면만 사용 | Brockmann 평면 구성 원칙 | S |
| color-count | 2-4색/페이지 (흑·백 포함) | Brockmann 포스터 전수 분석 | A |
| surface | 무광, 텍스처 없음, 순수 색면 | Brockmann 객관적 디자인 원칙 | A |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| form-vocabulary | 원, 직사각형, 삼각형, 직선 — 4종 | Musica Viva 포스터 형태 분석 | S |
| corner-radius | 0px (직각) | Brockmann 기하학적 형태 원칙 | A |
| arc-geometry | 동심원, 균등 분할 호 | Musica Viva "Beethoven" 포스터 분석 | S |
| line-weight | 균일 두께, 0.5-2pt (인쇄) | Brockmann 포스터 선 분석 | A |
| circle-ratio | 원형 면적 = 화면의 20-60% (포스터) | Musica Viva 원형 구성 실측 | A |
| shape-repetition | 동일 형태 반복 5-50회 (리듬 생성) | Musica Viva "der Film" 포스터 분석 | A |
| negative-space | 여백 비율 40-60% | Brockmann 포스터 공백 분석 | A |
| border | 없음 — 형태 자체가 경계 | Brockmann 프레임리스 구성 | A |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| transition-duration | 0.2-0.3s (수학적 정밀함) | Brockmann 체계적 원칙의 UI 해석 | F |
| animation | 기하학적 변형만 (회전, 스케일, 이동) | Brockmann 기하학 어휘의 모션 변환 | F |
| easing | linear (등속) — 자연 곡선 회피 | 수학적 객관성 원칙 해석 | F |
| rhythm | 균등 간격 반복 패턴 | Musica Viva 시각적 리듬 분석 | A |
| hover-feedback | opacity 0.7-1.0 (단순 투명도 변화) | Brockmann 절제 원칙 UI 해석 | F |
| scroll-behavior | 그리드 스냅 스크롤 (필드 단위) | 그리드 시스템의 디지털 변환 | F |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1950-1955 | 초기 포스터 — 구성주의 영향 | 대각선 활용 30%+, 비정형 구성 |
| 1955-1965 | Musica Viva 포스터 전성기 | 원형·동심원 구성 확립, 1-2색 제한 |
| 1966-1981 | 그리드 체계 이론화 | "Grid Systems" 집필, 수학적 그리드 공식 체계화 |
| 1982-1996 | IBM 컨설팅 + 교육 | 기업 CI에 그리드 적용, 디지털 매체 인식 시작 |

## 영향 관계

- **바우하우스/구성주의 → Brockmann**: El Lissitzky, Moholy-Nagy의 기하학적 구성
- **Max Bill → Brockmann**: 취리히 구체예술(Concrete Art)의 수학적 형태
- **Brockmann → Vignelli**: 스위스 그리드 → 미국 기업 아이덴티티 이식
- **Brockmann → CSS Grid/Flexbox**: "Grid Systems"가 웹 그리드 레이아웃의 이론적 기반
- **Brockmann → Material Design**: 8pt 그리드, 모듈 단위, 필드 개념
- **주요 참고 문헌**: "Grid Systems in Graphic Design" (1981), "The Graphic Artist and His Design Problems" (1961)

## UI 적용 매핑

| Brockmann 원칙 | 현대 UI 토큰 변환 규칙 |
|---------------|----------------------|
| 수학적 그리드 | `display: grid; grid-template-columns: repeat(N, 1fr)` — N=2,3,4,6 |
| 모듈 단위 | 모든 간격 8pt 배수, `gap: 8px / 16px / 24px` |
| 단일 서체 | `font-family: system-ui` 단독, 웨이트 3종으로 위계 표현 |
| 좌측 정렬 | `text-align: left` 기본, 중앙/우측 정렬 금지 |
| 기하학적 형태 | `border-radius: 0`, `clip-path: circle()` 또는 `polygon()` |
| 객관적 색상 | 색상 = 영역 구분/위계 기능, 장식 그래디언트 0개 |
| 여백 = 디자인 | `padding` 넉넉히 — 콘텐츠 밀도 ≤ 60% |
| 리듬 반복 | 동일 컴포넌트 반복 배치, `grid-auto-flow: row` |
| √2 비율 | 카드/화면 비율 `1:1.414`, `aspect-ratio: 1 / 1.414` |
| 등속 전환 | `transition-timing-function: linear`, 바운스 없음 |
