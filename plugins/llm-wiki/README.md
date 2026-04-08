# llm-wiki

프로젝트별 지식 베이스를 LLM이 점진적으로 구축·유지하는 Claude Code 플러그인.

[Andrej Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 기반.

## 핵심 아이디어

기존 RAG(매 질문마다 원본에서 검색)와 달리, LLM이 **영속적 마크다운 위키**를 점진적으로 구축합니다. 소스를 추가할 때마다 기존 위키에 통합하고, 교차참조를 갱신하며, 모순을 표시합니다.

## 아키텍처 (3-Layer)

```
{project}/.wiki/
├── schema.md       ← Layer 3: 위키 구조·규칙 정의
├── index.md        ← 마스터 인덱스 (카테고리별 페이지 목록)
├── log.md          ← 운영 로그
├── sources/        ← Layer 1: 원본 문서 (불변, LLM은 읽기만)
└── pages/          ← Layer 2: LLM이 생성·유지하는 위키 페이지
```

## 스킬

| 스킬 | 설명 |
|------|------|
| `wiki-init` | 프로젝트 위키 초기화 — `.wiki/` 스캐폴딩, 스키마 설정, 기존 문서 탐지 |
| `wiki-ingest` | 소스 수집·통합 — 파일/디렉토리/URL을 읽어 위키 페이지로 변환, 교차참조 갱신 |
| `wiki-query` | 위키 검색·답변 — 인덱스 기반 페이지 탐색, 인용 포함 답변 합성 |
| `wiki-lint` | 위키 건강 점검 — 모순, 고아 페이지, 누락 교차참조, 오래된 콘텐츠 탐지 |

## 에이전트

| 에이전트 | 설명 |
|----------|------|
| `wiki-keeper` | 자율 유지보수 — 코드/문서 변경 후 위키 정합성 검증, 업데이트 제안 |

## 사용법

```
/wiki-init                    # 현재 프로젝트에 위키 초기화
/wiki-ingest docs/            # docs/ 디렉토리 문서 일괄 수집
/wiki-ingest README.md        # 단일 파일 수집
/wiki-query "인증 흐름은?"    # 위키에서 검색·답변
/wiki-lint                    # 위키 건강 점검
/wiki-lint --fix              # 자동 수정 모드
```
