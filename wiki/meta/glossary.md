---
title: Glossary
type: meta
created: 2026-04-28
updated: 2026-04-28
status: draft
---

# 📖 Glossary

> 이 위키 안에서 일관되게 쓰는 용어 정의. 너무 짧아서 자기 페이지를 가질 정도는 아닌 용어들의 모음. 어떤 용어가 자주 인용되기 시작하면 자기 페이지로 승격(`wiki/concepts/`).

## 위키 내부 용어

- **raw source** — `raw/` 아래의 원본 파일. 절대 수정 금지.
- **wiki page** — `wiki/` 아래의 LLM이 작성/유지하는 마크다운 파일. 5가지 type: entity, concept, topic, source, synthesis (+ meta).
- **wikilink** — `[[page-name]]` 형식의 위키 내부 참조.
- **stub** — frontmatter `status: stub`. 1~2 문장만 있는 미완성 페이지.
- **mature** — frontmatter `status: mature`. 다수 출처로 검증되어 안정적으로 인용 가능.
- **orphan** — 어떤 페이지로부터도 wikilink되지 않는 페이지. lint에서 식별.
- **hub** — inbound link가 많은 페이지. 위키의 "허브".
- **contradiction marker** — `> ⚠️ Contradiction:` blockquote. 페이지 간 모순을 명시할 때 사용.

## 작업 종류
- **ingest** — 새 raw source를 읽고 위키에 통합하는 작업.
- **query** — 위키에 질문하는 작업. 의미 있는 답변은 synthesis로 저장 가능.
- **lint** — 위키 건강 검진.
- **curate** — 위키를 더 좋게 정리하는 작업 (rename, merge, split 등).

---

이 글로사리는 시간이 지나며 늘어난다. 새 용어가 쓰이기 시작하면 추가.
