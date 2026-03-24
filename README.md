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
| [context-architect](plugins/context-architect/) | 계층적 컨텍스트 아키텍처 자동화 (스캐폴딩, 검증, 토큰 효율성 감사) | `/plugin install context-architect@oozoofrog-plugins` |
| [gpt-research](plugins/gpt-research/) | GPT-PRO 리서치 위임용 구조화된 프롬프트 생성 (module/arch/issue/custom) | `/plugin install gpt-research@oozoofrog-plugins` |
| [codex-delegate](plugins/codex-delegate/) | Codex CLI에 작업 위임 (코드 생성, 분석, 리팩토링) | `/plugin install codex-delegate@oozoofrog-plugins` |

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
│   └── context-architect/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── context-architecture/
│       │       ├── SKILL.md
│       │       └── references/
│       ├── commands/
│       │   ├── init.md
│       │   ├── verify.md
│       │   └── audit.md
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
│   └── codex-delegate/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── scripts/
│       │   ├── preflight.sh
│       │   ├── process-output.sh
│       │   └── snapshot-diff.sh
│       ├── skills/
│       │   └── codex-delegate/
│       │       ├── SKILL.md
│       │       └── references/
│       │           ├── mode-detection.md
│       │           └── output-handling.md
│       └── README.md
└── README.md
```
