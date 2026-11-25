---
title: 안쪽 loop와 바깥쪽 loop — 각 층위에서 무엇을 검증하는가
type: synthesis
created: 2026-11-25
updated: 2026-11-25
sources: [2026-09-30-loop-is-the-product, 2026-08-14-practical-loop-engineering, 2025-07-25-gepa-reflective-prompt-evolution, 2026-08-21-the-ai-native-sdlc-playbook]
question: "loop engineering을 이야기할때 바깥쪽 loop, 안쪽 loop이라고 하는건 어떤걸 의미하는걸까? 검증과 관련된거야?"
aliases: [inner loop, outer loop, 안쪽 루프, 바깥쪽 루프]
tags: [loop-engineering, verification, system-distillation, agent-evaluation, synthesis]
status: draft
---

# 안쪽 loop와 바깥쪽 loop — 각 층위에서 무엇을 검증하는가

> 둘 다 검증과 관련 있지만 검증하는 대상이 다르다. **안쪽 loop는 작업 결과가 맞는지**를 검증한다. **바깥쪽 loop는 안쪽 loop가 쓰는 판단 기준(eval·verifier·skill·prompt)이 맞는지**를 검증하고 고친다.

## 용어 정리

이 위키는 "inner/outer"라는 말을 쓰지 않는다. 같은 구조를 [[loop-engineering]]의 **첫 번째 루프 / 두 번째 루프**로 기록한다. "inner loop"는 [[2026-09-30-loop-is-the-product]] 원문에만 나온다.

> *"you can think of the worker as the inner loop and it generates all these artifacts. But how you look at the artifacts and know what to change is the taste."* — Gavrilescu, 11:42 ([raw](../../raw/articles/2026-09-30-loop-is-the-product.md))

"outer loop = 두 번째 루프"라는 대응은 이 원문에서 끌어낸 것이다. outer loop라는 말을 명시적으로 쓰는 소스는 없다. *(추론)*

## 구조

```
바깥쪽 (두 번째 루프)   trace 패턴 → judge/eval 보정 → recipe 후보 → offline eval → A/B → promote
      ▲    │
      │    ▼  recipe: eval·skill·prompt·harness profile
안쪽 (첫 번째 루프)     observe → orient → decide → act   ← signal ─ verifier
```

([[loop-engineering]], [[2026-09-30-loop-is-the-product]])

Gavrilescu는 루프의 품질을 두 끝이 정한다고 본다. *"the quality of the signal determines the success rate of the loop and the quality of the verifier is able to calibrate if that success is actually correct or not."* ([[loop-engineering]])

## 비교

| | 안쪽 loop (worker) | 바깥쪽 loop (distillation) |
|---|---|---|
| 하는 일 | 도구를 호출하고 관측을 받는 OODA 순환으로 태스크를 수행한다 ([[loop-engineering]]) | 안쪽 loop의 산출물(trace, 실패, 사용자 불만)을 signal로 되먹여 **루프 자체를 고친다** ([[loop-engineering]]) |
| 검증 대상 | "이 결과물이 맞는가": verifier, maker/checker 분리, 검증 skill ([[loop-engineering]], [[agent-evaluation]]) | "우리가 '좋다'고 판정하는 기준이 맞는가": judge·eval 보정, offline eval, 프로덕션 A/B ([[agent-recipe]]) |
| 산출물 | 코드, PR, 답변 같은 작업 결과 | [[agent-recipe]]: git에 버전 관리되는 eval·skill·prompt·harness profile |
| 사람의 역할 | 결과 리뷰. "done"은 주장이지 증명이 아니다 ([[loop-engineering]]) | taste 제공과 eval 보정. 원문 표현으로 experiments가 *"my taste is actually validated in production with users"* 를 확인한다 ([[2026-09-30-loop-is-the-product]]) |

바깥쪽 loop의 증류 규칙은 이렇다. 실패 패턴은 judge와 eval이 되고, 반복 행동은 skill과 prompt가 되고, 사용자 불만은 harness 확장과 memory가 된다. 이 과정 전체를 **system distillation**이라 부른다 ([[agent-recipe]], [[loop-engineering]]).

## 검증이 두 층위를 잇는 방식

1. **안쪽 검증을 손으로 증류하면 바깥쪽 loop의 한 단계가 된다.** Claude Code 팀의 `verify-frontend-change` skill은 사람이 반복하던 확인을 skill로 옮긴 것이다. [[loop-engineering]]은 이것을 "system distillation 한 단계를 손으로 한 것"으로 기록한다 ([[2026-08-14-practical-loop-engineering]]).
2. **evaluator를 걸어도 안쪽 검증이 끝난 것은 아니다.** `/goal`의 evaluator는 품질을 판정하지 않는다. 사람이 명시한 하드 룰이 충족됐는지만 transcript에서 확인한다. 그래서 별도의 checker가 여전히 필요하다 ([[loop-engineering]], [[2026-08-14-practical-loop-engineering]]).
3. **안쪽 verifier가 남기는 signal의 품질이 바깥쪽 loop의 효율을 정한다.** GEPA는 점수 하나 대신 점수로 접히기 전의 텍스트(컴파일러 에러, 실패한 루브릭)를 피드백으로 줬다. 그 결과 train rollout 6~179회로 RL(24,000 rollout)의 최고 점수에 도달했다 ([[prompt-optimization]], [[2025-07-25-gepa-reflective-prompt-evolution]]). 정리하면 안쪽 verifier가 이유까지 텍스트로 남길수록 바깥쪽 loop가 적은 시도로 배운다. *(추론)*

세 가지를 한 줄로 묶으면 이렇다. 안쪽 loop의 검증 출력이 곧 바깥쪽 loop의 입력이다. 바깥쪽 loop의 산출물(새 eval·skill)이 다음 안쪽 loop의 검증 기준이 된다. *(추론)*

## 모순: taste를 바깥쪽 loop에 맡길 수 있는가

> ⚠️ **Contradiction** ([[loop-engineering]]에 기록된 모순을 그대로 옮긴다)
> - **Gavrilescu** ([[2026-09-30-loop-is-the-product]]): taste를 eval로 코드화하고 사람은 보정만 하면, 바깥쪽 loop가 판단까지 증류한다.
> - **Osmani** ([[2026-08-14-practical-loop-engineering]]): "이게 만들 가치가 있는 변경인가"라는 판단은 어떤 정지 조건으로도 표현되지 않는다. task는 위임하고 judgment는 되가져와야 한다.
> - **판정 상태: 부분 판정.** 두 사람의 맥락이 다르다(반복되는 제품 판단 vs 매번 다른 일회성 판단). GEPA는 정답이 있는 과제만 다뤄서 이 모순을 판정하지 못한다.

## 헷갈리기 쉬운 두 가지

- **"네 종류의 루프"는 안팎 구분이 아니다.** turn-based / goal-based / time-based / proactive 분류의 축은 트리거와 정지 조건이다. 네 종류 모두 안쪽 loop를 *언제·얼마나* 돌릴지의 문제다 ([[loop-engineering]]).
- **소프트웨어 개발의 inner/outer loop와는 다른 뜻이다.** *(위키 외)* 개발 쪽에서 inner loop는 개발자 한 명의 edit-build-test 순환이고, outer loop는 CI·리뷰·배포다. 위키 안에서는 SDLC 플레이북의 *"`permissions.allow` pre-approves the safe inner loop"* 가 이 뜻으로 쓰인다 ([[agentic-governance]], [[2026-08-21-the-ai-native-sdlc-playbook]]).

## 빈틈

- "outer loop"를 명시적으로 쓰는 소스가 없다.
- 바깥쪽 loop가 실제로 안쪽 loop를 개선했다는 정량 근거는 GEPA의 prompt 최적화 결과뿐이다. pi.recipes 발표에는 수치가 없다 ([[loop-engineering]]).

## Related

- [[loop-engineering]] — 첫 번째/두 번째 루프의 원래 기록. 이 페이지는 그 절을 검증 관점에서 다시 정리한 것이다
- [[agent-recipe]] — 바깥쪽 loop의 산출물
- [[agent-evaluation]] — 안쪽 loop의 결과 검증 방법(LLM-as-judge, 판정자 분리)
- [[prompt-optimization]] — 바깥쪽 loop의 한 조각(prompt 증류)을 측정한 GEPA
- [[agentic-governance]] — 개발 쪽 의미의 "inner loop"가 나오는 곳

## Sources

- [[2026-09-30-loop-is-the-product]] — inner loop 정의, 두 번째 루프, taste 쪽 주장
- [[2026-08-14-practical-loop-engineering]] — `/goal` evaluator의 정체, 검증 skill, judgment 위임 경계
- [[2025-07-25-gepa-reflective-prompt-evolution]] — 텍스트 피드백의 표본 효율
- [[2026-08-21-the-ai-native-sdlc-playbook]] — 개발 쪽 의미의 "inner loop"
