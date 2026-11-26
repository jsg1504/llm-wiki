---
title: 에이전트 평가 (Agent Evaluation)
type: concept
created: 2026-09-11
updated: 2026-11-27
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-06-07-loop-engineering, 2026-08-14-practical-loop-engineering, 2026-09-30-loop-is-the-product, 2025-07-25-gepa-reflective-prompt-evolution, 2023-03-20-reflexion, 2024-10-14-longmemeval, 2023-10-12-memgpt, 2025-01-20-zep, 2026-03-03-reproducing-recursive-language-models, 2024-12-19-building-effective-agents, 2022-10-06-react, 2026-11-23-working-with-ai]
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

> **분리하지 않았을 때의 수치 (2026-11-26).** [[2023-03-20-reflexion]]의 코딩 에이전트는 **같은 모델이 만든 unit test**로 자기 코드를 채점한다. 이 절이 경고하는 구성 그대로다.
>
> - **false positive**(테스트는 통과, 실제로는 틀림)가 MBPP Python에서 **16.3%**, HumanEval Python에서 1.4%였다. MBPP에서는 이 때문에 Reflexion(77.1%)이 GPT-4 단독(80.1%)보다 낮았다. false positive가 나면 에이전트는 틀린 답을 일찍 제출한다.
> - **검증 없이 반성만 하면 더 나빠진다.** HumanEval Rust 최난도 50문제에서 테스트 생성을 빼면 0.52로 baseline 0.60보다 낮았다. 지금 코드가 맞는지 판단하지 못해 멈추지 못하고 해로운 수정을 한다.
>
> 두 수치는 self-preferential bias를 직접 잰 것이 아니다. 판정자를 분리하지 않은 구성에서 **판정자의 품질이 성능 상한을 정한다**는 것을 보여준다. 루프가 "done"을 선언하는 근거가 그 판정자뿐이라면 그 오류율이 곧 루프의 오류율이다. → [[loop-engineering]] *(뒤 문장은 추론이다.)*

#### 정지 조건도 판정 대상이다 (2026-09-21)

같은 원리가 한 층 위에 적용된 사례가 [[2026-06-07-loop-engineering]]에 있다. [[claude-code]]의 `/goal`은 조건이 참이 될 때까지 작업을 이어가되, **매 턴 후 별도의 작은 모델**이 완료 여부를 판정한다:

> *"a separate small model checks whether you are done, so the agent that wrote the code isnt the one grading it."*

지금까지 이 페이지의 판정자 분리는 **산출물**을 대상으로 했다. 여기서는 판정 대상이 *"끝났는가"* 라는 메타 질문이고, 그것을 만든 쪽(작업한 세션)과 판정하는 쪽이 분리된다. Codex에도 같은 이름의 기능이 있다 — **두 제품이 독립적으로 같은 자리에 판정자 분리를 놓았다.**

> ⚠️ **정정 (2026-09-21) — 이 evaluator는 §2b의 checker가 아니다.** 위 문단은 처음에 `/goal`을 이 절의 판정자 분리가 확장된 사례로 적었다. **그 기술은 넓었다.** 같은 저자가 두 달 뒤 직접 좁힌다:
>
> > *"The evaluator sitting behind goal is not that checker, by the way. It doesn't look at the content to see if it's good or bad in any way, shape, or form. All it does is examine the conversation transcript to see if the hard rules you specified have been met."* — [[2026-08-14-practical-loop-engineering]]
>
> **차이가 두 겹이다.** (a) 판정 대상이 **산출물의 품질이 아니라 내가 명시한 하드 룰의 충족 여부**이고, (b) 보는 것이 **코드가 아니라 대화 transcript**다. 이 절이 다루는 self-preferential bias — 루브릭에 비추어 자기 결과를 후하게 보는 경향 — 는 애초에 **품질 판정에서만 발생하는 문제**이므로, `/goal`의 evaluator는 그 문제를 겪지도 않고 풀지도 않는다.
>
> **따라서 evaluator는 adversarial verifier를 대신하지 않는다.** 같은 소스가 둘을 나란히 요구한다 — 한 subagent가 초안하고 별도의 하나가 검증한다. 실무적 함의는 잘못된 안심의 경계다: *"루프에 evaluator를 걸었으니 검증은 됐다"* 는 성립하지 않는다.
>
> **남는 것:** 이 사례가 이 절에 여전히 기여하는 것은 *"작업한 쪽이 완료를 선언하게 두지 않는다"* 는 **구조**이지, *"판정자가 품질을 본다"* 가 아니다. §4의 end-state 평가에 더 가깝다 — 경로가 아니라 **최종 상태가 지정한 조건을 만족하는가**만 본다.

단, 이 사례도 §4의 제약을 그대로 상속한다 — 정지 조건은 *"all tests in test/auth pass and lint is clean"* 처럼 **검증 가능한 문장**이어야 하고, 표현할 수 없는 태스크에는 쓸 수 없다. 결정론적 기준(통과한 테스트 수, 점수 임계값)일수록 강하다는 것이 후속 소스의 권고다. 그리고 첫 소스 자신의 경고: **"done"은 주장이지 증명이 아니다.** → [[loop-engineering]]

**eval 자체를 워크플로로 돌릴 수도 있다** — worktree에서 에이전트를 띄워 산출물을 만들고, 비교 에이전트가 루브릭으로 채점한다. 예: 내가 만든 skill을 특정 기준으로 평가·개선. → [[dynamic-workflows]]

> **분리의 이른 판본: evaluator-optimizer (2026-11-27).** [[2024-12-19-building-effective-agents]]는 한 호출이 생성하고 다른 호출이 평가·피드백하는 루프를 workflow 하나로 정리했다. 맞는 신호는 둘이다. ① 사람이 피드백을 말해 주면 응답이 **실제로** 나아지는가. ② LLM이 그런 피드백을 줄 수 있는가. 같은 글은 guardrail도 본 응답과 **다른 호출**이 맡는 편이 낫다고 쓴다. 분리의 이유로 든 것은 *"각 고려사항을 별도 호출이 맡으면 주의가 집중된다"* 였고, self-preferential bias는 아직 말하지 않았다. 2026년 소스는 분리의 이유를 편향으로 바꿔 부른다. *(대비는 이 위키의 정리다.)*

### 3. 사람 평가가 자동화의 사각지대를 잡는다

사람이 직접 써보면 eval이 놓치는 것들이 나온다 — 특이한 쿼리에서의 환각, 시스템 실패, 그리고 **미묘한 출처 선택 편향**. 실제로 Research 초기 에이전트가 권위 있지만 검색 순위가 낮은 학술 PDF·개인 블로그 대신 **SEO 최적화된 콘텐츠팜**을 일관되게 고르는 것을 사람 테스터가 발견했다. 프롬프트에 source quality 휴리스틱을 추가해 해결했다.

> 자동 평가가 아무리 잘 돌아도 수동 테스트는 여전히 필수다.

**궤적을 읽고 실패를 분류한다 (2026-11-27).** [[2022-10-06-react]]는 HotpotQA에서 ReAct와 CoT 궤적을 성공·실패 각 50개씩, 모두 200개 뽑아 사람이 실패 유형을 붙였다. 점수(EM)로는 ReAct가 CoT보다 조금 낮을 뿐이었다(27.4 vs 29.4). 라벨을 붙이자 두 방법이 **전혀 다른 방식으로 실패한다**는 게 드러났다. CoT 실패의 56%는 hallucination이었고, ReAct는 0%였다. 대신 ReAct 실패의 47%는 reasoning error였다(CoT 16%). 이 교환은 점수 하나로는 보이지 않는다. 그리고 이 분석이 두 방법을 섞는 처방으로 바로 이어졌다. 성공률은 무엇이 나은지를, 실패 분류는 **왜 그리고 어떻게 고칠지**를 알려 준다. → [[agent-loop]]

### 3b. 사람은 eval을 만들지 않고 보정한다 (2026-09-30)

§3은 사람이 **직접 써보며** 사각지대를 찾는다. [[2026-09-30-loop-is-the-product]]는 역할을 바꾼다. 발견도 eval 작성도 에이전트가 하고, 사람은 **판정에 동의하는지만** 답한다.

> *"You don't need the human to actually build the evals. You need them to calibrate the evals."*

리크루팅 에이전트 사례의 절차:

1. **Patterns.** trace에서 공통 행동과 사용자 불만을 클러스터링한다. 발견된 것: 에이전트가 숨은 인재 대신 **빅테크 직원에게만** 연락한다. 아무도 미리 eval로 적을 생각을 못 했을 행동이다.
2. **Calibrate.** 그 패턴을 잡는 judge를 에이전트가 만든다. 사람은 *"숨은 인재 쪽이 맞다는 이 판단에 동의하는가?"* 에만 답한다.
3. **Recipe candidates.** 반영할 diff 후보를 offline eval로 거른다.
4. **Experiments.** 프로덕션 A/B(multi-armed bandit)로 **사용자도 그 판단에 동의하는지** 확인한 뒤 promote한다.

이 페이지에 두 가지가 새로 들어온다.

- **eval의 내용물은 taste다.** 이 페이지의 루브릭(§2)은 사실 정확성처럼 누가 봐도 같은 기준이었다. 이 소스의 eval은 **제작자 고유의 판단**(*"좋은 리크루팅이란 무엇인가"*)을 코드화한 것이다. 소스 표현으로 *"It's not just tests. It's really what is the taste of the creator."*
- **세 번째 검증 층: 프로덕션 실험.** offline eval은 **제작자가** 만족하는지만 확인한다. A/B는 **사용자가** 그 taste에 동의하는지 확인한다. 이 위키의 기존 소스들은 offline eval과 사람 테스트에서 멈췄다.

§3과 이어지는 부분이 있다. §3의 *"SEO 콘텐츠팜을 고르는 편향"* 과 이 소스의 *"빅테크만 고르는 편향"* 은 같은 모양이다. 둘 다 **아무도 예상하지 못한 선택 편향**이다. 차이는 발견 경로에 있다. §3에서는 사람 테스터가 발견했고, 여기서는 trace 클러스터링이 발견한다.

> ⚠️ 이 절차는 [[loop-engineering]]이 기록한 *"taste는 루프에 맞지 않는다"* 와 부딪힌다. 그 페이지의 Contradiction 절 참조. 이 소스도 결과 수치(응답률, A/B 효과 크기)를 제시하지 않는다.

> **보정할 사람은 협조해야 한다 (2026-11-27).** 이 절차는 사람의 보정을 공짜 입력으로 둔다. [[2026-11-23-working-with-ai]]는 조직에서 그 입력이 공짜가 아님을 기록한다. 효과적인 workflow는 **전문가가 prompt를 설계하고 출력을 평가해야** 서는데, 그 workflow가 전문가를 대체할 수 있으면 전문가는 저항한다. *"If I'm open to this, I'm essentially building my own coffin."* 리뷰어 채용을 90% 넘게 줄이려던 회사에서는 리뷰어들이 속도를 올리지 않았다. 반대쪽 사례도 같은 소스에 있다. CPA가 금융 에이전트의 출력을 채점하는 일이 **새 업무로** 생겼다. 평가가 대체의 도구가 될 때와 넓어진 역할의 일부가 될 때 협조가 갈린다. 그리고 채점기도 낡는다. 상담원을 **2년 된 모델**로 채점하는 시스템은 관리자들이 진지하게 받아들이지 않았다. *(평가 설계와 조직 협조의 연결은 이 위키의 추론이다.)* → [[ai-in-organizations]] §2

### 4. 상태를 바꾸는 에이전트는 end-state로 평가한다

읽기 전용 리서치와 달리, 여러 턴에 걸쳐 영속 상태를 수정하는 에이전트는 각 행동이 다음 스텝의 환경을 바꾼다. 이때는 **턴별 분석 대신 최종 상태(end state)가 옳은가**를 본다. 에이전트가 다른 경로로 같은 목표에 도달할 수 있음을 인정하면서도 의도한 결과는 보장하는 방식이다. 복잡한 워크플로는 모든 중간 단계를 검증하려 들지 말고 **상태 변화가 일어나야 할 지점을 discrete checkpoint로 쪼개** 검사한다.

> 이 원칙의 도구 차원 구현이 [[claude-code]]의 **verifier subagent**다 — 세션이 작업을 끝냈다고 믿을 때 **신선한 컨텍스트로 한 번** 돌며, 요점은 *"판정이 코드를 만든 가정에 오염되지 않는다는 것"*이다. 판정자를 만든 쪽과 분리한다는 점에서 LLM-as-judge와 같은 발상이다. → [[subagent]]

### 5. 평가의 짝은 관측성(observability)이다

비결정적 시스템은 "왜 실패했는지"를 사후에 알 수 없으면 고칠 수 없다. 사용자가 "에이전트가 뻔한 정보를 못 찾는다"고 신고해도 원인이 나쁜 검색 쿼리인지, 나쁜 출처 선택인지, 도구 실패인지 알 수 없었다. **full production tracing**을 붙여서야 체계적 진단이 가능해졌다. 단, 프라이버시를 위해 개별 대화 **내용은 보지 않고** 에이전트의 **결정 패턴과 상호작용 구조**만 모니터링한다. 구체적 수단의 예: [[claude-code]]의 **OpenTelemetry export**(세션 transcript, hook 결정의 timestamp와 allow/block verdict, 동시 세션 수)가 조직 observability 스택으로 전달된다.

### 6. 다른 맥락에서의 같은 원리: eval을 CI에 넣기

위 지침들은 **제품 에이전트를 개선하기 위한** 평가다. [[2026-08-21-the-ai-native-sdlc-playbook]]은 같은 도구를 다른 자리에 놓는다 — **에이전트의 설정 자체**(`CLAUDE.md`·skills·hooks)가 바뀔 때 CI에서 eval suite를 돌려 통과율을 보고하게 한다. 실제 작업 20~50개를 eval로 만들라는 권고는 위 "20개 쿼리로 시작"과 규모가 같고, 여기에 하나를 더한다: **production incident 하나당 eval 하나**를 추가해 영구 회귀 테스트로 남긴다. 모델이 좋아지면 변별력을 잃은 케이스를 교체해야 하는 살아있는 suite다.

> **벤치마크가 낡는 실제 사례 (2026-11-26).** [[2023-10-12-memgpt]]가 2023년에 만든 DMR(Deep Memory Retrieval)은 MemGPT가 GPT-4 Turbo로 93.4%를 내며 기준이 됐다. 2025년 [[2025-01-20-zep]]이 다시 재자 **memory 시스템 없이 대화 전체를 context에 넣은 baseline**이 gpt-4-turbo 94.4%, gpt-4o-mini 98.0%였다. 대화당 60메시지라 context에 다 들어가기 때문이다. Zep 저자들은 DMR이 *"memory 시스템 평가에 부적합하다"* 고 본다. 측정하려던 능력(context 밖의 기억)이 context window가 커지면서 시험되지 않게 됐다. 위 "변별력을 잃은 케이스를 교체"가 suite 전체 단위에서 일어난 사례다. *(뒤 문장은 추론이다.)*
>
> **교체 대신 늘린다 (2026-11-26).** [[2024-10-14-longmemeval]]은 변별력 문제를 벤치마크 설계에서 푼다. 기존 장기 memory 벤치마크의 이력이 짧고 고정돼 있어 *"시스템이 계속 좋아지면서 난이도를 제한한다"* 고 보고, 증거 세션을 무관한 세션들 사이에 넣는 방식으로 **이력 길이를 자유롭게 늘릴 수 있게** 만든다. 표준은 약 115k token과 약 1.5M token 두 가지다. 케이스를 새로 쓰지 않고 **같은 질문의 난이도를 올리는** 길이다. 다만 길이라는 축 하나로만 늘어나므로 모든 과제에 쓸 수 있는 방법은 아니다. *(뒤 문장은 추론이다.)*
>
> **판정자를 사람과 대조한다.** 같은 소스는 GPT-4o 판정자를 유형별 30문항, 두 생성 모델에 대해 사람 전문가 판정과 비교해 평균 97~98% 일치를 확인하고 결과를 공개한다. 답이 열린 유형(preference, abstention)에서 가장 많이 어긋났다. §2의 LLM-as-judge를 쓸 때 **판정자 자체의 정확도를 따로 보고하는** 사례다. 대조적으로 [[2023-10-12-memgpt]]는 판정자에게 *"후하게 채점하라"* 고 지시하고, GPT-4가 사람과 잘 일치한다는 선행 연구를 인용할 뿐 **자체 대조 결과는 내지 않는다.**
>
> **채점이 형식과 능력을 섞으면 결론이 뒤집힌다 (2026-11-26).** [[2026-03-03-reproducing-recursive-language-models]]는 RLM의 핵심 이득(DeepSeek v3.2 OOLONG 0.0 → 42.1)을 재현했다고 보고한다. 그런데 부록에서 저자 스스로 base의 0%는 **답을 찾고도** *"Answer: number"* 형식 대신 서술로 답한 결과라고 적는다. 채점 함수가 형식 실패와 오답을 같은 0점으로 접었기 때문에, 이 수치로는 "RLM이 추론을 도왔다"와 "RLM scaffold가 형식을 맞추게 했다"를 가를 수 없다. 같은 논문의 RLM 실패 중 하나(최종 답 대신 `print()` 코드를 반환)도 같은 칸에 들어간다. 처방은 위의 판정자 대조와 같은 방향이다. **점수만이 아니라 실패의 종류를 따로 집계한다.** §7의 feedback_text가 그 그릇이다. *(처방은 이 위키의 추론이다.)*

### 7. 채점 함수는 점수와 함께 텍스트를 내야 한다 (2026-11-25)

지금까지 이 페이지의 eval은 **판정**을 위한 것이었다. 통과했는가, 몇 점인가. [[2025-07-25-gepa-reflective-prompt-evolution]]은 eval의 출력을 **개선의 재료**로 쓴다. 그러려면 점수 하나로는 부족하다.

- **feedback function.** 채점 함수가 점수와 함께 `feedback_text`를 돌려준다. 점수로 접히기 전에 이미 있던 텍스트다. 컴파일러 에러, 통과 못 한 루브릭 항목, 멀티홉 검색에서 아직 못 찾은 문서 목록 같은 것이다. 모듈별로 줄 수 있으면 더 좋다.
- **사람 채점의 근거도 같은 자리에 들어간다.** 사람이 점수를 매기는 도메인이라면 *왜 그 점수인지* 쓴 설명을 feedback_text로 넣는다. §3b의 "사람은 eval을 보정한다"와 같은 방향이다. 사람의 판단이 숫자가 아니라 **읽을 수 있는 근거**로 루프에 들어간다.
- **효과의 크기.** 이렇게 텍스트를 반성해 prompt를 고치면 학습 신호로 쓴 train rollout 6~179회로 가중치 RL(24,000 rollout)의 최고 점수에 도달했다. 다만 텍스트를 **끄고** 돌린 직접 비교는 논문에 없다. → [[prompt-optimization]]

**같은 엔진을 뒤집으면 회귀 suite가 나온다.** 보상을 반대로 주면 성능을 떨어뜨리는 지시문을 찾는다. 과제 내용을 보존하는 잡담 몇 줄이 GPT-5 Mini의 AIME-2025 정답률을 76%에서 10%로 떨어뜨렸다. 저자들은 이런 지시문을 **재사용 가능한 stress test와 회귀 suite**로 쓰자고 제안한다. §6의 "incident 하나당 eval 하나"는 사고가 **난 뒤** 회귀 케이스를 추가한다. 이쪽은 **사고 전에** 최악의 경우를 탐색해 케이스를 만든다. *(대비는 이 위키의 정리다. 저자들의 결과는 모델 하나, 30문제의 예비 결과다.)*

## Related

- [[agent-orchestration-patterns]] — adversarial verification·tournament가 제어 구조로 구현된 형태
- [[orchestrator-worker]] — 평가를 어렵게 만드는 그 구조. 경로 비결정성의 출처다.
- [[multi-agent-systems]] — 창발적 행동 때문에 "개별 에이전트가 아니라 상호작용을 평가해야 한다"는 논점이 여기서 나온다.
- [[ai-native-sdlc]] — eval을 SDLC의 CI 게이트로 배치하는 관점.
- [[claude-code]] — verifier subagent와 OTel export. 이 페이지 원칙들의 도구 구현.
- [[subagent]] — 오염되지 않은 판정자로서의 subagent.
- [[anthropic]] — 이 지침을 공개한 주체.
- [[agent-recipe]] — judge와 eval이 recipe의 핵심 구성물로 누적되는 자리. §3b의 절차가 곧 recipe 개선 절차다
- [[loop-engineering]] — 판정자 분리가 정지 조건에까지 적용되는 자리. 감독 없이 도는 루프에서 이 원칙의 값이 가장 크다.
- [[prompt-optimization]] — eval 출력을 판정이 아니라 개선 재료로 쓰는 방법. §7의 feedback_text와 adversarial 회귀 suite
- [[agent-memory]] — Reflexion이 판정 결과를 반성문으로 바꿔 쌓는 episodic memory. LongMemEval로 memory를 재는 법
- [[agent-loop]] — 매 단계 ground truth가 판정자 분리를 루프 한 단계 단위로 적용한 것이다. ReAct 실패 분류의 대상
- [[agent-fundamentals]] — 단순성 원칙("결과가 나아질 때만 복잡도를 올린다")을 지키는 수단이 측정이다
- [[ai-in-organizations]] — 보정·채점을 맡을 전문가가 조직에서 협조하는가. 채점이 새 직무가 되는 경우와 낡은 채점기
- [[context-and-memory]] — memory·long-context 클러스터의 측정과 재현을 모은 topic. 남이 다시 잰 주장 2건이 §6의 두 노트(DMR이 낡은 사례, 형식과 능력을 섞은 채점)와 겹친다

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — self-preferential bias, adversarial verification, skeptic 페르소나, pairwise 판정
- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering (2025-06-13). "Effective evaluation of agents" 절과 부록. 이 페이지의 1~5절.
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Claude Blog (2026-08-21). 6절(eval을 CI에 넣기)만 이 소스에서 왔다.
- [[2026-06-07-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-06-07). 2b절의 "정지 조건도 판정 대상이다"만 이 소스에서 왔다.
- [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu (Introspection, AI Engineer World's Fair). §3b만 이 소스에서 왔다.
- [[2026-08-14-practical-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-08-14). 같은 절의 ⚠️ 정정 — evaluator는 룰 체커이지 품질 판정자가 아니다.
- [[2025-07-25-gepa-reflective-prompt-evolution]] — Agrawal 외 16인 (ICLR 2026 Oral). §7만 이 소스에서 왔다 (2026-11-25)
- [[2023-03-20-reflexion]] — Shinn 외 5인 (arXiv 2303.11366). §2b의 "분리하지 않았을 때의 수치" 노트만 이 소스에서 왔다 (2026-11-26)
- [[2024-10-14-longmemeval]] — Wu 외 5인 (ICLR 2025). §6의 "교체 대신 늘린다"·판정자 대조 노트만 이 소스에서 왔다 (2026-11-26)
- [[2023-10-12-memgpt]] — Packer 외 6인 (arXiv 2310.08560). §6 노트의 대조 사례(검증 없는 관대한 판정자), DMR 원 출처 (2026-11-26)
- [[2025-01-20-zep]] — Rasmussen 외 4인 (Zep AI, arXiv 2501.13956). §6의 "벤치마크가 낡는 실제 사례"(DMR 재측정)만 이 소스에서 왔다 (2026-11-26)
- [[2026-03-03-reproducing-recursive-language-models]] — Daren Wang (CUHK, arXiv 2603.02615). §6의 "형식과 능력을 섞은 채점" 노트만 이 소스에서 왔다 (2026-11-26)
- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic Engineering, 2024-12-19). §2b의 evaluator-optimizer 노트만 이 소스에서 왔다 (2026-11-27)
- [[2022-10-06-react]] — Yao 외 (Princeton·Google, ICLR 2023). §3의 궤적 실패 분류만 이 소스에서 왔다 (2026-11-27)
- [[2026-11-23-working-with-ai]] — Wilmers 외 (Anthropic Institute, 2026-11-23). §3b의 "보정할 사람은 협조해야 한다" 노트만 이 소스에서 왔다 (2026-11-27)
