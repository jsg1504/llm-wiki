---
title: Tool Use
type: concept
created: 2026-11-27
updated: 2026-11-27
sources: [2022-10-06-react, 2023-02-09-toolformer, 2024-12-19-building-effective-agents, 2025-06-13-multi-agent-research-system, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude]
tags: [tool-use, function-calling, aci, react, toolformer, mcp, poka-yoke, agent-design]
status: draft
---

# Tool Use

> 모델이 외부 도구(검색, 계산기, API, 셸)를 불러 그 결과로 다음 생성을 이어 가는 것. 같은 능력을 **어디에 두느냐**로 세 층위가 갈린다. prompt에 예시로 두거나(ReAct), 가중치에 학습시키거나(Toolformer), 도구 쪽 인터페이스를 모델에 맞게 설계한다(ACI). 셋은 경쟁이 아니라 함께 쓰는 층이고, 수명이 다르다.

## Overview

이 위키는 tool call을 이미 일어나는 일로 다뤄 왔다. [[orchestrator-worker]]의 subagent는 도구를 3개 이상 동시에 부르고, [[meta-harness]]는 tool call을 인프라로 라우팅하는 배선을 harness라 부르고, [[prompt-injection]]은 tool 결과를 공격면으로 본다. 이 페이지는 **모델이 도구를 쓰게 되는 방식 자체**를 다룬다.

## 세 층위 — 같은 능력을 어디에 두는가

| 층위 | 대표 소스 | 능력을 두는 곳 | 누가 유용성을 판단하나 | 썩는 속도 |
|---|---|---|---|---|
| **prompt** | [[2022-10-06-react]] | few-shot 예시 궤적 (1~6개) | 사람이 쓴 예시 + 모델의 실행 중 판단 | 빠름 — 모델이 바뀌면 예시를 다시 고른다 |
| **가중치** | [[2023-02-09-toolformer]] | fine-tuning 데이터 | **모델 자신의 loss** | 모델과 함께 교체된다 |
| **인터페이스** | [[2024-12-19-building-effective-agents]] | tool 정의·인자·형식 (ACI) | 사람이 모델의 실수를 보고 고친다 | 느림 — 과제 규칙에 가깝다 |

"썩는 속도" 열은 이 위키의 판단이다. 근거는 [[what-to-accumulate-outside-the-model]]의 기준이다. **능력 가정은 썩고 과제 규칙은 남는다.** "모델은 도구를 이 예시처럼 써야 한다"는 능력 가정이다. "경로는 항상 절대 경로로 받는다"는 과제 규칙에 가깝다. *(분류는 이 위키의 해석이다.)*

### 1. prompt 층 — 예시로 가르친다 (ReAct)

[[2022-10-06-react]]는 도구를 frozen 모델에 **few-shot 예시**로 가르친다. 도구는 의도적으로 약하다. Wikipedia API의 `search`, `lookup`, `finish` 셋이고, 정확한 문서명을 알아야 검색된다. 저자들은 사람이 Wikipedia를 쓰는 방식을 흉내 내고 모델이 언어로 명시적으로 추론해 검색하게 하려고 이렇게 설계했다.

이 층의 강점은 **루프 안에서 다시 묻는다**는 것이다. 검색이 실패하면 thought로 검색어를 고치고 다시 검색한다. 약점은 규모다. PaLM-8B/62B에서는 prompting ReAct가 최하였고, 같은 궤적으로 fine-tuning해야 최상이 됐다. → [[agent-loop]]

### 2. 가중치 층 — 모델이 스스로 가르친다 (Toolformer)

[[2023-02-09-toolformer]]는 사람의 대량 주석 없이 tool use를 학습시킨다. 모델이 텍스트에 호출 후보를 끼우고, 실행하고, **결과가 뒤 토큰 예측의 loss를 줄인 호출만** 남긴다. 저자들의 동기는 *"사람이 유용하다고 여기는 것과 모델이 유용하다고 여기는 것이 다를 수 있다"* 는 것이다.

이 층에서 나온 두 관찰이 지금도 쓸모 있다.

- **규모 문턱.** 도구가 도움이 되기 시작한 것은 약 775M 파라미터부터다. 그 아래에서는 도구가 있으나 없으나 같았다. 도구를 주는 것 자체가 **능력 가정**이다. → [[meta-harness]]
- **보정.** 일반 greedy decoding에서 모델은 도구 없이는 틀릴 예시에서 호출을 골랐다. 호출 빈도를 억지로 올리자 그 보정이 사라졌다.

그리고 한계 목록이 그대로 다음 세대의 요구사항이다. **연쇄 불가**(A 도구의 결과를 B에 못 넣음), **상호작용 불가**(검색어를 고쳐 다시 묻지 못함), **비용 무시**. 셋 다 prompt 층의 루프가 이미 하던 일이다.

### 3. 인터페이스 층 — 도구를 모델에 맞춘다 (ACI)

[[2024-12-19-building-effective-agents]]는 방향을 뒤집는다. 모델을 도구에 맞추는 대신 **도구를 모델에 맞춘다.** 이름은 agent-computer interface(ACI)다. *"HCI에 들이는 만큼 ACI에 들여라."*

**형식 고르는 법.**
- 모델이 막다른 곳에 몰리기 전에 "생각할" 토큰을 준다.
- 인터넷 텍스트에서 자연스럽게 보던 형식에 가깝게 한다.
- 형식 부담을 없앤다. diff는 새 코드를 쓰기 전에 hunk header의 줄 수를 알아야 하고, JSON 안의 코드는 줄바꿈과 따옴표를 escape해야 한다. 사람에게는 무손실 변환이지만 모델에게는 난이도가 다르다.

**정의 쓰는 법.**
- 모델 입장에서 읽어 본다. 설명과 인자만 보고 쓰는 법이 뻔한가?
- 예시, edge case, 입력 형식, **비슷한 도구와의 경계**를 넣는다. 비슷한 도구가 많을수록 중요하다.
- 팀의 주니어 개발자에게 주는 좋은 docstring처럼 쓴다.
- 많은 입력으로 모델이 어떻게 쓰는지 **시험하고** 고친다.
- **poka-yoke** — 실수하기 어렵게 인자를 바꾼다.

**사례.** SWE-bench 에이전트를 만들 때 Anthropic은 *"전체 prompt보다 도구 최적화에 시간을 더 썼다."* 에이전트가 루트 밖으로 나가면 상대 경로에서 실수했다. 도구가 항상 절대 경로를 받게 바꾸자 실수가 사라졌다. 이 글에는 수치가 없다.

**반년 뒤의 수치.** [[2025-06-13-multi-agent-research-system]]은 같은 원칙을 이어 간다. *"도구 설계는 human-computer interface만큼 중요하다."* 그리고 ACI 개선을 **에이전트에게 맡겼다.** 결함 있는 MCP 도구를 에이전트가 수십 번 써 보게 한 뒤 도구 설명을 다시 쓰게 했더니, 이후 에이전트의 task 완료 시간이 **40% 줄었다.** 사람이 모델의 실수를 보고 고치던 일(2024)을 모델이 자기 실수를 보고 고친 셈이다. [[prompt-optimization]]이 prompt에 하는 일을 도구 설명에 한 것이다. *(대응은 이 위키의 해석이다.)* 같은 소스는 도구 **선택**의 실패도 든다. *"Slack에만 있는 정보를 웹에서 찾는 에이전트는 처음부터 실패한다."*

## 세 층위는 함께 쓴다

현재 harness는 세 층을 모두 쓴다. *(아래 대응은 이 위키의 정리이고, 단일 소스의 주장이 아니다.)*

- **가중치** — 모델 제공자가 tool use를 학습시킨다. Toolformer가 self-supervised로 하던 일이다.
- **prompt** — tool 정의와 system prompt가 언제 무엇을 쓸지 안내한다. ReAct의 예시 자리다.
- **인터페이스** — 도구 설계자가 ACI를 다듬는다.

prompt 층의 자동 최적화는 [[prompt-optimization]]이 다룬다. GEPA는 tool 정의를 직접 최적화하지 않는다. 다만 위의 40% 사례가 보여 주듯 에이전트가 도구 설명을 고치는 일은 이미 수작업 수준에서 효과가 있었다. GEPA 같은 체계적 탐색을 도구 설명에 적용한 소스는 아직 없다. *(질문은 이 위키의 것이다.)*

## 도구를 어떻게 연결하는가 — MCP

[[2024-12-19-building-effective-agents]]는 augmented LLM을 구현하는 한 방법으로 **Model Context Protocol(MCP)**을 든다. 제3자 도구 생태계에 간단한 client 구현으로 붙는 프로토콜이다. 이 위키의 다른 소스에서 MCP는 주로 **보안 경계**로 나온다.

- [[2026-04-08-scaling-managed-agents]] — 자격증명을 sandbox 밖 vault에 두고 MCP proxy가 대신 붙인다.
- [[2026-05-25-how-we-contain-claude]] — MCP 서버는 외부 콘텐츠 위험이다. 공급망 위험과 injection 위험을 동시에 갖고, *"감사된 커넥터는 감사된 데이터가 아니다."* 원격 도구는 로컬 도구와 달리 내 밑에서 바뀔 수 있다.

MCP 자체(spec, 서버·client 구조, 생태계)를 다룬 소스는 아직 없다. 지난 lint에서 stub 후보로 올랐던 MCP 페이지는 그런 소스가 들어올 때까지 이 절로 대신한다. → [[agentic-governance]], [[prompt-injection]]

## 도구는 공격면이다

tool 결과는 모델이 읽는 **미신뢰 입력**이다. ReAct 저자들은 2022년에 이미 윤리 절에서 이렇게 경고했다. 외부 환경과 연결된 LLM은 부적절한 정보를 찾거나 해로운 행동을 할 수 있다. 그래서 실험의 행동 공간에서 실제 구매와 Wikipedia 편집을 뺐다 ([[2022-10-06-react]]). 행동 공간을 줄여 위험의 상한을 정한 셈이다. [[agent-containment]]의 blast radius 원리와 같은 발상이다. *(대응은 이 위키의 해석이다.)*

## 한계와 읽을 때의 주의

- **수치는 2022~23년 모델이다.** PaLM-540B, GPT-J 6.7B, GPT-3 davinci다. 775M 문턱도 GPT-2 계열에서 잰 값이라 지금 모델 계열에 그대로 옮길 수 없다.
- **ACI의 정량 근거가 얇다.** 수치는 도구 설명 재작성 후 40% 단축 하나다. Anthropic 자사 측정이고, 비교 조건과 표본은 공개되지 않았다. 외부에서 ACI를 정량화한 소스(예: SWE-agent)는 이 위키에 없다.
- **native function calling을 직접 다룬 소스가 없다.** 지금 모델의 tool use가 어떻게 학습되는지는 이 위키의 소스로 답할 수 없다.

## Related

- [[agent-fundamentals]] — 이 페이지가 속한 topic
- [[agent-loop]] — tool 호출이 루프 안에서 반복될 때. 연쇄와 다시 묻기는 루프가 준다
- [[what-to-accumulate-outside-the-model]] — "밖에 쌓기 vs 가중치에 넣기" 축. 세 층위의 수명 판단 근거
- [[meta-harness]] — tool 배선은 harness의 일부다. 도구를 주는 것도 능력 가정이다
- [[prompt-optimization]] — prompt 층의 자동 최적화
- [[agent-containment]] — 행동 공간을 줄여 위험의 상한을 정하는 원리
- [[prompt-injection]] — tool 결과와 MCP 서버를 통한 공격
- [[agentic-governance]] — MCP와 connector를 통제하는 층

## Sources

- [[2022-10-06-react]] — Yao 외 (Princeton·Google, ICLR 2023). prompt 층, 약한 도구 설계, 윤리 절
- [[2023-02-09-toolformer]] — Schick 외 (Meta AI, arXiv 2302.04761). 가중치 층, 규모 문턱, 보정, 한계 목록
- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic, 2024-12-19). 인터페이스 층(ACI), poka-yoke, 절대 경로 사례, MCP
- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering (2025-06-13). 에이전트가 도구 설명을 고쳐 40% 단축, 도구 선택 실패만 이 소스에서 왔다
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic, 2026-04-08). MCP proxy와 자격증명 격리만 이 소스에서 왔다
- [[2026-05-25-how-we-contain-claude]] — Max McGuinness 외 4인 (Anthropic, 2026-05-25). MCP를 외부 콘텐츠 위험으로 본 서술만 이 소스에서 왔다
