---
name: wiki-page
description: Use this skill whenever a wiki page needs to be created from scratch or substantially rewritten. Covers entity pages (people, organizations, products, tools), concept pages (abstract ideas, patterns, algorithms), topic pages (broader subject areas synthesizing multiple sources), and synthesis pages (preserved Q&A or comparisons). Triggers when an ingest operation determined a new page is needed, when the user explicitly asks to create a page, or when a stub page is being matured. The deliverable is always a single well-formed markdown file under the appropriate wiki/ subdirectory with valid frontmatter, proper internal linking, and citations to source pages.
---

# wiki-page skill

위키 페이지 한 장을 잘 쓰는 방법. 이 위키에서 페이지는 단순한 메모가 아니라 **참조 가능한 지식 단위**다.

## 1. 페이지 종류 결정

위키 페이지는 5가지 중 하나에 속한다 (`type:` frontmatter):

| type | 어디에 두는가 | 무엇을 담는가 | 예시 |
|---|---|---|---|
| `entity` | `wiki/entities/` | 고유 개체: 사람, 조직, 제품, 도구, 모델 | `andrej-karpathy.md`, `claude-code.md` |
| `concept` | `wiki/concepts/` | 일반 개념, 패턴, 알고리즘 | `rag.md`, `wiki-pattern.md` |
| `topic` | `wiki/topics/` | 큰 주제 영역 (여러 entity/concept를 묶음) | `llm-knowledge-management.md` |
| `source` | `wiki/sources/` | 원본 소스의 1:1 요약 (source-ingest가 생성) | `2026-04-04-karpathy-llm-wiki.md` |
| `synthesis` | `wiki/syntheses/` | 사용자 질문에서 나온 의미 있는 답변을 보존 | `wiki-vs-rag-comparison.md` |

**판단이 애매하면**: 일단 `concept`로 시작하고, 시간이 지나며 `topic`으로 승격되거나 `entity`로 분리될 수 있다.

## 2. 파일명

- 소문자, kebab-case (`andrej-karpathy.md`)
- 일관성이 가장 중요. 한 위키 안에서 영어/한글 혼용은 OK이지만 한 카테고리 안에서는 통일.
- entity는 보통 영어 (인명/제품명), concept/topic은 한글이 자연스러우면 한글.

## 3. 표준 페이지 구조

### 3.1 Entity 페이지

```markdown
---
title: Andrej Karpathy
type: entity
subtype: person   # person | organization | product | tool | model | venue
created: 2026-04-04
updated: 2026-04-04
sources: [2026-04-04-karpathy-llm-wiki]
tags: [llm, ai-research, openai, tesla]
aliases: [karpathy]
status: draft
---

# Andrej Karpathy

> AI 연구자. 전 OpenAI/Tesla. nanoGPT, LLM101n 저자.

## Background
…

## Key Contributions
- nanoGPT
- nanochat
- LLM101n
- LLM Wiki 패턴 ([[wiki-pattern]])

## Related
- [[openai]] — 전 직장
- [[tesla]] — 전 Director of AI
- [[wiki-pattern]] — 이 위키가 따르는 패턴의 출처
- [[llm101n]] — 그가 만든 강의 시리즈

## Sources
- [[wiki/sources/2026-04-04-karpathy-llm-wiki|LLM Wiki gist (2026)]]
```

### 3.2 Concept 페이지

```markdown
---
title: LLM Wiki Pattern
type: concept
created: 2026-04-04
updated: 2026-04-04
sources: [2026-04-04-karpathy-llm-wiki]
tags: [knowledge-management, llm, pkm]
status: mature
---

# LLM Wiki Pattern

> RAG와 달리 매 쿼리마다 다시 추론하지 않고, LLM이 점진적으로 누적되는 markdown 위키를 유지하는 패턴.

## Definition
…

## Why It Works
- 사람은 bookkeeping을 하기 싫어한다 → 위키가 죽는다.
- LLM은 bookkeeping을 지치지 않고 한다 → 위키가 산다.
- ([[wiki-pattern#why-this-works]] 참조)

## Architecture
세 레이어:
1. **Raw sources** — immutable
2. **Wiki** — LLM이 작성/유지
3. **Schema** — 사용자와 LLM이 공동 진화 (보통 `CLAUDE.md`)

## Comparison with RAG
[[rag]]는 매 쿼리마다 raw chunk를 재검색해서 답한다. LLM Wiki는…

## See Also
- [[memex]] — Vannevar Bush의 1945년 비전과 깊이 관련됨
- [[obsidian]] — 이 패턴을 시각화하기 좋은 도구
- [[rag]]

## Sources
- [[wiki/sources/2026-04-04-karpathy-llm-wiki]]
```

### 3.3 Topic 페이지

토픽은 여러 entity와 concept를 묶는 hub 페이지다. 짧은 anchor + 많은 링크.

```markdown
---
title: LLM 기반 개인 지식 관리
type: topic
created: 2026-04-04
updated: 2026-04-04
sources: [2026-04-04-karpathy-llm-wiki, ...]
tags: [pkm, llm]
status: draft
---

# LLM 기반 개인 지식 관리

> LLM을 활용해 개인 지식베이스를 자동으로 유지보수하는 영역.

## 핵심 패턴
- [[wiki-pattern]] — Karpathy의 LLM Wiki
- [[memex]] — Bush의 원형
- [[zettelkasten]]

## 관련 도구
- [[obsidian]]
- [[claude-code]]
- [[notebooklm]]

## 핵심 인물
- [[andrej-karpathy]]
- [[ward-cunningham]]
- …

## 미해결 질문
- 어떻게 hallucination을 통제할 것인가?
- 어떻게 audit trail을 보장할 것인가? ([[provenance]])
- ...

## Sources
- [[wiki/sources/2026-04-04-karpathy-llm-wiki]]
- [[wiki/sources/...]]
```

### 3.4 Synthesis 페이지

사용자가 질문해서 답을 받았는데, 그 답이 충분히 가치 있어서 보존하기로 한 페이지.

```markdown
---
title: Wiki vs RAG 비교
type: synthesis
created: 2026-04-04
updated: 2026-04-04
sources: [2026-04-04-karpathy-llm-wiki]
question: "RAG와 LLM Wiki는 뭐가 다른가?"
tags: [comparison, rag, wiki-pattern]
status: mature
---

# Wiki vs RAG 비교

> 같은 문제(LLM을 통한 지식 활용)에 대한 두 가지 접근. RAG는 stateless, Wiki는 stateful.

## 한 줄 차이
- **RAG:** 매 쿼리마다 raw chunk를 retrieve해서 답함.
- **Wiki:** raw → 위키로 한 번 컴파일해두고, 위키를 유지보수.

## 표

| | RAG | LLM Wiki |
|---|---|---|
| 스토리지 | 임베딩 + raw | markdown 파일 |
| 매 쿼리 비용 | retrieval + 합성 | 위키 read + 합성 |
| 누적 효과 | 없음 (매번 다시) | 있음 |
| 모순 처리 | 없음 | 명시적 flag |
| 인간 가독성 | 낮음 (chunk) | 높음 (페이지) |

## 언제 어느 쪽?
- 자주 바뀌는 거대 코퍼스 → RAG
- 천천히 누적되는 개인/팀 지식 → Wiki

## See Also
- [[wiki-pattern]]
- [[rag]]

## Sources
- [[wiki/sources/2026-04-04-karpathy-llm-wiki]]
```

## 4. 작성 원칙

- **TL;DR 먼저:** 모든 페이지는 frontmatter 다음에 `> ` blockquote로 한 줄 요약.
- **링크 우선:** 다른 위키 페이지에서 다룰 만한 단어는 무조건 `[[...]]`로 링크. 링크 대상이 없으면 stub 페이지를 만들거나, "TODO: 페이지 만들기" 메모.
- **출처 명시:** 사실 주장에는 `[[wiki/sources/<source>]]` 또는 footnote `[^1]`. 출처 없는 사실 주장은 위키에 들어가면 안 된다.
- **헤더 구조:** H1은 페이지 제목 한 번만. 본문은 H2/H3.
- **간결:** 위키는 시처럼 압축적이어야 한다. 산문은 raw에 두고, 위키는 골격.

## 5. Cross-reference 추가

새 페이지를 만들 때, **반드시** 다음을 한다:
1. 이 페이지를 어디서 링크할지 정한다 (최소 1개 inbound link).
2. 그 inbound link 페이지를 실제로 수정한다.
3. 이 페이지의 `## Related` 섹션에 outbound link를 최소 2개 둔다.

이 단계를 빼면 **고아 페이지**가 양산된다 (lint에서 잡힌다).

## 6. 페이지 status

- `stub` — 1~2 문장. 다른 페이지에서 링크되지만 아직 본문 없음.
- `draft` — 본문 있지만 출처가 1개거나 작성이 미완.
- `mature` — 다수 출처로 검증됨, 다른 페이지가 안정적으로 의존 가능.

stub 페이지는 가능한 한 빨리 채우거나, 다른 페이지로 흡수.

## 7. 안티패턴

- ❌ 위키 페이지에 raw 소스의 긴 문단을 그대로 복사 — 위키는 산문이 아니라 골격.
- ❌ 모든 줄을 hedge ("~일 수도 있다", "~인 것 같다") — 출처가 그렇게 말한다면 그렇게 단정. 의심되면 출처를 안 쓴다.
- ❌ frontmatter 누락 — 자동화/lint가 깨진다.
- ❌ inbound link 없는 새 페이지 — 그래프에서 떠다니는 섬.
