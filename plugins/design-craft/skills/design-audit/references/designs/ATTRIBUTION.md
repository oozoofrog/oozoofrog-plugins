# Attribution — awesome-design-md internalization source

The 69 `.md` files and `manifest.json` in this directory (`references/designs/`) are copied and redistributed from VoltAgent team's public material under the MIT License.

## Original source

| Item | Path |
|------|------|
| GitHub | <https://github.com/VoltAgent/awesome-design-md> |
| Homepage | <https://getdesign.md> |
| npm package | `getdesign@0.6.8` — <https://www.npmjs.com/package/getdesign> |
| Author | VoltAgent team (omerfarukaplak, necatiozmen) |
| License | MIT License — Copyright (c) 2026 VoltAgent |
| Snapshot date | 2026-04-24 (based on npm `getdesign@0.6.8` tarball) |

The original `templates/*.md` files were copied byte-for-byte identically (sha256 hashes preserved in `manifest.json`). File names and directory structure are also identical to the original.

## License text

```
MIT License

Copyright (c) 2026 VoltAgent

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Ownership of brand assets

The `*.md` files are records of design tokens extracted from public websites; the trademarks, logos, and visual identity of each brand (Stripe, Linear, Apple, etc.) belong to the respective companies. The VoltAgent original repo README states the following:

> "This repository is a curated collection of design system documents extracted from public websites. All DESIGN.md files are provided 'as is' without warranty. The extracted design tokens represent publicly visible CSS values. We do not claim ownership of any site's visual identity."

This skill inherits the same conditions. Use of each `.md` file must occur only within the scope of compliance with the trademark and copyright rules of the respective brand.

## Synchronization

When the original is updated, run `scripts/fetch-catalog-diff.sh` to detect new, changed, and removed brands, and use `scripts/sync-designs.sh` to download the new npm tarball and update `references/designs/`. During synchronization, changes are determined based on `sourceCommit` and `templateHash` in `manifest.json`.

## Contributions or objections

Requests to modify or remove content of the original repository should be filed directly upstream:

- <https://github.com/VoltAgent/awesome-design-md/issues>

Issues related to this skill's internalization snapshot are handled in the `oozoofrog-plugins` repository.
