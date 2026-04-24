# design-craft

멀티플랫폼 디자인 하네스 — iOS/Web/Android 플랫폼별 최적화 디자이너 에이전트 팀.

## 개요

유명 디자이너(Jony Ive, Dieter Rams, Don Norman 등)와 화가(Mondrian, Rothko, Albers 등)의 디자인 특성을 정량적 토큰으로 체계화하고, 플랫폼별 최적화된 디자인 스펙을 생성합니다.

## 스킬

| 스킬 | 설명 |
|------|------|
| `/design-research` | 디자이너/화가 연구 → 정량적 토큰 생성 |
| `/design-craft` | 플랫폼별 디자인 스펙 생성 (토큰 기반) |
| `/design-audit` | 앱 디자인 상태 진단 → awesome-design-md 69개 DESIGN.md 본문 내재화 기반 Top-3 매칭 리포트 (정확한 hex·폰트·수치 인용) |

## 에이전트

### 리서치 팀
| 에이전트 | 역할 |
|---------|------|
| design-historian | UI/UX 거장 연구 + 정량 토큰 추출 |
| art-aesthetics | 화가/시각 아티스트 시각 언어 분석 |
| token-architect | 토큰 통합 + 플랫폼 매핑 + 검색 인덱스 |
| verification-scientist | 출처 검증 + 가설 수립 + 검증 리포트 |

### 플랫폼 팀
| 에이전트 | 역할 |
|---------|------|
| ios-designer | Apple HIG + Liquid Glass + SwiftUI 토큰 매핑 |
| web-designer | WCAG + 반응형 + CSS 토큰 매핑 |
| android-designer | Material Design 3 + Compose 토큰 매핑 |
| design-qa | 교차 플랫폼 정합성 + 접근성 + 수치 검증 |

## 사용법

```bash
# 1단계: 디자인 리서치 실행 (최초 1회)
/design-research

# 2단계: 플랫폼별 디자인 생성
/design-craft "로그인 화면" --platform ios
/design-craft "대시보드" --platform all --style "jony-ive"
/design-craft "랜딩 페이지" --platform web --style "mondrian"
```

## 설치

```bash
claude plugin install design-craft@oozoofrog-plugins
```
