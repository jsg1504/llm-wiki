---
title: Agent Loop
type: concept
created: 2026-11-27
updated: 2026-11-27
sources: [2022-10-06-react, 2024-12-19-building-effective-agents, 2023-02-09-toolformer, 2023-03-20-reflexion, 2026-08-14-practical-loop-engineering]
tags: [agent-loop, react, reasoning, acting, tool-use, stopping-condition, failure-modes, agent-design]
status: draft
---

# Agent Loop

> 에이전트 하나가 **실행 안에서** 도는 루프. 생각하고(thought) → 행동하고(action) → 환경의 관측(observation)을 받아 → 다시 생각한다. thought는 환경을 바꾸지 않고 context만 갱신한다. 이 루프가 에이전트를 단일 LLM 호출과 가르는 최소 구조다. 루프의 품질은 매 단계 **환경에서 오는 ground truth**와 **언제 멈추는가**가 정한다.

## Overview

이 위키는 처음부터 에이전트가 "루프를 돈다"고 전제해 왔다. [[orchestrator-worker]]의 subagent, [[dynamic-workflows]]의 harness, [[loop-engineering]]의 `/goal` 전부가 그 위에 서 있다. 이 페이지는 그 전제 자체를 다룬다.

원전은 [[2022-10-06-react]]다. 행동 공간 A에 언어 공간 L을 더해 Â = A ∪ L로 만든다. L에 속하는 행동(thought)은 관측을 돌려받지 않는다. 대신 지금까지의 context를 추론해 다음 context에 쓸모 있는 정보를 더한다. 2년 뒤 [[2024-12-19-building-effective-agents]]는 같은 구조를 제품 언어로 다시 정의한다. *"They are typically just LLMs using tools based on environmental feedback in a loop."* *(두 소스를 잇는 계보는 이 위키의 해석이다. 2024년 글은 ReAct를 인용하지 않는다.)*

```
          ┌──────────────────────────────────────────┐
          │                 context c_t              │
          │  (질문, thought, action, observation …)   │
          └──────────────┬───────────────────────────┘
                         ▼
                 ┌───────────────┐
                 │      LLM      │
                 └───┬───────┬───┘
       thought (∈ L) │       │ action (∈ A)
     환경 변화 없음  │       ▼
     context만 갱신  │   ┌─────────────┐
                     │   │    환경      │  tool 결과, 코드 실행,
                     │   │ (tool/API)  │  웹 페이지 …
                     │   └──────┬──────┘
                     │          │ observation = ground truth
                     ▼          ▼
               c_{t+1} = c_t + thought / action + observation
                         │
             정지 조건? ─┼─ 아니오 → 반복
                         │ 예
                         ▼
                      finish
```

## Key Points

### 1. 추론과 행동은 서로를 보완한다

[[2022-10-06-react]]의 핵심 주장이다. 추론은 행동 계획을 세우고 유지하고 고친다(*reason to act*). 행동은 외부 정보를 가져와 추론에 넣는다(*act to reason*). 하나만 쓰면 각자의 실패가 드러난다.

- **추론만 (CoT).** 모델 내부 표현으로만 생각하므로 외부 세계에 묶여 있지 않다. HotpotQA 실패의 **56%가 hallucination**이었다.
- **행동만 (Act-only).** 목표를 하위 목표로 쪼개지 못하고 환경의 현재 상태를 놓친다. ALFWorld 최고 성공률 45%로, ReAct의 71%보다 낮았다.
- **둘 다 (ReAct).** 실패 중 hallucination은 0%였다.

thought의 **내용**도 중요하다. 환경 피드백을 받아 적기만 하는 thought(Inner Monologue식)는 53%에 그쳤다. 하위 목표가 끝났는지, 다음 목표가 무엇인지 판단하지 못했다. 루프에 필요한 건 관측의 반복이 아니라 **목표 분해와 진행 추적**이다.

### 2. 루프는 공짜가 아니다 — 실패를 교환한다

같은 표에서 ReAct 실패의 **47%는 reasoning error**였다(CoT 16%). 관측을 끼워 넣는 구조가 추론 단계를 짜는 유연성을 줄였다. HotpotQA 점수 자체도 CoT보다 낮았다(27.4 vs 29.4). 쓸모없는 검색 결과가 들어오면(실패의 23%) 추론이 탈선하고 회복하지 못했다.

가장 좋은 방법은 섞는 것이었다. ReAct가 정해진 단계 안에 답을 못 내면 CoT-SC로 넘어가고, CoT-SC가 자신 없으면 ReAct로 넘어간다. **루프를 쓸지 말지를 과제 상황에 따라 바꾼 것**이다.

이 관찰은 위키의 다른 데이터와 같은 모양이다. RLM 재현에서는 단순 검색 과제와 강한 모델에서 scaffold가 오히려 손해였다 ([[recursive-language-model]]). 2024년 글의 *"가장 단순한 해법부터"* 원칙도 같은 판단을 실무로 옮긴 것이다 ([[agent-fundamentals]]). *(세 관찰을 하나로 묶은 것은 이 위키의 해석이다.)*

### 3. 루프의 고유한 실패: 같은 걸 반복한다

[[2022-10-06-react]]가 ReAct 특유의 실패로 기록한 것은 **이전 thought와 action을 다시 생성하며 루프를 빠져나오지 못하는 것**이다. 저자들은 greedy decoding 탓일 수 있다고 추측했다.

같은 신호가 이후 소스에서 정지 규칙이 된다.

| 소스 | 반복을 다루는 방식 |
|---|---|
| [[2022-10-06-react]] (2022) | 실패 유형으로 관찰. HotpotQA 7단계, FEVER 5단계 상한. 더 늘려도 성능이 오르지 않았다 |
| [[2023-02-09-toolformer]] (2023) | 입력당 API 호출 최대 1회. 호출만 계속하는 루프를 **구조적으로** 막는다. 대신 연쇄를 못 한다 |
| [[2023-03-20-reflexion]] (2023) | *"같은 행동을 하고 같은 응답을 3회 넘게 받으면"* 반성을 시작하는 heuristic |
| [[2024-12-19-building-effective-agents]] (2024) | 정지 조건(최대 반복 수 등)을 두어 통제를 유지하라 |
| [[2026-08-14-practical-loop-engineering]] (2026) | 같은 명령이 결과 변화 없이 반복되면 멈출 때다. 세 번째도 두 번째와 같으면 끊는다 |

4년 동안 처방이 바뀌지 않았다. **"관측이 바뀌지 않는데 행동을 반복하면 루프가 죽은 것이다."** 감지 주체가 저자의 분석(2022) → harness의 heuristic(2023) → 사람이 거는 규칙(2026)으로 옮겨 갔을 뿐이다. *(표의 통합은 이 위키의 정리다.)*

### 4. 매 단계 ground truth가 필요하다

[[2024-12-19-building-effective-agents]]는 agent가 *"매 단계 환경에서 ground truth를 얻어 진행을 판단해야 한다"* 고 쓴다. tool 결과나 코드 실행 결과다. 그 글이 코딩 에이전트를 유망한 분야로 꼽는 이유도 같다. 테스트가 자동으로 ground truth를 주기 때문이다.

이것은 [[agent-evaluation]]의 "판정자 분리"와 같은 원리를 루프 한 단계 단위로 적용한 것이다. 모델이 스스로 진행을 판단하면 hallucination이 루프를 따라 누적된다(*"compounding errors"*). 환경이 판단하면 루프가 매 단계 바로잡힌다. Reflexion의 ablation이 반대편 증거다. 테스트 없이 반성만 하면 baseline보다 **나빠졌다** ([[2023-03-20-reflexion]]).

### 5. 사람은 루프 안 어디에 있는가

- **ReAct:** 사람이 thought를 직접 고쳐 에이전트 행동을 바꿀 수 있다. 해석 가능성과 통제 가능성의 근거로 든다.
- **Building effective agents:** 사람의 명령이나 대화로 시작하고, checkpoint나 막힐 때 사람에게 돌아온다. 투명성 원칙은 *"계획 단계를 명시적으로 보여 주라"* 다.

둘 다 사람을 **매 턴이 아니라 예외 지점**에 둔다. [[loop-engineering]]이 루프가 처리 못 한 것만 triage inbox로 올리는 설계와 같은 방향이다.

## 이 루프와 다른 "루프"들

이 위키에는 루프라는 말이 여러 층위에서 나온다. 이 페이지는 **가장 안쪽**이다.

| 층위 | 무엇이 반복되나 | 페이지 |
|---|---|---|
| **agent loop** (이 페이지) | 한 실행 안의 thought → action → observation | — |
| 실행 단위 재시도 | 같은 과제 전체를 다시 시도(반성문을 들고) | [[2023-03-20-reflexion]], [[agent-memory]] |
| harness가 쥔 제어 흐름 | 에이전트 여러 개를 spawn·조율하는 코드 루프 | [[dynamic-workflows]], [[agent-orchestration-patterns]] #6 |
| loop engineering | 실행과 실행 **사이** — 주기, 외부 state, 정지 조건 | [[loop-engineering]] |
| 두 번째 루프 | 루프의 산출물이 eval·skill·prompt를 고친다 | [[loop-engineering]], [[agent-recipe]] |

[[inner-outer-loop-verification]]의 "안쪽 loop"는 이 표의 실행 단위 재시도와 harness 층을 포함한다. agent loop는 그보다 한 단계 더 안쪽이다.

## 한계와 읽을 때의 주의

- **수치의 수명이 짧다.** 1·2절의 수치는 2022년 PaLM-540B few-shot 결과다. 지금 모델에서 CoT와 ReAct의 실패 비율이 같다고 볼 근거는 없다. 남는 것은 "실패를 교환한다"는 구조적 관찰이다.
- **reasoning model 이후를 다룬 소스가 없다.** 지금 모델은 thought를 별도의 reasoning 단계로 내는 경우가 많다. 그것이 ReAct의 thought와 같은 역할인지, 반복 실패를 줄이는지는 이 위키의 소스로 답할 수 없다.
- **정지 조건의 설계는 여기서 다루지 않는다.** 무엇을 검증 가능한 정지 조건으로 삼는가는 [[loop-engineering]]과 [[agent-orchestration-patterns]] #6에 있다.

## Related

- [[agent-fundamentals]] — 이 페이지가 속한 topic. workflow vs agent, augmented LLM
- [[tool-use]] — 루프의 action이 무엇으로 이뤄지는가. prompt·가중치·인터페이스 세 층위
- [[loop-engineering]] — 실행 *사이*의 루프. 이 페이지는 실행 *안*의 루프
- [[agent-orchestration-patterns]] — loop-until-done(#6)은 이 루프를 여러 에이전트 단위로 올린 것
- [[agent-evaluation]] — 매 단계 ground truth와 판정자 분리
- [[2023-03-20-reflexion]] — 이 루프를 Actor로 쓰고 과제 단위로 재시도하는 바깥 루프
- [[recursive-language-model]] — 루프의 action이 REPL 코드와 자기 재귀 호출인 변형

## Sources

- [[2022-10-06-react]] — Yao 외 (Princeton·Google, ICLR 2023). 루프 정식화, 실패 교환, 반복 실패의 원전
- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic, 2024-12-19). agent 정의, ground truth, 정지 조건, 사람의 위치
- [[2023-02-09-toolformer]] — Schick 외 (Meta AI, 2023). 호출 1회 제한, 루프 없는 tool use의 대조군
- [[2023-03-20-reflexion]] — Shinn 외 (NeurIPS 2023). 반복 감지 heuristic, 검증자 없는 반성의 손해
- [[2026-08-14-practical-loop-engineering]] — Addy Osmani (2026-08-14). 같은 명령 반복을 정지 신호로 삼는 실무 규칙
