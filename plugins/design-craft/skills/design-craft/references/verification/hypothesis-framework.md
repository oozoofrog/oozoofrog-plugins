# Hypothesis-Verification Framework

The hypothesis formulation and verification framework used by the verification-scientist in the design-research research team.

## Hypothesis Structure

For each design token, formulate a hypothesis in the following form:

```
H: Setting [token-name] to [value/range] produces [measurable outcome].
출처: [primary/secondary source]
검증 방법: [measurement method]
반증 조건: [reject hypothesis if this condition holds]
```

## Source Confidence Grades

| Grade | Source Type | Confidence |
|-------|-------------|------------|
| **S** | Official guidelines (HIG, Material Design, WCAG) | Highest — adopt values as-is |
| **A** | Official SDK/framework defaults (UIKit, Compose) | High — adopt as implementation defaults |
| **B** | Measured values from official platform apps | High — adopt after cross-verification |
| **C** | Academic papers (peer-reviewed) | Medium — after confirming reproducibility |
| **D** | Designer interviews/talks/books | Medium — qualitative reference |
| **F** | Blogs/community/estimates | Low — cross-verify against 2 or more sources |

## Verification Methods

### Quantitative Verification
- **Measurement comparison**: measure actual values from official apps and compare against token values
- **Guideline cross-check**: compare against explicit values in official documentation
- **SDK default check**: extract defaults from framework source/documentation

### Qualitative Verification
- **Heuristic evaluation**: evaluate against Nielsen's 10 heuristics
- **Expert review**: judge adherence to design principles
- **A/B comparison**: compare mockups with and without the token applied

## Verification Report Format

```markdown
## 토큰: {token-name}
- 가설: {H}
- 출처 등급: {S-F}
- 검증 결과: PASS / FAIL / INCONCLUSIVE
- 근거: {구체적 측정값 또는 비교 결과}
- 수정 제안: {FAIL 시 대안값}
```
