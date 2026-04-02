# yoda

학습과학 기반 코드 리뷰 및 교육 콘텐츠 생성 통합 스킬 (Before/After/Why 트리플 + 4개 포맷 팀 전파)

## 설치

```bash
claude plugin add ./plugins/yoda
```

## 스킬

| 명령어 | 설명 |
|--------|------|
| `/yoda review <대상>` | 6단계 파이프라인으로 코드 분석 후 3계층 학습과학 기반 리포트 생성 |
| `/yoda share <입력> --format --audience` | 리뷰 결과 또는 독립 분석을 4개 포맷(md/web/wiki/slides)으로 교육 콘텐츠 생성 |

## 사용 예시

### Review 모드

```bash
/yoda review ChatRoomViewModel.swift           # 단일 파일 리뷰
/yoda review Sources/Feature/Chat/              # 디렉토리 리뷰
```

### Share 모드

```bash
/yoda share --from-review --format md           # 리뷰 결과를 마크다운 문서로
/yoda share --from-review --format slides       # 리뷰 결과를 Marp 슬라이드로
/yoda share "Swift Concurrency 패턴" --format web   # 인터랙티브 HTML
```

## 학습과학 기반

- **Before/After/Why 트리플**: Sweller CLT + Mayer 인접 원칙 + Dunlosky 정교화 질문
- **3계층 점진적 공개**: Layer 1(30초) → Layer 2(5-10분) → Layer 3(+5분)
- **호기심 트리거**: Loewenstein(1994) 정보 격차 이론
- **ZPD 보정**: Vygotsky 근접 발달 영역 이론으로 junior/mid/senior 수준별 비계 자동 조절
- **포맷별 원칙 자동 적용**: md(Worked Examples), web(인출 연습), wiki(스토리텔링), slides(인지적 도제)

## 플러그인 구조

```
yoda/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── yoda/
│       ├── SKILL.md
│       ├── review-reference.md
│       ├── share-reference.md
│       ├── learning-science.md
│       └── templates/
│           ├── md-template.md
│           ├── web-template.md
│           ├── wiki-template.md
│           ├── slides-template.md
│           └── pptx-template.md
└── README.md
```
