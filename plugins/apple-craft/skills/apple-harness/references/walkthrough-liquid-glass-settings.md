# Walkthrough: Liquid Glass 설정 화면 구현

apple-craft-harness의 Plan→Build→Evaluate 루프를 사용하여 SwiftUI 설정 화면에
Liquid Glass 디자인을 적용하는 전체 과정입니다. 10개 기능(기본 5 + 차별화 5)을
4축 다차원 평가로 검증하는 개선된 하네스 흐름을 시연합니다.

> **참고**: 이 워크스루는 **Pencil MCP 미연결 환경**에서의 실행 예시입니다.
> Phase 2(DESIGN)은 Pencil MCP가 사용 가능할 때만 실행되므로, 여기서는 자동 스킵됩니다.
> Phase 번호는 스킵된 Phase를 제외한 실제 실행 순서를 따릅니다.

---

## 사용자 요청

> "처음부터 Liquid Glass를 적용한 설정 화면을 만들어줘. 프로필, 알림, 테마 설정 섹션이 필요해."

---

## Phase 1: PLAN (harness-planner)

### Step 0: 설계 원칙 숙지

Planner가 `harness-design-principles.md`를 Read하여 핵심 원칙을 확인합니다:
- **최소 복잡성**: 모델이 스스로 할 수 없는 것에 대한 가정만 인코딩
- **Generator-Evaluator 분리**: 자기평가 편향 제거
- **Planner 유지 이유**: 전체 비용의 0.4%로 가장 높은 ROI

### Step 1: AskUserQuestion으로 사용자 맥락 수집

Planner가 4개 질문으로 맥락을 수집합니다. 이후 자율 진행의 기반입니다.

```
Q1: 이 설정 화면의 주 사용자는 누구인가요?
A1: 일반 소비자용 소셜 앱. 20-30대, 디자인 감도가 높은 사용자층.

Q2: 기존 프로젝트에 추가하나요? 아키텍처 패턴은?
A2: 기존 SwiftUI 프로젝트, MVVM + @Observable 매크로.

Q3: 기본 설정 화면 외에 특별히 원하는 기능이 있나요?
A3: FoundationModels 자연어 검색 + VoiceOver 접근성 지원.

Q4: 테스트 환경은?
A4: iPhone 16 Pro 시뮬레이터, iOS 26 beta.
```

### Step 2: .claude/harness/harness-spec.md 생성

```markdown
# 제품 스펙: Liquid Glass 설정 화면

## 개요
SwiftUI Liquid Glass 설정 화면. 프로필/알림/테마 3개 섹션 + 접근성, AI 검색,
haptic, 다크모드 전환, 에러 처리까지 포괄.

## 사용자 맥락
- 대상: 20-30대 디자인 감도 높은 일반 소비자
- 아키텍처: MVVM + @Observable
- 차별화 요구: FoundationModels 자연어 검색, VoiceOver 접근성
- 테스트 환경: iPhone 16 Pro 시뮬레이터, iOS 26 beta

## 차별화 기능
1. FoundationModels 자연어 설정 검색
2. VoiceOver accessibilityLabel 전체 적용
3. 설정 변경 시 haptic feedback
4. 다크모드/라이트모드 전환 애니메이션
5. 데이터 로딩 실패 시 에러 상태 UI

## 대상 플랫폼
iOS 26+ / SwiftUI + Liquid Glass, FoundationModels, MVVM + @Observable
```

### Step 3: .claude/harness/features.json 생성

10개 기능. Planner가 verification_steps를 초기 작성합니다.

| ID | category | description | verification_steps (요약) | reference |
|----|----------|-------------|--------------------------|-----------|
| F001 | config | SettingsView 기본 구조 | build -> launch -> screenshot | liquid-glass-swiftui.md |
| F002 | ui | glassEffect() + GlassEffectContainer | render_preview -> screenshot | liquid-glass-swiftui.md |
| F003 | ui | 프로필 -- 아바타 + 편집 + .buttonStyle(.glass) | tap 편집 -> type_text 이름 | liquid-glass-swiftui.md |
| F004 | ui | 알림 설정 -- Toggle + Glass 배경 | tap 토글 -> screenshot | liquid-glass-swiftui.md |
| F005 | ui | 테마 -- Glass 카드 + @Namespace morphing | tap 다크 카드 -> morphing | liquid-glass-swiftui.md |
| F006 | ui | 접근성 -- VoiceOver accessibilityLabel | analyze_ui 접근성 트리 | liquid-glass-swiftui.md |
| F007 | logic | FoundationModels 자연어 설정 검색 | tap 검색 -> type "알림 끄기" | foundation-models.md |
| F008 | ui | 설정 변경 시 haptic feedback | tap 토글 -> code_review | liquid-glass-swiftui.md |
| F009 | ui | 다크모드/라이트모드 전환 애니메이션 | tap 라이트 -> 전환 확인 | liquid-glass-swiftui.md |
| F010 | ui | 에러 상태 -- 로딩 실패 시 안내 | simulate_error -> screenshot | liquid-glass-swiftui.md |

모든 기능의 status: "pending". priority: F001(1) ~ F010(10).

### 사용자 확인 (마지막 확인점)

> .claude/harness/harness-spec.md: 10개 기능, iOS 26+, MVVM + @Observable
> .claude/harness/features.json: F001-F010 (기본 5 + 차별화 5)
> "이 스펙으로 진행할까요?" -> 사용자: "좋아요, 진행해주세요."

---

## Phase 1.5: VERIFICATION REVIEW (harness-evaluator)

Evaluator가 VERIFICATION_REVIEW 모드로 호출. **사용자 확인 없이 자율 진행.**

**F003 보강** -- "편집 -> 저장 -> 반영" 시나리오 추가:
```json
[{"action":"tap","target":"편집 버튼","expect":"편집 화면 전환"},
 {"action":"type_text","target":"이름 필드","text":"새이름","expect":"입력 반영"},
 {"action":"tap","target":"저장 버튼","expect":"설정 화면 복귀"},
 {"action":"screenshot","expect":"변경된 이름이 프로필 섹션에 표시"}]
```

**F006 보강** -- analyze_ui 접근성 트리 확인 추가:
```json
[{"action":"analyze_ui","expect":"접근성 트리에 모든 요소 label 존재"},
 {"action":"analyze_ui","target":"편집 버튼","expect":"label: '프로필 편집'"},
 {"action":"analyze_ui","target":"테마 카드","expect":"label + hint 존재"},
 {"action":"voiceover_navigate","expect":"순차 탐색 시 모든 요소 읽힘"}]
```

**F007 보강** -- FoundationModels 인터랙션 + 코드 검증:
```json
[{"action":"tap","target":"검색 바","expect":"키보드 활성화"},
 {"action":"type_text","text":"알림 끄기","expect":"알림 설정 항목 표시"},
 {"action":"tap","target":"검색 결과","expect":"해당 섹션으로 이동"},
 {"action":"type_text","text":"의미없는문자열","expect":"결과 없음 안내"},
 {"action":"code_review","target":"SettingsSearchView.swift",
  "expect":"SystemLanguageModel.default 가용성 체크 존재"}]
```

자동 진행 -- Phase 2: BUILD로 이동.

---

## Phase 2: BUILD (harness-builder)

Builder가 priority 순서대로 10개 기능을 순차 구현합니다.

### F001: SettingsView 기본 구조

```swift
struct SettingsView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileSectionView()
                    NotificationSectionView()
                    ThemeSectionView()
                }.padding()
            }
            .navigationTitle("설정")
            .searchable(text: $searchText, prompt: "설정 검색")
        }
    }
}
```

빌드: 성공 | 커밋: `feat(F001): SettingsView 기본 구조`

### F002: Liquid Glass 적용

```swift
// SettingsView body 수정 — GlassEffectContainer 래핑
ScrollView {
    GlassEffectContainer {
        VStack(spacing: 16) {
            ProfileSectionView().glassEffect(in: .rect(cornerRadius: 16))
            NotificationSectionView().glassEffect(in: .rect(cornerRadius: 16))
            ThemeSectionView().glassEffect(in: .rect(cornerRadius: 16))
        }.padding()
    }
}
```

빌드: 성공 | 프리뷰 확인 | 커밋: `feat(F002): glassEffect + GlassEffectContainer`

### F003: 프로필 섹션

```swift
struct ProfileSectionView: View {
    @State private var userName = "사용자"
    @State private var isEditing = false
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48)).foregroundStyle(.secondary)
                .accessibilityLabel("프로필 사진")
            VStack(alignment: .leading) {
                Text(userName).font(.headline)
                Text("프로필 편집").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("편집") { isEditing = true }
                .buttonStyle(.glass)
                .accessibilityLabel("프로필 편집")
        }.padding()
        .sheet(isPresented: $isEditing) { ProfileEditView(userName: $userName) }
    }
}
```

빌드: 성공 | 커밋: `feat(F003): 프로필 섹션 -- Glass 버튼 + 편집 시트`

### F004: 알림 설정

```swift
struct NotificationSectionView: View {
    @State private var pushEnabled = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("알림 설정", systemImage: "bell.fill").font(.headline)
            Toggle("푸시 알림", isOn: $pushEnabled)
                .accessibilityValue(pushEnabled ? "켜짐" : "꺼짐")
            Toggle("소리", isOn: $soundEnabled)
            Toggle("배지", isOn: $badgeEnabled)
        }.padding()
    }
}
```

빌드: 성공 | 커밋: `feat(F004): 알림 설정 -- Toggle 컨트롤`

### F005: 테마 선택

```swift
struct ThemeSectionView: View {
    @State private var selectedTheme = "system"
    @Namespace private var themeNamespace
    let themes = [("system","자동","circle.lefthalf.filled"),
                  ("light","라이트","sun.max.fill"),("dark","다크","moon.fill")]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("테마", systemImage: "paintpalette.fill").font(.headline)
            HStack(spacing: 12) {
                ForEach(themes, id: \.0) { id, name, icon in
                    Button {
                        withAnimation(.spring(duration: 0.4)) { selectedTheme = id }
                    } label: {
                        VStack { Image(systemName: icon).font(.title2)
                                 Text(name).font(.caption) }
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                    .glassEffect(in: .rect(cornerRadius: 12), isEnabled: selectedTheme == id)
                    .glassEffectID(id, in: themeNamespace)
                }
            }
        }.padding()
    }
}
```

빌드: 성공 | morphing 확인 | 커밋: `feat(F005): 테마 선택 -- Glass 카드 + morphing`

### F006-F010: 차별화 기능 (핵심 코드)

**F006: 접근성 VoiceOver** -- 전체 UI에 accessibilityLabel/Hint/Value 적용 + 유틸리티:

```swift
extension View {
    func settingsAccessibility(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label).accessibilityHint(hint ?? "")
    }
}
// 모든 인터랙티브 요소에 적용, 섹션 헤더에 .isHeader trait 추가
```

커밋: `feat(F006): VoiceOver 접근성 전체 적용`

**F007: FoundationModels 검색** -- ViewModel + 가용성 체크 + 폴백:

```swift
@Observable class SettingsSearchViewModel {
    var searchResults: [SettingsItem] = []
    func search(query: String) async {
        guard !query.isEmpty else { searchResults = []; return }
        guard SystemLanguageModel.default.isAvailable else {
            searchResults = allSettings.filter { /* 키워드 폴백 */ }; return
        }
        do {
            let session = LanguageModelSession()
            // TODO: FoundationModels 실제 호출 로직
        } catch { /* 에러 처리 */ }
    }
}
```

> Builder가 호출부를 TODO로 남김. Phase 3에서 탐지 예정.

커밋: `feat(F007): FoundationModels 검색 -- UI + ViewModel 스텁`

**F008: haptic feedback** -- HapticManager + onChange/action 연결:

```swift
enum HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style); g.prepare(); g.impactOccurred()
    }
}
// Toggle.onChange, Button.action에서 HapticManager.impact() 호출
```

커밋: `feat(F008): haptic feedback`

**F009: 다크모드 전환** -- preferredColorScheme + easeInOut 애니메이션:

```swift
@State private var colorSchemeOverride: ColorScheme? = nil
// 테마 선택 시:
withAnimation(.easeInOut(duration: 0.5)) {
    colorSchemeOverride = id == "dark" ? .dark : id == "light" ? .light : nil
}
// SettingsView: .preferredColorScheme(colorSchemeOverride)
```

커밋: `feat(F009): 다크모드 전환 애니메이션`

**F010: 에러 상태** -- ErrorStateView + Glass 효과 + 재시도:

```swift
struct ErrorStateView: View {
    let message: String; let retryAction: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 48))
            Text("문제가 발생했어요").font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
            Button("다시 시도", action: retryAction).buttonStyle(.glass)
        }.padding().glassEffect(in: .rect(cornerRadius: 16))
    }
}
```

커밋: `feat(F010): 에러 상태 처리 -- ErrorStateView`

### 시뮬레이터 배포

```
baepsae install_app --udid "UDID" --app-path "build/Debug-iphonesimulator/LiquidSettings.app"
baepsae launch_app --udid "UDID" --bundle-id "com.example.LiquidSettings"
```

---

## Phase 3: EVALUATE (harness-evaluator)

**이 섹션이 가장 중요합니다.** 4축 다차원 평가를 상세히 시연합니다.

### Step 0: 도구 탐지 + 참조 문서

```
mcp-baepsae: 탐지 성공 -> RUNTIME_TOOL = "baepsae"
axe-simulator: 탐지 성공 (보조)
Xcode MCP: BuildProject, RenderPreview 사용 가능
Read: common-mistakes.md -> FoundationModels 가용성 체크 필수
Read: harness-design-principles.md -> 4축 평가 가중치
```

### 4축 평가 기준

| 축 | 가중치 | 설명 |
|----|--------|------|
| 기능 완성도 | 35% | 핵심 기능이 의도대로 동작하는가 |
| 코드 품질 | 25% | Best Practices, 안티패턴 부재 |
| UI 품질 | 25% | 레이아웃, 색상, 타이포, 다크모드 |
| 인터랙션 | 15% | 터치 반응, 전환, 접근성 |

---

### F001: SettingsView -- 상세 평가

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 9/10 | NavigationStack + ScrollView 정상. 3개 섹션 모두 표시 |
| 코드 품질 | 9/10 | @State private var 일관. MVVM 준수 |
| UI 품질 | 8/10 | 레이아웃 정상이나 다크모드 대비 미검증 |
| 인터랙션 | 8/10 | 스크롤 정상. 각 섹션 탭 반응 |

가중 평균: (9x0.3)+(9x0.2)+(8x0.3)+(8x0.2) = **8.5 -> PASS**

baepsae: launch_app 성공, screenshot -> 3개 섹션 + "설정" 타이틀 확인

---

### F005: 테마 선택 -- 상세 평가

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 7/10 | morphing 동작하나 선택 피드백이 약함 |
| 코드 품질 | 8/10 | @Namespace 올바르게 사용 |
| UI 품질 | 6/10 | **접근성 label 누락** -- analyze_ui로 탐지 |
| 인터랙션 | 7/10 | 탭 선택 가능하나 현재 선택 시각적 구분 약함 |

가중 평균: (7x0.3)+(8x0.2)+(6x0.3)+(7x0.2) = **6.9 -> PARTIAL**

baepsae: `analyze_ui -> 카드 접근성 트리: "button"(label 없음) x 3`

개선 권고: `.accessibilityLabel("\(name) 테마")` + `.accessibilityValue` 추가.
선택 카드에 border overlay로 시각적 강조 추가.

---

### F007: FoundationModels 검색 -- 상세 평가 (FAIL)

| 축 | 점수 | 근거 |
|----|------|------|
| 기능 완성도 | 4/10 | **핵심 검색 로직 TODO** -- import만 있고 실제 호출 미구현 |
| 코드 품질 | 3/10 | common-mistakes.md "가용성 체크" 준수. do-catch 내부 빈 상태 |
| UI 품질 | 5/10 | 검색 바 UI 존재하나 결과 화면 없음 |
| 인터랙션 | 2/10 | 검색 입력 후 반응 없음 -- verification_steps 전체 실패 |

가중 평균: (4x0.3)+(3x0.2)+(5x0.3)+(2x0.2) = **3.7 -> FAIL**

baepsae 검증:
```
tap "검색 바" -> 키보드 활성화 성공
type_text "알림 끄기" -> 입력 성공, 결과 영역 비어 있음 (FAIL)
tap "검색 결과 항목" -> 탭 대상 없음 (FAIL)
코드: SettingsSearchView.swift:28 -> "// TODO: FoundationModels 실제 호출 로직"
```

수정 지침:
> 1. `SettingsSearchView.swift:28` -- TODO 제거, `session.respond(to:)` 구현
> 2. references/foundation-models.md "Generating Text" 섹션 참조
> 3. `SettingsSearchResultsView` 신규 작성 -- 결과 리스트 + 섹션 이동
> 4. 폴백 경로(키워드 검색)도 동일 UI에 연결

---

### 나머지 기능 요약

| ID | 기능 | 기능완성 | 코드품질 | UI품질 | 인터랙션 | 가중평균 | 판정 |
|----|------|---------|---------|--------|---------|---------|------|
| F002 | glassEffect + Container | 9 | 9 | 9 | 8 | 8.8 | PASS |
| F003 | 프로필 섹션 | 8 | 8 | 8 | 8 | 8.0 | PASS |
| F004 | 알림 설정 | 9 | 8 | 8 | 9 | 8.5 | PASS |
| F006 | 접근성 VoiceOver | 8 | 9 | 7 | 8 | 7.9 | PASS |
| F008 | haptic feedback | 8 | 9 | N/A | 8 | 8.2 | PASS |
| F009 | 다크모드 전환 | 8 | 7 | 8 | 8 | 7.8 | PASS |
| F010 | 에러 상태 처리 | 8 | 8 | 8 | 7 | 7.8 | PASS |

### .claude/harness/evaluation-round-1.md 생성

```markdown
# Evaluation Round 1

## 메타 정보
- 검증 도구: mcp-baepsae | 시뮬레이터: iPhone 16 Pro
- 참조: harness-design-principles.md, common-mistakes.md

## 결과 요약
| ID | 가중평균 | 판정 | 비고 |
|----|---------|------|------|
| F001 | 8.5 | PASS | |
| F002 | 8.8 | PASS | |
| F003 | 8.0 | PASS | |
| F004 | 8.5 | PASS | |
| F005 | 6.9 | PARTIAL | 접근성 label 누락, 시각적 구분 약함 |
| F006 | 7.9 | PASS | |
| F007 | 3.7 | FAIL | 핵심 로직 TODO |
| F008 | 8.2 | PASS | |
| F009 | 7.8 | PASS | |
| F010 | 7.8 | PASS | |

## F007 수정 지침
SettingsSearchView.swift:28 -- session.respond(to:) 구현.
references/foundation-models.md "Generating Text" + "Availability Check" 참조.

## 종합: 8 PASS + 1 PARTIAL + 1 FAIL = 80% -> PASS
```

### 종합 결과

| 구분 | 수량 | 기능 ID |
|------|------|---------|
| PASS | 8개 | F001, F002, F003, F004, F006, F008, F009, F010 |
| PARTIAL | 1개 | F005 |
| FAIL | 1개 | F007 |

**통과율**: 80% (임계값 충족) -- **판정: PASS**

---

## 완료 보고

```
apple-craft harness 완료

기능 수: 10개
라운드: 1/3 (첫 라운드에서 통과)
PASS: 8개, PARTIAL: 1개, FAIL: 1개
변경 파일: 8개 (SettingsView, ProfileSection, NotificationSection, ThemeSection,
  AccessibilityModifiers, SettingsSearchView, HapticManager, ErrorStateView)
커밋 수: 10개
참조 문서: liquid-glass-swiftui.md, foundation-models.md,
  harness-design-principles.md, common-mistakes.md
검증 도구: mcp-baepsae (런타임), axe-simulator (접근성)

Git 히스토리:
  feat(F001): SettingsView 기본 구조
  feat(F002): glassEffect + GlassEffectContainer
  feat(F003): 프로필 섹션 -- Glass 버튼 + 편집 시트
  feat(F004): 알림 설정 -- Toggle 컨트롤
  feat(F005): 테마 선택 -- Glass 카드 + morphing
  feat(F006): VoiceOver 접근성 전체 적용
  feat(F007): FoundationModels 검색 -- UI + ViewModel 스텁
  feat(F008): haptic feedback
  feat(F009): 다크모드 전환 애니메이션
  feat(F010): 에러 상태 처리
```

---

## 핵심 포인트

### 1. Planner가 질문으로 맥락 수집 -- 이후 자율 진행의 기반

4개의 AskUserQuestion으로 대상 사용자, 아키텍처, 차별화 요구, 테스트 환경을 수집.
이 정보가 .claude/harness/harness-spec.md "사용자 맥락" 섹션에 기록되어 Phase 1.5 -> 3 전체 과정의
의사결정 기반이 됩니다. 사용자는 Phase 1 확인 후 완료까지 개입 불필요.

### 2. Evaluator가 검증 기준을 사전 리뷰 (Phase 1.5)

VERIFICATION_REVIEW 모드에서 Planner의 verification_steps를 보강.
F003의 "편집 -> 저장 -> 반영", F006의 "analyze_ui 접근성 트리", F007의
"FoundationModels 가용성 체크 코드 확인"이 추가됨. Builder 코드 작성 전에
검증 기준이 확립되어 평가의 공정성과 깊이가 보장됩니다.

### 3. 10개 기능으로 야심찬 범위 (기본 5 + 차별화 3 + 품질 2)

기존 5개에 차별화 3개(접근성, AI 검색, haptic) + 품질 2개(다크모드, 에러)를 추가.
사용자 맥락에서 추출한 요구가 F006, F007로 구체화. under-scope 방지가
Planner의 핵심 가치.

### 4. baepsae로 실제 인터랙션 테스트 -- TODO를 런타임에서 탐지

mcp-baepsae로 시뮬레이터에서 앱을 조작. F007에 "알림 끄기" 입력 후 결과 미표시를
런타임에서 탐지. 정적 분석만으로는 "빌드 성공"으로 PASS했을 F007이 인터랙션
테스트 덕분에 FAIL로 정확 판정. Generator-Evaluator 분리 + 런타임 검증의 핵심 가치.

### 5. 4축 다차원 평가 -- "빌드 성공"이 아닌 "얼마나 잘 만들었나"

기능 완성도, 코드 품질, UI 품질, 인터랙션 4축 평가. F005는 기능 완성도 7점이지만
UI 품질 6점(접근성 label 누락)으로 PARTIAL. harness-design-principles.md의
Design Quality/Originality/Craft/Functionality를 적용한 결과. "빌드 성공"만으로는
잡을 수 없는 품질 문제를 구조적으로 탐지.

### 6. .claude/harness/evaluation-round-1.md로 구체적 수정 지침

단순 점수가 아닌 파일명, 라인 번호, 참조 문서까지 명시하는 수정 지침 제공.
Builder가 다음 라운드에서 추가 조사 없이 바로 수정 착수 가능. Anthropic 사례의
"Evaluator 발견은 추가 조사 없이 조치 가능할 만큼 구체적" 원칙을 구현.
