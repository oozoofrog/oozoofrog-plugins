---
name: design-audit
description: "앱의 현재 디자인 상태를 진단하고 awesome-design-md 카탈로그(69개 브랜드 DESIGN.md 본문 전체 내재화)에서 가장 적합한 디자인 시스템 Top-3를 정확한 hex·폰트·수치 인용과 함께 매칭 리포트로 제공. '디자인 진단', '디자인 감사', 'design audit', '디자인 체크', '디자인 상태', '디자인 분석', '디자인 리뷰', '내 앱 디자인', '우리 앱 디자인', '디자인 시스템 추천', '어떤 디자인이 어울려', '어떤 디자인이 맞을까', 'DESIGN.md 추천', '디자인 매칭', '디자인 벤치마크', 'awesome-design-md' 요청 시 사용. 플랫폼 무관(iOS/Web/Android/토큰) 입력을 받아 Top-3 매칭 리포트 + 각 브랜드의 정확한 디자인 토큰을 제공하며, getdesign CLI로 DESIGN.md를 설치한 경험과 동등하게 동작함."
model: opus
argument-hint: "[<대상 경로|screenshot|서술> --platform ios|web|android|any]"
---

<example>
user: "내 iOS 앱 디자인 진단해줘"
assistant: "design-audit 모드로 전환. Xcode 프로젝트의 색상·폰트·컴포넌트 토큰을 스캔하고, awesome-design-md 69개 브랜드 중 Top-3 매칭을 리포트로 제공합니다."
</example>

<example>
user: "우리 웹 앱에 어떤 디자인 시스템이 어울릴까? 스크린샷 첨부"
assistant: "design-audit 모드로 전환. 스크린샷의 색상/타이포/밀도/무드를 추출하고, 카탈로그 인덱스와 매칭해 Top-3를 선정합니다."
</example>

<example>
user: "'다크 미니멀, 보라 포인트, 개발자 도구 느낌' 이런 방향이야. 맞는 DESIGN.md 추천해줘"
assistant: "서술형 입력을 파싱해 trait 벡터(무드/색상/카테고리)를 구성하고, matching-rubric으로 Top-3를 리포트합니다."
</example>

# design-audit

현재 앱의 디자인 상태를 진단(audit)하고, VoltAgent의 [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) 카탈로그에서 가장 적합한 브랜드 디자인 시스템 Top-3를 매칭해 **리포트**(정확한 hex·폰트·수치 인용 포함)를 생성한다.

## 동등성 원칙 — getdesign CLI와의 경험 동등

이 스킬은 `npx getdesign@latest add <slug>`로 DESIGN.md를 설치해 작업하는 경험과 **동등한 결과**를 제공해야 한다. 이를 위해:

- **전체 본문 내재화**: 69개 브랜드의 실제 `DESIGN.md` 본문이 `$REF/designs/*.md`에 바이트 수준으로 복제되어 있다. 요약·재구성 없음.
- **정확한 인용**: 리포트에서 브랜드 토큰(색상 hex, 폰트 패밀리, 수치)을 언급할 때는 본문에서 직접 읽어 인용하고 의역하지 않는다.
- **출처 보존**: `$REF/designs/manifest.json`에 원본 sha256 해시·commit·갱신일이 보존되며, `$REF/designs/ATTRIBUTION.md`에 MIT 라이선스·귀속 정보가 기록된다.

사용자가 선택한 브랜드를 프로젝트에 설치하고 싶다면 `npx getdesign@latest add <slug>` 커맨드도 보조로 제공한다(선택 사항).

## 경로 규약

이 스킬은 설치 환경에 따라 절대 경로가 달라진다(예: 리포지토리 직접 사용 시와 `~/.claude/plugins/cache/.../design-audit/` 배치 시). 본 문서의 모든 경로는 **이 SKILL.md가 위치한 스킬 디렉토리 기준의 상대 경로**이며, 축약 기호는 다음과 같다:

```
$SKILL = 이 SKILL.md가 위치한 디렉토리 (절대경로는 런타임에서 결정)
$REF   = $SKILL/references
```

**Read 도구 호출 규칙**: Read 도구는 절대 경로를 요구하므로, `Read $REF/designs/stripe.md` 예시를 볼 때 Claude는 SKILL.md가 로드된 절대 경로를 기반으로 `<스킬 절대경로>/references/designs/stripe.md`를 구성해 호출한다. 하드코딩된 `plugins/...` 경로를 절대 사용하지 말라.

**Bash 스크립트 호출 규칙**: `$SKILL/scripts/*.sh`를 실행할 때는 `$CLAUDE_PLUGIN_ROOT` 환경변수 또는 SKILL.md 로드 시점의 절대 경로를 이용하라. 스크립트 내부는 `BASH_SOURCE` 기반으로 자체 경로를 해석하므로, 호출만 올바르면 내부 로직은 이식 가능하다.

## 스코프와 비스코프

| 스코프 (스킬이 수행) | 비스코프 (스킬이 하지 않음) |
|---------------------|---------------------------|
| 현재 앱의 디자인 토큰·무드·카테고리 추출 | 실제 코드의 색상/폰트 교체 |
| 69개 DESIGN.md 본문 내재화 기반 Top-3 매칭 | 플랫폼별 토큰 코드 생성 |
| Top-3 브랜드의 정확한 hex·폰트·수치 인용 | SwiftUI/CSS/Compose 변환 구현 |
| 선택 근거·트레이드오프·대비 참고 제시 | 설치 실행(사용자가 직접 수행) |

플랫폼별 토큰 변환·적용이 필요하면 **design-craft** 스킬로 전환한다. 디자이너·화가 기반 생성이 필요하면 **design-research + design-craft** 조합을 사용한다.

## 입력 소스

세 가지 입력을 단독 또는 결합해 사용한다. 결합할수록 정확도가 높다.

1. **코드/토큰 파일** — SwiftUI Color, Asset Catalog, CSS 변수, Tailwind config, Android colors.xml, design tokens JSON
2. **스크린샷** — 사용자가 제공하거나 Simulator/브라우저에서 캡처한 이미지(Read 도구로 시각 분석)
3. **서술형** — "다크 미니멀, 보라 포인트, 개발자 도구" 같은 자연어 설명

## 워크플로우

### Phase 0: 입력 파악

입력 타입을 확정하라:

- 프로젝트 경로가 주어지면 → **코드 추출 모드**로 진행
- 이미지 파일/스크린샷이 첨부되면 → **시각 분석 모드**로 진행
- 텍스트 설명만 주어지면 → **서술 파싱 모드**로 진행
- 아무것도 없으면 → 최소 1가지 소스를 요구(AskUserQuestion 사용 가능)

`--platform ios|web|android|any` 인수로 추출 전략을 분기한다. 기본값은 `any`(플랫폼 무관 토큰만).

### Phase 1: 디자인 상태 추출

`$REF/extraction-guide.md`를 반드시 로드하고 섹션 중 해당 플랫폼 블록을 따른다. 추출 결과는 다음 6개 필드를 가진 **trait 벡터**로 구조화한다:

| 필드 | 내용 | 예시 |
|------|------|------|
| palette | 주요 색상 3~5개 + 명도 극값 | `#0A0A0A`, `#8B5CF6`, `#F5F5F4` / 초저명도+고채도보라 |
| typography | 패밀리 + 주요 weight | `Geist`, weight 400/600 / 모노 `JetBrains Mono` |
| density | 여백/컴포넌트 밀도 | loose / moderate / dense |
| mood | 분위기 키워드 3개 | `minimal`, `dark`, `developer` |
| surface | 배경/카드 처리 | flat / elevated / gradient |
| category | 추정 업종 | `developer-tool`, `fintech`, `ai-llm`, ... |

**추출이 불가능한 필드**는 `unknown`으로 표기하고 리포트에 명시한다. 없는 데이터를 추측으로 채우지 말라.

### Phase 2: 1차 매칭 (인덱스 기반 스크리닝)

`$REF/catalog-index.md`를 반드시 로드하라. 69개 브랜드를 9개 카테고리로 구조화한 인덱스다. 각 엔트리는 `slug | category | file | one_liner | traits[]`를 가진다.

`$REF/matching-rubric.md`의 스코어링 공식으로 **Top-5 후보**를 산출한다:

```
score(brand) = palette_match * 0.30
             + mood_match    * 0.25
             + category_fit  * 0.20
             + typography_fit * 0.15
             + density_fit   * 0.10
```

Top-5에서 Top-3를 확정하기 전에 **Phase 3의 본문 검증**을 먼저 수행한다. 다음 규칙을 준수하라:

- **카테고리 편향 방지**: Top-3가 모두 같은 카테고리면 2위를 다른 카테고리 후보로 교체 검토
- **근거 필수**: 각 매칭에 "어떤 trait가 일치했는지" 최소 2개 인용
- **트레이드오프 기재**: 장점뿐 아니라 "이 브랜드를 적용하면 희생되는 특성"도 리포트

### Phase 3: 2차 매칭 (본문 정밀 검증)

Top-5 후보 각각에 대해 `$REF/designs/{slug}.md`를 **Read 도구로 반드시 로드**하라. 이 파일은 원본 DESIGN.md 본문의 바이트 수준 복제본이다.

본문에서 아래 정보를 추출해 벡터와 재대조하라:

1. **Section 1 — Visual Theme & Atmosphere**: 무드 키워드 재확인
2. **Section 2 — Color Palette & Roles**: 실제 hex 값 (예: Stripe Purple `#533afd`)
3. **Section 3 — Typography Rules**: 실제 폰트 패밀리명 (예: `sohne-var`, `SF Pro`)
4. **Section 7 — Do's and Don'ts**: 사용자 앱과 충돌 가능한 가이드라인 식별

본문 정보가 인덱스 one_liner와 불일치하면 **본문을 우선**하고 재스코어링한다. 예: 인덱스에는 `purple`로만 태그된 브랜드가 본문에서는 `#6366F1`(indigo)로 드러나면 palette_match를 재계산.

재스코어링 후 Top-3를 확정한다. 정보 수집이 Top-5로 충분하지 않으면 Top-7까지 확장 가능.

### Phase 4: 리포트 생성

`$REF/report-template.md`의 섹션 구조를 정확히 따른다. 리포트는 다음 7개 섹션으로 구성한다:

1. **요약** — 현재 앱 trait 벡터 (6필드)
2. **Top-3 매칭** — 브랜드별 점수, 근거, 트레이드오프
3. **Top-3 디자인 토큰 발췌** — 각 브랜드 DESIGN.md 본문에서 **실측** 팔레트·타이포·핵심 수치 인용 (의역 금지)
4. **선택 가이드** — 어떤 상황에 어떤 후보가 맞는가
5. **본문 전체 경로** — `Read $REF/designs/{slug}.md` + 보조 설치 커맨드
6. **주의사항** — 데이터 한계, 검증되지 않은 추론
7. **다음 단계** — 선택 후 design-craft로 토큰 변환 or 직접 설치

리포트는 마크다운 텍스트로 출력한다. 파일 저장이 필요하면 사용자에게 경로를 물어본다.

### Phase 5: 후속 작업 제안

리포트 출력 직후 사용자에게 단 하나의 후속 옵션만 제시한다:

- "Top-3 중 X를 골랐다면 → 본문 전체 로드 확장 / 설치 커맨드 실행 / design-craft로 토큰 변환"

자동으로 코드를 수정하지 말라. 사용자 승인 없이는 여기서 종료한다.

## 카탈로그 신선도

`$REF/catalog-index.md`는 awesome-design-md README의 스냅샷이다(현재 69개 브랜드). 신선도가 의심되면:

```bash
bash $AUDIT/scripts/fetch-catalog-diff.sh
```

이 스크립트는 원격 README.md와 로컬 인덱스를 비교해 신규·삭제된 브랜드를 출력한다. 차이가 발견되면 `$REF/catalog-index.md`를 갱신할지 사용자에게 묻는다.

## 입력 소스별 세부 지침

### 코드/토큰 파일 모드

플랫폼 블록은 `$REF/extraction-guide.md`의 해당 섹션을 참조하라. 핵심 탐색 패턴은 다음과 같다:

- **iOS**: `**/*.xcassets/**/Contents.json`, `Color(red:green:blue:)`, `Color("Asset")`, `Font.custom`, `.font(.system)`
- **Web**: `:root { --color-* }`, `tailwind.config.*`, `theme.extend.colors`, 전역 CSS 변수
- **Android**: `res/values/colors.xml`, `Theme.kt`, `MaterialTheme.colorScheme`
- **플랫폼 무관**: `design-tokens.json`, `tokens.yaml`, `*.tokens.*`

Glob/Grep으로 파일을 찾고 Read로 정확한 값을 읽어라. 추측한 색상을 벡터에 넣지 말라.

### 스크린샷 모드

Read 도구로 이미지를 열고 다음을 식별하라:

- **Dominant hex** 3~5개(대략치 허용, `#2E2A2B` 수준 정밀도)
- **Typography**: serif vs sans vs mono, weight 대비 강약
- **Density**: 화면당 요소 개수, 패딩 면적비
- **Mood**: dark/light, flat/gradient, editorial/functional

여러 장이 제공되면 공통 trait를 우선하고 화면별 차이는 별도 노트로 기록하라.

### 서술형 모드

자연어 설명에서 6필드를 추출하라. 누락된 필드는 `unknown` 처리하고 사용자에게 보강 질문을 최대 2개 제시하라:

- "주 색상은 무엇인가? (hex 또는 이름)"
- "타이포 방향은 serif/sans/mono 중 어느 쪽인가?"

질문이 3개 이상 필요하면 불확실성을 허용하고 `unknown`으로 진행하라.

## 에이전트 위임

단일 스킬 턴에서 부담되는 대량 코드 스캔은 Explore 서브에이전트로 위임할 수 있다:

```
Agent(subagent_type=Explore,
      description="앱 디자인 토큰 스캔",
      prompt="<플랫폼별 glob 패턴 + 추출 기준>. Top 색상 5개와 폰트 패밀리만 리포트. 200단어 이내.")
```

위임 후 trait 벡터 조립과 매칭은 메인 스레드에서 수행한다.

## 한계와 주의

- **카탈로그 스냅샷 시점**: 내재화 시점은 `getdesign@0.6.8` (2026-04-24). 상류가 갱신되면 `scripts/fetch-catalog-diff.sh`가 차이를 감지하며, `scripts/sync-designs.sh`로 재동기화한다.
- **"비슷함"은 기본값이 아님**: 가장 비슷한 브랜드가 반드시 최선은 아니다. 리포트에 "대비 브랜드"(완전히 다른 방향의 1~2개)를 참고로 포함해 사용자 상상력을 확장하라.
- **브랜드 상표**: 본 스킬이 제공하는 토큰 수치는 공개 CSS 값에서 추출한 디자인 시스템 기록이며, 각 브랜드의 로고·상표·시각 정체성 권리는 해당 회사에 귀속된다. 상업적 사용 전 법률 검토 필요.

## Additional Resources

### Reference Files

- **`references/catalog-index.md`** — 69개 브랜드 카테고리·슬러그·trait·로컬 파일 경로 인덱스
- **`references/designs/*.md`** — 69개 브랜드의 전체 DESIGN.md 본문 (awesome-design-md 원본 바이트 복제)
- **`references/designs/manifest.json`** — 각 파일의 sha256 해시·sourceCommit·갱신일
- **`references/designs/ATTRIBUTION.md`** — MIT 라이선스 전문 및 출처 귀속
- **`references/extraction-guide.md`** — iOS/Web/Android/플랫폼무관 입력별 추출 전략과 glob 패턴
- **`references/matching-rubric.md`** — Trait 벡터 vs 카탈로그 매칭 스코어링 공식 (+ 본문 재스코어링 규칙)
- **`references/report-template.md`** — Top-3 리포트 마크다운 구조 (7섹션 — 본문 토큰 발췌 포함)

### Scripts

- **`scripts/fetch-catalog-diff.sh`** — 원격 npm 패키지(`getdesign`) 최신 tarball의 `manifest.json`과 로컬 해시 비교해 변경 감지
- **`scripts/sync-designs.sh`** — 상류 변경을 발견했을 때 새 tarball로부터 `references/designs/`를 재동기화
- **`scripts/fetch-design-md.sh`** — 슬러그의 로컬 본문을 즉시 출력하고 보조로 설치 커맨드·URL 안내

### 관련 스킬

- **design-craft** — Top-3에서 브랜드를 선택한 후 플랫폼별 토큰으로 변환할 때 사용
- **design-research** — 디자이너·화가 기반 토큰이 필요할 때 사용 (브랜드 기반과 대비)
