---
title: Agent Recipe / System Distillation
aliases: [system-distillation, System Distillation]
type: concept
created: 2026-09-30
updated: 2026-09-30
sources: [2026-09-30-loop-is-the-product]
tags: [agent-recipe, system-distillation, loop-engineering, evaluation, taste, versioning, provider-agnostic]
status: stub
---

# Agent Recipe / System Distillation

> **System distillation은 과정이고 agent recipe는 그 결과물이다.** 루프가 돌 때마다 나오는 교훈(실패 패턴, 반복 행동, 사용자 불만)을 eval·skill·prompt·harness 설정으로 증류해 git에 버전 관리한 묶음이 recipe다. 모델이나 제공자가 아니라 *"어떻게 이 시스템에 도달했고 왜 그런가"* 를 재현 가능하게 만든다. 제안자는 이것을 **해자(moat)**라 부른다.

## Overview

RL 연구에는 **data recipe**가 있다. 연구자는 recipe를 계속 고쳐 환각이나 reward hacking 같은 행동에 대응하고, 마지막에 남는 것이 최종 recipe다. [[2026-09-30-loop-is-the-product]]의 주장은 **harness와 AI 시스템 일반에는 이런 것이 없다**는 것이다. eval, 튜닝, 사람의 판단처럼 처음부터 정해지지 않고 에이전트가 환경에서 행동하는 걸 보며 알게 되는 것들을 담을 그릇이 없다.

agent recipe는 그 그릇이다. 이 과정 전체를 **system distillation**이라 부른다.

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

### 세 가지 속성

- **Provider-agnostic.** 특정 플랫폼이나 모델에 묶이지 않는다. 모델별로 다른 harness profile을 recipe 안에 둔다.
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

## 한계와 읽을 때의 주의

- **소스 하나, 그것도 제품 발표다.** 개념 설명이 곧바로 `pi.recipes`(Introspection) 소개로 이어진다. 이 이름이 업계 용어로 자리 잡을지는 불명이다. 소스 스스로 *"skills가 2025년에 그랬던 것과 비슷하지만 한 걸음 더 나간 것"*이라 말한다.
- **"해자"라는 주장은 논증이 아니다.** recipe가 복제 가능한 git repo라면 왜 해자가 되는지는 설명되지 않는다. 읽을 수 있는 답은 *"그 recipe에 도달한 과정(프로덕션 신호)은 복제되지 않는다"* 정도인데, 소스는 이것을 명시하지 않는다.
- **정량 근거 없음.** recipe 도입 전후를 비교한 수치가 없다.

## Related

- [[loop-engineering]] — recipe를 만드는 과정. "루프가 제품"이라면 recipe는 그 제품의 누적 상태다
- [[agent-evaluation]] — recipe의 핵심 구성물(judge, eval)과 그 보정 절차
- [[meta-harness]] — 모델보다 오래 사는 것에 대한 또 다른 답(인터페이스)
- [[artifact-chain]] — 상태를 커밋된 파일로 빼는 같은 계열의 처방
- [[claude-code]] — skill, CLAUDE.md, hook 같은 recipe 부품의 한 구현

## Sources

- [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu (Introspection, AI Engineer World's Fair 발표). 이 페이지 전체의 유일한 출처
