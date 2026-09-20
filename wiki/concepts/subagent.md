---
title: Subagent
type: concept
created: 2026-09-12
updated: 2026-09-21
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude]
tags: [multi-agent, agent-design, context-window, orchestration, agentic-coding]
status: draft
---

# Subagent

> 부모 에이전트가 호출하는, **자기 컨텍스트 윈도와 제한된 도구를 가진 하위 에이전트.** 공통 효용은 하나다 — 부모의 컨텍스트를 채우지 않고 일을 대신 해서 **결과만 압축해 올린다.** 이 위키의 소스들이 서로 다른 도메인(리서치 / 코딩)에서, 그리고 서로 다른 **조정 주체** 아래서 같은 장치를 쓰므로, 이 페이지는 그 용어를 정렬한다.

## Overview

`subagent`는 이 위키에서 **두 클러스터를 가로지르는 유일한 용어**다. [[multi-agent-systems]] 쪽에서는 리서치 병렬 탐색의 단위로, [[ai-native-sdlc]] 쪽에서는 코딩 세션 내부의 스코프된 헬퍼로 등장한다. 같은 단어가 다른 것을 가리키는 것은 아니지만, **조정 주체와 목적이 다르다.**

공통 정의는 세 가지로 좁혀진다:

1. **독립 context window** — 부모의 컨텍스트를 소비하지 않는다.
2. **제한된 도구 표면** — 무엇을 건드릴 수 있는지가 정의에 박혀 있다.
3. **압축된 반환** — 탐색 과정 전체가 아니라 결론만 부모에게 올라간다.

세 번째가 존재 이유다. 부모가 직접 탐색하면 컨텍스트가 중간 산물로 가득 차지만, subagent를 쓰면 **탐색의 비용은 다른 컨텍스트에서 치르고 결과만 받는다.**

## 두 갈래

| | **리서치형** ([[2025-06-13-multi-agent-research-system]]) | **코딩형** ([[2026-08-21-the-ai-native-sdlc-playbook]]) |
|---|---|---|
| 정의 위치 | lead agent가 **런타임에 동적으로** 생성 | `.claude/agents/<name>.md`에 **사전 정의**, git에 체크인 |
| 개수 | 쿼리 복잡도에 따라 1~10+ (보통 병렬 3-5) | 역할별로 소수, 필요할 때 호출 |
| 태스크 | lead가 objective·output format·도구·경계를 기술해 위임 | 정의 파일의 description이 언제 쓰일지를 말함 |
| 대표 역할 | 주제의 한 측면을 맡아 웹 검색 | **verifier**(신선한 컨텍스트로 최종 확인), **researcher**(메인 컨텍스트를 채우지 않고 코드베이스 탐색), **code simplifier**(불필요한 복잡도 제거) |
| 목적 | **처리량** — 한 질문을 넓게 병렬 탐색 | **집중** — 세션이 자기 본 작업에서 벗어나지 않게 |

**차이의 핵심:** 리서치형은 *분업*을 위해, 코딩형은 *오염 방지*를 위해 쓴다. `researcher` subagent가 메인 컨텍스트를 채우지 않고 탐색해 보고하는 것, `verifier`가 *"판정이 코드를 만든 가정에 오염되지 않도록"* 신선한 컨텍스트로 한 번 도는 것 — 둘 다 압축이지만 목적이 다르다.

## 위임에는 사양이 필요하다

리서치형에서 확인된 규칙이지만 코딩형에도 그대로 적용된다. 태스크 기술이 부실하면 **중복 수행·누락·오해**가 즉시 발생한다. 최소 네 슬롯:

| 슬롯 | 내용 |
|---|---|
| objective | 무엇을 알아내야 하는가 |
| output format | 어떤 형태로 돌려줘야 하는가 |
| tools / sources | 무엇을 쓸 것인가 |
| task boundaries | 어디까지가 내 몫인가 |

실패 사례: "반도체 부족 사태를 조사해"라는 짧은 지시에 subagent 3개 중 1개는 2021 자동차 칩 위기를, 나머지 2개는 똑같이 2025 공급망을 조사했다. 자세한 위임 지침은 [[orchestrator-worker]].

## 반환 경로: 부모를 거칠 것인가

subagent의 결과가 전부 부모를 통과하면 두 가지가 나빠진다 — **정보가 손실되고**(*"game of telephone"*) 큰 출력이 대화 히스토리에 복사되며 **토큰을 낭비한다.**

완화책은 **subagent가 산출물을 외부(파일시스템 등)에 저장하고 부모에게는 가벼운 참조만 넘기는 것**이다. 코드·리포트·데이터 시각화처럼 구조화된 산출물에 특히 잘 맞는다.

> 이 패턴은 [[artifact-chain]]의 명제 — *"에이전트는 stateless다. 커밋된 아티팩트가 세션 사이에 살아남는 유일한 기억이다"* — 와 **같은 통찰의 두 표현**이다. 한쪽은 단일 세션 내부의 토큰 손실을, 다른 쪽은 세션 사이의 기억 손실을 말하지만, 처방은 동일하다: **대화가 아니라 파일이 인터페이스가 되게 하라.**

## 인접 개념과의 구분 (혼동 주의)

네 가지가 자주 뒤섞여 쓰인다. 이 위키에서는 다음과 같이 구분한다:

| | 무엇인가 | 조정 주체 | 서로를 아는가 |
|---|---|---|---|
| **subagent** | 한 세션/한 lead 안에서 도는 하위 에이전트 | 부모 에이전트 | 아니오 (부모를 통해서만) |
| **병렬 세션 (worktree)** | 각자의 git worktree에서 도는 **완전한 독립 인스턴스** | **사람** | 아니오 — *"공유하는 것은 그것들을 조종하는 엔지니어뿐"* |
| **에이전트 간 실시간 위임** | 에이전트가 다른 에이전트에게 동적으로 조율·위임 | 에이전트 | 예 (이론상) |
| **dynamic workflow** | 에이전트가 **쓴 결정론적 프로그램**이 subagent를 spawn·조율 | **프로그램 (코드)** | 아니오 — 프로그램이 결과를 모은다 |

세 번째는 **아직 잘 안 된다고 보고된 것**이다 — *"LLM agents are not yet great at coordinating and delegating to other agents in real time"* (2025-06). 병렬 세션은 이것이 **아니다.** 세션들은 서로를 모르고 사람이 조종하며, 천장도 *"한 사람이 제대로 리뷰할 수 있는 스트림 수"*로 사람에게 묶여 있다.

**네 번째는 세 번째처럼 보이지만 아니다.** [[dynamic-workflows]]에서 조정을 하는 것은 에이전트가 아니라 **에이전트가 작성한 결정론적 JavaScript 프로그램**이다. 조정 상태(누가 무엇을 했고 다음은 무엇인가)가 어떤 LLM의 context window에도 살지 않고 프로그램 변수에 산다 — *"the deterministic loop holds the bracket and only the running order stays in context"* ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]). LLM이 판단하는 것은 *harness를 한 번 쓰는 일*뿐이고, 실행 중의 조율은 코드가 한다.

**조정 상태가 어디 사는가**로 보면 네 층위가 한 줄로 정렬된다:

| | 조정 상태의 거처 | 조정 능력의 한계 |
|---|---|---|
| subagent (orchestrator-worker) | 부모 LLM의 context window | 부모의 컨텍스트가 차면 열화. compaction이 lossy |
| 병렬 세션 | 사람의 머리 | *"한 사람이 제대로 리뷰할 수 있는 스트림 수"* |
| 에이전트 간 실시간 위임 | 에이전트들 사이 (합의) | *"not yet great"* — 보고된 미성숙 |
| dynamic workflow | **프로그램 변수 (컨텍스트 밖)** | 정지 조건을 **미리 표현할 수 있어야** 한다 |

> **네 층위 모두가 공유하는 취약점 하나:** 조정 상태가 **휘발성**이라는 것. 부모 컨텍스트도, 사람의 머리도, 프로그램 변수도 프로세스가 죽으면 같이 죽는다. [[2026-04-08-scaling-managed-agents]]가 보여주는 다섯 번째 선택지는 조정의 *주체*가 아니라 **거처**를 바꾼다 — 상태를 append-only 이벤트 로그에 durable하게 두고, harness가 crash하면 `wake(sessionId)` → `getSession(id)`로 마지막 이벤트부터 재개한다. 조정을 *누가* 하느냐(이 표의 축)와 그것이 *어디 살아남느냐*는 직교하는 질문이고, 이 위키의 세 소스는 후자를 다루지 않았다. → [[meta-harness]]
>
> 단 이 소스는 **단일 brain의 세션 복구**를 설명하지, 여러 subagent를 조율하는 스키마를 제시하지 않는다. 위 표의 다섯 번째 행이 되기에는 근거가 부족하다.

> ✅ **판정 (2026-09-12):** [[multi-agent-systems]]의 모순은 **두 축으로 나뉘어 부분 판정됐다.**
>
> - **적합성 축** — 코딩에서 에이전트를 여럿 조정하는 것은 **가능해졌다.** 단 2025-06의 판단이 **반증된 것이 아니라 우회됐다** — 네 번째 층위는 LLM의 조정 능력에 의존하지 않는다. 세 번째 층위(LLM이 LLM에게 실시간 위임)에 대한 데이터는 세 소스 어디에도 **여전히 없다.**
> - **경제성 축** — **모순 없음.** 세 소스가 일치한다.
>
> 전체 논의와 근거는 [[multi-agent-systems]]의 Contradiction 절.

## 알려진 한계

- **subagent끼리 협력할 수 없다.** 네 층위 전부에서 그렇다 — 반환은 부모(또는 프로그램)에게만 간다. [[agent-orchestration-patterns]]의 여섯 패턴 중 에이전트가 서로 직접 주고받는 것은 하나도 없다. 리서치 시스템은 현재 lead가 subagent 묶음을 **동기적으로** 기다리므로, 느린 하나가 전체를 막고 lead가 진행 중인 subagent를 조종할 수도 없다.

  > ⚠️ **부분 예외 (2026-09-21):** [[2026-04-08-scaling-managed-agents]]는 *"brains can pass hands to one another"* 라고 적는다 — 어떤 hand(sandbox·도구)도 특정 brain에 결합되어 있지 않으므로 에이전트끼리 **실행 환경을 넘겨줄 수 있다.**
  >
  > 위 단정을 뒤집지는 않는다. 넘어가는 것은 **메시지가 아니라 자원**이고, 산출은 여전히 부모나 세션 로그로 간다. 그래도 *"에이전트가 서로 직접 주고받는 것은 하나도 없다"* 는 문장은 이제 **"결과를 주고받지 않는다"** 로 좁혀 읽어야 한다. 공유 상태를 통한 간접 전달의 경로는 열려 있다.
  >
  > 관찰 하나 더: 이 소스는 many hands가 **모델이 똑똑해지면서 비로소 가능해진 것**이라고 말한다 — 여러 실행 환경 중 어디로 일을 보낼지 고르는 것은 단일 셸보다 어려운 인지 과제라 초기 모델로는 안 됐다는 것. 위 표의 세 번째 층위(LLM 간 실시간 위임, *"not yet great"*)가 **시간이 지나면 풀릴 종류의 한계**라는 방증으로 읽힌다. 다만 이 소스도 그 층위를 직접 측정하지는 않는다.
- **개수를 스스로 정하지 못한다.** 초기 시스템은 단순한 쿼리에 subagent 50개를 띄웠다. 노력 배분 규칙을 프롬프트에 명시해야 한다.
- **창발적 행동.** 부모 프롬프트의 작은 변경이 subagent 행동을 예측 불가능하게 바꾼다.
- **⚠️ subagent 경계는 신뢰 경계이기도 하다 — 그리고 양방향이다.** [[2026-05-25-how-we-contain-claude]]가 **multi-agent trust escalation**을 보고한다.

  좋은 쪽은 이미 이 위키에 있다 — [[agentic-governance]]의 **quarantine 패턴**: 미신뢰 콘텐츠를 읽는 subagent가 raw text 대신 **구조화된 사실**만 위로 올리면, 메인 에이전트는 주입된 텍스트를 보지 않는다.

  나쁜 쪽이 새로 기록된다:

  > *"if a sub-agent's output is treated as higher-trust than raw tool results, because such output came from "us," a new vector for prompt injection is introduced."*

  **격리가 세탁이 된다.** 경계를 넘으면서 데이터의 출처 표식이 사라지고, "우리 subagent가 준 것"이라는 이유로 신뢰 등급이 오히려 **올라간다.** 주입된 지시가 "구조화된 사실"로 포장되어 도달한다.

  > 위 표의 네 층위 전부에 걸린다. 조정 주체가 누구든(부모 LLM·사람·프로그램) **subagent 반환값을 무엇으로 취급하느냐**는 별개 결정이고, 이 위키는 지금까지 그것을 다루지 않았다. 완화 방향은 **subagent 출력을 raw tool result와 같은 등급으로 검사하는 것**이지만, 그러면 quarantine의 이득이 얼마나 남는지는 소스도 답하지 않는다. 상세는 [[prompt-injection]].

## Related

- [[orchestrator-worker]] — subagent를 쓰는 대표 아키텍처. 위임·병렬성·한계의 상세
- [[multi-agent-systems]] — 이 장치를 쓸 경제적 가치가 언제 성립하는가
- [[claude-code]] — 코딩형 subagent와 병렬 세션(worktree)의 실제 구현
- [[agent-evaluation]] — verifier subagent가 "오염되지 않은 판정"으로 쓰이는 맥락
- [[artifact-chain]] — 파일을 인터페이스로 삼는 같은 처방의 다른 층위
- [[dynamic-workflows]] — 조정을 컨텍스트 밖 코드로 옮긴 네 번째 층위
- [[agent-orchestration-patterns]] — subagent를 엮는 여섯 가지 제어 구조
- [[meta-harness]] — 조정 상태를 durable하게 만드는 축. "누가 조정하는가"와 직교한다
- [[managed-agents]] — brain끼리 hand를 넘기는 것이 가능한 실제 구조
- [[prompt-injection]] — subagent 경계에서 일어나는 trust escalation
- [[agent-containment]] — 에이전트를 여럿 굴릴 때의 환경 층위 격리

## Sources

- [[2025-06-13-multi-agent-research-system]] — 리서치형 subagent, 위임 사양, game of telephone, 동기 실행 한계
- [[2026-08-21-the-ai-native-sdlc-playbook]] — 코딩형 subagent 정의 방식, verifier/researcher/simplifier, 병렬 세션과의 구분
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — 결정론적 프로그램이 조정하는 네 번째 층위, 모순 판정의 근거
- [[2026-04-08-scaling-managed-agents]] — 조정 상태의 durable한 거처, "brains pass hands" 부분 예외
- [[2026-05-25-how-we-contain-claude]] — multi-agent trust escalation. subagent 경계가 신뢰 경계로서 갖는 양면성
