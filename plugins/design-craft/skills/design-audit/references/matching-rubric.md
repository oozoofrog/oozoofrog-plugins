# Matching Rubric — Trait 벡터 vs 카탈로그 매칭 스코어링

**두 단계 매칭 구조**:

- **Phase 2 (인덱스 스크리닝)**: `catalog-index.md`의 one_liner·traits만으로 Top-5 후보를 산출한다. 값싼 키워드 매칭.
- **Phase 3 (본문 정밀 검증)**: Top-5 각각에 대해 `references/designs/{slug}.md`의 Section 2~3을 Read로 로드해 palette·typography를 재스코어링한다. 인덱스와 본문이 불일치하면 본문을 우선.

아래 공식은 두 단계 모두 적용되나, Phase 3에서는 palette_match·typography_fit의 가중치가 실제 hex·폰트명에 근거해 더 엄밀하게 계산된다.

## 스코어 공식

```
score(brand) = 0.30 * palette_match
             + 0.25 * mood_match
             + 0.20 * category_fit
             + 0.15 * typography_fit
             + 0.10 * density_fit
```

각 서브점수는 `[0, 1]` 구간. 가중치 합은 1.0.

## 서브 스코어 산출

### palette_match (0.30)

**Phase 2 (인덱스 기반)**: 사용자 palette 색상가족을 정규화하고 브랜드 traits에서 색상 키워드와 대조:

| 일치 단계 | 점수 |
|-----------|------|
| 주 포인트색 가족 정확 일치 (purple ↔ purple) | 1.0 |
| 유사 색상가족 (purple ↔ violet, pink-purple) | 0.7 |
| 보조색 수준의 부분 일치 | 0.4 |
| 서브 명도(dark/light) 일치만 있음 | 0.3 |
| 불일치 | 0.0 |

**Phase 3 (본문 기반 정밀 재계산)**: `references/designs/{slug}.md` Section 2의 실제 hex 값을 파싱하여 사용자 palette와 HSL 거리로 재계산한다:

```
distance(userHex, brandHex) = |ΔH|/180 + |ΔS|/100 + |ΔL|/100  # 각 구성요소 정규화
# 1.0 - min(distance, 1.0) 을 가중합해 palette_match 재산출
```

Phase 3 재계산 결과가 Phase 2 점수와 `±0.15` 이상 다르면 본문 기반 값을 채택하고 재랭킹한다. 예: 인덱스에서 `purple`로 태그된 Stripe가 본문에서 `#533afd`(순도 높은 violet)임이 드러나면 사용자의 "soft lavender"와는 예상보다 거리가 멀어 점수가 하향될 수 있다.

**주의**: 사용자가 "다크 + 중성"이면 `mono` 기반 브랜드(`uber`, `spacex`, `x.ai`)가 높게, "다크 + 포인트"면 `supabase`(emerald), `linear.app`(purple), `kraken`(purple)가 높게 나와야 한다.

### mood_match (0.25)

사용자 mood 키워드와 브랜드 traits 키워드의 Jaccard 유사도 × 1.0:

```
mood_match = |user_mood ∩ brand_traits| / |user_mood ∪ brand_traits|
```

키워드는 `catalog-index.md`의 Mood 사전으로 정규화한 뒤 비교한다. `minimal` ≡ `austere` ≡ `sparse`, `premium` ≡ `elegant` 같은 동의어는 사전에서 묶어라:

- `minimal` = {minimal, austere, sparse, subtraction}
- `premium` = {premium, elegant, luxury}
- `playful` = {playful, friendly, illustration}
- `editorial` = {editorial, magazine, serif-headings}
- `cinematic` = {cinematic, full-bleed, photo}
- `bold` = {bold, monumental, uppercase}

### category_fit (0.20)

| 일치 단계 | 점수 |
|-----------|------|
| 동일 카테고리 | 1.0 |
| 인접 카테고리 (developer-tool ↔ backend-devops) | 0.7 |
| 무관 카테고리 | 0.3 |
| `unknown` | 0.5 (페널티 없음) |

**인접 카테고리 테이블**:

| 카테고리 | 인접 |
|----------|------|
| AI & LLM | Developer Tools, Backend |
| Developer Tools | AI & LLM, Backend |
| Backend | Developer Tools, Productivity |
| Productivity | Backend, Design Tools |
| Design Tools | Productivity, Media |
| Fintech | Productivity, Media |
| E-commerce | Media, Design Tools |
| Media | E-commerce, Automotive |
| Automotive | Media, E-commerce |

### typography_fit (0.15)

**Phase 2 (인덱스 기반)**:

| 사용자 typography | 브랜드 키워드 | 점수 |
|-------------------|--------------|------|
| mono 계열 | `mono`, `geist`, `terminal` | 1.0 |
| sans (모던) | `geist`, `neo-grotesk`, `sans` | 1.0 |
| serif | `serif`, `editorial`, `magazine` | 1.0 |
| uppercase heavy | `uppercase`, `monumental`, `bold` | 1.0 |
| 불일치 | | 0.3 |
| `unknown` | | 0.5 |

**Phase 3 (본문 기반 정밀 재계산)**: `references/designs/{slug}.md` Section 3의 실제 font-family 문자열을 파싱. 동일 패밀리명이 있으면 1.0, 동일 카테고리(둘 다 mono/sans/serif)면 0.7, 다르면 0.3. 예: 사용자 앱이 `Geist`를 쓰고 Vercel 본문에도 `Geist`가 명시되면 최고점.

### density_fit (0.10)

| 사용자 density | 궁합 브랜드 특성 | 점수 |
|----------------|-----------------|------|
| loose | `minimal`, `premium`, `sparse`, `cinematic` | 1.0 |
| moderate | `clean`, `structured`, `editorial` | 1.0 |
| dense | `dashboard`, `data-dense`, `trading`, `docs` | 1.0 |
| 반대 특성 | | 0.2 |
| `unknown` | | 0.5 |

## Top-3 선정 후처리

1. **카테고리 편향 방지**: Top-3가 같은 카테고리로만 채워지면 2위를 인접 카테고리 후보로 교체 검토. 단 2위와 신규 후보의 점수 차이가 `0.05` 이내여야 한다.
2. **동점 tiebreaker**: 동점이 나오면 사용자 palette의 주 포인트색이 brand traits에 직접 명시된 쪽을 우선.
3. **대비 브랜드 제시**: Top-3와 무드·색상이 정반대인 브랜드 1개를 "Contrast reference"로 추가 제공. 예: Top-3가 모두 `dark/minimal`이면 `zapier`(warm orange friendly)를 대비로.

## 근거(근거 문장) 요건

각 Top-3 매칭에 아래 3개 문장을 반드시 포함하라:

1. **Match**: "사용자 trait의 X가 브랜드 trait Y와 일치 (score: 0.XX)"
2. **Gain**: "이 브랜드를 채택하면 얻는 특성 1개"
3. **Loss**: "이 브랜드를 채택하면 희생되는 특성 1개"

Loss 문장이 비어있으면 매칭의 회의적 검토가 부족하다는 신호다. 억지로라도 트레이드오프를 1개 기술하라.

## 실패 케이스 처리

- **전체 후보 점수 < 0.4**: 카탈로그 내 적합 브랜드가 없다는 뜻. 리포트에 "카탈로그 내 강한 매칭 없음"을 명시하고 사용자에게 다음 경로를 제시:
  - 범위 확장: `--platform any` 또는 카테고리 제약 해제
  - 대안: `design-research` 스킬(디자이너/화가 기반) 사용
- **점수 상위 3개가 0.05 이내로 밀집**: "어느 쪽이든 큰 차이 없음, 선택은 브랜드 선호로" 명시.

## 샘플 계산

사용자 trait:
- palette: `["#0A0A0A", "#8B5CF6", "#F5F5F4"]` (dark + purple)
- mood: `["minimal", "developer"]`
- category: `developer-tool`
- typography: `mono`
- density: `moderate`
- surface: `dark`

후보 `linear.app` (traits: minimal, purple, precise / category: Productivity / typography: sans / density: moderate):

- palette_match = 1.0 (purple 정확 일치) × 0.30 = **0.30**
- mood_match = |{minimal} ∩ {minimal, precise}| / |{minimal, developer} ∪ {minimal, precise}| = 1/3 ≈ 0.33 × 0.25 = **0.08**
- category_fit = 0.7 (인접) × 0.20 = **0.14**
- typography_fit = 0.3 (mono ≠ sans) × 0.15 = **0.045**
- density_fit = 1.0 (moderate 직접 일치) × 0.10 = **0.10**

**total = 0.665**

후보 `supabase` (dark, emerald, code / Backend / mono / moderate):

- palette_match = 0.3 (dark만 일치, emerald ≠ purple) × 0.30 = **0.09**
- mood_match = |{developer}∩{code}|(code≡developer 사전 매핑 시 1/2=0.5) × 0.25 = **0.125**
- category_fit = 0.7 × 0.20 = **0.14**
- typography_fit = 1.0 × 0.15 = **0.15**
- density_fit = 1.0 × 0.10 = **0.10**

**total = 0.605**

두 후보 모두 0.6대. 리포트에 둘 다 포함하고 Loss/Gain으로 구분한다.
