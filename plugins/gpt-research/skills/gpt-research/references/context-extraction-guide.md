# 모드별 컨텍스트 추출 전략

## module 모드

### 1단계: 대상 소스 파일 수집

```
Glob: {대상 경로}/**/*.{swift,ts,tsx,js,jsx,py,go,rs,java,kt}
```

대상이 단일 파일이면 해당 파일만, 디렉토리면 하위 모든 소스 파일을 수집합니다.

### 2단계: 임포트/의존성 파싱

각 소스 파일에서 임포트 문을 추출하고, 프로젝트 내부 의존 파일을 탐색합니다.

**언어별 임포트 패턴:**

| 언어 | 패턴 | 예시 |
|------|------|------|
| Swift | `import\s+(\w+)` | `import Foundation` |
| TypeScript/JS | `import\s+.*from\s+['"](.+)['"]` | `import { foo } from './bar'` |
| | `require\(['"](.+)['"]\)` | `const x = require('./bar')` |
| Python | `from\s+(\S+)\s+import` | `from auth.manager import AuthManager` |
| | `import\s+(\S+)` | `import auth.manager` |
| Go | `"(.+)"` (import 블록 내) | `"github.com/user/pkg/auth"` |
| Rust | `use\s+(\S+)` | `use crate::auth::manager` |
| | `mod\s+(\w+)` | `mod auth` |
| Java/Kotlin | `import\s+(\S+)` | `import com.example.auth.AuthManager` |

**프로젝트 내부 의존 판별:**
- 상대 경로 (`./`, `../`): 항상 내부
- 패키지명이 프로젝트 모듈명과 일치: 내부
- 표준 라이브러리 또는 외부 패키지: 제외

### 3단계: 프로토콜/인터페이스 탐색

```
Grep: protocol\s+\w+|interface\s+\w+|abstract\s+class\s+\w+|trait\s+\w+
범위: 프로젝트 전체 (대상 파일이 참조하는 타입에 한정)
```

### 4단계: 테스트 파일 매칭

```
Glob: **/*Test*.{swift,ts,js,py}
Glob: **/*Spec*.{swift,ts,js,py}
Glob: **/*_test*.{swift,ts,js,py,go}
Glob: **/test_*.py
```

대상 모듈명 또는 파일명이 테스트 파일명에 포함된 것만 선택합니다.

### 5단계: 패키지 선언

프로젝트 루트에서 다음을 탐색:

```
Glob: Package.swift | package.json | Cargo.toml | go.mod | pyproject.toml | build.gradle* | pom.xml | Podfile
```

---

## arch 모드

### 1단계: 디렉토리 트리

Bash로 디렉토리 트리를 생성합니다:

```bash
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/.build/*' -not -path '*/DerivedData/*' -not -path '*/Pods/*' -not -path '*/venv/*' -not -path '*/__pycache__/*' -not -path '*/.next/*' -not -path '*/dist/*' -not -path '*/.swiftpm/*' -not -path '*/Tuist/.build/*' | head -200 | sort
```

또는 `tree` 명령어가 있으면:

```bash
tree -L 3 -I 'node_modules|.git|build|.build|DerivedData|Pods|venv|__pycache__|.next|dist|.swiftpm'
```

### 2단계: 프로젝트 문서

```
Glob: CLAUDE.md | README.md | ARCHITECTURE.md | CONTRIBUTING.md | docs/architecture* | docs/README*
```

각 문서를 읽되, 개별 문서가 10K 문자를 초과하면 처음 5K만 포함합니다.

### 3단계: 의존성 파일

```
Glob: Package.swift | package.json | Podfile | Cargo.toml | go.mod | requirements.txt | pyproject.toml | build.gradle* | pom.xml | Gemfile
```

`package.json`은 `dependencies`와 `devDependencies` 섹션만 추출합니다.
lock 파일(package-lock.json, Podfile.lock 등)은 제외합니다.

### 4단계: 빌드 시스템

```
Glob: Makefile | Tuist/** | *.xcodeproj/project.pbxproj | CMakeLists.txt | webpack.config.* | vite.config.* | tsconfig.json
```

pbxproj는 전체를 포함하지 않고, 타겟 목록과 빌드 설정만 추출합니다:

```
Grep: /\* .* \*/ = {$ | buildSettings | PRODUCT_NAME | INFOPLIST
범위: *.pbxproj
```

### 5단계: 핵심 설정 파일

```
Glob: .env.example | .swiftlint.yml | .eslintrc* | tsconfig.json | .prettierrc* | .editorconfig | docker-compose.yml | Dockerfile
```

`.env`는 제외 (보안). `.env.example`만 포함합니다.

---

## issue 모드

### 1단계: 에러 정보 파싱

사용자가 제공한 에러 메시지 또는 스택 트레이스에서:

- **파일 경로** 추출: `/path/to/file.swift:42` 패턴
- **함수명** 추출: 스택 프레임에서 함수/메서드명
- **에러 타입** 추출: `TypeError`, `SIGSEGV`, `fatalError` 등

### 2단계: 관련 소스 탐색

추출된 파일 경로를 직접 읽습니다.
파일이 없으면 에러 문자열로 Grep:

```
Grep: {에러 메시지의 고유한 문자열}
범위: 프로젝트 전체
```

### 3단계: 콜체인 추적

에러 발생 함수에서:

```
Grep: {함수명}
범위: 프로젝트 전체
```

호출자(caller)를 식별하고, 1~2단계 상위까지 추적합니다.

### 4단계: 테스트 파일

에러 관련 모듈/클래스의 테스트 파일을 module 모드와 동일하게 탐색합니다.

### 5단계: Git 히스토리

```bash
git log --oneline -10 -- {관련 파일 경로들}
```

최근 변경이 에러 원인일 수 있으므로, diff도 포함:

```bash
git diff HEAD~5 -- {관련 파일 경로들}
```

### 6단계: 환경 정보

```bash
# macOS
sw_vers
# Swift
swift --version 2>/dev/null
# Node
node --version 2>/dev/null
# Python
python3 --version 2>/dev/null
# 기타 관련 런타임
```

---

## custom 모드

### 대화형 파일 선택 흐름

1. **범위 질문**: "어떤 파일이나 디렉토리를 포함할까요?"
2. **파일 목록 확인**: Glob으로 매칭 → 사용자에게 목록 보여주기
3. **추가/제거**: "더 추가하거나 제거할 파일이 있나요?"
4. **리서치 질문**: "GPT-PRO에게 어떤 질문을 하고 싶으신가요?"
5. **역할 지정**: "특정 역할을 지정하시겠어요? (기본: 소프트웨어 개발 전문가)"
6. **출력 형식**: "원하는 출력 형식이 있나요? (기본: 자유 형식)"

각 단계에서 사용자 응답을 기다린 후 진행합니다.

---

## 공통: 파일 크기 처리

개별 파일이 너무 클 때:

| 파일 크기 | 처리 |
|-----------|------|
| < 5K 문자 | 전체 포함 |
| 5K~20K 문자 | 전체 포함 (경고 없음) |
| 20K~50K 문자 | 전체 포함 + 크기 기록 |
| > 50K 문자 | 핵심 부분만 포함 (클래스/함수 시그니처 + 관련 구현) |

생성 파일(generated), 번들 파일(bundled), 미니파이된 파일은 항상 제외합니다.
