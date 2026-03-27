# Apple HIG 조회 패턴 가이드

> harness-designer가 Apple HIG를 참조할 때 사용하는 가이드.
> 이 문서는 HIG 원문이 아닌 **조회 전략 + 즉시 참조용 핵심 규칙**입니다.

## HIG 3대 원칙

- **Hierarchy**: 컨트롤과 인터페이스 요소가 콘텐츠 위에 부유하며 명확한 시각적 위계 형성
- **Harmony**: 하드웨어·소프트웨어의 동심원(concentric) 디자인과 조화
- **Consistency**: 플랫폼 규약을 따라 윈도우 크기·디스플레이에 일관되게 적응

## 조건부 DocumentationSearch 전략

Designer는 `get_guidelines(topic="mobile-app")`으로 기본 iOS 규칙을 이미 로드합니다.
**추가 조회는 아래 조건일 때만** 실행하세요:

### 조회가 필요한 경우 (Claude 학습 데이터에 없는 내용)

| 조건 | 쿼리 | 이유 |
|------|------|------|
| Liquid Glass 사용 | `"Liquid Glass materials design"` | iOS 26 신규 소재, 학습 컷오프 이후 |
| iOS 26 컴포넌트 마이그레이션 | `"Adopting Liquid Glass visual refresh"` | 플로팅 탭바, 스크롤 엣지 등 신규 |
| Glass 색상 틴팅 | `"Color Liquid Glass color"` | 틴팅 규칙이 새로움 |

### 조회가 불필요한 경우 (Claude가 이미 아는 것)

| 주제 | 이유 | 대신 참조할 것 |
|------|------|--------------|
| Safe Area, 레이아웃 | 수년간 변하지 않은 기본 규칙 | 아래 Foundation 체크리스트 |
| SF Pro 타이포그래피 | iOS 14+ 동일 | 아래 Typography 빠른 참조 |
| 시맨틱 색상 | 잘 문서화된 API | 아래 Color 빠른 참조 |
| Dynamic Type, VoiceOver | 접근성 기본 | 아래 Foundation 체크리스트 |
| Dark Mode | iOS 13+ 동일 | apple-craft 참조 문서 |

### Graceful Degradation

DocumentationSearch 실패 시:
- 이 문서의 체크리스트 + 빠른 참조로 진행 (네트워크 불필요)
- {HARNESS_DIR}/design-spec.md에 "⚠️ HIG 동적 조회 실패, 정적 참조 기반" 기록

---

## Liquid Glass 핵심 규칙 (즉시 참조)

Claude의 학습 데이터에 없는 iOS 26 신규 내용이므로 여기에 핵심만 정리합니다:

1. **콘텐츠 레이어에 Liquid Glass 사용 금지** — 컨트롤/네비게이션 레이어 전용
2. **효과 절제** — 가장 중요한 기능 요소에만 적용. 과다 사용은 콘텐츠를 방해
3. **Regular vs Clear**:
   - Regular: 배경 블러+광도 조정, 텍스트 많은 요소(알럿, 사이드바, 팝오버)
   - Clear: 고투명, 미디어 배경 위(사진/비디오)에서만
4. **Clear + dimming**: 밝은 배경이면 35% 다크 디밍 레이어 추가
5. **색상 틴팅 절제**: 강조 요소(Done 버튼 등)의 배경에만. 여러 컨트롤에 배경색 금지
6. **양쪽 모드 필수**: 단일 모드 앱이라도 Light/Dark 양쪽 색상 제공 (Glass 적응성)
7. **접근성 자동 적응 테스트**: Reduce Transparency, Increase Contrast, Reduce Motion

---

## HIG Foundation 체크리스트 (Designer/Builder/Evaluator 공용)

### 필수 (Foundation) — 반드시 충족

- [ ] Safe Area 준수 (Status Bar, Home Indicator, Dynamic Island)
- [ ] 터치 타겟 최소 44×44pt
- [ ] 시맨틱 색상 사용 (systemBackground, label, separator 등)
- [ ] Dark Mode 대응 (양쪽 색상 제공)
- [ ] Dynamic Type 지원 (body, headline 최소)
- [ ] accessibilityLabel — 모든 인터랙티브 요소
- [ ] 네비게이션 Back 제스처 동작
- [ ] 키보드 dismiss 처리
- [ ] 대비율 4.5:1 이상 (WCAG AA, 18pt+ 또는 Bold는 3:1)
- [ ] Liquid Glass는 컨트롤/네비게이션 레이어에만 (콘텐츠 레이어 금지)

### 자유 (Expression) — Foundation 위에서 자유

- 색상 팔레트 (HIG 시맨틱 위에 커스텀 가능)
- 타이포 weight/size (SF Pro 기반, 커스텀 폰트도 가능)
- 카드/섹션 형태 (cornerRadius, 그림자, 재질 자유)
- 레이아웃 구성 (Grid, Bento, 커스텀 자유)
- 애니메이션/전환 효과 (Reduce Motion 대응 필수)
- 아이콘 스타일 (SF Symbols weight/rendering 자유)
- 정보 구조 (계층/그룹핑 방식 자유)

---

## SwiftUI 시맨틱 색상 빠른 참조

| HIG 시맨틱 | SwiftUI | 용도 |
|-----------|---------|------|
| Background | Color(.systemBackground) | 기본 배경 |
| Secondary BG | Color(.secondarySystemBackground) | 그룹/카드 배경 |
| Tertiary BG | Color(.tertiarySystemBackground) | 중첩 그룹 |
| Label | Color(.label) | 기본 텍스트 |
| Secondary Label | Color(.secondaryLabel) | 보조 텍스트 |
| Separator | Color(.separator) | 구분선 |
| Accent | Color.accentColor | 강조/브랜드 |
| Tint | .tint(.blue) | 인터랙티브 |

## Typography 빠른 참조

| Text Style | iOS Size | Weight | SwiftUI |
|-----------|----------|--------|---------|
| Large Title | 34pt | Regular | .largeTitle |
| Title 1 | 28pt | Regular | .title |
| Title 2 | 22pt | Regular | .title2 |
| Title 3 | 20pt | Regular | .title3 |
| Headline | 17pt | Semibold | .headline |
| Body | 17pt | Regular | .body |
| Callout | 16pt | Regular | .callout |
| Subheadline | 15pt | Regular | .subheadline |
| Footnote | 13pt | Regular | .footnote |
| Caption 1 | 12pt | Regular | .caption |
| Caption 2 | 11pt | Regular | .caption2 |

플랫폼별 기본/최소: iOS 17pt/11pt, macOS 13pt/10pt, watchOS 16pt/12pt, visionOS 17pt/12pt

## 비용 추정

| 항목 | 토큰 | 비용 |
|------|------|------|
| 이 문서 읽기 | ~2K | ~$0.005 |
| DocumentationSearch 1회 | ~2K | ~$0.005 |
| 최악 (읽기 + 3회 조회) | ~8K | ~$0.02 |
| 전체 하네스 대비 | | <0.5% |
