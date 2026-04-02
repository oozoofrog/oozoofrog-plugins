# Mike Matas -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 2004-현재, 핵심기 2007-2014 (Apple → Push Pop Press → Facebook Paper)
- **주요 소속**: Apple(2004-2009, iPhone 초기 UI), Push Pop Press 공동 창립(2010-2011), Facebook(2011-2018, Paper), Discord(VP Design)
- **핵심 공헌**: iPhone 초기 UI 디자인, "Our Choice" 인터랙티브 전자책, Facebook Paper(2014), 물리 기반 인터랙션 시스템, 제스처 드리븐 내비게이션
- **디자인 계보**: Apple 스큐어모피즘 → 물리 기반 인터랙션 → 제스처 중심 UI → 소셜 미디어 콘텐츠 경험

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | UI 메트릭 |
|------|----------|----------|
| 물리 기반 모션 | 모든 전환에 스프링/관성 물리 적용 | 선형 애니메이션 0% |
| 제스처 우선 | 핵심 동작의 80%+ 제스처로 수행 | 버튼 탭 최소화 |
| 콘텐츠 몰입 | 크롬(UI 장식) ≤ 5% | 콘텐츠 영역 95%+ |
| 연속적 조작감 | 입력-반응 지연 ≤ 16ms (60fps) | 프레임 드롭 0 |
| 촉각적 피드백 | 모든 제스처에 시각+햅틱 반응 | 무반응 인터랙션 0개 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| content-fullbleed | 콘텐츠 = 화면 100% (마진 0) | Facebook Paper 레이아웃 분석 | S |
| card-ratio | 16:9 (콘텐츠 카드), 4:3 (이미지) | Paper 카드 비율 실측 | A |
| card-stack-gap | 8pt (축소 상태), 0pt (확장 상태) | Paper 카드 스택 간격 분석 | A |
| parallax-ratio | 전경:배경 이동 비율 = 1:0.3-0.5 | Paper/Push Pop Press 패럴랙스 실측 | A |
| tilt-parallax | ±15° 기울기 → ±10pt 시각 이동 | Paper 모션 패럴랙스 분석 | B |
| edge-gesture-zone | 화면 가장자리 20pt 영역 | Paper 엣지 스와이프 감지 영역 | A |
| chrome-ratio | ≤ 5% (네비게이션 바 최소화/숨김) | Paper UI 크롬 면적 분석 | A |
| grid-base | 8pt (기본 단위) | Paper 레이아웃 그리드 분석 | B |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| font-family | 시스템 서체 (SF Pro / Roboto) | Paper 서체 선택 — 플랫폼 네이티브 | A |
| font-size-headline | 28-36pt Bold (콘텐츠 제목) | Paper 기사 제목 크기 실측 | A |
| font-size-body | 17-19pt Regular (본문) | Paper 기사 본문 크기 실측 | A |
| font-size-caption | 12-13pt (메타데이터, 타임스탬프) | Paper 보조 텍스트 크기 | A |
| line-height | 1.4-1.5 (본문, 읽기 최적화) | Paper 본문 행간 실측 | A |
| text-max-width | 540pt (읽기 최적화 줄 길이) | Paper 본문 최대 너비 분석 | B |
| text-animation | 텍스트 = 모션 대상 (스케일+페이드) | Paper 텍스트 전환 효과 분석 | A |
| font-weight-range | Regular(400)-Bold(700), 2종 중심 | Paper 서체 웨이트 분석 | A |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| background-content | 콘텐츠 이미지 = 배경 (풀블리드) | Paper 이미지 중심 디자인 | S |
| overlay-gradient | 하단 → 상단 선형 그래디언트, #000 60% → 0% | Paper 텍스트 가독성 오버레이 | A |
| text-on-image | #FFFFFF 100% (이미지 위 텍스트) | Paper 텍스트 컬러 — 이미지 위 흰색 전용 | A |
| blur-background | 가우시안 블러 radius 20-40pt | Paper 배경 블러 효과 | A |
| card-shadow | offset(0, 2), blur(8), #000 15% | Paper 카드 그림자 값 | B |
| surface-depth | 3단계 (배경이미지 → 카드 → 오버레이) | Paper 깊이 구조 분석 | A |
| status-bar-blend | 배경과 연속적 블렌딩 (투명 상태바) | Paper 상태바 처리 | A |
| vibrant-text | 배경 블러 위 하이콘트라스트 텍스트 | Paper 텍스트 가독성 전략 | A |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| corner-radius-card | 12-16pt (continuous corner) | Paper 카드 곡률 실측 | A |
| corner-radius-button | 전체 높이의 50% (pill shape) | Paper 버튼 형태 — 완전 둥근 알약형 | A |
| card-edge | 얇은 1px 구분선 또는 그림자만 | Paper 카드 경계 처리 | A |
| image-crop | 중심 크롭 (center-fill) 기본 | Paper 이미지 크롭 규칙 | A |
| icon-style | 선형(outline), 균일 2pt 선폭 | Paper 아이콘 스타일 분석 | A |
| gesture-indicator | 얇은 5pt × 36pt 핸들 바 (하단 시트) | Paper 스와이프 핸들 실측 | B |
| shape-morph | 카드 → 풀스크린 형태 변환 (radius 변화) | Paper 카드 확장 애니메이션 | S |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| spring-response | 0.3-0.5s (response parameter) | Paper 스프링 애니메이션 분석 | A |
| spring-damping | 0.7-0.85 (약간 탄성 있는 정지) | Paper 스프링 감쇠 값 분석 | A |
| spring-bounce | velocity 기반 — 플릭 속도에 비례 | Paper 물리 기반 바운스 | A |
| gesture-velocity-threshold | 500pt/s (빠른 스와이프 인식) | Paper 제스처 속도 임계값 | A |
| gesture-dismiss-threshold | 화면 높이의 30% 드래그 시 dismiss | Paper 카드 닫기 임계값 | A |
| pan-to-dismiss | 하방 팬 → 카드 축소 + 배경 노출 | Paper 인터랙티브 dismiss 패턴 | S |
| rubber-band-factor | 오버스크롤 시 입력의 1/3 반영 | Paper 러버밴드 효과 계수 | A |
| momentum-deceleration | 0.998 (자연스러운 관성 감속) | Paper 스크롤 관성 값 | A |
| tilt-response | ≤ 16ms (가속도계 → 패럴랙스 반영) | Paper 기울기 반응 시간 | A |
| flip-animation | 0.4-0.6s (페이지 넘김 스프링) | Push Pop Press 페이지 전환 | A |
| pinch-to-open | 핀치 아웃 → 이미지 확장 (1:1 스케일 추적) | Paper 이미지 핀치 줌 | S |
| frame-rate | 60fps 필수 (드롭 시 인터랙션 품질 저하) | Paper 렌더링 성능 기준 | S |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 2004-2009 | Apple iPhone 초기 UI | 스큐어모피즘 텍스처, 관성 스크롤 기본 물리 확립 |
| 2010-2011 | Push Pop Press "Our Choice" | 인터랙티브 전자책 — 핀치/회전/틸트 제스처 조합 |
| 2012-2014 | Facebook Paper | 물리 기반 애니메이션 엔진(Pop), 제스처 드리븐 네비게이션 |
| 2015-2018 | Facebook 인터랙션 확장 | Paper 물리 엔진이 Facebook 앱 전체에 영향 |
| 2019-현재 | Discord + 독립 프로젝트 | 소셜 플랫폼 인터랙션 디자인 적용 |

## 영향 관계

- **Apple 관성 스크롤 → Matas**: iPhone 초기 물리 기반 스크롤의 DNA 흡수
- **Matas → Facebook Pop 라이브러리**: Paper용 물리 애니메이션 엔진 → 오픈소스 공개
- **Matas → iOS 인터랙션 패턴**: Paper의 제스처 패턴이 iOS 7+ 엣지 스와이프 등에 영향
- **Matas → 인터랙티브 미디어**: Push Pop Press가 Apple Books 인터랙티브 기능에 영향
- **Matas → SwiftUI 애니메이션**: `.spring()` 기반 애니메이션 API 설계에 Paper DNA 반영
- **주요 참고**: Facebook Paper (2014), Pop Animation Engine (GitHub), Push Pop Press "Our Choice" TED 발표

## UI 적용 매핑

| Matas 원칙 | 현대 UI 토큰 변환 규칙 |
|-----------|----------------------|
| 물리 기반 모션 | `.animation(.spring(response: 0.4, dampingFraction: 0.8))` — 선형 금지 |
| 제스처 우선 | `DragGesture`, `MagnificationGesture` 조합 — 버튼 최소화 |
| 콘텐츠 풀블리드 | `.ignoresSafeArea()`, 이미지 = 화면 100% 채움 |
| 인터랙티브 dismiss | `.interactiveDismissDisabled(false)` + 드래그 임계값 30% |
| 러버밴드 효과 | `ScrollView` 오버스크롤 바운스 + 1/3 감속 |
| 패럴랙스 깊이 | `GeometryReader` + 스크롤 오프셋 × 0.3-0.5 배율 |
| 60fps 필수 | `CADisplayLink`, Metal 렌더링, 무거운 효과 `drawingGroup()` |
| 속도 기반 전환 | 플릭 속도 ≥ 500pt/s → 자동 전환, < 500pt/s → 위치 기반 판단 |
| 카드 → 풀스크린 | `.matchedGeometryEffect` + corner radius 애니메이션 |
| 틸트 반응 | `CMMotionManager` → ±10pt 시각 패럴랙스 |
