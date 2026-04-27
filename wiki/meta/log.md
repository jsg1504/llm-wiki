# Wiki Log

> 이 위키에서 일어난 모든 작업의 시간순 기록. **append-only**: 절대 과거 항목을 수정하지 않는다. 각 항목은 `## [YYYY-MM-DD HH:MM] <op> | <title>` 형식이며, grep으로 빠르게 훑을 수 있다.

빠른 조회:
```bash
# 최근 5건
grep "^## \[" wiki/meta/log.md | tail -5

# 특정 날짜 이후
grep "^## \[2026-04" wiki/meta/log.md

# ingest 작업만
grep "^## \[.*\] ingest" wiki/meta/log.md
```

`<op>` ∈ {`ingest`, `query`, `lint`, `curate`, `manual`}

---

## [2026-04-28 00:00] manual | wiki bootstrap
- created: 프로젝트 스캐폴딩
- notes: CLAUDE.md, 4개 스킬 (source-ingest, wiki-page, wiki-link, wiki-lint), 3개 에이전트 (librarian, editor, linker), 4개 슬래시 커맨드 (/ingest, /lint, /wiki-status, /save-as-synthesis), 4개 hook (protect-raw, validate-frontmatter, session-start, log-tracker), 초기 meta 페이지(index, glossary).
- next: 첫 source를 raw/에 두고 /ingest로 시작.

## [2026-04-28 01:30] ingest | MetaGPT (Hong et al., ICLR 2024)
- source: [[2308.00352-metagpt]]
- created: [[metagpt]] (entity), [[sop-for-llm-agents]] (concept), [[llm-multi-agent-frameworks]] (topic), [[2308.00352-metagpt]] (source)
- updated: [[index]]
- contradictions: none (위키가 비어있던 첫 ingest)
- notes: 위키의 첫 source ingest. 5개 takeaway — SOP 인코딩 / 5개 역할 / structured communication / pub-sub message pool / executable feedback. 비교 entity(ChatDev, AutoGPT, LangChain, AgentVerse)는 stub 만들지 않고 topic 페이지에서 평문 + "자체 ingest 대기" 표기.

## [2026-04-28 02:30] ingest | ChatDev (Qian et al., 2024)
- source: [[2307.07924-chatdev]]
- created: [[chatdev]] (entity), [[2307.07924-chatdev]] (source), [[contradictions]] (meta)
- updated: [[metagpt]] (cross-ref + contradiction), [[2308.00352-metagpt]] (contradiction note), [[sop-for-llm-agents]] (강한/약한 SOP 구분), [[llm-multi-agent-frameworks]] (ChatDev first-class 승격 + cross-eval 모순 표), [[index]]
- contradictions: **C-001** — MetaGPT 논문은 SoftwareDev 벤치에서 MetaGPT > ChatDev라고, ChatDev 논문은 SRDD에서 ChatDev > MetaGPT라고 정반대 보고. 자체 벤치 cross-citation 신뢰성 약함을 위키 포지션으로 채택. 자세히: [[contradictions]].
- notes: 5개 takeaway — chat chain / communicative dehallucination / 이중 메모리 / inception prompting / 자체 SRDD 벤치. CDH는 별도 concept 페이지로 빼지 않고 [[chatdev]] 내부 흡수. 첫 contradiction 등록으로 [[contradictions]] meta 페이지 신설.
