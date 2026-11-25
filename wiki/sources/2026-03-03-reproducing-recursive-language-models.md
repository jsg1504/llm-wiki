---
title: "Think, But Don't Overthink: Reproducing Recursive Language Models"
type: source
created: 2026-11-26
updated: 2026-11-26
source_file: ../../raw/papers/2026-03-03-reproducing-recursive-language-models.pdf
source_url: https://arxiv.org/abs/2603.02615
author: Daren Wang
source_date: 2026-03-03
tags: [recursive-language-model, reproduction, long-context, recursion-depth, overthinking, latency, failure-modes, external-perspective, academic, quantitative]
status: mature
---

# Think, But Don't Overthink: Reproducing Recursive Language Models

> RLM을 오픈 모델 둘(DeepSeek v3.2, Kimi K2)로 재현하고 recursion depth=2를 처음 시험했다. **실패 쪽은 재현됐고, 이득 쪽은 확인되지 않았다.** 단순 검색과 이미 long-context에 강한 모델에서는 RLM이 정확도를 떨어뜨렸다. depth=2는 모든 조건에서 나빠졌고, 지연은 한 문항에 3.6초에서 344초까지 늘었다.

## Context

- **저자:** Daren Wang (The Chinese University of Hong Kong), 단독 저자. 과제 보고서 형식이다(환경 설정, API 키 관리, 디버그 일지 부록).
- **발행:** arXiv 2603.02615 v1, 2026-03-03. 본문 6쪽 + 부록. **동료 심사 없음.**
- **코드:** https://github.com/drbillwang/rlm-reproduction. 원 저자의 `rlm` 라이브러리를 그대로 쓰고, 파서를 일부 고쳤다.
- **재현 대상:** [[2025-12-31-recursive-language-models]]의 S-NIAH와 OOLONG(trec_coarse) 실험. 원 논문 v1을 인용한다.
- **이 위키에서의 위치:** 원 저자 그룹과 독립인 **첫 재현 소스**. 원 논문이 "더 깊은 재귀는 향후 과제"로 남긴 depth=2를 직접 잰다.

## Key Claims

1. **설정이 원 논문과 다르다.**
   - 모델: DeepSeek v3.2(`deepseek-chat` API), Kimi K2(Volcano Engine API). 원 논문은 GPT-5, Qwen3-Coder-480B.
   - 표본: 조건당 **20문항, 1회 실행**. 원 논문은 S-NIAH·OOLONG 각 50문항.
   - OOLONG context 길이를 **1,024~65,536 token**으로 제한했다. 원 논문은 RLM의 우위를 주로 2¹⁴(약 16k) token 이상에서 주장했다.
   - 원 논문의 표에는 없는 **depth=2**를 추가했다.
2. **단순 검색에서 RLM이 오히려 나빴다 (S-NIAH).** base는 두 모델 모두 100%. RLM depth=1은 DeepSeek 85%, Kimi 90%, depth=2는 DeepSeek 70%. 저자는 단순한 문자열 찾기에 REPL을 강제하면 모델이 해법을 "over-engineer"한다고 해석한다.
3. **OOLONG 결과는 모델에 따라 반대였다.**

   | 모델 | base | RLM depth=1 | RLM depth=2 |
   |---|---|---|---|
   | DeepSeek v3.2 | 0.0 | 42.1 | 33.7 |
   | Kimi K2 | **86.6** | 60.0 | 55.0 |

   저자는 DeepSeek의 0.0 → 42.1을 원 논문의 Qwen3-8B 이득(0.0 → 24.0)과 같은 현상, 즉 핵심 결과의 재현으로 본다. Kimi K2는 base가 이미 강해서 scaffold가 성능을 끌어내렸다.
4. **depth=2는 모든 조건에서 나빠졌다.** 저자는 이를 "overthinking"이라 부른다. sub-RLM이 자기 sub-call을 다시 띄우면서 형식 오류가 누적되고, 중복 루프가 돌고, 과제를 실패한다.
5. **실패 모드 셋 (Figure 5, 로그 분석).**
   - **Context anchoring 상실 (parametric hallucination).** DeepSeek, S-NIAH depth=2. 텍스트에 숨긴 가상의 "special magic number"를 찾으라 하자, 입력을 버리고 **핵물리의 magic number(2, 8, 20, 28, 50, 82, 126)**를 사전지식으로 답했다.
   - **REPL과 최종 출력의 혼동.** Kimi, OOLONG depth=1. 형식에 맞춘 답 대신 `print(f"Answer: {abbreviation_count}")` 같은 Python 코드를 답으로 반환했다.
   - **끝없는 재검증 (performative reasoning).** DeepSeek, OOLONG depth=2. 한 문항에 741초를 쓰면서 token은 11,715개만 냈다. 이미 뽑은 답을 다시 확인하는 sub-call을 계속 띄웠다. 저자: *"The REPL architecture inherently lacks a stopping mechanism for an over-anxious agent."*
6. **지연과 비용이 실무 장벽이다.** DeepSeek의 S-NIAH 평균 시간은 base 3.6초 → depth=1 89.3초 → depth=2 344.5초. Kimi는 depth=2에서 문항당 545.5초. RLM을 켜는 순간 token과 API 비용이 자릿수 단위로 늘었다(그림만 있고 표는 없다). depth=1 → 2에서 token이 오히려 줄기도 했는데(DeepSeek S-NIAH 25.2k → 20.1k), 저자는 형식 실패로 일찍 끝나거나 고립된 루프에 갇힌 탓으로 본다.
7. **결론.** depth=1은 복잡한 추론을 돕지만, 단순 과제나 이미 강한 모델에는 해롭다. depth=2는 현재 모델을 망가뜨린다. 저자는 REPL 안의 정지 장치와 native RLM 학습을 처방으로 든다. 원 논문의 처방과 같다.

## Notable Quotes / Passages

> *"While depth-1 RLMs effectively boost accuracy on complex reasoning tasks, applying deeper recursion (depth=2) or using RLMs on simple retrieval tasks paradoxically degrades performance and exponentially inflates execution time."*

> *"The massive latency penalties, exploding API costs, and high risk of recursive degradation (overthinking) currently outweigh the theoretical reasoning benefits, especially when modern frontier models (like Kimi K2) can natively handle vast contexts at a fraction of the time and cost."*

부록 A.3 (디버그 일지):

> *"An early OOLONG run showed 0/20 accuracy (DeepSeek v3.2 Base LLM). Upon inspection, the model had successfully found the answers but produced long narrative explanations instead of the expected strict formats (e.g., "Answer: number")."*

## Connections

- [[recursive-language-model]] — 이 소스가 보강하는 concept. 외부 재현 절과 ⚠️ Contradiction의 한쪽.
- [[2025-12-31-recursive-language-models]] — 재현 대상. 부록 B의 실패(FINAL 태그 불안정, thinking 모델 문제, 깊이에 따른 오류 전파)가 다른 모델 둘에서 다시 나왔다.
- [[meta-harness]] — Kimi K2 사례. 학습 안 된 scaffold가 이미 강한 모델에서 짐이 된다.
- [[anthropic]] — 소스 다양성 기록. Anthropic도, 원 저자 그룹도 거치지 않는다.

## My Notes

- **이득의 재현은 확인되지 않았다.** 재현의 근거로 든 수치는 DeepSeek OOLONG 0.0 → 42.1 하나다. 그런데 부록 A.3에서 저자 스스로 base의 0%는 **답을 찾고도 형식을 어긴 결과**라고 적는다. 그러면 이 차이가 보여주는 것은 "RLM scaffold가 출력 형식을 맞추게 했다"까지다. "long-context 추론이 좋아졌다"는 이 수치로 가를 수 없다. 저자는 이 0%를 *"formatting failures under recursive abstraction"* 이라 쓰지만, 해당 실행은 재귀가 없는 base LLM이었다. 본문과 부록이 어긋난다.
- **실패의 재현은 확인됐다.** 원 논문 부록 B가 적은 실패가 다른 모델 둘에서 독립적으로 나왔다. 최종 답과 생각을 가르는 태그가 불안정했고(Kimi의 print문 반환), thinking 모델이 파서를 깼고(Kimi의 `<thinking>` 태그 때문에 저자가 `strip_think_tags()`를 직접 추가), 깊은 재귀에서 오류가 번졌고, 꼬리 비용이 컸다. 이 재현의 실제 기여는 이쪽이다.
- **양쪽 수치 모두 형식과 능력이 섞여 있다.** S-NIAH의 RLM 하락에도 "REPL과 최종 출력의 혼동"이 섞였을 수 있다. 이 위키는 base 0%만 의심하지 않고, 이 소스의 모든 수치를 "능력 + 형식" 합산으로 읽는다.
- **원 논문과 정면으로 겹치는 구간이 좁다.** context를 64k 이하로 제한했으므로, 원 논문이 RLM 우위를 주장한 긴 구간(수십만~수백만 token)은 재지 않았다. Kimi K2의 하락이 원 논문의 "2¹⁴ token 이상에서 RLM이 일관되게 이긴다"와 겹치는 것은 16k~64k 구간뿐이다.
- **표본이 매우 작다.** 조건당 20문항, 1회 실행, 분산과 유의성 검정이 없다. 저자는 효과 크기가 커서 결론이 견고하다고 쓰지만, 20문항에서 85%와 100%는 3문항 차이다.
- **depth 결과는 원 논문과 일치한다.** 원 논문에서도 Qwen3-Coder는 깊이가 늘면 평균이 나빠졌고, 깊이가 이득이었던 것은 GPT-5뿐이었다. 이 소스는 그것을 다른 모델 둘에서 확인한다. 모순이 아니다.
- **부록 A.2의 작은 발견:** OOLONG trec_coarse는 `test`가 아니라 `validation` split에 있다. 원 논문의 설명과 다르다고 저자가 적는다.

## Raw Source

[원본 PDF](../../raw/papers/2026-03-03-reproducing-recursive-language-models.pdf)
