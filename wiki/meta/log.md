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

## [2026-04-28 03:30] ingest | AgentVerse (Chen et al., 2023)
- source: [[2308.10848-agentverse]]
- created: [[agentverse]] (entity), [[dynamic-agent-recruitment]] (concept), [[2308.10848-agentverse]] (source)
- updated: [[llm-multi-agent-frameworks]] (AgentVerse stub→first-class, 분류축 2개 추가, 비교표 편향 경고 강화, ReAct stub 추가, 열린 질문 2개 추가), [[sop-for-llm-agents]] ('정반대 축 — Dynamic Recruitment' 섹션 추가), [[chatdev]] ([[agentverse]] 동그룹 cousin cross-ref), [[metagpt]] ([[agentverse]] cross-ref), [[contradictions]] (C-001 메타 정황 추가), [[index]]
- contradictions: 새 등록 없음. AgentVerse는 SoftwareDev/SRDD를 평가하지 않아 C-001에 새 데이터를 더하지 않음. 단, 같은 OpenBMB/Tsinghua 그룹(Chen Qian 등 공저)이 ChatDev/AgentVerse 둘 다 만들면서도 SRDD에서 cross-comparison을 안 한 정황을 메타 노트로 추가.
- notes: 5개 takeaway — 4-stage MDP 루프 + horizontal/vertical 토폴로지 / dynamic expert recruitment / multi-agent gain은 base LLM 능력에 종속 (GPT-3.5에서 Group<Solo, ~10% MGSM 오답이 erroneous feedback에 의한 sway) / Minecraft에서 volunteer-conformity-destructive emergent behaviors / 벤치 영역이 ChatDev/MetaGPT와 거의 안 겹침. emergent behaviors는 별도 concept 페이지로 빼지 않고 [[agentverse]] 본문에 흡수. ReAct는 stub 형태로만 [[llm-multi-agent-frameworks]]에 등록. **새 디자인 축 [[dynamic-agent-recruitment]]를 [[sop-for-llm-agents]]의 정반대로 명시.**

## [2026-04-28 04:30] ingest | ReAct (Yao et al., ICLR 2023)
- source: [[2210.03629-react]]
- created: [[react]] (entity), [[2210.03629-react]] (source)
- updated: [[llm-multi-agent-frameworks]] (ReAct stub→first-class, 'Single-agent precursor / baseline' 서브섹션 신설, AgentVerse 측 자체-벤치 caveat 명시), [[agentverse]] (ReAct 언급을 [[react]] wikilink로 교체 + selection bias caveat 추가, Related 보강), [[index]]
- contradictions: 새 등록 없음. AgentVerse 자체 10-task 벤치의 'ReAct 3/10' 결과는 self-bench selection caveat을 [[react]]·[[agentverse]] 양쪽에 명시 (C-001과 같은 패턴이지만 별도 등록은 보류 — 직접 충돌하는 다른 1차 출처가 아직 없음).
- notes: 5개 takeaway — action space `̂A = A ∪ L` 확장 / hallucination 0%(CoT 56%) vs reasoning error 47%(CoT 16%) trade-off / ReAct+CoT-SC 결합이 단독보다 우월 (HotpotQA 35.1 best, Fever 64.6) / prompting만으로 RL+IL trained 압도 (ALFWorld +34%, WebShop +10%) / framework 계보의 선조이자 standing baseline. 'reasoning-action interleaving' 추상 패턴은 별도 concept 페이지로 분리하지 않고 [[react]] 본문에 흡수 (현재 1차 출처 단일). CoT/Inner Monologue/WebGPT/SayCan/BUTLER 등 비교 대상은 1차 출처 부재로 stub 미생성.
