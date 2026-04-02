# 충돌 리포트

동일 카테고리에서 디자이너/화가 간 상충하는 토큰 값을 기록한다.

## 해결 전략 범례
- **상위 호환**: 넓은 범위가 좁은 범위를 포함 -> 넓은 범위 채택
- **맥락 분리**: 용도/맥락에 따라 다른 값 적용
- **가중 평균**: 신뢰도 가중치로 중간값 산출
- **variants**: 양립 불가 -> 별도 variant로 병존

## Layout & Spacing

| 토큰 | 디자이너A 값 | 디자이너B 값 | 해결 방식 |
|------|------------|------------|----------|
| base-unit | Ive: 4pt, Kare: 4pt | Rams: 8pt, Vignelli: 8pt, Brockmann: 8pt | **상위 호환** -- 4pt 채택 (8pt는 4pt의 배수) |
| whitespace-ratio | Ive/Brockmann: 40-60% | Lee Ufan: 70-90% | **맥락 분리** -- 표준 UI: 40-60%, 미니멀/명상 UI: 70-90% |
| grid-columns | Brockmann: 2,3,4,6열 | Vignelli: 2,3,6,12열 | **상위 호환** -- 12열 체계 채택 (모든 분할 포함) |
| margin-ratio | Rams: 10-20% | Tschichold: inner:top:outer:bottom = 2:3:4:6 | **맥락 분리** -- 앱 UI: 균등 마진, 독서/인쇄: 비례 마진 |
| content-density | Rams: 요소 밀도 20-30% | Kandinsky: 10-50+개 요소 허용 | **맥락 분리** -- 미니멀 UI: Rams, 대시보드/데이터: Kandinsky |

## Typography

| 토큰 | 디자이너A 값 | 디자이너B 값 | 해결 방식 |
|------|------------|------------|----------|
| font-family-count | Brockmann: 1종 엄수 | Vignelli: 2-3종 | **맥락 분리** -- 유틸리티 UI: 1종, 에디토리얼: 2-3종 |
| text-align | Brockmann/Tschichold(초기): 좌측 정렬만 | Tschichold(후기): 양쪽 정렬 허용 | **맥락 분리** -- UI 본문: 좌측 정렬, 장문 독서: 양쪽 정렬 가능 |
| text-transform | Vignelli: uppercase 선호 | Rams/Brockmann: lowercase 기본 | **맥락 분리** -- 사인/제목: uppercase, 본문/레이블: lowercase |
| font-size-ratio | Tschichold: 제목:본문 = 1.5:1~2:1 | Rand: 2:1~3:1 (강한 대비) | **variants** -- moderate(1.5-2x), bold(2-3x) |
| body-size | Ive: 17pt (iOS) | Norman: 16px (web) | **맥락 분리** -- iOS: 17pt, Web: 16px |

## Color & Surface

| 토큰 | 디자이너A 값 | 디자이너B 값 | 해결 방식 |
|------|------------|------------|----------|
| gradient | Rams/Mondrian/Malevich: 사용 안 함 | Rothko: 수직 그라디언트 필수 | **맥락 분리** -- 구조적 UI: flat 단색, 몰입형 배경: 그라디언트 |
| background-white | Ive: 순백 #FFFFFF | Mondrian: 미색 #F5F5F0, Lee Ufan: 생지 #F5F0E8, Malevich: #F0EDE5 | **variants** -- pure-white(#FFF), warm-white(#F5F0E8), cream(#F0EDE5) |
| dark-bg | Ive/Dye: 순흑 #000000 (OLED) | Rothko: 색조 있는 어둠 #1A1520 | **맥락 분리** -- OLED 절전: 순흑, 일반 다크모드: 색조 있는 어둠 |
| accent-usage | Rams: 5% 이하 | Mondrian: 15-30% | Rand: 30-50% | **맥락 분리** -- 미니멀: 5%, 표준: 15-30%, 브랜드 강조: 30-50% |
| color-count | Rams: 3색 (흑-백-악센트1) | Kandinsky: 최소 3-4색 다색 | **맥락 분리** -- 도구/유틸리티: 3색, 크리에이티브/시각화: 다색 |
| shadow | Rams/Mondrian/Malevich: box-shadow 없음 | Dye/Matas: shadow로 깊이 표현 | **맥락 분리** -- 플랫 구조: 색차로 깊이, 물리적 계층: shadow 허용 |
| surface-warmth | Turrell: 시간대별 색온도 변화 | Ive: 고정 시맨틱 컬러 | **맥락 분리** -- 표준 앱: 고정 시맨틱, 명상/웰니스: 시간 적응형 |

## Shape & Geometry

| 토큰 | 디자이너A 값 | 디자이너B 값 | 해결 방식 |
|------|------------|------------|----------|
| corner-radius | Ive/Dye: 6-22pt 연속 곡률 | Rams/Vignelli/Mondrian: 0px 직각 | **맥락 분리** -- Apple: 연속 곡률, 그래픽: 직각. **추가 해소**: corner-radius-large를 `.ios`/`.web`/`.android` 플랫폼별 분리 토큰으로 전환 |
| layout-symmetry | Rams: 좌우 대칭 95% | Mondrian/Brockmann/Lee Ufan: 비대칭 | **맥락 분리** -- 제품/도구: 대칭, 아트/에디토리얼: 비대칭 |
| grid-strictness | Brockmann/Vignelli: 100% 그리드 정렬 | Kandinsky/Malevich: 자유 배치 | **맥락 분리** -- 정보 UI: 엄격 그리드, 크리에이티브/시각화: 자유 배치 |
| form-style | Kare: 유기적 곡선 40% (친근함) | Malevich: 유기적 곡선 0% (순수 기하) | **맥락 분리** -- 소비자 앱: Kare 친근함, 아트/미니멀: Malevich 순수 기하 |
| diagonal-use | Kandinsky/Malevich: 15-45도 기울기 허용 | Mondrian: 대각선 완전 배제 | **맥락 분리** -- 직교 UI: 대각선 금지, 역동적 UI: 대각선 허용 |

## Motion & Interaction

| 토큰 | 디자이너A 값 | 디자이너B 값 | 해결 방식 |
|------|------------|------------|----------|
| transition-duration | Rams: 0.15-0.25s (절제) | Turrell: 2-5s (점진적) | **맥락 분리** -- 기능적 전환: 0.15-0.35s, 몰입/모드 전환: 2-5s |
| easing | Rams: linear/ease-out | Ive/Matas: spring(damping 0.7-0.85) | **맥락 분리** -- 미니멀: ease-out, 물리적 피드백: spring |
| animation-count | Rams: 화면당 동시 1개 | Kandinsky: 다층 병렬 가능 | **맥락 분리** -- 도구 UI: 1개, 시각화/크리에이티브: 다층 허용 |
| scroll-behavior | Vignelli: 페이지 스냅 | Matas: 관성 스크롤 + 러버밴드 | **맥락 분리** -- 프레젠테이션: 스냅, 피드/콘텐츠: 관성 |
| hover-feedback | Rams: opacity 0.85 (미세) | Rand: 색상 반전 (극적) | **variants** -- subtle(opacity), bold(반전) |
