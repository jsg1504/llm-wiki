---
title: "Scaling Managed Agents: Decoupling the brain from the hands"
type: source
created: 2026-09-21
updated: 2026-09-21
source_file: ../../raw/articles/2026-04-08-scaling-managed-agents.md
source_url: https://www.anthropic.com/engineering/managed-agents
author: Lance Martin, Gabe Cemaj, Michael Cohen
source_date: 2026-04-08
tags: [managed-agents, meta-harness, agentic-harness, sandbox, session-log, context-engineering, security, anthropic]
status: mature
---

# Scaling Managed Agents: Decoupling the brain from the hands

> Harness는 "Claude가 아직 못 하는 것"에 대한 가정의 집합이고, 그 가정은 모델이 좋아지면 썩는다. 그러므로 더 좋은 harness를 만들 게 아니라 **harness보다 오래 사는 인터페이스**를 만들어야 한다 — session / harness / sandbox 셋으로 에이전트를 virtualize한 것이 Managed Agents다.

## Context

Anthropic Engineering 블로그(2026-04-08). Lance Martin, Gabe Cemaj, Michael Cohen 공저.
[[managed-agents]]라는 Claude Platform 호스팅 서비스를 만들며 겪은 아키텍처 전환의 회고다. 같은 블로그의 "building effective agents", "effective harnesses for long-running agents", "harness design for long-running apps" 계열을 잇는 글이라고 스스로 위치시킨다.

성격은 **제품 발표를 겸한 인프라 회고**다. 실패한 초기 설계(모든 것을 한 컨테이너에)를 구체적으로 공개하고, 왜 그것이 무너졌는지를 pets-vs-cattle 유비로 설명한 뒤, 현재 설계를 정당화한다. 정량 데이터는 TTFT 개선 수치 하나뿐이고 나머지는 설계 논증이다.

## Key Claims

1. **Harness는 가정의 집합이고 가정은 노후화한다.** *"harnesses encode assumptions about what Claude can't do on its own."* 저자들은 이를 Bitter Lesson과 연결한다. 구체적 증거: Sonnet 4.5가 컨텍스트 한계를 감지하면 작업을 조기 종료하는 **"context anxiety"** 를 보여 harness에 context reset을 넣었는데, 같은 harness를 **Opus 4.5**에 쓰자 그 행동이 사라져 있었다. *"The resets had become dead weight."*

2. **해법은 OS의 방식 — "아직 생각되지 않은 프로그램(programs as yet unthought of)"을 위한 설계.** 수십 년 전 OS는 하드웨어를 *process*, *file* 같은 추상으로 virtualize해서, 아직 존재하지 않는 프로그램까지 수용했다. `read()`는 1970년대 디스크 팩이든 현대 SSD든 무관하다. **추상이 하드웨어보다 오래 살아남았다.** Managed Agents는 같은 패턴으로 에이전트를 셋으로 virtualize한다:
   - **session** — 일어난 모든 것의 append-only 로그
   - **harness** — Claude를 호출하고 Claude의 tool call을 인프라로 라우팅하는 루프
   - **sandbox** — Claude가 코드를 돌리고 파일을 편집하는 실행 환경

   *"We're opinionated about the shape of these interfaces, not about what runs behind them."*

3. **"pet을 기르지 마라" — 단일 컨테이너 설계가 무너진 두 가지 방식.** 처음엔 session·harness·sandbox를 한 컨테이너에 넣었다. 이점은 있었다(파일 편집이 직접 syscall, 설계할 서비스 경계 없음). 그러나:
   - **서버가 pet이 됐다.** 컨테이너가 죽으면 세션이 사라지고, 응답하지 않으면 되살려야 했다. 게다가 유일한 관찰 창이 WebSocket 이벤트 스트림이라 *어디서* 실패했는지 알 수 없었다 — **harness 버그·패킷 드롭·컨테이너 오프라인이 전부 똑같이 보였다.** 원인을 알려면 컨테이너에 셸을 열어야 하는데 거기 사용자 데이터가 있어서, 사실상 **디버깅 능력이 없었다.**
   - **VPC 연결이 막혔다.** harness가 "Claude가 작업하는 대상은 나와 같은 컨테이너에 있다"고 가정했으므로, 고객사 VPC의 자원에 붙이려면 네트워크를 peering하거나 고객이 harness를 자기 환경에서 돌려야 했다.

4. **brain / hands / session 분리.** "brain"(Claude와 harness)을 "hands"(sandbox와 도구)와 "session"(이벤트 로그)에서 떼어낸다. 셋 각각이 서로에 대해 거의 가정하지 않는 인터페이스가 되고, **독립적으로 실패하거나 교체될 수 있다.**
   - **harness가 컨테이너를 떠난다.** 컨테이너를 다른 도구와 똑같이 호출한다 — `execute(name, input) → string`. 컨테이너는 cattle이 된다. 죽으면 harness가 **tool-call 에러로 받아 Claude에게 되돌려준다.** Claude가 재시도를 택하면 `provision({resources})`로 표준 레시피에 따라 새 컨테이너를 올린다.
   - **harness도 cattle이 된다.** 세션 로그가 harness 밖에 있으므로 harness 안에는 crash를 견뎌야 할 것이 없다. 실패하면 `wake(sessionId)`로 새로 띄우고 `getSession(id)`로 이벤트 로그를 되받아 마지막 이벤트부터 재개한다. 루프 도중에는 `emitEvent(id, event)`로 durable한 기록을 남긴다.

5. **보안 경계: "좁은 스코프"는 가정이고, "도달 불가"가 구조다.** 결합 설계에서는 Claude가 생성한 미신뢰 코드가 자격증명과 같은 컨테이너에서 돌았다. 그래서 prompt injection은 *Claude에게 자기 환경을 읽도록 설득하기만* 하면 됐다. 토큰을 얻은 공격자는 **제약 없는 새 세션을 띄워 거기에 일을 위임할 수 있다.** 좁은 스코핑은 명백한 완화책이지만, *"이것은 Claude가 제한된 토큰으로 무엇을 할 수 없는지에 대한 가정을 인코딩하는 것이고 — Claude는 점점 똑똑해지고 있다."* 구조적 해결은 **토큰이 sandbox에서 애초에 닿을 수 없게** 만드는 것. 두 패턴:
   - **자원에 auth를 번들.** Git은 sandbox 초기화 시점에 repo의 access token으로 clone하고 그것을 local git remote에 배선한다. 이후 `push`/`pull`은 **에이전트가 토큰을 한 번도 만지지 않고** 동작한다.
   - **sandbox 밖 vault + 프록시.** 커스텀 도구는 MCP로 지원하고 OAuth 토큰은 vault에 둔다. Claude는 전용 프록시를 통해 MCP 도구를 부르고, 프록시가 세션에 연결된 토큰을 받아 vault에서 해당 자격증명을 꺼내 외부 서비스를 호출한다. **harness는 자격증명의 존재를 통보받지 않는다.**

6. **세션은 Claude의 context window가 아니다.** 장기 작업은 context window를 넘기고, 이를 다루는 표준 방법들(compaction, memory tool, trimming)은 **전부 되돌릴 수 없는 보존/폐기 결정**을 수반한다. *"미래의 턴이 어떤 토큰을 필요로 할지 알기 어렵다."* compaction이 메시지를 변형하면 harness는 원본을 context window에서 제거하고, 따로 저장해두지 않는 한 복구할 수 없다. 선행 연구는 컨텍스트를 **context window 밖의 객체**로 두는 접근(예: REPL 안의 객체를 LLM이 코드로 filter·slice)을 탐구해 왔다.
   Managed Agents에서는 **session이 그 객체**다. 단 sandbox나 REPL이 아니라 세션 로그에 durable하게 저장된다. `getEvents()`는 이벤트 스트림의 **위치 기반 슬라이스**를 허용한다 — 마지막으로 읽은 곳부터 잇기, 특정 순간 직전 몇 개를 되감아 정황 보기, 어떤 행동 전의 컨텍스트 다시 읽기.
   가져온 이벤트는 Claude의 context window에 들어가기 전에 **harness에서 변형될 수 있다.** prompt cache hit rate를 높이는 컨텍스트 정렬이든 다른 context engineering이든, harness가 인코딩하는 무엇이든. 관심사를 이렇게 나눈 이유는 명시적이다 — *"미래 모델에 어떤 context engineering이 필요할지 예측할 수 없기 때문."* 인터페이스는 **세션이 durable하고 interrogable하다는 것만 보장한다.**

7. **Many brains — 그리고 TTFT 수치.** brain을 컨테이너에 두면 brain 수만큼 컨테이너가 필요했고, 그 컨테이너가 provision될 때까지 추론이 시작되지 못했다. **sandbox를 영영 쓰지 않을 세션도** repo clone·프로세스 부팅·대기 이벤트 fetch를 선불했다. 이 죽은 시간이 **TTFT**(작업을 받고 첫 응답 토큰을 내기까지)로 나타나며, 저자들은 이것을 *사용자가 가장 예민하게 느끼는 지연*이라고 말한다.
   분리 후에는 컨테이너가 **필요할 때만** brain의 tool call(`execute(name, input) → string`)로 provision된다. 추론은 오케스트레이션 레이어가 세션 로그에서 대기 이벤트를 가져오는 즉시 시작된다. **p50 TTFT 약 60% 감소, p95 90% 이상 감소.** 많은 brain으로 스케일하는 것은 곧 stateless harness를 많이 띄우고 필요할 때만 hand에 연결하는 일이 된다.

8. **Many hands — 인텔리전스가 올라가면서 가능해진 쪽.** 여러 실행 환경을 놓고 어디로 일을 보낼지 판단하는 것은 단일 셸에서 작업하는 것보다 어려운 인지 과제다. **초기 모델이 이것을 못 했기 때문에** 단일 컨테이너로 시작했다. 그러나 인텔리전스가 스케일하자 단일 컨테이너가 오히려 제약이 됐다 — 그 컨테이너가 죽으면 brain이 뻗고 있던 **모든 hand의 상태가 함께 사라졌다.**
   분리하면 각 hand가 `execute(name, input) → string`이라는 도구가 된다. 이름과 입력이 들어가고 문자열이 나온다. 이 인터페이스는 임의의 커스텀 도구, 임의의 MCP 서버, 자사 도구를 모두 받는다. *"harness는 sandbox가 컨테이너인지, 휴대폰인지, 포켓몬 에뮬레이터인지 모른다."* 그리고 어떤 hand도 특정 brain에 결합되어 있지 않으므로, **brain끼리 hand를 서로 넘겨줄 수 있다.**

9. **Managed Agents는 meta-harness다.** *특정* harness에 대해 의견을 갖지 않는다. 저자들은 Claude Code를 *"an excellent harness that we use widely across tasks"* 라고 부르고, 태스크 전용 harness가 좁은 도메인에서 뛰어나다는 것도 인정하며, **Managed Agents가 그 어느 쪽도 수용한다**고 말한다. 의견을 갖는 대상은 Claude 주변의 **인터페이스**뿐이다 — Claude는 상태를 조작할 수 있어야 하고(session), 계산을 수행할 수 있어야 하고(sandbox), 많은 brain과 hand로 스케일할 수 있어야 한다. **그 brain과 hand가 몇 개인지, 어디 있는지에 대해서는 아무 가정도 하지 않는다.**

## Notable Quotes / Passages

> "harnesses encode assumptions about what Claude can't do on its own. However, those assumptions need to be frequently questioned because they can go stale as models improve."

> "The resets had become dead weight."

컨테이너가 pet이던 시절의 관측 불능에 대해:

> "our only window in was the WebSocket event stream, but that couldn't tell us *where* failures arose, which meant that a bug in the harness, a packet drop in the event stream, or a container going offline all presented the same."

보안 경계가 왜 스코핑이 아니라 도달 불가여야 하는지:

> "Narrow scoping is an obvious mitigation, but this encodes an assumption about what Claude can't do with a limited token—and Claude is getting increasingly smart. The structural fix was to make sure the tokens are never reachable from the sandbox where Claude's generated code runs."

인터페이스가 무엇을 보장하지 *않는지*:

> "We separated the concerns of recoverable context storage in the session and arbitrary context management in the harness because we can't predict what specific context engineering will be required in future models."

hand의 불가지성:

> "The harness doesn't know whether the sandbox is a container, a phone, or a Pokémon emulator."

## Connections

- 이 소스는 [[meta-harness]]라는 개념의 1차 출처다.
- [[managed-agents]]라는 제품의 아키텍처 문서다.
- [[dynamic-workflows]]와 **같은 문제에 반대 방향의 처방**을 낸다 — 한쪽은 harness를 태스크마다 새로 쓰고, 다른 쪽은 harness를 교체 가능하게 만든다. 소스 본문이 둘을 직접 화해시킨다(결론부).
- [[claude-code]]를 *"an excellent harness"* — 즉 meta-harness 위에 얹힐 수 있는 여러 harness 중 하나로 위치시킨다.
- [[agentic-governance]]에 자격증명 격리의 **구조적** 논거를 더한다.
- [[subagent]]·[[multi-agent-systems]]의 스케일링 논의에 **인프라 층위**를 더한다.
- [[anthropic]]이 발행한 네 번째 소스.

## My Notes

**이 소스의 가장 이식 가능한 아이디어는 6번(세션 ≠ 컨텍스트 윈도)이다.** 위키에는 이미 *compaction은 lossy하고 그래서 goal drift가 생긴다*는 실이 [[dynamic-workflows]]·[[orchestrator-worker]]·[[multi-agent-systems]]·[[subagent]] 네 페이지에 흩어져 있다. 기존에 기록된 처방은 둘이었다 — **(a) 잘 요약한다**(compaction 자체), **(b) 애초에 compaction에 도달하지 않는다**(subagent 격리). 이 소스는 세 번째를 더한다: **(c) 폐기 결정을 되돌릴 수 있게 만든다.** 창 밖에 durable하게 두고 필요할 때 슬라이스해서 다시 가져온다. 앞의 둘과 배타적이지 않다.

**2번(OS 유비)은 수사가 아니라 이 글의 설계 논증 전체다.** "인터페이스의 모양에는 의견이 있고 뒤에 무엇이 도는지에는 없다"는 문장이 나머지 모든 선택을 설명한다. 다만 **유비의 성공 조건은 인터페이스를 맞게 골랐느냐**이고, 그것은 글이 증명할 수 없는 부분이다. `process`/`file`이 살아남은 것은 사후적으로 안 사실이다. session/harness/sandbox가 그만큼 오래갈지는 열린 질문이다.

**5번은 이 위키의 보안 서술을 한 단계 위로 올린다.** [[agentic-governance]]와 [[claude-code]]는 지금까지 `permissions.deny`, sandbox, `credentials` 같은 **설정 표면** 중심으로 기술되어 있다. 이 소스의 논지는 그 위에 얹히는 판단 기준이다 — *어떤 방어가 "Claude가 X를 못 한다"는 가정에 의존하는가?* 그런 방어는 모델이 좋아질수록 약해진다. 토큰을 아예 다른 신뢰 경계에 두는 것만이 그 함수에서 벗어난다. (`raw/articles/2026-05-25-how-we-contain-claude.md`가 아직 ingest되지 않은 채 대기 중이므로, 이 실은 다음 ingest에서 깊어질 가능성이 높다.)

**정량 근거의 무게는 가볍다.** 전체에서 검증 가능한 숫자는 TTFT 개선(p50 −60%, p95 −90%+) 하나다. 그마저 내부 측정이고 비교 대상 워크로드의 구성이 공개되어 있지 않다. "sandbox를 쓰지 않는 세션이 컨테이너 부팅을 선불했다"는 설명을 보면 **그런 세션의 비중이 높을수록 개선폭이 커지는 지표**이므로, 60%/90%는 아키텍처의 우월성보다 워크로드 믹스를 반영할 수 있다. 나머지 주장은 전부 설계 논증이다.

**⚠️ 8번은 [[subagent]]의 한 단정과 부딪힌다 (경미).** [[subagent]]는 *"subagent끼리 협력할 수 없다 — 네 층위 전부에서 그렇다, 반환은 부모(또는 프로그램)에게만 간다"*고 적고 있다. 이 소스의 *"brains can pass hands to one another"*는 직접적인 모순은 아니다 — sandbox를 넘기는 것은 에이전트 간 메시징이 아니라 **공유 자원의 양도**이고, 이벤트는 여전히 세션 로그로 간다. 다만 위키가 "없다"고 단정한 에이전트 간 채널의 한 종류이므로 양쪽을 병기하는 것이 맞다.

**소스 편중은 더 심해졌다.** 이 위키의 소스가 이제 **4개 중 4개 Anthropic**이다. 특히 "harness 가정이 노후화한다"는 이 글의 중심 주장은 *"모델이 계속 좋아진다"*를 전제하며, 그 전제의 이해관계자가 저자와 같다. 주장 자체는 설득력 있고 반례(context reset)도 구체적이지만, 외부 검증은 여전히 없다.

## Raw Source

[원본 파일](../../raw/articles/2026-04-08-scaling-managed-agents.md) · [anthropic.com/engineering/managed-agents](https://www.anthropic.com/engineering/managed-agents)
