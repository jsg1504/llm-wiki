---
title: "Toolformer: Language Models Can Teach Themselves to Use Tools"
type: source
created: 2026-11-27
updated: 2026-11-27
source_file: ../../raw/papers/2023-02-09-toolformer.pdf
source_url: https://arxiv.org/abs/2302.04761
author: Timo Schick, Jane Dwivedi-Yu, Roberto Dessì, Roberta Raileanu, Maria Lomeli, Luke Zettlemoyer, Nicola Cancedda, Thomas Scialom
source_date: 2023-02-09
tags: [toolformer, tool-use, self-supervised, fine-tuning, api-calls, scaling, external-perspective, academic, quantitative]
status: mature
---

# Toolformer: Language Models Can Teach Themselves to Use Tools

> tool use를 **가중치에 넣는다.** 모델이 텍스트에 API 호출 후보를 스스로 끼워 넣고, 실행 결과가 다음 토큰 예측의 loss를 줄인 호출만 남겨 그 데이터로 fine-tuning한다. 6.7B GPT-J가 수학·사실 질의에서 175B GPT-3를 이겼다. 다만 도구를 연쇄하거나, 결과를 보고 다시 묻거나, 호출 비용을 따지지는 못한다.

## Context

- **저자:** Meta AI Research 7명, Universitat Pompeu Fabra 1명.
- **발행:** arXiv 2302.04761 v1, 2023-02-09. raw에 v1이 있다. 본문 약 9쪽, 부록 포함 17쪽. raw 판본에는 게재 학회 표기가 없다.
- **실험 모델:** GPT-J 6.7B를 fine-tuning했다. 규모 실험은 GPT-2 124M~1.6B. 비교 대상은 OPT 66B, GPT-3 175B(davinci, instruction tuning 이전). Claude는 없다.
- **이 위키에서의 위치:** Anthropic을 거치지 않는 학술 소스. "같은 능력을 prompt·harness 밖에 두느냐, 가중치에 넣느냐"는 위키의 축([[what-to-accumulate-outside-the-model]])에서 **가중치 쪽의 가장 이른 사례**다. → [[tool-use]]

## Key Claims

1. **목표 두 가지.** tool use를 사람의 대량 주석 없이 **self-supervised로** 배운다. 저자들은 *"사람이 유용하다고 여기는 것과 모델이 유용하다고 여기는 것이 다를 수 있다"* 고 쓴다. 그리고 모델은 일반성을 잃지 않고 **언제·어떤 도구를 쓸지 스스로 정해야** 한다.
2. **API 호출을 텍스트로 만든다.** 호출은 `[QA("…") → 답]` 처럼 텍스트 안에 끼운다. 입력·출력이 텍스트로 표현되기만 하면 어떤 도구든 된다. 어휘를 바꾸지 않으려고 `[`, `]`, `->` 를 쓴다.
3. **세 단계로 데이터를 만든다.**
   1. **Sample** — 도구마다 몇 개의 시연이 든 prompt로 모델이 텍스트에 호출 후보를 넣는다. `<API>` 확률이 임계값을 넘는 위치만 쓴다.
   2. **Execute** — 후보 호출을 실제로 실행한다.
   3. **Filter** — 호출과 결과를 앞에 붙였을 때 뒤 토큰들의 가중 loss가 "호출 없음"과 "호출은 하되 결과 없음" 중 작은 쪽보다 τ_f 이상 줄면 남긴다. **판정자는 모델 자신의 perplexity다.**

   남은 호출을 원문에 끼운 데이터셋으로 표준 LM 목적함수로 fine-tuning한다. 원문은 그대로라 일반 언어 능력이 유지된다.
4. **도구 다섯 개.** QA(Atlas), Wikipedia 검색(BM25), 계산기(사칙연산), 달력(오늘 날짜), 번역(NLLB 600M).
5. **추론 시.** `→` 토큰이 나오면 디코딩을 멈추고 API를 불러 결과를 넣고 이어 간다. 호출을 늘리려고 `<API>`가 top-k(k=10)에 들면 호출을 시작한다. **입력당 호출은 최대 1회**다. 호출만 계속하는 루프에 빠지지 않게 하려는 제한이다.
6. **결과 (zero-shot).**

   | 과제 | GPT-J | Toolformer | GPT-3 175B | 주로 쓴 도구 |
   |---|---|---|---|---|
   | LAMA T-REx | 31.9 | **53.5** | 39.8 | QA (98.1%) |
   | ASDiv | 7.5 | **40.4** | 14.0 | 계산기 (97.9%) |
   | SVAMP | 5.2 | **29.4** | 10.0 | 계산기 |
   | WebQS | 18.5 | 26.3 | **29.0** | 검색 (99.3%) |
   | TriviaQA | 43.9 | 48.8 | **65.9** | 검색 |
   | DATESET | 3.9 | **27.3** | 0.8 | 달력 (54.8%) |

   QA 과제에서는 GPT-3에 졌다. 저자들은 검색 엔진이 단순한 데다, 결과가 나쁠 때 **검색어를 고쳐 다시 묻지 못하는** 점을 원인으로 든다.
7. **언어 능력은 유지된다.** API 호출을 끈 Toolformer의 perplexity는 호출 없는 같은 데이터로 fine-tuning한 모델과 같았다(WikiText 10.3, CCNet 10.5).
8. **도구 사용은 규모에서 나타난다.** GPT-2 계열에서 도구가 도움이 되기 시작한 것은 **약 775M 파라미터**부터다. 그보다 작으면 도구가 있으나 없으나 같았다. 쉬운 Wikipedia 검색만 예외였다.
9. **보정(calibration).** k=1(일반 greedy)일 때 모델은 **도구 없이는 잘 못 풀 예시에서** 호출을 골랐다. k를 올려 호출을 늘리면 이 보정은 사라졌다.
10. **명시된 한계.**
    - 도구를 **연쇄하지 못한다.** 호출을 도구마다 따로 샘플링해서 연쇄 예시가 학습 데이터에 없다. TempLAMA에서 "달력으로 날짜를 얻고 그 날짜로 QA를 묻는" 최선의 경로를 쓰지 못했다.
    - **상호작용하지 못한다.** 검색 결과 여러 개를 훑거나 검색어를 고치지 못한다.
    - 입력 문구에 민감하다.
    - sample efficiency가 낮다. 문서 100만 개 이상을 처리해 계산기 유용 호출 수천 개를 얻었다.
    - **호출 비용을 고려하지 않는다.**

## Notable Quotes / Passages

> *"… what humans find useful may be different from what a model finds useful."*

> *"Intuitively, an API call is helpful to M if providing it with both the input and the output of this call makes it easier for the model to predict future tokens …"*

> *"One such limitation is the inability of Toolformer to use tools in a chain (i.e., using the output of one tool as an input for another tool)."*

## Connections

- [[tool-use]] — 세 층위(prompt·가중치·인터페이스) 중 **가중치** 층의 대표.
- [[2022-10-06-react]] — 같은 해의 반대 방향. ReAct는 도구를 prompt로 쓰게 하고 루프 안에서 다시 묻는다. Toolformer가 한계로 적은 연쇄와 상호작용이 ReAct 루프에서는 기본이다.
- [[agent-loop]] — 입력당 호출 1회 제한은 "루프 없는 tool use"다. 루프가 무엇을 더하는지 보여 주는 대조군이다. *(대조는 이 위키의 해석이다.)*
- [[what-to-accumulate-outside-the-model]] — "밖에 쌓기 vs 가중치에 넣기" 축의 가중치 쪽 사례.
- [[recursive-language-model]] — RLM 저자들이 scaffold를 학습으로 모델에 넣은 것과 같은 방향이다.
- [[agent-evaluation]] — 모델 자신의 loss를 유용성 판정자로 쓴다. 사람 라벨도 외부 judge도 아니다.

## My Notes

- **한계 목록이 이후 에이전트의 요구사항 목록이다.** 연쇄, 상호작용(다시 묻기), 비용 고려는 2024년 이후 native function calling과 agent loop가 기본으로 제공하는 것들이다. *(이후 발전에 대한 서술은 이 위키의 정리이고, 이 소스의 주장이 아니다.)*
- 수치(GPT-J, GPT-3 davinci)는 낡았다. 남는 것은 "모델이 유용성을 스스로 판정한다"는 필터 원리와 "도구 사용 능력에는 규모 문턱이 있다"는 관찰이다. 후자는 [[meta-harness]]의 "harness는 능력 가정의 집합"과 같은 질문을 낳는다. 문턱 아래 모델에게 도구를 주는 harness는 쓸모없는 가정이다.

## Raw Source

[원본 PDF](../../raw/papers/2023-02-09-toolformer.pdf)
