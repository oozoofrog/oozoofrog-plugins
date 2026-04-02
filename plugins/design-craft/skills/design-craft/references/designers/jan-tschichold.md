# Jan Tschichold -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1925-1974, 핵심기 1925-1935 (신타이포그래피), 1947-1967 (Penguin Books)
- **주요 소속**: 뮌헨 인쇄학교 교수, Penguin Books 타이포그래피 디렉터(1947-1949)
- **핵심 공헌**: "Die neue Typographie"(1928), "Typographische Gestaltung"(1935), Penguin Books 그리드 표준화, Sabon 서체 디자인(1967)
- **디자인 계보**: 바우하우스 영향 → 신타이포그래피 창시 → 전통 타이포그래피 회귀 (드문 U턴)

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 비대칭 레이아웃 (초기) | 중심축 0%, 비대칭 배치 100% | 좌측 정렬 기본 |
| 황금 단면 (후기) | 페이지 비율 2:3, 텍스트 영역 비율 황금비 | 콘텐츠 영역 61.8% |
| 기능적 타이포그래피 | 장식 서체 0개 (초기), 기능적 세리프 허용 (후기) | 서체 수 ≤ 2 |
| 위계적 명확성 | 크기 대비 ≥ 1.5배 (제목 vs 본문) | 시각 위계 3단계 이내 |
| 여백의 비례 | 내측:상단:외측:하단 = 2:3:4:6 | 마진 비례 규칙 적용 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| page-ratio | 2:3 (황금 단면 근사) | "Die neue Typographie" (1928) p.145 | S |
| margin-inner | 전체 폭의 1/9 | Tschichold 황금 단면 규칙 (Van de Graaf 캐논 변형) | S |
| margin-top | 전체 높이의 1/9 | Tschichold 마진 비례 체계 | S |
| margin-outer | inner의 2배 (전체 폭의 2/9) | Tschichold 마진 비례 체계 | S |
| margin-bottom | top의 2배 (전체 높이의 2/9) | Tschichold 마진 비례 체계 | S |
| text-area-ratio | 전체 면적의 약 44.4% (1/9 마진 기준) | 황금 단면 계산값 | A |
| asymmetric-axis | 중심에서 좌측 1/3 지점 (초기 작업) | "Die neue Typographie" 레이아웃 분석 | A |
| penguin-grid | 4단 수평 분할 + 3열 | Penguin Composition Rules (1947) | S |
| penguin-margin | 상하좌우 균등 3/4인치(19mm) | Penguin Composition Rules | S |
| grid-base-ui | 4pt 또는 8pt (디지털 변환) | Tschichold 비례 체계의 UI 스케일링 | F |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family-early | 산세리프만 (Akzidenz-Grotesk, Futura) | "Die neue Typographie" (1928) 선언 | S |
| font-family-late | 세리프 허용 (Garamond, Bembo, Sabon) | Penguin Books 서체 선택 (1947-49) | S |
| font-sabon | Sabon (1967) — Garamond 현대화 | Tschichold 직접 설계 서체 | S |
| font-size-body | 10-12pt (인쇄 본문) | Penguin Composition Rules | S |
| font-size-ratio | 제목:본문 = 1.5:1 ~ 2:1 | "Typographische Gestaltung" (1935) | A |
| line-height | 본문 크기의 120-140% (자동 행간) | Penguin Composition Rules 행간 규정 | S |
| line-length | 60-70자/줄 (영문 기준) | Tschichold 가독성 규칙 | S |
| letter-spacing-caps | 대문자 조판 시 +5-10% 자간 확대 | "Die neue Typographie" 대문자 규칙 | S |
| text-align-early | 좌측 정렬(flush left, ragged right) | "Die neue Typographie" 비대칭 원칙 | S |
| text-align-late | 양쪽 정렬(justified) 허용 | Penguin Books 본문 조판 | S |
| orphan-widow | 최소 2줄 (고아줄/과부줄 금지) | Penguin Composition Rules | S |
| font-size-ui | 14-16pt (본문), 21-24pt (제목) | 비례 체계의 UI 변환 | F |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| palette-early | 흑·백·빨강 3색 체계 | "Die neue Typographie" 포스터 분석 | S |
| red-accent | 빨강 = 강조 전용 (면적 10-20%) | Tschichold 초기 포스터 컬러 분석 | A |
| penguin-orange | #FF6600 근사 (Penguin 주황) | Penguin Books 표지 컬러 (1935-) | A |
| penguin-color-code | 주황=소설, 녹색=추리, 파랑=전기 | Penguin Books 장르 컬러 시스템 | S |
| background | 순백(#FFFFFF) — 인쇄 기본 | 인쇄 타이포그래피 전통 | A |
| color-count | 2-3색/페이지 (흑 + 악센트 1-2) | Tschichold 컬러 절제 원칙 | A |
| contrast-ratio | 최소 10:1 (흑자/백지 인쇄) | 인쇄 타이포그래피 가독성 기준 | A |
| surface | 무광 종이 질감, 디지털은 단색 flat | Tschichold 인쇄 매체 기반 | D |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius | 0px (직각) | Tschichold 기하학적 형태 원칙 | A |
| rule-weight | 0.5-2pt 수평선/수직선 | Tschichold 인쇄 규선(rule) 분석 | A |
| form-vocabulary | 직선, 직사각형, 원 — 3종 | "Die neue Typographie" 기하학 원칙 | S |
| diagonal-use | 대각선 = 시선 유도 (초기 작업 30%+) | Tschichold 초기 포스터 구성 분석 | A |
| border | 없음 또는 0.5pt hairline | Penguin Books 구분선 분석 | A |
| penguin-frame | 3중 프레임(외곽선-간격-내곽선) | Penguin Books 표지 디자인 (1947-49) | S |
| icon-style | 사용 최소화 — 타이포그래피로 대체 | Tschichold 텍스트 우선 원칙 | A |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| transition-duration | 0.2-0.3s (차분한 전환) | 인쇄 기반 정적 철학의 UI 해석 | F |
| animation | 없음 — 텍스트 중심 정적 레이아웃 | Tschichold 인쇄 매체 기반 | D |
| page-turn | 페이지 전환 = 단순 컷 또는 슬라이드 | 책 페이지 넘김의 디지털 변환 | F |
| reading-flow | 좌→우, 상→하 자연 흐름 준수 | Tschichold 가독성 원칙 | S |
| scroll-behavior | 부드러운 연속 스크롤 (책 스크롤 비유) | 인쇄 텍스트의 디지털 변환 | F |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1925-1933 | 신타이포그래피 시기 | 비대칭 100%, 산세리프만, 빨강·흑 2색, 대각선 활용 |
| 1933-1946 | 나치 탄압 → 스위스 망명 | 전통 타이포 회귀 시작, 세리프 재도입 |
| 1947-1949 | Penguin Books 재정비 | 500+ 표지 표준화, 그리드 체계 확립, 양쪽 정렬 채택 |
| 1950-1967 | 고전주의 성숙기 + Sabon 설계 | 황금 단면 비율 엄수, 서체 디자인 직접 수행 |
| 1967-1974 | 만년 — 원칙 종합 | 초기 아방가르드와 후기 고전의 통합 시도 |

## 영향 관계

- **바우하우스 → Tschichold**: Moholy-Nagy, El Lissitzky의 구성주의 타이포그래피
- **Tschichold → 스위스 타이포그래피**: Müller-Brockmann, Emil Ruder가 신타이포그래피 계승
- **Tschichold → Penguin Books**: 대중 출판 타이포그래피 표준의 원형
- **Tschichold → Robert Bringhurst**: "Elements of Typographic Style"에 Tschichold 비례 체계 인용
- **Tschichold → 웹 타이포그래피**: 행간·자간·줄 길이 규칙이 CSS 타이포 가이드라인의 기반
- **주요 참고 문헌**: "Die neue Typographie" (1928), "Typographische Gestaltung" (1935), "The Form of the Book" (1975)

## UI 적용 매핑

| Tschichold 원칙 | 현대 UI 토큰 변환 규칙 |
|----------------|----------------------|
| 비대칭 레이아웃 | `text-align: left`, 좌측 정렬 기본, 중앙 정렬 제목만 |
| 황금 단면 마진 | padding 비율 `inner:top:outer:bottom = 2:3:4:6` |
| 60-70자 줄 길이 | `max-width: 65ch`, `line-height: 1.4` |
| 2-3색 제한 | CSS 변수 3개 — `--text`, `--bg`, `--accent` |
| 서체 2종 체계 | `font-family` 산세리프 1 + 세리프 1 (또는 산세리프 단독) |
| 고아줄/과부줄 금지 | `orphans: 2; widows: 2` |
| 기하학적 형태 | `border-radius: 0`, 직선·직각 기반 |
| 위계적 크기 대비 | 제목 `1.5-2em`, 본문 `1em`, 캡션 `0.875em` |
| 색상 = 기능 | 빨강/악센트 = CTA·경고, 흑 = 본문, 회색 = 보조 |
| 정적 읽기 경험 | 콘텐츠 영역 애니메이션 0개, `content-visibility: auto` |
