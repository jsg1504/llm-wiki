---
title: "Reflexion: Language Agents with Verbal Reinforcement Learning"
type: source
created: 2026-11-26
updated: 2026-11-26
source_file: ../../raw/papers/2023-03-20-reflexion.pdf
source_url: https://arxiv.org/abs/2303.11366
author: Noah Shinn, Federico Cassano, Edward Berman, Ashwin Gopinath, Karthik Narasimhan, Shunyu Yao
source_date: 2023-03-20
tags: [verbal-reinforcement, self-reflection, episodic-memory, agent-memory, prompt-optimization, verification, self-generated-tests, external-perspective, academic, quantitative]
status: mature
---

# Reflexion: Language Agents with Verbal Reinforcement Learning

> 가중치를 바꾸지 않고 언어로 강화한다. 실패하면 LLM이 **무엇이 틀렸는지 자연어로 반성**하고, 그 반성문을 memory에 쌓아 다음 시도에 넣는다. ALFWorld +22%p, HotPotQA +20%, HumanEval pass@1 91%. 다만 성능의 상한은 **검증자**가 정하고, 반성 능력 자체는 **강한 모델에서만** 나타났다.

## Context

- **저자:** Northeastern University 3명, MIT 1명, Princeton 2명. Shunyu Yao는 실험의 Actor로 쓰인 ReAct의 저자이기도 하다.
- **발행:** arXiv 2303.11366. v1 2023-03-20, v4 2023-10-10. raw에 보관된 v4 표지는 *"Preprint. Under review."* 다. [[2025-07-25-gepa-reflective-prompt-evolution]]의 참고문헌은 이 논문을 NeurIPS 2023 게재 논문으로 인용한다. 본문 약 9쪽, 부록 포함 19쪽.
- **실험 모델:** GPT-4, gpt-3.5-turbo, text-davinci-003, GPT-3(ALFWorld), starchat-beta. Claude는 없다.
- **이 위키에서의 위치:** 위키에서 가장 오래된 소스다(2023-03). Anthropic을 거치지 않고, 이 위키의 다른 학술 소스(GEPA, MemGPT)와 달리 UC Berkeley 계열도 아니다. → [[anthropic]]
- **코드:** https://github.com/noahshinn024/reflexion

## Key Claims

1. **세 모델의 분업.**
   - **Actor** (M_a) — 상태를 보고 텍스트와 행동을 만든다. CoT나 ReAct를 쓴다.
   - **Evaluator** (M_e) — trajectory를 채점한다. 과제에 따라 exact match, 손으로 쓴 heuristic, LLM 분류, 스스로 만든 unit test를 쓴다.
   - **Self-Reflection** (M_sr) — 성공/실패 같은 희소 신호, 현재 trajectory, 기존 memory를 보고 **구체적인 자연어 피드백**을 쓴다. 저자들은 이것을 "semantic gradient"라 부른다.
2. **두 종류의 memory.** trajectory 이력은 단기 기억이고, 반성문은 장기 기억이다. Actor는 둘 다 보고 결정한다. 반성문은 **최근 Ω개(보통 1~3개)만** 남긴다. context 한계 때문이다. 코딩 과제에서는 1개다.
3. **루프.** Evaluator가 통과를 선언하거나 최대 시도 횟수에 닿을 때까지 시도 → 채점 → 반성 → memory 추가를 반복한다. **같은 과제를 다시 시도하는 루프**다.
4. **결과.**
   - **ALFWorld (순차 의사결정).** 134개 환경. ReAct + Reflexion(heuristic 평가)이 130개를 풀었다. 12번 연속 시도하며 계속 늘었다. ReAct만 쓰면 6~7회차에 멈추고 hallucination 22%에서 회복하지 못했다. 반성을 시작하는 heuristic은 *"같은 행동을 하고 같은 응답을 3회 넘게 받거나, 행동이 30개를 넘으면"* 이다.
   - **HotPotQA (추론).** 100문항. 모든 Reflexion 구성이 baseline을 크게 앞섰다. baseline은 temperature 0.7로 재시도해도 처음 틀린 문제를 하나도 풀지 못했다. **ablation:** 정답 context가 주어진 CoT에서, 최근 trajectory만 넣은 경우(episodic memory)보다 반성문을 넣은 경우가 **+8%p** 높았다.
   - **Programming.** pass@1:

     | 벤치마크 | 기존 SOTA | GPT-4 | Reflexion |
     |---|---|---|---|
     | HumanEval (Python) | 65.8 | 80.1 | **91.0** |
     | HumanEval (Rust) | – | 60.0 | 68.0 |
     | MBPP (Python) | 67.7 | **80.1** | 77.1 |
     | MBPP (Rust) | – | 70.9 | 75.4 |
     | LeetcodeHard (Python) | – | 7.5 | 15.0 |

     LeetcodeHardGym은 저자들이 만든 벤치마크다. GPT-4 학습 cutoff 이후에 공개된 hard 문제 40개다.
5. **검증자가 상한을 정한다.** 코딩 과제의 Evaluator는 **같은 모델이 만든 unit test**(최대 6개)다.
   - **false positive**(테스트는 통과했는데 실제로는 틀림)가 MBPP Python에서 **16.3%**, HumanEval Python에서 1.4%였다. MBPP에서 Reflexion이 GPT-4보다 낮은 이유가 이것이다. false positive가 나면 에이전트는 틀린 답을 일찍 제출한다.
   - 저자들은 false negative(맞는 코드인데 테스트가 실패)가 차라리 낫다고 본다. 반성 단계에서 테스트가 틀렸다고 알아채고 코드를 지킬 수 있기 때문이다.
   - **ablation (HumanEval Rust 최난도 50문제, GPT-4):**

     | 구성 | pass@1 |
     |---|---|
     | base model | 0.60 |
     | 테스트 생성 없이 반성만 | **0.52** |
     | 테스트만, 반성 없이 | 0.60 |
     | Reflexion (둘 다) | 0.68 |

     테스트 없이 반성하면 baseline보다 **나빠진다.** 지금 구현이 맞는지 판단하지 못해 일찍 멈추지 못하고 해로운 수정을 한다. 반성 없이 테스트만 돌리면 에러는 잡지만 수정에 반영되지 않는다.
6. **반성은 강한 모델의 능력이다.** starchat-beta에서는 HumanEval pass@1이 0.26 → 0.26으로 변화가 없었다. 저자들은 *"자기 수정을 지정하는 능력은 더 강하고 큰 모델의 emergent quality"* 라고 쓴다. HotPotQA에서는 text-davinci-003, gpt-3.5-turbo, gpt-4 모두 올랐다.
7. **저자들의 전망.** 약점으로 LLM의 자기 평가 능력에 기댄다는 점과 성공 보장이 없다는 점을 든다. 그러면서 *"LLM 능력이 좋아질수록 이 패러다임은 더 좋아질 것"* 이라고 쓴다. 측정이 아니라 전망이다.
8. **한계와 권고.** local minimum에 빠질 수 있다. memory는 sliding window로 제한했고, vector DB나 SQL DB로 확장하라고 권한다. 테스트 주도 방식은 비결정적 함수, 외부 API 호출, 동시성 코드에서 입출력을 정하기 어렵다. 생성된 코드는 실행 전에 검증되지 않으므로 **격리된 실행 환경**에서 돌리라고 권한다.

## Notable Quotes / Passages

> *"We propose Reflexion, a novel framework to reinforce language agents not by updating weights, but instead through linguistic feedback."*

> *"This self-reflective feedback acts as a 'semantic' gradient signal by providing the agent with a concrete direction to improve upon."*

> *"We found that the ability to specify self-corrections is an emergent quality of stronger, larger models."* (부록 A)

> *"However, as LLM capabilities improve, we only expect this paradigm to get better over time."*

> *"We highly advise others to use isolated execution environments when running autonomous code writing experiments as the generated code is not validated before execution."*

## Connections

- [[prompt-optimization]] — 계보의 앞자리. 반성문은 인스턴스 하나에 쓰이고, GEPA는 반성을 과제 규칙(지시문)으로 옮긴다. +8%p ablation은 텍스트 반성 효과의 직접 비교다.
- [[agent-memory]] — 사실이 아니라 **교훈**을 담는 episodic memory. sliding window는 "무엇을 잊는가"의 가장 단순한 답이다.
- [[agent-evaluation]] — 만든 쪽이 채점하면 생기는 문제의 정량 사례. self-generated test의 false positive 16.3%, 테스트 없는 반성의 역효과.
- [[loop-engineering]] — 같은 과제를 다시 시도하는 루프. 시스템을 고치는 두 번째 루프와 구분된다. 3회 무변화 신호의 선례.
- [[what-to-accumulate-outside-the-model]] — 모델의 강점에 올라타는 구조의 사례. 반성문 자체는 인스턴스용이라 그대로 쌓을 자산이 아니다.
- [[agent-containment]] — 생성 코드를 격리된 환경에서 돌리라는 권고.

## My Notes

- **시도 횟수가 다른 비교.** HotPotQA에서 Reflexion은 한 과제에서 연속 3회 실패할 때까지 재시도할 수 있었다. ALFWorld 곡선도 시도 횟수 축이다. pass@1은 "첫 제출"이 기준이지만 그 전에 내부 테스트로 여러 번 고친다. 그래서 단일 샘플 baseline과는 계산량이 다르다. *(추론)*
- **자기 데이터셋과 작은 표본.** LeetcodeHardGym은 40문제이고 저자들이 만들었다. HotPotQA는 100문항, Rust ablation은 50문제다.
- **2023년 모델만 실험했다.** "강한 모델일수록 반성이 잘 된다"는 관찰은 이후 모델로 갈수록 유리해지는 방향이지만, 이 소스는 그것을 측정하지 않았다.
- **GEPA와의 관계.** GEPA는 Reflexion을 "in-context self-bootstrapping" 계열로 묶고, 자신은 예시로 **과제별 규칙**을 만든다고 차별화한다 ([[2025-07-25-gepa-reflective-prompt-evolution]] 관련 연구 절).

## Raw Source

[원본 PDF](../../raw/papers/2023-03-20-reflexion.pdf)
