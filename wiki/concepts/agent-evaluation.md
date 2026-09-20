---
title: 에이전트 평가 (Agent Evaluation)
type: concept
created: 2026-09-11
updated: 2026-09-21
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-06-07-loop-engineering]
tags: [evaluation, llm-as-judge, testing, observability, agent-design]
status: draft
---

# 에이전트 평가 (Agent Evaluation)

> 에이전트는 같은 입력에도 매번 다른, 그러나 똑같이 유효한 경로를 밟는다. 따라서 "정해진 스텝을 따랐는가"를 검사할 수 없고, **결과가 옳은가 + 과정이 합리적인가**를 유연하게 판정해야 한다.

## Overview

전통적 평가는 "입력 X → 경로 Y → 출력 Z"를 가정한다. 에이전트는 이 가정을 깬다 — 한 에이전트는 소스 3개를 보고 다른 에이전트는 10개를 보며, 서로 다른 도구로 같은 답에 도달한다. 애초에 **올바른 스텝이 무엇인지 우리도 모르는** 경우가 많다.

이 페이지는 [[2025-06-13-multi-agent-research-system]]이 제시한 실무 지침을 정리한다. [[orchestrator-worker]] 구조를 운영하며 얻은 것이다.

## Key Points

### 1. 작게, 지금 당장 시작한다

초기 개발에서는 변경의 효과 크기가 크다 — 프롬프트 한 번 손봐서 성공률이 30%에서 80%로 뛴다. 효과가 이만큼 크면 **테스트 케이스 몇 개로도 변화가 보인다.** Research 팀은 실사용 패턴을 대표하는 **쿼리 약 20개**로 시작했다.

> 흔한 실패는 "수백 개짜리 제대로 된 eval을 만들 때까지 기다리는 것"이다. 소규모 테스트를 먼저 돌리는 쪽이 항상 낫다.

### 2. LLM-as-judge는 단일 호출·단일 루브릭이 낫다

연구 결과물은 자유 서술이고 정답이 하나가 아니라 프로그램적 채점이 어렵다. LLM 판정자를 쓰되, **구성 요소별로 판정자를 여럿 두는 것보다 하나의 프롬프트로 하나의 호출**을 하는 쪽이 더 일관적이고 사람 판단과 잘 맞았다.

루브릭 5개 항목:

| 항목 | 묻는 것 |
|---|---|
| **factual accuracy** | 주장이 출처와 일치하는가 |
| **citation accuracy** | 인용된 출처가 그 주장을 실제로 뒷받침하는가 |
| **completeness** | 요청된 모든 측면을 다뤘는가 |
| **source quality** | 이차 저품질 자료 대신 일차 출처를 썼는가 |
| **tool efficiency** | 맞는 도구를 합리적인 횟수로 썼는가 |

출력은 **0.0~1.0 점수 + pass/fail 등급**. 정답이 분명한 케이스("R&D 예산 상위 3개 제약사를 정확히 나열했는가")에서 특히 잘 작동한다.

> ⚠️ **다른 소스는 다르게 권한다.** [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]는 정성적 판정에서 ***"comparative judgment is more reliable than absolute scoring"***이라며 **pairwise 비교 토너먼트**를 권한다 — 1000+ 항목을 심각도순으로 정렬할 때 절대 점수 대신 각 비교를 자기 에이전트로 띄우는 식이다. 위의 *"단일 호출·단일 루브릭 + 0.0~1.0 점수"*와 방법이 충돌한다.
>
> 다만 **대상이 다르다.** 위쪽은 *하나의 산출물을 채점*하는 상황이고(정답이 분명한 케이스에서 특히 잘 작동한다고 명시), 아래쪽은 *다수를 서로 견주어 순위를 매기는* 상황이다. 실질 모순이라기보다 용도 구분으로 읽히지만, **어느 쪽도 상대를 측정해 비교하지는 않았다.** 새 소스는 이 명제에 근거를 대지 않는다. → [[agent-orchestration-patterns]]의 tournament 패턴

### 2b. 판정자는 산출물을 만든 에이전트와 분리되어야 한다

같은 컨텍스트가 만들고 채점하면 **self-preferential bias**가 걸린다 — *"Claude's tendency to prefer its own results or findings, **especially when asked to verify or judge them against a rubric**"* ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]). 루브릭을 주는 것이 편향을 막아주지 않고, 오히려 편향이 가장 잘 나타나는 상황이라는 점이 요지다.

처방은 구조적이다:

- **adversarial verification** — 산출물마다 별도 에이전트가 루브릭에 비추어 적대적으로 검증한다. [[claude-code]]의 verifier subagent가 *"신선한 컨텍스트 윈도로 한 번"* 도는 것을 모든 산출물로 체계화한 형태.
- **skeptic 페르소나** — 검증자를 촘촘히 걸면 false positive가 늘어난다. 규칙·판정 자체가 타당한지 되묻는 에이전트를 두어 과잉 지적을 억제한다.
- **disjoint 증거원** — 근본원인 조사에서 로그·파일·데이터 담당 에이전트를 나눠 가설이 서로 오염되지 않게 한다.

#### 정지 조건도 판정 대상이다 (2026-09-21)

같은 원리가 한 층 위에 적용된 사례가 [[2026-06-07-loop-engineering]]에 있다. [[claude-code]]의 `/goal`은 조건이 참이 될 때까지 작업을 이어가되, **매 턴 후 별도의 작은 모델**이 완료 여부를 판정한다:

> *"a separate small model checks whether you are done, so the agent that wrote the code isnt the one grading it."*

지금까지 이 페이지의 판정자 분리는 **산출물**을 대상으로 했다. 여기서는 판정 대상이 *"끝났는가"* 라는 메타 질문이고, 그것을 만든 쪽(작업한 세션)과 판정하는 쪽이 분리된다. Codex에도 같은 이름의 기능이 있다 — **두 제품이 독립적으로 같은 자리에 판정자 분리를 놓았다.**

단, 이 소스도 §4의 제약을 그대로 상속한다 — 정지 조건은 *"all tests in test/auth pass and lint is clean"* 처럼 **검증 가능한 문장**이어야 하고, 표현할 수 없는 태스크에는 쓸 수 없다. 그리고 소스 자신의 경고: **"done"은 주장이지 증명이 아니다.** → [[loop-engineering]]

**eval 자체를 워크플로로 돌릴 수도 있다** — worktree에서 에이전트를 띄워 산출물을 만들고, 비교 에이전트가 루브릭으로 채점한다. 예: 내가 만든 skill을 특정 기준으로 평가·개선. → [[dynamic-workflows]]

### 3. 사람 평가가 자동화의 사각지대를 잡는다

사람이 직접 써보면 eval이 놓치는 것들이 나온다 — 특이한 쿼리에서의 환각, 시스템 실패, 그리고 **미묘한 출처 선택 편향**. 실제로 Research 초기 에이전트가 권위 있지만 검색 순위가 낮은 학술 PDF·개인 블로그 대신 **SEO 최적화된 콘텐츠팜**을 일관되게 고르는 것을 사람 테스터가 발견했다. 프롬프트에 source quality 휴리스틱을 추가해 해결했다.

> 자동 평가가 아무리 잘 돌아도 수동 테스트는 여전히 필수다.

### 4. 상태를 바꾸는 에이전트는 end-state로 평가한다

읽기 전용 리서치와 달리, 여러 턴에 걸쳐 영속 상태를 수정하는 에이전트는 각 행동이 다음 스텝의 환경을 바꾼다. 이때는 **턴별 분석 대신 최종 상태(end state)가 옳은가**를 본다. 에이전트가 다른 경로로 같은 목표에 도달할 수 있음을 인정하면서도 의도한 결과는 보장하는 방식이다. 복잡한 워크플로는 모든 중간 단계를 검증하려 들지 말고 **상태 변화가 일어나야 할 지점을 discrete checkpoint로 쪼개** 검사한다.

> 이 원칙의 도구 차원 구현이 [[claude-code]]의 **verifier subagent**다 — 세션이 작업을 끝냈다고 믿을 때 **신선한 컨텍스트로 한 번** 돌며, 요점은 *"판정이 코드를 만든 가정에 오염되지 않는다는 것"*이다. 판정자를 만든 쪽과 분리한다는 점에서 LLM-as-judge와 같은 발상이다. → [[subagent]]

### 5. 평가의 짝은 관측성(observability)이다

비결정적 시스템은 "왜 실패했는지"를 사후에 알 수 없으면 고칠 수 없다. 사용자가 "에이전트가 뻔한 정보를 못 찾는다"고 신고해도 원인이 나쁜 검색 쿼리인지, 나쁜 출처 선택인지, 도구 실패인지 알 수 없었다. **full production tracing**을 붙여서야 체계적 진단이 가능해졌다. 단, 프라이버시를 위해 개별 대화 **내용은 보지 않고** 에이전트의 **결정 패턴과 상호작용 구조**만 모니터링한다. 구체적 수단의 예: [[claude-code]]의 **OpenTelemetry export**(세션 transcript, hook 결정의 timestamp와 allow/block verdict, 동시 세션 수)가 조직 observability 스택으로 전달된다.

### 6. 다른 맥락에서의 같은 원리: eval을 CI에 넣기

위 지침들은 **제품 에이전트를 개선하기 위한** 평가다. [[2026-08-21-the-ai-native-sdlc-playbook]]은 같은 도구를 다른 자리에 놓는다 — **에이전트의 설정 자체**(`CLAUDE.md`·skills·hooks)가 바뀔 때 CI에서 eval suite를 돌려 통과율을 보고하게 한다. 실제 작업 20~50개를 eval로 만들라는 권고는 위 "20개 쿼리로 시작"과 규모가 같고, 여기에 하나를 더한다: **production incident 하나당 eval 하나**를 추가해 영구 회귀 테스트로 남긴다. 모델이 좋아지면 변별력을 잃은 케이스를 교체해야 하는 살아있는 suite다.

## Related

- [[agent-orchestration-patterns]] — adversarial verification·tournament가 제어 구조로 구현된 형태
- [[orchestrator-worker]] — 평가를 어렵게 만드는 그 구조. 경로 비결정성의 출처다.
- [[multi-agent-systems]] — 창발적 행동 때문에 "개별 에이전트가 아니라 상호작용을 평가해야 한다"는 논점이 여기서 나온다.
- [[ai-native-sdlc]] — eval을 SDLC의 CI 게이트로 배치하는 관점.
- [[claude-code]] — verifier subagent와 OTel export. 이 페이지 원칙들의 도구 구현.
- [[subagent]] — 오염되지 않은 판정자로서의 subagent.
- [[anthropic]] — 이 지침을 공개한 주체.
- [[loop-engineering]] — 판정자 분리가 정지 조건에까지 적용되는 자리. 감독 없이 도는 루프에서 이 원칙의 값이 가장 크다.

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — self-preferential bias, adversarial verification, skeptic 페르소나, pairwise 판정
- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering (2025-06-13). "Effective evaluation of agents" 절과 부록. 이 페이지의 1~5절.
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Claude Blog (2026-08-21). 6절(eval을 CI에 넣기)만 이 소스에서 왔다.
- [[2026-06-07-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-06-07). 2b절의 "정지 조건도 판정 대상이다"만 이 소스에서 왔다.
