# CLAUDE.md — LLM Wiki Schema

This file is the **schema** for this LLM-maintained knowledge base. Read it before every session. Karpathy의 LLM Wiki 패턴(2026-04-04)을 기반으로 한다.

> 핵심 원칙: **사용자는 sourcing/curation/questioning을, Claude는 모든 bookkeeping을 담당한다.** 위키는 단순 RAG가 아니라 점진적으로 누적되는 영구 아티팩트(persistent compounding artifact)이다. 사용자가 새 소스를 추가할 때마다 Claude는 단순히 인덱싱만 하는 것이 아니라, 읽고 핵심을 추출하여 기존 위키와 통합한다.

---

## 1. Three-Layer Architecture (변경 금지)

```
┌─────────────────────────────────────────────────────────────┐
│  raw/        ← 원본 소스 (IMMUTABLE, 읽기만 함)              │
│  wiki/       ← LLM이 작성하고 유지하는 마크다운 (읽기/쓰기)  │
│  CLAUDE.md   ← 스키마 (사용자와 LLM이 함께 진화시킴)         │
└─────────────────────────────────────────────────────────────┘
```

### 1.1 `raw/` — 원본 소스 (UNTOUCHABLE)

- **절대 수정/삭제하지 않는다.** Claude는 `raw/`에서 **읽기만** 수행한다.
- 하위 분류:
  - `raw/articles/` — 웹 클리핑, 블로그 포스트 (Obsidian Web Clipper 등)
  - `raw/papers/` — 논문 PDF/Markdown
  - `raw/notes/` — 사용자가 직접 적은 메모, 미팅 노트
  - `raw/assets/` — 이미지, 다이어그램 (마크다운에서 참조)
- 파일명 규칙: `YYYY-MM-DD-slug.md` (예: `2026-04-04-karpathy-llm-wiki.md`)
- 가능하면 frontmatter에 `source_url`, `author`, `date`, `tags`를 기록한다.

### 1.2 `wiki/` — LLM이 소유하는 레이어

이 레이어는 Claude가 **전적으로 관리한다.** 사용자는 보기만 한다(또는 가끔 직접 편집).

| 디렉토리 | 무엇을 담는가 | 페이지 예시 |
|---|---|---|
| `wiki/entities/` | 사람, 조직, 제품, 도구, 모델 | `andrej-karpathy.md`, `claude-code.md`, `obsidian.md` |
| `wiki/concepts/` | 추상 개념, 패턴, 알고리즘 | `rag.md`, `persistent-knowledge-base.md`, `memex.md` |
| `wiki/topics/` | 큰 주제 영역 (여러 소스 종합) | `llm-knowledge-management.md`, `agentic-workflows.md` |
| `wiki/sources/` | 각 raw 소스의 1:1 요약 | `2026-04-04-karpathy-llm-wiki.md` |
| `wiki/syntheses/` | 사용자 질문에 대한 대답을 페이지로 보존한 것 | `wiki-vs-rag-comparison.md` |
| `wiki/meta/` | `index.md`, `log.md`, `glossary.md` 등 메타 페이지 | `index.md`, `log.md` |

### 1.3 위키 페이지 형식 (모든 페이지 공통)

모든 wiki 페이지는 다음 frontmatter를 가진다:

```yaml
---
title: <Page Title>
type: entity | concept | topic | source | synthesis | meta
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [<source-page-id>, ...]   # 이 페이지를 뒷받침하는 raw 소스
tags: [...]
status: stub | draft | mature       # 페이지의 성숙도
---
```

본문은 다음 구조를 권장한다:

```markdown
# <Title>

> 한 줄 요약 (TL;DR)

## Overview
…

## Key Points
…

## Related
- [[other-page]] — 왜 관련 있는지
- [[another-page]] — …

## Sources
- [[wiki/sources/2026-04-04-karpathy-llm-wiki|Karpathy LLM Wiki gist]]
```

---

## 2. Core Operations (4가지)

Claude는 항상 다음 4가지 작업 중 하나를 수행한다고 명확히 인식한다.

### 2.1 INGEST — 새 소스 통합

**Trigger:** 사용자가 `raw/`에 파일을 추가하고 "ingest <file>" 또는 `/ingest` 명령을 내리거나, "이거 정리해줘"라고 한다.

**Flow:**
1. `source-ingest` 스킬을 호출한다.
2. 소스를 읽고, 사용자와 **핵심 takeaway 3-5개를 대화로 합의한다.** (조용히 통합하지 않는다)
3. `wiki/sources/<filename>.md`에 1:1 요약 페이지를 작성한다.
4. **영향받는 페이지를 식별한다:** 새 entity? 기존 entity 업데이트? 새 concept? 기존 topic 보강?
5. 영향받는 모든 페이지를 업데이트한다 (보통 1 소스 = 5~15 페이지 변경).
6. `wiki/meta/index.md`에 새 페이지/변경된 페이지를 반영한다.
7. `wiki/meta/log.md`에 한 줄 추가: `## [YYYY-MM-DD] ingest | <Source Title>` + bullet로 영향받은 페이지 나열.
8. **모순(contradiction) 탐지:** 새 소스가 기존 페이지의 주장과 어긋나면 그냥 덮어쓰지 말고, 양쪽 주장을 모두 보존하고 `> ⚠️ Contradiction:` 노트를 단다. 사용자에게 보고한다.

### 2.2 QUERY — 위키에 질문하기

**Trigger:** 사용자가 위키에 대해 질문하거나, "X에 대해 알려줘"라고 한다.

**Flow:**
1. 먼저 `wiki/meta/index.md`를 읽어 관련 페이지를 찾는다 (RAG 임베딩 대신 인덱스 우선).
2. 관련 페이지들을 읽고 **출처를 명시(citation)하며** 답한다.
3. 답변은 형식이 다양할 수 있다: 마크다운 페이지, 비교 표, 다이어그램, 코드.
4. **답변이 충분히 가치 있다고 판단되면** (사용자가 명시적으로 요청하거나, 새로운 종합/연결을 만들었으면) 사용자에게 묻는다: "이 답변을 `wiki/syntheses/<name>.md`로 저장할까요?"
5. 저장 시 `log.md`에 `## [YYYY-MM-DD] query | <Question>`을 기록.

### 2.3 LINT — 위키 건강 검진

**Trigger:** 사용자가 `/lint`를 입력하거나 "위키 점검해줘"라고 한다.

**Flow:** `wiki-lint` 스킬을 호출하여 다음을 점검한다.
- **모순:** 같은 사실에 대해 다른 페이지가 다른 주장을 하는가?
- **오래된 주장(stale):** 새 소스가 들어왔는데 반영 안 된 페이지가 있는가? (`updated` 필드와 `log.md` 비교)
- **고아 페이지(orphan):** 어떤 페이지로부터도 링크되지 않는 페이지가 있는가?
- **누락된 개념:** 여러 페이지에서 언급되지만 자기 페이지가 없는 용어가 있는가?
- **누락된 cross-reference:** 의미적으로 관련 있어 보이는데 서로 링크 안 된 페이지가 있는가?
- **데이터 갭:** 사용자가 더 조사하면 좋을 영역은?

결과는 `wiki/meta/lint-YYYY-MM-DD.md`로 저장하고, 사용자에게 우선순위 있는 액션 목록을 제시.

### 2.4 CURATE — 위키 정리/리팩터링

**Trigger:** 사용자가 명시적으로 요청하거나 lint 결과 액션 항목을 따를 때.

이는 LLM이 자율적으로 위키를 더 좋게 만드는 작업이다. 다음을 포함:
- 너무 큰 페이지를 분할
- 너무 작은 stub 페이지들을 합치거나 삭제 제안
- 네이밍 일관성 정리
- 누락된 cross-reference 추가

**중요:** 큰 변경(파일 이동/삭제, 5+ 페이지 동시 수정)은 항상 **사용자 승인**을 받는다.

---

## 3. Naming & Linking 규칙

### 3.1 파일명
- **소문자, kebab-case** (`andrej-karpathy.md`, NOT `Andrej_Karpathy.md`)
- **공백/한글 사용 가능** 단, ASCII slug 우선. 한글이 자연스러운 경우(한국어 위키)는 한글 사용 허용 (예: `mlir-dialect.md` 보다 `mlir-방언.md`가 자연스러우면 후자도 OK). 단, **한 위키 내 일관성**이 우선.
- 소스 페이지: 원본 raw 파일명과 동일하게 (`raw/articles/2026-04-04-foo.md` → `wiki/sources/2026-04-04-foo.md`)

### 3.2 링크
- **모든 위키 내부 링크는 Obsidian wikilink 형식 사용:** `[[page-name]]` 또는 `[[page-name|표시 텍스트]]`
- raw 소스를 직접 링크할 때는 상대 경로 사용: `[Karpathy gist](../raw/articles/2026-04-04-karpathy-llm-wiki.md)`
- **링크는 깨지면 안 된다.** 페이지 이름 변경 시 모든 백링크를 업데이트해야 한다 (`wiki-link` 스킬 사용).

### 3.3 한 페이지의 적정 크기
- **너무 작으면** (50줄 이하) stub. 다른 페이지로 합치거나 보강할 후보.
- **적정** 100~400줄.
- **너무 크면** (600줄 이상) 분할 후보. 하위 주제로 쪼개고 원본은 hub 페이지로.

---

## 4. `index.md`와 `log.md`

### 4.1 `wiki/meta/index.md` — 콘텐츠 카탈로그
- 모든 페이지를 카테고리별로 나열.
- 각 항목: `[[페이지명]] — 한 줄 요약 (소스 N개, 마지막 업데이트 YYYY-MM-DD)`
- **모든 ingest/curate 작업 후 반드시 갱신.**
- 이 파일은 사용자와 LLM이 위키를 navigate하는 1차 진입점.

### 4.2 `wiki/meta/log.md` — 시간순 로그
- **append-only.** 절대 과거 항목을 수정하지 않는다.
- 각 항목 형식 (grep 가능):
  ```
  ## [YYYY-MM-DD HH:MM] <op> | <title>
  - touched: [[page1]], [[page2]], ...
  - notes: …
  ```
- `op` ∈ {`ingest`, `query`, `lint`, `curate`, `manual`}
- `manual`은 사용자가 직접 편집한 경우.

---

## 5. Output Format Preferences

사용자는 한국어로 소통한다. 위키 페이지는 다음 원칙을 따른다:

- **본문 언어:** 한국어 우선. 단, 기술 용어/고유명사는 원어 보존 (예: "context window", "cross-reference", "Obsidian"). 무리한 번역(예: "맥락 창")은 피한다.
- **frontmatter:** 영어 키 (`title`, `tags` 등).
- **헤더:** 한국어 또는 영어 자연스러운 쪽.
- **TL;DR**은 모든 페이지 첫 줄 (`> ` blockquote).
- 짧고 단단한 문장 선호. 불필요한 hedge는 제거.

---

## 6. 절대 하지 말 것 (Anti-patterns)

- ❌ **`raw/` 수정** — 원본은 신성불가침.
- ❌ **무단 자동 통합** — ingest 시 takeaway 합의 없이 위키를 바꾸면 안 된다.
- ❌ **모순을 조용히 덮어쓰기** — 새 소스가 기존과 다르면 양쪽을 다 보존하고 사용자에게 알린다.
- ❌ **검증 안 된 사실 추가** — 항상 `sources:` 필드에 출처를 명시한다. 출처 없는 주장은 위키에 들어가면 안 된다.
- ❌ **고아 페이지 양산** — 새 페이지를 만들 때는 항상 어디에서 들어오는 링크가 있을지 먼저 정한다.
- ❌ **링크 깨뜨리기** — 페이지 이름 바꿀 때 백링크 갱신 필수.
- ❌ **거대한 한 번의 변경** — 너무 많은 파일을 한 번에 바꾸려 하면 사용자에게 plan을 먼저 제시한다.

---

## 7. Workflow: 첫 세션의 표준 절차

새 세션을 시작할 때 Claude는 다음을 수행한다:

1. `CLAUDE.md` 읽기 (이 파일).
2. `wiki/meta/index.md` 빠르게 훑기 (위키의 현재 상태 파악).
3. `wiki/meta/log.md`의 최근 5개 항목 확인 (`tail`):
   ```bash
   grep "^## \[" wiki/meta/log.md | tail -5
   ```
4. 사용자의 요청을 INGEST/QUERY/LINT/CURATE 중 어느 작업인지 분류.
5. 해당 작업의 적절한 스킬/에이전트를 호출.

---

## 8. 스킬과 에이전트 (자세한 사용법은 각 SKILL.md 참조)

| 이름 | 종류 | 언제 자동 호출되는가 |
|---|---|---|
| `source-ingest` | skill | raw/에 새 파일이 있고 사용자가 ingest 의도를 표현했을 때 |
| `wiki-page` | skill | 새 위키 페이지 생성 또는 기존 페이지 대대적 개편 |
| `wiki-link` | skill | 페이지 이름 변경, 링크 무결성 검사, cross-reference 추가 |
| `wiki-lint` | skill | `/lint` 명령 또는 위키 건강 검진 요청 |
| `librarian` | agent | 큰 ingest 작업(여러 소스 동시), 멀티 페이지 리팩터링 |
| `editor` | agent | 페이지 작성/리라이트 전담 |
| `linker` | agent | 그래프 구조 분석, cross-reference 추천 |

스킬은 자동 호출, 에이전트는 명시적으로 호출되거나 큰 작업에서 librarian이 위임.

---

## 9. 이 스키마는 살아있는 문서다

이 `CLAUDE.md` 자체도 시간이 지나면서 진화한다. 사용자가 새 패턴을 발견하면 함께 수정한다. **단, 변경 시 `wiki/meta/log.md`에 `manual` 항목으로 기록한다.**
