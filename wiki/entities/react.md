---
title: ReAct
type: entity
created: 2026-04-28
updated: 2026-04-28
sources: [2210.03629-react, 2308.10848-agentverse]
tags: [llm, prompting, paradigm, reasoning, agent, tool-use, single-agent]
status: draft
---

# ReAct

> 단일 LLM의 출력 스트림에 자유 형식 **thought**와 환경 **action**을 in-context few-shot으로 인터리브하는 prompting paradigm. action space를 `̂A = A ∪ L`(L = language space)로 확장. ICLR 2023, Yao et al. (Princeton + Google Brain). [[chatdev]]·[[metagpt]]·[[agentverse]] 같은 후속 멀티에이전트 framework들의 계보적 선조이자 standing baseline.

## Overview

- **종류**: prompting paradigm (framework가 아닌 prompt template + action loop pattern).
- **저자**: Shunyu Yao 1저자 (Princeton CS, 작업은 Google Brain 인턴 중). Karthik Narasimhan (Princeton). Google Research / Brain team 공저.
- **발표**: **ICLR 2023**. arXiv v1 2022-10-06, v3 2023-03-10.
- **공개**: react-lm.github.io.
- **대표 논문**: [[2210.03629-react|ReAct (Yao et al., ICLR 2023)]].

## 핵심 설계 요소

### 1. Action space augmentation: `̂A = A ∪ L`

Agent의 매 step `t`에서:
- 환경 action `a_t ∈ A` → 환경 state 변화, observation feedback.
- thought `̂a_t ∈ L` (자연어 free-form) → 환경 영향 없음, context만 갱신: `c_{t+1} = (c_t, ̂a_t)`.

**언제 thought를 낼지 자체가 LLM의 결정**. 구조 강제 없음 — task-dependent하게 dense (reasoning-heavy QA: thought-action-obs 반복) 또는 sparse (long-horizon decision-making: 가끔만 thought) 형태로 자연스럽게 분기.

### 2. Few-shot in-context prompting (no training)

PaLM-540B에 task당 **1~6개 trajectory**를 in-context example로 주입. 각 예시는 thought/action/observation의 인간이 쓴 sequence. 추가 finetuning · RL 없음. "More examples do not improve performance"(footnote 2) — 6 이상은 plateau.

### 3. Thought의 용도 (ad-hoc)

- task decomposition: "I need to search x, find y, then z"
- commonsense 주입: "x is not y, so z must instead be..."
- observation에서 정보 추출
- plan 추적·갱신
- exception 처리·rerouting
- search reformulation: "maybe I can search/look up x instead"
- 합성: "...so the answer is x"

→ 미리 정해진 thought taxonomy 없음. LLM이 task에 맞춰 사용.

### 4. Wikipedia API (HotpotQA/Fever용 환경 예)

- `search[entity]`: 첫 5문장 또는 top-5 유사 entity.
- `lookup[string]`: 페이지 내 string 포함 다음 문장 (Ctrl+F).
- `finish[answer]`: 종료.

**의도적으로 약한 retriever**: state-of-the-art neural retriever 안 씀. "사람이 Wikipedia를 쓰는 방식"을 강제해 explicit reasoning을 유도.

## 주요 결과 (PaLM-540B)

### Knowledge-intensive reasoning

| Method | HotpotQA EM | Fever Acc |
|---|---|---|
| Standard | 28.7 | 57.1 |
| CoT | 29.4 | 56.3 |
| CoT-SC (21 sample) | 33.4 | 60.4 |
| Act | 25.7 | 58.9 |
| ReAct | 27.4 | **60.9** |
| CoT-SC → ReAct | 34.2 | **64.6** |
| **ReAct → CoT-SC** | **35.1** | 62.0 |
| Supervised SoTA | 67.5 | 89.5 |

- **HotpotQA**: CoT 단독 > ReAct 단독. 결합(ReAct→CoT-SC)이 best.
- **Fever**: ReAct 단독이 CoT 단독보다 우위.
- prompting 결과는 supervised SoTA 한참 미달. domain-specific finetuning 차이 여전히 큼.

### Hallucination vs reasoning error trade-off (HotpotQA 200 trajectory 수동 분석)

| | ReAct | CoT |
|---|---|---|
| Success: True positive | 94% | 86% |
| Success: False positive | 6% | 14% |
| Failure: Reasoning error | **47%** | 16% |
| Failure: Search result error | 23% | — |
| Failure: **Hallucination** | **0%** | **56%** |
| Failure: Label ambiguity | 29% | 28% |

**External grounding이 hallucination을 거의 제거**(56% → 0%)하나, 구조적 제약 때문에 'thought·action 반복 루프 탈출 실패'가 새 주된 실패 모드. greedy decoding 한계로 추정 (논문 footnote 4).

### Decision-making (prompting > RL/IL trained baseline)

**ALFWorld** (text game, 134 unseen tasks):

| Method | All Avg | All Best |
|---|---|---|
| Act | 45 | 45 |
| **ReAct** | **57** | **71** |
| ReAct-IM (Inner Monologue 스타일) | 48 | 53 |
| BUTLER (10⁵ expert traj IL trained) | 22 | 37 |
| Human Expert | — | 59.6 (WebShop 기준) |

**+34% absolute over BUTLER**, 1~3 in-context example로. ReAct-IM ablation은 "dense external feedback만으론 부족, thought의 유연성이 핵심"임을 보임.

**WebShop** (1.18M product 실 환경, 500 test instruction):

| Method | Score | SR (%) |
|---|---|---|
| Act | 62.3 | 30.1 |
| **ReAct** | **66.6** | **40.0** |
| IL | 59.9 | 29.1 |
| IL+RL | 62.4 | 28.7 |

**+10% absolute over IL+RL** with one-shot prompt. human expert 59.6에는 한참 못 미침.

### Finetuning scaling

- prompting only: 작은 모델(PaLM-8B/62B)에서 ReAct 가장 약함 — 1-6 example로 format 학습 어려움.
- 3,000 trajectory finetuning 시 **ReAct가 4가지 method 중 best**: PaLM-8B finetuned ReAct > 모든 PaLM-62B prompting, PaLM-62B finetuned ReAct > 모든 PaLM-540B prompting.
- 가설: Standard/CoT finetuning은 hallucinated facts 암기 학습 위험. ReAct/Act는 'Wikipedia 접근법' 학습 — 더 generalizable.

## 후속 framework들과의 관계

- **[[chatdev]]·[[metagpt]]·[[agentverse]]**: 모두 2023년 후반 등장. ReAct가 던진 "LLM이 thought+action을 인터리브하는 single-agent 패러다임"을 multi-agent로 확장하거나 (ChatDev/MetaGPT) 그 위에 dynamic recruitment를 얹은 (AgentVerse) 형태.
- ReAct 본 논문도 한계를 명시: "complex action space는 1-2 shot로 부족, multi-task training + RL 결합이 future work" (§6) — 후속 멀티에이전트 흐름의 motivation을 ReAct 자신이 던져둔 셈.

### ⚠️ AgentVerse 자체 벤치의 ReAct 평가

[[agentverse]] §3.3에서 자체 10-task tool-use 벤치(Bing Search API + web browser + code interpreter + task API)에서 "single ReAct **3/10** vs AgentVerse(GPT-4) **9/10**"으로 보고. 이를 멀티에이전트 우위 핵심 증거로 사용.

이 결과는 ReAct paradigm의 일반적 한계라기보다는:
- **Selection caveat**: AgentVerse 측이 디자인한 task suite가 'multi-tool 분해가 명시적으로 필요한 task'에 편향됐을 가능성. ([[contradictions]] C-001과 같은 자체-벤치 cross-citation 신뢰성 패턴.)
- **Prompt budget 한계**: AgentVerse 환경의 풍부한 action space는 ReAct이 원래 실험한 'search/lookup/finish 3-action Wikipedia API'보다 훨씬 복잡. ReAct 자신도 §6에서 1-shot의 한계를 인정.

→ 위키 포지션: ReAct이 멀티에이전트보다 본질적으로 약하다는 결론은 AgentVerse 자체 벤치만으론 약한 증거.

## 한계 / 열린 질문

- **Prompt budget 의존**: 1-6 example로는 복잡한 action space cover 부족. ReAct 자신이 §6에서 finetuning을 답으로 제시.
- **Reasoning error 47%의 'thought-action 반복 루프'**: greedy decoding 부작용 추정만. 다른 decoding 전략 (beam search 등) 효과 미측정. 멀티에이전트 framework들의 evaluator/critic 모티베이션 중 하나로 읽을 만함.
- **HotpotQA에서 CoT 단독 > ReAct 단독**: external retrieval이 항상 도움이 아님. internal knowledge로 풀 수 있는 task에선 검색이 noise. → "언제 도구를 쓸지 결정"이 진짜 hard problem이며, 이 결정 자체를 학습하는 후속 연구의 시작점.
- **simple action space 가정**: search/lookup/finish 3개로 의도적으로 단순화. real-world tool API의 풍부한 action space에서의 일반화 검증은 ReAct 자체엔 없음 (AgentVerse 등 후속 작업이 시도).

## Related

- [[2210.03629-react]] — 1차 출처 논문.
- [[agentverse]] — ReAct를 single-agent baseline으로 사용한 후속 멀티에이전트 framework. 자체 10-task에서 ReAct 3/10으로 평가 (caveat 위 참고).
- [[chatdev]] — ReAct 이후 등장한 멀티에이전트 framework. 직접 비교는 없음.
- [[metagpt]] — 〃.
- [[llm-multi-agent-frameworks]] — single-agent precursor 위치.

## Sources

- [[2210.03629-react|ReAct (Yao et al., ICLR 2023)]] — paradigm 정의 + 모든 empirical 결과.
- [[2308.10848-agentverse|AgentVerse (Chen et al., 2023)]] — AgentVerse 측 자체 벤치 ReAct 평가 (3/10) 및 caveat의 출처.
