# James Turrell -- 시각 언어 디자인 토큰

## 프로필
- **활동 기간**: 1966-현재 (핵심 활동기: 1966-현재)
- **운동/유파**: Light and Space Movement (빛과 공간 운동)
- **핵심 공헌**: 빛 자체를 조각의 매체로 확립. Roden Crater(1979-)에서 자연광과 인공광의 통합 환경을 설계. Ganzfeld 효과(균질한 시야로 인한 깊이감 상실)를 예술적 도구로 활용. 지각의 현상학을 체험 가능한 공간으로 구현.

## 시각 언어 원칙

1. **빛으로 보기(Seeing Light, Not Things)**: 빛을 사물을 비추는 수단이 아닌 그 자체로 인지되는 존재로 취급한다. UI에서 배경색, 화면 밝기, 색온도가 "콘텐츠를 담는 그릇"이 아닌 "경험 그 자체"라는 원칙이다.
2. **Ganzfeld 효과(Total Field)**: 균질한 색광이 시야 전체를 채우면 깊이 지각이 사라지고 무한한 공간감이 생긴다. UI에서 단색 전체화면 배경이 만드는 몰입 효과의 근거이다.
3. **색온도의 감정(Color Temperature as Emotion)**: 빛의 색온도(Kelvin)가 심리적 상태를 직접 유도한다. 2700K(따뜻한 노랑) = 친밀, 5000K(중립) = 명료, 7500K(차가운 파랑) = 경각. UI에서 다크모드/라이트모드의 색온도를 의도적으로 설계하는 근거이다.
4. **점진적 적응(Gradual Adaptation)**: Turrell의 작품은 10-15분 이상 머물러야 빛의 미세한 변화를 인지한다. 망막 적응(dark/light adaptation)이 경험의 일부이다. UI에서 사용 시간에 따라 인터페이스가 미세하게 변하는 adaptive UI의 근거.
5. **경계의 소멸(Dissolving Boundaries)**: Turrell의 공간에서 벽, 바닥, 천장의 경계가 빛에 의해 사라진다. UI에서 컨테이너의 경계를 줄이고 색상 전환으로 영역을 구분하는 원칙이다.
6. **Sky Space(하늘 틀)**: 천장에 타원형 개구부를 만들어 하늘을 "그림"처럼 보여준다. 프레이밍이 지각을 변환한다. UI에서 뷰포트/프레임이 콘텐츠의 의미를 변환하는 원칙이다.
7. **Ambient Intelligence(주변 지능)**: 주변 조명이 시간·날씨에 반응하여 변한다. 사용자가 의식하지 못하는 수준에서 환경이 적응한다. UI에서 시간대별 색온도 자동 조절, ambient light sensor 활용의 근거이다.

## 정량적 디자인 토큰

### 색상 체계
| 토큰명 | 값/범위 | 출처 | 신뢰도 | UI 적용 |
|--------|---------|------|--------|---------|
| turrell-warm-glow | #FF8C42 ~ #FFAA5C (≈2700K) | Aten Reign (2013) 주황 단계 측색 | B | 야간 모드, 따뜻한 알림, 환영 화면 |
| turrell-pink-dusk | #E87EB0 ~ #F09BC0 (≈3500K) | Aten Reign 핑크 단계 | B | 전환 상태, soft alert, 중간 강도 표시 |
| turrell-magenta | #B840A0 ~ #D050B8 | Ganzfeld 설치 측색 (Akhob, 2013) | C | 강조, 프리미엄, 브랜드 포인트 |
| turrell-blue-twilight | #4060C0 ~ #5070D0 (≈6500K) | Roden Crater 시민 박명 촬영 | C | 기본 액센트, 링크, 포커스 링 |
| turrell-blue-deep | #1A2060 ~ #2A3080 (≈7500K) | Roden Crater 천문 박명 촬영 | B | 다크모드 깊은 배경, 몰입 영역 |
| turrell-white-daylight | #F0F0F8 ~ #FAFAFE (≈5000K) | Sky Space 정오 색온도 | B | 라이트모드 중립 배경, 콘텐츠 영역 |
| turrell-red-ambient | #CC3030 ~ #E04040 | Aten Reign 빨강 단계 | C | 긴급 알림, 집중 유도, 에너지 표현 |
| turrell-green-liminal | #30A060 ~ #40C070 | Ganzfeld 설치 녹색 단계 | D | 성공, 완료, 자연 연관 |
| turrell-void-black | #0A0A15 ~ #12122A | Perceptual Cell 내부 완전 암흑 | B | 최심 배경, OLED 절전, 극한 다크모드 |
| kelvin-gradient | 2700K→5000K→7500K | Roden Crater 일출-정오-일몰 색온도 | B | 시간대별 색온도 자동 전환 시스템 |

### 구성 & 레이아웃
| 토큰명 | 값/범위 | 출처 | 신뢰도 | UI 적용 |
|--------|---------|------|--------|---------|
| ganzfeld-fill | 100% 단색 충전 (시야 전체) | Ganzfeld 설치 원리 | B | 전체화면 단색 배경, 몰입 모드 |
| aperture-shape | 타원형 또는 직사각형 개구부 | Sky Space 연작 개구부 형태 | B | 콘텐츠 프레임 형태, 마스크 모양 |
| aperture-ratio | 개구부가 시야의 15-30% | Sky Space 개구부 대 벽면 비율 | C | 메인 콘텐츠 영역 대 여백 비율 |
| transition-duration | 색상 전환 10-45분 (극도로 느린 변화) | Aten Reign 색상 사이클 | B | 긴 전환 시간: CSS transition 2-5s (축약) |
| layer-count | 2-5개 빛의 레이어 중첩 | Aten Reign (2013) 동심 타원 구조 | B | 중첩 레이어 수, 오버레이 깊이 |

### 비율 & 균형
| 토큰명 | 값/범위 | 출처 | 신뢰도 | UI 적용 |
|--------|---------|------|--------|---------|
| surround-to-aperture | 주변(70-85%) : 개구부(15-30%) | Sky Space 비율 분석 | B | 프레임(주변):콘텐츠 비율 |
| light-falloff | 중심 100% → 가장자리 60-80% (부드러운 감쇠) | Ganzfeld 조도 분포 | C | radial-gradient 중심 밝음 → 가장자리 어둠 |
| concentric-ratio | 내부 레이어가 외부의 60-75% | Aten Reign 동심 타원 비율 | C | 중첩 카드/모달의 크기 비율 |
| symmetry-type | 중심 대칭 (방사형 또는 동심원) | 전 작품 대칭성 분석 | B | 중앙 초점 레이아웃, 방사형 메뉴 |
| horizon-line | 시야의 50% 지점 (물리적 수평선) | Sky Space 개구부 수직 위치 | C | 메인 콘텐츠의 수직 중앙 배치 |

### 공간 & 여백
| 토큰명 | 값/범위 | 출처 | 신뢰도 | UI 적용 |
|--------|---------|------|--------|---------|
| immersive-padding | 0 (요소가 뷰포트 가장자리까지 도달) | Ganzfeld 원리 (경계 없음) | B | 몰입 모드에서 마진/패딩 제거 |
| perceptual-depth | 물리적 깊이와 인지 깊이의 불일치 | Ganzfeld 효과 연구 | C | box-shadow, blur로 무한 깊이감 시뮬레이션 |
| boundary-softness | 벽과 빛의 경계에서 10-20% 점진적 전환 | Turrell 설치 코너 처리 | B | 영역 경계에 gradient fade, 날카로운 border 금지 |
| void-space | 인지 가능한 요소가 없는 순수 색광 영역 | Perceptual Cell, Dark Space | B | 의도적 "빈 영역" — 콘텐츠도 장식도 없는 순수 색면 |
| threshold-space | 밝음→어둠 전환 복도 (적응 유도 공간) | Roden Crater 진입 터널 | C | 모드 전환 시 중간 전환 화면 (splash/transition screen) |

### 시각적 리듬 & 반복
| 토큰명 | 값/범위 | 출처 | 신뢰도 | UI 적용 |
|--------|---------|------|--------|---------|
| color-cycle-speed | 풀 사이클 10-60분 | Aten Reign, Roden Crater 사이클 | B | 배경색 자동 변화 주기 (UI에서 2-10초로 축약) |
| kelvin-shift-rate | 시간당 200-500K 변화 | 자연광 일출-일몰 색온도 변화율 | B | 시간대별 색온도 자동 전환 속도 |
| concentric-rhythm | 동심 타원/원이 2-5겹 | Aten Reign 구조 | B | 중첩 요소의 반복 구조 |
| breath-animation | 밝기 ±5-10% 미세 진동, 주기 4-8초 | Turrell 설치 호흡 효과 관찰 | C | 배경 밝기 미세 변화 애니메이션 (호흡 효과) |
| dawn-dusk-symmetry | 일출과 일몰 색상 시퀀스가 대칭 | Roden Crater 프로그램 분석 | C | 앱 시작(따뜻한 톤) ↔ 종료(차가운 톤) 색상 대칭 |

## 대표작 분석

### 1. Aten Reign (2013)
- **규모**: Solomon R. Guggenheim Museum 로툰다 전체 (높이 약 28m, 너비 약 18m)
- **소장**: 임시 설치 (2013.6-9)
- **구성**: 구겐하임 원형 로툰다의 나선형 경사로에 5겹의 동심 타원형 패브릭 스크린을 설치. 각 레이어에 개별 LED 조명이 색상을 독립적으로 변환. 최외곽에서 최내곽까지 색상이 다르게 진행.
- **색상 사이클**: 약 45분 사이클로 빨강→주황→핑크→보라→파랑→녹색 등 전체 스펙트럼 순환. 각 레이어가 시차를 두고 변화하여 동심원 간 대비가 지속적으로 변함.
- **Kelvin 범위**: 약 2200K(붉은 주황) ~ 8000K(차가운 파랑) 범위를 순환.
- **UI 변환**: 동심 오버레이 구조. 5단계 깊이의 모달/시트 시스템에서 각 레이어가 독립적 색상을 가짐.
  ```css
  .aten-layer-1 { background: rgba(255, 140, 66, 0.9); }
  .aten-layer-2 { background: rgba(232, 126, 176, 0.85); }
  .aten-layer-3 { background: rgba(184, 64, 160, 0.8); }
  .aten-layer-4 { background: rgba(64, 96, 192, 0.75); }
  .aten-layer-5 { background: rgba(26, 32, 96, 0.7); }
  ```

### 2. Roden Crater (1979-진행 중)
- **규모**: Arizona 사막의 사화산 분화구 전체 (직경 약 400m)
- **소장**: Skystone Foundation
- **구성**: 분화구 내부에 6개 이상의 터널과 챔버를 굴착. 각 챔버에 정밀한 개구부를 만들어 특정 천문 현상(일출, 일몰, 하지, 동지, 월출)에 맞춰 빛이 특정 각도로 진입. 수십 년에 걸쳐 건설 중.
- **색온도 경험**: 외부(밝음, 5500K) → 진입 터널(점진적 어두움, 적응 시간 10-15분) → 챔버 내부(완전한 어둠 또는 개구부를 통한 순수 하늘빛). 빛에서 어둠으로, 다시 빛으로의 전이가 핵심 경험.
- **UI 변환**: 온보딩/모드 전환의 원형. 라이트모드 → 전환 화면(2-3초, 중간 톤) → 다크모드. 급격한 전환이 아닌 점진적 적응 유도. `transition: background-color 3s ease-in-out`.

### 3. Akhob (2013, 영구 설치)
- **규모**: Louis Vuitton Las Vegas CityCenter 내부, 2층 높이 공간
- **소장**: Louis Vuitton (영구 설치)
- **구성**: 순수 Ganzfeld 체험 공간. 관람자가 경사로를 걸어 올라가면 균질한 색광이 시야 전체를 채운다. 바닥, 벽, 천장의 경계가 사라지고 무한한 색 공간에 떠 있는 느낌. 색상이 10분 사이클로 서서히 변환.
- **Ganzfeld 효과**: 깊이 지각 상실, 공간감 왜곡, 색광 속에 "부유"하는 감각. 관람자가 비틀거릴 수 있어 안전 보조 필요.
- **UI 변환**: 몰입형 미디어 재생 화면, 명상 앱의 배경, VR/AR의 환경 색상. 콘텐츠가 아닌 "환경 자체"가 경험인 UI. `position: fixed; inset: 0; background: #B840A0; transition: background-color 5s;`

## UI 적용 매핑

### 변환 규칙

1. **색온도 시스템**: 시간대에 따라 UI 색온도를 자동 조절한다.
   ```css
   /* 아침 (6-9시): 따뜻한 톤 */
   :root[data-time="morning"] {
     --bg: #FFF8E8;           /* ≈3500K */
     --surface: #FFFAF0;
     --accent: #FF8C42;
   }
   /* 낮 (9-17시): 중립 톤 */
   :root[data-time="day"] {
     --bg: #F0F0F8;           /* ≈5000K */
     --surface: #FAFAFE;
     --accent: #4060C0;
   }
   /* 밤 (17-22시): 차가운 톤 */
   :root[data-time="night"] {
     --bg: #1A2060;           /* ≈7500K → 따뜻한 다크 */
     --surface: #2A3080;
     --accent: #E87EB0;
   }
   ```

2. **Ganzfeld 몰입 모드**: 전체화면 단색 배경으로 사용자를 "감싸는" 경험을 만든다. 콘텐츠를 최소화하고 색면 자체가 경험이 된다.
   ```css
   .ganzfeld-mode {
     position: fixed;
     inset: 0;
     background: var(--immersive-color);
     transition: background-color 5s ease-in-out;
   }
   ```

3. **경계 소멸**: 컨테이너의 테두리를 줄이고 색상 그라디언트로 영역을 구분한다. `border: none`, `border-radius: 0`, 대신 `background` 차이와 `backdrop-filter: blur()`.

4. **점진적 전환**: 모드 전환(라이트/다크), 화면 전환에 2-5초의 느린 전환을 적용한다. 급격한 변화는 Turrell 미학에 정면 위배된다.
   ```css
   * { transition: background-color 2s ease-in-out, color 1.5s ease; }
   ```

5. **동심원 레이어**: 모달, 시트, 오버레이를 동심원적으로 중첩한다. 각 레이어에 독립적 색상(명도/색상 변화)을 부여한다.

6. **호흡 효과**: 배경 밝기를 ±5% 범위에서 4-8초 주기로 미세 진동시킨다. 사용자가 의식적으로 인지하지 못하는 수준의 변화.
   ```css
   @keyframes breathe {
     0%, 100% { opacity: 1; }
     50% { opacity: 0.95; }
   }
   .breathing-bg { animation: breathe 6s ease-in-out infinite; }
   ```

### 적합한 UI 유형
- **명상/웰니스 앱**: Ganzfeld 몰입 모드, 호흡 애니메이션, 색온도 자동 조절
- **수면/야간 모드**: 따뜻한 색온도(2700K), 극저 밝기, 점진적 어두워짐
- **미디어 플레이어**: 전체화면 몰입, 앨범아트 색상으로 배경 충전
- **VR/AR 인터페이스**: 환경색 적응, 공간감 제어, 깊이 지각 조절
- **럭셔리 브랜드**: Akhob처럼 색광 경험이 브랜드 아이덴티티가 되는 UI
- **전시/박물관 앱**: 관람 환경에 맞춘 색온도 적응, 작품과 UI의 조화
- **스마트홈 제어**: 조명 색온도 연동, 시간-공간-감정의 통합 제어

### 주의사항
- **급격한 색상 전환 금지**: 색상 변화는 최소 2초 이상의 전환 시간을 가진다. `transition-duration: 0.3s`는 Turrell 미학에 정면 위배된다. 사용자가 변화를 "느끼되 놀라지 않는" 속도를 유지한다.
- **고대비 패턴 금지**: Turrell의 빛은 균질하고 부드럽다. 날카로운 경계, 체커보드, 줄무늬 패턴은 미학을 파괴한다.
- **작은 요소 부적합**: 이 토큰은 화면의 30% 이상을 차지하는 대형 면에 적용해야 효과가 있다. 아이콘, 버튼 등 소형 요소에는 효과가 없다.
- **텍스트 가독성 확보**: 밝은 색광 배경 위의 텍스트는 충분한 대비를 확보한다. WCAG AA 기준(4.5:1) 준수. 필요시 `text-shadow` 또는 반투명 배경 패널을 사용한다.
- **배터리/성능 고려**: 지속적 배경색 변화 애니메이션은 배터리를 소모한다. `will-change: background-color`, `transform: translateZ(0)`로 GPU 가속을 활성화하고, 백그라운드에서는 애니메이션을 정지한다.
- **Ganzfeld 남용 주의**: 전체화면 단색은 강력하지만, 모든 화면에 적용하면 콘텐츠 접근성이 파괴된다. 특정 모드(명상, 음악 재생)에서만 활성화한다.
- **색온도 자동 조절 옵트아웃**: 사용자가 색온도 자동 변화를 비활성화할 수 있는 옵션을 반드시 제공한다. 색각 이상 사용자에게 의도치 않은 경험을 줄 수 있다.
- **물리적 환경 의존성**: Turrell의 작품은 물리적 공간에서 최적화되어 있다. 스크린은 주변 조명에 영향을 받으므로, ambient light sensor API 활용을 권장하되 폴백을 준비한다.
