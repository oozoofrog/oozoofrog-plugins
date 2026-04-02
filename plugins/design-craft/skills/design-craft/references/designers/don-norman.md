# Don Norman -- 디자인 토큰 사전

## 프로필
- **활동 기간**: 1980s-현재, 핵심 저서 1988 ("The Design of Everyday Things")
- **주요 소속**: UCSD 인지과학 교수, Apple Advanced Technology Group(1993-1998), Nielsen Norman Group 공동설립(1998)
- **핵심 공헌**: 어포던스·시그니파이어 개념 정립, "사용자 중심 디자인(UCD)" 보급, 감성 디자인 3단계 모델, "UX" 용어 대중화
- **디자인 계보**: James J. Gibson(생태심리학) → Norman(인지과학 UX) → 현대 UCD/HCI 전체

## 디자인 철학 (정량화 가능한 원칙)

| 원칙 | 정량 변환 | 측정 기준 |
|------|----------|----------|
| 어포던스(Affordance) | 조작 가능 요소의 95%+ 시각적 단서 제공 | 사용성 테스트 최초 성공률 |
| 시그니파이어(Signifier) | 인터랙티브 요소에 시각 구분 최소 2가지 (색상+형태 등) | 시각 단서 수 |
| 피드백(Feedback) | 사용자 액션 후 ≤ 100ms 반응 | 지연 시간 |
| 매핑(Mapping) | 컨트롤-결과 공간 일치율 100% | 자연적 매핑 비율 |
| 제약(Constraint) | 오류 가능 경로 차단율 80%+ | 방어적 UI 비율 |
| 개념 모델(Conceptual Model) | 시스템 상태 가시성 90%+ | 사용자 멘탈모델 일치율 |
| 오류 관용(Error Tolerance) | Undo 가능 액션 95%+, 파괴적 액션 확인 대화 100% | 복구 가능성 |

## 정량적 디자인 토큰

### 레이아웃 & 간격

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| cognitive-chunk-max | 7 ±2 개 (화면 당 주요 요소 그룹) | Miller's Law (1956) | C |
| nav-depth-max | ≤ 3단계 (깊이 제한) | Norman "3-click rule" 변형 | D |
| choices-per-screen | ≤ 7개 (주요 선택지) | Hick's Law 최적 범위 | C |
| grouping-proximity | 관련 요소 간격 ≤ 비관련 요소 간격의 50% | Gestalt 근접성 원리 | C |
| visual-hierarchy-levels | 3-4단계 (제목/소제목/본문/캡션) | Norman 인지 부하 권장 | D |
| action-zone | 엄지 도달 범위 내 핵심 CTA (하단 1/3 영역) | Steven Hoober 연구 (2013) | C |
| fitts-target-min | 44x44pt (터치), 24x24pt (포인터) | Fitts's Law + Apple/Google HIG | S |
| label-proximity | 레이블-필드 간격 ≤ 8pt (시각적 연결) | Gestalt 근접성 | C |
| error-message-proximity | 오류 발생 필드로부터 ≤ 4pt | Norman 피드백 즉시성 원칙 | D |
| whitespace-cognitive | 정보 블록 간 여백 ≥ 16pt | 인지 분리 최소 간격 | C |

### 타이포그래피

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| readable-line-length | 45-75자/줄 (최적 60자) | Baymard Institute 가독성 연구 | C |
| font-size-min | 16px (모바일 본문 최소) | WCAG + 가독성 연구 | C |
| font-size-body | 16-18px (데스크탑), 16px (모바일) | NN/g 가독성 권장 | D |
| contrast-ratio-normal | ≥ 4.5:1 (AA), ≥ 7:1 (AAA) | WCAG 2.1 | S |
| contrast-ratio-large | ≥ 3:1 (AA), ≥ 4.5:1 (AAA) — 18pt+ 텍스트 | WCAG 2.1 | S |
| heading-scale-ratio | 1.2-1.5x (단계별 증가) | 타이포그래피 스케일 관례 | C |
| label-weight | 필드 레이블 ≥ medium(500) — 본문과 구분 | Norman 시그니파이어 원칙 | D |
| error-text-color | 빨강 + 아이콘 (색각 이상 대응 이중 코딩) | Norman 이중 코딩 원칙 | D |
| instruction-text | 회색 텍스트 금지 — 대비 4.5:1 보장 | WCAG + NN/g | C |
| text-alignment | 좌측 정렬 기본 (LTR) — 양쪽 정렬 금지 | 가독성 연구 | C |

### 색상 & 표면

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| status-success | 녹색 + 체크 아이콘 (이중 코딩) | Norman 이중 코딩 | D |
| status-error | 빨강 + 경고 아이콘 (이중 코딩) | Norman 이중 코딩 | D |
| status-warning | 주황/황색 + 주의 아이콘 | Norman 피드백 원칙 | D |
| status-info | 파랑 + 정보 아이콘 | Norman 피드백 원칙 | D |
| interactive-distinction | 인터랙티브 요소 색상 ≠ 비인터랙티브 — 최소 3:1 대비 | 시그니파이어 원칙 | D |
| focus-indicator | 2px+ 외곽선, 배경 대비 3:1 | WCAG 2.2 Focus Visible | S |
| disabled-opacity | 0.38-0.5 (비활성 상태 명확 구분) | Material Design + Norman 제약 | A |
| selected-state | 배경색 변화 + 체크 표시 (이중 코딩) | Norman 가시성 원칙 | D |
| color-alone-never | 색상 단독 정보 전달 금지 — 항상 형태/텍스트 병행 | WCAG 1.4.1 + Norman | S |
| palette-functional | 의미 기반 색상 — 시맨틱 토큰 사용 | Norman 매핑 원칙 | D |

### 형태 & 곡률

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| button-min-size | 44x44pt (터치), 24x24px (포인터) | Fitts's Law + HIG | S |
| button-padding | 수평 16-24pt, 수직 8-12pt | 터치 영역 확보 + 레이블 가독성 | A |
| clickable-affordance | 버튼: 배경색 + 둥글림 + 높이감(선택) | 어포던스 3중 단서 | D |
| link-affordance | 밑줄 + 색상 구분 (최소 2가지 단서) | 시그니파이어 이중 코딩 | D |
| input-border | 1-2px 실선 테두리 — 입력 영역 명확 구분 | 어포던스 경계 표시 | D |
| icon-with-label | 아이콘 단독 사용 금지 — 레이블 병행 (첫 사용 시) | Norman 매핑 원칙 | D |
| icon-size-min | 24x24pt (가시성 확보) | NN/g 아이콘 연구 | C |
| toggle-size | 최소 48pt 너비 (on/off 상태 구분 공간) | 어포던스 + Fitts | D |
| form-field-height | 40-48pt (터치), 32-40px (데스크탑) | 터치 타겟 + 가독성 | A |
| progress-indicator | 진행률 시각화 필수 — 3초+ 작업 시 | Norman 피드백 원칙 | D |

### 인터랙션 & 모션

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| response-instant | ≤ 100ms (즉각 반응 인지) | Jakob Nielsen 응답시간 3단계 | C |
| response-seamless | ≤ 1s (연속성 유지) | Nielsen 응답시간 연구 (1993) | C |
| response-attention | ≤ 10s (주의 유지 한계) | Nielsen 응답시간 연구 | C |
| loading-feedback | 1s 초과 시 스피너, 3s 초과 시 진행률 표시 | Norman 피드백 원칙 + Nielsen | C |
| undo-availability | 파괴적 액션 100% 되돌리기 제공 | Norman 오류 관용 원칙 | D |
| confirm-destructive | 삭제·취소 불가 액션 전 확인 대화 필수 | Norman 제약 원칙 | D |
| error-recovery-time | 오류 발견→수정 ≤ 15s (평균) | 사용성 연구 기준 | C |
| hick-response-time | RT = a + b·log₂(n+1) — 선택지 n개 | Hick's Law (1952) | C |
| fitts-movement-time | MT = a + b·log₂(2D/W) — 거리 D, 너비 W | Fitts's Law (1954) | C |
| animation-purpose | 상태 전환 설명용만 — 장식 애니메이션 금지 | Norman 피드백 원칙 | D |
| transition-cognitive | 0.2-0.4s (인지적 연속성 유지 범위) | NN/g 애니메이션 연구 | C |

### 인지 법칙 정량 토큰

| 토큰명 | 공식/값 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| millers-law | 작업 기억 용량 = 7 ±2 청크 | George Miller (1956) | C |
| hicks-law | 반응시간 = a + b·log₂(n+1) | Hick (1952), Hyman (1953) | C |
| fitts-law | 이동시간 = a + b·log₂(2D/W) | Paul Fitts (1954) | C |
| jakobs-law | 사용자는 기존 사이트 경험 기반 기대 형성 | Jakob Nielsen | D |
| teslers-law | 복잡성 보존 — 시스템이 흡수해야 할 최소 복잡성 존재 | Larry Tesler | D |
| doherty-threshold | 응답 ≤ 400ms → 몰입 유지 | Doherty & Thadhani (1982) | C |
| peak-end-rule | 경험 평가 = 피크 감정 + 종료 감정 | Kahneman (1993) | C |
| serial-position | 첫 번째 + 마지막 항목 회상률 ≥ 70% | Ebbinghaus (1885) | C |
| von-restorff | 시각적으로 구별되는 항목 회상률 2-3배 증가 | Von Restorff (1933) | C |
| zeigarnik-effect | 미완료 작업 회상률 90%+ (완료 대비 2배) | Zeigarnik (1927) | C |

### 감성 디자인 토큰 (Emotional Design 3단계)

| 토큰명 | 값/범위 | 출처 | 신뢰도 |
|--------|---------|------|--------|
| visceral-first-impression | 첫 50ms 이내 시각적 매력 판단 | Lindgaard et al. (2006) | C |
| visceral-color-warmth | 난색(빨강/주황/노랑) = 활성, 한색(파랑/녹색) = 안정 | 색채 심리학 연구 | C |
| behavioral-task-success | 태스크 완료율 ≥ 95% (good usability) | NN/g 벤치마크 | D |
| behavioral-error-rate | 오류율 ≤ 5% (good usability) | NN/g 벤치마크 | D |
| behavioral-efficiency | 전문가 대비 초보자 소요시간 ≤ 2배 | 사용성 연구 기준 | C |
| reflective-brand-trust | NPS ≥ 50 (높은 추천 의향) | Net Promoter Score 기준 | D |
| reflective-delight | 예상 외 긍정 순간 ≥ 1회/세션 | UX 감성 연구 | D |

## 시대별 변화

| 시기 | 전환점 | 주요 수치 변화 |
|------|--------|---------------|
| 1988 | "The Design of Everyday Things" 초판 | 어포던스 개념 보급 → UI 버튼에 3D 효과 확산 |
| 1993-1998 | Apple ATG 근무 | "UX" 용어 공식 사용, 사용자 테스트 정량화 시작 |
| 2002 | "Emotional Design" 출간 | 본능·행동·반성 3단계 → 감성 메트릭 도입 |
| 2004 | "시그니파이어" 개념 분리 | 어포던스(물리) ≠ 시그니파이어(인지) 구분 명확화 |
| 2013 | "The Design of Everyday Things" 개정판 | 시그니파이어 공식 도입, 디지털 UI 사례 대폭 추가 |
| 2023+ | AI/LLM 시대 | 자율 에이전트 UX, 대화형 인터페이스의 인지 부하 재정의 |

## 영향 관계

- **James J. Gibson → Norman**: 생태심리학의 "어포던스" 개념을 디자인 영역으로 이식
- **Gestalt 심리학 → Norman**: 근접성·유사성·연속성·폐합 원리를 UI 레이아웃 원칙으로 변환
- **Norman → Apple HIG**: 1993-1998 Apple 재직 시 HIG에 인지과학 원칙 직접 반영
- **Norman → WCAG**: 접근성 표준에 인지 부하·이중 코딩 원칙 간접 영향
- **Norman ↔ Jakob Nielsen**: Nielsen Norman Group — 사용성 휴리스틱 10가지와 Norman 원칙 상호 보완
- **Norman → 현대 UCD 전체**: "사용자 중심 디자인" 방법론이 ISO 9241-210 표준의 기반
- **주요 참고 문헌**: "The Design of Everyday Things" (1988/2013 개정), "Emotional Design" (2004), "Living with Complexity" (2010)

## Norman 7단계 행위 모델 → UI 체크리스트

| 단계 | 설명 | UI 토큰/체크 |
|------|------|-------------|
| 1. 목표 형성 | 사용자가 달성하려는 바 | 화면 제목이 목표를 반영하는가 |
| 2. 의도 형성 | 어떤 행동을 할지 결정 | CTA 레이블이 행동을 명시하는가 ("저장", "삭제") |
| 3. 행동 명세 | 구체적 조작 계획 | 조작 순서가 자연스러운가 (좌→우, 위→아래) |
| 4. 행동 실행 | 클릭/탭/입력 | 터치 타겟 ≥ 44pt, 클릭 피드백 ≤ 100ms |
| 5. 상태 지각 | 시스템 반응 인지 | 시각/청각/햅틱 피드백 존재 |
| 6. 상태 해석 | 반응의 의미 이해 | 성공/실패 메시지 명확, 이중 코딩 |
| 7. 결과 평가 | 목표 달성 여부 판단 | 완료 상태 시각화 (체크, 진행률 100%) |

## UI 적용 매핑

| Norman 원칙 | 현대 UI 토큰 변환 규칙 |
|-------------|----------------------|
| 어포던스 | 버튼에 배경색+둥글림+hover 효과 부여, 플랫 텍스트 버튼 최소화 |
| 시그니파이어 | 인터랙티브 요소에 최소 2가지 시각 단서 (색상+형태, 색상+밑줄 등) |
| 피드백 | 모든 액션에 100ms 이내 시각/청각/햅틱 반응, 로딩 1s 초과 시 스피너 |
| 매핑 | 슬라이더 좌→우 = 증가, 토글 우 = ON — 자연적 방향 일치 |
| 제약 | 불가능한 액션 비활성화(`disabled`), 유효하지 않은 입력 실시간 차단 |
| 개념 모델 | 시스템 상태 항상 가시화 (빵부스러기, 진행 표시, 현재 위치) |
| 오류 관용 | Ctrl+Z 제공, 삭제 전 확인, 휴지통 패턴, 30일 복구 |
| 이중 코딩 | 색상 단독 의미 전달 금지 — 아이콘·텍스트·패턴 병행 |
| 인지 부하 | 화면 당 선택지 ≤ 7, 단계 ≤ 3, 정보 그룹핑 필수 |
| Fitts's Law | 자주 쓰는 CTA는 크게(≥ 48pt), 화면 가장자리/모서리 활용 |
