# Harness Design Principles

> apple-craft 하네스 에이전트가 참조하는 핵심 설계 원칙 문서.
> Source: [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Anthropic, 2026-03-24)

---

## 핵심 원칙

에이전트가 반드시 따라야 하는 5가지 설계 원칙.

1. **최소 복잡성**: "Find the simplest solution possible, and only increase complexity when needed." — 하네스의 모든 구성요소는 모델이 스스로 할 수 없는 것에 대한 가정을 인코딩한다. 불필요한 복잡성은 제거하라.

2. **구성요소 가정 검증**: "Every component in a harness encodes an assumption about what the model can't do on its own, and those assumptions are worth stress testing." — 모델이 개선될 때마다 기존 구성요소가 여전히 필요한지 재평가하라. 가정이 잘못되었거나 시효가 만료될 수 있다.

3. **Generator-Evaluator 분리**: "Tuning a standalone evaluator to be skeptical turns out to be far more tractable than making a generator critical of its own work." — 자기 평가 편향(self-evaluation bias)을 구조적으로 제거하려면 생성과 평가를 분리하라. Evaluator가 독립적으로 존재해야 회의적(skeptical) 채점이 가능하다.

4. **Evaluator 조건부 활용**: "The evaluator is not a fixed yes-or-no decision. It is worth the cost when the task sits beyond what the current model does reliably solo." — Evaluator의 가치는 작업이 모델의 capability boundary를 넘어설 때 발생한다. 모델이 단독으로 안정적으로 처리 가능한 작업에는 오버헤드일 수 있다.

5. **하네스 공간 이동**: "The space of interesting harness combinations doesn't shrink as models improve. Instead, it moves." — 모델 성능이 향상되어도 하네스가 불필요해지는 것이 아니라, 더 복잡하고 새로운 작업 영역으로 이동한다. 다음 novel combination을 찾는 것이 AI 엔지니어의 핵심 업무다.

---

## V2 패턴 (Claude Opus 4.6 기준)

Claude Opus 4.6 출시 이후, 하네스를 대폭 단순화한 결과물. Opus 4.6은 "plans more carefully, sustains agentic tasks for longer, can operate more reliably in larger codebases, and has better code review and debugging skills to catch its own mistakes"로 설명되며, long-context retrieval도 크게 개선되었다.

### Sprint 구조 제거

- **이유**: Sprint 구조는 모델이 장시간 일관성을 유지하지 못하는 한계를 보완하기 위한 것이었다. Opus 4.6은 2시간 이상의 연속 빌드 세션에서도 일관성을 유지하므로 sprint 분해가 더 이상 load-bearing하지 않다.
- **방법**: Sprint 단위 반복(sprint contract 협상 -> 구현 -> QA)을 제거하고, Generator가 전체 빌드를 연속으로 수행한 뒤 Evaluator가 단일 패스로 평가.

### Evaluator 단일 패스 전환

- Sprint마다 QA를 수행하던 방식에서, 빌드 완료 후 1회 평가로 전환.
- Evaluator가 문제를 발견하면 Generator에게 피드백을 전달하고, 필요시 추가 Build-QA 라운드를 반복.
- 실제 DAW 사례에서는 3라운드(Build-QA)로 수렴.

### Planner 유지 이유

- Planner 없이 Generator에게 raw prompt만 주면 **under-scope** 현상 발생: "given the raw prompt, it would start building without first speccing its work, and end up creating a less feature-rich application than the planner did."
- Planner는 전체 비용의 0.4%($0.46)만 사용하면서 가장 높은 ROI를 제공한다.

### Evaluator 유지 이유

- Opus 4.6에서도 Generator는 여전히 디테일을 누락하거나 기능을 stub으로 남기는 경향이 있다.
- Evaluator는 **capability boundary** 밖의 작업에서 여전히 실질적 개선(lift)을 제공한다.

### 자동 compaction으로 context reset 대체

- Claude Sonnet 4.5에서는 context anxiety가 심해 compaction만으로는 부족했고, context reset(컨텍스트 윈도우 전체 초기화 + structured handoff)이 필수였다.
- Opus 4.6은 context anxiety를 크게 완화하여, Claude Agent SDK의 자동 compaction만으로 context growth를 관리할 수 있게 되었다.
- Context reset을 제거함으로써 오케스트레이션 복잡성, 토큰 오버헤드, 레이턴시가 감소.

---

## Evaluator 튜닝 방법론

### Self-evaluation bias와 그 해결

- "When asked to evaluate work they've produced, agents tend to respond by confidently praising the work -- even when, to a human observer, the quality is obviously mediocre."
- 특히 디자인 같은 주관적 작업에서 심각: "there is no binary check equivalent to a verifiable software test."
- **해결**: Generator와 Evaluator를 분리한다. 분리만으로 관대함이 자동 제거되지는 않지만, 독립된 Evaluator를 회의적으로 튜닝하는 것이 Generator의 자기 비판을 끌어내는 것보다 훨씬 다루기 쉽다(tractable).

### Context anxiety 현상과 대처

- "Some models also exhibit 'context anxiety,' in which they begin wrapping up work prematurely as they approach what they believe is their context limit."
- Sonnet 4.5에서는 compaction만으로 불충분하여 context reset이 필수였음.
- Opus 4.6은 이 행동을 크게 제거하여 자동 compaction으로 충분.

### Few-shot calibration

- Evaluator에 상세한 점수 분석이 포함된 few-shot 예시를 제공하여 교정.
- "This ensured the evaluator's judgment aligned with my preferences, and reduced score drift across iterations."

### Sprint contract의 역할과 V2에서의 대체

- V1에서는 각 sprint 시작 전에 Generator와 Evaluator가 **sprint contract**를 협상: "agreeing on what 'done' looked like for that chunk of work before any code was written."
- Generator가 제안하고 Evaluator가 검토하며, 합의에 도달할 때까지 반복.
- V2에서는 sprint 구조 자체가 제거되면서, Planner가 생성한 full spec이 contract의 역할을 대체.

### Evaluator의 초기 관대함 경향

- "In early runs, I watched it identify legitimate issues, then talk itself into deciding they weren't a big deal and approve the work anyway."
- "It also tended to test superficially, rather than probing edge cases, so more subtle bugs often slipped through."
- 해결: Evaluator 로그를 읽고, 판단이 개발자의 기대와 다른 지점을 찾아 프롬프트를 반복 업데이트.

### 튜닝 반복 과정

- "It took several rounds of this development loop before the evaluator was grading in a way that I found reasonable."
- 튜닝 루프: Evaluator 로그 읽기 -> 판단 불일치 지점 식별 -> QA 프롬프트 업데이트 -> 재실행

### 남은 한계

- "Even then, the harness output showed the limits of the model's QAing capabilities: small layout issues, interactions that felt unintuitive in places, and undiscovered bugs in more deeply nested features that the evaluator hadn't exercised thoroughly."
- 개선 여지는 남아 있으나, solo 대비 핵심 기능이 작동하는 수준의 lift는 명확.

---

## 프론트엔드 디자인 평가 기준

Generator와 Evaluator 모두에게 프롬프트로 제공되는 4가지 채점 기준. Design quality와 Originality에 더 높은 가중치를 부여.

| 기준 | 원문 정의 | apple-craft 적용 |
|------|----------|----------------|
| **Design Quality** | "Does the design feel like a coherent whole rather than a collection of parts? Strong work here means the colors, typography, layout, imagery, and other details combine to create a distinct mood and identity." | UI 품질 축으로 매핑 -- 색상, 타이포, 레이아웃, 이미지 등이 일관된 무드와 아이덴티티를 형성하는지 |
| **Originality** | "Is there evidence of custom decisions, or is this template layouts, library defaults, and AI-generated patterns? A human designer should recognize deliberate creative choices. Unmodified stock components -- or telltale signs of AI generation like purple gradients over white cards -- fail here." | 코드 품질의 "안티패턴이 아닌 의도적 선택" -- 기본 템플릿이나 AI slop이 아닌, 의식적인 설계 결정이 존재하는지 |
| **Craft** | "Technical execution: typography hierarchy, spacing consistency, color harmony, contrast ratios. This is a competence check rather than a creativity check. Most reasonable implementations do fine here by default; failing means broken fundamentals." | 코드 품질 축의 기술적 실행 -- 타이포 계층, 간격 일관성, 색상 조화, 대비 비율 등 기본기 |
| **Functionality** | "Usability independent of aesthetics. Can users understand what the interface does, find primary actions, and complete tasks without guessing?" | 기능 완성도 축으로 매핑 -- 미적 요소와 무관하게 사용자가 인터페이스를 이해하고 작업을 완수할 수 있는지 |

> **가중치 참고**: Claude는 Craft과 Functionality에서 기본적으로 높은 점수를 받는 반면, Design quality와 Originality에서 뻔한(bland) 출력을 내는 경향이 있다. 따라서 후자에 더 높은 가중치를 부여하여 미적 리스크 테이킹을 유도한다.

---

## 사례 연구: 비용-품질 참조점

### 레트로 게임 메이커 (RetroForge) -- V1, Opus 4.5

**프롬프트**: "Create a 2D retro game maker with features including a level editor, sprite editor, entity behaviors, and a playable test mode."

| 방식 | 시간 | 비용 | 결과 |
|------|------|------|------|
| Solo | 20분 | $9 | 핵심 기능(play mode) 동작 안 함. 레이아웃 공간 낭비, 워크플로 불명확, 엔티티가 화면에 나타나지만 입력에 반응 안 함 |
| V1 Harness | 6시간 | $200 | 16개 기능(10 sprint), AI 통합, 플레이 가능. 캔버스 풀 뷰포트, 일관된 비주얼 아이덴티티, 스프라이트 애니메이션, 사운드, AI 스프라이트 생성 등 |

#### Evaluator가 잡은 구체적 문제 예시

| Contract criterion | Evaluator finding |
|---|---|
| Rectangle fill tool allows click-drag to fill a rectangular area with selected tile | **FAIL** -- Tool only places tiles at drag start/end points instead of filling the region. `fillRectangle` function exists but isn't triggered properly on `mouseUp`. |
| User can select and delete placed entity spawn points | **FAIL** -- Delete key handler at `LevelEditor.tsx:892` requires both `selection` and `selectedEntityId` to be set, but clicking an entity only sets `selectedEntityId`. Condition should be `selection \|\| (selectedEntityId && activeLayer === 'entity')`. |
| User can reorder animation frames via API | **FAIL** -- PUT `/frames/reorder` route defined after `/{frame_id}` routes. FastAPI matches `'reorder'` as a `frame_id` integer and returns 422: "unable to parse string as an integer." |

> Sprint 3의 level editor만으로 27개의 테스트 기준이 존재했으며, Evaluator의 발견은 추가 조사 없이 바로 조치할 수 있을 만큼 구체적이었다.

### DAW (Digital Audio Workstation) -- V2, Opus 4.6

**프롬프트**: "Build a fully featured DAW in the browser using the Web Audio API."

| Agent & Phase | Duration | Cost | 비중 |
|---|---|---|---|
| Planner | 4.7분 | $0.46 | 0.4% |
| Build Round 1 | 2시간 7분 | $71.08 | 57.0% |
| QA Round 1 | 8.8분 | $3.24 | 2.6% |
| Build Round 2 | 1시간 2분 | $36.89 | 29.6% |
| QA Round 2 | 6.8분 | $3.09 | 2.5% |
| Build Round 3 | 10.9분 | $5.88 | 4.7% |
| QA Round 3 | 9.6분 | $4.06 | 3.3% |
| **Total** | **3시간 50분** | **$124.70** | **100%** |

**Key insight**: Planner가 0.4%의 비용으로 가장 높은 ROI 제공. Generator는 sprint 분해 없이 2시간 이상 일관되게 코딩.

#### QA가 잡은 문제

**Round 1**: "The main failure point is Feature Completeness -- while the app looks impressive and the AI integration works well, several core DAW features are display-only without interactive depth: clips can't be dragged/moved on the timeline, there are no instrument UI panels (synth knobs, drum pads), and no visual effect editors (EQ curves, compressor meters). These aren't edge cases -- they're the core interactions that make a DAW usable."

**Round 2**: "Audio recording is still stub-only (button toggles but no mic capture), clip resize by edge drag and clip split not implemented, effect visualizations are numeric sliders, not graphical (no EQ curve)."

### 네덜란드 미술관 사례 (창의적 도약)

프론트엔드 디자인 실험에서 Generator-Evaluator 루프의 창의적 잠재력을 보여준 사례.

- **Iteration 1~9**: 점진적(incremental) 개선. 깔끔한 다크 테마의 가상 미술관 랜딩 페이지. 시각적으로 세련되었지만 예상 범위 내.
- **Iteration 10**: 급진적(radical) 전환. 기존 접근을 완전히 폐기하고 **공간적 경험(spatial experience)**으로 재해석:
  - CSS perspective로 렌더링된 3D 방, 체커 패턴 바닥
  - 벽면에 자유 배치된 작품
  - 스크롤/클릭 대신 문(doorway) 기반 갤러리 간 내비게이션
- **의의**: "It was the kind of creative leap that I hadn't seen before from a single-pass generation." -- Evaluator의 반복적 피드백이 Generator를 안전한 선택에서 벗어나게 하여 발생한 emergent creativity.

---

## 용어집

> Source: [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (Anthropic, 2026-03-24)

### 아키텍처 / 시스템 설계

| 용어 | 설명 |
|------|------|
| **Harness** | 모델의 성능을 높이기 위해 설계된 오케스트레이션 프레임워크. 에이전트 구성, 피드백 루프, 컨텍스트 관리 등을 포함 |
| **GAN-inspired architecture** | Generative Adversarial Network에서 영감을 받은 구조. Generator와 Evaluator를 분리하여 출력 품질을 반복적으로 개선 |
| **Three-agent architecture** | Planner, Generator, Evaluator 세 에이전트로 구성된 시스템 |
| **Multi-agent system** | 각기 다른 역할의 여러 에이전트가 협력하여 작업을 수행하는 구조 |

### 에이전트 역할

| 용어 | 설명 |
|------|------|
| **Planner** | 1~4문장의 간단한 프롬프트를 전체 제품 스펙으로 확장하는 에이전트. 세부 기술 구현보다 제품 컨텍스트와 고수준 기술 설계에 집중 |
| **Generator** | 스펙에 따라 실제 코드를 구현하는 에이전트. V1에서는 sprint 단위, V2에서는 연속 빌드 |
| **Evaluator** | Playwright MCP 등을 사용해 생성된 결과물을 실제 사용자처럼 테스트하고 채점하는 에이전트. 라이브 페이지를 탐색하고 스크린샷을 찍으며 평가 |
| **Initializer agent** | 초기 하네스에서 제품 스펙을 태스크 리스트로 분해하는 에이전트 (V1 이전) |

### 컨텍스트 관리

| 용어 | 설명 |
|------|------|
| **Context degradation** | 컨텍스트 윈도우가 채워지면서 모델의 일관성이 저하되는 현상 |
| **Context anxiety** | 모델이 컨텍스트 한계에 가까워졌다고 판단해 작업을 조기에 마무리하려는 경향. Sonnet 4.5에서 심각, Opus 4.6에서 크게 완화 |
| **Context reset** | 컨텍스트 윈도우를 완전히 비우고 구조화된 핸드오프로 새 에이전트를 시작하는 방식. Clean slate 제공 |
| **Compaction** | 대화 초반부를 요약하여 동일 에이전트가 축약된 히스토리로 계속 작업하는 방식. 연속성은 유지되지만 clean slate를 제공하지 않음 |
| **Structured handoff** | 이전 에이전트의 상태와 다음 작업을 구조화된 아티팩트로 전달하는 메커니즘 |

### 평가 기준

| 용어 | 설명 |
|------|------|
| **Design quality** | 색상, 타이포, 레이아웃 등이 일관된 분위기와 아이덴티티를 형성하는지 |
| **Originality** | 템플릿 기본값이나 AI 생성 패턴이 아닌, 의도적인 창의적 선택이 있는지 |
| **Craft** | 타이포그래피 계층, 간격 일관성, 색상 조화 등 기술적 실행 수준. Competence check |
| **Functionality** | 미적 요소와 무관하게 사용자가 인터페이스를 이해하고 작업을 수행할 수 있는지 |

### 실행 패턴

| 용어 | 설명 |
|------|------|
| **Sprint contract** | Generator와 Evaluator가 구현 전에 "완료 기준"을 합의하는 계약. V2에서 제거됨 |
| **One-feature-at-a-time** | 한 번에 하나의 기능만 구현하여 스코프를 관리하는 접근법. V1 sprint 구조의 기반 |
| **File-based communication** | 에이전트 간 파일 읽기/쓰기를 통해 소통하는 방식 |
| **Few-shot calibration** | Evaluator에 점수 분석 예시를 제공하여 평가 기준을 교정하는 기법 |
| **Methodical ablation** | 하네스 구성요소를 하나씩 제거하며 영향을 측정하는 체계적 단순화 방식 |

### 문제점 / 실패 모드

| 용어 | 설명 |
|------|------|
| **Self-evaluation bias** | 에이전트가 자신이 생성한 작업을 과대평가하는 경향. Generator-Evaluator 분리로 해결 |
| **AI slop** | 보라색 그래디언트+흰색 카드 등 전형적으로 AI가 생성하는 뻔하고 개성 없는 디자인 패턴 |
| **Score drift** | 반복 실행 시 Evaluator의 채점 기준이 점진적으로 변하는 현상. Few-shot calibration으로 완화 |
| **Under-scope** | Planner 없이 Generator에게 raw prompt를 주었을 때 기능 범위가 축소되는 현상 |

### 핵심 원칙

| 용어 | 설명 |
|------|------|
| **Load-bearing component** | 하네스에서 실제로 성능에 기여하는 핵심 구성요소. 모델 개선 시 재평가 필요 |
| **Capability boundary** | 모델이 단독으로 안정적으로 처리할 수 있는 작업의 경계. 모델 개선마다 바깥으로 이동 |
| **Harness space movement** | 모델이 개선되어도 하네스 조합의 공간이 축소되지 않고 이동한다는 원칙 |
