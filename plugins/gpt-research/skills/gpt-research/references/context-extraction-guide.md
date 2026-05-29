# Context Extraction Strategy by Mode

## module mode

### Step 1: Collect target source files

```
Glob: {target path}/**/*.{swift,ts,tsx,js,jsx,py,go,rs,java,kt}
```

If the target is a single file, collect only that file; if a directory, collect all source files beneath it.

### Step 2: Parse imports/dependencies

Extract import statements from each source file and trace project-internal dependency files.

**Import patterns by language:**

| Language | Pattern | Example |
|------|------|------|
| Swift | `import\s+(\w+)` | `import Foundation` |
| TypeScript/JS | `import\s+.*from\s+['"](.+)['"]` | `import { foo } from './bar'` |
| | `require\(['"](.+)['"]\)` | `const x = require('./bar')` |
| Python | `from\s+(\S+)\s+import` | `from auth.manager import AuthManager` |
| | `import\s+(\S+)` | `import auth.manager` |
| Go | `"(.+)"` (inside import block) | `"github.com/user/pkg/auth"` |
| Rust | `use\s+(\S+)` | `use crate::auth::manager` |
| | `mod\s+(\w+)` | `mod auth` |
| Java/Kotlin | `import\s+(\S+)` | `import com.example.auth.AuthManager` |

**Determining project-internal dependencies:**
- Relative paths (`./`, `../`): always internal
- Package name matches the project module name: internal
- Standard library or external package: excluded

### Step 3: Find protocols/interfaces

```
Grep: protocol\s+\w+|interface\s+\w+|abstract\s+class\s+\w+|trait\s+\w+
Scope: entire project (limited to types referenced by the target file)
```

### Step 4: Match test files

```
Glob: **/*Test*.{swift,ts,js,py}
Glob: **/*Spec*.{swift,ts,js,py}
Glob: **/*_test*.{swift,ts,js,py,go}
Glob: **/test_*.py
```

Select only those whose test file name contains the target module name or file name.

### Step 5: Package declarations

Search from the project root for:

```
Glob: Package.swift | package.json | Cargo.toml | go.mod | pyproject.toml | build.gradle* | pom.xml | Podfile
```

---

## arch mode

### Step 1: Directory tree

Generate a directory tree with Bash:

```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/.build/*' -not -path '*/DerivedData/*' -not -path '*/Pods/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/.next/*' -not -path '*/dist/*' -not -path '*/.swiftpm/*' -not -path '*/Tuist/.build/*' | head -200 | sort
```

Or, if the `tree` command is available:

```bash
tree -L 3 -I 'node_modules|.git|build|.build|DerivedData|Pods|venv|__pycache__|.next|dist|.swiftpm'
```

### Step 2: Project documentation

```
Glob: CLAUDE.md | README.md | ARCHITECTURE.md | CONTRIBUTING.md | docs/architecture* | docs/README*
```

Read each document, but if an individual document exceeds 10K characters, include only the first 5K.

### Step 3: Dependency files

```
Glob: Package.swift | package.json | Podfile | Cargo.toml | go.mod | requirements.txt | pyproject.toml | build.gradle* | pom.xml | Gemfile
```

For `package.json`, extract only the `dependencies` and `devDependencies` sections.
Exclude lock files (package-lock.json, Podfile.lock, etc.).

### Step 4: Build system

```
Glob: Makefile | Tuist/** | *.xcodeproj/project.pbxproj | CMakeLists.txt | webpack.config.* | vite.config.* | tsconfig.json
```

Do not include the full pbxproj; extract only the target list and build settings:

```
Grep: /\* .* \*/ = {$ | buildSettings | PRODUCT_NAME | INFOPLIST
Scope: *.pbxproj
```

### Step 5: Core configuration files

```
Glob: .env.example | .swiftlint.yml | .eslintrc* | tsconfig.json | .prettierrc* | .editorconfig | docker-compose.yml | Dockerfile
```

Exclude `.env` (security). Include only `.env.example`.

---

## issue mode

### Step 1: Parse error information

From the error message or stack trace provided by the user:

- Extract **file path**: `/path/to/file.swift:42` pattern
- Extract **function name**: function/method name from the stack frame
- Extract **error type**: `TypeError`, `SIGSEGV`, `fatalError`, etc.

### Step 2: Find related source

Read the extracted file paths directly.
If the file does not exist, Grep with the error string:

```
Grep: {unique string from the error message}
Scope: entire project
```

### Step 3: Trace the call chain

From the function where the error occurred:

```
Grep: {function name}
Scope: entire project
```

Identify the caller and trace 1–2 levels upward.

### Step 4: Test files

Find the test files for the module/class related to the error, the same way as in module mode.

### Step 5: Git history

```bash
git log --oneline -10 -- {related file paths}
```

Since a recent change may be the cause of the error, also include the diff:

```bash
git diff HEAD~5 -- {related file paths}
```

### Step 6: Environment information

```bash
# macOS
sw_vers
# Swift
swift --version 2>/dev/null
# Node
node --version 2>/dev/null
# Python
python3 --version 2>/dev/null
# Other relevant runtimes
```

---

## custom mode

### Interactive file selection flow

1. **Scope question**: "Which files or directories should be included?"
2. **Confirm file list**: match with Glob → show the list to the user
3. **Add/remove**: "Are there any files to add or remove?"
4. **Research question**: "What question would you like to ask GPT-PRO?"
5. **Role assignment**: "Would you like to assign a specific role? (default: software development expert)"
6. **Output format**: "Is there an output format you prefer? (default: free form)"

Wait for the user's response at each step before proceeding.

---

## Common: File size handling

When an individual file is too large:

| File size | Handling |
|-----------|------|
| < 5K characters | Include in full |
| 5K–20K characters | Include in full (no warning) |
| 20K–50K characters | Include in full + record size |
| > 50K characters | Include core parts only (class/function signatures + relevant implementation) |

Always exclude generated files, bundled files, and minified files.
