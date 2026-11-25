---
title: Agent Memory (에이전트 장기 기억)
type: concept
created: 2026-11-26
updated: 2026-11-26
sources: [2023-10-12-memgpt, 2026-04-08-scaling-managed-agents, 2026-06-07-loop-engineering, 2026-05-25-how-we-contain-claude, 2023-03-20-reflexion, 2024-10-14-longmemeval, 2025-01-20-zep, 2025-02-17-a-mem]
aliases: [long-term memory, 장기 memory, virtual context management, main context, external context, knowledge update, abstention, memory evolution, edge invalidation]
tags: [agent-memory, virtual-context-management, memory-hierarchy, context-engineering, memory-poisoning, retrieval, benchmark, knowledge-graph, bi-temporal]
status: draft
---

# Agent Memory (에이전트 장기 기억)

> 모델은 실행이 끝나면 전부 잊는다. **agent memory는 context window 밖에 무엇을 남기고, 어떻게 갱신하고, 언제 무엇을 다시 창 안으로 가져올지를 정하는 설계**다. 소스들이 모이는 결론은 하나다. **원문을 남기고, 추출한 것은 찾는 길로 쓴다.** 갱신은 두 방식으로 갈린다. Zep은 옛 사실을 **지우지 않고 무효화**하고, A-MEM은 검색용 설명을 **덮어쓴다.** 어떤 정책이든 모델이 바뀌면 다시 검증할 대상이다.

## Overview

### 왜 따로 다루는가

이 위키에는 "상태를 context 밖에 둔다"는 처방이 여러 곳에 흩어져 있다. [[loop-engineering]]의 외부 state(*"The agent forgets, the repo doesn't."*), [[meta-harness]]의 durable 세션 로그, [[artifact-chain]]의 커밋된 파일, [[agent-recipe]]의 누적된 판단이 그렇다. 이들은 모두 **무엇을 밖에 둘 것인가**를 말한다. 이 페이지는 그 다음 질문을 다룬다. **밖에 둔 것을 어떻게 구조화하고, 어떻게 갱신하고, 누가 언제 다시 꺼내는가.**

### 기본 모델: 메모리 계층

[[2023-10-12-memgpt]]는 context window를 RAM으로, 외부 저장소를 디스크로 본다. 이것을 **virtual context management**라고 부른다.

```
┌─ main context (prompt token = RAM) ──────────────────────────┐
│  system instructions   읽기 전용. 계층의 용도, 함수 사용법     │
│  working context       고정 크기. 함수로만 씀. 사용자 사실·persona │
│  FIFO queue            메시지 이력 + 첫 칸에 재귀 요약          │
└──────────────────────────────────────────────────────────────┘
        ▲ 검색 결과를 페이지 단위로 가져옴     │ 밀어냄 (eviction)
        │                                      ▼
┌─ external context (디스크) ──────────────────────────────────┐
│  recall storage    모든 메시지를 영구 저장                    │
│  archival storage  임의 텍스트 DB (벡터 검색)                  │
└──────────────────────────────────────────────────────────────┘
```

([[2023-10-12-memgpt]])

핵심은 밀려난 것이 **사라지지 않는다**는 점이다. FIFO queue에서 밀려난 메시지는 요약으로 압축되지만 원본은 recall storage에 무기한 남는다. 필요하면 다시 검색해 창으로 가져온다.

### 설계를 나누는 틀: 세 단계, 네 조정점

[[2024-10-14-longmemeval]]은 memory를 거대한 key-value 저장소로 보고, 어떤 memory 시스템이든 세 단계로 나눈다.

```
(1) indexing         (2) retrieval          (3) reading
세션 → key-value     질의 → 상위 k개        LLM이 읽고 답함
   │    │               │                      │
 CP1   CP2             CP3                    CP4
 value  key            query                  reading strategy
 무엇을  무엇으로       질의를 어떻게           어떻게 읽나
 어떤 단위로 저장하나   색인하나   만드나
```

([[2024-10-14-longmemeval]])

이 틀로 이 페이지의 시스템들을 놓아 보면 차이가 보인다. *(대응은 이 위키의 해석이다.)*

| | value | key | query | reading |
|---|---|---|---|---|
| MemGPT | 메시지 원본(recall), 임의 텍스트(archival), 사실(working context) | archival은 벡터 임베딩 (recall의 검색 방식은 논문에 명시 없음) | **모델이** 함수 호출로 질의를 직접 쓴다 | 결과를 페이지 단위로 넘겨 본다 |
| Reflexion | 반성문 1~3개 | 없음 (검색하지 않고 전부 넣는다) | 없음 | 전부 prompt에 넣는다 |
| Zep | 원본 episode + 추출한 entity·사실(유효 기간 포함) + community 요약 | 사실·entity 이름·community 이름. cosine + BM25 + graph BFS | 질의 그대로, reranker로 정밀화 | 사실과 **유효 기간**, entity 요약을 텍스트로 |
| A-MEM | 원본 내용 + LLM이 만든 keyword·tag·설명 | 위를 모두 이어 붙인 임베딩 | 질의 임베딩 cosine, 링크된 노트도 함께 | 상위 k개 노트 |

([[2023-10-12-memgpt]], [[2023-03-20-reflexion]], [[2025-01-20-zep]], [[2025-02-17-a-mem]])

### 무엇을 재는가: 다섯 능력

[[2024-10-14-longmemeval]]은 장기 memory 능력을 다섯으로 나눈다.

- **Information Extraction** — 긴 이력에서 사용자나 assistant가 말한 세부 정보를 찾는다.
- **Multi-Session Reasoning** — 여러 세션의 정보를 모으고 비교한다.
- **Temporal Reasoning** — 시간 표현과 timestamp로 추론한다.
- **Knowledge Update** — 바뀐 사용자 정보를 알아채고 갱신한다.
- **Abstention** — 이력에 없는 것을 물으면 모른다고 답한다.

뒤의 둘이 "무엇을 잊고 갱신하는가"와 맞닿는다. LongMemEval은 갱신을 **재는** 방법이다. 갱신을 **하는** 방법은 §3의 Zep과 A-MEM이 준다.

## Key Points

### 1. 무엇을 남기나 — 원문은 창 밖에 남긴다

[[meta-harness]]는 compaction 처방을 셋으로 정리했다. (a) 잘 요약한다, (b) 애초에 도달하지 않는다, (c) 되돌릴 수 있게 한다. Managed Agents의 세션 로그가 (c)였다 ([[2026-04-08-scaling-managed-agents]]).

MemGPT는 2023년에 이미 (a)와 (c)를 함께 썼다. FIFO queue 첫 칸의 재귀 요약이 (a)이고, recall storage가 (c)다 ([[2023-10-12-memgpt]]). [[meta-harness]]의 문장 *"(c)는 (a)를 안전하게 만든다"* 의 구체적 구현이다. *(대응은 이 위키의 해석이다.)* Zep도 원본 episode를 *"non-lossy data store"* 로 두고, 추출한 사실에서 원본으로 거슬러 올라갈 수 있게 한다 ([[2025-01-20-zep]]). A-MEM도 노트 안에 원본 내용을 그대로 둔다 ([[2025-02-17-a-mem]]).

> **제품에서 잰 (a)의 약점.** [[2024-10-14-longmemeval]]이 2024년 8월에 ChatGPT memory를 사람이 직접 상호작용하며 쟀다. 원문 전체를 읽힌 GPT-4o(0.918)보다 ChatGPT memory(GPT-4o, 0.577)가 37% 낮았다. ChatGPT는 증거를 처음엔 바로 기록했지만, 대화가 이어지며 **이력을 압축할 때 그 정보를 바꿔 버렸다.** 원본 없이 요약만 남기면(처방 (a)만 쓰면) 무엇이 사라지는지를 제품 수준에서 보여준다. Coze(0.330)는 다른 이유로 실패했다. 간접적으로 나온 정보를 아예 기록하지 않았다.

### 2. 무엇을 담나 — 사실과 교훈

MemGPT의 memory는 **사실**을 담는다. 사용자의 생일, 남자친구 이름, 과거 대화 원본이다 ([[2023-10-12-memgpt]]). [[2023-03-20-reflexion]]의 memory는 **교훈**을 담는다. 과제에 실패할 때마다 LLM이 반성문을 쓰고 다음 시도에 넣는다. 논문의 ALFWorld 예시는 *"냄비를 스토브 버너에서 집으려 했지만 냄비는 거기 없었다"* 는 취지다(Figure 1). 실패한 trajectory는 단기 기억이고 반성문은 장기 기억이다.

| | 담는 것 | 언제 쓰나 | 무엇을 잊나 |
|---|---|---|---|
| MemGPT | 사실 (working context), 원본 (recall storage) | 같은 사용자와의 다음 대화 | 원본은 잊지 않는다. 요약만 밀려난다 |
| Reflexion | 교훈 (반성문) | **같은 과제**의 다음 시도 | 최근 1~3개만 남긴다 (sliding window) |
| Zep | 원본, 사실과 그 유효 기간, entity·community 요약 | 같은 사용자·조직의 다음 대화 | 지우지 않는다. 낡은 사실은 무효 표시 |
| A-MEM | 원본 + LLM이 만든 설명·태그·링크 | 같은 사용자와의 다음 대화 | 지우지 않는다. 설명은 덮어쓴다 |

([[2023-10-12-memgpt]], [[2023-03-20-reflexion]], [[2025-01-20-zep]], [[2025-02-17-a-mem]])

Reflexion의 sliding window는 "무엇을 잊는가"에 대한 가장 단순한 답이다. 오래된 것부터 잊는다. 근거는 context 한계뿐이고, 어떤 교훈이 더 중요한지는 따지지 않는다. 저자들 스스로 vector DB나 SQL DB로 확장하라고 권한다 ([[2023-03-20-reflexion]]).

교훈을 담는 memory는 [[prompt-optimization]]과 맞닿는다. 같은 반성 엔진의 결과를 GEPA는 **지시문**으로 증류해 과제 전체에 쓰고, Reflexion은 **인스턴스 하나의 memory**로 쓴다. *(대응은 이 위키의 해석이다.)*

### 3. 어떻게 갱신하나 — 무효화 vs 덮어쓰기

사용자 정보는 바뀐다. 이사를 가고, 직장을 옮기고, 취향이 변한다. 두 소스가 갱신을 구현하는데 방식이 정반대다.

**Zep — 지우지 않고 무효화한다** ([[2025-01-20-zep]]).
- 사실마다 시간 넷을 둔다. 사실이 **참이었던 기간**(t_valid, t_invalid)과 시스템에 **들어오고 무효화된 시점**(t′_created, t′_expired)이다. 이것을 **bi-temporal** 모델이라 부른다.
- 새 사실이 들어오면 LLM이 의미가 가까운 기존 사실과 비교해 모순을 찾는다. 시간이 겹치는 모순이면 옛 사실의 t_invalid를 새 사실의 t_valid로 정한다(**edge invalidation**). 새 정보가 우선한다.
- 그래서 graph는 *"현재 관계 상태와 관계가 변해 온 역사 기록을 둘 다"* 가진다.

**A-MEM — 검색용 설명을 덮어쓴다** ([[2025-02-17-a-mem]]).
- 새 노트가 들어오면 가장 가까운 기존 노트 k개를 찾는다. LLM이 그중 무엇과 링크할지 정하고(**link generation**), 각 기존 노트의 context·keyword·tag를 다시 쓸지 정한다(**memory evolution**).
- *"The evolved memory then replaces the original memory."* 원본 내용은 남지만, LLM이 만든 속성은 이전 버전이 남지 않는다.
- ablation에서 링크를 빼면 크게 떨어지고(multi-hop F1 27.02 → 9.65), 갱신만 빼면 중간쯤 떨어진다(21.35).

세 시스템을 나란히 놓으면 위치가 갈린다. *(이 표는 이 위키의 정리다.)*

| | 원문 | 찾는 데 쓰는 쪽(key) | 이전 상태 |
|---|---|---|---|
| Zep | 보존 | 무효화로 갱신 | **보존** |
| A-MEM | 보존 | 덮어씀 | 없음 |
| ChatGPT memory (LongMemEval 관측) | 압축하며 바뀜 | 바뀜 | 없음 |

([[2025-01-20-zep]], [[2025-02-17-a-mem]], [[2024-10-14-longmemeval]])

**어느 쪽이 나은지는 판정할 수 없다.** 두 방식은 같은 벤치마크로 비교된 적이 없다(Zep은 LongMemEval·DMR, A-MEM은 LoCoMo·DialSim). 모순이 아니라 **비교 데이터가 없는 설계 선택의 대립**이다. 다만 위험의 종류는 다르다. *(추론)*
- 덮어쓰기는 LLM이 **잘못 갱신하면** 되돌릴 근거가 없다. 원본은 남지만 검색은 갱신된 속성이 섞인 임베딩으로 한다.
- 무효화는 LLM이 **모순을 잘못 판정하면** 맞는 사실이 무효가 된다. 그래도 이전 상태가 남으므로 되돌릴 수 있다. 판정 정확도는 Zep도 보고하지 않았다.

**삭제는 여전히 비어 있다.** A-MEM의 갱신 프롬프트에 "prune" 동작이 있지만 방법 설명과 실험에는 나오지 않는다 ([[2025-02-17-a-mem]]). Zep은 무효화만 하고 지우지 않는다. LongMemEval 저자들은 memory "deletion" 연산이 없는 것을 신뢰의 문제로 꼽는다 ([[2024-10-14-longmemeval]]).

이 원칙을 memory 밖의 축적 자산으로 일반화한 것은 [[what-to-accumulate-outside-the-model]]에 있다.

### 4. 어떻게 찾고 읽나 — 설계 실험

[[2024-10-14-longmemeval]]은 네 조정점을 하나씩 바꿔 비교한다. 주 설정은 약 1.5M token 이력(500세션), dense retriever, 색인용 추출은 Llama 3.1 8B다.

| 조정점 | 결과 |
|---|---|
| **value** | 세션 통째보다 **round**(한 번의 질문-응답)로 쪼개는 것이 낫다. 요약이나 사실로 압축하면 token은 아끼지만 정보 손실로 대체로 나빠진다. 예외는 여러 세션에 걸친 추론으로, 사실 추출이 일관되게 좋았다 |
| **key** | 압축한 형태만 key로 쓰면 나아지지 않는다. **원문 + 추출한 사실**을 key로 쓰면 recall@k +9.4%, 정확도 +5.4% |
| **query** | 질문에서 시간 범위를 뽑아 검색을 좁히면 시간 추론 recall +6.8~11.3%. 단 범위를 뽑는 모델이 강해야 한다 |
| **reading** | 증거만 정확히 줘도 읽는 방식이 나쁘면 최대 10%p 손해. Chain-of-Note(항목마다 메모를 먼저 쓰고 추론) + JSON 형식이 가장 좋다 |

([[2024-10-14-longmemeval]])

**결론은 1절과 같은 방향이다.** 압축본만 두면 잃고, 원본을 남긴 채 압축본을 **찾는 길**로 쓰면 얻는다. MemGPT가 원본(recall storage)과 사실(working context)을 함께 둔 것, A-MEM이 원본에 LLM 설명을 이어 붙여 임베딩하는 것, Zep이 원본 episode와 사실을 양방향으로 잇는 것이 모두 이 처방이다. *(대응은 이 위키의 해석이다.)*

**검색 결과를 줄이면 빨라진다.** Zep은 LongMemEval_S에서 context를 115k token에서 1.6k로 줄이고, GPT-4o 정확도를 60.2%에서 71.2%로 올리고, 지연을 28.9초에서 2.58초로 줄였다 ([[2025-01-20-zep]]). A-MEM도 LoCoMo에서 token을 85~93% 줄였다 ([[2025-02-17-a-mem]]). 둘 다 저자 측정이다.

**찾는 것과 읽는 것은 따로 잰다.** memory 시스템의 성능은 "잘 찾는가"로 끝나지 않는다. 다 찾아 줘도 읽는 모델과 읽는 방식에 따라 결과가 달라진다. 그래서 retrieval 지표(recall@k)와 최종 정확도를 따로 봐야 한다. LongMemEval은 사람이 증거 위치를 표시해 두어 둘을 분리해 잴 수 있다 ([[2024-10-14-longmemeval]]).

**단순 사실은 통째로 넣는 쪽이 이기기도 한다.** A-MEM은 GPT-4o에서 single-hop(48.43 vs 61.56)과 답할 수 없는 질문 판별(36.35 vs 52.61)에서 대화 전체를 넣은 baseline보다 낮았다 ([[2025-02-17-a-mem]]). Zep은 assistant가 한 말을 기억하는 문제에서 떨어졌다(gpt-4o −17.7%) ([[2025-01-20-zep]]). 검색으로 줄이면 무언가를 빠뜨린다.

### 5. 누가 관리하나 — 모델 vs harness

두 소스는 같은 구조를 두고 결정 주체를 반대로 둔다.

| | MemGPT | Managed Agents |
|---|---|---|
| 창 밖 저장소 | recall / archival storage | session 이벤트 로그 |
| 무엇을 가져올지 | **모델**이 function call로 정한다 | **harness**가 정한다. 인터페이스는 "durable하고 interrogable하다"만 보장 |
| 근거 | 모델이 현재 목표를 가장 잘 안다 | 미래 모델에 어떤 context engineering이 필요할지 예측할 수 없다 |
| 출처 | [[2023-10-12-memgpt]] | [[2026-04-08-scaling-managed-agents]], [[meta-harness]] |

*(이 대비는 이 위키의 정리다. 두 소스는 서로를 언급하지 않는다.)*

Zep과 A-MEM은 그 사이에 있다. 검색 절차는 코드로 고정하고(Zep은 미리 정한 Cypher 질의, A-MEM은 임베딩 top-k), **무엇을 추출하고 연결하고 갱신할지는 LLM이** 정한다 ([[2025-01-20-zep]], [[2025-02-17-a-mem]]).

모델에게 맡기면 harness가 단순해진다. 대신 성능이 **모델의 능력**에 묶인다. MemGPT는 GPT-3.5에서 function calling이 약해 문서 QA 성능이 크게 떨어졌다 ([[2023-10-12-memgpt]]). 다음 절의 사례도 같은 이유다.

### 6. memory 정책은 능력 가정이다

memory 정책에는 모델에 대한 가정이 들어 있다. 그 가정은 모델이 바뀌면 어느 방향으로든 틀릴 수 있다.

- **새 모델이 더 나빴다.** nested KV 과제에서 baseline으로는 GPT-4 Turbo가 GPT-4보다 나았다. 그런데 MemGPT에 올리자 GPT-4 Turbo가 GPT-4보다 나빴다. 조회를 충분히 하지 않았다 ([[2023-10-12-memgpt]]).
- **context 한계 경고가 반대로 작용했다.** MemGPT는 window의 70%에서 "memory pressure" 경고를 넣고, *"context 한계를 의식하는 것이 자기 편집이 작동하는 핵심"* 이라고 쓴다 ([[2023-10-12-memgpt]]). 반면 Claude Sonnet 4.5는 context 한계가 다가오는 것을 감지하자 작업을 일찍 끝냈다(context anxiety). harness에 넣은 reset은 Opus 4.5에서 쓸모가 없어졌다 ([[meta-harness]], [[2026-04-08-scaling-managed-agents]]).
- **큰 모델이 늘 낫지 않았다.** [[2024-10-14-longmemeval]]에서 ChatGPT memory는 GPT-4o-mini(0.711)로 돌릴 때가 GPT-4o(0.577)보다 높았다. 약 115k token 이력을 통째로 읽는 설정에서는 Llama 3.1 70B(0.334)가 8B(0.454)보다 낮았다. 가져온 기억을 몇 token까지 넣는 게 좋은지도 읽는 모델마다 달랐다. Llama 3.1 8B는 3k token을 넘으면 급락했고 GPT-4o는 20k를 넘어서도 좋아졌다. 시간 범위를 뽑는 query 확장도 강한 모델에서만 효과가 있었다. 단, ChatGPT의 결과는 내부 구현이 공개되지 않아 모델 효과인지 시스템 효과인지 가를 수 없다.
- **갱신의 효과도 모델에 달렸다.** Zep의 knowledge update 개선은 gpt-4o에서만 나타났고(+6.52%), gpt-4o-mini에서는 떨어졌다(−3.36%). 저자들은 *"덜 강한 모델이 Zep의 시간 데이터를 이해하려면 더 개발이 필요하다"* 고 쓴다 ([[2025-01-20-zep]]). A-MEM은 memory 조직의 품질이 하부 LLM 능력에 좌우된다는 것을 스스로 한계로 적는다 ([[2025-02-17-a-mem]]).

같은 신호(context가 차고 있다)가 한 설계에서는 핵심 기능이고 다른 모델에서는 실패 원인이었다. 정면 모순은 아니다. 실험한 모델과 과제가 다르다. 대신 **"모델은 한계를 알려 주면 잘 대처한다"는 것도 능력 가정**이라는 사례로 읽는다. [[what-to-accumulate-outside-the-model]]의 기준(능력 가정은 썩고 과제 규칙은 남는다)에 따르면, memory **정책**(언제 경고하고, 언제 밀어내고, 몇 token을 넣고, 무엇을 모순으로 볼지)은 모델이 바뀔 때마다 다시 검증할 대상이다. 반면 memory **내용**(사용자에 대한 사실, 과거 대화 원본)은 모델과 무관하게 남는다. *(추론)*

### 7. 이벤트와 cadence

MemGPT는 사용자 메시지만이 아니라 시스템 경고, 사용자 행동(로그인, 업로드 완료), **정해진 일정의 timed event**로도 추론을 깨운다. 함수에 `request_heartbeat=true`를 주면 결과를 받은 즉시 다시 추론해 여러 함수를 이어 부른다 ([[2023-10-12-memgpt]]). [[loop-engineering]]의 automations(cadence)와 loop-until-done을 memory 시스템 안에 넣은 형태다. *(대응은 이 위키의 해석이다.)* Zep의 community도 새 entity가 올 때마다 조금씩 고치다 보면 정확한 결과에서 멀어지므로 **주기적인 전체 재계산**이 필요하다 ([[2025-01-20-zep]]). memory에도 cadence가 있다.

### 8. 쓰기 경로는 공격 경로다

[[prompt-injection]]은 persistent memory poisoning을 앞으로 커질 위험으로 꼽는다. product memory, `CLAUDE.md`, 장기 실행 에이전트의 state 디렉토리에 들어간 injection은 매 시작마다 다시 로드된다 ([[2026-05-25-how-we-contain-claude]]).

MemGPT 구조에서는 **모델이 사용자 메시지와 검색 결과를 읽고 스스로** working context와 archival storage에 쓴다. 사람이 리뷰하는 단계가 없다. 그래서 대화나 문서에 섞인 지시문이 영구 memory로 옮겨갈 수 있다. MemGPT 논문은 보안을 다루지 않는다. *(추론)* [[artifact-chain]]이 기대는 방어(커밋과 PR 리뷰)는 이런 자동 쓰기 경로에는 없다.

갱신이 자동이면 쓰기 경로는 더 넓어진다. A-MEM에서는 새 노트 하나가 **이웃 노트들의 설명까지** 다시 쓰게 하고, Zep에서는 새 사실 하나가 **기존 사실을 무효화**할 수 있다. 오염된 입력 하나가 새 항목을 넘어 기존 memory를 바꾸는 경로다. 두 논문 모두 보안을 다루지 않는다. *(추론)*

**소스가 직접 말한다.** [[2024-10-14-longmemeval]]의 저자들은 윤리 절에서 같은 위험을 적는다. 악의적 사용자가 memory 저장소에 **유해 콘텐츠를 넣어** 추론 시 jailbreak를 일으킬 수 있고, 저장한 사용자 정보가 샐 수 있다. 처방은 memory의 **읽기/쓰기 흐름을 감시하는 moderation**이다. 위의 추론이 처음으로 memory 연구 쪽 소스의 뒷받침을 얻는다. 다만 이 소스도 공격을 실험하지는 않았다.

## 한계와 읽을 때의 주의

- **정면 소스가 다섯이다.** MemGPT(preprint), Reflexion, LongMemEval(ICLR 2025), Zep(벤더 preprint), A-MEM(preprint)이다. 나머지 소스는 memory를 정면으로 다루지 않고 인접한 처방을 준다.
- **MemGPT의 비교는 MemGPT 쪽에 유리했다.** DMR baseline은 원본 대화 대신 손실 요약만 받았다. Zep이 다시 쟀더니 대화 전체를 넣은 baseline(gpt-4-turbo 94.4%)이 MemGPT(93.4%)보다 높았다. → [[2023-10-12-memgpt]], [[2025-01-20-zep]]
- **Zep과 A-MEM은 저자 측정이다.** Zep은 자사 제품이다. Zep은 abstention 유형을 보고하지 않았고, A-MEM은 단어 겹침 지표(F1, BLEU-1)를 쓴다.
- **LongMemEval의 상용 시스템 측정은 작다.** 97문항, 3~6세션의 짧은 이력, 2024년 8월 시점이다. 제품은 계속 바뀐다. → [[2024-10-14-longmemeval]] My Notes
- **비어 있는 질문.** **삭제**는 구현도 측정도 없다. 갱신의 두 방식(무효화, 덮어쓰기)을 같은 벤치마크로 비교한 소스가 없다. 모순 판정과 갱신 판정의 정확도도 보고되지 않았다. 여러 에이전트가 memory를 공유할 때의 문제도 비어 있다. 후보: Generative Agents(reflection), Mem0, memory poisoning 연구(MemoryGraft, MINJA 등).
- **Claude 데이터는 하나뿐이다.** A-MEM 부록의 Claude 3.0/3.5 Haiku 결과가 유일하고, 그 baseline 수치가 비정상적으로 낮아 신뢰도가 낮다. 나머지 소스는 GPT-3.5/4, GPT-4o, Llama, Qwen 세대다. → [[2025-02-17-a-mem]] My Notes

## Related

- [[meta-harness]] — 창 밖 durable 세션 로그. 같은 처방을 harness가 관리하는 쪽
- [[loop-engineering]] — 외부 state와 cadence. memory를 실행 사이의 연속성으로 쓰는 쪽
- [[artifact-chain]] — 산출물을 파일로 밖에 둔다. 리뷰를 거치는 쓰기 경로
- [[agent-recipe]] — 판단을 밖에 둔다. memory가 "무엇을 아는가"라면 recipe는 "어떻게 판단하는가"
- [[what-to-accumulate-outside-the-model]] — 모델 밖에 쌓을 자산의 수명 순서. memory 정책과 내용의 수명 차이, 무효화하되 지우지 않는 원칙
- [[prompt-injection]] — memory poisoning. LongMemEval 저자들이 직접 쓴 저장소 오염 경고
- [[agent-evaluation]] — memory를 재는 벤치마크 설계. 판정자 검증, retrieval과 최종 정확도의 분리, DMR이 낡은 사례
- [[prompt-optimization]] — 같은 반성 엔진의 결과를 memory가 아니라 지시문에 두는 쪽(GEPA)
- [[orchestrator-worker]] — 조정 상태가 lead의 context window에 사는 구조. memory를 밖에 두지 않을 때의 비용

## Sources

- [[2023-10-12-memgpt]] — Packer 외 (UC Berkeley), arXiv 2310.08560. 메모리 계층, self-directed memory, 이벤트 트리거, 결과 수치, 모델 의존성
- [[2023-03-20-reflexion]] — Shinn 외 (Northeastern·MIT·Princeton), arXiv 2303.11366. 교훈을 담는 episodic memory, sliding window
- [[2024-10-14-longmemeval]] — Wu 외 (UCLA·Tencent AI Lab·UCSD), ICLR 2025. 세 단계·네 조정점, 다섯 능력, 설계 실험, 상용 시스템 실측, 저장소 오염 경고
- [[2025-01-20-zep]] — Rasmussen 외 (Zep AI), arXiv 2501.13956. bi-temporal graph, edge invalidation, DMR 재측정, LongMemEval 결과. 벤더 자사 제품
- [[2025-02-17-a-mem]] — Xu 외 (Rutgers 등), arXiv 2502.12110. Zettelkasten 노트, link generation, memory evolution(덮어쓰기), Claude Haiku 데이터
- [[2026-04-08-scaling-managed-agents]] — 세션 로그, harness가 context를 관리하는 쪽의 근거, context anxiety
- [[2026-06-07-loop-engineering]] — 외부 state, *"The agent forgets, the repo doesn't."*
- [[2026-05-25-how-we-contain-claude]] — persistent memory poisoning
