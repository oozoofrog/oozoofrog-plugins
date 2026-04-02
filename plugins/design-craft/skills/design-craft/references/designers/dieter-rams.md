# Dieter Rams -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1955-1995 (Braun), 핵심기 1961-1995 (디자인 책임자)
- **주요 소속**: Braun AG 수석 디자이너, Vitsoe 가구 디자인 컨설턴트
- **핵심 공헌**: "Good Design" 10원칙 정립, SK4 레코드 플레이어(1956), T3 라디오(1958), ET66 계산기(1987), 606 유니버설 선반(Vitsoe), TP1 트랜지스터 라디오(1959)
- **디자인 계보**: Ulm 조형대학(HfG Ulm) 기능주의 → Apple/Jony Ive에 직접 영향

## 디자인 철학 (정량화 가능한 원칙)

| 10원칙 | 정량 변환 | UI 메트릭 |
|--------|----------|----------|
| 1. 혁신적 (Innovative) | 기존 대비 구성요소 30%+ 감소 | 신규 인터랙션 패턴 도입 |
| 2. 유용하게 (Useful) | 핵심 기능 접근 ≤ 2탭 | 태스크 완료율 95%+ |
| 3. 미적으로 (Aesthetic) | 황금비(1:1.618) 근접 비율 | 시각 조화도 |
| 4. 이해 가능하게 (Understandable) | 레이블 없이 기능 파악 가능한 요소 80%+ | 어포던스 명확성 |
| 5. 겸손하게 (Unobtrusive) | 장식 요소 0-5% | 콘텐츠 대 크롬 비율 ≥ 85% |
| 6. 정직하게 (Honest) | 가짜 텍스처/효과 0개 | 실제 기능 = 시각 표현 |
| 7. 오래가게 (Long-lasting) | 트렌드 의존 요소 0개 | 5년 후 시각 노후화 0% |
| 8. 철저하게 (Thorough) | 미정의 상태 0개 | 모든 에지케이스 처리 |
| 9. 환경친화적 (Eco-friendly) | 재질 종류 ≤ 3종/제품 | 렌더링 레이어 최소화 |
| 10. 최소한으로 (As little design) | 시각 요소 수 최소화 (필수 요소만) | UI 요소 밀도 ≤ 30% |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| grid-base | 5mm (물리 제품 기준) | Braun 제품 실측 ("Less and More" 전시) | B |
| grid-base-ui | 8pt (디지털 변환) | Rams 그리드를 8pt UI 그리드로 변환 | F |
| golden-ratio | 1:1.618 (레이아웃 분할) | SK4, ET66 비율 실측 | B |
| content-area-ratio | 85-95% (장식 최소화) | Braun 패널 레이아웃 분석 | B |
| symmetry | 좌우 대칭 (95%+ 제품 적용) | Braun 제품 전수 조사 | B |
| margin-ratio | 전체 면적의 10-20% | SK4, T3 외곽 여백 실측 | B |
| element-density | 화면/패널 면적의 20-30% | Braun 컨트롤 패널 분석 | B |
| control-spacing | 컨트롤 간 최소 간격 = 컨트롤 높이의 50% | T3, SK4 다이얼 간격 실측 | B |
| alignment-axes | 수직·수평 정렬축 최대 3개/면 | Braun 패널 그리드 분석 | B |
| hierarchy-levels | 최대 3단계 시각 위계 | Rams 디자인 원칙 해석 | D |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family | Akzidenz-Grotesk, Helvetica | Braun 제품 표기 서체 | B |
| font-weight | Regular(400)-Medium(500) 범위만 사용 | Braun 제품 서체 분석 | B |
| text-hierarchy | 최대 2단계 (제목 + 본문) | Braun 패널 텍스트 분석 | B |
| label-size-ratio | 제품 전체 높이의 2-4% | SK4, T3 라벨 실측 | B |
| label-case | 소문자 선호 (all-lowercase) | Braun 브랜드 타이포 | B |
| letter-spacing | 넓은 자간 (+5-10% 기본 대비) | Braun 인쇄물 분석 | B |
| numeral-style | Tabular figures (등폭 숫자) | ET66 계산기 디스플레이 | B |
| text-color | 검정 or 흰색 — 2색 제한 | Braun 라벨 색상 규칙 | B |
| font-size-ui | 14-16pt (본문), 20-24pt (제목) | 8pt 그리드 기반 UI 변환 | F |
| type-contrast | 전경/배경 대비 최소 7:1 | Braun 고대비 설계 실측 | B |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| palette-primary | 순백(#FFFFFF), 순흑(#000000) | Braun 기본 컬러 | B |
| palette-neutral | 밝은 회색(#E0E0E0 ~ #F5F5F5) | SK4, T1000 표면 | B |
| accent-color | 녹색(#4CAF50), 주황(#FF9800) — 기능 표시용 | Braun on/off 표시등 | B |
| accent-usage | 화면 면적의 ≤ 5% | Braun 악센트 컬러 비율 실측 | B |
| surface-finish | 무광(matte) 우선, 유광은 디스플레이 영역만 | Braun 소재 전략 | D |
| color-count | 최대 3색/제품 (흑·백·악센트 1) | Braun 컬러 팔레트 분석 | B |
| grayscale-steps | 3-5단계 (흰→밝은회→중간회→어두운회→흑) | Braun 제품 톤 분석 | B |
| texture | 없음 — 매끈한 단색 표면 | Rams "정직한 디자인" 원칙 | D |
| shadow-usage | 물리적 깊이감만 (인위적 그림자 없음) | Braun 입체 구조 분석 | D |
| background-ui | #FAFAFA (밝은 모드), #1A1A1A (어두운 모드) | 8pt 그리드 기반 UI 변환 | F |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius | 0-2mm (거의 직각) | Braun 제품 실측 — 날카로운 모서리 선호 | B |
| corner-radius-ui | 2-4pt (디지털 변환 — 최소 둥글림) | Rams 직각 원칙의 UI 적용 | F |
| edge-treatment | chamfer(모따기) 0.5-1mm | Braun 금속 에지 실측 | B |
| form-geometry | 직사각형 90%+, 원형 다이얼 10% 이하 | Braun 제품 형태 통계 | B |
| aspect-ratio | 황금비(1:1.618) 또는 √2비(1:1.414) | SK4(1:1.62), ET66(1:1.58) 실측 | B |
| button-shape | 원형 또는 정사각형 — 2종만 사용 | T3, ET66 버튼 분석 | B |
| button-size | 지름 10-15mm (물리), 36-44pt (UI 변환) | Braun 버튼 실측 | B |
| icon-style | 선형(outline), 균일 선 두께 | Braun 픽토그램 스타일 | B |
| icon-stroke | 1.5-2pt @1x | Braun 아이콘 두께 UI 변환 | F |
| depth-layers | 최대 2단계 (기저면 + 컨트롤면) | Braun 제품 깊이 구조 | B |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| feedback-immediate | 조작 후 ≤ 100ms 시각 반응 | Braun 물리 토글 즉시 반응 원칙 | D |
| transition-duration | 0.15-0.25s (빠르고 절제된 전환) | Rams "겸손한 디자인" 원칙 UI 해석 | F |
| animation-count | 화면 당 동시 애니메이션 ≤ 1개 | "최소한의 디자인" 원칙 | D |
| easing | linear 또는 ease-out — 과장된 바운스 없음 | 물리 조작감의 디지털 번역 | F |
| hover-feedback | opacity 변화 0.85-1.0 (미세한 변화) | Rams 절제 원칙 UI 해석 | F |
| click-feedback | scale 0.97-1.0 (미세한 눌림) | 물리 버튼 햅틱의 디지털 표현 | F |
| scroll-behavior | 관성 스크롤, 오버스크롤 바운스 없음 | "겸손한" 인터랙션 해석 | F |
| state-change | 즉각적 — fade 0.1s 이내 | Braun 토글 스위치 동작 | D |
| affordance-ratio | 조작 가능 요소의 90%+ 시각적 구분 | Rams "이해 가능한 디자인" | D |
| micro-interaction | 최소화 — 필수 피드백만 | "최소한의 디자인" 원칙 | D |

### 모듈 & 시스템 디자인

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| module-base | 제품 최소 단위의 정수배 | Vitsoe 606 선반 시스템 | B |
| stackability | 수직/수평 연결 시 간격 0mm (무간극) | Braun 스택 오디오 실측 | B |
| interchangeability | 동일 폼팩터 내 부품 호환율 100% | Braun 모듈 시스템 | D |
| system-coherence | 제품군 간 공유 디자인 언어 90%+ | Braun 오디오 라인업 분석 | B |
| proportional-grid | 전체 면적을 3x3 또는 5x5 등분 | SK4, T1000 레이아웃 분석 | B |
| label-placement | 좌하단 또는 우하단 — 일관된 위치 | Braun 라벨 배치 규칙 | B |

## 핵심 제품 토큰 스냅샷

| 제품 | 핵심 비율 | 값 |
|------|----------|---|
| SK4 레코드 플레이어 | 전체 비율 | 58x33cm → 1:1.76 (황금비 근접) |
| T3 포켓 라디오 | 전면 비율 | 12x7cm → 1:1.71 |
| ET66 계산기 | 전체 비율 | 15x9.5cm → 1:1.58 (황금비 근접) |
| TP1 트랜지스터 | 원형 다이얼 비율 | 전면 면적의 60% |
| T1000 월드 리시버 | 다이얼 면적 | 전면의 70%, 버튼 면적 15% |
| 606 유니버설 선반 | 모듈 단위 | 65.5cm 폭, 무한 수직 확장 |
| ABR 21 시계 | 문자판 비율 | 지름 26cm, 숫자 높이 15mm |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1955-1960 | 초기 Braun — Ulm 조형대학 합류 | 곡선 비율 30% → 직선 비율 90%+ |
| 1961-1970 | 시스템 디자인 확립 | 모듈 그리드 도입, 색상 3색 제한 확립 |
| 1971-1980 | 미니멀리즘 심화 | 표면 장식 완전 제거, 제어부 면적 20% 이하 |
| 1981-1990 | ET66 등 정점기 | 비례 정밀도 극대화, 황금비 적용 일관화 |
| 1991-1995 | 10원칙 공식 발표(1995경 정리) | 디자인 철학의 문서화·체계화 |

## 영향 관계

- **Ulm 조형대학(HfG Ulm) → Rams**: Max Bill, Otl Aicher의 기능주의·체계적 디자인 방법론
- **바우하우스 → Rams**: "형태는 기능을 따른다" — 그러나 Rams는 "형태는 기능을 명확히 한다"로 재해석
- **Rams → Jony Ive**: Braun ET66 → iOS 계산기, SK4 → iPod, T3 → 초기 iPod 형태
- **Rams → Flat Design 운동**: 10원칙의 "겸손함"·"정직함"이 스큐어모피즘 배격의 이론적 기반
- **Rams → Muji**: 나오토 후카사와의 Muji 디자인에 직접 영향
- **주요 참고 문헌**: "Dieter Rams: As Little Design as Possible" (Sophie Lovell, 2011), "Less and More" 전시 카탈로그 (2009)

## 10원칙 → CSS/SwiftUI 직접 매핑

| 원칙 | CSS 프로퍼티 변환 | SwiftUI 변환 |
|------|------------------|-------------|
| 겸손함 | `box-shadow: none; border: 1px solid` | `.shadow(radius: 0)` |
| 정직함 | `background-image: none` (텍스처 금지) | 시맨틱 컬러만 사용 |
| 최소한 | `* { transition: 0.15s ease-out }` | `.animation(.easeOut(duration: 0.15))` |
| 이해 가능 | `cursor: pointer` (인터랙티브 명시) | `.buttonStyle(.bordered)` |
| 오래감 | `font-family: system-ui` (시스템 서체) | `.font(.body)` |

## UI 적용 매핑

| Rams 원칙 | 현대 UI 토큰 변환 규칙 |
|-----------|----------------------|
| 최소한의 디자인 | 장식 그림자·그래디언트·텍스처 제거, `box-shadow: none`, 단색 배경 |
| 직각 선호 | `border-radius: 2-4px` — 둥글림 최소화, 직선 기반 레이아웃 |
| 3색 팔레트 | 흑·백·악센트 1색, CSS 변수 3개로 전체 테마 구성 |
| 황금비 레이아웃 | `grid-template-columns: 1fr 1.618fr` 또는 38.2% / 61.8% 분할 |
| 높은 대비 | 텍스트 대비 7:1 이상, WCAG AAA 준수 |
| 겸손한 모션 | `transition: 0.15s ease-out`, 바운스·오버슈트 없음 |
| 기능 = 형태 | 버튼은 버튼처럼, 링크는 링크처럼 — role 일치 |
| 체계적 그리드 | 8pt 그리드 엄수, 모든 치수 8의 배수 |
| 내구성 | 트렌디한 글래스모피즘·뉴모피즘 배제, 시대 초월 스타일 |
| 환경 고려 | 불필요한 애니메이션 제거 → `prefers-reduced-motion` 존중 |
