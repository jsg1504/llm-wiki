---
title: Meta-harness (harness보다 오래 사는 인터페이스)
type: concept
created: 2026-09-21
updated: 2026-09-21
sources: [2026-04-08-scaling-managed-agents, 2026-08-20-a-harness-for-every-task-dynamic-workflows]
tags: [meta-harness, agentic-harness, interface-design, session-log, context-engineering, sandbox, security, anthropic]
status: draft
---

# Meta-harness (harness보다 오래 사는 인터페이스)

> **Harness는 "모델이 아직 혼자 못 하는 것"에 대한 가정의 집합**이고, 모델이 좋아지면 그 가정은 썩는다. Meta-harness는 더 좋은 harness를 만드는 대신 **어떤 harness가 와도 갈아 끼울 수 있는 인터페이스**를 고정하는 설계다. 의견을 갖는 대상이 harness의 내용물이 아니라 **harness 주변의 경계선**으로 옮겨간다.

## Overview

### 먼저: harness란 무엇인가

**Harness**는 모델을 감싸고 *무엇을 언제 할지*를 정하는 바깥 껍질이다 — Claude를 호출하는 루프, tool call을 실제 인프라로 라우팅하는 배선, 컨텍스트를 채우고 비우는 규칙. [[claude-code]]는 하나의 harness고, [[dynamic-workflows]]가 만드는 JavaScript 프로그램도 harness다.

문제는 harness에 들어가는 모든 결정이 **모델의 현재 능력에 대한 진술**이라는 점이다. "Claude는 컨텍스트가 차면 조기에 포기하므로 리셋을 넣는다", "Claude는 여러 실행 환경을 놓고 어디로 보낼지 고르지 못하므로 셸은 하나만 준다" — 전부 *못 한다*는 가정이고, 그 가정은 다음 모델에서 틀릴 수 있다.

### 가정이 썩는 방식: context anxiety 사례

[[2026-04-08-scaling-managed-agents]]가 드는 구체적 증거다.

```
Claude Sonnet 4.5
  관측: 컨텍스트 한계가 다가오는 것을 감지하면 작업을 조기 종료 ("context anxiety")
  처방: harness에 context reset을 추가
        │
        ▼  같은 harness를 다음 모델에
Claude Opus 4.5
  관측: 그 행동이 없다
  결과: reset은 dead weight가 됐다
```

harness의 코드는 그대로인데 그것이 방어하던 실패가 사라졌다. 저자들은 이것을 [Bitter Lesson](http://www.incompleteideas.net/IncIdeas/BitterLesson.html)의 사례로 제시한다 — **모델의 부족분을 메우려고 넣은 구조는, 모델이 그 부족분을 없애는 순간 순비용이 된다.**

여기서 나오는 결론이 meta-harness의 출발점이다. harness가 계속 바뀔 것을 전제하고, **바뀌지 않을 것이 무엇인지를 따로 고른다.**

### 설계 원형: "아직 생각되지 않은 프로그램"

저자들은 이것을 컴퓨팅의 오래된 문제로 되돌린다 — *"[programs as yet unthought of](http://www.catb.org/esr/writings/taoup/html/ch03s01.html)"* 를 위한 시스템 설계.

수십 년 전 OS가 같은 문제를 풀었다. 하드웨어를 **process**, **file** 같은 추상으로 virtualize해서, **아직 존재하지 않는 프로그램까지 수용**했다. `read()`는 1970년대 디스크 팩을 읽는지 현대 SSD를 읽는지에 무관하다. 위의 추상은 안정적으로 남고 아래의 구현은 자유롭게 바뀌었다 — **추상이 하드웨어보다 오래 살아남았다.**

Meta-harness는 같은 수를 에이전트에 둔다. 에이전트의 구성요소를 virtualize한다:

| 인터페이스 | 무엇인가 | 대표 호출 |
|---|---|---|
| **session** | 일어난 모든 것의 append-only 로그 | `getSession(id)`, `getEvents()`, `emitEvent(id, event)` |
| **harness** | Claude를 호출하고 tool call을 인프라로 라우팅하는 루프 | `wake(sessionId)` |
| **sandbox** | Claude가 코드를 돌리고 파일을 편집하는 실행 환경 | `execute(name, input) → string`, `provision({resources})` |

각각의 구현이 **나머지를 건드리지 않고 교체될 수 있다.** 의견을 갖는 지점은 명시적으로 한정된다:

> *"We're opinionated about the shape of these interfaces, not about what runs behind them."*
> — [[2026-04-08-scaling-managed-agents]]

이 위키에서 이 접근의 유일한 구현 사례는 [[managed-agents]]다.

## Key Points

### brain / hands / session — 분리의 세 축

핵심 조작은 **"brain"(Claude와 그 harness)을 "hands"(sandbox와 도구)와 "session"(이벤트 로그)에서 떼어내는 것**이다. 셋이 서로에 대해 거의 가정하지 않으면, **각각 독립적으로 실패하거나 교체될 수 있다.**

반례가 먼저 나온다. 처음엔 셋을 한 컨테이너에 넣었고, 이점도 있었다 — 파일 편집이 직접 syscall이고 설계할 서비스 경계가 없다. 그러나 두 가지가 무너졌다:

**(1) 서버가 pet이 됐다.** [pets-vs-cattle](https://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/)에서 pet은 이름이 붙은, 손으로 돌보는, 잃으면 안 되는 개체이고 cattle은 교체 가능한 개체다. 컨테이너가 죽으면 세션이 사라졌고 응답하지 않으면 되살려야 했다. 더 나쁜 것은 **관측 불능**이었다 — 유일한 창이 WebSocket 이벤트 스트림인데 그것은 *어디서* 실패했는지를 말해주지 못했다:

> *"a bug in the harness, a packet drop in the event stream, or a container going offline all presented the same."*

원인을 알려면 컨테이너에 셸을 열어야 했고, 거기 사용자 데이터가 있었다. 결과적으로 **디버깅 능력 자체가 없었다.**

**(2) 위치에 대한 가정이 고객 인프라를 막았다.** harness가 "Claude가 작업할 대상은 나와 같은 컨테이너에 있다"고 가정했으므로, 고객사 VPC의 자원에 붙이려면 네트워크를 peering하거나 고객이 harness를 자기 환경에서 돌려야 했다. **harness에 박힌 가정 하나가 인프라 선택지를 닫았다.**

분리 후에 일어난 일:

- **harness가 컨테이너를 떠난다.** 컨테이너를 다른 도구와 똑같이 호출한다 — `execute(name, input) → string`. 컨테이너는 cattle이 된다. 죽으면 harness가 **tool-call 에러로 받아 Claude에게 넘긴다.** Claude가 재시도를 택하면 `provision({resources})`로 표준 레시피에 따라 새로 올린다. 컨테이너를 간호하는 일이 사라진다.
- **harness도 cattle이 된다.** 세션 로그가 harness 밖에 있으므로 **harness 안에는 crash를 견뎌야 할 것이 없다.** 실패하면 `wake(sessionId)`로 새로 띄우고 `getSession(id)`로 로그를 되받아 마지막 이벤트부터 재개한다. 루프 도중에는 `emitEvent(id, event)`로 durable한 기록을 남긴다.

> **일반화하면:** 무엇이 pet인지는 *"그것이 죽으면 무엇이 같이 사라지는가"* 로 판별된다. 상태를 인터페이스 밖으로 빼내면 그 구성요소는 cattle이 된다. [[artifact-chain]]이 파일을 인터페이스로 삼아 단계 간 결합을 끊는 것과 같은 처방의 인프라 버전이다.

### 보안 경계 — "좁은 스코프"는 가정이고 "도달 불가"가 구조다

meta-harness 사고가 보안에 적용되면 판단 기준 하나가 나온다. 이 위키에서 가장 이식 가능한 부분 중 하나다.

결합 설계에서는 Claude가 생성한 **미신뢰 코드가 자격증명과 같은 컨테이너에서** 돌았다. 그래서 prompt injection은 *Claude에게 자기 환경을 읽도록 설득하기만* 하면 됐다. 그리고 토큰을 얻은 공격자는 그 토큰으로 **제약 없는 새 세션을 띄워 거기에 일을 위임할 수 있다** — 원래 세션에 걸린 어떤 제약도 우회된다.

명백한 완화책은 토큰을 좁게 스코핑하는 것이다. 그런데 저자들의 지적이 여기서 갈린다:

> *"Narrow scoping is an obvious mitigation, but this encodes an assumption about what Claude can't do with a limited token—and Claude is getting increasingly smart."*

**좁은 스코프는 harness의 가정과 같은 종류의 물건이다.** "이 정도 권한으로는 Claude가 심각한 일을 못 한다"는 진술이고, 모델이 좋아질수록 약해진다. 구조적 해결은 **토큰이 sandbox에서 애초에 닿을 수 없게** 하는 것 — 모델 능력의 함수에서 벗어나는 유일한 방어다.

두 패턴:

| 패턴 | 작동 방식 | 무엇을 보장하는가 |
|---|---|---|
| **자원에 auth를 번들** | Git은 sandbox 초기화 시점에 repo access token으로 clone하고 그 토큰을 local git remote에 배선한다 | `push`/`pull`이 **에이전트가 토큰을 한 번도 만지지 않고** 동작한다 |
| **sandbox 밖 vault + 프록시** | 커스텀 도구는 MCP로 지원하고 OAuth 토큰은 vault에. Claude는 전용 프록시로 MCP 도구를 부르고, 프록시가 세션 토큰을 받아 vault에서 자격증명을 꺼내 외부 서비스를 호출 | **harness조차 자격증명의 존재를 통보받지 않는다** |

통제 표면(`permissions.deny`, sandbox, `credentials`)의 구체적 배치는 [[agentic-governance]]와 [[claude-code]]에 있다. 이 절이 더하는 것은 그 위의 판별 질문이다 — **이 방어는 "모델이 X를 못 한다"에 기대고 있는가?**

### 세션은 Claude의 context window가 아니다

장기 작업은 context window를 넘긴다. 표준 처방들 — compaction(요약을 저장하고 원본을 치움), memory tool(컨텍스트를 파일로 씀), trimming(오래된 tool result나 thinking block을 선별 제거) — 은 **전부 되돌릴 수 없는 보존/폐기 결정**을 수반한다. 그리고:

> *"It is difficult to know which tokens the future turns will need."*

compaction이 메시지를 변형하면 harness는 원본을 창에서 제거하고, 따로 저장해두지 않는 한 **복구 불가능하다.** 선행 연구는 컨텍스트를 **창 밖의 객체**로 두는 접근을 탐구해 왔다 — 예컨대 REPL 안의 객체로 두고 LLM이 코드를 써서 filter·slice하게 하는 것.

Managed Agents에서 **session이 그 객체 역할을 한다.** 단 sandbox나 REPL이 아니라 세션 로그에 durable하게 저장된다. `getEvents()`가 이벤트 스트림의 **위치 기반 슬라이스**를 허용하고, 쓰임새가 유연하다:

- 마지막으로 읽은 지점부터 이어서 읽기
- 특정 순간 **직전 몇 개를 되감아** 그 정황을 보기
- 어떤 행동을 하기 전에 관련 컨텍스트를 **다시** 읽기

가져온 이벤트는 Claude의 창에 들어가기 전에 **harness에서 변형될 수 있다** — prompt cache hit rate를 높이는 컨텍스트 정렬이든 임의의 context engineering이든. 관심사를 이렇게 나눈 이유가 명시적이고, 그 자체가 meta-harness 논증이다:

> *"We separated the concerns of recoverable context storage in the session and arbitrary context management in the harness because we can't predict what specific context engineering will be required in future models."*

즉 **인터페이스는 "세션이 durable하고 interrogable하다"만 보장하고, 어떻게 쓸지는 전부 harness로 밀어낸다.**

#### 위키 안에서의 위치 — compaction 실의 세 번째 처방

이 위키에는 *compaction은 lossy하고 그래서 goal drift가 생긴다*는 관찰이 여러 페이지에 흩어져 있다([[dynamic-workflows]], [[orchestrator-worker]], [[multi-agent-systems]], [[subagent]]). 지금까지 기록된 처방은 둘이었고, 이 소스가 세 번째를 더한다:

| 처방 | 하는 일 | 약점 | 출처 |
|---|---|---|---|
| **(a) 잘 요약한다** — compaction / memory tool | 창에 들어갈 것을 압축 | 요약이 lossy. 엣지케이스 요건과 *"don't do X"* 제약이 유실 | [[2025-06-13-multi-agent-research-system]] |
| **(b) 도달하지 않는다** — subagent 격리 | 각 목표를 짧고 독립적으로 유지해 애초에 compaction까지 가지 않음 | 부모의 조정 컨텍스트는 여전히 찬다. subagent 간 컨텍스트 공유 불가 | [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] |
| **(c) 되돌릴 수 있게 한다** — 창 밖 durable 로그 | 폐기가 아니라 **탈거(eviction)**. 필요하면 슬라이스해 다시 가져옴 | 저장 비용, 재조회의 지연·토큰 비용. 무엇을 다시 읽을지는 여전히 판단 문제 | [[2026-04-08-scaling-managed-agents]] |

**셋은 배타적이지 않다.** (c)는 (a)를 안전하게 만든다 — 원본이 로그에 남아 있으면 compaction의 되돌릴 수 없음이 되돌릴 수 있음이 된다.

### Many brains — 스케일의 병목은 인텔리전스가 아니라 provisioning이었다

brain을 컨테이너에 두면 brain 수만큼 컨테이너가 필요하고, 그것이 provision될 때까지 추론이 시작되지 못한다. **sandbox를 영영 쓰지 않을 세션도** repo clone·프로세스 부팅·대기 이벤트 fetch를 선불했다.

그 죽은 시간이 **TTFT**(time-to-first-token — 작업을 받고 첫 응답 토큰을 내기까지)로 나타난다. 저자들은 이것을 *사용자가 가장 예민하게 느끼는 지연*이라고 부른다.

분리 후에는 컨테이너가 **필요할 때만** brain의 tool call로 provision된다. 당장 컨테이너가 필요 없는 세션은 기다리지 않고, 추론은 오케스트레이션 레이어가 세션 로그에서 대기 이벤트를 가져오는 즉시 시작된다.

> **p50 TTFT 약 60% 감소, p95 90% 이상 감소.**

많은 brain으로 스케일하는 일이 **stateless harness를 많이 띄우고 필요할 때만 hand에 연결하는 일**로 바뀐다.

> ⚠️ **수치를 읽을 때:** 이것은 내부 측정이고 워크로드 구성이 공개되어 있지 않다. 개선의 메커니즘이 "sandbox를 쓰지 않는 세션이 컨테이너 부팅을 선불하던 것을 없앴다"이므로, **그런 세션의 비중이 높을수록 개선폭이 커진다.** 60%/90%는 아키텍처의 우월성만큼이나 워크로드 믹스를 반영할 수 있다.

### Many hands — 인텔리전스가 올라가며 열린 쪽

반대편은 순서가 정반대다. 여러 실행 환경을 놓고 **어디로 일을 보낼지 판단하는 것**은 단일 셸에서 작업하는 것보다 어려운 인지 과제다. 초기 모델이 그것을 못 했기 때문에 단일 컨테이너로 시작한 것이었다. 그러나 인텔리전스가 스케일하자 **단일 컨테이너가 오히려 제약이 됐다** — 그것이 죽으면 brain이 뻗고 있던 모든 hand의 상태가 함께 사라졌다.

분리하면 각 hand가 하나의 도구가 된다 — `execute(name, input) → string`. 이름과 입력이 들어가고 문자열이 나온다. 이 인터페이스는 임의의 커스텀 도구, 임의의 MCP 서버, 자사 도구를 모두 받는다.

> *"The harness doesn't know whether the sandbox is a container, a phone, or a Pokémon emulator."*

그리고 어떤 hand도 특정 brain에 결합되어 있지 않으므로 — **brain끼리 hand를 서로 넘겨줄 수 있다.** ([[subagent]]가 기록한 "에이전트끼리 직접 주고받는 것은 없다"는 단정에 대한 예외 후보다. 그 페이지의 ⚠️ 노트 참조.)

> **이 두 절이 같이 말하는 것:** 인터페이스를 고정한 덕에 **한쪽 축은 비용이 내려가고(many brains) 다른 쪽 축은 모델이 좋아지며 가치가 올라간다(many hands).** meta-harness가 노리는 것이 정확히 이것이다 — 모델이 좋아질 때 **버려야 할 코드가 아니라 쓸 수 있게 되는 용량**이 생기는 구조.

## Meta-harness와 dynamic workflow — 같은 문제, 반대 방향

둘은 **같은 관찰에서 출발한다**: 모든 태스크를 커버해야 하는 generic harness는 어떤 태스크에도 최적이 아니고, 손으로 만든 harness는 금세 낡는다.

처방이 갈린다:

```
                    "generic harness는 최적이 아니고 가정은 썩는다"
                                    │
                ┌───────────────────┴───────────────────┐
                ▼                                       ▼
      [[dynamic-workflows]]                      meta-harness
   harness를 태스크마다 새로 쓴다              harness를 교체 가능하게 만든다
                │                                       │
   주체: 모델이 실행 시점에 작성               주체: 플랫폼이 경계선을 고정
   수명: 그 태스크 동안 (저장은 가능)           수명: harness들보다 길게
   해결: 태스크 적합성                          해결: 시간에 따른 노후화
```

**대체재가 아니다.** 소스 본문이 직접 화해시킨다 — Claude Code를 *"an excellent harness"* 라고 부르고, 태스크 전용 harness가 좁은 도메인에서 뛰어나다는 것도 인정하며, **Managed Agents가 그중 무엇이든 수용한다**고 말한다. dynamic workflow가 쓰는 harness도 meta-harness 위에 얹힐 수 있는 한 종류다.

층위로 보면:

```
meta-harness        ← 인터페이스 (session / harness / sandbox). 가장 느리게 변함
  └─ harness        ← Claude Code, 태스크 전용 harness, dynamic workflow가 쓴 프로그램
       └─ prompt    ← 가장 빠르게 변함
```

이 층위 구분은 [[subagent]]가 기록한 **조정 주체의 네 층위**(사람 / lead agent / 프로그램 / …)와 직교한다. 그쪽은 *누가 조정하는가*를, 이쪽은 *무엇이 얼마나 오래 사는가*를 나눈다.

## 한계와 읽을 때의 주의

- **유비의 성공 조건은 증명되지 않았다.** OS 유비의 설득력은 `process`/`file`이 실제로 오래 살아남았다는 **사후적** 사실에서 온다. session/harness/sandbox가 그만큼 잘 고른 추상인지는 이 글이 증명할 수 없다. meta-harness 설계도 결국 **"이 세 경계는 안 썩는다"는 가정**을 하나 더 만든 것이고, 그 가정도 같은 종류의 노후화에 노출된다.
- **검증 가능한 수치는 TTFT 하나뿐이다.** 나머지는 전부 설계 논증이다. 안정성·복구율·보안 사고 감소 같은 지표는 제시되지 않는다.
- **출처 편중.** [[anthropic]]이 자사 플랫폼 제품을 설명하는 글이다. 중심 전제(*모델은 계속 좋아진다*)의 이해관계자가 저자와 같다. 반례(context reset)가 구체적이라 주장 자체는 튼튼하지만, 외부 검증은 없다.
- **적용 범위 주의.** 이 처방은 **호스팅 플랫폼을 만드는 쪽**의 문제 설정에서 나왔다 — 남의 워크로드를 임의의 인프라 위에서 오래 돌려야 하는 상황. 단일 팀이 자기 에이전트 하나를 돌린다면 인터페이스 분리의 비용(서비스 경계, 네트워크 홉, 이벤트 로그 저장)이 이득보다 클 수 있다. *"파일 편집이 직접 syscall이고 설계할 서비스 경계가 없다"* 던 초기 설계의 이점은 실재했다.

## Related

- [[managed-agents]] — 이 개념의 유일한 구현 사례이자 1차 출처의 대상
- [[dynamic-workflows]] — 같은 문제의 반대 방향 처방. 대체재가 아니라 다른 층위
- [[claude-code]] — meta-harness 위에 얹힐 수 있는 harness 중 하나로 위치 지어진다
- [[agentic-governance]] — 통제 표면의 구체. 이 페이지는 그 위의 판별 기준("이 방어는 모델 능력의 함수인가")을 더한다
- [[artifact-chain]] — 상태를 구성요소 밖 파일로 빼 결합을 끊는 같은 처방의 다른 층위
- [[subagent]] — 조정 주체의 층위 구분. "brain끼리 hand를 넘긴다"가 그 페이지의 단정과 만나는 지점
- [[orchestrator-worker]] — 조정 상태가 lead의 context window에 사는 구조. 세션 로그는 그것을 창 밖으로 뺀다
- [[multi-agent-systems]] — 많은 brain으로 스케일할 때의 경제성

## Sources

- [[2026-04-08-scaling-managed-agents]] — Lance Martin, Gabe Cemaj, Michael Cohen (Anthropic Engineering, 2026-04-08). 이 페이지 전체의 1차 출처
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). "dynamic workflow와의 대비" 절
