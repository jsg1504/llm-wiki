---
title: 멀티에이전트 시스템
type: topic
created: 2026-09-11
updated: 2026-09-11
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook]
tags: [multi-agent, agentic-workflows, token-economics, architecture]
status: draft
---

# 멀티에이전트 시스템

> 여러 LLM 에이전트가 협력해 하나의 문제를 푸는 시스템. 이 주제의 중심 질문은 "어떻게 만드는가"가 아니라 **"언제 쓸 가치가 있는가"**다 — 챗 대비 약 15배의 토큰을 태우기 때문이다.

## Overview

멀티에이전트 시스템은 **도구를 루프 안에서 자율적으로 쓰는 LLM** 여럿이 함께 일하는 구조다. 이 위키에서는 다음 세 축으로 다룬다:

1. **구조** — 어떻게 조립하는가 → [[orchestrator-worker]]
2. **경제성** — 언제 그 비용을 낼 가치가 있는가 → 이 페이지
3. **검증** — 비결정적 시스템을 어떻게 평가하는가 → [[agent-evaluation]]

## Key Points

### 왜 이기는가: 토큰이 성능의 80%를 설명한다

가장 반직관적인 발견은 멀티에이전트의 우위가 "협업 지능"이 아니라 **토큰 지출**로 거의 다 설명된다는 것이다. BrowseComp 평가 분석에서 세 요인이 성능 분산의 95%를 설명했는데, 그중 **token usage 단독이 80%**였고 나머지가 tool call 수와 모델 선택이었다 ([[2025-06-13-multi-agent-research-system]]).

> "Multi-agent systems work mainly because they help spend enough tokens to solve the problem."

이 프레이밍을 받아들이면 설계 질문이 바뀐다. "에이전트를 몇 개 둘까"가 아니라 **"이 태스크에 토큰을 얼마나 쓸 가치가 있고, 그 토큰을 여러 context window에 나눠 담는 것이 이득인가"**가 된다. 단일 에이전트는 결국 자기 context window가 천장이고, subagent를 띄우는 것은 그 천장을 여러 개로 늘리는 행위다.

단, 토큰이 전부는 아니다. **최신 모델은 토큰의 효율 배수로 작동한다** — Sonnet 3.7에서 Sonnet 4로 올리는 것이 토큰 예산을 2배로 늘리는 것보다 이득이 컸다. 즉 모델 업그레이드가 아키텍처 복잡화보다 먼저 검토할 카드다.

**측정된 우위:** Opus 4 lead + Sonnet 4 subagents 조합이 내부 research eval에서 단일 Opus 4 대비 **90.2%** 앞섰다. (내부 평가이며 루브릭은 비공개 — 외부 재현 불가라는 점을 감안해 읽을 것.)

### 비용: 챗 대비 15배

| 형태 | 토큰 소비 (챗 기준) |
|---|---|
| 챗 대화 | 1x |
| 단일 에이전트 | ~4x |
| 멀티에이전트 | ~15x |

따라서 멀티에이전트는 **태스크의 가치가 충분히 높을 때만** 경제적으로 성립한다. 이것은 기술적 제약이 아니라 경제적 제약이며, 아키텍처 선택의 1차 필터다.

> 주목할 공백: [[ai-native-sdlc]]는 모든 play에 leading/lagging indicator 쌍을 요구하면서도 **토큰·비용 축을 지표 체계에 두지 않는다.** 그쪽 지표는 git history·PR metadata·CI·incident tracker에서 나오는 시간과 품질 지표뿐이다. 에이전트를 여럿 굴리는 SDLC의 실제 비용이 얼마인지는 두 소스 어느 쪽도 답하지 않는다.

### 적합 / 부적합 판정 기준

**적합:**
- 무거운 병렬화가 가능한 태스크 (breadth-first 쿼리 — 독립적인 여러 방향을 동시에 추적)
- 단일 context window를 넘는 정보량
- 복잡한 도구가 다수 관여하는 작업
- 가치가 높아 15배 토큰을 정당화하는 작업

**부적합:**
- 모든 에이전트가 **같은 컨텍스트를 공유해야** 하는 작업
- 에이전트 간 **의존성이 많은** 작업
- 가치 대비 비용이 안 맞는 단순 작업

리서치가 잘 맞는 이유는 애초에 경로를 미리 정할 수 없는 문제이기 때문이다. 발견에 따라 방향을 바꿔야 하므로 선형 파이프라인으로는 처리가 안 된다.

### 프롬프트는 규칙이 아니라 협업 프레임워크다

조정 복잡도가 빠르게 커지므로 프롬프트가 행동 교정의 주 레버가 된다. 초기 실패들은 전형적이다 — 간단한 쿼리에 subagent 50개 생성, 존재하지 않는 출처를 끝없이 검색, 과도한 업데이트로 서로 주의 분산. 교훈은 프롬프트를 **엄격한 지시문이 아니라 분업·문제해결 방식·노력 예산을 정의하는 협업 프레임워크**로 쓰라는 것이다. 구체적 지침은 [[orchestrator-worker]] 참조.

### 창발적 행동을 전제로 설계한다

멀티에이전트 시스템에는 프로그래밍하지 않은 행동이 나타난다. lead agent 프롬프트의 작은 변경이 subagent 행동을 예측 불가능하게 바꾼다. 따라서 **개별 에이전트의 행동이 아니라 상호작용 패턴을 이해해야** 하고, 이것이 [[agent-evaluation]]에서 "경로 대신 결과를 본다"는 원칙으로 이어진다.

### 프로토타입과 프로덕션 사이의 간격

> "When building AI agents, the last mile often becomes most of the journey."

에이전트 시스템은 상태를 오래 들고 돌기 때문에 일반 소프트웨어에서는 사소한 문제가 여기서는 치명적이 된다. 한 스텝의 실패가 에이전트를 완전히 다른 궤적으로 보낸다. 프로덕션 운영에 필요한 것들:

- **resume + checkpoint + retry** — 처음부터 재시작하지 않고 중단 지점에서 복구
- **도구 실패를 에이전트에게 알리기** — 모델의 적응력을 활용하되 결정론적 안전장치와 결합
- **full production tracing** — 내용이 아니라 결정 패턴과 상호작용 구조를 관측
- **rainbow deployment** — 실행 중인 에이전트를 깨지 않기 위해 신구 버전을 동시 운영하며 트래픽 점진 이전

## Contradiction: 코딩은 멀티에이전트에 맞는가

> ⚠️ **Contradiction (2026-09-11):** 두 소스가 코딩 도메인에서의 멀티에이전트 적합성에 대해 반대 방향을 가리킨다.
>
> - [[2025-06-13-multi-agent-research-system]] (2025-06): 코딩을 **부적합 사례로 명시**한다. *"most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not yet great at coordinating and delegating to other agents in real time."*
> - [[2026-08-21-the-ai-native-sdlc-playbook]] / [[ai-native-sdlc]] (2026-08): worktree로 격리한 **병렬 세션 2~3개**를 권장하고, 계층화된 **에이전트 리뷰 pass**를 SDLC의 정식 단계로 배치한다.
>
> **해소 가설 두 가지 (미검증):**
> 1. **오케스트레이터가 다르다.** 전자가 부정한 것은 *에이전트가 에이전트에게 실시간으로 위임하는* 구조이고, 후자가 권하는 병렬은 *사람이 오케스트레이션하고 각 스트림이 독립 worktree에서 도는* 구조다. 후자 스스로 *"the practical ceiling is how many streams one person can review properly"*라고 천장을 사람의 리뷰 능력에 둔다. 그렇다면 둘은 서로 다른 것을 말하고 있으며 모순이 아니다.
> 2. **시점 차이.** 14개월 간격이고, 전자가 *"not yet"*, *"today"*로 시점을 한정했다. 모델의 조정 능력이 그사이 향상됐다면 전자의 판단이 갱신된 것일 수 있다.
>
> **2026-09-12 lint에서 추가된 증거 (가설 ① 관련):** [[claude-code]]가 병렬 세션을 *"각자의 git worktree에서 별도 작업을 하는 완전한 Claude Code 인스턴스. **서로를 모르며, 공유하는 것은 그것들을 조종하는 엔지니어뿐**"*으로, subagent를 *"**단일 세션 안에서** 도는 스코프된 헬퍼"*로 정의한다. 즉 SDLC 플레이북이 권하는 병렬은 **에이전트 간 실시간 위임이 아니다.** 병렬성 세 층위의 구분은 [[subagent]]에 정리했다.
>
> **판정 상태: 미판정.** 위 증거는 가설 ①과 일관되지만 "따라서 두 소스는 애초에 충돌하지 않는다"는 결론은 내리지 않는다. 가설 ②(14개월 시차로 *"not yet"*이 완화됐는가)는 여전히 미검증이고, 두 소스 모두 **에이전트가 에이전트에게 위임하는 코딩**에 대한 데이터를 주지 않는다.
>
> **필요한 추가 조사:** 두 소스 이후에 나온, 코딩 태스크에서 에이전트 간 위임을 실제로 측정한 자료.

## Related

- [[orchestrator-worker]] — 이 주제의 대표 아키텍처. 구조와 위임 방법.
- [[agent-evaluation]] — 비결정적 멀티에이전트를 어떻게 검증하는가.
- [[subagent]] — 이 시스템들의 기본 단위. 병렬성 세 층위의 구분.
- [[ai-native-sdlc]] — 코딩 도메인에서 에이전트를 병렬로 굴리는 반대편 주제. 위 Contradiction 절의 상대편이다.
- [[claude-code]] — 사람이 오케스트레이션하는 병렬 세션(worktree)을 실제로 제공하는 도구.
- [[anthropic]] — 이 위키에 들어온 멀티에이전트 자료 대부분의 출처.

## Sources

- [[2025-06-13-multi-agent-research-system]] — 이 페이지의 주 출처. 아키텍처·경제성·프로덕션 전반.
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Contradiction 절에서만 인용. 코딩 도메인의 병렬 세션 권장.
