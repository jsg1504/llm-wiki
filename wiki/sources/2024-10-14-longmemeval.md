---
title: "LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory"
type: source
created: 2026-11-26
updated: 2026-11-26
source_file: ../../raw/papers/2024-10-14-longmemeval.pdf
source_url: https://arxiv.org/abs/2410.10813
author: Di Wu, Hongwei Wang, Wenhao Yu, Yuwei Zhang, Kai-Wei Chang, Dong Yu
source_date: 2024-10-14
tags: [agent-memory, long-term-memory, benchmark, knowledge-update, abstention, retrieval, memory-design, llm-as-judge, external-perspective, academic, quantitative]
status: mature
---

# LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory

> 장기 memory를 **다섯 능력**(정보 추출, 여러 세션에 걸친 추론, 시간 추론, knowledge update, abstention)으로 나눠 재는 500문항 벤치마크. 상용 memory 챗봇은 대화 원문을 그대로 읽힌 경우보다 37~64% 낮았다. memory 설계를 indexing·retrieval·reading 세 단계로 나눠 비교했고, **원문을 남기고 추출한 사실로 색인을 보강하는** 쪽이 가장 좋았다.

## Context

- **저자:** UCLA 2명(Di Wu, Kai-Wei Chang), Tencent AI Lab Seattle 3명, UC San Diego 1명. 제1저자는 Tencent 인턴십 중에 작업했다. 학계·산업 공동 연구다.
- **발행:** arXiv 2410.10813. v1 2024-10-14, v2 2025-03-04. **ICLR 2025 게재.** 본문 약 10쪽, 부록 포함 28쪽.
- **실험 모델:** GPT-4o, GPT-4o-mini, GPT-3.5-turbo(상용 시스템 안), Llama 3.1 8B/70B Instruct, Phi-3/3.5. 판정자는 gpt-4o-2024-08-06이다. Claude는 없다.
- **이 위키에서의 위치:** 장기 memory의 세 번째 정면 소스이자 첫 **측정 도구** 소스다. Anthropic을 거치지 않는다. 대신 OpenAI 제품(ChatGPT memory)을 직접 실측한다. → [[anthropic]]
- **공개:** https://github.com/xiaowu0162/LongMemEval (MIT 라이선스 예정)

## Key Claims

1. **다섯 능력과 일곱 질문 유형.**
   - **Information Extraction (IE)** — 긴 이력에서 사용자 **또는 assistant**가 말한 세부 정보를 찾는다.
   - **Multi-Session Reasoning (MR)** — 여러 세션의 정보를 모으고 비교한다.
   - **Knowledge Updates (KU)** — 사용자 정보가 바뀐 것을 알아채고 갱신한다.
   - **Temporal Reasoning (TR)** — 명시적 시간 표현과 timestamp 메타데이터로 추론한다.
   - **Abstention (ABS)** — 이력에 없는 정보를 묻는 질문에 "모른다"고 답한다. 기존 유형에서 30문항을 뽑아 거짓 전제 질문으로 바꿨다.

   기존 장기 memory 벤치마크(LoCoMo 포함)는 **assistant가 준 정보의 회상**과 **갱신된 사용자 정보 추론**을 재지 않았다.
2. **길이를 늘릴 수 있는 이력.** needle-in-a-haystack처럼, 증거 세션을 무관한 세션들 사이에 넣어 이력을 만든다. 무관한 세션은 ShareGPT 25%, UltraChat 25%, 다른 속성으로 시뮬레이션한 세션 50%다. 길이는 자유롭게 늘릴 수 있고 표준은 둘이다. **S**는 문항당 약 115k token(약 50세션), **M**은 500세션(약 1.5M token)이다. 저자들은 기존 벤치마크의 짧고 고정된 이력이 *"시스템이 계속 좋아지면서 난이도를 제한한다"* 고 지적한다.
3. **데이터 구축.** 164개 사용자 속성에서 LLM(Llama 3 70B)이 배경 문단과 질문 후보를 만들고, **사람 전문가가 모든 질문을 걸러 다시 쓴다.** 답은 증거 문장으로 나눈다. 증거는 과제 중심 대화에 **간접적으로** 섞는다("새 차를 샀다" 대신 자동차 보험을 묻다가 드러나게). 세션은 LLM이 self-chat으로 만들고 사람이 검토·수정한다. 구축에 약 400시간, 상용 시스템 실측에 약 150시간이 들었다.
4. **판정자 검증.** GPT-4o를 유형별 프롬프트로 판정자로 쓴다. 유형별 30문항, 두 생성 모델(GPT-4o, Llama 3.1 8B)에 대해 사람 전문가와 비교해 **평균 97~98% 일치**했다. preference와 abstention처럼 답이 열린 유형에서 약간 어긋났지만 모든 설정에서 90% 이상이다.
5. **상용 시스템과 긴 context LLM 모두 약하다.**
   - **상용 memory 챗봇** (사람이 웹에서 직접 대화, 97문항, 3~6세션의 짧은 이력, 2024년 8월 첫 2주):

     | 시스템 | 모델 | 정확도 |
     |---|---|---|
     | 원문 전체를 읽힘 (offline reading) | GPT-4o | 0.918 |
     | ChatGPT memory | GPT-4o | 0.577 |
     | ChatGPT memory | GPT-4o-mini | 0.711 |
     | Coze | GPT-4o | 0.330 |
     | Coze | GPT-3.5-turbo | 0.247 |

     실패 방식이 달랐다. **ChatGPT는 증거를 바로 기록하지만, 대화가 이어지며 이력을 압축할 때 그 정보를 바꿔 버렸다.** Coze는 간접적으로 나온 정보를 기록하지 못했다. 저자들은 *"신뢰할 수 있는 개인화와 효율 사이의 trade-off"* 라고 쓴다.
   - **긴 context LLM** (S, 약 115k token): 증거 세션만 준 경우(oracle) 대비 30~60% 떨어졌다. GPT-4o 0.870 → 0.606(−30%), Llama 3.1 70B 0.744 → 0.334(−55%), Llama 3.1 8B 0.710 → 0.454(−36%). Chain-of-Note를 써도 비슷했다. **70B가 8B보다 낮았다.**
6. **memory 설계의 통일된 틀.** memory를 거대한 key-value 저장소로 보고 세 단계로 나눈다. **indexing**(세션을 key-value로 바꿈) → **retrieval**(질의를 만들어 상위 k개를 가져옴) → **reading**(LLM이 읽고 답함). 조정점은 네 개다. **value**(무엇을 어떤 단위로 저장하나), **key**(무엇으로 색인하나), **query**(질의를 어떻게 만드나), **reading strategy**. 기존 시스템 9개(MemoryBank, RAPTOR, HippoRAG, ChatGPT, Coze 등)를 이 틀로 정리한다.
7. **설계 실험 결과** (주로 M, retriever는 Stella V5 1.5B, 색인용 추출은 Llama 3.1 8B):
   - **Value — round 단위가 낫다.** 세션을 한 번의 질문-응답(round)으로 쪼개면 GPT-4o reader에서 크게 좋아진다. 요약이나 사실로 압축하면 token은 아끼지만 **정보 손실로 대체로 나빠진다.** 예외는 여러 세션에 걸친 추론으로, 사실 추출이 일관되게 좋았다.
   - **Key — 원문 + 사실.** 압축한 형태(요약, keyphrase, 사실)만 key로 쓰면 나아지지 않았다. 압축한 정보를 **원문에 이어 붙여** key로 쓰면(document expansion), 특히 사용자 사실로 보강할 때 recall@k +9.4%, 최종 정확도 +5.4%였다.
   - **Query — 시간 범위로 좁힌다.** 각 항목을 그 안의 사건 날짜로도 색인하고, 질문에서 LLM이 시간 범위를 뽑아 검색을 좁힌다. 시간 추론 recall이 round 단위에서 +11.3%, 세션 단위에서 +6.8%였다. **범위를 뽑는 모델이 강해야** 효과가 있었다. Llama 3.1 8B는 예시를 많이 줘도 없는 범위를 지어내거나 놓쳤다.
   - **Reading — 완벽히 찾아도 읽기가 어렵다.** 증거만 준 oracle 설정에서도 읽는 방식이 나쁘면 GPT-4o에서 최대 10%p 떨어졌다. **Chain-of-Note**(항목마다 먼저 메모를 쓰고 그 메모로 추론)와 **JSON 형식**을 함께 쓸 때 가장 좋았다. CoN 없이는 JSON이 일관되게 낫지 않았다.
   - **읽는 모델마다 적정 분량이 다르다.** Llama 3.1 8B는 가져온 token이 3k를 넘으면 급락했고, GPT-4o는 20k를 넘어서도 계속 좋아졌다.
   - 정답을 낸 경우의 약 90%는 retrieval이 맞았다. 나머지는 대부분 knowledge update 유형이었다. 갱신된 정보는 찾았지만 **갱신 전 정보**는 못 찾은 경우다.
8. **저자들이 쓴 위험** (윤리 절). 사용자 정보를 저장하고 회상하면 개인정보가 샐 수 있다. **memory "deletion" 연산이 없으면** 시스템의 신뢰를 해친다. 악의적 사용자가 memory 저장소에 **유해 콘텐츠를 넣어** 추론 시 jailbreak를 일으킬 수 있다. 그래서 memory의 **읽기/쓰기 흐름을 감시하는 moderation**을 권한다.

## Notable Quotes / Passages

> *"Their interactive histories also typically have a non-configurable length spanning only a few thousand tokens, limiting the difficulty as current systems continue to improve."*

> *"ChatGPT generally records the evidence statements immediately after it has been presented in the evidence session. However, as the interaction proceeds, ChatGPT often modify this information when it compresses the history, resulting in information loss."* (부록 B)

> *"Surprisingly, even with perfect retrieval, a suboptimal reading strategy results in up to a 10-point absolute performance drop compared to the best approach for GPT-4o."*

> *"Storing and recalling user information could cause personal information leakage, and the lack of a memory 'deletion' operator could harm the system's trustworthiness. It is also possible that the memory mechanism could be leveraged by malicious parties to toxic contents into the datastore, which may cause a jailbreak behavior during inference."*

## Connections

- [[agent-memory]] — 세 단계·네 조정점 틀, 다섯 능력, 설계 실험 결과. memory 정책이 능력 가정이라는 세 번째 사례.
- [[meta-harness]] — ChatGPT가 이력을 압축하며 정보를 덮어쓴 것은 compaction 처방 (a)의 약점을 제품에서 잰 것이다.
- [[agent-evaluation]] — 판정자를 사람과 대조해 검증한 사례(97%). 이력 길이를 늘려 변별력을 지키는 벤치마크 설계.
- [[prompt-injection]] — 저자들이 직접 쓴 memory 저장소 오염 위험과 읽기/쓰기 감시 권고.
- [[what-to-accumulate-outside-the-model]] — 낡지 않는 eval의 설계 하나. memory 내용은 원문 + 추출한 사실로 둔다.
- [[2023-10-12-memgpt]] — MemGPT는 원본(recall storage)과 사실(working context)을 함께 둔다. 이 소스의 "원문 + 사실" 결과와 같은 방향이다.

## My Notes

- **상용 시스템 측정은 작고 낡기 쉽다.** 97문항, S보다 약 10배 짧은 3~6세션, 2024년 8월 시점이다. abstention은 재지 않았고, assistant 쪽 정보 회상과 일부 시간 추론도 제외했다. 제품은 계속 바뀐다.
- **GPT-4o-mini > GPT-4o의 원인은 단정할 수 없다.** 같은 ChatGPT라도 모델에 따라 memory 구현이 다를 수 있고, 내부는 공개되지 않았다. 모델 효과인지 시스템 효과인지 이 소스로는 가를 수 없다. *(추론)*
- **70B < 8B도 해석에 주의.** 긴 context(115k)를 읽는 설정의 결과다. 설계 실험(M + RAG)에서는 모델 크기 순서가 대체로 유지된다(Table 3). *(추론)*
- **데이터의 일부가 LLM 생성이다.** 질문은 사람이 쓰고 다듬었지만, 대화 세션은 LLM self-chat으로 만든 뒤 사람이 검토했다.
- **색인용 추출은 작은 모델(Llama 3.1 8B)로 했다.** 추출 모델이 강하면 사실 압축의 손실이 줄어 value 결론이 달라질 수 있다. 이 소스는 그것을 시험하지 않았다. *(추론)*
- **이 위키와의 대응 *(추론)*.** "원문 + 추출한 사실로 색인"은 이 위키 구조와 같다. `raw/`가 원문이고, `wiki/`의 페이지와 `index.md` 한 줄 요약이 추출한 사실 쪽 key다. 위키는 원문을 버리지 않는다.

## Raw Source

[원본 PDF](../../raw/papers/2024-10-14-longmemeval.pdf)
