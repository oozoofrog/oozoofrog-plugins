# agent-context

대규모 프로젝트를 위한 계층적 컨텍스트 아키텍처 자동화 플러그인.

CLAUDE.md(루트 + 서브디렉토리), `.claude/rules/`, AGENTS.md로 구성되는 계층적 컨텍스트 구조를 스캐폴딩하고, 검증하고, 토큰 효율성을 감사합니다. CONTEXT.md는 타 AI 도구 호환용으로 지원합니다.

## 핵심 개념

- **주의력 예산(Attention Budget)**: LLM의 토큰 제한 내에서 최적의 정보만 노출
- **국소성(Locality)**: 정보를 해당 코드와 물리적으로 인접하게 배치
- **점진적 노출(Progressive Disclosure)**: 필요한 시점에만 컨텍스트 로드

## Claude Code 컨텍스트 로딩

| 파일 | 자동 로딩 | 로딩 시점 |
|------|-----------|-----------|
| `/CLAUDE.md` | ✅ | 세션 시작 시 |
| 서브디렉토리 `CLAUDE.md` | ✅ | 해당 디렉토리 파일 접근 시 (on-demand) |
| `.claude/rules/*.md` | ✅ | glob 패턴 매칭 시 |
| `AGENTS.md` | ❌ | `@AGENTS.md` import 필요 |
| `CONTEXT.md` | ❌ | 명시적 Read 또는 `@` import 필요 |

## 설치

```bash
/plugin install agent-context@oozoofrog-plugins
```

## 컴포넌트

### Skills

| 스킬 | 설명 |
|------|------|
| `/agent-context:guide` | 계층적 컨텍스트 설계 원칙 및 실무 가이드 |
| `/agent-context:init` | 프로젝트 분석 → 계층적 컨텍스트 스캐폴딩 |
| `/agent-context:verify` | 3단계 검증 (참조 무결성, 코드 참조, 내용 정확성) |
| `/agent-context:audit` | 토큰 효율성 감사 (간결성, 계층 깊이, 중복, 커버리지) |

### Agent

`context-validator` — 코드 변경 후 컨텍스트 문서와 코드의 정합성을 자율 검증하고, "Fix the Rules" 원칙에 따라 업데이트를 제안.

### Hook

`SessionStart` — CLAUDE.md가 없으면 세션 시작 시 초기화 안내 표시.

## 사용 예시

```bash
# 새 프로젝트에 컨텍스트 아키텍처 초기화
/agent-context:init

# 주기적 검증 (전체)
/agent-context:verify

# 특정 단계만 검증
/agent-context:verify 1    # 참조 무결성만
/agent-context:verify 2    # 코드 참조만

# 토큰 효율성 감사
/agent-context:audit
```

## 파일 구조

```
agent-context/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── guide/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── file-standards.md
│   │       ├── token-optimization.md
│   │       └── verification-guide.md
│   ├── init/
│   │   └── SKILL.md
│   ├── verify/
│   │   └── SKILL.md
│   └── audit/
│       └── SKILL.md
├── agents/
│   └── context-validator.md
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       └── check-claude-md.sh
└── README.md
```
