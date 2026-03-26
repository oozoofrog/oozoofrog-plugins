# oozoofrog-plugins

oozoofrog의 개인 Claude Code 플러그인 마켓플레이스입니다.

## 마켓플레이스 등록

```bash
/plugin marketplace add oozoofrog/oozoofrog-plugins
```

## 포함 플러그인

| 플러그인 | 설명 | 설치 |
|---------|------|------|
| [macos-release](plugins/macos-release/) | macOS 앱 릴리스 자동화 (버전 범프, DMG, GitHub Release, Homebrew) | `/plugin install macos-release@oozoofrog-plugins` |
| [agent-context](plugins/agent-context/) | 계층적 컨텍스트 아키텍처 자동화 (스캐폴딩, 검증, 토큰 효율성 감사) | `/plugin install agent-context@oozoofrog-plugins` |
| [gpt-research](plugins/gpt-research/) | GPT-PRO 리서치 위임용 구조화된 프롬프트 생성 (module/arch/issue/custom) | `/plugin install gpt-research@oozoofrog-plugins` |
| [hey-codex](plugins/hey-codex/) | Codex CLI에 작업 위임 (코드 생성, 분석, 리팩토링) | `/plugin install hey-codex@oozoofrog-plugins` |
| [apple-craft](plugins/apple-craft/) | Apple 플랫폼 통합 개발 어시스턴트 — Swift/SwiftUI/UIKit + Xcode MCP 연동 + 최신 API 참조 문서 20개 내장 | `/plugin install apple-craft@oozoofrog-plugins` |
| [plugin-doctor](plugins/plugin-doctor/) | 플러그인 종합 진단·수정·개선 (공식 스펙 기반 8단계 검증 + 자기 수리) | `/plugin install plugin-doctor@oozoofrog-plugins` |

## 플러그인 구조

```
oozoofrog-plugins/
├── .claude-plugin/
│   └── marketplace.json       ← 마켓플레이스 매니페스트
├── plugins/
│   ├── macos-release/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── skills/
│   │   │   └── macos-release/
│   │   │       ├── SKILL.md
│   │   │       └── references/
│   │   └── README.md
│   └── agent-context/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   ├── guide/
│       │   │   ├── SKILL.md
│       │   │   └── references/
│       │   ├── init/
│       │   │   └── SKILL.md
│       │   ├── verify/
│       │   │   └── SKILL.md
│       │   └── audit/
│       │       └── SKILL.md
│       ├── agents/
│       │   └── context-validator.md
│       ├── hooks/
│       │   ├── hooks.json
│       │   └── scripts/
│       └── README.md
│   └── gpt-research/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── gpt-research/
│       │       ├── SKILL.md
│       │       └── references/
│       │           ├── output-templates.md
│       │           ├── context-extraction-guide.md
│       │           ├── prompting-best-practices.md
│       │           └── size-limits-and-chunking.md
│       └── README.md
│   ├── hey-codex/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── scripts/
│   │   │   ├── preflight.sh
│   │   │   ├── process-output.sh
│   │   │   └── snapshot-diff.sh
│   │   ├── skills/
│   │   │   └── hey-codex/
│   │   │       ├── SKILL.md
│   │   │       └── references/
│   │   │           ├── mode-detection.md
│   │   │           └── output-handling.md
│   │   └── README.md
│   ├── apple-craft/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── scripts/
│   │   │   ├── sync-docs.sh
│   │   │   └── preflight.sh
│   │   ├── skills/
│   │   │   └── apple-craft/
│   │   │       ├── SKILL.md
│   │   │       └── references/ (20 docs)
│   │   └── README.md
│   └── plugin-doctor/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── doctor/
│       │       ├── SKILL.md
│       │       └── references/
│       │           └── official-spec.md
│       └── README.md
└── README.md
```
