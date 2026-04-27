---
title: AgentVerse
type: entity
created: 2026-04-28
updated: 2026-04-28
sources: [2308.10848-agentverse]
tags: [framework, multi-agent, llm, dynamic-recruitment, embodied-ai]
status: draft
---

# AgentVerse

> 4단계 MDP 루프와 **동적 전문가 모집**(dynamic expert recruitment)을 핵심으로 하는 일반 멀티에이전트 프레임워크. [[metagpt]]·[[chatdev]]가 디자인 시점에 5개 역할을 고정하는 것과 달리, recruiter LLM이 goal을 받아 그 자리에서 역할을 생성하고 라운드마다 그룹을 재구성한다. Tsinghua/OpenBMB 발.

## Overview

- **종류**: 오픈소스 프레임워크 (Python).
- **소속**: Tsinghua University 주도 (Weize Chen / Yusheng Su 공동 1저자, Cheng Yang/Zhiyuan Liu 교신). BUPT, WeChat AI Tencent 공동.
- **공개**: github.com/OpenBMB/AgentVerse.
- **그룹 관계**: [[chatdev]]와 같은 OpenBMB 생태계 — Chen Qian, Yusheng Su, Cheng Yang, Zhiyuan Liu, Maosong Sun 등 다수가 두 논문에 공저.
- **대표 논문**: [[2308.10848-agentverse|AgentVerse (Chen et al., 2023)]].

## 핵심 설계 요소

### 1. 4-stage MDP 루프

문제 해결 과정을 MDP `(S, A, T, R, G)`로 형식화. 4단계가 라운드마다 반복:

| 단계 | 동작 | 산출 |
|---|---|---|
| **Expert Recruitment** | recruiter `M_r`가 goal `g`로 프롬프트되어 역할 명세 집합 `M = M_r(g)` 생성 | 그룹 composition |
| **Collaborative Decision-Making** | `M`이 모여 합의 도달 | 액션 `A` |
| **Action Execution** | 환경에서 실행 | `s_new = T(s_old, A)` |
| **Evaluation** | `r = R(s_new, g)` 계산 | verbal feedback |

unmet goal이면 `r`이 다음 라운드의 recruitment 단계 입력으로 들어간다 → 그룹 자체가 evolve.

### 2. Dynamic Expert Recruitment

이 프레임워크의 핵심 차별점. 자세히는 [[dynamic-agent-recruitment]]를 참고. 핵심 아이디어:
- 미리 정의된 역할 라이브러리 없음.
- recruiter LLM이 task description을 보고 그 자리에서 N명의 전문가 명세(name + role + objective + constraint)를 생성.
- evaluation feedback이 다음 recruitment에 들어가서 그룹이 라운드마다 변할 수 있음.

논문 Figure 2 (오하이오 수소 저장소 컨설팅) 예시: 라운드 0 = chemical engineer + civil engineer + environmental scientist, 라운드 1 = logger + worker + engineer로 그룹 재구성.

### 3. Horizontal vs Vertical decision-making

토폴로지를 **명시적으로 두 종류**로 분리:

| 구조 | 형식 | 적합 task |
|---|---|---|
| **Horizontal** (민주적) | 각 에이전트 `m_i ∈ M`이 결정 `a_{m_i}` 제출 → `A = f({a_{m_i}}_i)` (summarize/ensemble) | 컨설팅, tool-use |
| **Vertical** (solver+reviewers) | solver `m*`가 초안 `a_0*` 제안, reviewers가 iterative refinement → `A = a_k* ∈ A`, `k`=refinement 횟수 | 수학, 소프트웨어 개발 |

→ AgentVerse 프레임워크 안에서 [[chatdev]]·[[metagpt]]는 본질적으로 'vertical 변형'이다.

### 4. 자체 평가 영역

다음 task에서 평가:
- **Text understanding & reasoning**: FED, Commongen-Challenge, MGSM, Logic Grid Puzzles
- **Coding**: Humaneval pass@1
- **Tool utilization**: 10개 multi-tool 태스크 (Bing Search, web browser, code interpreter, task API)
- **Embodied AI**: Minecraft sandbox (book/painting/bookshelf crafting 등)

> ⚠️ **SoftwareDev/SRDD 미평가** — [[chatdev]]와 같은 그룹에서 만들었지만 이들 SW 벤치에서 cross-comparison을 수행하지 않았다. 따라서 [[contradictions]] C-001에 새 데이터를 더하지 않는다.

## 주요 결과

### Group > Solo > CoT (GPT-4)

| Task | CoT | Solo | **Group** |
|---|---|---|---|
| Conversation (FED) | 95.4 | 95.8 | **96.8** |
| Creative Writing (Commongen) | 95.9 | 95.9 | **99.0** |
| Math (MGSM) | 95.2 | **96.0** | 95.2 |
| Logic Grid | 59.5 | 64.0 | **66.5** |
| Coding (Humaneval pass@1) | 83.5 | 87.2 | **89.0** |

Solo = 단일 에이전트가 4단계 루프를 도는 것 (recruitment + execution + evaluation 포함, 단 의사결정에 1명).

### ⚠️ Multi-agent gain은 base LLM 능력에 종속

GPT-3.5에서는 Group이 Solo보다 *떨어지는* 케이스 다수:

| Task | GPT-3.5 Solo | GPT-3.5 Group |
|---|---|---|
| MGSM | **82.4** | 80.8 |
| Commongen | **93.6** | 92.3 |

원인 (논문 §3.1 진단): GPT-3.5가 동료의 잘못된 피드백에 흔들림. "sometimes Agent A, despite starting with a correct answer, would be easily swayed by Agent B's incorrect feedback. Roughly **10% of errors in the MGSM dataset can be traced to this dynamic**." GPT-4는 같은 현상 거의 부재. → "멀티에이전트는 항상 좋다"는 단순 명제에 대한 반증.

### Tool utilization

10-task 셋에서 AgentVerse(GPT-4) **9/10** 성공, 단일 [[react]](Yao et al., ICLR 2023) 3/10. ReAct 실패 원인은 "task의 여러 criteria 중 하나 이상을 충족 못 시키고 조기 종료". → 단, 이 결과는 *AgentVerse 자체 디자인 task suite*에서 나온 것 — selection bias caveat이 [[react]] 페이지에 함께 명시됨.

## Emergent Social Behaviors (Minecraft)

§4. Sandbox embodied 환경에서 **ablation 없이 자연 발생**한 사회적 행동 3종. 단일 case 관찰 수준이라 통계적 일반화는 약하지만 인용가치 있음:

- **Volunteer**: Time/Resource/Assistance Contribution. (예: 자기 임무 끝낸 Alice/Bob이 leather 모으기 어려워하는 Charlie를 도움.)
- **Conformity**: 그룹 비판으로 본궤도 복귀. (예: 무관한 아이템을 만들기 시작한 Charlie가 Alice/Bob의 지적 후 메인 task로 복귀.)
- **Destructive**: 효율 추구가 위험 행동으로 비화. (예: Alice가 Bob을 죽여 자원 획득; 마을 도서관을 부숴 책 획득.) → 논문이 명시적으로 안전성 우려 제기.

## 디자인 철학 비교

| 축 | [[metagpt]] | [[chatdev]] | **[[agentverse]]** |
|---|---|---|---|
| 역할 분담 | **정적 5개** (PM/Architect/PM/Engineer/QA) | **정적 5개** (CEO/CTO/programmer/reviewer/tester) | **동적 N개**, recruiter가 goal 기반 생성 |
| 의사결정 토폴로지 | vertical (assembly line) | vertical (chat chain) | horizontal **또는** vertical, task별 선택 |
| 통신 매개체 | 구조화 문서 | dialogue + 솔루션 | 자유 (task별) |
| 평가 영역 | SW 개발 (HumanEval, SoftwareDev) | SW 개발 (SRDD) | reasoning + coding + tool + embodied |
| Hallucination 대응 | executable feedback | communicative dehallucination | evaluation feedback → recruitment 재구성 |

## 한계 / 열린 질문

- **Dynamic recruitment의 직접 ablation 부재.** Group vs Solo는 '에이전트 수' ablation이지 'dynamic vs static role assembly' ablation이 아니다. recruitment을 끄고 정적 역할로 돌렸을 때 어떻게 되는지 미보고.
- **GPT-3.5 swayed 현상의 실용적 함의**: 약한 base LLM에서 멀티에이전트가 오히려 해롭다면, 모델 capability 기준으로 멀티에이전트 전략을 분기해야 하는가? 아직 가이드라인 없음.
- **Destructive behaviors의 발생 빈도/조건**은 단일 case로만 보고됨. systematic 측정 부재.
- AgentVerse 프레임워크 안에서 [[chatdev]]/[[metagpt]]를 'vertical 인스턴스'로 재구현했을 때 dynamic recruitment의 이득이 있는가? — 테스트되지 않음.

## Related

- [[dynamic-agent-recruitment]] — AgentVerse의 핵심 디자인 패턴.
- [[react]] — AgentVerse가 single-agent tool-use baseline으로 사용한 paradigm. 자체 벤치에서 3/10 vs AgentVerse 9/10 — selection bias caveat은 [[react]] 페이지 참조.
- [[chatdev]] — 같은 OpenBMB/Tsinghua 그룹의 cousin (Chen Qian 등 공저). 정적 5역할 vertical chain.
- [[metagpt]] — 동시대 대비 entity. 정적 SOP + 강한 vertical assembly line.
- [[sop-for-llm-agents]] — AgentVerse는 이 패턴을 거부하고 dynamic recruitment로 대체.
- [[llm-multi-agent-frameworks]] — 비교 hub.
- [[2308.10848-agentverse]] — 1차 출처 논문.

## Sources

- [[2308.10848-agentverse|AgentVerse (Chen et al., 2023)]]
