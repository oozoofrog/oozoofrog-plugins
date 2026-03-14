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

## 플러그인 구조

```
oozoofrog-plugins/
├── .claude-plugin/
│   └── marketplace.json       ← 마켓플레이스 매니페스트
├── plugins/
│   └── macos-release/
│       ├── .claude-plugin/
│       │   └── plugin.json    ← 플러그인 매니페스트
│       ├── skills/
│       │   └── macos-release/
│       │       ├── SKILL.md   ← 스킬 본문
│       │       └── references/
│       │           ├── release-checklist.md
│       │           ├── release-script-guide.md
│       │           ├── github-workflow-guide.md
│       │           ├── homebrew-publishing.md
│       │           ├── local-install-and-dmg.md
│       │           └── troubleshooting.md
│       └── README.md
└── README.md
```
