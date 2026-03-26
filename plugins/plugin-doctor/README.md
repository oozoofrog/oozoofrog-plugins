# plugin-doctor

Claude Code 플러그인 종합 진단·수정·개선 도구.

마켓플레이스 내 모든 플러그인을 공식 표준에 맞게 검증하고, 자동 수정 가능한 문제는 즉시 수정합니다. 자기 자신(plugin-doctor)도 점검 대상에 포함됩니다.

## 설치

```bash
/plugin install plugin-doctor@oozoofrog-plugins
```

## 사용법

```bash
# 전체 마켓플레이스 점검
/fixer

# 특정 플러그인만 점검
/fixer agent-context

# 공식 스펙 최신화 후 점검
/fixer --update-spec
```

## 검증 항목 (8단계)

| 단계 | 검증 대상 | 주요 체크 |
|------|----------|----------|
| Stage 0 | 공식 스펙 최신화 | WebFetch로 공식 문서 조회, official-spec.md 업데이트 |
| Stage 1 | marketplace.json | 필수 필드, SemVer, kebab-case, 중복 이름 |
| Stage 2 | plugin.json | 필수/권장 필드, marketplace 버전 동기화 |
| Stage 3 | 스킬 (SKILL.md) | frontmatter 유효성, allowed-tools 형식, deprecated commands/ 감지 |
| Stage 4 | 에이전트 | frontmatter 필수 필드, 플러그인 제한사항 준수 |
| Stage 5 | 훅 (hooks.json) | 이벤트 이름, 매처 정규식, 스크립트 존재/실행권한 |
| Stage 6 | 구조 | README 존재, 빈 디렉토리, 네이밍 통일 |
| Stage 7 | 자기 진단 | plugin-doctor 자체를 동일 기준으로 메타 검증 |

## 파일 구조

```
plugin-doctor/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── fixer/
│       ├── SKILL.md
│       └── references/
│           └── official-spec.md
└── README.md
```
