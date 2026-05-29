# Extraction Guide — App Design State Extraction

Platform- and source-specific extraction strategies used in Phase 1. Branch on the input type first, then follow only the matching section.

## Common Principles

- Do not guess; record **measured values only** in the trait vector. Use `unknown` for uncertain fields.
- Limit extraction scope to the app's **actual in-use colors/fonts**. Brand assets like `Assets.xcassets/AppIcon.appiconset` may be excluded, but core palette files (`Colors`, `tokens`) must be included.
- Delegate large file scans to the Explore subagent. Ask the subagent for "only the Top 5 colors + font families + spacing scale, summarized in under 200 words".

## iOS / macOS Mode

### Search Paths (priority order)

1. **Asset Catalog color sets**: `**/*.xcassets/**/Contents.json` containing the `"colors"` key
2. **Design token Swift files**: `**/*Color*.swift`, `**/*Token*.swift`, `**/*Palette*.swift`, `**/*Theme*.swift`
3. **Font definitions**: `**/*Font*.swift`, `UIAppFonts` in `Info.plist`
4. **SwiftUI call sites** (if needed): locations using `.font(...)`, `Color(...)`, `.foregroundColor(...)`

### Extraction Patterns

```
# color search
rg "Color\((red|\.sRGB|#)" --glob '*.swift'
rg "Color\(\"[^\"]+\"\)" --glob '*.swift'
rg "UIColor\((red|displayP3|named:)" --glob '*.{swift,m}'

# font search
rg "Font\.(custom|system)" --glob '*.swift'
rg "\.font\(" --glob '*.swift' | head -50

# Asset Catalog color hex
find . -name "Contents.json" -path "*.colorset*" | head -30
```

The inside of an Asset Catalog `Contents.json` is JSON:

```json
"components" : {
  "red" : "0xFF", "green" : "0x80", "blue" : "0x00", "alpha" : "1.000"
}
```

Normalize hexadecimal to decimal and convert to hex (`0xFF 0x80 0x00` → `#FF8000`).

### Field Mapping

| trait field | extraction source | normalization rule |
|------------|----------|-------------|
| palette | Top 5 colors by usage frequency (hex) | sort descending by brightness |
| typography | `Font.custom("...")` argument + system default | custom > system priority |
| density | median of the top 5 `.padding()` values | `<8` dense, `8~20` moderate, `>20` loose |
| mood | saturation/brightness distribution of color hex + font characteristics | choose among `minimal`/`bold`/`playful`/`premium` |
| surface | usage frequency of `.background(.ultraThinMaterial)`, `.shadow`, gradient | flat/elevated/gradient |
| category | inferred from app name / README | 1 of 9 categories or `unknown` |

## Web Mode

### Search Paths (priority order)

1. **CSS variables**: `:root {`, `--color-`, `--font-`, `--space-` declarations
2. **Tailwind config**: `theme.extend.colors` in `tailwind.config.{js,ts,cjs,mjs}`
3. **Design tokens JSON**: `design-tokens.json`, `tokens.yaml`, `**/*.tokens.*`
4. **Global styles**: `app/globals.css`, `styles/theme.*`, `src/styles/*`
5. **Component library config**: `shadcn`/`chakra`/`mantine` theme files

### Extraction Patterns

```
# CSS variables
rg "^\s*--color-" --glob '*.{css,scss,sass}' | head -40
rg "^\s*--font-|--text-" --glob '*.{css,scss,sass}' | head -20

# Tailwind
rg "theme:\s*\{" --glob 'tailwind.config.*' -A 40
rg "extend:\s*\{" --glob 'tailwind.config.*' -A 60

# Design tokens
fd -e json -e yaml -e yml . -t f | rg -i 'token|palette|theme' | head -20
```

### Field Mapping

| trait field | extraction source | normalization rule |
|------------|----------|-------------|
| palette | top 5 of CSS variable `--color-*` values | prioritize semantic names (`primary`, `surface`) |
| typography | `--font-*`, `font-family` declarations | only those actually used in body/heading |
| density | Tailwind `spacing` scale or `--space-*` | dense if base unit is `4px` or less |
| mood | background brightness + accent color saturation | |
| surface | `box-shadow` variable / gradient usage | |
| category | `package.json` name + README | |

## Android (Jetpack Compose) Mode

### Search Paths

1. **Material3 Theme**: `**/ui/theme/Color.kt`, `Theme.kt`, `Type.kt`
2. **colors.xml**: `app/src/main/res/values/colors.xml`, `values-night/colors.xml`
3. **Typography resources**: `font/*.xml`, `res/values/fonts.xml`

### Extraction Patterns

```
rg "val\s+\w+\s*=\s*Color\(0x[0-9A-Fa-f]{8}\)" --glob '*.kt'
rg "<color name=" --glob 'colors.xml'
rg "TextStyle\(" --glob 'Type.kt' -A 5
```

Convert `0xFF2563EB` → `#2563EB` (drop the leading 2 alpha digits).

### Field Mapping

Adopt the Compose `ColorScheme`'s `primary`, `secondary`, `surface`, `background` as the top 4 of trait.palette. The `Typography`'s `bodyLarge`, `headlineLarge` fonts are the primary typography.

## Platform-Agnostic / Design Tokens Mode

### Supported Formats

- [Design Tokens Community Group](https://design-tokens.github.io/community-group/) JSON format (`$value`, `$type`)
- Style Dictionary structure (`color.primary.value`)
- Tailwind config (see Web Mode above)
- Figma Tokens Studio export

### Search Pattern

```
fd -e json -e yaml -e yml | rg -i 'tokens|design-tokens|palette'
```

### Field Mapping

Read paths like `color.primary`, `color.surface.background`, `typography.heading.fontFamily`, `size.spacing.md` directly from the token file and map them to the trait vector. If a semantic name exists, place `primary` at `palette[0]`.

## Screenshot Mode

Open the image with the Read tool and observe in this order:

1. **Background brightness judgment**: dark (#000~#2A) / light (#F0~#FF) / midtone
2. **Accent color identification**: approximate hex of the 1~2 most saturated colors
3. **Typography family**: serif (serif protrusions) / sans (uniform stroke weight) / mono (uniform width)
4. **Component density**: number of major elements visible on screen and whitespace ratio
5. **Mood judgment**: editorial (lots of whitespace, text-centric) / functional (information density, dashboard) / cinematic (high saturation, full-bleed) / playful (rounded, illustration)

If there are multiple screenshots, **prioritize common traits** and record per-screen differences in `notes`.

### Hex Approximation Allowed

Since exact hex cannot be extracted from a screenshot, 2-digit precision like `#2E2A2B` is sufficient. However, classify **brightness, saturation, and color family** clearly:

- distinguish "dark neutral" vs "dark warm" (`#1A1A1A` vs `#1F1815`)
- distinguish "saturated purple" vs "soft lavender"

## Descriptive Mode

Find the patterns below in the natural-language description and fill in traits:

| input keyword example | mapped field |
|-----------------|-----------|
| "dark", "nighttime" | surface=dark, add `dark` to mood |
| "minimal", "simple", "whitespace" | add `minimal` to mood, density=loose |
| "purple" | add purple family to palette |
| "developer tool", "IDE" | category=developer-tool |
| "premium", "high-end" | add `premium` to mood |
| "friendly", "cute", "rounded" | add `playful`/`friendly` to mood, rounded to surface |
| "cinematic" | add `cinematic` to mood |
| "editorial", "magazine" | add `editorial` to mood, serif possibility in typography |

If 3 or more fields are missing from the description, ask the user at most 2 follow-up questions and proceed with `unknown` for the rest.

## Result Verification

Once the trait vector is complete, perform a **self-check**:

- Does palette have 3 or more hex values?
- Does mood have at least 1 entry?
- Are surface and density not contradictory? (e.g., dense + line-only editorial type may be inconsistent)

If there is a contradiction, confirm with the user before Phase 2 matching.
