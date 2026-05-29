# awesome-design-md Catalog Index

Index that internalizes all **69 full DESIGN.md bodies** from VoltAgent [awesome-design-md](https://github.com/VoltAgent/awesome-design-md) inside the skill (`references/designs/*.md`) for direct use. The original npm package `getdesign@0.6.8` tarball was cloned; see `references/designs/ATTRIBUTION.md` for license and attribution.

## Core Principles

- **Equivalent experience**: Using DESIGN.md installed via the getdesign CLI and using this skill must yield the same experience. Exact hex values, fonts, numbers, and component specs are all preserved.
- **Byte-level replication**: Identical filenames and identical content to the original. Not summarized or restructured. sha256 hashes are preserved in `references/designs/manifest.json`.
- **Body load path**: After selecting the Top-3 in Phase 3, immediately load `$REF/designs/{slug}.md` (skill-relative path) with the `Read` tool. At actual call time, construct the path from the absolute path where SKILL.md is located; the repository-relative `plugins/...` path will not work in an installed environment.

## Schema

Each entry has the following fields:

| Field | Description |
|-------|-------------|
| `slug` | URL and filename (e.g., `stripe`, `linear.app`, `x.ai`) |
| `brand` | Display name |
| `category` | One of 9 categories |
| `file` | Local body path — `references/designs/{slug}.md` |
| `one_liner` | One-line description from manifest.json |
| `traits` | Matching keywords (extracted from one_liner + first paragraph of body) |

## Access Paths

- **Inside the skill (recommended)**: `Read $REF/designs/{slug}.md` — no login required, instant access. Claude constructs the Read call from the absolute path at SKILL.md load time. For Bash calls, use `$CLAUDE_PLUGIN_ROOT/skills/design-audit/references/designs/{slug}.md` or `scripts/fetch-design-md.sh <slug>`.
- **npm install (alternative)**: `npx getdesign@latest add <slug>` — installs the original at the project root
- **Web view**: `https://getdesign.md/<slug>/design-md`

Some slugs contain dots in their URL/filename: `linear.app`, `mistral.ai`, `x.ai`, `opencode.ai`, `together.ai` — the file is saved exactly as `linear.app.md`.

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

## Category Counts (total 69)

- AI & LLM Platforms: 12
- Developer Tools & IDEs: 7
- Backend, Database & DevOps: 8
- Productivity & SaaS: 7
- Design & Creative Tools: 6
- Fintech & Crypto: 7
- E-commerce & Retail: 5
- Media & Consumer Tech: 11
- Automotive: 6

## Trait Keyword Dictionary

When matching, normalize user traits and brand traits with the dictionary below:

- **Color family**: `black`, `white`, `mono`, `gray`, `red`, `orange`, `yellow`, `green`, `emerald`, `mint`, `blue`, `cyan`, `purple`, `pink`, `gold`, `cream`, `coral`, `terracotta`, `neon`
- **Mood**: `minimal`, `editorial`, `cinematic`, `playful`, `bold`, `premium`, `friendly`, `clean`, `structured`, `urban`, `futuristic`, `warm`, `austere`, `sparse`
- **Surface**: `flat`, `gradient`, `dark`, `light`, `mono`
- **Typography**: `serif`, `sans`, `mono`, `uppercase`, `tight-type`, `geist`, `futura`, `neo-grotesk`, `sohne-var`, `sf-pro`
- **Context**: `developer`, `enterprise`, `fintech`, `gaming`, `automotive`, `retail`, `marketing`, `dashboard`, `docs`, `terminal`

In Phase 2 matching, you may use one_liner, traits, and body excerpts together. Do first-pass screening with traits, then perform precise re-evaluation on the Top-5 candidates by reading sections 1–3 (Visual Theme / Color Palette / Typography) of `references/designs/{slug}.md`.

## Body Internalization Checklist

- [x] 69 `.md` files exist in `references/designs/` (verified with `ls`)
- [x] `references/designs/manifest.json` has 69 entries (hashes, commits, update dates preserved)
- [x] `references/designs/ATTRIBUTION.md` states MIT license and source
- [x] Filenames and body bytes identical to the original (per getdesign@0.6.8)
