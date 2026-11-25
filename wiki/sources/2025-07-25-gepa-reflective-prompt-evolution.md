---
title: "GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning"
type: source
created: 2026-11-25
updated: 2026-11-25
source_file: ../../raw/papers/2025-07-25-gepa-reflective-prompt-evolution.pdf
source_url: https://arxiv.org/abs/2507.19457
author: Lakshya A Agrawal, Shangyin Tan, Dilara Soylu, Noah Ziems, Rishi Khare, Krista Opsahl-Ong, Arnav Singhvi, Herumb Shandilya, Michael J Ryan, Meng Jiang, Christopher Potts, Koushik Sen, Alexandros G. Dimakis, Ion Stoica, Dan Klein, Matei Zaharia, Omar Khattab
source_date: 2025-07-25
tags: [prompt-optimization, gepa, reflection, compound-ai-systems, evolutionary-search, pareto, reinforcement-learning, grpo, dspy, red-teaming, external-perspective, academic, quantitative]
status: mature
---

# GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning

> LLM 시스템의 실행 trace와 채점 과정의 텍스트를 LLM이 **자연어로 반성**해 prompt를 고치고, 과제별 최고 후보들(Pareto frontier)에서 진화를 이어가면 **가중치 RL(GRPO)보다 최대 35배 적은 rollout으로 평균 6%, 최대 20% 더 좋은 결과**가 나온다. 언어 자체가 스칼라 보상보다 풍부한 학습 매체라는 주장이다.

## Context

- **저자:** UC Berkeley, Stanford, Notre Dame, Databricks, MIT, BespokeLabs.ai 소속 17명. 교신 계열에 Matei Zaharia, Ion Stoica, Omar Khattab(DSPy 창시자)가 있다.
- **발행:** arXiv 2507.19457. v1 2025-07-25, v2 2026-02-14. **ICLR 2026 Oral.** 본문 약 12쪽, 부록 포함 96쪽.
- **이 위키에서의 위치:** **최초의 동료 심사 학술 소스이자 최초의 대규모 정량 소스.** Anthropic을 발행처로도, 인용 경로로도 거치지 않는다. 실험 모델도 Claude가 아니라 Qwen3 8B, GPT-4.1 Mini, GPT-4o, GPT-5 Mini다. → [[anthropic]]
- **코드:** https://github.com/gepa-ai/gepa 로 공개. DSPy 생태계에 통합돼 있다.

## Key Claims

1. **언어는 스칼라 보상보다 풍부한 학습 매체다.** 아무리 복잡한 LLM 시스템도 rollout은 자연어 trace로 직렬화된다. 각 모듈의 지시문, reasoning, tool call, 그리고 보상 함수의 내부 작동(점수로 접히기 전의 컴파일러 에러 같은 것)이다. LLM은 이걸 읽을 수 있으므로, 반성으로 배우는 알고리즘이 policy gradient보다 언어 사전지식을 잘 쓴다.
2. **세 원리: 유전적 진화, 자연어 반성, Pareto 선택.**
   - **Reflective mutation:** 후보 하나를 minibatch에 돌려 trace와 피드백을 모은다. reflection LM이 (현재 prompt, trace, 점수, 피드백)을 보고 성패를 prompt 요소에 귀속시킨 뒤 새 지시문을 쓴다. minibatch에서 나아졌을 때만 pool에 넣는다. 이것이 LLM에 의한 **암묵적 credit assignment**다.
   - **Feedback function µf:** 보상 µ를 확장해 점수와 함께 **feedback_text**를 돌려준다. 컴파일러 에러, 통과 못 한 루브릭, 멀티홉에서 아직 못 찾은 문서 목록 등이다. **사람이 쓴 채점 근거**도 여기에 넣을 수 있다.
   - **Pareto 기반 후보 선택:** 항상 최고 후보만 고치면 국소 최적에 갇힌다. GEPA는 **인스턴스마다** 최고 점수를 낸 후보들을 남기고, 지배당한 후보는 버리고, 각 후보가 이긴 인스턴스 수에 비례해 확률적으로 고른다.
   - **Merge(선택):** 공통 조상에서 갈라져 **서로 다른 모듈**을 개선한 두 계통을 합친다.
3. **RL보다 표본 효율이 높다 (Qwen3 8B, 6과제).** GEPA 집계 +9.62%, GRPO(24,000 rollout, LoRA) +3.68%, MIPROv2 +2.61%. GEPA 예산은 과제별 1,839~7,051 rollout이다. GRPO 최고 validation 점수에 도달하는 데 243~1,179 rollout이면 됐고, **학습 신호로 쓴 train rollout만 세면 6~179회**였다. 예산 대부분은 후보 선택용 validation에 쓰인다. **예외:** AIME-2025에서는 GRPO가 이겼다(38.00 vs 32.00).
4. **기존 prompt optimizer를 넘는다 (GPT-4.1 Mini).** GEPA +12.19%, GEPA+Merge +13.33%. TextGrad +6.11%, MIPROv2 +5.64%, Trace +3.27%. **지시문만 최적화해도 지시문+few-shot 공동 최적화를 이긴다.** 저자들은 최근 LLM의 지시문 따르기와 자기 반성 능력 향상 덕으로 본다.
5. **Pareto 선택의 효과가 크다.** 같은 진화 harness에서 선택 전략만 바꾸면 Pareto +12.44%, 최고 후보만(SelectBestCandidate, TextGrad 방식) +6.05%, BeamSearch(APO 방식) +5.11%다.
6. **모델 간 전이.** Qwen3 8B로 최적화한 prompt를 GPT-4.1 Mini에 수정 없이 쓰면 +9.00%다. GPT-4.1 Mini에서 직접 최적화한 MIPROv2, TextGrad, Trace보다 높다.
7. **결과 prompt가 짧고 선언적이다.** MIPROv2보다 최대 9.2배 짧고 평균 약 33% 짧다. 예시 대신 **과제별 규칙과 교훈**을 서술한다("Key Observations and Lessons" 같은 절이 생긴다). 집계상 성능이 좋은 optimizer일수록 prompt가 짧은 경향이 있다.
8. **확장 응용 (예비 결과).** 추론 시점 탐색: 풀 과제 집합을 train과 Pareto set 양쪽에 넣어 "과적합"시킨다. AMD NPU 커널은 평균 vector utilization 4.25% → 30.52%, CUDA 커널(KernelBench 35과제)은 fast1 ≈0% → 20% 이상이다. 커널 실험에서는 컴파일러 에러로 기술 매뉴얼을 검색해 피드백에 넣는다.
9. **Adversarial prompt search.** 보상을 뒤집어, 과제 내용을 보존하는 잡담(trivia) 지시문 하나를 찾았다. GPT-5 Mini의 AIME-2025 pass@1을 **76% → 10%**로 떨어뜨렸다. 원인은 잡담과 엄격한 출력 형식 규칙의 상호작용이었다(모델이 `### <final answer>`를 글자 그대로 출력). 저자들은 이를 **재사용 가능한 stress test와 회귀 suite**로 쓰자고 제안한다.

## Notable Quotes / Passages

> *"We argue that the interpretable nature of language often provides a much richer learning medium for LLMs, compared to policy gradients derived from sparse, scalar rewards."*

> *"Candidates are derived from existing ones via reflective mutation or crossover, guided by feedback from rollouts, with each inheriting learning signals from its parents and its own rollout so that GEPA accumulates knowledge along the genetic tree."*

반성 meta-prompt (부록 C, 발췌):

> *"Identify all niche and domain specific factual information about the task and include it in the instruction, as a lot of it may not be available to the assistant in the future. The assistant may have utilized a generalizable strategy to solve the task, if so, include that in the instruction as well."*

## Connections

- [[prompt-optimization]] — 이 소스가 만든 concept 페이지. GEPA를 MIPROv2, TextGrad, DSPy 계열 안에 놓는다.
- [[agent-recipe]] — GEPA는 system distillation의 **prompt 부분을 자동화한 것**으로 읽힌다. 모델 간 전이는 recipe의 provider-agnostic 주장에 대한 첫 정량 근거다. 동시에 "AI 시스템에는 recipe 같은 그릇이 없다"는 그 페이지의 진술을 부분적으로 반박한다.
- [[loop-engineering]] — 두 번째 루프의 *"signal 품질이 성공률을 정한다"* 에 대한 메커니즘 수준 근거. feedback_text가 그 signal이다.
- [[agent-evaluation]] — 채점 함수를 점수만 내는 것에서 텍스트도 내는 것으로 넓힌다. adversarial 탐색이 회귀 suite를 만든다.
- [[meta-harness]] — 층위 그림의 가장 빠르게 변하는 층(prompt)을 자동으로 최적화한다.
- [[anthropic]] — 소스 다양성 기록.

## My Notes

- **자기 생태계 편향.** 핵심 비교 대상 MIPROv2의 저자(Opsahl-Ong)와 DSPy 창시자(Khattab)가 공저자다. 벤치마크 대부분도 같은 연구 계열(Tan et al. 2025)에서 가져왔다. GEPA는 공개 라이브러리이기도 하다. 벤더 편향은 아니지만 **자기 도구 편향**이다.
- **핵심 주장을 직접 검증하는 비교가 없다.** "텍스트 피드백이 스칼라보다 풍부하다"가 논문의 중심 주장인데, 본문에는 feedback_text를 끄고 돌린 비교가 없다. GRPO 비교는 prompt 공간과 가중치 공간이라는 **다른 파라미터 공간**끼리의 비교다. 선택 전략 비교(Table 3)는 harness를 고정해 비교했지만, 그건 Pareto의 효과를 보여줄 뿐이다.
- **표본이 작다.** 과제당 train 150, validation 300, test 300 수준이다(HotpotQA 기준). 신뢰구간은 보고되지 않는다.
- **rollout 수가 비용 전부는 아니다.** reflection LM 호출(과제당 17~92회)은 rollout에 안 들어간다. 다만 그 수 자체는 작다.
- **Merge는 불안정하다.** Qwen3 8B에서 IFBench가 38.61 → 28.23으로 떨어졌다. 저자들은 하이퍼파라미터를 두 모델에 똑같이 둔 탓으로 본다.
- **전이는 한 방향, 두 모델이다.** 약한 모델 → 강한 모델(Qwen3 8B → GPT-4.1 Mini)만 보고됐다. 반대 방향이나 다른 계열(Claude 등)은 없다.
- **커널과 adversarial 실험은 저자 스스로 "preliminary"라고 한다.** adversarial 결과는 모델 하나, 30문제다.

## Raw Source

[원본 PDF](../../raw/papers/2025-07-25-gepa-reflective-prompt-evolution.pdf)
