---
title: Agent Recipe / System Distillation
aliases: [system-distillation, System Distillation]
type: concept
created: 2026-09-30
updated: 2026-11-26
sources: [2026-09-30-loop-is-the-product, 2025-07-25-gepa-reflective-prompt-evolution]
tags: [agent-recipe, system-distillation, loop-engineering, evaluation, taste, versioning, provider-agnostic, prompt-optimization]
status: draft
---

# Agent Recipe / System Distillation

> **System distillation은 과정이고 agent recipe는 그 결과물이다.** 루프가 돌 때마다 나오는 교훈(실패 패턴, 반복 행동, 사용자 불만)을 eval·skill·prompt·harness 설정으로 증류해 git에 버전 관리한 묶음이 recipe다. 모델이나 제공자가 아니라 *"어떻게 이 시스템에 도달했고 왜 그런가"* 를 재현 가능하게 만든다. 제안자는 이것을 **해자(moat)**라 부른다.

## Overview

RL 연구에는 **data recipe**가 있다. 연구자는 recipe를 계속 고쳐 환각이나 reward hacking 같은 행동에 대응하고, 마지막에 남는 것이 최종 recipe다. [[2026-09-30-loop-is-the-product]]의 주장은 **harness와 AI 시스템 일반에는 이런 것이 없다**는 것이다. eval, 튜닝, 사람의 판단처럼 처음부터 정해지지 않고 에이전트가 환경에서 행동하는 걸 보며 알게 되는 것들을 담을 그릇이 없다.

agent recipe는 그 그릇이다. 이 과정 전체를 **system distillation**이라 부른다.

> ⚠️ **"그릇이 없다"는 부분적으로만 맞다 (2026-11-25).** AI 시스템의 prompt를 trace에서 증류하는 방법은 이미 있다. DSPy 계열 optimizer가 있고, [[2025-07-25-gepa-reflective-prompt-evolution]](GEPA, 2025-07)은 실행 trace와 채점 텍스트를 반성해 prompt에 교훈을 누적한다. ICLR 2026 Oral이고 코드도 공개돼 있다. → [[prompt-optimization]]
>
> 양쪽 주장을 보존한다. **Gavrilescu의 진술:** harness와 AI 시스템에는 data recipe에 해당하는 것이 없다. **GEPA가 보여주는 것:** 적어도 **prompt 층**에는 있고, 정량적으로 작동한다.
>
> **화해할 수 있는 범위:** recipe는 eval, skill, harness profile, memory까지 **하나의 버전 관리 단위로** 묶는 것이고, GEPA는 그중 prompt 하나만 다룬다. "부품을 자동으로 증류하는 방법은 있다. 그것들을 묶는 그릇은 없다"로 읽으면 두 주장이 같이 선다. 소스는 GEPA나 DSPy를 언급하지 않는다. *(화해는 이 위키의 해석이다)*

## Key Points

### 무엇이 무엇으로 증류되는가

루프 하나가 끝나면 harness, profile, eval, model, resource, tool, environment에 관한 정보가 나온다. 변환 규칙:

| 루프에서 관측된 것 | recipe에 들어가는 형태 |
|---|---|
| 실패 패턴 | judge, eval |
| 반복 행동 | skill, prompt |
| 사용자 불만 | harness 확장, memory |

위키에 이미 있는 부품들이다. [[loop-engineering]]의 "검증을 skill로 코드화한다", [[agent-evaluation]]의 LLM-as-judge, [[claude-code]]의 skill과 CLAUDE.md가 그렇다. **새로운 것은 부품이 아니라 묶음 단위다.** 이들을 흩어진 설정이 아니라 **하나의 버전 관리되는 산출물**로 보고, 루프의 목적을 그 산출물을 개선하는 것으로 정의한다.

> *"Loops should focus on this. Loops should be the way you distill these systems into recipes."*

### 증류 한 단계를 자동화한 사례: GEPA (2026-11-25)

위 표의 *"반복 행동 → prompt"* 칸은 손으로 할 필요가 없다. [[2025-07-25-gepa-reflective-prompt-evolution]]의 GEPA가 그 단계를 알고리즘으로 돌린다. *(대응은 이 위키의 해석이다. GEPA 논문은 recipe라는 말을 쓰지 않는다.)*

- **입력:** 시스템을 몇 번 돌린 trace와, 채점 함수가 점수와 함께 돌려주는 텍스트(컴파일러 에러, 실패한 루브릭, 사람이 쓴 채점 근거).
- **증류:** reflection LM이 성패를 모듈에 귀속시키고 교훈을 지시문에 쓴다. meta-prompt의 지시는 *"niche하고 domain-specific한 사실을 찾아 지시문에 넣어라. 앞으로 assistant가 그걸 다시 볼 수 없을 테니."* 다. 결과 prompt에 "Key Observations and Lessons" 절이 생긴다.
- **누적:** 자식 후보가 부모의 교훈을 물려받는다. 과제별 최고 후보들(Pareto frontier)을 남겨 한 전략에 갇히지 않는다.
- **비용:** 학습 신호로 쓴 train rollout 6~179회로 GRPO(24,000 rollout) 최고 점수에 도달했다.

이 위키에서 recipe 개념에 붙은 **첫 정량 근거**다. 동시에 범위의 차이도 분명하다. GEPA는 **prompt만** 바꾸고, **채점 함수가 이미 있어야** 돈다. recipe의 다른 부품(eval 자체, skill, harness profile)을 만들지는 않는다. → [[prompt-optimization]]

### 세 가지 속성

- **Provider-agnostic.** 특정 플랫폼이나 모델에 묶이지 않는다. 모델별로 다른 harness profile을 recipe 안에 둔다.
  > **부분 근거 (2026-11-25).** 소스는 이 속성을 주장만 했다. [[2025-07-25-gepa-reflective-prompt-evolution]]에 정량 근거가 하나 있다. Qwen3 8B로 증류한 prompt를 GPT-4.1 Mini에 **수정 없이** 쓰면 +9.00%다. GPT-4.1 Mini에서 직접 최적화한 다른 방법들(+3~6%)보다 높다. trace에서 증류한 교훈이 특정 모델의 버릇이 아니라 **과제에 대한 규칙**이라는 뜻으로 읽힌다. **한계:** 약한 모델 → 강한 모델 한 방향, 모델 두 개, prompt 하나뿐이다. 반대 방향, Claude 계열, harness profile 같은 다른 부품의 전이는 근거가 없다.
- **Versioned.** git repo에 산다. 에이전트가 무엇이 왜 바뀌었는지 추적할 수 있다.
- **Owned by you, managed by agents.** 사람은 taste를 가진 "방 안의 상위 인격"이고, 에이전트는 그 taste에 스스로를 보정한다.

### recipe는 taste를 싣는다

recipe의 핵심 내용물은 **제작자의 taste**다. 남의 recipe를 받아 쓰면 그 사람의 판단 기준도 함께 온다. 그래서 recipe를 개선하는 절차는 [[agent-evaluation]]의 **taste-as-eval 절차**와 같다. 순서는 trace 패턴 → judge 보정(HITL) → recipe 후보 → offline eval → 프로덕션 A/B → promote이다.

### 위키의 다른 "오래 사는 것"과의 대비

| | 무엇을 고정/누적하는가 | 무엇에 대한 방어인가 |
|---|---|---|
| [[meta-harness]] | 인터페이스 (session / harness / sandbox) | harness의 가정이 모델 발전으로 썩는 것 |
| [[artifact-chain]] | 단계별 커밋된 파일 | 단계 간 결합, 감사 불가능성 |
| **agent recipe** | **누적된 판단 (eval, skill, profile)** | **모델이나 제공자 교체 시 노하우 유실** |

셋 다 상태를 모델과 context window **밖**에 두는 처방이다. 무엇을 밖에 두는지가 다르다. meta-harness는 경계선을, artifact-chain은 산출물을, recipe는 **판단**을 밖에 둔다.

> **recipe 안에서도 수명이 다르다 (2026-11-26).** [[meta-harness]]가 세운 기준을 recipe 부품에 적용하면 순서가 생긴다. *"모델은 X를 못 한다"* 는 **능력 가정**은 모델이 좋아지면 썩고, **과제 규칙**은 모델을 바꿔도 남는다. eval과 judge는 과제 규칙에 가깝고 오래 산다. 사용자 불만에서 나온 harness profile은 능력 가정을 담기 쉬워 가장 빨리 낡는다. 그래서 harness profile을 모델별로 따로 두는 것이다. 부품별 수명 표와 능력 가정에 유효기간을 다는 방법은 [[what-to-accumulate-outside-the-model]]에 있다. *(추론)*

## 한계와 읽을 때의 주의

- **개념의 소스는 하나, 그것도 제품 발표다.** (2026-11-25에 들어온 GEPA는 recipe 개념이 아니라 그 부품 하나의 자동화를 뒷받침한다.) 개념 설명이 곧바로 `pi.recipes`(Introspection) 소개로 이어진다. 이 이름이 업계 용어로 자리 잡을지는 불명이다. 소스 스스로 *"skills가 2025년에 그랬던 것과 비슷하지만 한 걸음 더 나간 것"*이라 말한다.
- **"해자"라는 주장은 논증이 아니다.** recipe가 복제 가능한 git repo라면 왜 해자가 되는지는 설명되지 않는다. 읽을 수 있는 답은 *"그 recipe에 도달한 과정(프로덕션 신호)은 복제되지 않는다"* 정도인데, 소스는 이것을 명시하지 않는다.
- **정량 근거는 부품 수준에만 있다.** recipe를 묶음 단위로 도입한 전후 비교는 여전히 없다. 있는 것은 prompt 증류(GEPA)와 그 모델 간 전이의 수치뿐이다.

## Related

- [[loop-engineering]] — recipe를 만드는 과정. "루프가 제품"이라면 recipe는 그 제품의 누적 상태다
- [[agent-evaluation]] — recipe의 핵심 구성물(judge, eval)과 그 보정 절차
- [[meta-harness]] — 모델보다 오래 사는 것에 대한 또 다른 답(인터페이스)
- [[artifact-chain]] — 상태를 커밋된 파일로 빼는 같은 계열의 처방
- [[claude-code]] — skill, CLAUDE.md, hook 같은 recipe 부품의 한 구현
- [[prompt-optimization]] — recipe 부품 중 prompt를 trace에서 자동으로 증류하는 방법들. GEPA가 대표
- [[what-to-accumulate-outside-the-model]] — recipe 부품을 수명 순으로 정렬한 synthesis. 무엇을 로컬에 쌓고 무엇에 유효기간을 다는가

## Sources

- [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu (Introspection, AI Engineer World's Fair 발표). recipe와 system distillation 개념의 출처
- [[2025-07-25-gepa-reflective-prompt-evolution]] — Agrawal 외 16인 (ICLR 2026 Oral). prompt 증류의 자동화, 모델 간 전이 수치, "그릇이 없다"에 대한 반례 (2026-11-25)
