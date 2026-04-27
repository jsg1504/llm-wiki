---
title: ChatDev
type: entity
created: 2026-04-28
updated: 2026-04-28
sources: [2307.07924-chatdev]
tags: [framework, multi-agent, code-generation, chat-chain]
status: draft
---

# ChatDev

> 워터폴 모델을 "chat chain" dialogue 그래프로 재구성한 LLM 멀티에이전트 소프트웨어 개발 프레임워크. 5개 역할(CEO/CTO/programmer/reviewer/tester) × 3 phase(Design/Coding/Testing). [[metagpt]]와 동시대·경쟁 관계.

## Overview

- **종류**: 오픈소스 프레임워크 (Python).
- **소속**: Tsinghua University 주도 (Chen Qian 1저자, Maosong Sun 교신), ModelBest Inc · USyd · BUPT 공동.
- **공개**: github.com/OpenBMB/ChatDev.
- **대표 논문**: [[2307.07924-chatdev|ChatDev (Qian et al., 2024)]].

## 핵심 설계 요소

### 1. Chat Chain (𝓒)
워터폴 phase를 sequential chain으로 정의:
```
𝓒 = ⟨𝓟¹, 𝓟², …, 𝓟^|𝓒|⟩
𝓟ⁱ = ⟨𝓣¹, 𝓣², …⟩
𝓣 = τ(𝓒(𝓘, 𝓐))
```
- **3 phase**: Design / Coding (coding + code complete subtask) / Testing (code review + system testing subtask).
- 각 subtask는 두 에이전트(Instructor 𝓘, Assistant 𝓐) 사이의 다중 턴 대화로 풀린다. 합의 도달 또는 10라운드/2번 연속 무변경 코드에서 종료.
- 5 역할: CEO (요구 분석), CTO (디자인/코딩 지시), programmer (코드 작성), reviewer (정적 리뷰), tester (실행 테스트).

### 2. Communicative Dehallucination (CDH)
일반 패턴: `⟨𝓘 → 𝓐, 𝓐 ⤳ 𝓘⟩↻`
CDH 패턴: assistant가 답하기 전에 먼저 instructor에게 더 구체적인 정보를 **요청**한다 (역할 반전):
```
⟨𝓘 → 𝓐,  ⟨𝓐 → 𝓘, 𝓘 ⤳ 𝓐⟩↻,  𝓐 ⤳ 𝓘⟩↻
```
ablation: CDH 제거 시 4개 metric 모두 하락. coding hallucination 감소가 핵심 모티베이션.

### 3. 이중 메모리
- **Short-term**: 같은 phase 내 utterance를 누적 (`𝓜ᵢ_t = ⟨(𝓘ᵢ₁, 𝓐ᵢ₁), …, (𝓘ᵢ_t, 𝓐ᵢ_t)⟩`).
- **Long-term**: phase 간에는 *솔루션만* 다음 phase의 시작 프롬프트에 합쳐서 전달. 전체 대화 history는 buang. → context window 폭증과 정보 과부하 동시 차단.

### 4. Inception Prompting
양쪽 에이전트의 system prompt P_I, P_A는 거의 대칭으로 작성. subtask overview, 역할 정의, 가용 외부 도구, 통신 프로토콜, 종료 조건, 안티 행동(role flipping, instruction repeating, fake replies) 명시. `𝓘 = ρ(LLM, P_I)`, `𝓐 = ρ(LLM, P_A)`.

## 자체 벤치 (SRDD)
- 1,200 task prompt, 5 카테고리 × 40 subcategory × 30 prompt.
- 평가 metric: Completeness · Executability · Consistency (요구-코드 임베딩 cosine) · Quality (셋의 곱).
- 평가: GPT-3.5, temp 0.2, Python 3.11.4.

## 성능 (자체 벤치 기준)

| Method | Completeness | Executability | Consistency | Quality |
|---|---|---|---|---|
| GPT-Engineer | 0.5022 | 0.3583 | 0.7887 | 0.1419 |
| MetaGPT | 0.4834 | 0.4145 | 0.7601 | 0.1523 |
| **ChatDev** | **0.5600** | **0.8800** | **0.8021** | **0.3953** |

## ⚠️ vs [[metagpt]] — 두 논문이 서로를 이긴다고 주장

[[2308.00352-metagpt]]는 자체 SoftwareDev 벤치(70-task)에서 **MetaGPT(3.75/4) > ChatDev(2.25/4)** 라고 보고. ChatDev 논문은 SRDD에서 정반대. 자세한 분석: [[contradictions]].

## 디자인 철학 비교

| 축 | [[metagpt]] | [[chatdev]] |
|---|---|---|
| 통신 매개체 | 구조화 문서 (PRD, 설계서, 다이어그램) | 다중 턴 dialogue + 솔루션 결과물 |
| 통신 토폴로지 | shared message pool + role 기반 subscription | sequential chain, 각 subtask = 이중 에이전트 대화 |
| Hallucination 대응 | executable feedback loop (Engineer가 코드 실행 후 디버그, 최대 3 retry) | communicative dehallucination (역할 반전 clarify) |
| 핵심 비유 | "assembly line" / 어셈블리 라인 | "communicative agents" / 워터폴-as-chain |

## Related

- [[metagpt]] — 동시대 경쟁 프레임워크. 디자인 철학 정반대 (구조화 문서 vs dialogue).
- [[sop-for-llm-agents]] — ChatDev의 chat chain은 SOP의 약한 형태(dialogue-based) 변형.
- [[llm-multi-agent-frameworks]] — 비교 hub.
- [[contradictions]] — MetaGPT와의 cross-evaluation 모순.

## Sources

- [[2307.07924-chatdev|ChatDev (Qian et al., 2024)]]
