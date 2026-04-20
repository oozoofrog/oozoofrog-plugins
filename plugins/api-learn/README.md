# api-learn

프로젝트 도메인 API 내재화 플러그인 — 라이브러리/프레임워크의 공식 문서 + 예제를 수집하여 프로젝트별 `.claude/references/`에 저장하고, CLAUDE.md에 Knowledge Authority로 자동 등록합니다.

## 스킬

| 스킬 | 설명 |
|------|------|
| `/api-learn <library>` | 특정 라이브러리 문서를 수집·정제·저장·등록 |
| `/api-scan` | 프로젝트 의존성 스캔 → 미내재화 목록 제안 |

## 수집 전략

1. **context7 MCP** — 라이브러리 ID 해석 → 공식 문서 조회
2. **웹 검색** — 공식 문서 사이트 크롤링 (WebSearch → WebFetch)
3. **Codex 병렬 보강** (선택) — `/codex:rescue` 백그라운드 디스패치로 추가 패턴/마이그레이션 가이드 수집

> **범위**: 외부 공식 문서만 수집합니다. 로컬 프로젝트 코드의 import/사용 패턴은 분석/문서화하지 않습니다.

### Apple 프레임워크 추가 수집 (v1.1.0)

Apple 자체 프레임워크(SwiftUI, MapKit, SwiftData 등) 대상 시 2단계가 선행됩니다:

0. **Xcode DocumentationSearch** — `mcp__xcode__DocumentationSearch`로 공식 문서 직접 조회
0.5. **apple-craft 참조 확인** — curated 참조 문서 + 안티패턴 재활용 (설치 시)

## 출력 위치

```
{project}/.claude/references/
├── _index.md          ← 내재화 인덱스
├── react-query.md     ← 수집된 문서
└── zod.md
```

## 사용 예시

```bash
# 특정 라이브러리 내재화
/api-learn react-query

# 프로젝트 의존성 스캔
/api-scan
```
