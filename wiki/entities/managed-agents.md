---
title: Managed Agents
type: entity
created: 2026-09-21
updated: 2026-09-21
sources: [2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude]
tags: [managed-agents, anthropic, claude-platform, meta-harness, product, sandbox, session-log]
status: draft
---

# Managed Agents

> Claude Platform의 **호스팅 에이전트 서비스.** 장기 작업(long-horizon) 에이전트를 Anthropic이 대신 돌려준다. 제품으로서의 특징은 기능 목록이 아니라 **스스로에 대해 의견을 갖지 않는다는 점**이다 — 특정 harness에 대해 중립이고, 고정하는 것은 그 주변의 세 인터페이스뿐이다.

> ℹ️ **범위 주의:** 이 페이지는 [[2026-04-08-scaling-managed-agents]] 한 편에만 기반한다. 그 글은 **아키텍처 회고**이지 제품 문서가 아니므로, 가격·한도·SDK 표면·가용성 같은 것은 여기 없다. 공식 문서는 [platform.claude.com/docs — managed-agents](https://platform.claude.com/docs/en/managed-agents/overview).

## Overview

Managed Agents는 [[anthropic]]이 Claude Platform 안에서 제공하는 서비스로, **긴 시간 지평의 에이전트 작업을 사용자 대신 실행한다.** 설계 목표가 특이하다 — 오늘 Anthropic이 돌리는 구현을 포함해 **어떤 특정 구현보다도 오래 가도록 만들어진 소수의 인터페이스**를 통해 동작하는 것.

그 설계 사상이 [[meta-harness]]이고, Managed Agents는 이 위키가 아는 유일한 구현 사례다. 저자들의 표현:

> *"Managed Agents is a meta-harness in the same spirit, unopinionated about the specific harness that Claude will need in the future."*

## 세 인터페이스

에이전트를 세 조각으로 virtualize하고, 각각이 나머지를 건드리지 않고 교체될 수 있게 한다.

| | 무엇인가 | 노출된 호출 |
|---|---|---|
| **session** | 일어난 모든 것의 append-only 이벤트 로그 | `getSession(id)` — 로그 전체를 되받음<br>`getEvents()` — 위치 기반 슬라이스<br>`emitEvent(id, event)` — durable 기록 |
| **harness** | Claude를 호출하고 tool call을 인프라로 라우팅하는 루프 | `wake(sessionId)` — crash 후 새 harness 기동 |
| **sandbox** | Claude가 코드를 돌리고 파일을 편집하는 실행 환경 | `execute(name, input) → string`<br>`provision({resources})` |

`execute(name, input) → string`이 이 서비스의 중심 인터페이스다. **모든 hand가 이 모양**이다 — 자사 sandbox든, 임의의 커스텀 도구든, 임의의 MCP 서버든. 그래서 harness는 상대가 무엇인지 알 필요가 없다:

> *"The harness doesn't know whether the sandbox is a container, a phone, or a Pokémon emulator."*

## 아키텍처의 성질

이 서비스가 내세우는 운영 특성들. 각 항목의 설계 논증은 [[meta-harness]]에 있다.

- **컨테이너는 cattle이다.** 죽으면 harness가 tool-call 에러로 받아 Claude에게 넘긴다. Claude가 재시도를 택하면 표준 레시피로 새로 provision한다. 간호하지 않는다.
- **harness도 cattle이다.** 세션 로그가 harness 밖에 있어 harness 안에는 crash를 견뎌야 할 것이 없다. 실패하면 `wake(sessionId)` → `getSession(id)` → 마지막 이벤트부터 재개.
- **컨테이너는 필요할 때만 뜬다.** sandbox를 쓰지 않는 세션은 컨테이너를 기다리지 않는다. 추론은 오케스트레이션 레이어가 대기 이벤트를 가져오는 즉시 시작된다. → **p50 TTFT 약 60% 감소, p95 90% 이상 감소** (내부 측정, 워크로드 구성 비공개)
- **고객 VPC 연결이 가능하다.** harness가 컨테이너 밖으로 나오면서 "작업 대상이 나와 같은 곳에 있다"는 가정이 사라졌다. 초기 설계에서는 네트워크 peering이나 고객 환경에서의 harness 직접 운용이 유일한 경로였다.
- **brain끼리 hand를 넘길 수 있다.** 어떤 hand도 특정 brain에 결합되어 있지 않다.
- **세션은 context window와 별개다.** 컨텍스트가 창 밖 durable 로그에 살고 `getEvents()`로 슬라이스해 되가져온다. 가져온 이벤트의 변형(prompt cache 최적화, context engineering)은 harness의 몫으로 남긴다.

## 자격증명 처리

에이전트에 자격증명을 주는 두 경로를 지원하며, 공통 원칙은 **토큰이 sandbox에서 닿을 수 없어야 한다**는 것이다. 근거는 [[meta-harness]]의 "보안 경계" 절, 통제 표면 일반은 [[agentic-governance]].

- **Git** — sandbox 초기화 시점에 repo access token으로 clone하고 그 토큰을 local git remote에 배선한다. 이후 `push`/`pull`은 **에이전트가 토큰을 한 번도 만지지 않고** 동작한다.
- **커스텀 도구** — MCP를 지원하고 OAuth 토큰은 sandbox 밖 vault에 둔다. Claude는 전용 **프록시**를 통해 MCP 도구를 부르고, 프록시가 세션에 연결된 토큰을 받아 vault에서 해당 자격증명을 꺼내 외부 서비스를 호출한다. **harness조차 자격증명의 존재를 통보받지 않는다.**

> **자매 사례 (2026-09-21).** [[2026-05-25-how-we-contain-claude]]가 Cowork에서 같은 원리를 다른 형태로 구현한다 — 자격증명은 **호스트 keychain**에 남고 게스트 VM에 들어가지 않으며, VM은 **세션별 스코프다운 토큰**을 받는다. 그 토큰은 **사용자 것과 독립적으로 폐기 가능하다.**
>
> 그리고 그쪽이 **이 페이지의 프록시 설계에 대칭인 교훈**을 준다. 여기서 프록시가 sandbox *밖*에 있는 이유는 비밀을 **안 보이게** 하기 위해서다. Cowork의 방어적 MITM 프록시는 VM *안*에 있는데, 이유는 반대다 — **provenance를 아는 것이 VM뿐**이기 때문이다(서버 입장에서 Cowork 요청은 다른 API 클라이언트와 구별되지 않는다). **경계를 어디 두느냐는 "누가 맥락을 아는가"로 정해진다.**
>
> ⚠️ 그쪽에서 실패한 것도 같은 계열이다. egress allowlist가 자사 API 도메인을 통과시켰고 공격자가 심은 키로 데이터가 나갔다. **allowlist는 목적지 필터가 아니라 capability grant다.** 이 페이지의 프록시도 같은 질문을 받는다 — *세션 토큰으로 도달 가능한 기능의 집합은 정확히 무엇인가?* 소스는 답하지 않는다. → [[prompt-injection]]

## Claude Code와의 관계

같은 층위의 제품이 아니다. [[claude-code]]는 **하나의 harness**이고 Managed Agents는 **harness가 꽂히는 자리**다. 글이 명시적으로 이렇게 위치시킨다:

> *"Claude Code is an excellent harness that we use widely across tasks. We've also shown that task-specific agent harnesses excel in narrow domains. Managed Agents can accommodate any of these."*

```
Managed Agents (meta-harness)
  ├─ Claude Code                     ← 범용, 코딩 중심
  ├─ 태스크 전용 harness             ← 좁은 도메인에서 뛰어남
  └─ [[dynamic-workflows]]가 쓴 프로그램  ← 태스크마다 생성
```

## 열린 질문

이 소스만으로는 답할 수 없는 것들 — 다음 소스나 공식 문서가 필요하다.

- **어떤 harness를 실제로 가져다 쓸 수 있는가?** "어떤 harness든 수용한다"가 사용자가 임의의 harness를 배포할 수 있다는 뜻인지, Anthropic이 고른 harness 중 선택하는 것인지 글은 말하지 않는다.
- **`getEvents()`의 슬라이스는 누가 결정하는가?** Claude가 직접 호출하는지, harness가 정책으로 부르는지 불명확하다. "the brain to interrogate context"라는 표현은 전자를 시사하지만 단정할 수 없다.
- **세션 로그의 보존 기간·비용 모델.** durable 저장이 전제인데 한도가 언급되지 않는다.
- **세션 토큰으로 도달 가능한 기능의 집합은 정확히 무엇인가?** capability grant 관점([[prompt-injection]])에서 이 vault·프록시 설계를 검증하려면 필요한데, 소스는 토큰의 존재만 말하고 그 권한 범위를 말하지 않는다.
- **many hands를 쓸 때 Claude가 라우팅에 실패하면?** "어디로 일을 보낼지 고르는 것이 어려운 인지 과제"라고 인정하면서 그 실패 모드는 다루지 않는다.

## Related

- [[meta-harness]] — 이 제품의 설계 사상. 왜 이 세 인터페이스인지의 논증
- [[claude-code]] — 이 위 또는 밖에서 도는 harness. 경쟁 제품이 아니라 다른 층위
- [[dynamic-workflows]] — 여기 얹힐 수 있는 harness를 모델이 직접 쓰는 접근
- [[agentic-governance]] — 자격증명·통제 표면의 일반 원리
- [[agent-containment]] — 같은 원리의 클라이언트측 구현 세 가지. 여기와 대칭인 프록시 설계
- [[prompt-injection]] — 이 격리가 막으려는 공격면
- [[anthropic]] — 발행·운영 주체
- [[multi-agent-systems]] — many brains로 스케일할 때의 경제성

## Sources

- [[2026-04-08-scaling-managed-agents]] — Lance Martin, Gabe Cemaj, Michael Cohen (Anthropic Engineering, 2026-04-08)
- [[2026-05-25-how-we-contain-claude]] — Max McGuinness 외 4인 (Anthropic Engineering, 2026-05-25). 자격증명 처리 절의 자매 사례
