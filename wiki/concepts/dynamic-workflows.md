---
title: Dynamic Workflows (동적 harness)
type: concept
created: 2026-09-12
updated: 2026-09-21
sources: [2026-08-20-a-harness-for-every-task-dynamic-workflows, 2025-06-13-multi-agent-research-system, 2026-04-08-scaling-managed-agents]
tags: [dynamic-workflows, agentic-harness, orchestration, multi-agent, context-window, token-economics]
status: draft
---

# Dynamic Workflows (동적 harness)

> 에이전트가 **자기가 쓸 harness를 태스크마다 즉석에서 작성**하는 것. 조정 로직이 LLM의 판단이 아니라 **결정론적 프로그램**에 들어가고, 그 프로그램이 독립 context window를 가진 subagent들을 spawn·조율한다. 존재 이유는 성능이 아니라 **단일 context window의 세 가지 실패 모드를 구조로 막는 것**이다.

## Overview

**Harness**란 모델을 감싸고 그것이 무엇을 언제 할지를 정하는 바깥 껍질이다. Claude Code의 기본 harness는 코딩용으로 설계됐고, *"많은 태스크가 알고 보면 코딩 태스크를 닮았기 때문에"* 다른 일에도 잘 통했다. 그러나 Research, security analysis, agent teams, Code Review처럼 특정 부류의 태스크는 **전용 harness를 사람이 손으로 만들어야** 최고 성능이 나왔다 ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]).

Dynamic workflow는 그 제작 주체를 바꾼다. Claude가 JavaScript 파일을 써서 subagent를 spawn하고 조율한다. 결과물은 저장·공유 가능한 아티팩트다.

```
전통적 접근                          Dynamic workflow
─────────────────────────────       ─────────────────────────────
사람이 harness를 설계·구현           Claude가 태스크를 보고 harness를 작성
    │                                    │
    ▼                                    ▼
모든 엣지케이스를 커버해야 함         이 태스크만 커버하면 됨
    │                                    │
    ▼                                    ▼
generic해짐                          맞춤형(tailor-made)
    │                                    │
    ▼                                    ▼
재사용 가능, 최적은 아님              일회용(저장 가능), 이 태스크엔 최적
```

전제는 모델이 harness를 직접 쓸 만큼 똑똑해졌다는 것이며, 소스는 그 분기점을 **Claude Opus 4.8**로 지목한다.

## Key Points

### 조정이 컨텍스트에서 코드로 이동한다 — 이 개념의 정의적 특징

가장 중요한 구조적 사실이며, 소스가 지나가듯 말하지만 이 위키 기준으로는 핵심이다:

> *"Each comparison is its own agent, so **the deterministic loop holds the bracket** and only the running order stays in context."*

토너먼트에서 브래킷을 들고 있는 것은 에이전트의 기억이 아니라 **JS 프로그램의 변수**다. fan-out의 종합 단계도 마찬가지로 *"synthesize step is a **barrier**—it waits for all the fan-out agents"* — barrier는 에이전트들이 협상해 만드는 것이 아니라 프로그램이 강제한다.

이 구분이 왜 중요한가: [[subagent]]에 정리된 병렬성 층위 중 **"에이전트 간 실시간 위임"은 아직 잘 안 되는 것**으로 보고되어 있었다 (*"LLM agents are not yet great at coordinating and delegating to other agents in real time"*, [[2025-06-13-multi-agent-research-system]], 2025-06). Dynamic workflow는 이 한계를 **해결한 것이 아니라 회피한다.** 조정을 LLM에게 시키지 않고 코드에게 시키기 때문이다.

| | 조정 주체 | 조정 상태가 사는 곳 |
|---|---|---|
| 단일 에이전트 | LLM 자신 | 자기 context window |
| orchestrator-worker | **lead agent (LLM)** | lead의 context window (+ Memory) |
| 병렬 세션 (worktree) | **사람** | 사람의 머리 |
| **dynamic workflow** | **결정론적 프로그램** | **프로그램 변수 (컨텍스트 밖)** |

LLM이 담당하는 것은 *harness를 한 번 쓰는 일*이고, 실행 중의 조정은 코드가 한다. 이 분리가 아래 세 실패 모드에 대한 방어의 원리다.

### 막으려는 것: 단일 context window의 세 실패 모드

기본 harness는 **계획과 실행을 같은 context window에서** 한다. 많은 코딩 태스크에는 이것이 효과적이지만, 길고·대규모 병렬이며·고도로 구조화되었거나·적대적인 태스크에서 무너진다. 한 컨텍스트에서 오래 일할수록 나타나는 것:

| 실패 모드 | 무엇인가 | 워크플로가 막는 방식 |
|---|---|---|
| **Agentic laziness** | 복잡한 다부분 태스크를 다 끝내기 전에 멈추고 부분 진척으로 완료 선언 (보안 리뷰 50개 중 35개) | 항목마다 별도 에이전트. 프로그램이 목록을 들고 있으므로 **빠뜨릴 대상이 없다** |
| **Self-preferential bias** | 자기 결과를 편애하는 경향. **특히 루브릭에 비추어 스스로 판정하라고 할 때** | 검증을 만든 에이전트가 아닌 **별도 에이전트**가 한다 → [[agent-orchestration-patterns]]의 adversarial verification |
| **Goal drift** | 여러 턴에 걸쳐 원 목표 충실도가 점진적으로 상실. **특히 compaction 이후** — 요약이 lossy해서 엣지케이스나 *"don't do X"* 제약이 유실 | 각 subagent의 목표가 짧고 격리되어 있어 **애초에 compaction에 도달하지 않는다** |

요지는 **프롬프트로 달래지 않고 구조로 막는다**는 것이다. "게으르지 마"라고 쓰는 대신, 게으를 수 있는 자리를 없앤다.

> 세 번째 실패 모드는 [[artifact-chain]]·[[subagent]]가 말하는 *"대화가 아니라 파일이 인터페이스가 되게 하라"*와 같은 통찰의 또 다른 표현이다. 잃어버리면 안 되는 상태를 컨텍스트 밖에 둔다 — 저쪽은 파일에, 이쪽은 프로그램 변수에.

### 무엇으로 만들어지는가

- **실행 단위:** 특수 함수 몇 개를 가진 JavaScript 파일. subagent spawn과 조율을 담당한다.
- **표준 JS 사용 가능:** JSON, Math, Array 등으로 데이터를 가공한다.
- **모델 선택과 격리를 워크플로가 정한다.** 에이전트마다 어떤 모델을 쓸지, subagent를 각자의 worktree에서 돌릴지를 결정할 수 있다 → 필요한 **지능 수준과 격리 수준**을 Claude가 고른다.
- **중단 복구:** 사용자 개입이나 터미널 종료로 중단되어도 세션을 재개하면 멈춘 지점부터 이어 간다.
- **트리거:** 그냥 워크플로를 만들어 달라고 하거나, 트리거 단어 `ultracode`를 쓴다.
- **저장·배포:** 워크플로 메뉴에서 `s`. `~/.claude/workflows`에 체크인하거나 skill에 담아 배포한다. skill로 배포할 때는 **스크립트가 아니라 템플릿으로 취급하라고 프롬프트하는 편**이 유연하다.

### 언제 쓰지 말아야 하는가 — 경제성 판단은 그대로다

이 소스는 기능 소개 글이면서도 스스로 선을 긋는다:

> *"they are not needed for every task and may end up using significantly more tokens"*
>
> *"For regular coding tasks, try and ask yourself: does it really need more compute? For example, **most traditional coding tasks do not need a panel of 5 reviewers.**"*

그리고 아키텍처 층위로 일반화한다 — **병렬성과 전문화는 자신의 조정 비용을 벌어야 한다**(*"parallelism and specialization have to earn their coordination cost"*). 이것은 [[multi-agent-systems]]가 *"멀티에이전트는 챗 대비 15x 토큰이므로 가치 높은 태스크에만"*이라고 기록한 판단과 **같은 이야기**다. 도구가 쉬워졌다고 경제성이 바뀌지는 않았다.

**통제 수단 두 가지:**
- **명시적 토큰 예산** — *"use 10k tokens"*처럼 프롬프트에 쓰면 상한이 걸린다.
- **quick workflow** — 워크플로가 대형 태스크 전용은 아니다. 어떤 가정에 대한 빠른 적대적 리뷰 같은 소규모 용도로도 요청할 수 있다.

**반복 가능한 워크플로**(triage, research, verification)는 `/loop`로 정기 실행하고 `/goal`로 하드한 완료 요건을 건다.

### 적용 범위는 코딩 밖이 더 넓을 수 있다

> *"I've found that workflows are sometimes even more useful for non-technical work."*

소스가 드는 사례는 마이그레이션·deep research·사실 검증·정성적 정렬·규칙 준수·근본원인 조사·대규모 triage·탐색과 취향 판단·eval·모델 라우팅이다. 이 중 세일즈(3월 매출이 왜 떨어졌나)와 포스트모템은 코드와 무관하다. 사례별 상세는 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]], 패턴은 [[agent-orchestration-patterns]].

주목할 실증 하나: **Bun이 Zig에서 Rust로 재작성된 것이 워크플로를 통해서였다.** 방법은 태스크를 조작 단위(callsite, 실패 테스트, 모듈)로 쪼개고, 수정마다 worktree에서 subagent를 띄우고, 별도 에이전트가 적대적으로 리뷰한 뒤 머지하는 것. 팁 — **리소스 집약적 명령을 쓰지 말라고 지시**해야 머신 자원 고갈 없이 최대 병렬화가 된다.

## 반대 방향의 처방 — meta-harness

[[2026-04-08-scaling-managed-agents]]는 **같은 관찰에서 출발해 반대로 간다.** 관찰은 이 페이지 Overview의 그것과 거의 같다 — 모든 엣지케이스를 커버해야 하는 generic harness는 어떤 태스크에도 최적이 아니다. 거기에 이 소스가 한 겹을 더한다: **harness는 "모델이 아직 못 하는 것"에 대한 가정의 집합이고, 모델이 좋아지면 그 가정이 썩는다.**

그쪽이 든 증거가 구체적이다. Sonnet 4.5가 컨텍스트 한계를 감지하면 작업을 조기 종료하는 "context anxiety"를 보여 harness에 context reset을 넣었는데, **Opus 4.5에서는 그 행동이 없어서 reset이 dead weight가 됐다.**

```
        "generic harness는 최적이 아니고, 가정은 시간이 지나면 썩는다"
                                │
            ┌───────────────────┴───────────────────┐
            ▼                                       ▼
     dynamic workflow (이 페이지)              [[meta-harness]]
  harness를 태스크마다 새로 쓴다          harness를 교체 가능하게 만든다
            │                                       │
 주체: 모델이 실행 시점에 작성            주체: 플랫폼이 경계선을 고정
 수명: 그 태스크 동안 (저장은 가능)        수명: harness들보다 길게
 푸는 문제: **태스크 적합성**              푸는 문제: **시간에 따른 노후화**
```

**대체재가 아니다.** 그 소스가 직접 화해시킨다 — [[claude-code]]를 *"an excellent harness"* 라고 부르고, 태스크 전용 harness가 좁은 도메인에서 뛰어나다는 것도 인정하며, [[managed-agents]]가 그중 무엇이든 수용한다고 말한다. 여기서 Claude가 쓰는 JavaScript 프로그램도 그 위에 얹힐 수 있는 harness 한 종류다.

**이 페이지에 주는 시사점 하나:** 위의 "세 실패 모드" 표에 적힌 처방들 — context pollution, context rot, goal drift를 subagent 격리로 막는 것 — 도 **모델 능력에 대한 가정**이다. 단일 컨텍스트가 길어지면 무너진다는 전제가 어느 모델에서 약해지면, 워크플로가 막아주던 것 중 일부는 reset과 같은 길을 갈 수 있다. 소스가 *"best practices are still developing"* 이라고 쓴 것과 같은 방향의 경계다.

## 한계와 읽을 때의 주의

> ⚠️ **이 소스에는 정량 데이터가 없다.** [[2025-06-13-multi-agent-research-system]]이 BrowseComp 분산 분석과 90.2% 같은 수치를 제시한 것과 달리, 이 소스는 성능 비교·토큰 실측·성공률을 **전혀 제시하지 않는다.** Bun 재작성도 외부 X 스레드 링크로만 언급된다. 저자들 스스로 *"best practices are still developing"*이라고 쓴다. 따라서 이 페이지의 주장은 **경험 보고이지 측정이 아니다.**

- **토큰 비용이 상방으로 열려 있다.** 15x 같은 구체적 배수조차 제시되지 않는다. 예산을 명시적으로 걸라는 조언이 그 자체로 비용이 예측 불가함을 시사한다.
- **조정을 코드로 옮긴 대가는 유연성이다.** 결정론적 프로그램은 실행 중 전략을 바꾸지 못한다. [[orchestrator-worker]]에서 lead agent는 종합 후 *"충분한가?"*를 판단해 subagent를 더 띄울 수 있지만, 그 판단을 코드가 하려면 정지 조건을 미리 표현할 수 있어야 한다 (loop-until-done 패턴이 이 자리를 메운다).
- **harness를 쓰는 것 자체가 한 번의 LLM 판단이다.** 잘못 설계된 워크플로는 잘못을 병렬로 확대한다. 소스가 skeptic 페르소나와 루브릭을 반복 권하는 이유가 이것으로 읽힌다.
- **워크플로가 인코딩한 가정도 낡는다.** 태스크마다 새로 쓰므로 노후화 주기가 짧다는 것이 이 접근의 방어책이지만, skill이나 `~/.claude/workflows`에 **저장·배포된** 워크플로는 손으로 만든 harness와 같은 문제를 갖는다. 저장하는 순간 수명이 길어지기 때문이다. → [[meta-harness]]

## Related

- [[agent-orchestration-patterns]] — 워크플로가 조합하는 6가지 패턴의 카탈로그. 이 페이지의 "어떻게"에 해당
- [[subagent]] — 워크플로가 spawn하는 단위. 병렬성 층위 구분표에 이 개념이 4번째 행으로 들어간다
- [[orchestrator-worker]] — 조정을 **LLM이** 하는 대안 구조. 무엇이 달라지는지의 대조군
- [[multi-agent-systems]] — 이 모든 것의 경제성. *"조정 비용을 벌어야 한다"*는 판단의 근거
- [[agent-evaluation]] — adversarial verification과 pairwise 판정이 평가 원리로서 갖는 의미
- [[claude-code]] — 이 기능이 실제로 사는 도구
- [[agentic-governance]] — quarantine 패턴이 워크플로 층위의 통제로 등장한다
- [[meta-harness]] — 같은 문제의 반대 방향 처방. harness를 새로 쓰는 대신 갈아 끼울 수 있게 만든다
- [[managed-agents]] — 이 워크플로가 얹힐 수 있는 하부 층위의 구현

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). 이 페이지의 주 출처
- [[2025-06-13-multi-agent-research-system]] — 대조군으로 인용. *"에이전트 간 실시간 위임"*의 한계 보고와 orchestrator-worker의 LLM 주도 조정
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). "반대 방향의 처방" 절
