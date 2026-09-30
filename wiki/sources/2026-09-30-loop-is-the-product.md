---
title: The Loop Is the Product
type: source
created: 2026-09-30
updated: 2026-09-30
source_file: ../../raw/articles/2026-09-30-loop-is-the-product.md
source_url: https://www.youtube.com/watch?v=cv2_Lzvd1mk
author: Roland Gavrilescu (Introspection; 한영자막 클리핑 Tech Bridge)
source_date: 2026-09-30
tags: [loop-engineering, agent-recipe, system-distillation, evaluation, taste, hitl, ab-testing, ooda, external-perspective, talk]
status: mature
---

# The Loop Is the Product

> 오토리서치(auto research) 제품의 청사진을 세 문장으로 제시하는 발표. **① 루프가 곧 제품이다 ② system distillation이 해자다 ③ 최적화할 점수는 valued work per watt다.** 중심 주장은 제작자의 **taste를 eval로 코드화**하고, 사람은 eval을 만드는 게 아니라 **보정만** 하며, 그 taste가 맞는지는 프로덕션 A/B로 사용자에게 확인받는다는 것이다.

## Context

xAI에서 에이전트 인프라를 하던 Roland Gavrilescu가 공동 창업자와 나와 세운 **Introspection**의 발표. AI Engineer World's Fair 무대(약 18분). 위키가 가진 것은 YouTube 영상의 **자동 생성 영어 자막 + 한국어 채널(Tech Bridge)의 설명·타임라인**이다. 클리핑 날짜 2026-09-30, 발표 자체의 날짜는 불명.

읽을 때 세 가지를 염두에 둔다.

- **자동 자막이다.** "Cloud Code"는 Claude Code, "Pie Harness"는 pi harness, "open cloud"는 OpenClaw로 읽힌다. 인용은 자막 그대로 싣되 문장 단위 정확성은 보장되지 않는다.
- **자사 제품 발표다.** 결론부의 recipe 개념은 곧바로 `pi.recipes`(Introspection의 early release)로 이어진다. 개념 주장과 제품 소개가 한 흐름이다.
- **이 위키 최초로 Anthropic을 발행처로도, 인용 경로로도 거치지 않는 소스다.** Claude Code는 한 번, 경쟁 대상으로 언급될 뿐이다(*"people would switch away from Claude Code to something you provide"*). → [[anthropic]]

## Key Claims

1. **루프가 곧 제품이다.** 업계 초점의 이동을 한 줄로 요약한다 — RLHF(모델) → harness(*"the model is a commodity and it's all about the harness"*) → loop. 첫 사례로 OpenClaw(구 Clawbot) 위에 누군가 짠 **자동차 가격 협상 루프**를 든다: Reddit에서 시세·재고 조사 → 딜러와 대화 → 딜러끼리 경쟁 붙이기 → **가격이 맞는지 검증 가능한 기준** → 계약. → [[loop-engineering]]

2. **루프의 구조는 OODA이고, 두 끝이 품질을 정한다.** 1970년대 미 공군의 Observe-Orient-Decide-Act. 도구 호출 → 관측이 곧 그 루프라고 본다.
   > *"the quality of the signal determines the success rate of the loop and the quality of the verifier is able to calibrate if that success is actually correct or not."*

   그리고 **두 번째 루프** — 첫 루프의 산출물을 signal로 되먹여 다음 루프를 돌린다. 지속 개선의 원리가 이것이다.

3. **System distillation이 해자다.** 각 루프는 harness·profile·eval·model·resource·tool·environment에 관한 정보를 낸다. 이것을 **portable하게, 버전 관리하며, 진화**시켜야 한다. RL의 data recipe 유비 — 연구자는 recipe를 계속 고쳐 환각·reward hacking에 대응했지만 **harness나 AI 시스템 일반에는 그런 recipe가 없다.** → [[agent-recipe]]

4. **Agent recipe — 재현 가능한 frontier 시스템.** 특정 플랫폼·제공자에 묶이지 않고, 회사 안에 살며, git repo로 버전 관리되고, **사람이 소유하되 에이전트가 관리한다.** 루프의 산출물을 recipe로 증류하는 변환 규칙:
   > *"Failure patterns should become judges and evals. Repeated behavior should become skills and prompts. User frustration, extensions and memories to your harness."*

   recipe는 *"제작자의 taste를 인코딩한 것"*이고, 남의 recipe를 쓰면 **그 사람의 taste도 함께 가져온다.** 기반은 pi harness와 Harbor(eval).

5. **Taste를 eval로 코드화하고, 사람은 보정만 한다.** 리크루팅 에이전트 실례로 5단계를 보인다. → [[agent-evaluation]]
   1. **Baseline** — 웹 검색·LinkedIn 도구, subagent, 리크루터 system prompt.
   2. **Patterns** — trace에서 공통 행동·사용자 불만을 클러스터링. 발견: 에이전트가 **빅테크 직원에게만 연락**한다(*"You don't want to try to hire John Carmack"*). 숨은 인재를 찾는 게 목적인데. **아무도 미리 코드화할 생각을 못 했을 행동**이다.
   3. **Calibrate judges & evals** — 그 패턴을 잡는 judge를 에이전트가 만든다. 사람은 *"이 판단에 동의하는가?"* 에만 답한다.
      > *"You don't need the human to actually build the evals. You need them to calibrate the evals."*
   4. **Recipe candidates** — 반영할 diff 후보. offline eval로 거른다.
   5. **Experiments** — 프로덕션 A/B(multi-armed bandit). **사용자도 그 taste에 동의하는지** 확인한 뒤에야 promote.

   검증이 두 겹이다 — **offline eval은 제작자가 만족하는지**, **프로덕션 실험은 사용자가 동의하는지.**

6. **최적화 점수는 valued work per watt.** 첫째 만든 작업이 가치 있는가, 둘째 그 경제성이 맞는가. 근거로 Cursor·Cognition의 궤적 — 최고의 제품 → 그 제품의 최고의 eval → 앞의 둘로 만든 최고의 모델. 코드가 첫 도메인이었고 법률·리서치 등이 뒤따른다고 본다. 순서는 **frontier에 먼저 도달하고, 그다음 비용을 줄인다.** frontier가 어디인지는 *"프로덕션에서 돌려보기 전엔 알 수 없다."*

## Notable Quotes / Passages

> *"You try to automate yourself as the higher level judge and you want to make sure your second-loop agents are able to apply the same judgment."* — 결론부

> *"What would Miranda do in certain cases? And you kind of want to codify that thinking into agents."* — *The Devil Wears Prada*의 Miranda를 taste의 예로 든다

## Connections

- [[loop-engineering]] — 같은 "루프" 담론의 비-벤더, **제품 빌더** 쪽 목소리. Osmani가 개인 개발 워크플로를 다뤘다면 이쪽은 **루프를 파는 회사**의 관점. taste를 두고 정면으로 부딪힌다 (⚠️ Contradiction).
- [[agent-recipe]] — 이 소스가 이름을 붙인 개념. 이 ingest로 신설.
- [[agent-evaluation]] — HITL을 "제작"이 아니라 "보정"에 두는 분업, taste-as-eval, 프로덕션 A/B라는 세 번째 검증 층.
- [[meta-harness]] — "harness보다 오래 사는 것"에 대한 다른 답. 거기는 **인터페이스**, 여기는 **recipe(누적된 판단)**.
- [[anthropic]] — 이 위키 최초의 완전 외부 소스. 단 벤더 편향 대신 **스타트업 제품 편향**이 들어온다.

## My Notes

- **takeaway 합의 (2026-09-30):** 5개 후보 전부 채택. 새 concept 이름은 `agent-recipe`(추천안 채택). raw 파일명은 사용자가 `2026-09-30-loop-is-the-product.md`로 rename.
- **Osmani와의 충돌이 이 소스의 가장 큰 기여다.** Osmani: *"사람의 taste는 루프에 맞지 않는다"*, *"task는 위임하고 judgment는 되가져온다."* Gavrilescu: *"상위 judge로서의 자신을 자동화하라."* 다만 Gavrilescu도 사람을 **보정 단계에 남긴다** — 부분 화해 가능. 상세는 [[loop-engineering]]의 Contradiction 절.
- **정량 데이터 0.** 리크루팅 사례도 결과 수치(응답률, A/B 효과 크기) 없이 절차만 보인다. "Cursor·Cognition이 이렇게 했다"도 해석이지 인용된 증거가 아니다.
- **Valued work per watt는 정의되지 않는다.** "value를 어떻게 재는가가 첫 단계"라고 말하고 끝난다. 구호로 읽는 것이 안전하다.

## Raw Source

[원본 파일](../../raw/articles/2026-09-30-loop-is-the-product.md)
