---
title: "Building effective agents"
type: source
created: 2026-11-27
updated: 2026-11-27
source_file: ../../raw/articles/2024-12-19-building-effective-agents.md
source_url: https://www.anthropic.com/engineering/building-effective-agents
author: Erik S., Barry Zhang (Anthropic)
source_date: 2024-12-19
tags: [agents, workflows, augmented-llm, prompt-chaining, routing, parallelization, orchestrator-workers, evaluator-optimizer, tool-use, aci, frameworks, simplicity, anthropic]
status: mature
---

# Building effective agents

> 성공한 에이전트 구현은 복잡한 framework가 아니라 **단순하고 조합 가능한 패턴**으로 만들어졌다. agentic system을 미리 정한 코드 경로를 따르는 **workflow**와 모델이 스스로 과정을 지휘하는 **agent**로 나눈다. augmented LLM 하나에서 다섯 workflow를 거쳐 agent로 복잡도를 올리되, 결과가 나아질 때만 올리라고 한다. agent는 결국 *루프 안에서 환경 피드백을 받아 도구를 쓰는 LLM*이므로, prompt만큼 **tool 정의(ACI)**에 공을 들여야 한다.

## Context

- **저자:** "Erik S. and Barry Zhang"(Anthropic). raw frontmatter의 "Erik Schluntz"는 ingest 때 보충한 이름이고, 페이지에는 "Erik S."로만 나온다.
- **발행:** Anthropic Engineering, 2024-12-19.
- **⚠️ 판본 주의.** raw는 2026-11-27에 받은 **현재 페이지**다. 원본 2024년 글이 아니다.
  - 맨 위에 편집 주석이 붙어 있다. *"Much of the tooling landscape described in this post has changed since December 2024. For our current approach, see how we built Claude Managed Agents …"*
  - framework 목록에 Claude Agent SDK와 Strands Agents SDK(AWS)가 있다.
  - routing 예시의 모델이 Claude Haiku 4.5와 Sonnet 4.5다. 모두 2024-12 이후의 이름이다.

  어느 문장이 원문이고 어느 문장이 개정인지는 이 판본만으로 가를 수 없다. 이 위키는 **개정판 기준**으로 인용한다.
- **성격.** 고객 수십 팀과의 작업과 자사 구현에서 얻은 실무 조언이다. 정량 데이터는 없다. 근거는 SWE-bench 에이전트 경험담 하나다.
- **이 위키에서의 위치.** [[2026-04-08-scaling-managed-agents]]가 스스로를 이 글을 잇는 계열에 둔다. 이 위키의 Anthropic 소스 중 가장 이르다. → [[anthropic]]

## Key Claims

1. **workflow vs agent.** 둘 다 *agentic systems*다.
   - **Workflow** — LLM과 도구가 **미리 정한 코드 경로**로 조율된다.
   - **Agent** — LLM이 **자기 과정과 도구 사용을 동적으로 지휘**하며 작업 방식의 통제권을 갖는다.
2. **가장 단순한 해법부터.** agentic system은 지연과 비용을 성능과 바꾼다. 많은 경우 retrieval과 in-context 예시로 단일 호출을 다듬는 것으로 충분하다. 복잡도가 필요하면 잘 정의된 과제에는 workflow(예측 가능성·일관성), 유연성과 모델 주도 결정이 필요하면 agent다.
3. **framework 경고.** framework는 시작을 쉽게 하지만 **추상화 층이 prompt와 응답을 가려** 디버깅을 어렵게 하고, 필요 없는 복잡도를 부추긴다. LLM API를 직접 쓰는 것부터 시작하라. framework를 쓴다면 그 밑의 코드를 이해하라. *"Incorrect assumptions about what's under the hood are a common source of customer error."*
4. **building block: augmented LLM.** retrieval, tools, memory로 강화된 LLM이다. 모델이 검색어를 만들고 도구를 고르고 무엇을 남길지 정한다. 구현 방법 하나로 MCP를 든다.
5. **다섯 workflow.**

   | workflow | 구조 | 맞는 경우 |
   |---|---|---|
   | **Prompt chaining** | 단계를 순서대로. 중간에 프로그램 검사(gate) | 고정된 하위 과제로 깔끔히 쪼개질 때. 지연을 정확도와 바꾼다 |
   | **Routing** | 입력을 분류해 전문 경로로 | 범주가 뚜렷하고 분류가 정확할 때. 쉬운 질문은 작은 모델로 |
   | **Parallelization** | sectioning(독립 하위 과제 병렬) / voting(같은 과제 여러 번) | 속도가 필요하거나 여러 관점이 신뢰도를 올릴 때. guardrail은 본 응답과 **다른 호출**이 맡는 게 낫다 |
   | **Orchestrator-workers** | 중앙 LLM이 동적으로 분해·위임·종합 | 필요한 하위 과제를 **미리 알 수 없을 때**(코딩의 수정 파일 수) |
   | **Evaluator-optimizer** | 한 호출이 생성, 다른 호출이 평가·피드백, 반복 | 평가 기준이 분명하고 반복 개선이 측정 가능할 때 |

   evaluator-optimizer가 맞는 신호는 둘이다. 사람이 피드백을 말해 주면 응답이 실제로 나아지는가, 그리고 LLM이 그런 피드백을 줄 수 있는가.
6. **agent의 정의.** 사람의 명령이나 대화로 시작해, 과제가 분명해지면 독립적으로 계획하고 움직인다. **매 단계 환경에서 "ground truth"**(tool 결과, 코드 실행)를 받아 진행을 판단한다. checkpoint나 막힐 때 사람에게 돌아올 수 있다. 완료 시 끝나지만 **정지 조건**(최대 반복 수 등)을 두는 게 흔하다. *"They are typically just LLMs using tools based on environmental feedback in a loop."*
7. **agent가 맞는 경우와 비용.** 필요한 단계 수를 예측할 수 없고 경로를 하드코딩할 수 없는 열린 문제다. 그 대신 모델의 판단을 어느 정도 믿어야 한다. 비용이 크고 **오류가 누적**된다. sandbox에서 충분히 테스트하고 guardrail을 두라.
8. **세 원칙.** 설계는 **단순하게**, agent의 계획 단계를 드러내 **투명하게**, agent-computer interface(ACI)는 tool **문서화와 테스트**로 공들여.
9. **agent가 가치를 내는 곳 (부록 1).** 대화와 행동이 함께 필요하고, 성공 기준이 분명하고, 피드백 루프가 돌고, 사람의 감독이 의미 있게 들어가는 과제다. 예시는 고객 지원(해결 건당 과금 모델이 성공 측정의 근거)과 코딩 에이전트(테스트로 검증 가능, 결과를 피드백으로 반복)다. 테스트가 기능을 검증해도 시스템 요구와 맞는지는 **사람 리뷰**가 필요하다.
10. **tool의 prompt engineering (부록 2).**
    - 같은 행동도 형식에 따라 모델이 쓰기 어렵다. diff는 새 코드를 쓰기 전에 hunk header의 줄 수를 알아야 하고, JSON 안의 코드는 줄바꿈과 따옴표를 escape해야 한다.
    - 형식 고르는 법: 막다른 곳에 몰리기 전에 "생각할" 토큰을 준다. 인터넷 텍스트에서 자연스럽게 보던 형식에 가깝게 한다. 줄 수 세기나 escape 같은 형식 부담을 없앤다.
    - **ACI:** HCI에 들이는 노력만큼 ACI에 들여라. 모델 입장에서 읽어 본다. 예시·edge case·입력 형식·다른 도구와의 경계를 정의에 넣는다. 팀의 주니어 개발자에게 쓰는 좋은 docstring처럼 쓴다. 많은 입력으로 모델이 도구를 어떻게 쓰는지 시험한다. **poka-yoke** — 실수하기 어렵게 인자를 바꾼다.
    - **사례:** SWE-bench 에이전트를 만들 때 *"we actually spent more time optimizing our tools than the overall prompt."* 에이전트가 루트 밖으로 나가면 상대 경로에서 실수했다. 도구가 항상 절대 경로를 받게 바꾸자 *"the model used this method flawlessly."*

## Notable Quotes / Passages

> *"Consistently, the most successful implementations weren't using complex frameworks or specialized libraries. Instead, they were building with simple, composable patterns."*

> *"Workflows are systems where LLMs and tools are orchestrated through predefined code paths. Agents, on the other hand, are systems where LLMs dynamically direct their own processes and tool usage, maintaining control over how they accomplish tasks."*

> *"To repeat: you should consider adding complexity only when it demonstrably improves outcomes."*

> *"One rule of thumb is to think about how much effort goes into human-computer interfaces (HCI), and plan to invest just as much effort in creating good agent-computer interfaces (ACI)."*

## Connections

- [[agent-fundamentals]] — workflow vs agent 구분과 augmented LLM이 이 topic의 뼈대다.
- [[agent-loop]] — "환경 피드백을 받아 도구를 쓰는 루프"와 정지 조건.
- [[tool-use]] — ACI와 poka-yoke는 tool use의 **인터페이스** 층위다.
- [[agent-orchestration-patterns]] — 다섯 workflow와 그 페이지의 여섯 패턴의 대응.
- [[orchestrator-worker]] — 이 글이 Anthropic의 첫 정의다. 단 이 글은 그것을 *workflow*로 분류한다.
- [[dynamic-workflows]] — "미리 정한 코드 경로"를 에이전트가 직접 쓰면 이 글의 이분법이 흐려진다.
- [[agent-evaluation]] — evaluator-optimizer의 적합 조건, guardrail 호출 분리.
- [[meta-harness]] — framework 경고와 2026년 편집 주석이 가리키는 Managed Agents 사이의 긴장.
- [[multi-agent-systems]] — "결과가 나아질 때만 복잡도를 올린다"는 그 topic의 경제성 판단과 같은 원리다.

## My Notes

- **용어 긴장.** 이 글은 orchestrator-workers를 *workflow*로 분류한다. 그러면서 *"subtasks aren't pre-defined, but determined by the orchestrator"* 라고 설명한다. 미리 정한 코드 경로라는 자기 workflow 정의와 어긋난다. 위키는 이 구조를 [[orchestrator-worker]]에서 multi-agent 구조로 다룬다. 이 글의 이분법은 **제어 흐름을 코드가 쥐느냐 모델이 쥐느냐**의 연속선으로 읽는 게 안전하다. *(해석은 이 위키의 것이다.)*
- **벤더 입장의 이동.** 2024년 본문은 "API를 직접 쓰라"고 한다. 2026년 편집 주석은 "Managed Agents를 보라"고 한다. 부분 판정과 근거는 [[meta-harness]] "framework 경고와 호스팅 harness" 절과 [[contradictions]]에 있다.

## Raw Source

[원본 파일](../../raw/articles/2024-12-19-building-effective-agents.md)
