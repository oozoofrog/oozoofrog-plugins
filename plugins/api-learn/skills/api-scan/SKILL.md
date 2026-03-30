---
name: api-scan
description: 프로젝트 의존성을 스캔하여 미내재화 라이브러리를 식별하고 내재화를 제안합니다. "의존성 스캔", "api scan", "라이브러리 현황", "내재화 현황", "API 스캔", "어떤 라이브러리 쓰고 있는지", "레퍼런스 현황", "미내재화 목록", "api-scan", "프로젝트 의존성", "dependency scan" 등의 요청에 사용하세요.
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

프로젝트 의존성 파일을 스캔하여 내재화 현황을 분석하고, 미내재화 라이브러리의 문서 수집을 제안합니다.

## Workflow

### Phase 1 — 의존성 파일 감지

프로젝트 루트에서 다음 파일들을 `Glob`으로 탐지합니다:

| 파일 | 생태계 | 의존성 추출 방법 |
|------|--------|-----------------|
| `package.json` | npm/yarn/pnpm | `dependencies` + `devDependencies` 키의 패키지명과 버전 |
| `requirements.txt` | pip | 각 줄의 패키지명 (`==` 이전) |
| `pyproject.toml` | Poetry/PDM | `[tool.poetry.dependencies]` 또는 `[project.dependencies]` |
| `Podfile` | CocoaPods | `pod '{name}'` 패턴 |
| `Package.swift` | SPM | `.package(url:` 또는 `.package(name:` 패턴 |
| `Cargo.toml` | Rust | `[dependencies]` 섹션 |
| `go.mod` | Go | `require` 블록의 모듈명 |
| `build.gradle` / `build.gradle.kts` | Gradle | `implementation`, `api`, `compileOnly` 등의 의존성 |
| `pom.xml` | Maven | `<dependency>` 태그의 `<artifactId>` |
| `Gemfile` | Ruby | `gem '{name}'` 패턴 |
| `pubspec.yaml` | Flutter/Dart | `dependencies` 키 |

**Apple 플랫폼 감지:** `Package.swift`, `Podfile`, `*.xcodeproj`, `*.xcworkspace` 중 하나라도 발견되면 Apple 플랫폼 프로젝트로 표시합니다. 리포트에 `🍎 Apple 플랫폼` 태그를 추가합니다.

**복수 파일 발견 시:** 모든 파일을 처리합니다 (예: Node + Python 혼합 프로젝트).

**의존성 파일 미발견 시:** 사용자에게 "프로젝트 루트에서 의존성 파일을 찾지 못했습니다. 의존성 파일 경로를 지정하거나, /api-learn으로 직접 라이브러리를 지정해 주세요."라고 안내.

### Phase 2 — 비교·분류

1. 추출된 의존성 목록 확보
2. `.claude/references/_index.md` 읽기 (없으면 전부 미내재화)
3. 각 의존성을 3가지로 분류:
   - **내재화 완료** — `_index.md`에 존재하고 메이저 버전 일치
   - **갱신 필요** — `_index.md`에 존재하지만 메이저 버전 불일치
   - **미내재화** — `_index.md`에 없음

**제외 대상:** 표준 라이브러리, 내부 패키지 (스코프가 `@company/`인 것), 유틸리티성 소형 패키지(예: `is-odd`)는 제안에서 제외합니다. 판단이 어려우면 포함하되 목록 하단에 배치합니다.

### Phase 3 — 사용자에게 제안

결과를 아래 포맷으로 보고합니다:

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

### Phase 4 — 위임

사용자 선택에 따라 실행:

- **(1) 또는 (2):** 선택된 라이브러리 목록을 순회하며 각각에 대해 `/api-learn`의 Phase 1~3과 동일한 수집·저장·등록 로직을 실행합니다. 가능한 경우 병렬 에이전트(Agent 도구)를 활용하여 여러 라이브러리를 동시 수집합니다.
- **(3):** 사용자에게 라이브러리 이름을 입력받은 뒤 동일하게 실행합니다.

각 라이브러리 수집 완료 시 진행 상황을 보고합니다:
```
[2/8] zod 수집 완료 (890줄, context7+web)
```

모든 수집 완료 후 최종 요약을 출력합니다.
