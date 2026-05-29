# GPT-PRO Prompting Best Practices

## Context/Question Ratio Principle

An effective research prompt balances sufficient context with a clear question.

| Ratio | Situation | Description |
|------|------|------|
| Context 80% / Question 20% | Code analysis, refactoring | Provide enough code, ask concisely |
| Context 60% / Question 40% | Architecture decisions | Show the structure, but detail constraints and considerations |
| Context 40% / Question 60% | Debugging | Error + minimal reproduction code + detailed symptom description |

**Principle**: A question without context yields only generic answers; context without a question loses direction.

---

## Role-Setting Strategy

### Effective Role Examples

```
# Good example — specific expertise + perspective
"You are an iOS app architect with 10 years of experience, specializing in modularizing large-scale Swift codebases."

# Bad example — too generic
"You are a programming expert."
```

### Customizing the Role per Mode

When the user wants a specific perspective, reflect it in the role:

- **Performance perspective**: "... with particular focus on memory optimization and runtime performance"
- **Security perspective**: "... with particular focus on identifying security vulnerabilities and defensive programming"
- **Testing perspective**: "... with particular focus on test strategy design and testability"
- **Migration perspective**: "... with particular focus on incremental migration and backward compatibility"

---

## Specifying Output Format

Specify the format in the Expected Output so GPT-PRO returns a structured response.

### Effective Format Specification

```
## Expected Output

Please respond with the following structure:

1. **Summary** (within 3 lines)
2. **Detailed analysis** (markdown by section)
3. **Code examples** (before/after diff format)
4. **Recommendations** (in priority order)
```

### What to Avoid

- "Please explain in detail" → long, directionless response
- No format specified → inconsistent output
- Too many requirements → reduced depth on each item

---

## Language Consistency

### Basic Principle

| Element | Language | Example |
|------|------|------|
| Prompt description / question | Korean | "Please analyze the responsibilities of this module" |
| Code | Keep original | `func authenticate(token: String)` |
| Technical terms | Keep original | "Protocol Oriented Programming" |
| File paths | Keep original | `src/auth/AuthManager.swift` |
| Response request | Korean | "Please explain in Korean" |

### Inserting the Language Instruction

Append the following at the end of the prompt:

```
> Please write the response in Korean. Keep code, technical terms, and file paths in their original form.
```

---

## Effective Research Question Types

### Analysis Questions (What/How)

```
"Please analyze what responsibilities this module has and whether it follows the Single Responsibility Principle."
"Please explain how data flows through this architecture."
```

### Comparison Questions (Trade-off)

```
"Please compare the pros and cons of the current implementation versus an implementation using the Strategy pattern."
"Please analyze which is more suitable in this context: Protocol-based abstraction vs. generics-based abstraction."
```

### Improvement Questions (Improve)

```
"Please suggest, with concrete code, what refactoring is needed to improve the testability of this code."
"Please identify performance bottlenecks and propose optimization approaches."
```

### Debugging Questions (Fix)

```
"Please identify the root cause of this error and provide the fix as a diff."
"Please enumerate all scenarios in which this crash could occur, and propose defensive code for each."
```

### Design Questions (Design)

```
"Please propose how to add this feature while extending the existing architecture and maintaining consistency with it."
"Please propose how the interface should be designed when separating this module into a standalone package."
```

---

## Context Composition Tips

### File Order

Arrange files in the context in this order:

1. **Core target file** — the code at the center of the question
2. **Dependent interfaces** — protocols/interfaces the target implements or uses
3. **Related implementations** — code that interacts with the target
4. **Tests** — tests that show current behavior
5. **Config/environment** — build settings, environment variables, etc.

### Removing Unnecessary Information

- License headers: remove
- Long comment blocks: keep only the essentials
- Duplicate imports: keep only one
- Auto-generated code: keep only signatures
- Unrelated methods: remove methods in the class that are unrelated to the question
