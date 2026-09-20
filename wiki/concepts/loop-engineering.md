---
title: Loop Engineering (루프 엔지니어링)
type: concept
created: 2026-09-21
updated: 2026-09-21
sources: [2026-06-07-loop-engineering, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents]
tags: [loop-engineering, agentic-workflows, agent-harness, automations, cadence, external-state, verification, comprehension-debt]
status: draft
---

# Loop Engineering (루프 엔지니어링)

> **에이전트에게 프롬프트를 던지는 사람 자리에서 자기를 빼고, 그 일을 대신 할 시스템을 설계하는 것.** 다섯 개의 primitive(automations·worktrees·skills·plugins/connectors·sub-agents)와 대화 밖에 사는 state 하나로 만들어진다. 이 위키의 다른 harness 개념들과 다른 점은 단 하나 — **실행 하나가 아니라 실행과 실행 사이를 설계한다.**

## Overview

지난 2년의 작업 방식은 이랬다: 좋은 프롬프트를 쓰고, 돌아온 걸 읽고, 다음 걸 친다. 에이전트는 도구이고 **당신이 내내 그걸 손에 쥐고 있다.** Loop engineering은 그 자리를 비운다 — 일을 찾아내고, 나눠주고, 검사하고, 무엇이 끝났는지 적고, 다음 할 일을 정하는 작은 시스템을 만들어서 **그게 에이전트를 찌르게** 한다 ([[2026-06-07-loop-engineering]]).

주장의 출처는 두 사람의 발언이다. Peter Steinberger — *"You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."* Claude Code 책임자 Boris Cherny — *"I don't prompt Claude anymore. I have loops running that prompt Claude and figuring out what to do. My job is to write loops."*

### 위치: harness 층위의 세 번째 자리

이 위키는 이미 harness를 두 방향에서 다뤘다. 루프는 그 위에 얹힌다 — 소스 저자 본인의 표현으로 *"Loop engineering sits one floor above the harness."*

```
loop              ← 언제·얼마나 자주 돌 것인가 + 실행 사이에 무엇이 남는가
  │                 (automations, 외부 state)
  ▼
meta-harness      ← 인터페이스 (session / harness / sandbox). 가장 느리게 변함
  └─ harness      ← Claude Code, 태스크 전용 harness, dynamic workflow가 쓴 프로그램
       └─ prompt  ← 가장 빠르게 변함
```

세 개념이 **서로 다른 문제**를 푼다:

| | 푸는 문제 | 설계 주체 | 수명 |
|---|---|---|---|
| [[dynamic-workflows]] | 태스크 적합성 — generic harness는 어떤 태스크에도 최적이 아니다 | 모델이 실행 시점에 작성 | 그 태스크 동안 |
| [[meta-harness]] | 시간에 따른 노후화 — harness의 가정은 모델이 좋아지면 썩는다 | 플랫폼이 경계선을 고정 | harness들보다 길게 |
| **loop engineering** | **기동과 연속성 — 누가 언제 이걸 돌리며, 지난번 결과는 어디에 남는가** | **사람이 한 번 설계** | **세션들보다 길게** |

**대체재가 아니다.** 루프의 한 턴이 dynamic workflow를 띄울 수 있고, 그 워크플로가 meta-harness 위에서 돌 수 있다. 다만 층위가 다르므로 **한 방향의 긴장은 있다** — 아래의 "조정 주체가 다시 사람에게 올라간다" 참조.

## Key Points

### 다섯 primitive + 하나의 state

소스의 목록이다. 앞의 다섯은 "루프가 무엇을 할 수 있는가"이고, 여섯 번째는 "루프가 루프인 이유"다.

1. **Automations** — 주기적으로 스스로 발동해 discovery와 triage를 한다. **루프의 심장박동.** 이게 없으면 그냥 한 번 돌린 실행이다.
2. **Worktrees** — 둘 이상의 에이전트가 같은 파일에서 부딪히지 않게 한다.
3. **Skills** — 에이전트가 아니면 추측할 프로젝트 지식을 적어둔다.
4. **Plugins / connectors** — 이미 쓰는 도구(이슈 트래커, DB, staging API, Slack)에 에이전트를 연결한다.
5. **Sub-agents** — 아이디어를 낸 쪽과 검사하는 쪽을 다른 에이전트로 둔다.
6. **State** — 단일 대화 **바깥**에 살면서 무엇이 끝났고 무엇이 남았는지 들고 있는 것. 마크다운 파일이든 Linear 보드든.

> *"The agent forgets, the repo doesnt."*

여섯 번째가 너무 시시해 보이지만, 소스는 이것을 장기 실행 에이전트가 전부 의존하는 같은 트릭이라고 말한다 — 모델은 실행 사이에 전부 잊으므로 **메모리는 컨텍스트가 아니라 디스크에 있어야 한다.** 이 위키의 [[artifact-chain]]과 [[meta-harness]]의 세션 로그가 같은 처방의 다른 층위다.

### 이것이 위키에 채우는 빈칸: cadence와 연속성

[[subagent]]는 *누가 조정하는가*를 네 층위로 나눴고(사람 / lead agent / 프로그램 / 플랫폼), [[agent-orchestration-patterns]]는 *한 실행 안에서 어떤 제어 구조를 쓰는가*를 여섯 개로 카탈로그했다. **둘 다 실행 하나의 내부를 본다.**

루프가 더하는 것은 두 개의 축이다:

- **cadence** — 누가 이걸 언제 시작하는가. 사람이 프롬프트를 칠 때가 아니라 스케줄이 올 때.
- **연속성** — 이번 실행이 남긴 것을 다음 실행이 어떻게 집어드는가. 외부 state 파일.

[[agent-orchestration-patterns]]의 "무엇이 이 카탈로그에 없는가"에 적힌 세 공백 중 하나(사람이 루프 안에 있는 패턴)가 여기서 부분적으로 답을 얻는다 — 소스의 예시 루프에서 **루프가 처리 못 한 것만 triage inbox로 사람에게 간다.** 사람은 매 턴이 아니라 **예외 경로**에 있다.

### 정지 조건의 판정자도 분리한다 — `/goal`

세션 안의 두 primitive가 구분된다:

- **`/loop`** — 정해진 주기로 **재실행**한다.
- **`/goal`** — 내가 쓴 조건이 **실제로 참이 될 때까지** 계속한다. 그리고 매 턴 후 **별도의 작은 모델**이 완료 여부를 판정한다.

> *"so the agent that wrote the code isnt the one grading it."*

이건 [[agent-evaluation]] §2b(self-preferential bias 때문에 판정자를 분리하라)가 **정지 조건이라는 메타 판정에까지** 적용된 형태다. [[agent-orchestration-patterns]]로 보면 #3 adversarial verification과 #6 loop-until-done의 결합이며, 그 카탈로그가 *"정지 조건을 표현할 수 없는 태스크에는 못 쓴다"* 고 적은 제약이 여기서도 그대로다 — `/goal`에 주는 건 *"all tests in test/auth pass and lint is clean"* 같이 **검증 가능한 문장**이어야 한다.

Codex에도 같은 이름의 `/goal`이 있다. 두 제품이 독립적으로 같은 자리에 같은 것을 놓았다는 점이 이 항목의 무게다.

### skill은 저작 포맷, plugin은 배포 수단

혼동하기 쉬운 구분이라 소스가 명시한다. 둘 다 `SKILL.md`를 담은 폴더이고, repo를 넘어 공유하거나 여러 개를 묶을 때 **plugin으로 패키징**한다. Codex와 Claude Code 양쪽에서 동일하다.

트리거 설계에 대한 한 줄이 실무적으로 유용하다 — description이 매칭되면 암묵 호출되므로 ***"a tight boring description beats a clever one."***

**skill이 없으면 루프는 매 사이클 프로젝트를 처음부터 재추론한다.** 에이전트는 매번 차갑게 시작하고 의도의 구멍을 자신 있는 추측으로 메운다(저자의 표현으로 "intent debt"). Skill은 그 의도를 바깥에 한 번 적는 것 — 컨벤션, 빌드 스텝, *"we dont do it like this because of that one incident."* 이게 있어야 루프가 **누적**된다. state 파일이 *무엇을 했는지*를 나른다면 skill은 *어떻게 하는지*를 나른다.

### 도구 선택은 논점이 아니다

소스가 놀라워하는 지점 — 1년 전이면 bash 더미를 직접 쌓아 혼자 영원히 유지해야 했는데, 지금은 *"the pieces just ship inside the products."* Codex와 Claude Code 양쪽에 다섯 개가 전부 있다. 결론은 도구 비교를 그만두라는 것이다:

> *"you just design a loop that still works no matter which one you happen to be sitting in."*

대응표 전체는 [[2026-06-07-loop-engineering]]에 있다. 이 위키에서 의미 있는 건 **[[claude-code]]가 유일한 구현이 아니라는 첫 기록**이라는 점이다.

## 반대급부 — 루프가 좋아질수록 커지는 셋

이 절이 이 소스가 위키에 주는 가장 다른 것이다. 기존 소스들은 대체로 처방을 제시하고 한계를 각주로 달지만, 여기서는 **한계가 결론 자체**다.

### 검증은 여전히 사람 몫이다

> *"A loop running unattended is also a loop making mistakes unattended."*

maker/checker를 분리하는 이유가 루프의 "끝났다"를 의미 있게 만들기 위해서인데, **그렇게 해도 "done"은 주장이지 증명이 아니다.** [[agent-evaluation]] 전체가 이 문제를 다루지만, 루프에서는 한 가지가 달라진다 — 검증 실패를 **내가 안 보는 동안** 누적한다.

### 이해가 썩는다 (comprehension debt)

루프가 내가 쓰지 않은 코드를 빨리 내보낼수록 **존재하는 것과 내가 아는 것의 간격**이 벌어진다. 매끄러운 루프는 그 간격을 더 빨리 벌릴 뿐이고, 줄이는 방법은 루프가 만든 걸 읽는 것밖에 없다.

> 이 위키의 [[ai-native-sdlc]]가 "커밋된 아티팩트가 다음 단계를 트리거하는 루프"를 처방하는데, 그쪽에는 이 항목에 대응하는 경계가 없다. 아티팩트 체인이 감사 가능하다는 것과 **사람이 실제로 읽는다는 것**은 다른 명제다.

### 편안한 자세가 위험한 자세다 (cognitive surrender)

루프가 알아서 돌면 의견 갖기를 그만두고 나온 걸 그대로 받게 된다. 소스의 핵심 문장:

> *"Designing the loop is the cure when you do it with judgement and the accelerant when you do it to avoid thinking, same action, opposite result."*

그래서 **같은 루프가 사람에 따라 정반대 결과를 낸다** — 한 사람은 깊이 이해하는 일을 더 빨리 하는 데 쓰고, 다른 사람은 그 일을 이해하지 않기 위해 쓴다. *"The loop doesn't know the difference. You do."*

### 그리고 토큰

소스는 첫 문단부터 경고한다 — *"usage patterns can vary wildly if you are token rich or poor."* subagent는 각자 모델·도구 작업을 하므로 비용을 더 쓰고, **두 번째 의견이 값을 하는 자리에만** 쓰라는 것이 처방이다. [[multi-agent-systems]]의 15배 배수와 [[agent-orchestration-patterns]]의 *"loop-until-done은 비용이 가장 예측하기 어려운 패턴"* 이 여기에 그대로 걸린다. 루프는 그 패턴을 **주기적으로** 돌린다는 점에서 비용 예측이 한 겹 더 어렵다.

## 조정 주체가 다시 사람에게 올라간다 — 층위 간 긴장

[[dynamic-workflows]]의 정의적 특징은 **조정이 LLM의 판단에서 결정론적 코드로 내려간 것**이었다. 루프는 반대로 보인다 — 무엇을 언제 돌릴지, 어떤 state를 남길지를 **사람이 한 번 설계**한다.

모순은 아니다. 대상이 다르다:

```
사람이 정하는 것        루프의 골격 — 주기, 어떤 skill을 부를지, state를 어디 둘지
     │                  (한 번 설계하고 그 뒤로 안 만짐)
     ▼
프로그램이 정하는 것     한 턴 안의 조정 — 무엇을 병렬로, 누가 검증, 언제 멈춤
     │                  ([[dynamic-workflows]], [[agent-orchestration-patterns]])
     ▼
LLM이 정하는 것          각 subagent 안의 실제 판단
```

[[subagent]]가 기록한 **조정 주체 네 층위**에 시간 축이 하나 붙은 셈이다. 그쪽은 *한 실행 안에서 누가 조정하는가*를 나누고, 이쪽은 **그 실행을 누가 시작시키는가**를 묻는다.

> 다만 소스는 이 관계를 명시적으로 따지지 않는다. 위 정리는 이 위키가 두 소스를 맞붙여 만든 것이다.

## 한계와 읽을 때의 주의

- **정량 데이터가 없다.** 대응표는 기능 존재 여부이지 성능 비교가 아니다. 루프를 도입해서 무엇이 얼마나 나아졌는지에 대한 숫자가 하나도 없다. 증거 두께로는 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]와 같은 급(경험 보고)이다.
- **외부 소스이지만 독립 검증은 아니다.** 저자는 두 벤더의 제품 문서와 X 포스트를 읽고 정리했지 스스로 측정하지 않았다. **관점**의 외부성이지 **증거**의 외부성이 아니다. → [[anthropic]]
- **"루프의 시대다"의 근거는 두 사람의 X 발언이다.** 그중 한 명은 Claude Code 책임자, 즉 이해관계자다. 저자 본인도 *"its still early, I'm skeptical"* 이라 쓰고 마지막에 *"프롬프팅도 여전히 효과적이다, 균형의 문제"* 로 돌아온다. 이 페이지도 그 유보를 그대로 들고 간다.
- **다섯 primitive가 필요조건인지 충분조건인지 불분명하다.** 소스는 *"A loop needs five things"* 라고 단언하지만 왜 다섯인지, 넷으로는 왜 안 되는지의 논증은 없다. 실무 관찰의 정리로 읽는 것이 안전하다.
- **연재의 한 편이다.** comprehension debt, cognitive surrender, intent debt, orchestration tax는 저자의 다른 글에서 전개된 개념이고 여기서는 한 문단씩만 나온다. 이 위키는 그 한 문단씩만 갖고 있다.

## Related

- [[meta-harness]] — 바로 아래 층위. harness들보다 오래 사는 인터페이스를 고정하는 처방
- [[dynamic-workflows]] — 한 턴 안의 조정을 코드로 내리는 처방. 루프의 한 턴이 이것을 띄울 수 있다
- [[agent-orchestration-patterns]] — 루프의 한 턴 안에서 쓰이는 여섯 제어 구조. #6 loop-until-done이 `/goal`의 원형
- [[agent-evaluation]] — 정지 조건의 판정자를 분리하는 근거. §2b가 이 페이지의 `/goal` 절과 같은 원리
- [[subagent]] — maker/checker 분리의 실행 단위. 조정 주체 네 층위에 시간 축을 더하는 지점
- [[artifact-chain]] — 외부 state가 "루프의 척추"인 이유. 같은 처방의 SDLC 버전
- [[claude-code]] — `/loop`·`/goal`·worktree·skill·plugin·MCP의 실제 구현
- [[ai-native-sdlc]] — 커밋된 아티팩트가 다음 단계를 트리거하는 루프. comprehension debt 경계가 빠져 있는 곳
- [[multi-agent-systems]] — 루프가 주기적으로 지불하게 되는 토큰 비용의 근거
- [[anthropic]] — 이 위키 최초의 비-Anthropic 소스가 들어온 지점

## Sources

- [[2026-06-07-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-06-07). 이 페이지 전체의 1차 출처
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). 층위 대비와 loop-until-done·판정자 분리의 대조군
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). harness 층위 다이어그램의 출처
