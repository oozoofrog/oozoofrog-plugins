# gpt-research

프로젝트의 특정 부분을 GPT-PRO에게 위임할 구조화된 리서치 프롬프트로 추출하여 클립보드에 복사합니다.

## 4가지 모드

| 모드 | 설명 | 사용 예 |
|------|------|---------|
| `module` | 특정 모듈/파일의 소스, 의존성, 인터페이스 추출 | `gpt-research module src/auth/` |
| `arch` | 프로젝트 전체 아키텍처 요약 | `gpt-research arch` |
| `issue` | 에러/버그 관련 맥락 수집 | `gpt-research issue "TypeError: ..."` |
| `custom` | 대화형으로 범위 지정 | `gpt-research custom` |

## 사용법

```
# 스킬 트리거 (자연어)
"이 모듈에 대해 GPT에 물어보게 컨텍스트 뽑아줘 src/auth/"
"프로젝트 아키텍처를 GPT-PRO한테 분석시키고 싶어"
"이 에러 GPT한테 넘겨서 원인 분석 받자"
"GPT 리서치용 프롬프트 만들어줘"
```

## 출력 형식

생성되는 프롬프트는 4섹션 구조:
1. **Role** — GPT-PRO의 전문가 역할 지정
2. **Context** — 추출된 프로젝트 맥락 (소스 코드, 설정 등)
3. **Research Request** — 구체적 리서치 질문
4. **Expected Output** — 기대하는 응답 형식

결과는 `pbcopy`로 클립보드에 복사됩니다.

## 설치

```
/plugin install gpt-research@oozoofrog-plugins
```
