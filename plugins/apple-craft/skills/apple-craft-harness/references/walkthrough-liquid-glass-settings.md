# Walkthrough: Liquid Glass 설정 화면 구현

apple-craft-harness의 Plan→Build→Evaluate 루프를 사용하여 SwiftUI 설정 화면에 Liquid Glass 디자인을 적용하는 전체 과정입니다.

---

## 사용자 요청

> "처음부터 Liquid Glass를 적용한 설정 화면을 만들어줘. 프로필, 알림, 테마 설정 섹션이 필요해."

---

## Phase 1: PLAN (harness-planner)

### 생성된 harness-spec.md

```markdown
# 제품 스펙: Liquid Glass 설정 화면

## 개요
SwiftUI로 구현하는 설정 화면. Liquid Glass 디자인 시스템을 전면 적용하여
프로필, 알림, 테마 3개 섹션으로 구성. 각 섹션은 glassEffect로 시각적 계층을
구분하고, GlassEffectContainer로 morphing 전환을 지원.

## 대상 플랫폼
iOS 26+

## 핵심 기능
1. Liquid Glass가 적용된 설정 메인 화면 (3개 섹션)
2. 프로필 편집 화면 (Glass 버튼 스타일)
3. 알림 설정 토글 (Glass 효과 내 Toggle)
4. 테마 선택 화면 (Glass 카드 기반 선택)
5. NavigationStack 기반 화면 전환 (Glass morphing)

## 기술 스택
- UI: SwiftUI
- 프레임워크: SwiftUI Liquid Glass
- 참조 문서: references/liquid-glass-swiftui.md

## 범위 외
- 서버 연동, 데이터 영속성, 인증
```

### 생성된 features.json

```json
[
  {
    "id": "F001",
    "category": "config",
    "description": "SettingsView 기본 구조 — NavigationStack + List",
    "verification": "BuildProject 성공 + XcodeRefreshCodeIssuesInFile 에러 0",
    "status": "pending",
    "reference": "references/liquid-glass-swiftui.md",
    "priority": 1
  },
  {
    "id": "F002",
    "category": "ui",
    "description": "3개 섹션에 glassEffect() 적용 + GlassEffectContainer 래핑",
    "verification": "RenderPreview에서 유리 효과 렌더링 확인",
    "status": "pending",
    "reference": "references/liquid-glass-swiftui.md",
    "priority": 2
  },
  {
    "id": "F003",
    "category": "ui",
    "description": "프로필 섹션 — 아바타 + 이름 편집 + .buttonStyle(.glass)",
    "verification": "RenderPreview에서 Glass 버튼 렌더링 확인",
    "status": "pending",
    "reference": "references/liquid-glass-swiftui.md",
    "priority": 3
  },
  {
    "id": "F004",
    "category": "ui",
    "description": "알림 설정 — Toggle 컨트롤 + Glass 배경",
    "verification": "BuildProject 성공",
    "status": "pending",
    "reference": "references/liquid-glass-swiftui.md",
    "priority": 4
  },
  {
    "id": "F005",
    "category": "ui",
    "description": "테마 선택 — Glass 카드 기반 선택 UI + @Namespace morphing",
    "verification": "RenderPreview에서 카드 선택 UI 렌더링 확인",
    "status": "pending",
    "reference": "references/liquid-glass-swiftui.md",
    "priority": 5
  }
]
```

---

## Phase 2: BUILD (harness-builder)

Builder가 features.json의 priority 순서대로 하나씩 구현합니다.

### F001: SettingsView 기본 구조

```swift
// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("프로필") {
                    ProfileSectionView()
                }
                Section("알림") {
                    NotificationSectionView()
                }
                Section("테마") {
                    ThemeSectionView()
                }
            }
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
```

**빌드 결과**: BuildProject ✅ 성공
**커밋**: `feat(F001): SettingsView 기본 구조 — NavigationStack + List`
**features.json**: F001 status → "built"

### F002: Liquid Glass 적용

참조 문서 `references/liquid-glass-swiftui.md`에서 핵심 패턴 확인:
- `glassEffect()` 모디파이어로 유리 효과 적용
- `GlassEffectContainer`로 여러 뷰를 감싸 morphing 지원
- `.interactive()` 추가로 터치 반응

```swift
// SettingsView.swift (수정)
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                // GlassEffectContainer로 감싸서 morphing 지원
                GlassEffectContainer {
                    VStack(spacing: 16) {
                        ProfileSectionView()
                            .glassEffect(in: .rect(cornerRadius: 16))

                        NotificationSectionView()
                            .glassEffect(in: .rect(cornerRadius: 16))

                        ThemeSectionView()
                            .glassEffect(in: .rect(cornerRadius: 16))
                    }
                    .padding()
                }
            }
            .navigationTitle("설정")
        }
    }
}
```

**빌드 결과**: BuildProject ✅ 성공
**프리뷰**: RenderPreview ✅ 유리 효과 렌더링 확인
**커밋**: `feat(F002): 3개 섹션에 glassEffect + GlassEffectContainer 적용`
**features.json**: F002 status → "built"

### F003: 프로필 섹션

```swift
// ProfileSectionView.swift
import SwiftUI

struct ProfileSectionView: View {
    @State private var userName = "사용자"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading) {
                    Text(userName)
                        .font(.headline)
                    Text("프로필 편집")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Glass 버튼 스타일 (참조: liquid-glass-swiftui.md)
                Button("편집") {
                    // TODO: 프로필 편집 화면 전환
                }
                .buttonStyle(.glass)
            }
            .padding()
        }
    }
}
```

**빌드 결과**: BuildProject ✅ 성공
**프리뷰**: RenderPreview ✅ Glass 버튼 렌더링 확인
**커밋**: `feat(F003): 프로필 섹션 — 아바타 + 이름 + Glass 버튼`

### F004: 알림 설정

```swift
// NotificationSectionView.swift
import SwiftUI

struct NotificationSectionView: View {
    @State private var pushEnabled = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("알림 설정", systemImage: "bell.fill")
                .font(.headline)

            Toggle("푸시 알림", isOn: $pushEnabled)
            Toggle("소리", isOn: $soundEnabled)
            Toggle("배지", isOn: $badgeEnabled)
        }
        .padding()
    }
}
```

**빌드 결과**: BuildProject ✅ 성공
**커밋**: `feat(F004): 알림 설정 — Toggle 컨트롤`

### F005: 테마 선택

```swift
// ThemeSectionView.swift
import SwiftUI

struct ThemeSectionView: View {
    @State private var selectedTheme = "system"
    @Namespace private var themeNamespace

    let themes = [
        ("system", "자동", "circle.lefthalf.filled"),
        ("light", "라이트", "sun.max.fill"),
        ("dark", "다크", "moon.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("테마", systemImage: "paintpalette.fill")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(themes, id: \.0) { id, name, icon in
                    Button {
                        withAnimation {
                            selectedTheme = id
                        }
                    } label: {
                        VStack {
                            Image(systemName: icon)
                                .font(.title2)
                            Text(name)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    // @Namespace으로 morphing 전환 (참조: liquid-glass-swiftui.md)
                    .glassEffect(
                        in: .rect(cornerRadius: 12),
                        isActive: selectedTheme == id
                    )
                    .glassEffectID(id, in: themeNamespace)
                }
            }
        }
        .padding()
    }
}
```

**빌드 결과**: BuildProject ✅ 성공
**프리뷰**: RenderPreview ✅ 카드 선택 UI + morphing 확인
**커밋**: `feat(F005): 테마 선택 — Glass 카드 + @Namespace morphing`

---

## Phase 3: EVALUATE (harness-evaluator)

### Evaluate Round 1/3

| ID | 기능 | 점수 | 상세 |
|----|------|------|------|
| F001 | SettingsView 기본 구조 | **PASS** | 빌드 성공, NavigationStack + ScrollView 구조 정상 |
| F002 | glassEffect + Container | **PASS** | RenderPreview에서 유리 효과 확인, GlassEffectContainer 올바르게 래핑 |
| F003 | 프로필 섹션 | **PASS** | .buttonStyle(.glass) 정상 적용, 프리뷰 확인 |
| F004 | 알림 설정 | **PASS** | Toggle 정상 동작, 빌드 성공 |
| F005 | 테마 선택 | **PARTIAL** | morphing 구현되었으나 `isActive` 파라미터 사용법이 참조 문서와 다름. `liquid-glass-swiftui.md`에 따르면 `GlassEffect`의 `isActive`가 아닌 별도 조건부 `glassEffect` 적용이 권장됨 |

**총점**: 4/5 PASS + 1 PARTIAL = 90% (임계값 80% 충족)

### 판정: **PASS** ✅

PARTIAL 항목(F005)에 대한 개선 권고:

> **F005 개선 사항**: `ThemeSectionView.swift`에서 `glassEffect(isActive:)` 대신
> 선택된 테마에만 `glassEffect()`를 적용하고 비선택 항목은 `glassEffect` 없이
> 렌더링하세요. 이렇게 하면 선택 시 morphing 전환이 더 자연스럽습니다.
> 참조: `references/liquid-glass-swiftui.md` — "Customizing Liquid Glass Effects" 섹션

---

## 완료 보고

```
✅ apple-craft harness 완료

기능 수: 5개
라운드: 1/3 (첫 라운드에서 통과)
PASS: 4개, PARTIAL: 1개
변경 파일: 4개 (SettingsView, ProfileSection, NotificationSection, ThemeSection)
커밋 수: 5개
참조 문서: references/liquid-glass-swiftui.md

Git 히스토리:
  feat(F001): SettingsView 기본 구조 — NavigationStack + List
  feat(F002): 3개 섹션에 glassEffect + GlassEffectContainer 적용
  feat(F003): 프로필 섹션 — 아바타 + 이름 + Glass 버튼
  feat(F004): 알림 설정 — Toggle 컨트롤
  feat(F005): 테마 선택 — Glass 카드 + @Namespace morphing
```

---

## 핵심 포인트

이 워크스루에서 하네스가 보여주는 패턴:

1. **Planner가 범위를 설정** — 5개 기능으로 분해, 각각 검증 가능한 기준 포함
2. **Builder가 한 번에 한 기능씩** — 참조 문서 기반, 빌드 검증, 기능별 커밋
3. **Evaluator가 회의적으로 검증** — F005에서 PARTIAL 부여, 구체적 수정 방향 제시
4. **1라운드에 90%** — Opus 4.6 수준에서는 대부분 1-2라운드에서 완료
5. **참조 문서가 핵심** — `liquid-glass-swiftui.md`의 GlassEffectContainer, .buttonStyle(.glass), @Namespace 패턴이 코드에 직접 반영
