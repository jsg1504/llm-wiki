---
title: MetaGPT
type: entity
created: 2026-04-28
updated: 2026-04-28
sources: [2308.00352-metagpt, 2307.07924-chatdev, 2308.10848-agentverse]
tags: [framework, multi-agent, code-generation, sop]
status: draft
---

# MetaGPT

> 인간 소프트웨어 회사의 SOP(Standard Operating Procedures)를 프롬프트 시퀀스로 인코딩한 LLM 멀티에이전트 협업 프레임워크. 5개 역할(PM/Architect/Project Manager/Engineer/QA)을 어셈블리 라인으로 엮어 cascading hallucination을 줄인다.

## Overview

- **종류**: 오픈소스 프레임워크 (Python).
- **창시자**: Chenglin Wu (DeepWisdom CEO)가 시작, Sirui Hong이 주요 실험·executable feedback 모듈을 설계.
- **소속**: DeepWisdom 주도, KAUST AI Initiative · 시아먼대 · CUHK-Shenzhen · 난징대 · UPenn · UC Berkeley · IDSIA 공동 연구. Jürgen Schmidhuber가 자문.
- **공개**: github.com/geekan/MetaGPT.
- **대표 논문**: [[2308.00352-metagpt|MetaGPT (ICLR 2024)]].

## 핵심 설계 요소

### 1. SOP를 프롬프트 시퀀스로 인코딩
[[sop-for-llm-agents]] 패턴의 대표 사례. 인간 조직의 표준 절차를 그대로 매핑해 자유 대화의 모호함을 제거한다.

### 2. 5개 역할 (assembly line)
| 역할 | 산출물 | 액션 |
|---|---|---|
| Product Manager | PRD (User Stories, Requirement Pool, Competitive Analysis) | WritePRD |
| Architect | 시스템 인터페이스 설계 + sequence flow diagram | WriteDesign |
| Project Manager | File List, Task List, Logic Analysis | WriteTasks |
| Engineer | 코드 + 단위 테스트 | WriteCode |
| QA Engineer | 코드 리뷰 | WriteCodeReview |

각 역할은 name·profile·goal·constraint·tool로 정의된다. 예: Engineer constraint = "PEP8, modular, readable."

### 3. Structured Communication Interfaces
ChatDev처럼 dialogue로 주고받는 대신 **PRD/설계 문서/다이어그램** 자체를 핸드오버. 자연어만 쓰면 "telephone game (Chinese whispers)" 식 왜곡이 누적된다는 게 motivation.

### 4. Publish-Subscribe + Shared Message Pool
글로벌 메시지 풀에 publish, role profile 기반으로 subscribe. one-to-one 통신의 토폴로지 폭증과 정보 과부하를 동시에 해결. Architect는 PM의 PRD에 주로 subscribe하고, QA의 메시지는 무시하는 식.

### 5. Executable Feedback Loop
Engineer 단계에서 코드 → 단위 테스트 실행 → 실패 시 디버그를 **최대 3회 retry**. 단순한 self-correction이지만 ablation에서 단독으로 HumanEval +4.2%, MBPP +5.4% 기여. SoftwareDev에서 human revision cost를 2.25→0.83으로 떨어뜨림.

## 성능

- **HumanEval Pass@1**: 85.9% (GPT-4 single-shot 67.0% 대비 SoTA).
- **MBPP Pass@1**: 87.7%.
- **SoftwareDev (자체 70-task 벤치)**: executability 3.75/4. ChatDev(2.25) 대비 큰 격차.
- **Token cost**: ChatDev의 약 1.6배 (19,292 → 31,255). SOP의 풍부함은 공짜가 아니다.

## 비교 대상

- [[llm-multi-agent-frameworks]] 에서 ChatDev, AutoGPT, LangChain, AgentVerse와 함께 비교.
- 가장 가까운 cousin: [[chatdev]] (Qian et al., 2024). 둘 다 소프트웨어 회사 시뮬레이션이지만 ChatDev는 dialogue 기반, MetaGPT는 structured-doc 기반.

> ⚠️ **Contradiction (2026-04-28):** [[2308.00352-metagpt]]는 자체 SoftwareDev 벤치에서 MetaGPT가 ChatDev보다 낫다고 주장하지만, [[2307.07924-chatdev]]는 자체 SRDD 벤치에서 정반대 결과를 보고한다. 자체 벤치 cross-citation은 selection bias 가능성이 높아 위키는 어느 쪽도 단정하지 않는다. 자세히: [[contradictions]].

ChatDev는 §2 Related Work에서 MetaGPT를 "**static** instructions predefined by human experts"라 평가하나, 이는 MetaGPT의 executable feedback loop을 무시한 평가로 보임.

## Related

- [[chatdev]] — 동시대 cousin·경쟁. 디자인 철학 정반대.
- [[agentverse]] — 또 다른 동시대 비교 entity. MetaGPT의 정적 5역할 SOP와 정면으로 다른 dynamic recruitment + horizontal/vertical 선택 디자인.
- [[sop-for-llm-agents]] — MetaGPT가 가장 명시적으로 구현한 패턴.
- [[dynamic-agent-recruitment]] — MetaGPT 디자인의 정반대 축.
- [[llm-multi-agent-frameworks]] — 동시대 멀티에이전트 프레임워크 비교 hub.
- [[2308.00352-metagpt]] — 1차 출처 논문.
- [[contradictions]] — ChatDev 논문과의 cross-evaluation 모순.

## Sources

- [[2308.00352-metagpt|MetaGPT (Hong et al., ICLR 2024)]]
- [[2307.07924-chatdev|ChatDev (Qian et al., 2024)]] — ChatDev 측 평가 인용
