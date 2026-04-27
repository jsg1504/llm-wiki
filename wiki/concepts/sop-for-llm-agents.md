---
title: SOP for LLM Agents
type: concept
created: 2026-04-28
updated: 2026-04-28
sources: [2308.00352-metagpt, 2307.07924-chatdev]
tags: [multi-agent, prompt-engineering, sop, workflow]
status: draft
---

# SOP for LLM Agents

> 인간 조직의 **Standard Operating Procedures**(역할 정의 + 핸드오버 절차 + 산출물 표준)를 LLM 에이전트의 프롬프트 시퀀스로 인코딩하는 패턴. 자유 대화의 모호함을 절차의 모호성으로 대체해 cascading hallucination을 억제한다.

## 무엇인가

전통적인 멀티에이전트 시스템은 에이전트들이 자연어로 자유롭게 대화하면서 합의를 만들어가는 방식이다. 이 접근은 단순 작업에서는 동작하지만 복잡한 작업에서 무너진다 — LLM이 잡담("Hi, hello")을 만들어내거나, 각 단계의 환각이 다음 단계로 누적되거나, 누가 무엇을 책임지는지 모호해진다.

SOP-for-agents 패턴은 이를 거꾸로 뒤집는다: **인간 조직이 같은 문제를 푸는 방식**(역할 분담 + 표준 산출물 + 정해진 핸드오버)을 그대로 프롬프트 레벨에 인코딩한다. 그 결과 에이전트는 "지금 무엇을 해야 하는가"를 자유 추론하지 않고, 자기 역할이 정한 산출물을 정해진 다음 역할에게 넘기기만 하면 된다.

## 구성 요소

1. **역할 명세** — name, profile, goal, constraint, tool. 예: Engineer = {goal: "elegant, readable, efficient code", constraint: "PEP8, modular"}.
2. **표준 산출물** — 자연어 대화가 아니라 PRD, 시스템 설계 문서, 태스크 리스트, 다이어그램 같은 **구조화된 deliverable**. 에이전트는 이 산출물을 "쓰는" 일이 자기 액션이다.
3. **워크플로우/핸드오버 그래프** — 누가 누구에게 무엇을 넘기는지 결정. 어셈블리 라인이 가장 단순한 형태.
4. **(선택) 통신 토폴로지** — one-to-one dialogue 대신 publish-subscribe + shared message pool 같은 메커니즘으로 정보 과부하 차단.
5. **(선택) 실행 가능한 검증 루프** — 산출물이 코드라면 컴파일/테스트/실행으로 자기 교정. MetaGPT의 executable feedback이 한 예.

## 왜 작동하는가 (가설)

- **모호함의 위치 이동**: 자유 대화에서는 "지금 무엇을 결정해야 하는가" 자체가 모호하다. SOP에서는 그 메타 결정이 절차로 고정되어 있고, LLM은 그 슬롯을 채우는 데만 집중한다.
- **구조화된 출력 = lossy 채널의 왜곡 감소**: 대화는 LLM 사이에서도 "telephone game"처럼 의미가 마모된다. 문서/다이어그램은 누락 여부가 검증 가능하다.
- **역할별 컨텍스트 분리**: 각 에이전트가 자기 역할에 맞는 메시지에만 subscribe하면 컨텍스트 윈도우가 본질적으로 짧아져서 산만함이 줄어든다.

## 한계와 비용

- **토큰 비용 증가**: SOP를 풍부하게 정의할수록 프롬프트가 길어진다. [[metagpt]]는 ChatDev 대비 약 1.6배 토큰 사용.
- **도메인 종속성**: 소프트웨어 개발 SOP는 인류가 수십 년간 다듬은 것이다. 다른 도메인에서 좋은 SOP가 있는지/만들 수 있는지는 별개 문제. 저자들도 software engineering에 집중.
- **유연성 ↓**: 역할 정의가 작업의 실제 분해와 안 맞으면 SOP는 오히려 족쇄가 된다.
- **upstream 환각은 여전히 전파됨**: PM이 잘못된 PRD를 써도 SOP 구조 자체가 그것을 잡지는 못한다. 그래서 [[metagpt]]는 마지막에 executable feedback을 끼워 넣는다.

## 변형 — 강한 SOP vs 약한 SOP

같은 motivation(자유 대화의 모호함 차단)을 두 방식이 정반대로 다룬다:

| | 강한 SOP ([[metagpt]]) | 약한 SOP ([[chatdev]]) |
|---|---|---|
| 핸드오버 매개체 | **구조화된 문서** (PRD, 시스템 설계, 다이어그램) | **다중 턴 dialogue + 솔루션 결과물** |
| 절차 정의 | 정적 (역할·산출물·순서 모두 명시) | 동적 (chat chain 그래프, dialogue가 합의 도달) |
| 통신 토폴로지 | shared message pool + role 기반 subscribe | sequential chain, 각 subtask = Instructor↔Assistant 이중 에이전트 |
| Hallucination 대응 | executable feedback loop | communicative dehallucination (역할 반전) |

ChatDev은 자기 시스템을 "communicative agents"로 부르고 SOP라는 단어를 거의 쓰지 않지만, 워터폴 phase + 5 역할(CEO/CTO/programmer/reviewer/tester) + 정해진 산출물 구조는 본질적으로 SOP의 한 형태다. 다만 **무엇을 통신하는가**(문서 vs 대화)에서 갈라진다.

## 대표 사례

- [[metagpt]] — 강한 SOP. 5개 역할(PM/Architect/PM/Engineer/QA)과 구조화된 산출물을 명시적으로 인코딩.
- [[chatdev]] — 약한 SOP. 동일한 워터폴 phase 구조이지만 핸드오버가 dialogue 기반.

## Related

- [[metagpt]] — 강한 SOP의 대표 구현.
- [[chatdev]] — 약한 SOP / dialogue-기반 변형.
- [[llm-multi-agent-frameworks]] — SOP 기반 vs free-form 비교 hub.

## Sources

- [[2308.00352-metagpt|MetaGPT (Hong et al., ICLR 2024)]] — SOP-for-agents의 motivation, 강한 SOP 구현, ablation.
- [[2307.07924-chatdev|ChatDev (Qian et al., 2024)]] — 약한 SOP / chat-chain 변형의 사례.
