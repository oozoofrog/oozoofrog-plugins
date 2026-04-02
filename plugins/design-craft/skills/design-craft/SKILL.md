---
name: design-craft
description: "멀티플랫폼 디자인 생성 — iOS/Web/Android 플랫폼별 최적화된 디자인 스펙과 토큰 매핑 생성. '디자인 만들어', '디자인 스펙', 'UI 설계', '화면 디자인', '디자인 시스템', '디자인 토큰 적용' 요청 시 사용. 특정 플랫폼만 요청해도 사용 (예: 'iOS 디자인', '웹 디자인', '안드로이드 디자인')."
model: opus
argument-hint: "[<대상> --platform ios|web|android|all --style <디자이너명>]"
---

<example>
user: "로그인 화면 디자인 스펙 만들어줘"
assistant: "design-craft 모드로 전체 플랫폼(iOS/Web/Android) 로그인 화면 디자인 스펙을 생성합니다. references/ 토큰을 참조하여 플랫폼별 디자이너 팀을 구성합니다."
</example>

<example>
user: "iOS 설정 화면을 Dieter Rams 스타일로 디자인해줘"
assistant: "design-craft --platform ios --style dieter-rams 모드로 Rams 토큰을 우선 적용한 iOS 설정 화면 스펙을 생성합니다."
</example>

<example>
user: "웹 대시보드 디자인을 Mondrian 스타일로 만들어줘"
assistant: "design-craft --platform web --style mondrian 모드로 Mondrian 직교 그리드 + 3원색 토큰을 적용한 웹 대시보드 스펙을 생성합니다."
</example>

# design-craft

멀티플랫폼 디자인 오케스트레이터 — 리서치 팀이 생성한 정량적 토큰을 기반으로 iOS/Web/Android 플랫폼별 최적화된 디자인 스펙을 생성한다.

## 산출물 기준 경로

design-research 스킬과 공유하는 레퍼런스 경로. 이 경로를 `$REF`로 축약한다:

```
$REF = plugins/design-craft/skills/design-craft/references
```

## 플랫폼 디자이너 팀

| 에이전트 | 역할 | 호출 조건 |
|----------|------|----------|
| ios-designer | Apple HIG + SwiftUI/UIKit 스펙 생성 | --platform ios 또는 all |
| web-designer | WCAG + CSS/HTML 반응형 스펙 생성 | --platform web 또는 all |
| android-designer | M3 + Jetpack Compose 스펙 생성 | --platform android 또는 all |
| design-qa | 교차 플랫폼 정합성 + 토큰 수치 검증 | 항상 포함 |

## 워크플로우

### Phase 0: 사전 검증

디자인 생성 전에 반드시 다음을 확인하라:

#### 1. 토큰 사전 존재 확인
`$REF/` 디렉토리에 토큰 사전이 있는지 확인하라:
- `$REF/tokens/unified-tokens.md` 존재 여부
- `$REF/designers/` 에 1개 이상의 파일 존재 여부

**토큰 사전이 없으면:**
```
"디자인 토큰 레퍼런스가 없습니다.
design-research 스킬을 먼저 실행하여 디자이너/화가 토큰을 생성하세요.
예: /design-research Dieter Rams, Jony Ive"
```
사용자에게 안내하고 design-craft를 중단하라. 토큰 없이 디자인을 생성하지 마라.

#### 2. 파라미터 파싱

| 파라미터 | 기본값 | 설명 |
|----------|--------|------|
| --platform | all | ios, web, android, all 중 선택 |
| --style | (없음) | 특정 디자이너/화가 스타일 우선 적용 |

**--platform 파싱 규칙:**
- "iOS 디자인" → `--platform ios`
- "웹 디자인", "반응형 디자인" → `--platform web`
- "안드로이드 디자인", "Material 디자인" → `--platform android`
- 플랫폼 명시 없으면 → `--platform all`

**--style 파싱 규칙:**
- "Rams 스타일로" → `--style dieter-rams`
- "Mondrian 느낌으로" → `--style mondrian`
- 스타일 명시 없으면 → 모든 가용 토큰을 균등 참조

#### 3. --style 토큰 존재 확인
--style이 지정되었으면 해당 디자이너/화가의 토큰 파일이 `$REF/designers/` 또는 `$REF/artists/`에 존재하는지 확인하라. 없으면 사용자에게 design-research 실행을 안내하라.

### Phase 1: 요구사항 분석

사용자 입력에서 다음을 파악하라:

1. **디자인 대상**: 어떤 화면/컴포넌트/기능인가
2. **디자인 목적**: 신규 디자인 / 리디자인 / 디자인 시스템 확장
3. **제약 조건**: 기존 디자인 시스템과의 호환, 브랜드 가이드라인, 접근성 요구사항
4. **우선순위**: 심미성 vs 사용성 vs 접근성 균형

명확하지 않은 항목은 사용자에게 질문하라. 단, 질문은 한 번에 모아서 하라. 여러 차례 나누어 묻지 마라.

### Phase 2: 팀 구성

TeamCreate로 필요한 플랫폼 디자이너 + QA를 구성하라. 모든 에이전트 호출에 model: "opus"를 사용하라.

**--platform별 팀 구성:**

| --platform | 팀원 |
|------------|------|
| ios | ios-designer + design-qa |
| web | web-designer + design-qa |
| android | android-designer + design-qa |
| all | ios-designer + web-designer + android-designer + design-qa |

```
TeamCreate:
  team_name: "design-craft-team"
  agents: [필요한 에이전트 목록] (model: opus)
```

### Phase 3: 디자인 생성 — 병렬 실행

각 플랫폼 디자이너에게 TaskCreate로 작업을 할당하라. **플랫폼 디자이너들은 병렬로 실행하라.**

#### 각 디자이너에게 전달할 정보
SendMessage로 다음을 전달하라:

1. **디자인 요청서**: Phase 1에서 파악한 대상/목적/제약
2. **참조 토큰 경로**: `$REF/designers/{name}.md`, `$REF/artists/{name}.md`
3. **--style 지정 시**: 해당 디자이너/화가 토큰을 우선 적용하라는 지시
4. **통합 토큰 경로**: `$REF/tokens/unified-tokens.md`

#### 각 디자이너의 산출물
- `_workspace/phase3_{agent}_{component}.md` — 플랫폼별 디자인 스펙
- 토큰 매핑 테이블 (원본 토큰 → 플랫폼 구현값)
- 색상 팔레트 (Light/Dark 모드)
- 간격/레이아웃 수치
- 인터랙션 명세
- 구현 힌트 (SwiftUI / CSS / Compose)

**완료 확인**: 각 디자이너가 SendMessage로 오케스트레이터에게 완료를 보고하면 다음 Phase로 진행하라.

### Phase 4: QA 검증

모든 플랫폼 디자이너의 스펙이 완료되면 design-qa에게 TaskCreate로 검증 작업을 할당하라.

#### design-qa에게 전달할 정보
SendMessage로 다음을 전달하라:

1. 각 플랫폼 디자이너의 스펙 파일 경로
2. 리서치 팀 원본 토큰 파일 경로
3. 검증 요구사항 (접근성 기준, 교차 플랫폼 일관성 기준)

#### design-qa 검증 항목
1. **접근성 검증**: contrast ratio, 터치 타겟 크기, 폰트 크기 최소 기준
2. **토큰 원본 일치**: 리서치 팀 토큰과 플랫폼 스펙의 수치 일치 여부
3. **교차 플랫폼 일관성**: 공유 토큰의 시각적 동등성 + 플랫폼 특화의 적절성
4. **간격 그리드 준수**: 모든 spacing 값이 4의 배수인지

#### 검증 결과 처리

**PASS**: Phase 5로 진행
**NEED_REVISION**:
1. FAIL 항목을 해당 플랫폼 디자이너에게 SendMessage로 전달
2. 디자이너가 수정 후 design-qa에게 재검증 요청
3. 최대 3회 수정-재검증 루프. 3회 초과 시 사용자에게 에스컬레이션

### Phase 5: 산출물 출력

QA PASS 후 최종 산출물을 정리하여 사용자에게 출력하라.

#### 산출물 구조

**중간 산출물** (유지):
```
_workspace/
├── phase3_ios-designer_{component}.md
├── phase3_web-designer_{component}.md
├── phase3_android-designer_{component}.md
└── phase4_design-qa_report.md
```

**최종 출력** (사용자에게 제시):

각 플랫폼별 디자인 스펙을 마크다운으로 출력하라. 포함 사항:

1. **토큰 매핑 테이블**: 원본 토큰 → 플랫폼별 구현값
2. **컴포넌트 구조**: View 계층 트리 + 각 노드별 적용 토큰
3. **색상 팔레트**: Light/Dark 모드 대응 쌍 + contrast ratio
4. **간격/레이아웃**: 그리드 기반 수치 + safe area/breakpoint 대응
5. **인터랙션**: 터치 타겟, 제스처, 애니메이션 duration
6. **구현 힌트**: 핵심 API/modifier/class 참조

**QA 리포트 요약**도 함께 출력하라:
- 접근성 판정 (PASS/FAIL per platform)
- 교차 플랫폼 일관성 판정
- 토큰 원본 일치율

## 데이터 전달 프로토콜

### 파일 기반 (_workspace/)
- 중간 산출물: `_workspace/{phase}_{agent}_{artifact}.md`
- 각 에이전트는 파일을 생성하고 경로를 SendMessage로 공유

### 메시지 기반 (SendMessage)
- 오케스트레이터 → 디자이너: 디자인 요청서 + 토큰 경로
- 디자이너 → 오케스트레이터: 완료 보고 + 스펙 파일 경로
- 오케스트레이터 → design-qa: 검증 요청 + 모든 스펙 파일 경로
- design-qa → 오케스트레이터: QA 리포트
- design-qa → 디자이너: FAIL 항목 + 수정 지침 (NEED_REVISION 시)

## 에러 핸들링

| 상황 | 대응 |
|------|------|
| references/ 토큰 없음 | design-craft를 중단하고 design-research 스킬 실행을 안내 |
| --style 디자이너 토큰 없음 | 해당 디자이너 토큰이 없다고 안내. design-research 실행을 제안 |
| 플랫폼 디자이너 미응답 | TaskGet으로 상태 확인. 미응답 시 재할당 |
| QA 3회 연속 FAIL | 근본 원인 분석 + 사용자에게 에스컬레이션 |
| 토큰 원본 불일치 발견 | 리서치 팀 원본이 정확하다고 가정하고 플랫폼 스펙을 교정 |
| 교차 플랫폼 공유 토큰 충돌 | design-qa가 양쪽 근거를 제시하고, 오케스트레이터가 사용자에게 결정 위임 |
| --platform 미인식 값 | "지원 플랫폼: ios, web, android, all" 안내 후 재입력 요청 |

## 테스트 시나리오

### 정상 시나리오: "iOS 로그인 화면 Dieter Rams 스타일"
1. 사용자: "iOS 로그인 화면을 Rams 스타일로 디자인해줘"
2. Phase 0: `$REF/designers/dieter-rams.md` 존재 확인 → OK. --platform ios, --style dieter-rams 파싱
3. Phase 1: 대상=로그인 화면, 목적=신규, 제약=Rams 원칙 준수
4. Phase 2: ios-designer + design-qa 팀 구성
5. Phase 3: ios-designer가 Rams 토큰 우선 적용하여 iOS 로그인 스펙 생성
   - spacing-base: 8pt, corner-radius: 8pt (Rams 미니멀), contrast: 4.5:1+
6. Phase 4: design-qa가 검증 → 접근성 PASS, 토큰 일치 100%, 단일 플랫폼이므로 교차 정합성 N/A
7. Phase 5: iOS 로그인 디자인 스펙 + 토큰 매핑 테이블 출력

### 에러 시나리오: "토큰 없이 디자인 요청"
1. 사용자: "대시보드 디자인 스펙 만들어줘"
2. Phase 0: `$REF/tokens/unified-tokens.md` 미존재 확인
3. 즉시 중단:
   ```
   "디자인 토큰 레퍼런스가 없습니다.
   design-research 스킬을 먼저 실행하여 디자이너/화가 토큰을 생성하세요.
   예: /design-research Dieter Rams, Jony Ive"
   ```
4. design-craft 워크플로우 중단. 사용자가 design-research를 실행한 후 재시도하도록 안내
