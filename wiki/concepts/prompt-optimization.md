---
title: Prompt Optimization (프롬프트 최적화)
aliases: [prompt-optimizer, reflective-prompt-evolution, GEPA]
type: concept
created: 2026-11-25
updated: 2026-11-27
sources: [2025-07-25-gepa-reflective-prompt-evolution, 2023-03-20-reflexion, 2025-12-31-recursive-language-models, 2025-06-13-multi-agent-research-system, 2024-12-19-building-effective-agents]
tags: [prompt-optimization, gepa, dspy, mipro, textgrad, reflection, compound-ai-systems, evolutionary-search, pareto]
status: draft
---

# Prompt Optimization (프롬프트 최적화)

> **LLM 시스템의 가중치는 그대로 두고 prompt만 자동으로 고쳐 성능을 올리는 것.** 사람이 손으로 하던 prompt 튜닝을 알고리즘으로 옮긴다. 이 위키에서 현재 대표 사례는 **GEPA**다. 실행 trace와 채점 텍스트를 LLM이 자연어로 반성하고, 과제별 최고 후보들 위에서 진화를 이어간다. 가중치 RL보다 훨씬 적은 시도로 더 좋은 결과를 냈다.

## Overview

### 무엇을 최적화하는가: compound AI system

[[2025-07-25-gepa-reflective-prompt-evolution]]은 대상을 **compound AI system**으로 정의한다. LLM 호출 하나 이상이 tool call과 섞여 임의의 제어 흐름으로 엮인 모듈식 시스템이다. 에이전트, 멀티에이전트 시스템, ReAct 같은 scaffolding이 전부 여기에 들어간다.

형식으로는 Φ = (M, C, X, Y)다. M은 언어 모듈들이고, 각 모듈은 prompt π와 가중치 θ를 갖는다. C는 제어 흐름이다. 최적화의 손잡이는 두 개다.

| 손잡이 | 방법 | 대표 | 비용 |
|---|---|---|---|
| **θ (가중치)** | 강화학습, fine-tuning | GRPO | rollout 수만~수십만. 최대 모델은 가중치 접근 불가 |
| **π (prompt)** | prompt optimization | GEPA, MIPROv2, TextGrad | rollout 수백~수천. 닫힌 모델에도 쓸 수 있다 |

이 위키의 층위 그림으로 보면 **가장 빠르게 변하는 맨 아래 층**을 자동으로 돌리는 것이다. → [[meta-harness]]

### 계보

- **Reflexion** (2023): 실패할 때마다 LLM이 자연어로 반성하고, 반성문을 memory에 쌓아 **같은 과제를 다시 시도**할 때 넣는다. 가중치도 prompt 지시문도 바꾸지 않는다. 교훈이 그 인스턴스 하나에만 쓰인다 ([[2023-03-20-reflexion]]). GEPA는 이 계열을 "in-context self-bootstrapping"으로 묶고, 자신은 예시로 **과제별 규칙**을 만든다고 차별화한다 ([[2025-07-25-gepa-reflective-prompt-evolution]]). 반성이라는 엔진은 같고, 결과를 어디에 두느냐가 다르다. Reflexion은 episodic memory에, GEPA는 지시문에 둔다. → [[agent-memory]] *(대응은 이 위키의 해석이다.)*
- **DSPy** 계열: few-shot 예시를 탐색하거나 bootstrap한다.
- **MIPROv2:** 지시문과 few-shot 예시를 Bayesian optimization으로 함께 맞춘다. GEPA 이전의 최고 성능 기준점이다.
- **TextGrad:** 텍스트 피드백을 "역전파"한다. 항상 최고 후보 하나를 고친다.
- **EvoPrompt, AlphaEvolve:** 진화 탐색. 뒤쪽은 prompt가 아니라 코드를 직접 진화시킨다.
- **GEPA:** 위 요소를 조합하고 **모듈별 텍스트 피드백**과 **인스턴스별 Pareto frontier**를 더한다.

([[2025-07-25-gepa-reflective-prompt-evolution]] §6)

## Key Points

### 1. 언어가 학습 매체다

GEPA의 출발 관찰은 이렇다. rollout은 결국 **자연어 trace**다. 지시문, reasoning, tool call, 그리고 점수로 접히기 전 채점기의 출력(컴파일러 에러, 실패한 루브릭)까지 전부 글이다. RL은 이걸 스칼라 하나로 접어 버리고, 그 신호로 gradient를 추정하느라 rollout 수만 번이 든다. LLM은 그 글을 **그냥 읽을 수 있다** ([[2025-07-25-gepa-reflective-prompt-evolution]]).

그래서 GEPA는 채점 함수 µ를 **feedback function µf**로 넓힌다. 점수와 함께 `feedback_text`를 돌려준다. 멀티홉 검색이면 "아직 못 찾은 문서", 커널 생성이면 컴파일러 에러와 프로파일링 결과다. 사람이 채점할 수 있는 도메인이라면 **사람이 쓴 채점 근거**도 넣는다.

> ⚠️ 이 주장 자체를 직접 검증한 비교는 본문에 없다. feedback_text를 끄고 돌린 실험이 없다. GRPO와의 비교는 prompt 공간과 가중치 공간이라는 다른 파라미터 공간끼리의 비교다.
>
> **다른 설정에서의 직접 비교 (2026-11-26).** [[2023-03-20-reflexion]]에는 텍스트 반성을 끈 ablation이 둘 있다. (1) HotPotQA(정답 context가 주어진 CoT, 100문항)에서 최근 trajectory만 다시 넣은 경우보다 **반성문을 넣은 경우가 +8%p** 높았다. (2) HumanEval Rust 최난도 50문제에서 테스트는 돌리되 반성을 빼면 baseline(0.60)과 같았고, 둘 다 쓰면 0.68이었다. 에러 정보만으로는 수정에 반영되지 않고, **자연어로 옮기는 단계**가 효과를 냈다는 뜻이다. GEPA의 feedback_text와 같은 설정은 아니므로 이 절의 주장을 직접 검증하지는 않는다. 같은 방향의 근거다. *(대응은 이 위키의 해석이다.)*

### 2. 반성은 암묵적 credit assignment다

한 번의 mutation은 이렇게 돈다.

```
후보 선택 (Pareto frontier에서 확률적으로)
  → minibatch 실행, trace + 점수 + feedback_text 수집
  → 고칠 모듈 선택 (round-robin)
  → reflection LM: (현재 prompt, trace, 점수, 피드백) → 새 지시문
  → minibatch 재평가 → 나아졌으면 pool에 추가, Pareto set 전체 평가
```

reflection LM이 trace를 읽고 **어느 모듈의 어느 결정이 성패를 냈는지** 귀속시킨다. RL이 수천 번의 시도로 통계적으로 하는 일을 한 번의 읽기로 한다. 반성 meta-prompt는 이렇게 지시한다.

> *"Identify all niche and domain specific factual information about the task and include it in the instruction, as a lot of it may not be available to the assistant in the future."*

결과 prompt에는 "Key Observations and Lessons" 같은 절이 생긴다. **trace에서 배운 교훈이 지시문에 누적**된다. 자식 후보는 부모의 교훈을 물려받는다.

### 3. 최고 후보만 고치면 갇힌다 — Pareto 선택

| 선택 전략 (Qwen3 8B, 4과제) | 집계 개선 |
|---|---|
| 최고 후보만 (TextGrad 방식) | +6.05% |
| BeamSearch N=4 (APO 방식) | +5.11% |
| **Pareto 기반 (GEPA)** | **+12.44%** |

최고 후보만 고치면 첫 개선 직후 같은 후보를 다듬다 예산을 다 쓴다. GEPA는 **인스턴스마다** 최고 점수를 낸 후보를 모두 남긴다. 어느 한 문제에서라도 이기는 "전략"이면 살린다. 그리고 이긴 인스턴스 수에 비례해 확률적으로 고른다 ([[2025-07-25-gepa-reflective-prompt-evolution]] Table 3).

### 4. 결과

| | Qwen3 8B 집계 | GPT-4.1 Mini 집계 | 예산 |
|---|---|---|---|
| GRPO (LoRA) | +3.68% | — | 24,000 rollout |
| MIPROv2 | +2.61% | +5.64% | — |
| TextGrad | — | +6.11% | — |
| **GEPA** | **+9.62%** | **+12.19%** | 1,839~7,051 rollout |
| GEPA+Merge | +7.17% | +13.33% | 같음 |

- 학습 신호로 쓴 train rollout만 세면 GRPO 최고 점수 도달에 **6~179회**면 됐다.
- **AIME-2025에서는 GRPO가 이겼다**(38.00 vs 32.00). 수학 추론처럼 지시문으로 옮기기 어려운 능력에서는 가중치 학습이 아직 유리할 수 있다. *(추론 — 저자들은 원인을 분석하지 않는다)*
- 결과 prompt는 MIPROv2보다 최대 9.2배 짧다. 입력 토큰 비용과 지연이 함께 준다.

### 5. 모델을 바꿔도 남는다

Qwen3 8B로 최적화한 prompt를 **GPT-4.1 Mini에 그대로** 쓰면 +9.00%다. GPT-4.1 Mini에서 직접 최적화한 다른 optimizer(+3~6%)보다 높다. 지시문이 **특정 모델의 버릇이 아니라 과제에 대한 규칙**을 담고 있기 때문으로 읽힌다. *(추론)*

이 위키에서 이 결과가 중요한 이유: [[agent-recipe]]는 누적된 판단이 **provider-agnostic**해야 한다고 주장했는데 근거가 없었다. 이것이 그 주장의 첫 정량 근거다. 다만 한 방향(약한 모델 → 강한 모델), 모델 두 개만 확인됐다.

> **전이되지 않은 prompt (2026-11-26).** 반대 사례가 있다. [[2025-12-31-recursive-language-models]]의 RLM 시스템 프롬프트는 GPT-5용으로 쓴 것을 Qwen3-Coder에 그대로 쓰자 sub-call을 남발하게 했고, 한 문장을 더해야 했다. 모순은 아니다. 방향(강→약)과 종류가 다르다. GEPA 지시문은 **과제 규칙**("이 과제에서는 X를 확인하라")이고, RLM 프롬프트에 더한 문장은 특정 모델의 버릇을 다루는 **운용 규칙**("sub-call을 너무 많이 쓰지 마라")이다. [[what-to-accumulate-outside-the-model]]의 기준(능력 가정은 썩고 과제 규칙은 남는다)과 맞는다. *(구분은 이 위키의 해석이다.)* → [[recursive-language-model]]

### 6. 보상을 뒤집으면 red-teaming이 된다

같은 엔진으로 성능을 **떨어뜨리는** 지시문을 찾게 하면, 과제 내용은 그대로 둔 채 잡담 몇 줄을 끼워 넣은 지시문 하나가 나온다. GPT-5 Mini의 AIME-2025 정답률이 76%에서 10%로 떨어졌다. 원인은 잡담과 엄격한 출력 형식 규칙의 상호작용이었다. 모델이 `### <final answer>`를 글자 그대로 출력했다.

저자들의 제안은 이런 지시문을 **재사용 가능한 stress test와 회귀 suite**로 쓰는 것이다. 모델이나 버전이 바뀔 때 robustness가 떠내려가는지 추적할 수 있다. → [[agent-evaluation]] §6

> 이 위키의 [[prompt-injection]]과는 위협 모델이 다르다. 그쪽은 **외부 공격자가 신뢰 경계를 넘는** 문제다. 이쪽은 **과제를 보존하는 사소한 교란이 성능을 무너뜨리는** 취약성이다. 같은 탐색 기법이 앞쪽 테스트에도 쓰일 수 있는지는 소스가 다루지 않는다.

## 위키 안에서의 위치

### system distillation의 prompt 부분을 자동화한 것

[[agent-recipe]]의 변환 규칙 중 *"반복 행동 → skill, prompt"* 와 *"실패 패턴 → judge, eval"* 이 있다. GEPA는 앞쪽 절반, **trace에서 교훈을 뽑아 prompt로 증류하는 단계**를 알고리즘으로 돌린다. 반성 meta-prompt의 "niche하고 domain-specific한 사실을 지시문에 넣어라"는 지시가 곧 증류다. *(추론 — GEPA 논문은 recipe라는 말을 쓰지 않는다)*

범위는 recipe보다 좁다. GEPA가 바꾸는 것은 **prompt뿐**이다. eval, skill, harness profile, memory는 손대지 않는다. 그리고 **채점 함수 µ가 이미 있어야** 돈다.

### 두 번째 루프의 signal

[[loop-engineering]]의 두 번째 루프 절은 Gavrilescu의 말을 싣는다. *"signal의 품질이 루프의 성공률을 정한다."* GEPA는 그 signal을 구체적으로 무엇으로 할지에 대한 하나의 답이다. 점수 하나가 아니라 **점수로 접히기 전의 텍스트**다. 그리고 그 signal을 몇 번 받으면 되는지에 대한 숫자를 처음으로 준다.

### 밖에 쌓기 vs 가중치에 넣기

GEPA는 trace에서 배운 것을 **창 밖의 지시문**으로 남긴다. 같은 시기 RLM 연구는 scaffold의 행동을 SFT로 **가중치에** 넣었다 ([[2025-12-31-recursive-language-models]]). 둘을 한 축에 놓은 정리는 [[context-and-memory]]에 있다. *(대비는 이 위키의 정리다.)*

### 도구 설명도 최적화 대상이다 (2026-11-27)

최적화 대상은 지시문만이 아니다. [[2025-06-13-multi-agent-research-system]]에서 결함 있는 MCP 도구를 에이전트가 수십 번 써 본 뒤 **도구 설명을 다시 쓰게** 하자, 이후 에이전트의 task 완료 시간이 40% 줄었다. trace를 보고 텍스트를 고친다는 점에서 이 페이지의 반성 루프와 같은 일이다. 다만 한 번의 재작성이고, 후보 탐색도 Pareto 선택도 없다. [[2024-12-19-building-effective-agents]]는 같은 대상을 사람이 고치는 일로 다룬다. *"tool 정의에도 전체 prompt만큼 prompt engineering을 들여라."* GEPA 같은 체계적 탐색을 도구 설명에 적용한 소스는 아직 없다. → [[tool-use]] *(대응은 이 위키의 해석이다.)*

### taste 모순과의 관계

[[loop-engineering]]의 Contradiction(*taste는 루프에 맞는가*)을 판정하지는 못한다. GEPA의 모든 실험은 **정답이 있는 과제**(exact match, F1, pass rate)다. taste처럼 채점 함수 자체가 논쟁거리인 영역은 다루지 않는다. 다만 하나는 말해 준다. **채점 함수와 텍스트 피드백이 있으면 증류는 적은 시도로 자동화된다.** 남는 질문은 여전히 "taste를 채점 함수로 쓸 수 있는가"이다. 사람이 쓴 채점 근거를 feedback_text로 넣을 수 있다는 설계는 Gavrilescu 쪽(사람은 eval을 보정한다)과 같은 방향이다.

## 한계와 읽을 때의 주의

- **자기 생태계 편향.** 주요 비교 대상 MIPROv2의 저자와 DSPy 창시자가 공저자다. 벤치마크도 같은 연구 계열에서 왔다.
- **중심 주장을 직접 검증하는 비교가 없다.** §1의 ⚠️ 참조.
- **표본이 작다.** 과제당 test 300개 수준이고 신뢰구간이 없다.
- **Merge는 불안정하다.** Qwen3 8B IFBench에서 38.61 → 28.23으로 떨어졌다.
- **에이전트가 아니라 고정된 파이프라인이다.** 실험 대상은 멀티홉 QA, 지시문 따르기, 프라이버시 위임 같은 **제어 흐름이 고정된** compound system이다. 이 위키가 주로 다루는 장기 실행 코딩 에이전트에서도 같은 효율이 나는지는 미검증이다. 커널 생성 실험이 가장 가깝지만 예비 결과다.

## Related

- [[agent-recipe]] — GEPA가 자동화하는 증류의 상위 개념. 모델 간 전이가 provider-agnostic 주장의 근거가 되는 곳
- [[loop-engineering]] — 두 번째 루프의 signal. taste 모순의 맥락
- [[agent-evaluation]] — 채점 함수가 텍스트를 함께 내야 하는 이유. adversarial 탐색으로 만드는 회귀 suite
- [[meta-harness]] — prompt가 층위 그림의 가장 빠르게 변하는 층인 이유
- [[prompt-injection]] — adversarial prompt search와 위협 모델이 다른 이웃
- [[agent-memory]] — 반성의 결과를 지시문이 아니라 episodic memory에 두는 쪽(Reflexion)
- [[context-and-memory]] — 밖에 쌓기 vs 가중치에 넣기 축. 이 페이지는 밖에 쌓는 쪽
- [[recursive-language-model]] — 모델 간에 전이되지 않은 시스템 프롬프트 사례. 과제 규칙과 운용 규칙의 구분
- [[tool-use]] — 도구 설명이라는 또 하나의 최적화 대상. prompt·가중치·인터페이스 세 층위

## Sources

- [[2025-07-25-gepa-reflective-prompt-evolution]] — Agrawal 외 16인 (UC Berkeley·Stanford·Databricks·MIT 등, ICLR 2026 Oral). 이 페이지 전체의 출처
- [[2023-03-20-reflexion]] — Shinn 외 5인 (Northeastern·MIT·Princeton, arXiv 2303.11366). 계보의 Reflexion 항목과 §1의 직접 비교 노트 (2026-11-26)
- [[2025-12-31-recursive-language-models]] — Zhang, Kraska, Khattab (MIT CSAIL, arXiv 2512.24601). "밖에 쌓기 vs 가중치에 넣기" 대비의 반대편 (2026-11-26)
- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering (2025-06-13). 도구 설명 재작성 40% 단축만 이 소스에서 왔다 (2026-11-27)
- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic, 2024-12-19). tool 정의의 prompt engineering만 이 소스에서 왔다 (2026-11-27)
