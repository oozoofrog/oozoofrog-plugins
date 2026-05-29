# Walkthrough: Liquid Glass Settings Screen Implementation

The full process of applying Liquid Glass design to a SwiftUI settings screen
using apple-harness's Plan→Build→Evaluate loop. It demonstrates the improved
harness flow that verifies 10 features (5 core + 5 differentiating) via 4-axis
multi-dimensional evaluation.

> **Note**: This walkthrough is an execution example in an environment **without Pencil MCP connected**.
> Phase 2 (DESIGN) runs only when Pencil MCP is available, so it is auto-skipped here.
> Phase numbers follow the actual execution order, excluding skipped phases.

---

## User Request

> "Build a settings screen with Liquid Glass applied from scratch. I need profile, notification, and theme settings sections."

---

## Phase 1: PLAN (harness-planner)

### Step 0: Internalize Design Principles

The Planner Reads `harness-design-principles.md` to confirm the core principles:
- **Minimal complexity**: encode only assumptions about what the model cannot do on its own
- **Generator-Evaluator separation**: removes self-evaluation bias
- **Why keep the Planner**: highest ROI at 0.4% of total cost

### Step 1: Gather User Context via AskUserQuestion

The Planner gathers context with 4 questions. This is the foundation for subsequent autonomous progress.

```
Q1: Who are the primary users of this settings screen?
A1: A social app for general consumers. People in their 20s-30s, a design-conscious user base.

Q2: Adding to an existing project? What architecture pattern?
A2: Existing SwiftUI project, MVVM + @Observable macro.

Q3: Any features you specifically want beyond the basic settings screen?
A3: FoundationModels natural-language search + VoiceOver accessibility support.

Q4: Test environment?
A4: iPhone 16 Pro simulator, iOS 26 beta.
```

### Step 2: Create {HARNESS_DIR}/harness-spec.md

```markdown
# Product Spec: Liquid Glass Settings Screen

## Overview
SwiftUI Liquid Glass settings screen. 3 sections (profile/notification/theme) + accessibility, AI search,
haptic, dark mode transition, and error handling.

## User Context
- Target: design-conscious general consumers in their 20s-30s
- Architecture: MVVM + @Observable
- Differentiating requirements: FoundationModels natural-language search, VoiceOver accessibility
- Test environment: iPhone 16 Pro simulator, iOS 26 beta

## Differentiating Features
1. FoundationModels natural-language settings search
2. VoiceOver accessibilityLabel applied throughout
3. haptic feedback on settings change
4. dark/light mode transition animation
5. error-state UI on data load failure

## Target Platform
iOS 26+ / SwiftUI + Liquid Glass, FoundationModels, MVVM + @Observable
```

### Step 3: Create {HARNESS_DIR}/features.json

10 features. The Planner drafts the initial verification_steps.

| ID | category | description | verification_steps (summary) | reference |
|----|----------|-------------|--------------------------|-----------|
| F001 | config | SettingsView base structure | build -> launch -> screenshot | liquid-glass-swiftui.md |
| F002 | ui | glassEffect() + GlassEffectContainer | render_preview -> screenshot | liquid-glass-swiftui.md |
| F003 | ui | Profile -- avatar + edit + .buttonStyle(.glass) | tap edit -> type_text name | liquid-glass-swiftui.md |
| F004 | ui | Notification settings -- Toggle + Glass background | tap toggle -> screenshot | liquid-glass-swiftui.md |
| F005 | ui | Theme -- Glass card + @Namespace morphing | tap dark card -> morphing | liquid-glass-swiftui.md |
| F006 | ui | Accessibility -- VoiceOver accessibilityLabel | analyze_ui accessibility tree | liquid-glass-swiftui.md |
| F007 | logic | FoundationModels natural-language settings search | tap search -> type "turn off notifications" | foundation-models.md |
| F008 | ui | haptic feedback on settings change | tap toggle -> code_review | liquid-glass-swiftui.md |
| F009 | ui | dark/light mode transition animation | tap light -> confirm transition | liquid-glass-swiftui.md |
| F010 | ui | Error state -- guidance on load failure | simulate_error -> screenshot | liquid-glass-swiftui.md |

All features status: "pending". priority: F001(1) ~ F010(10).

### User Confirmation (final checkpoint)

> {HARNESS_DIR}/harness-spec.md: 10 features, iOS 26+, MVVM + @Observable
> {HARNESS_DIR}/features.json: F001-F010 (5 core + 5 differentiating)
> "Proceed with this spec?" -> User: "Sounds good, go ahead."

---

## Phase 1.5: VERIFICATION REVIEW (harness-evaluator)

The Evaluator is invoked in VERIFICATION_REVIEW mode. **Proceeds autonomously without user confirmation.**

**F003 reinforcement** -- add an "edit -> save -> reflect" scenario:
```json
[{"action":"tap","target":"edit button","expect":"transition to edit screen"},
 {"action":"type_text","target":"name field","text":"new name","expect":"input reflected"},
 {"action":"tap","target":"save button","expect":"return to settings screen"},
 {"action":"screenshot","expect":"changed name shown in profile section"}]
```

**F006 reinforcement** -- add an analyze_ui accessibility tree check:
```json
[{"action":"analyze_ui","expect":"label present on every element in accessibility tree"},
 {"action":"analyze_ui","target":"edit button","expect":"label: 'Edit Profile'"},
 {"action":"analyze_ui","target":"theme card","expect":"label + hint present"},
 {"action":"voiceover_navigate","expect":"all elements read aloud during sequential navigation"}]
```

**F007 reinforcement** -- FoundationModels interaction + code verification:
```json
[{"action":"tap","target":"search bar","expect":"keyboard activated"},
 {"action":"type_text","text":"turn off notifications","expect":"notification settings item shown"},
 {"action":"tap","target":"search result","expect":"navigate to the relevant section"},
 {"action":"type_text","text":"meaningless string","expect":"no-results notice"},
 {"action":"code_review","target":"SettingsSearchView.swift",
  "expect":"SystemLanguageModel.default availability check present"}]
```

Auto-advance -- move to Phase 2: BUILD.

---

## Phase 2: BUILD (harness-builder)

The Builder implements the 10 features sequentially in priority order.

### F001: SettingsView base structure

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
            .navigationTitle("Settings")
            .searchable(text: $searchText, prompt: "Search settings")
        }
    }
}
```

Build: success | Commit: `feat(F001): SettingsView base structure`

### F002: Apply Liquid Glass

```swift
// SettingsView body modification — wrap in GlassEffectContainer
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

Build: success | Preview confirmed | Commit: `feat(F002): glassEffect + GlassEffectContainer`

### F003: Profile section

```swift
struct ProfileSectionView: View {
    @State private var userName = "User"
    @State private var isEditing = false
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48)).foregroundStyle(.secondary)
                .accessibilityLabel("Profile photo")
            VStack(alignment: .leading) {
                Text(userName).font(.headline)
                Text("Edit Profile").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button("Edit") { isEditing = true }
                .buttonStyle(.glass)
                .accessibilityLabel("Edit Profile")
        }.padding()
        .sheet(isPresented: $isEditing) { ProfileEditView(userName: $userName) }
    }
}
```

Build: success | Commit: `feat(F003): profile section -- Glass button + edit sheet`

### F004: Notification settings

```swift
struct NotificationSectionView: View {
    @State private var pushEnabled = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notification settings", systemImage: "bell.fill").font(.headline)
            Toggle("Push notifications", isOn: $pushEnabled)
                .accessibilityValue(pushEnabled ? "On" : "Off")
            Toggle("Sound", isOn: $soundEnabled)
            Toggle("Badge", isOn: $badgeEnabled)
        }.padding()
    }
}
```

Build: success | Commit: `feat(F004): notification settings -- Toggle controls`

### F005: Theme selection

```swift
struct ThemeSectionView: View {
    @State private var selectedTheme = "system"
    @Namespace private var themeNamespace
    let themes = [("system","Auto","circle.lefthalf.filled"),
                  ("light","Light","sun.max.fill"),("dark","Dark","moon.fill")]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Theme", systemImage: "paintpalette.fill").font(.headline)
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

Build: success | morphing confirmed | Commit: `feat(F005): theme selection -- Glass card + morphing`

### F006-F010: Differentiating features (core code)

**F006: Accessibility VoiceOver** -- apply accessibilityLabel/Hint/Value across the entire UI + utility:

```swift
extension View {
    func settingsAccessibility(label: String, hint: String? = nil) -> some View {
        self.accessibilityLabel(label).accessibilityHint(hint ?? "")
    }
}
// applied to every interactive element, .isHeader trait added to section headers
```

Commit: `feat(F006): VoiceOver accessibility applied throughout`

**F007: FoundationModels search** -- ViewModel + availability check + fallback:

```swift
@Observable class SettingsSearchViewModel {
    var searchResults: [SettingsItem] = []
    func search(query: String) async {
        guard !query.isEmpty else { searchResults = []; return }
        guard SystemLanguageModel.default.isAvailable else {
            searchResults = allSettings.filter { /* keyword fallback */ }; return
        }
        do {
            let session = LanguageModelSession()
            // TODO: actual FoundationModels call logic
        } catch { /* error handling */ }
    }
}
```

> The Builder left the call site as a TODO. To be detected in Phase 3.

Commit: `feat(F007): FoundationModels search -- UI + ViewModel stub`

**F008: haptic feedback** -- HapticManager + onChange/action wiring:

```swift
enum HapticManager {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style); g.prepare(); g.impactOccurred()
    }
}
// call HapticManager.impact() in Toggle.onChange and Button.action
```

Commit: `feat(F008): haptic feedback`

**F009: Dark mode transition** -- preferredColorScheme + easeInOut animation:

```swift
@State private var colorSchemeOverride: ColorScheme? = nil
// on theme selection:
withAnimation(.easeInOut(duration: 0.5)) {
    colorSchemeOverride = id == "dark" ? .dark : id == "light" ? .light : nil
}
// SettingsView: .preferredColorScheme(colorSchemeOverride)
```

Commit: `feat(F009): dark mode transition animation`

**F010: Error state** -- ErrorStateView + Glass effect + retry:

```swift
struct ErrorStateView: View {
    let message: String; let retryAction: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 48))
            Text("Something went wrong").font(.headline)
            Text(message).font(.subheadline).foregroundStyle(.secondary)
            Button("Try again", action: retryAction).buttonStyle(.glass)
        }.padding().glassEffect(in: .rect(cornerRadius: 16))
    }
}
```

Commit: `feat(F010): error-state handling -- ErrorStateView`

### Simulator Deployment

```
baepsae install_app --udid "UDID" --app-path "build/Debug-iphonesimulator/LiquidSettings.app"
baepsae launch_app --udid "UDID" --bundle-id "com.example.LiquidSettings"
```

---

## Phase 3: EVALUATE (harness-evaluator)

**This section is the most important.** It demonstrates 4-axis multi-dimensional evaluation in detail.

### Step 0: Tool Detection + Reference Docs

```
mcp-baepsae: detection succeeded -> RUNTIME_TOOL = "baepsae"
axe-simulator: detection succeeded (auxiliary)
Xcode MCP: BuildProject, RenderPreview available
Read: common-mistakes.md -> FoundationModels availability check required
Read: harness-design-principles.md -> 4-axis evaluation weights
```

### 4-Axis Evaluation Criteria

| Axis | Weight | Description |
|----|--------|------|
| Functional completeness | 35% | Does the core functionality behave as intended |
| Code quality | 25% | Best Practices, absence of anti-patterns |
| UI quality | 25% | Layout, color, typography, dark mode |
| Interaction | 15% | Touch response, transitions, accessibility |

---

### F001: SettingsView -- detailed evaluation

| Axis | Score | Rationale |
|----|------|------|
| Functional completeness | 9/10 | NavigationStack + ScrollView correct. All 3 sections shown |
| Code quality | 9/10 | @State private var consistent. MVVM compliant |
| UI quality | 8/10 | Layout correct but dark-mode contrast unverified |
| Interaction | 8/10 | Scroll correct. Each section taps respond |

Weighted average: (9x0.3)+(9x0.2)+(8x0.3)+(8x0.2) = **8.5 -> PASS**

baepsae: launch_app success, screenshot -> 3 sections + "Settings" title confirmed

---

### F005: Theme selection -- detailed evaluation

| Axis | Score | Rationale |
|----|------|------|
| Functional completeness | 7/10 | morphing works but selection feedback is weak |
| Code quality | 8/10 | @Namespace used correctly |
| UI quality | 6/10 | **accessibility label missing** -- detected via analyze_ui |
| Interaction | 7/10 | Tap selection works but visual distinction of current selection is weak |

Weighted average: (7x0.3)+(8x0.2)+(6x0.3)+(7x0.2) = **6.9 -> PARTIAL**

baepsae: `analyze_ui -> card accessibility tree: "button"(no label) x 3`

Improvement recommendation: add `.accessibilityLabel("\(name) theme")` + `.accessibilityValue`.
Add a border overlay on the selected card for visual emphasis.

---

### F007: FoundationModels search -- detailed evaluation (FAIL)

| Axis | Score | Rationale |
|----|------|------|
| Functional completeness | 4/10 | **core search logic is TODO** -- only the import exists, actual call unimplemented |
| Code quality | 3/10 | common-mistakes.md "availability check" complied with. Empty body inside do-catch |
| UI quality | 5/10 | Search bar UI exists but no results screen |
| Interaction | 2/10 | No response after search input -- all verification_steps fail |

Weighted average: (4x0.3)+(3x0.2)+(5x0.3)+(2x0.2) = **3.7 -> FAIL**

baepsae verification:
```
tap "search bar" -> keyboard activation succeeded
type_text "turn off notifications" -> input succeeded, results area empty (FAIL)
tap "search result item" -> no tap target (FAIL)
code: SettingsSearchView.swift:28 -> "// TODO: actual FoundationModels call logic"
```

Fix instructions:
> 1. `SettingsSearchView.swift:28` -- remove TODO, implement `session.respond(to:)`
> 2. Refer to references/foundation-models.md "Generating Text" section
> 3. Write new `SettingsSearchResultsView` -- results list + section navigation
> 4. Wire the fallback path (keyword search) into the same UI

---

### Summary of Remaining Features

| ID | Feature | Func.compl. | Code qual. | UI qual. | Interaction | Weighted avg | Verdict |
|----|------|---------|---------|--------|---------|---------|------|
| F002 | glassEffect + Container | 9 | 9 | 9 | 8 | 8.8 | PASS |
| F003 | Profile section | 8 | 8 | 8 | 8 | 8.0 | PASS |
| F004 | Notification settings | 9 | 8 | 8 | 9 | 8.5 | PASS |
| F006 | Accessibility VoiceOver | 8 | 9 | 7 | 8 | 7.9 | PASS |
| F008 | haptic feedback | 8 | 9 | N/A | 8 | 8.2 | PASS |
| F009 | Dark mode transition | 8 | 7 | 8 | 8 | 7.8 | PASS |
| F010 | Error state handling | 8 | 8 | 8 | 7 | 7.8 | PASS |

### Create {HARNESS_DIR}/evaluation-round-1.md

```markdown
# Evaluation Round 1

## Meta Info
- Verification tool: mcp-baepsae | Simulator: iPhone 16 Pro
- References: harness-design-principles.md, common-mistakes.md

## Result Summary
| ID | Weighted avg | Verdict | Notes |
|----|---------|------|------|
| F001 | 8.5 | PASS | |
| F002 | 8.8 | PASS | |
| F003 | 8.0 | PASS | |
| F004 | 8.5 | PASS | |
| F005 | 6.9 | PARTIAL | accessibility label missing, visual distinction weak |
| F006 | 7.9 | PASS | |
| F007 | 3.7 | FAIL | core logic TODO |
| F008 | 8.2 | PASS | |
| F009 | 7.8 | PASS | |
| F010 | 7.8 | PASS | |

## F007 Fix Instructions
SettingsSearchView.swift:28 -- implement session.respond(to:).
Refer to references/foundation-models.md "Generating Text" + "Availability Check".

## Overall: 8 PASS + 1 PARTIAL + 1 FAIL = 80% -> PASS
```

### Overall Result

| Category | Count | Feature IDs |
|------|------|---------|
| PASS | 8 | F001, F002, F003, F004, F006, F008, F009, F010 |
| PARTIAL | 1 | F005 |
| FAIL | 1 | F007 |

**Pass rate**: 80% (threshold met) -- **Verdict: PASS**

---

## Completion Report

```
apple-craft harness complete

Feature count: 10
Rounds: 1/3 (passed on the first round)
PASS: 8, PARTIAL: 1, FAIL: 1
Changed files: 8 (SettingsView, ProfileSection, NotificationSection, ThemeSection,
  AccessibilityModifiers, SettingsSearchView, HapticManager, ErrorStateView)
Commit count: 10
Reference docs: liquid-glass-swiftui.md, foundation-models.md,
  harness-design-principles.md, common-mistakes.md
Verification tools: mcp-baepsae (runtime), axe-simulator (accessibility)

Git history:
  feat(F001): SettingsView base structure
  feat(F002): glassEffect + GlassEffectContainer
  feat(F003): profile section -- Glass button + edit sheet
  feat(F004): notification settings -- Toggle controls
  feat(F005): theme selection -- Glass card + morphing
  feat(F006): VoiceOver accessibility applied throughout
  feat(F007): FoundationModels search -- UI + ViewModel stub
  feat(F008): haptic feedback
  feat(F009): dark mode transition animation
  feat(F010): error-state handling
```

---

## Key Points

### 1. The Planner gathers context via questions -- the foundation for subsequent autonomous progress

4 AskUserQuestions gather the target user, architecture, differentiating requirements, and test environment.
This information is recorded in the "User Context" section of {HARNESS_DIR}/harness-spec.md and becomes
the decision-making basis across the entire Phase 1.5 -> 3 process. The user needs no intervention from
Phase 1 confirmation through completion.

### 2. The Evaluator pre-reviews the verification criteria (Phase 1.5)

In VERIFICATION_REVIEW mode it reinforces the Planner's verification_steps.
F003's "edit -> save -> reflect", F006's "analyze_ui accessibility tree", and F007's
"FoundationModels availability-check code verification" were added. Before the Builder writes code,
the verification criteria are established, ensuring the fairness and depth of evaluation.

### 3. Ambitious scope with 10 features (5 core + 3 differentiating + 2 quality)

Added 3 differentiating (accessibility, AI search, haptic) + 2 quality (dark mode, error) to the original 5.
Requirements extracted from user context were concretized as F006, F007. Preventing under-scope is
the Planner's core value.

### 4. Real interaction testing with baepsae -- detecting TODOs at runtime

Operate the app on the simulator with mcp-baepsae. After entering "turn off notifications" in F007, the missing result
was detected at runtime. F007, which static analysis alone would have PASSed as "build success", was
accurately judged FAIL thanks to interaction testing. The core value of Generator-Evaluator separation + runtime verification.

### 5. 4-axis multi-dimensional evaluation -- not "build success" but "how well it was made"

Evaluation across 4 axes: functional completeness, code quality, UI quality, interaction. F005 scored 7 in functional completeness but
6 in UI quality (missing accessibility label), resulting in PARTIAL. The result of applying
harness-design-principles.md's Design Quality/Originality/Craft/Functionality. It structurally detects quality issues
that "build success" alone cannot catch.

### 6. Concrete fix instructions via {HARNESS_DIR}/evaluation-round-1.md

Provides fix instructions that specify not just a score but file name, line number, and reference docs.
The Builder can immediately begin fixes in the next round without additional investigation. It implements the
"Evaluator findings are concrete enough to act on without additional investigation" principle from the Anthropic case.
