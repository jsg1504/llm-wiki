---
title: Agent Fundamentals
type: topic
created: 2026-11-27
updated: 2026-11-27
sources: [2024-12-19-building-effective-agents, 2022-10-06-react, 2023-02-09-toolformer, 2025-06-13-multi-agent-research-system, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents]
tags: [agents, workflows, augmented-llm, agent-loop, tool-use, simplicity, agent-design]
status: draft
---

# Agent Fundamentals

> 에이전트 **하나**는 무엇으로 이뤄지는가. 바닥에 augmented LLM(retrieval·tools·memory)이 있고, 그 위에서 제어 흐름을 **코드가 쥐면 workflow**, **모델이 쥐면 agent**다. agent의 핵심은 루프(thought → action → observation)와 도구다. 원칙은 하나다. **결과가 나아질 때만 복잡도를 올린다.** 이 위키의 다른 topic(multi-agent, context·memory, SDLC)은 전부 이 바닥 위에 서 있다.

## Overview

이 위키는 지금까지 에이전트의 **바깥 구조**를 주로 쌓았다. 여러 에이전트를 엮는 법([[multi-agent-systems]]), 실행 사이를 설계하는 법([[loop-engineering]]), context 밖에 무엇을 두는 법([[context-and-memory]])이다. 그 구조들이 공통으로 전제하는 "에이전트 하나"를 정의한 페이지는 없었다. 이 topic이 그 자리다.

세 소스가 바닥을 깐다.

| 소스 | 연도 | 이 topic에 주는 것 |
|---|---|---|
| [[2022-10-06-react]] | 2022 | 루프의 정식화. 추론과 행동을 번갈아 낸다 |
| [[2023-02-09-toolformer]] | 2023 | tool use를 가중치에 넣는 방향. 규모 문턱 |
| [[2024-12-19-building-effective-agents]] | 2024 | workflow vs agent 구분, 다섯 workflow, ACI, 단순성 원칙 |

## 층위 — 바닥에서 위로

```
┌─────────────────────────────────────────────────────────┐
│ multi-agent / dynamic workflow / loop engineering        │  ← 다른 topic·concept
├─────────────────────────────────────────────────────────┤
│ agent         모델이 제어 흐름을 쥔다 (루프 + 도구)       │  [[agent-loop]]
├─────────────────────────────────────────────────────────┤
│ workflow      코드가 제어 흐름을 쥔다 (다섯 패턴)         │  [[agent-orchestration-patterns]]
├─────────────────────────────────────────────────────────┤
│ augmented LLM retrieval · tools · memory                 │  [[tool-use]], [[agent-memory]]
├─────────────────────────────────────────────────────────┤
│ 단일 LLM 호출 + retrieval + in-context 예시              │  ← "많은 경우 이것으로 충분하다"
└─────────────────────────────────────────────────────────┘
```

[[2024-12-19-building-effective-agents]]는 아래에서 위로 복잡도를 올린다. 그리고 *"많은 응용에서는 retrieval과 in-context 예시로 단일 LLM 호출을 다듬는 것으로 대개 충분하다"* 고 쓴다. 맨 아래 칸이 기본값이라는 말이다.

## Key Points

### 1. workflow와 agent — 누가 제어 흐름을 쥐는가

- **workflow** — LLM과 도구가 **미리 정한 코드 경로**로 조율된다. 예측 가능하고 일관적이다. 잘 정의된 과제에 맞는다.
- **agent** — LLM이 **자기 과정과 도구 사용을 동적으로 지휘**한다. 유연하다. 필요한 단계 수를 예측할 수 없는 열린 문제에 맞는다. 대가는 비용, 누적되는 오류, 모델 판단에 대한 신뢰다.

**이분법보다 연속선으로 읽는 게 안전하다.** 근거는 두 가지다. *(해석은 이 위키의 것이다.)*

1. 같은 글이 **orchestrator-workers를 workflow로 분류**하면서 *"하위 과제는 미리 정해지지 않고 orchestrator가 정한다"* 고 설명한다. 자기 정의와 어긋난다. 위키는 이 구조를 [[orchestrator-worker]]에서 multi-agent로 다룬다.
2. [[dynamic-workflows]]는 **에이전트가 workflow 코드를 직접 쓴다.** 코드가 실행 중 제어 흐름을 쥐니 workflow이고, 그 코드를 모델이 과제마다 만드니 agent다. 2024년의 구분은 2026년에 이미 한 시스템 안에 겹쳐 있다.

그래서 이 위키는 이렇게 묻는다. **제어 흐름의 어느 부분을 코드가 쥐고, 어느 부분을 모델이 쥐는가.** [[dynamic-workflows]]의 "조정 주체" 표와 [[subagent]]의 네 층위가 이 질문의 답이다.

### 2. augmented LLM — 모든 것의 바닥

retrieval, tools, memory로 강화된 LLM이다. [[2024-12-19-building-effective-agents]]는 모델이 이 능력을 *능동적으로* 쓴다고 쓴다. 검색어를 스스로 만들고, 도구를 고르고, 무엇을 남길지 정한다. 구현에서 볼 것은 둘이다. 용도에 맞게 다듬는가, 그리고 LLM에게 **쉽고 잘 문서화된 인터페이스**를 주는가.

세 능력은 이 위키에서 각자 페이지가 있다.

- **tools** → [[tool-use]]. prompt·가중치·인터페이스 세 층위
- **memory** → [[agent-memory]], [[context-and-memory]]
- **retrieval** → 독립 페이지가 없다. [[agent-memory]]의 검색 단계와 [[context-and-memory]]의 "누가 다시 가져오나"에 흩어져 있다.

### 3. agent = 루프 + 도구 + 정지 조건

*"They are typically just LLMs using tools based on environmental feedback in a loop."* 구현은 대개 단순하다. 그래서 무게는 **도구 설계**와 **루프 통제**로 간다.

- **루프** — 추론과 행동을 번갈아 낸다. 추론만 하면 hallucination이, 행동만 하면 목표 상실이 온다. 둘을 섞으면 실패가 사라지는 게 아니라 **교환**된다 ([[2022-10-06-react]]). → [[agent-loop]]
- **ground truth** — 매 단계 환경에서 사실을 받아 진행을 판단한다. 코딩 에이전트가 유망한 이유가 테스트다.
- **정지 조건** — 최대 반복 수 등으로 통제를 유지한다. 루프 고유의 실패는 같은 행동을 반복하는 것이다.
- **도구** — prompt보다 도구 최적화에 시간을 더 쓴 SWE-bench 사례. → [[tool-use]]

### 4. 단순성 원칙 — 복잡도는 자기 비용을 벌어야 한다

> *"you should consider adding complexity only when it demonstrably improves outcomes."* ([[2024-12-19-building-effective-agents]])

이 원칙은 위키 곳곳에서 같은 모양으로 다시 나온다. *(아래 연결은 이 위키의 정리다.)*

| 어디서 | 같은 판단 |
|---|---|
| [[multi-agent-systems]] | 멀티에이전트는 챗 대비 15배 토큰이다. 가치 높은 과제에만 쓴다 |
| [[dynamic-workflows]] | *"parallelism and specialization have to earn their coordination cost"* |
| [[agent-loop]] | ReAct는 HotpotQA에서 CoT보다 낮았다. 루프는 공짜 이득이 아니다 |
| [[recursive-language-model]] | 재현에서 단순 과제·강한 모델은 scaffold가 손해였다 |

2024년 Anthropic 글의 원칙과 2026년 외부 재현의 측정이 같은 방향이다. 원칙은 **측정**으로 지키라고 한다. *"measuring performance and iterating on implementations."* → [[agent-evaluation]]

### 5. framework와 harness — 무엇을 맡기는가

[[2024-12-19-building-effective-agents]]는 framework가 prompt와 응답을 가려 디버깅을 어렵게 한다고 경고한다. API를 직접 쓰는 것부터 시작하라고 한다. 그런데 2026년 현재 페이지 맨 위에는 *"이 생태계는 바뀌었다, Managed Agents를 보라"* 는 편집 주석이 있다.

이 위키의 판정은 **부분 판정**이다. 2024년 글이 경고한 것은 *prompt를 가리는 추상화*다. [[managed-agents]]가 맡는 것은 *세션·sandbox·자격증명 같은 인프라*다. 층위가 다르다. 다만 권고의 무게가 "직접 짜라"에서 "우리 harness 위에서 짜라"로 옮겨간 것은 사실이고, 두 글 모두 같은 벤더의 것이다. 근거와 남는 질문은 [[meta-harness]] "framework 경고와 호스팅 harness" 절에 있다.

## 이 topic이 아직 다루지 못한 것

- **planning과 reasoning model.** 계획 단계, test-time compute, reasoning model이 루프의 thought를 대체하는지 다룬 소스가 없다.
- **native function calling.** 지금 모델의 tool use가 어떻게 학습되는지 다룬 소스가 없다. Toolformer는 그 이전이다.
- **ACI의 외부 정량 근거.** 자사 수치(도구 설명 재작성 후 40% 단축, [[tool-use]]) 하나뿐이다. SWE-agent 같은 외부 ACI 측정 소스가 후보다.
- **MCP 자체.** 프로토콜·생태계를 다룬 소스가 없다. [[tool-use]]의 MCP 절이 임시로 대신한다.
- **에이전트 벤치마크.** SWE-bench는 사례로만 언급된다. 벤치마크 지형을 다룬 소스가 없다.

## Related

- [[agent-loop]] — agent의 핵심 구조. 실패 교환, 반복 실패, 정지 조건
- [[tool-use]] — augmented LLM의 tools. 세 층위와 ACI
- [[agent-orchestration-patterns]] — workflow 층. 다섯 workflow와 여섯 패턴의 대응
- [[orchestrator-worker]] — workflow와 agent의 경계에 선 구조
- [[dynamic-workflows]] — 에이전트가 workflow를 직접 쓴다. 이분법이 겹치는 곳
- [[multi-agent-systems]] — 이 바닥 위에 에이전트를 여럿 쌓을 때
- [[context-and-memory]] — augmented LLM의 memory를 실행 사이로 확장할 때
- [[meta-harness]] — framework 경고와 호스팅 harness의 긴장
- [[agent-evaluation]] — 단순성 원칙을 지키는 수단은 측정이다
- [[anthropic]] — 이 topic의 정의 소스 하나가 Anthropic 글이다

## Sources

- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic Engineering, 2024-12-19). workflow vs agent, augmented LLM, 단순성 원칙, framework 경고. 2026-11-27 개정판 기준
- [[2022-10-06-react]] — Yao 외 (Princeton·Google, ICLR 2023). 루프와 실패 교환
- [[2023-02-09-toolformer]] — Schick 외 (Meta AI, 2023). 가중치 층의 tool use
- [[2025-06-13-multi-agent-research-system]] — Anthropic (2025-06-13). orchestrator-worker를 multi-agent로 다룬 쪽의 근거만 이 소스에서 왔다
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Anthropic (2026-08-20). 에이전트가 workflow를 쓰는 사례, 조정 비용 원칙
- [[2026-04-08-scaling-managed-agents]] — Anthropic (2026-04-08). 호스팅 harness 쪽의 근거만 이 소스에서 왔다
