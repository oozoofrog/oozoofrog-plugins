---
name: yoda
description: "학습과학 기반 코드 리뷰 및 교육 콘텐츠 생성. /yoda review로 Before/After/Why 기반 리뷰, /yoda share로 4개 포맷(md/web/wiki/slides) 팀 전파. 코드 리뷰, 코드 분석, 코드 설명, 팀 공유, 온보딩, 기술 세미나, 지식 전파 요청 시 활성화"
argument-hint: "[review <대상> | share <입력> --format md|web|wiki|slides --audience junior|mid|senior]"
model: opus
---

<example>
user: "이 ViewModel 리뷰해줘"
assistant: "/yoda review 모드로 6단계 파이프라인을 실행하여 Before/After/Why 기반 3계층 리뷰를 수행하겠습니다."
</example>

<example>
user: "이 코드를 팀에 공유할 마크다운 문서로 만들어줘"
assistant: "/yoda share --format md 모드로 Worked Examples와 이중 코딩 원칙을 적용한 교육 마크다운 문서를 생성하겠습니다."
</example>

<example>
user: "방금 리뷰한 내용으로 세미나 슬라이드 만들어줘"
assistant: "/yoda share --from-review --format slides 모드로 인지적 도제 모델링을 적용한 15장 Marp 프레젠테이션을 생성하겠습니다."
</example>

<example>
user: "Swift Concurrency 패턴을 주니어한테 설명하는 위키 글 써줘"
assistant: "/yoda share --format wiki --audience junior 모드로 4막 내러티브 구조와 높은 비계 수준의 위키 페이지를 생성하겠습니다."
</example>

# Yoda

학습과학 기반 코드 리뷰 및 교육 콘텐츠 생성 통합 스킬.

기존 코드 리뷰가 **"What"**(무엇이 문제인가)에 집중한다면, yoda는 **"Why"**(왜 문제인가, 왜 이렇게 고쳐야 하는가)까지 다룬다. Before/After/Why 트리플, 3계층 점진적 공개, 호기심 트리거, ZPD 보정, 포맷별 학습과학 원칙 자동 적용으로 코드 리뷰를 **학습 경험**으로 전환한다.

**모든 응답은 한글로 작성한다.**

---

## 참조 문서

실행 전 반드시 아래 레퍼런스를 읽고 해당 규칙을 준수한다.

- `review-reference.md` — Review 모드 6단계 파이프라인, 3계층 출력 구조, 심각도 분류 상세
- `share-reference.md` — Share 모드 포맷별 생성 전략, --from-review 파이프라인, ZPD 보정 상세
- `learning-science.md` — 4대 필수 원칙, 포맷별 추가 원칙, 호기심 트리거 규칙, ZPD 보정 매트릭스

---

## 모드 선택

사용자 입력의 키워드를 분석하여 모드를 자동 선택한다.

| 모드 | 키워드 | 설명 |
|------|--------|------|
| **review** | 리뷰, 분석, 검토, 코드 봐줘, 코드 확인, 점검 | 코드 분석 + 3계층 학습과학 기반 리포트 생성 |
| **share** | 공유, 전파, 세미나, 슬라이드, 위키, 문서, 온보딩, 마크다운 | 교육 콘텐츠 생성 (4개 포맷 지원) |

---

## 4대 필수 원칙

모든 출력에 항상 적용한다. 상세 규칙은 `learning-science.md` 참조.

| # | 원칙 | 적용 |
|---|------|------|
| 1 | **Before/After/Why 트리플** | 모든 발견 사항에 문제 코드(Before) + 수정 코드(After) + 이유(Why)를 인접 배치. Why는 호기심 트리거로 시작 |
| 2 | **신호/라벨링** | 모든 발견 사항에 심각도 라벨(🔴🟡🔵🟢💡) + 인지 오류 유형([Slip]/[Rule]/[Knowledge]/[Lapse]) 부착 |
| 3 | **일관성 -- 불필요 제거** | 독자가 이미 아는 것, 발견과 관련 없는 정보, 장식적 문구, 면책 조항 제거 |
| 4 | **청킹** | 한 섹션/슬라이드/카드 = 한 개념. 전체 발견 사항 7개 이하 유지 |
| 5 | **사양 근거** | 발견 사항을 구체적 테스트/계약/사양에 근거. 추측 기반 발견은 "확인 필요" 라벨 부착 |
| 6 | **성장 프레이밍** | 결함이 아닌 학습 기회로 프레이밍. 정상화 문구 + 성장 언어 사용 |

---

## Review 모드

### 진입점

```
/yoda review <파일|디렉토리>
```

- 단일 소스 파일 또는 디렉토리 경로를 대상으로 한다.
- 디렉토리인 경우 하위 소스 파일을 재귀 탐색하여 전체 리뷰한다.

### 내부 파이프라인 (6단계)

| Phase | 이름 | 요약 |
|-------|------|------|
| 1 | 컨텍스트 수집 | 대상 코드 읽기 + git log/blame + 테스트/의존성 탐색 + 저자 의도 추론 (묵시적 실행) |
| 2 | 다관점 분석 | 구조/명료성/안전성/성능/테스트 5개 렌즈로 독립 분석, 렌즈당 최대 3개, 전체 7개 이하 |
| 3 | 발견 사항 구조화 | 각 발견을 Before/After/Why 트리플로 구조화 (호기심 트리거 → 원칙 연결 → 실제 영향) |
| 4 | 심각도 + 오류 유형 분류 | 🔴🟡🔵🟢💡 심각도 + [Slip]/[Rule]/[Knowledge]/[Lapse] 인지 오류 유형 태그 |
| 5 | 멘탈 모델 시각화 | 아키텍처 변경 필요 시에만 Mermaid 다이어그램 1개 생성 (조건부) |
| 6 | 메타인지 프롬프트 | 확장성/변경 대응 + 전이/적용 2개 질문으로 사고 자극 |

### 출력: 3계층 점진적 공개

| Layer | 대상 독자 | 소요 시간 |
|-------|----------|----------|
| **Layer 1: 핵심 요약** | 바쁜 리더, 빠른 확인 | 30초 |
| **Layer 2: 상세 분석** | 코드 작성자, 리뷰어 | 5-10분 |
| **Layer 3: 깊은 통찰** | 학습 의지가 있는 개발자 | +5분 |

상세 파이프라인 규칙 및 출력 예시는 `review-reference.md`와 `templates/md-template.md` 참조.

---

## Share 모드

### 진입점

```
/yoda share <입력> [--format md|web|wiki|slides] [--audience junior|mid|senior]
```

### 입력 유형

| 입력 | 감지 방법 | 처리 |
|------|----------|------|
| `--from-review` | 플래그 존재 확인 | 직전 review 결과를 대화에서 추출하여 변환 |
| 파일/디렉토리 | `Glob`으로 경로 존재 확인 | 독립 분석 수행 후 콘텐츠 생성 |
| 자유 텍스트 | 위 두 가지에 해당하지 않음 | `Grep`으로 코드베이스 탐색 후 실제 예시 기반 생성 |

### 포맷별 생성 & 위임

`--format` 미지정 시 사용자에게 포맷 선택지를 제시하고 물어본다.

| 포맷 | 생성 방식 | 강화 원칙 |
|------|----------|----------|
| **md** | `Write` 도구로 `docs/yoda/YYYY-MM-DD-[slug].md`에 직접 생성 | Worked Examples (Sweller) + 이중 코딩 (Mayer) + 정교화 질문 (Dunlosky) |
| **web** | 인터랙티브 HTML 직접 생성 또는 `frontend-design` 스킬 위임 | 점진적 공개 (Nielsen) + 인출 연습 (Roediger & Karpicke) + 개인화 (Mayer) |
| **wiki** | `Write` 도구로 위키 마크다운 생성. Confluence MCP 연결 시 직접 게시 | 스토리텔링 (4막 내러티브) + 사회적 구성주의 (Vygotsky) + 정교화 질문 |
| **slides** | `Write` 도구로 Marp 마크다운 15장 슬라이드 직접 생성 | 신호 강화 + 일관성 극대화 + 인지적 도제 모델링 (Collins et al.) |

> **확장**: `pptx` 스킬이 설치되어 있으면 `--format pptx`로 발표자 노트 포함 PowerPoint를 생성할 수 있다. 미설치 시 이 옵션은 표시하지 않는다.

### ZPD 보정 (`--audience`)

Vygotsky의 근접 발달 영역(ZPD) 이론에 따라 청중 수준별로 콘텐츠를 보정한다. 미지정 시 `mid` 기본값.

| audience | Before/After/Why 조정 | 용어 처리 |
|----------|----------------------|----------|
| **junior** | Why를 상세히 설명. After 코드에 주석 풍부하게 배치 | 용어 풀이 포함. 약어 시 풀네임 병기 |
| **mid** | 표준 Before/After/Why 트리플. 원칙 명명 + 핵심 영향 설명 | 팀 공용 어휘 사용 |
| **senior** | Why를 질문으로 전환 (답을 주지 않고 사고 유도) | 축약/전문 용어 자유 사용 |

상세 포맷별 생성 전략, --from-review 파이프라인은 `share-reference.md`와 `templates/` 참조.

---

## 사용법

```bash
# Review 모드
/yoda review ChatRoomViewModel.swift          # 단일 파일 리뷰
/yoda review Sources/Feature/Chat/             # 디렉토리 리뷰

# Share 모드 — review 결과 기반
/yoda share --from-review --format md           # 마크다운 문서로 변환
/yoda share --from-review --format slides       # Marp 세미나 슬라이드로 변환
/yoda share --from-review --format slides       # Marp 슬라이드로 변환

# Share 모드 — 독립 콘텐츠 생성
/yoda share Sources/Feature/Chat/ --format wiki --audience junior   # 주니어 대상 위키
/yoda share "Swift Concurrency 에러 처리" --format web              # 인터랙티브 HTML

# Review → Share 파이프라인
/yoda review UserProfileViewModel.swift         # 1단계: 리뷰
/yoda share --from-review --format slides       # 2단계: 리뷰 결과를 슬라이드로
```

---

## 한계

- 정적 분석 기반이며 코드를 실행하지 않는다.
- 심각도 분류에는 정성적 판단이 포함된다.
- git 이력이 없는 새 파일은 컨텍스트 수집(Phase 1)의 일부 단계를 건너뛴다.
- `--format pptx`는 `pptx` 스킬이 설치된 환경에서만 사용 가능하다.
