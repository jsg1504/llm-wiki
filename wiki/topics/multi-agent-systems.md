---
title: 멀티에이전트 시스템
type: topic
created: 2026-09-11
updated: 2026-09-21
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents]
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
4. **인프라** — 실제로 여럿을 돌릴 때 무엇이 병목인가 → 아래 "스케일의 인프라 비용" 절, [[meta-harness]]

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

### 스케일의 인프라 비용 — 토큰이 전부가 아니다

위의 15배는 **토큰** 축이다. [[2026-04-08-scaling-managed-agents]]는 실제로 여러 에이전트를 호스팅할 때 드러나는 **다른 축**을 보여준다: provisioning 지연.

에이전트를 컨테이너 안에 두면 에이전트 수만큼 컨테이너가 필요하고, 그것이 뜰 때까지 추론이 시작되지 못한다. 문제는 **실행 환경을 영영 쓰지 않을 세션도 그 비용을 선불한다**는 것 — repo clone, 프로세스 부팅, 대기 이벤트 fetch. 이것이 **TTFT**(time-to-first-token)로 나타나고, 저자들은 이를 *사용자가 가장 예민하게 느끼는 지연*이라고 부른다.

실행 환경을 에이전트의 tool call로 **필요할 때만** provision하게 바꾼 결과:

> **p50 TTFT 약 60% 감소, p95 90% 이상 감소.**

많은 에이전트로 스케일하는 일이 **stateless한 루프를 많이 띄우고 필요할 때만 실행 환경에 연결하는 일**로 바뀐다.

> ⚠️ 내부 측정이고 워크로드 구성이 비공개다. 개선 메커니즘이 "실행 환경을 쓰지 않는 세션의 선불 비용 제거"이므로 **그런 세션의 비중이 높을수록 개선폭이 커진다.** 이 수치는 아키텍처의 우월성만큼이나 워크로드 믹스를 반영할 수 있다.

**이 페이지의 경제성 판단에 주는 시사점:** 멀티에이전트의 비용은 토큰만이 아니라 **에이전트당 인프라 수명주기**이기도 하다. 그리고 이 부분은 토큰과 달리 설계로 크게 줄어든다 — 구조를 바꿨더니 사라진 비용이다. 15배 필터는 여전히 유효하지만, *"에이전트를 하나 더 띄우는 데 드는 비용"* 은 토큰 배수만으로 표현되지 않는다.

한편 반대 방향의 기록도 있다. 같은 소스는 에이전트가 **여러 실행 환경을 놓고 어디로 일을 보낼지 고르는 것**이 단일 환경에서 작업하는 것보다 어려운 인지 과제라고 말하며, 초기 모델이 그것을 못 해서 단일 컨테이너로 시작했다고 밝힌다. 인텔리전스가 올라가자 단일 컨테이너가 오히려 제약이 됐다. → [[subagent]]의 조정 층위 논의

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

### 단일 에이전트가 길어질 때 무너지는 방식

멀티에이전트를 쓰는 이유는 처리량만이 아니다. 한 context window에서 오래 일할수록 나타나는 **세 가지 실패 모드**가 있고, 이것이 구조를 나누는 독립적인 근거가 된다 ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]):

- **Agentic laziness** — 복잡한 다부분 태스크를 끝내기 전에 멈추고 부분 진척으로 완료를 선언한다 (보안 리뷰 50개 항목 중 35개).
- **Self-preferential bias** — 자기 결과를 편애한다. **특히 루브릭에 비추어 스스로 검증·판정하라고 했을 때.** 이것이 검증자를 분리해야 하는 이유다 → [[agent-evaluation]]
- **Goal drift** — 여러 턴에 걸쳐 원 목표 충실도가 점진적으로 상실된다. **특히 compaction 이후** — 요약이 lossy해서 엣지케이스 요건이나 *"don't do X"* 제약이 유실된다.

이 프레이밍은 앞 절의 토큰 논변과 다른 층위다. 토큰이 *"왜 여럿이 더 잘하는가"*를 설명한다면, 이쪽은 *"왜 하나가 오래 하면 못하는가"*를 설명한다. 둘 다 참일 수 있고, 실제로 같은 처방(독립 context window로 나누기)으로 수렴한다. 구조로 막는 방법은 [[dynamic-workflows]]와 [[agent-orchestration-patterns]].

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

> ⚠️ **Contradiction (2026-09-11) → 부분 판정 (2026-09-12).** 세 번째 소스([[2026-08-20-a-harness-for-every-task-dynamic-workflows]])가 들어오면서 이 모순이 **하나의 질문이 아니라 두 개**였음이 드러났다. 아래에 원래 주장을 그대로 보존하고, 두 축으로 나눠 판정한다.

### 원래 기록된 대립 (2026-09-11, 원문 보존)

- [[2025-06-13-multi-agent-research-system]] (2025-06): 코딩을 **부적합 사례로 명시**한다. *"most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not yet great at coordinating and delegating to other agents in real time."*
- [[2026-08-21-the-ai-native-sdlc-playbook]] / [[ai-native-sdlc]] (2026-08): worktree로 격리한 **병렬 세션 2~3개**를 권장하고, 계층화된 **에이전트 리뷰 pass**를 SDLC의 정식 단계로 배치한다.

**당시 세운 해소 가설 두 가지:**
1. **오케스트레이터가 다르다.** 전자가 부정한 것은 *에이전트가 에이전트에게 실시간으로 위임하는* 구조이고, 후자가 권하는 병렬은 *사람이 오케스트레이션하고 각 스트림이 독립 worktree에서 도는* 구조다. 후자 스스로 *"the practical ceiling is how many streams one person can review properly"*라고 천장을 사람의 리뷰 능력에 둔다.
2. **시점 차이.** 14개월 간격이고, 전자가 *"not yet"*, *"today"*로 시점을 한정했다.

**2026-09-12 lint에서 추가된 증거 (가설 ① 관련):** [[claude-code]]가 병렬 세션을 *"각자의 git worktree에서 별도 작업을 하는 완전한 Claude Code 인스턴스. **서로를 모르며, 공유하는 것은 그것들을 조종하는 엔지니어뿐**"*으로, subagent를 *"**단일 세션 안에서** 도는 스코프된 헬퍼"*로 정의한다. 병렬성 세 층위의 구분은 [[subagent]]에 정리했다.

### 축 1 — **할 수 있는가 (적합성): 판정됨.** 뒤집힌 게 아니라 우회됐다

세 번째 소스가 **코딩 태스크에서 에이전트가 에이전트를 조정하는 실제 사례**를 제시한다. Bun이 Zig에서 Rust로 재작성된 것이 dynamic workflow를 통해서였고, 방법은 수정 단위마다 worktree에서 subagent를 띄우고 별도 에이전트가 적대적으로 리뷰한 뒤 머지하는 것이다. 가설 ②(14개월 시차)가 지지되는 것처럼 보인다.

**그러나 더 정확한 판정은 "우회"다.** 2025-06이 부정한 것은 *"LLM agents are not yet great at **coordinating and delegating** to other agents in real time"* — 즉 **LLM이 조정을 잘 못한다**는 것이다. [[dynamic-workflows]]는 그 능력이 좋아졌다고 주장하지 않는다. 대신 **조정을 LLM에게서 빼앗아 결정론적 JavaScript 프로그램에 맡긴다.**

> *"Each comparison is its own agent, so **the deterministic loop holds the bracket** and only the running order stays in context."*

따라서 두 소스는 서로 다른 것을 말하고 있으며, **2025-06의 판단은 여전히 반증되지 않았다.** 반증되려면 *LLM이 실시간으로 다른 LLM에게 위임하는* 구조의 데이터가 필요한데, 세 소스 중 어느 것도 그것을 주지 않는다. 조정 주체의 네 번째 범주가 생긴 것이고, 구분표는 [[subagent]]에 있다.

**가설 ①도 폐기되지 않는다.** SDLC 플레이북의 병렬 세션은 여전히 사람이 조종하는 구조이고, dynamic workflow는 그것과도 다른 세 번째 것이다. 세 소스가 각각 **다른 조정 주체**를 말하고 있었던 셈이다.

### 축 2 — **할 가치가 있는가 (경제성): 모순 없음.** 세 소스가 일치한다

이 축에서는 애초에 대립이 없었고, 세 번째 소스가 그것을 분명히 한다.

| 소스 | 경제성 판단 |
|---|---|
| [[2025-06-13-multi-agent-research-system]] (2025-06) | 멀티에이전트는 챗 대비 **~15x 토큰**. 가치 높은 태스크에만 |
| [[2026-08-21-the-ai-native-sdlc-playbook]] (2026-08) | 병렬 세션 **2~3개**가 출발점. 천장은 *"한 사람이 제대로 리뷰할 수 있는 스트림 수"* |
| [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] (2026-08) | *"may end up using significantly more tokens"* / ***"most traditional coding tasks do not need a panel of 5 reviewers"*** / *"parallelism and specialization have to **earn their coordination cost**"* |

세 번째 소스는 **기능을 소개하는 글이면서도 경제성 제약을 스스로 강화한다.** 즉 *"이제 코딩에서도 에이전트를 여럿 굴릴 수 있다"*는 것과 *"대부분의 코딩 작업에서 그래야 한다"*는 전혀 다른 명제이며, 세 소스 모두 후자를 부정한다.

### 남는 것

- **미해결:** *LLM이 다른 LLM에게 실시간 위임하는* 구조가 지금은 잘 되는가? 세 소스 모두 데이터 없음. 필요한 자료는 결정론적 harness **없이** 에이전트 간 위임을 측정한 것.
- **미해결:** 결정론적 조정이 LLM 조정보다 항상 나은가, 아니면 유연성을 잃는 트레이드오프인가? [[dynamic-workflows]]의 한계 절에 기록.
- **미해결:** 인프라 비용(TTFT·provisioning)과 토큰 비용을 **하나의 판단 기준**으로 합칠 수 있는가? 두 축이 각각 다른 소스에서 따로 보고되고 있다.
- **편향 주의:** **네 소스 모두** Anthropic 발행이다. 조정 구조에 대한 외부 관점이 없다. → [[anthropic]]

## Related

- [[orchestrator-worker]] — 이 주제의 대표 아키텍처. 구조와 위임 방법.
- [[agent-evaluation]] — 비결정적 멀티에이전트를 어떻게 검증하는가.
- [[subagent]] — 이 시스템들의 기본 단위. 조정 주체에 따른 병렬성 층위 구분.
- [[ai-native-sdlc]] — 코딩 도메인에서 에이전트를 병렬로 굴리는 반대편 주제. 위 Contradiction 절의 상대편이다.
- [[claude-code]] — 사람이 오케스트레이션하는 병렬 세션(worktree)을 실제로 제공하는 도구.
- [[dynamic-workflows]] — 조정을 LLM이 아니라 결정론적 코드에 맡기는 접근. 위 Contradiction 축 1의 판정 근거.
- [[agent-orchestration-patterns]] — 여러 에이전트를 엮는 여섯 가지 제어 구조 카탈로그.
- [[anthropic]] — 이 위키에 들어온 멀티에이전트 자료 **전부**의 출처. 외부 관점 부재는 이 페이지의 판정을 읽을 때의 주의 사항이다.
- [[meta-harness]] — 여러 에이전트를 돌릴 때의 인프라 인터페이스. 위 "스케일의 인프라 비용" 절의 설계 논증.
- [[managed-agents]] — TTFT 수치가 나온 실제 시스템.

## Sources

- [[2025-06-13-multi-agent-research-system]] — 이 페이지의 주 출처. 아키텍처·경제성·프로덕션 전반.
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Contradiction 절에서만 인용. 코딩 도메인의 병렬 세션 권장.
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — 세 실패 모드, 조정 주체의 네 번째 범주, 경제성 재확인. Contradiction 축 1·2 판정의 근거.
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). 스케일의 인프라 비용 절.
