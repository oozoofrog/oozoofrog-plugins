# Extraction Guide — 앱 디자인 상태 추출

Phase 1 단계에서 사용하는 플랫폼별·소스별 추출 전략. 입력 타입을 먼저 분기한 뒤 해당 섹션만 따른다.

## 공통 원칙

- 추측하지 말고 **실측값만** trait 벡터에 기입한다. 불확실한 필드는 `unknown`.
- 추출 반경은 앱의 **진짜 사용 색상/폰트**에 국한한다. `Assets.xcassets/AppIcon.appiconset` 같은 브랜드 에셋은 제외해도 되지만 핵심 팔레트 파일(`Colors`, `tokens`)은 반드시 포함한다.
- 대량 파일 스캔은 Explore 서브에이전트로 위임한다. 서브에이전트에게는 "Top 5 색상 + 폰트 패밀리 + 간격 스케일만 요약, 200단어 이내"로 요청한다.

## iOS / macOS 모드

### 탐색 경로 (우선순위 순)

1. **Asset Catalog 색상 세트**: `**/*.xcassets/**/Contents.json` 중 `"colors"` 키 포함
2. **디자인 토큰 Swift 파일**: `**/*Color*.swift`, `**/*Token*.swift`, `**/*Palette*.swift`, `**/*Theme*.swift`
3. **Font 정의**: `**/*Font*.swift`, `Info.plist`의 `UIAppFonts`
4. **SwiftUI 호출부** (필요 시): `.font(...)`, `Color(...)`, `.foregroundColor(...)` 사용 위치

### 추출 패턴

```
# 색상 검색
rg "Color\((red|\.sRGB|#)" --glob '*.swift'
rg "Color\(\"[^\"]+\"\)" --glob '*.swift'
rg "UIColor\((red|displayP3|named:)" --glob '*.{swift,m}'

# 폰트 검색
rg "Font\.(custom|system)" --glob '*.swift'
rg "\.font\(" --glob '*.swift' | head -50

# Asset Catalog 색상 hex
find . -name "Contents.json" -path "*.colorset*" | head -30
```

Asset Catalog의 `Contents.json` 내부는 JSON이다:

```json
"components" : {
  "red" : "0xFF", "green" : "0x80", "blue" : "0x00", "alpha" : "1.000"
}
```

16진수를 10진수로 정규화하여 hex로 변환하라(`0xFF 0x80 0x00` → `#FF8000`).

### 필드 매핑

| trait 필드 | 추출 소스 | 정규화 규칙 |
|------------|----------|-------------|
| palette | Top 5 사용 빈도 색상(hex) | 명도로 내림차순 정렬 |
| typography | `Font.custom("...")` 인자 + system 기본값 | 커스텀 > 시스템 우선 |
| density | 상위 5개 `.padding()` 값의 중앙값 | `<8` dense, `8~20` moderate, `>20` loose |
| mood | 색상 hex의 채도·명도 분포 + 폰트 특성 | `minimal`/`bold`/`playful`/`premium` 중 선택 |
| surface | `.background(.ultraThinMaterial)`, `.shadow`, gradient 사용 빈도 | flat/elevated/gradient |
| category | 앱 이름·README에서 추정 | 9개 카테고리 중 1개 또는 `unknown` |

## Web 모드

### 탐색 경로 (우선순위 순)

1. **CSS 변수**: `:root {`, `--color-`, `--font-`, `--space-` 선언
2. **Tailwind 설정**: `tailwind.config.{js,ts,cjs,mjs}`의 `theme.extend.colors`
3. **Design tokens JSON**: `design-tokens.json`, `tokens.yaml`, `**/*.tokens.*`
4. **전역 스타일**: `app/globals.css`, `styles/theme.*`, `src/styles/*`
5. **컴포넌트 라이브러리 설정**: `shadcn`/`chakra`/`mantine` 테마 파일

### 추출 패턴

```
# CSS 변수
rg "^\s*--color-" --glob '*.{css,scss,sass}' | head -40
rg "^\s*--font-|--text-" --glob '*.{css,scss,sass}' | head -20

# Tailwind
rg "theme:\s*\{" --glob 'tailwind.config.*' -A 40
rg "extend:\s*\{" --glob 'tailwind.config.*' -A 60

# Design tokens
fd -e json -e yaml -e yml . -t f | rg -i 'token|palette|theme' | head -20
```

### 필드 매핑

| trait 필드 | 추출 소스 | 정규화 규칙 |
|------------|----------|-------------|
| palette | CSS 변수 `--color-*` 값의 상위 5개 | 의미 이름(`primary`, `surface`) 우선 |
| typography | `--font-*`, `font-family` 선언 | 실제 body/heading에 사용된 것만 |
| density | Tailwind `spacing` 스케일 또는 `--space-*` | 기본 단위가 `4px` 이하 dense |
| mood | 배경색 명도 + 포인트색 채도 | |
| surface | `box-shadow` 변수·gradient 사용 | |
| category | `package.json` name + README | |

## Android (Jetpack Compose) 모드

### 탐색 경로

1. **Material3 Theme**: `**/ui/theme/Color.kt`, `Theme.kt`, `Type.kt`
2. **colors.xml**: `app/src/main/res/values/colors.xml`, `values-night/colors.xml`
3. **Typography 리소스**: `font/*.xml`, `res/values/fonts.xml`

### 추출 패턴

```
rg "val\s+\w+\s*=\s*Color\(0x[0-9A-Fa-f]{8}\)" --glob '*.kt'
rg "<color name=" --glob 'colors.xml'
rg "TextStyle\(" --glob 'Type.kt' -A 5
```

`0xFF2563EB` → `#2563EB`로 변환(앞 2자리 alpha 버림).

### 필드 매핑

Compose `ColorScheme`의 `primary`, `secondary`, `surface`, `background`를 trait.palette 상위 4개로 채택. `Typography`의 `bodyLarge`, `headlineLarge` 폰트가 주 typography.

## 플랫폼 무관 / Design Tokens 모드

### 지원 포맷

- [Design Tokens Community Group](https://design-tokens.github.io/community-group/) JSON 포맷 (`$value`, `$type`)
- Style Dictionary 구조 (`color.primary.value`)
- Tailwind config (위 Web 모드 참조)
- Figma Tokens Studio export

### 탐색 패턴

```
fd -e json -e yaml -e yml | rg -i 'tokens|design-tokens|palette'
```

### 필드 매핑

토큰 파일에서 `color.primary`, `color.surface.background`, `typography.heading.fontFamily`, `size.spacing.md` 같은 경로를 직접 읽어 trait 벡터에 매핑한다. 의미 이름이 있으면 `palette[0]`에 `primary`를 배치한다.

## 스크린샷 모드

Read 도구로 이미지를 열고 다음 순서로 관찰하라:

1. **배경 명도 판정**: 다크(#000~#2A) / 라이트(#F0~#FF) / 미드톤
2. **포인트 색상 식별**: 가장 채도 높은 색 1~2개의 대략 hex
3. **타이포 계열**: serif(세리프 돌출) / sans(균등 굵기) / mono(균등 폭)
4. **컴포넌트 밀도**: 화면에 보이는 주요 요소 수와 여백 비율
5. **무드 판정**: editorial(여백 많음·텍스트 중심) / functional(정보 밀도·대시보드) / cinematic(고채도·풀블리드) / playful(라운드·일러스트)

여러 스크린샷이 있으면 **공통 trait를 우선**하고 화면별 차이는 `notes`에 기록하라.

### hex 근사치 허용

스크린샷에서 정확한 hex를 추출할 수 없으므로 `#2E2A2B` 같은 2자리 정밀도로 충분하다. 단 **명도·채도·색상가족**은 분명하게 분류하라:

- "다크 뉴트럴" vs "다크 웜" 구분(`#1A1A1A` vs `#1F1815`)
- "세추레이티드 퍼플" vs "소프트 라벤더" 구분

## 서술형 모드

자연어 설명에서 아래 패턴을 찾아 trait를 채워라:

| 입력 키워드 예시 | 매핑 필드 |
|-----------------|-----------|
| "다크", "어두운", "야간" | surface=dark, mood에 `dark` 추가 |
| "미니멀", "심플", "여백" | mood에 `minimal`, density=loose |
| "보라", "퍼플" | palette에 purple 계열 추가 |
| "개발자 도구", "IDE" | category=developer-tool |
| "프리미엄", "고급" | mood에 `premium` 추가 |
| "친근", "귀여운", "둥글" | mood에 `playful`/`friendly`, surface에 rounded |
| "시네마틱", "영화적" | mood에 `cinematic` |
| "에디토리얼", "매거진" | mood에 `editorial`, typography에 serif 가능성 |

서술에서 누락된 필드가 3개 이상이면 사용자에게 최대 2개 보강 질문만 하고, 나머지는 `unknown`으로 진행한다.

## 결과 검증

trait 벡터가 완성되면 **자체 체크**를 수행하라:

- palette에 hex가 3개 이상 있는가?
- mood가 최소 1개 이상 있는가?
- surface와 density가 모순되지 않는가? (예: dense + 라인만 있는 편집자형은 불일치 가능)

모순이 있으면 Phase 2 매칭 전에 사용자에게 확인한다.
