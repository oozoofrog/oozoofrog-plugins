# oozoofrog-plugins

oozoofrog의 개인 Claude Code 플러그인 마켓플레이스입니다.

## 마켓플레이스 등록

```bash
/plugin marketplace add oozoofrog/oozoofrog-plugins
```

## 포함 플러그인

| 플러그인 | 설명 | 설치 |
|---------|------|------|
| [macos-release](plugins/macos-release/) | macOS 앱/CLI 릴리스 자동화 (버전 범프, DMG/ZIP 패키징, GitHub Release, Homebrew) | `/plugin install macos-release@oozoofrog-plugins` |
| [agent-context](plugins/agent-context/) | 계층적 컨텍스트 아키텍처 자동화 (CLAUDE.md, .claude/rules/, AGENTS.md 스캐폴딩, 검증, 토큰 감사) | `/plugin install agent-context@oozoofrog-plugins` |
| [gpt-research](plugins/gpt-research/) | GPT-PRO 리서치 위임용 구조화된 프롬프트 생성 | `/plugin install gpt-research@oozoofrog-plugins` |
| [hey-codex](plugins/hey-codex/) | Codex CLI 위임(hey-codex) + 목표 지향 반복 연구(codex-research) | `/plugin install hey-codex@oozoofrog-plugins` |
| [app-automation](plugins/app-automation/) | Apple 앱 자동화 — iOS Simulator + macOS 앱 UI 인터랙션, 접근성 검증, os_log 스트리밍, mcp-baepsae 통합 | `/plugin install app-automation@oozoofrog-plugins` |
| [apple-craft](plugins/apple-craft/) | Apple 플랫폼 통합 개발 — 구현/디버깅, 리뷰, 장기 하네스, Pencil 디자인, App Store 배포, Xcode MCP, 참조 문서 24개 | `/plugin install apple-craft@oozoofrog-plugins` |
| [plugin-doctor](plugins/plugin-doctor/) | 플러그인 종합 진단·수정·개선 (공식 스펙 기반 검증 + 회의적 재검증 루프) | `/plugin install plugin-doctor@oozoofrog-plugins` |
| [api-learn](plugins/api-learn/) | 프로젝트 도메인 API 내재화 — 공식 문서/예제 수집 → 프로젝트별 참조 문서 저장, CLAUDE.md 자동 등록 | `/plugin install api-learn@oozoofrog-plugins` |
| [git-workflow](plugins/git-workflow/) | GitHub 이슈 생성 + 브랜치 + Projects 보드 연동 자동화 | `/plugin install git-workflow@oozoofrog-plugins` |
| [release-cycle](plugins/release-cycle/) | GitHub 릴리스 라이프사이클 자동화 — 마일스톤 계획(plan-release) + 릴리스 실행(release) | `/plugin install release-cycle@oozoofrog-plugins` |

## 플러그인 구조

```
oozoofrog-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── macos-release/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/macos-release/
│   │       ├── SKILL.md
│   │       └── references/ (6 docs)
│   ├── agent-context/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── ctx-guide/ (SKILL.md + references/)
│   │   │   ├── ctx-init/
│   │   │   ├── ctx-verify/
│   │   │   └── ctx-audit/
│   │   ├── agents/context-validator.md
│   │   └── hooks/ (hooks.json + scripts/)
│   ├── gpt-research/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/gpt-research/
│   │       ├── SKILL.md
│   │       └── references/ (4 docs)
│   ├── hey-codex/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── hey-codex/ (SKILL.md + references/)
│   │   │   └── codex-research/ (SKILL.md + references/)
│   │   ├── scripts/ (5 files)
│   │   └── templates/codex-research/
│   ├── app-automation/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── app-automation/
│   │   │   └── os-log/
│   │   ├── agents/ui-verifier.md
│   │   ├── scripts/os-log-cli/ (Swift package)
│   │   └── references/baepsae-tools.md
│   ├── apple-craft/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── skills/
│   │   │   ├── apple-craft/ (SKILL.md + references/ 24 docs)
│   │   │   ├── apple-harness/ (SKILL.md + references/)
│   │   │   ├── apple-review/
│   │   │   ├── appstore-deploy/
│   │   │   └── pen-craft/
│   │   ├── agents/ (7 agents)
│   │   └── scripts/
│   ├── plugin-doctor/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/fixer/
│   │       ├── SKILL.md
│   │       └── references/ (2 docs)
│   ├── api-learn/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       ├── api-learn/
│   │       └── api-scan/
│   ├── git-workflow/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/add-git-issue/
│   └── release-cycle/
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           ├── plan-release/
│           └── release/
├── CLAUDE.md
└── README.md
```
