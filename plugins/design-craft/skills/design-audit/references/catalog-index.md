# awesome-design-md 카탈로그 인덱스

VoltAgent [awesome-design-md](https://github.com/VoltAgent/awesome-design-md)의 **전체 DESIGN.md 본문 69개**를 스킬 내부(`references/designs/*.md`)에 내재화하여 그대로 사용하는 인덱스. 원본 npm 패키지 `getdesign@0.6.8` tarball을 복제하였으며 라이선스·귀속은 `references/designs/ATTRIBUTION.md` 참조.

## 핵심 원칙

- **동등 경험**: getdesign CLI로 설치한 DESIGN.md를 사용하는 경험과 본 스킬 사용 경험은 동일해야 한다. 정확한 hex, 폰트, 수치, 컴포넌트 스펙이 모두 보존되어 있다.
- **바이트 수준 복제**: 원본과 동일 파일명·동일 내용. 요약·재구성하지 않았다. sha256 해시는 `references/designs/manifest.json`에 보존.
- **본문 로드 경로**: Phase 3에서 Top-3 선정 후 `Read` 도구로 `plugins/design-craft/skills/design-audit/references/designs/{slug}.md`를 즉시 로드한다.

## 스키마

각 엔트리는 다음 필드를 가진다:

| 필드 | 설명 |
|------|------|
| `slug` | URL 및 파일명 (예: `stripe`, `linear.app`, `x.ai`) |
| `brand` | 표기명 |
| `category` | 9개 카테고리 중 하나 |
| `file` | 로컬 본문 경로 — `references/designs/{slug}.md` |
| `one_liner` | manifest.json 기반 1줄 설명 |
| `traits` | 매칭용 키워드 (one_liner + 본문 첫 문단에서 추출) |

## 접근 경로

- **스킬 내부 (권장)**: `Read plugins/design-craft/skills/design-audit/references/designs/{slug}.md` — 로그인 불필요, 즉시 접근
- **npm 설치 (대안)**: `npx getdesign@latest add <slug>` — 프로젝트 루트에 원본 설치
- **웹 확인**: `https://getdesign.md/<slug>/design-md`

URL·파일명에는 점이 포함된 슬러그가 있다: `linear.app`, `mistral.ai`, `x.ai`, `opencode.ai`, `together.ai` — 파일도 정확히 `linear.app.md`로 저장.

---

## AI & LLM Platforms (12)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| claude | Claude | `designs/claude.md` | Anthropic's AI assistant. Warm terracotta accent, clean editorial layout | warm, terracotta, editorial, clean |
| cohere | Cohere | `designs/cohere.md` | Enterprise AI platform. Vibrant gradients, data-rich dashboard aesthetic | gradient, vibrant, dashboard, enterprise |
| elevenlabs | ElevenLabs | `designs/elevenlabs.md` | AI voice platform. Dark cinematic UI, audio-waveform aesthetics | dark, cinematic, audio, waveform |
| minimax | Minimax | `designs/minimax.md` | AI model provider. Bold dark interface with neon accents | dark, bold, neon |
| mistral.ai | Mistral AI | `designs/mistral.ai.md` | Open-weight LLM provider. French-engineered minimalism, purple-toned | minimal, purple, refined |
| ollama | Ollama | `designs/ollama.md` | Run LLMs locally. Terminal-first, monochrome simplicity | mono, terminal, simple |
| opencode.ai | OpenCode AI | `designs/opencode.ai.md` | AI coding platform. Developer-centric dark theme | dark, developer |
| replicate | Replicate | `designs/replicate.md` | Run ML models via API. Clean white canvas, code-forward | light, clean, code-forward |
| runwayml | RunwayML | `designs/runwayml.md` | AI video generation. Cinematic dark UI, media-rich layout | dark, cinematic, media |
| together.ai | Together AI | `designs/together.ai.md` | Open-source AI infrastructure. Technical, blueprint-style design | technical, blueprint |
| voltagent | VoltAgent | `designs/voltagent.md` | AI agent framework. Void-black canvas, emerald accent, terminal-native | black, emerald, terminal |
| x.ai | xAI | `designs/x.ai.md` | Elon Musk's AI lab. Stark monochrome, futuristic minimalism | mono, minimal, futuristic |

## Developer Tools & IDEs (7)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| cursor | Cursor | `designs/cursor.md` | AI-first code editor. Sleek dark interface, gradient accents | dark, sleek, gradient |
| expo | Expo | `designs/expo.md` | React Native platform. Dark theme, tight letter-spacing, code-centric | dark, code, tight-type |
| lovable | Lovable | `designs/lovable.md` | AI full-stack builder. Playful gradients, friendly dev aesthetic | gradient, playful, friendly |
| raycast | Raycast | `designs/raycast.md` | Productivity launcher. Sleek dark chrome, vibrant gradient accents | dark, gradient, vibrant |
| superhuman | Superhuman | `designs/superhuman.md` | Fast email client. Premium dark UI, keyboard-first, purple glow | dark, premium, purple |
| vercel | Vercel | `designs/vercel.md` | Frontend deployment platform. Black and white precision, Geist font | mono, black-white, geist |
| warp | Warp | `designs/warp.md` | Modern terminal. Dark IDE-like interface, block-based command UI | dark, terminal, block |

## Backend, Database & DevOps (8)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| clickhouse | ClickHouse | `designs/clickhouse.md` | Fast analytics database. Yellow-accented, technical documentation style | yellow, technical, docs |
| composio | Composio | `designs/composio.md` | Tool integration platform. Modern dark with colorful integration icons | dark, colorful |
| hashicorp | HashiCorp | `designs/hashicorp.md` | Infrastructure automation. Enterprise-clean, black and white | black-white, enterprise |
| mongodb | MongoDB | `designs/mongodb.md` | Document database. Green leaf branding, developer documentation focus | green, developer, docs |
| posthog | PostHog | `designs/posthog.md` | Product analytics. Playful hedgehog branding, developer-friendly dark UI | dark, playful, developer |
| sanity | Sanity | `designs/sanity.md` | Headless CMS. Red accent, content-first editorial layout | red, editorial, content |
| sentry | Sentry | `designs/sentry.md` | Error monitoring. Dark dashboard, data-dense, pink-purple accent | dark, dashboard, pink-purple |
| supabase | Supabase | `designs/supabase.md` | Open-source Firebase alternative. Dark emerald theme, code-first | dark, emerald, code |

## Productivity & SaaS (7)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| cal | Cal.com | `designs/cal.md` | Open-source scheduling. Clean neutral UI, developer-oriented simplicity | neutral, clean, developer |
| intercom | Intercom | `designs/intercom.md` | Customer messaging. Friendly blue palette, conversational UI patterns | blue, friendly, conversational |
| linear.app | Linear | `designs/linear.app.md` | Project management for engineers. Ultra-minimal, precise, purple accent | minimal, purple, precise |
| mintlify | Mintlify | `designs/mintlify.md` | Documentation platform. Clean, green-accented, reading-optimized | green, clean, docs |
| notion | Notion | `designs/notion.md` | All-in-one workspace. Warm minimalism, serif headings, soft surfaces | warm, minimal, serif, soft |
| resend | Resend | `designs/resend.md` | Email API for developers. Minimal dark theme, monospace accents | dark, mono, minimal |
| zapier | Zapier | `designs/zapier.md` | Automation platform. Warm orange, friendly illustration-driven | orange, friendly, illustration |

## Design & Creative Tools (6)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| airtable | Airtable | `designs/airtable.md` | Spreadsheet-database hybrid. Colorful, friendly, structured data aesthetic | colorful, friendly, structured |
| clay | Clay | `designs/clay.md` | Creative agency. Organic shapes, soft gradients, art-directed layout | organic, gradient, art-directed |
| figma | Figma | `designs/figma.md` | Collaborative design tool. Vibrant multi-color, playful yet professional | vibrant, colorful, playful |
| framer | Framer | `designs/framer.md` | Website builder. Bold black and blue, motion-first, design-forward | blue, motion, bold |
| miro | Miro | `designs/miro.md` | Visual collaboration. Bright yellow accent, infinite canvas aesthetic | yellow, canvas |
| webflow | Webflow | `designs/webflow.md` | Visual web builder. Blue-accented, polished marketing site aesthetic | blue, polished, marketing |

## Fintech & Crypto (7)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| binance | Binance | `designs/binance.md` | Crypto exchange. Bold yellow accent on monochrome, trading-floor urgency | yellow, mono, trading |
| coinbase | Coinbase | `designs/coinbase.md` | Crypto exchange. Clean blue identity, trust-focused, institutional feel | blue, clean, institutional |
| kraken | Kraken | `designs/kraken.md` | Crypto trading platform. Purple-accented dark UI, data-dense dashboards | dark, purple, dashboard |
| mastercard | Mastercard | `designs/mastercard.md` | Global payments network. Warm cream canvas, orbital pill shapes, editorial warmth | cream, warm, editorial |
| revolut | Revolut | `designs/revolut.md` | Digital banking. Sleek dark interface, gradient cards, fintech precision | dark, gradient, precise |
| stripe | Stripe | `designs/stripe.md` | Payment infrastructure. Signature purple gradients, weight-300 elegance | purple, gradient, elegant |
| wise | Wise | `designs/wise.md` | International money transfer. Bright green accent, friendly and clear | green, friendly, clear |

## E-commerce & Retail (5)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| airbnb | Airbnb | `designs/airbnb.md` | Travel marketplace. Warm coral accent, photography-driven, rounded UI | coral, warm, photo, rounded |
| meta | Meta | `designs/meta.md` | Tech retail store. Photography-first, binary light/dark surfaces, Meta Blue CTAs | blue, photo, binary |
| nike | Nike | `designs/nike.md` | Athletic retail. Monochrome UI, massive uppercase Futura, full-bleed photography | mono, uppercase, bold |
| shopify | Shopify | `designs/shopify.md` | E-commerce platform. Dark-first cinematic, neon green accent, ultra-light display type | dark, neon-green, cinematic |
| starbucks | Starbucks | `designs/starbucks.md` | Coffee retail flagship. Four-tier earth-green system, warm cream canvas, proprietary SoDoSans typography | green, cream, warm |

## Media & Consumer Tech (11)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| apple | Apple | `designs/apple.md` | Consumer electronics. Premium white space, SF Pro, cinematic imagery | white, premium, cinematic |
| ibm | IBM | `designs/ibm.md` | Enterprise technology. Carbon design system, structured blue palette | blue, structured, enterprise |
| nvidia | NVIDIA | `designs/nvidia.md` | GPU computing. Green-black energy, technical power aesthetic | green, black, technical |
| pinterest | Pinterest | `designs/pinterest.md` | Visual discovery platform. Red accent, masonry grid, image-first | red, masonry, image |
| playstation | PlayStation | `designs/playstation.md` | Gaming console retail. Three-surface channel layout, cyan hover-scale interaction | cyan, channel, gaming |
| spacex | SpaceX | `designs/spacex.md` | Space technology. Stark black and white, full-bleed imagery, futuristic | black-white, futuristic |
| spotify | Spotify | `designs/spotify.md` | Music streaming. Vibrant green on dark, bold type, album-art-driven | dark, green, bold |
| theverge | The Verge | `designs/theverge.md` | Tech editorial media. Acid-mint and ultraviolet accents, Manuka display type | mint, ultraviolet, editorial |
| uber | Uber | `designs/uber.md` | Mobility platform. Bold black and white, tight type, urban energy | black-white, bold, urban |
| vodafone | Vodafone | `designs/vodafone.md` | Global telecom brand. Monumental uppercase display, Vodafone Red chapter bands | red, uppercase, monumental |
| wired | WIRED | `designs/wired.md` | Tech magazine. Paper-white broadsheet density, custom serif, ink-blue links | white, serif, editorial |

## Automotive (6)

| slug | brand | file | one_liner | traits |
|------|-------|------|-----------|--------|
| bmw | BMW | `designs/bmw.md` | Luxury automotive. Dark premium surfaces, precise German engineering aesthetic | dark, premium, precise |
| bugatti | Bugatti | `designs/bugatti.md` | Luxury hypercar. Cinema-black canvas, monochrome austerity, monumental display type | black, mono, austere |
| ferrari | Ferrari | `designs/ferrari.md` | Luxury automotive. Chiaroscuro black-white editorial, Ferrari Red with extreme sparseness | red, black-white, sparse |
| lamborghini | Lamborghini | `designs/lamborghini.md` | Luxury automotive. True black cathedral, gold accent, LamboType custom Neo-Grotesk | black, gold, neo-grotesk |
| renault | Renault | `designs/renault.md` | French automotive. Vivid aurora gradients, NouvelR proprietary typeface, zero-radius buttons | gradient, vivid, aurora |
| tesla | Tesla | `designs/tesla.md` | Electric vehicles. Radical subtraction, cinematic full-viewport photography, Universal Sans | minimal, cinematic, photo |

---

## 카테고리 카운트 (총 69)

- AI & LLM Platforms: 12
- Developer Tools & IDEs: 7
- Backend, Database & DevOps: 8
- Productivity & SaaS: 7
- Design & Creative Tools: 6
- Fintech & Crypto: 7
- E-commerce & Retail: 5
- Media & Consumer Tech: 11
- Automotive: 6

## Trait 키워드 사전

매칭 시 아래 키워드 사전으로 사용자 trait와 브랜드 traits를 정규화하라:

- **Color family**: `black`, `white`, `mono`, `gray`, `red`, `orange`, `yellow`, `green`, `emerald`, `mint`, `blue`, `cyan`, `purple`, `pink`, `gold`, `cream`, `coral`, `terracotta`, `neon`
- **Mood**: `minimal`, `editorial`, `cinematic`, `playful`, `bold`, `premium`, `friendly`, `clean`, `structured`, `urban`, `futuristic`, `warm`, `austere`, `sparse`
- **Surface**: `flat`, `gradient`, `dark`, `light`, `mono`
- **Typography**: `serif`, `sans`, `mono`, `uppercase`, `tight-type`, `geist`, `futura`, `neo-grotesk`, `sohne-var`, `sf-pro`
- **Context**: `developer`, `enterprise`, `fintech`, `gaming`, `automotive`, `retail`, `marketing`, `dashboard`, `docs`, `terminal`

Phase 2 매칭에서는 one_liner·traits·본문 발췌를 모두 활용할 수 있다. 1차 스크리닝은 traits로, 정밀 재평가는 Top-5 후보에 대해 `references/designs/{slug}.md`의 섹션 1~3(Visual Theme / Color Palette / Typography)을 읽어 수행하라.

## 본문 내재화 확인 체크리스트

- [x] 69개 `.md` 파일이 `references/designs/` 에 존재 (`ls` 확인)
- [x] `references/designs/manifest.json` 에 69개 엔트리 (해시·커밋·갱신일 보존)
- [x] `references/designs/ATTRIBUTION.md` 에 MIT 라이선스·출처 명시
- [x] 파일명·본문 바이트 원본과 동일 (getdesign@0.6.8 기준)
