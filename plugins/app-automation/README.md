# app-automation

Apple 앱 자동화 플러그인 — iOS Simulator + macOS 앱 UI 인터랙션, 접근성 검증, 스크린샷/비디오, 워크플로우 자동화.

mcp-baepsae MCP 서버를 통해 시뮬레이터 및 macOS 앱을 제어합니다.

## 설치

```bash
/plugin install app-automation@oozoofrog-plugins
```

## 사용법

```bash
# 앱 자동화 가이드
/app-automation

# 시뮬레이터 조작, 접근성 검증, 스크린샷 등
```

## 컴포넌트

### Skill

| 스킬 | 설명 |
|------|------|
| `/app-automation` | Apple 앱 자동화 가이드 (시뮬레이터, UI 인터랙션, 접근성, 워크플로우) |

### MCP Server

`baepsae` — mcp-baepsae를 통한 iOS Simulator + macOS 앱 자동화

## 파일 구조

```
app-automation/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
├── skills/
│   └── app-automation/
│       └── SKILL.md
└── README.md
```
