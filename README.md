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
└── README.md
```
