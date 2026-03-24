# hey-codex

> Hey Codex! — Claude Code에서 Codex CLI에 작업을 위임하는 플러그인

Claude Code에서 OpenAI Codex CLI에 작업을 위임하는 플러그인입니다.

## 설치

```bash
/plugin install hey-codex@oozoofrog-plugins
```

## 사전 요구사항

- Codex CLI: `npm install -g @openai/codex`
- 환경변수: `OPENAI_API_KEY`

## 사용법

슬래시 커맨드:
```
/hey-codex "이 코드 리뷰해줘"
/hey-codex "테스트 작성해줘"
```

자연어:
```
codex한테 이 함수 리팩토링해달라고 해줘
codex로 버그 찾아줘
```

## 실행 모드

| 모드 | 설명 | 예시 |
|------|------|------|
| read | 분석/리뷰 (읽기 전용) | "이 코드 설명해줘" |
| suggest | 제안 (Claude Code가 적용) | "개선 방법 알려줘" |
| write | 직접 수정 (full-auto) | "테스트 작성해줘" |

모드는 프롬프트 내용에 따라 자동 선택됩니다.
