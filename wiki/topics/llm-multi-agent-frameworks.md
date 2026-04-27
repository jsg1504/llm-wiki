---
title: LLM Multi-Agent Frameworks
type: topic
created: 2026-04-28
updated: 2026-04-28
sources: [2308.00352-metagpt, 2307.07924-chatdev]
tags: [multi-agent, llm, framework, agentic]
status: draft
---

# LLM Multi-Agent Frameworks

> 여러 LLM 에이전트가 협업해 복잡한 태스크를 푸는 프레임워크 계열. 통신 구조(자유 대화 vs 구조화 문서), 워크플로우(자유 추론 vs SOP), 검증 메커니즘(없음 vs executable feedback)에서 갈라진다.

## 왜 별도 토픽인가

2023년부터 AutoGPT, LangChain agents, AgentVerse, ChatDev, [[metagpt]] 등 LLM 기반 멀티에이전트 시스템이 쏟아져 나왔다. 이들은 모두 "여러 에이전트의 협업"이라는 외피는 같지만 **무엇이 정보를 운반하는가**, **누가 무엇을 결정하는가**, **언제 멈추는가**에서 본질적으로 다르다. 이 토픽은 이 갈래들을 추적하는 hub.

## 분류 축

| 축 | 양 끝 |
|---|---|
| **통신 매개체** | 자유 자연어 대화 ↔ 구조화된 문서/다이어그램 |
| **워크플로우** | 자율 reasoning loop ↔ 명시적 SOP / 어셈블리 라인 |
| **에이전트 수** | 단일 에이전트 + tools ↔ 다수 역할 분담 |
| **검증** | 없음 ↔ self-reflection ↔ executable feedback |
| **통신 토폴로지** | one-to-one dialogue ↔ shared message pool + pub/sub |

## 주요 프레임워크 (현재 위키 기준)

### [[metagpt]] (Hong et al., ICLR 2024)
- SOP 기반, 5개 역할, 구조화 문서 핸드오버, executable feedback.
- HumanEval 85.9% / MBPP 87.7% Pass@1.
- 자세한 내용: [[2308.00352-metagpt]].

### [[chatdev]] (Qian et al., 2024)
- 워터폴을 **chat chain**(dialogue 그래프)으로 재구성. 5 역할 (CEO/CTO/programmer/reviewer/tester), 3 phase (Design/Coding/Testing).
- 핵심 메커니즘: **이중 에이전트 (Instructor + Assistant) 다중 턴 대화**, **communicative dehallucination** (역할 반전 clarify), 이중 메모리 (short/long-term).
- 자체 SRDD 벤치(1,200 task)에서 ChatDev > MetaGPT > GPT-Engineer 주장. ⚠️ MetaGPT 논문은 정반대 주장 — [[contradictions]].
- 자세한 내용: [[2307.07924-chatdev]].

### AutoGPT (Torantulino et al., 2023) — *stub*
- 단일 에이전트가 reasoning loop으로 태스크 분해/실행. 멀티에이전트라기보다 "자율 에이전트"의 원형.
- 자체 ingest 대기 중.

### LangChain (Chase, 2022) — *stub*
- 정확히는 프레임워크라기보다 **에이전트 빌딩 블록 라이브러리**. 다른 멀티에이전트 시스템의 기반으로 자주 쓰임.
- 자체 ingest 대기 중.

### AgentVerse (Chen et al., 2023) — *stub*
- 역할 기반 멀티에이전트 환경. MetaGPT와 비교될 때 PRD/기술 설계 생성 같은 소프트웨어 엔지니어링 specific 기능은 없음 (MetaGPT Table 2).
- 자체 ingest 대기 중.

## 비교 표 (MetaGPT 논문 Table 2 발췌)

| 기능 | AutoGPT | LangChain | AgentVerse | ChatDev | MetaGPT |
|---|:-:|:-:|:-:|:-:|:-:|
| PRD 생성 | ❌ | ❌ | ❌ | ❌ | ✅ |
| 기술 설계 | ❌ | ❌ | ❌ | ❌ | ✅ |
| API 인터페이스 생성 | ❌ | ❌ | ❌ | ❌ | ✅ |
| 코드 생성 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 사전 컴파일 실행 | ❌ | ❌ | ❌ | ❌ | ✅ |
| 역할 기반 태스크 관리 | ❌ | ❌ | ❌ | ✅ | ✅ |
| 코드 리뷰 | ❌ | ❌ | ✅ | ✅ | ✅ |

> 출처: [[2308.00352-metagpt]] Table 2. **편향 주의**: MetaGPT 저자들이 자기 프레임워크의 강점에 맞춰 axis를 골랐을 가능성이 있다. 다른 ingest로 검증 필요.

## ⚠️ Cross-evaluation 모순 (MetaGPT ↔ ChatDev)

두 논문이 자기 자체 벤치에서 서로를 이긴다고 주장한다:

| 출처 | 벤치 | ChatDev Executability | MetaGPT Executability |
|---|---|---|---|
| [[2308.00352-metagpt]] | SoftwareDev (70 task, /4) | 2.25 | **3.75** |
| [[2307.07924-chatdev]] | SRDD (1,200 task, [0,1]) | **0.8800** | 0.4145 |

토큰 사용량도 보고치 다름. [[contradictions]]에 등록. **위키 포지션**: 자체 벤치 비교는 selection bias 위험이 커 신뢰 약함. third-party 벤치(HumanEval, MBPP) 결과만 cross-validation에 신뢰. 두 프레임워크의 실제 우열은 미확정.

## 열린 질문

- 자유 대화 기반(ChatDev) vs 구조화 문서(MetaGPT)의 우열은 정말 일반적인가? Software engineering처럼 SOP가 잘 정립된 도메인 밖에서도 그러한가?
- Token cost ↔ 품질 trade-off에서 SOP의 비용은 어디까지 정당화되는가?
- "에이전트 수 = 4"가 ablation에서 sweet spot으로 보이는데 (Table 3), 이게 LLM의 어떤 한계와 관련 있는가?

## Related

- [[sop-for-llm-agents]] — 이 토픽의 핵심 design pattern (강한/약한 두 변형).
- [[metagpt]] — 강한 SOP의 대표 구현.
- [[chatdev]] — 약한 SOP / chat-chain 변형.
- [[contradictions]] — MetaGPT ↔ ChatDev cross-evaluation 모순.

## Sources

- [[2308.00352-metagpt|MetaGPT (Hong et al., ICLR 2024)]]
- [[2307.07924-chatdev|ChatDev (Qian et al., 2024)]]
