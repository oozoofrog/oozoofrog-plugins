---
name: design-research
description: "디자인 리서치 실행 — 유명 디자이너/화가의 디자인 특성을 연구하고 정량적 토큰으로 체계화. '디자인 리서치', '디자이너 연구', '디자인 토큰 생성', '화가 분석', '디자인 시스템 구축' 요청 시 사용. design-craft 스킬 실행 전에 레퍼런스가 없으면 자동 트리거."
model: opus
---

<example>
user: "Dieter Rams와 Jony Ive의 디자인 원칙을 정량적 토큰으로 정리해줘"
assistant: "design-research 모드로 리서치 팀 4명을 구성합니다. design-historian + art-aesthetics가 병렬 연구 → token-architect 통합 → verification-scientist 검증 순서로 진행합니다."
</example>

<example>
user: "Mondrian과 Rothko의 시각 언어를 UI에 적용할 수 있게 토큰화해줘"
assistant: "design-research 모드로 art-aesthetics가 두 화가의 색상/구성/공간 토큰을 추출하고, design-historian이 관련 디자이너 영향 관계를 병렬 조사합니다."
</example>

<example>
user: "디자인 시스템에 사용할 레퍼런스 토큰을 만들어줘"
assistant: "design-research 모드로 디자이너/화가 범위를 먼저 확인한 뒤, 리서치 팀을 구성하여 정량적 토큰 사전을 생성합니다."
</example>

# design-research

유명 디자이너/화가의 디자인 특성을 연구하고 정량적 토큰으로 체계화하는 리서치 오케스트레이터이다.
디자인 토큰이 없으면 design-craft 스킬이 동작할 수 없으므로, 이 스킬이 선행 실행된다.

## 산출물 기준 경로

모든 산출물은 design-craft 스킬의 references 디렉토리에 저장한다. 이 경로를 `$REF`로 축약한다:

```
$REF = plugins/design-craft/skills/design-craft/references
```

이 스킬과 design-craft 스킬이 동일한 경로를 참조해야 하네스가 동작한다. 상대 경로(`references/`)를 사용하지 마라 — 반드시 `$REF` 기준 경로를 사용하라.

## 리서치 팀 구성

| 에이전트 | 역할 | 단계 |
|----------|------|------|
| design-historian | UI/UX 디자이너 원칙 + 정량 수치 추출 | 팬아웃 (병렬) |
| art-aesthetics | 화가/아티스트 시각 언어 토큰 추출 | 팬아웃 (병렬) |
| token-architect | 수집된 토큰 통합 + 스키마 정규화 + 플랫폼 매핑 | 팬인 (통합) |
| verification-scientist | 출처 검증 + 수치 정확도 + 가설 리포트 | 검증 |

## 워크플로우

### Phase 1: 리서치 범위 결정

사용자에게 다음을 확인하라:

1. **연구 대상**: 특정 디자이너/화가 이름 또는 "전체" (기본 목록은 에이전트 파일 참조)
2. **집중 도메인**: 타이포그래피, 색상, 레이아웃, 전체 등
3. **용도**: 어떤 프로젝트/앱에 적용할 것인지

사용자가 명확한 대상을 지정하면 추가 질문 없이 바로 진행하라.
"전체"를 지정하면 기본 목록(P0 + P1 디자이너/화가)으로 진행하라.

### Phase 2: 팀 구성

TeamCreate로 리서치 팀 4명을 구성하라. 모든 에이전트 호출에 model: "opus"를 사용하라.

```
TeamCreate:
  team_name: "design-research-team"
  agents:
    - design-historian (model: opus)
    - art-aesthetics (model: opus)
    - token-architect (model: opus)
    - verification-scientist (model: opus)
```

### Phase 3: 연구 실행 — 팬아웃 (병렬)

TaskCreate로 design-historian과 art-aesthetics에게 동시에 작업을 할당하라.

#### design-historian 작업
- 대상 디자이너별 `$REF/designers/{name}.md` 생성
- 핵심 원칙 + 정량 수치 + 시대별 변화 + 영향 관계 추출
- 완료 시 SendMessage로 token-architect에게 파일 경로 + 요약 전달

#### art-aesthetics 작업
- 대상 화가별 `$REF/artists/{name}.md` 생성
- 색상 이론 + 구성 원칙 + 공간 활용 + 시각적 리듬 + UI 적용 매핑 추출
- 완료 시 SendMessage로 token-architect에게 파일 경로 + 요약 전달

**병렬 실행 확인**: 두 에이전트의 TaskCreate를 동시에 발행하라. 순차 실행하지 마라.

**진행 모니터링**: TaskGet으로 두 에이전트의 진행 상황을 주기적으로 확인하라. 한쪽이 완료되면 token-architect에게 부분 통합을 시작하도록 안내해도 된다.

### Phase 4: 통합 — 팬인

design-historian과 art-aesthetics의 연구가 **모두** 완료되면 token-architect에게 작업을 할당하라.

#### token-architect 작업
- 모든 디자이너/화가 토큰을 통합 스키마로 정규화
- 플랫폼별 매핑 테이블 생성 (iOS pt / Web rem / Android dp)
- 충돌 해결 (상위 호환 → 맥락 분리 → 가중 평균 → variants)
- 검색 인덱스 생성

**산출물:**
- `$REF/tokens/unified-tokens.md` — 통합 토큰 사전
- `$REF/tokens/platform-{ios|web|android}.md` — 플랫폼 매핑
- `$REF/tokens/index.md` — 검색 인덱스
- `$REF/tokens/conflicts.md` — 충돌 리포트

완료 시 SendMessage로 verification-scientist에게 전체 파일 경로 + 충돌 요약 전달.

### Phase 5: 검증

token-architect의 통합이 완료되면 verification-scientist에게 작업을 할당하라.

#### verification-scientist 작업
- 출처 신뢰도 등급 부여 (S/A/B/C/D/F)
- 수치 정확도 검증 (공식 가이드라인 대조 + 내적 일관성)
- 반증 가능한 가설 수립
- PASS / WARNING / FAIL / UNVERIFIABLE 판정

**산출물:**
- `$REF/verification/report.md` — 검증 리포트
- `$REF/verification/hypotheses.md` — 가설 목록
- `$REF/verification/rubric.md` — 휴리스틱 평가 루브릭

**FAIL 토큰이 있으면**: token-architect에게 교정 요청 → verification-scientist 재검증 루프를 실행하라. 최대 3회 반복. 3회 후에도 FAIL이면 `unresolved`로 표기하고 사용자에게 보고하라.

### Phase 6: 산출물 확인

모든 검증이 완료되면 다음을 확인하라:

1. `$REF/designers/` — 디자이너별 정량 토큰 사전이 존재하는가
2. `$REF/artists/` — 화가별 시각 언어 토큰이 존재하는가
3. `$REF/tokens/unified-tokens.md` — 통합 토큰 사전이 존재하는가
4. `$REF/tokens/platform-{ios|web|android}.md` — 플랫폼 매핑이 존재하는가
5. `$REF/verification/report.md` — 검증 리포트가 존재하는가

누락된 산출물이 있으면 해당 에이전트에게 보충을 요청하라.

모든 산출물이 확인되면 사용자에게 결과 요약을 보고하라:
- 연구 대상 수 (디자이너 N명, 화가 N명)
- 총 토큰 수
- 검증 결과 요약 (PASS / WARNING / FAIL / UNVERIFIABLE 비율)
- 충돌 해결 요약
- design-craft 스킬 사용 준비 완료 여부

## 산출물 디렉토리 구조

```
$REF (= plugins/design-craft/skills/design-craft/references/)
├── designers/
│   └── {name}.md              ← 디자이너별 정량 토큰 사전
├── artists/
│   └── {name}.md              ← 화가별 시각 언어 토큰
├── tokens/
│   ├── unified-tokens.md      ← 통합 토큰 사전
│   ├── platform-ios.md        ← iOS 매핑
│   ├── platform-web.md        ← Web 매핑
│   ├── platform-android.md    ← Android 매핑
│   ├── index.md               ← 통합 검색 인덱스
│   └── conflicts.md           ← 충돌 리포트
└── verification/
    ├── report.md              ← 검증 리포트
    ├── hypotheses.md          ← 가설 목록
    └── rubric.md              ← 평가 루브릭
```

## 데이터 전달 프로토콜

### 파일 기반 (_workspace/)
- 각 에이전트의 중간 산출물: `_workspace/{phase}_{agent}_{artifact}.md`
- 예: `_workspace/phase3_design-historian_rams.md`

### 메시지 기반 (SendMessage)
- 에이전트 간 작업 완료 알림, 충돌 예고, 보충 요청에 사용
- SendMessage에는 파일 경로 + 핵심 요약을 포함하라. 전체 내용을 메시지에 넣지 마라

## 에러 핸들링

| 상황 | 대응 |
|------|------|
| 에이전트가 응답 없음 | TaskGet으로 상태 확인. 30초 후에도 미응답이면 재할당 |
| 병렬 연구 중 한쪽만 완료 | 완료된 쪽을 token-architect에게 먼저 전달. 나머지는 도착 시 점진적 통합 |
| 검증에서 FAIL 비율 50% 초과 | 연구 범위를 축소하거나 1차 출처만으로 재연구를 제안 |
| 토큰 충돌이 과다 (10건 이상) | 사용자에게 디자이너/화가 우선순위를 재확인 요청 |
| references/ 디렉토리 미존재 | 자동 생성 후 진행 |
| 사용자가 범위를 지정하지 않음 | P0 디자이너 + P0 화가로 최소 범위를 제안 |

## 테스트 시나리오

### 정상 시나리오: "Dieter Rams 단일 디자이너 연구"
1. 사용자가 "Dieter Rams 디자인 토큰을 만들어줘"라고 요청
2. Phase 1: 범위 = Dieter Rams 1명
3. Phase 2: 팀 구성 (4명)
4. Phase 3: design-historian이 `$REF/designers/dieter-rams.md` 생성. art-aesthetics는 관련 화가(Mondrian 등) 조사
5. Phase 4: token-architect가 통합 토큰 사전 생성
6. Phase 5: verification-scientist가 Rams의 "10 Principles" 원문과 수치 대조 → PASS
7. Phase 6: 산출물 확인 → 완료 보고

### 에러 시나리오: "출처 불명 토큰 검증 실패"
1. design-historian이 Susan Kare의 비트맵 아이콘 간격을 "8px"로 기록 (출처: 블로그)
2. verification-scientist가 출처 등급 D (커뮤니티 해석) → confidence: 0.30
3. 수치 정확도 검증: 원본 Mac 128K의 실제 아이콘 그리드를 대조할 수 없음 → UNVERIFIABLE
4. token-architect에게 `needs-verification: true` 플래그로 유지하되, 범위 추정(6-10px)으로 교정 요청
5. 사용자에게 "Susan Kare 토큰 1건이 검증 불가 — 범위 추정치로 기록됨" 보고
