---
name: api-scan
description: Scan project dependencies to identify libraries not yet internalized and propose internalization. Trigger keywords "의존성 스캔", "api scan", "라이브러리 현황", "내재화 현황", "API 스캔", "어떤 라이브러리 쓰고 있는지", "레퍼런스 현황", "미내재화 목록", "api-scan", "프로젝트 의존성", "dependency scan".
---

<example>
user: "/api-scan"
assistant: "프로젝트 의존성을 스캔합니다. package.json 발견 — 12개 의존성 중 3개 내재화 완료, 1개 갱신 필요, 8개 미내재화입니다."
</example>

<example>
user: "이 프로젝트에서 쓰는 라이브러리 뭐 있는지 스캔해줘"
assistant: "의존성 파일을 탐지하여 내재화 현황을 분석하겠습니다."
</example>

<example>
user: "API 레퍼런스 현황 보여줘"
assistant: "프로젝트 의존성을 스캔하고 .claude/references/와 대조하여 현황을 보고하겠습니다."
</example>

# api-scan

Scan project dependency files to analyze internalization status, and propose documentation collection for libraries not yet internalized.

Respond to the user in Korean.

## Workflow

### Phase 1 — Detect dependency files

Use `Glob` to detect these files in the project root:

| File | Ecosystem | Dependency extraction method |
|------|-----------|-----------------|
| `package.json` | npm/yarn/pnpm | Package names and versions under the `dependencies` + `devDependencies` keys |
| `requirements.txt` | pip | Package name on each line (before `==`) |
| `pyproject.toml` | Poetry/PDM | `[tool.poetry.dependencies]` or `[project.dependencies]` |
| `Podfile` | CocoaPods | `pod '{name}'` pattern |
| `Package.swift` | SPM | `.package(url:` or `.package(name:` pattern |
| `Cargo.toml` | Rust | `[dependencies]` section |
| `go.mod` | Go | Module names in the `require` block |
| `build.gradle` / `build.gradle.kts` | Gradle | Dependencies under `implementation`, `api`, `compileOnly`, etc. |
| `pom.xml` | Maven | `<artifactId>` of `<dependency>` tags |
| `Gemfile` | Ruby | `gem '{name}'` pattern |
| `pubspec.yaml` | Flutter/Dart | `dependencies` key |

**Apple platform detection:** If any of `Package.swift`, `Podfile`, `*.xcodeproj`, `*.xcworkspace` is found, mark the project as an Apple platform project and add a `🍎 Apple 플랫폼` tag to the report.

**Multiple files found:** Process all of them (e.g. a mixed Node + Python project).

**No dependency file found:** Tell the user "프로젝트 루트에서 의존성 파일을 찾지 못했습니다. 의존성 파일 경로를 지정하거나, /api-learn으로 직접 라이브러리를 지정해 주세요."

### Phase 2 — Compare and classify

1. Obtain the extracted dependency list.
2. Read `.claude/references/_index.md` (if absent, treat everything as not internalized).
3. Classify each dependency into one of three buckets:
   - **내재화 완료** — present in `_index.md` and major version matches
   - **갱신 필요** — present in `_index.md` but major version mismatches
   - **미내재화** — not in `_index.md`

**Exclusions:** Exclude standard libraries, internal packages (scoped as `@company/`), and small utility packages (e.g. `is-odd`) from the proposal. When unsure, include them but place them at the bottom of the list.

### Phase 3 — Propose to the user

Report the result in this format:

```
📋 API 내재화 현황 ({총 의존성}개 의존성, {파일명} 기준)

✅ 내재화 완료 ({N}개):
   {library1} (v{version}, {collected_date})
   {library2} ...

⚠️ 갱신 필요 ({N}개):
   {library3} (내재화: v{old} → 현재: v{new})

❌ 미내재화 ({N}개):
   {library4}, {library5}, {library6}, ...

──────────────────────────────
내재화할 라이브러리를 선택하세요:
  (1) 미내재화 전체 ({N}개)
  (2) 갱신 필요 포함 전체 ({N}개)
  (3) 직접 선택

🍎 Apple 플랫폼 감지됨 (Package.swift / Podfile)
   Apple 자체 프레임워크의 내재화 시 Xcode DocumentationSearch로
   공식 문서를 직접 조회하여 더 정확한 수집이 가능합니다.
```

### Phase 4 — Delegate

Execute based on the user's choice:

- **(1) or (2):** Iterate over the selected library list and run the same collect/save/register logic as `/api-learn` Phase 1–3 for each. Where possible, use parallel agents (the Agent tool) to collect multiple libraries concurrently.
- **(3):** Ask the user for library names, then run the same flow.

Report progress as each library finishes collecting:
```
[2/8] zod 수집 완료 (890줄, context7+web)
```

After all collection finishes, print a final summary.
