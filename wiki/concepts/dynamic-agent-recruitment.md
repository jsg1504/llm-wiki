---
title: Dynamic Agent Recruitment
type: concept
created: 2026-04-28
updated: 2026-04-28
sources: [2308.10848-agentverse]
tags: [multi-agent, prompt-engineering, dynamic-roles, agent-composition]
status: draft
---

# Dynamic Agent Recruitment

> goal이 들어오면 그 자리에서 LLM이 전문가 역할 명세를 생성해 멀티에이전트 그룹을 구성하고, 각 라운드의 evaluation feedback에 따라 그룹 자체를 재구성하는 패턴. [[sop-for-llm-agents]]의 정적 역할 분담과 정면으로 다른 디자인 축.

## 무엇인가

[[metagpt]]·[[chatdev]] 같은 SOP 기반 프레임워크는 디자인 시점에 5개 역할(PM/Architect/.../QA 또는 CEO/CTO/.../tester)을 고정한다. 새 task가 와도 같은 역할 풀을 그대로 쓴다. 잘 정립된 도메인(SW 개발)에서는 강력하지만, **task가 SW 개발과 멀어지면 5역할 SOP는 잘 안 맞는다.**

Dynamic agent recruitment 패턴은 이 문제를 다음과 같이 풀려 한다:

1. **'recruiter' 역할의 LLM `M_r`을 둔다.** (다른 모든 에이전트와 같은 base LLM, 다른 system prompt.)
2. recruiter는 task goal `g`를 입력받아 **N개의 전문가 명세를 그 자리에서 생성**한다: `M = M_r(g)`. 각 명세는 name + role + objective + constraint 같은 구조.
3. 이 그룹이 task를 풀고 결과 `s_new`를 evaluator가 verbal feedback `r = R(s_new, g)`로 평가.
4. unmet goal이면 `r`이 다음 라운드의 recruiter 입력으로 들어가 **그룹 자체가 재구성**된다.

→ 역할 분담이 디자인 산출물이 아니라 **runtime의 액션**이 된다.

## 왜 작동하는가 (가설)

- **task-shape 적응성**: 컨설팅 task에는 chemical engineer + civil engineer + environmental scientist가, SW task에는 programmer + UI/UX designer + tester가 적합하다 — 디자인 시점에 모두 미리 정의할 수 없다. recruiter가 task 텍스트만 보고 분해하면 적어도 task-aligned된 역할 풀이 나온다.
- **diversity 자동 보장**: 인간 그룹 연구에서 diversity가 성능을 올린다는 발견(Woolley et al., 2015 등; AgentVerse §2.1 인용)을 LLM에 적용. recruiter에게 "diverse expert"를 요구하면 비슷한 역할의 중복을 자연스럽게 피한다.
- **feedback-driven evolution**: 첫 라운드 그룹이 부적합하면 다음 라운드에서 다른 전문가 조합으로 대체. 정적 SOP는 같은 5역할로 더 많이 시도할 수밖에 없다.

## 한계와 비용

- **재현성 ↓**: recruiter LLM의 sampling stochasticity 때문에 같은 goal에 대해 매번 다른 그룹이 나올 수 있음. SOP 기반 디자인의 재현성·디버깅성과 trade-off.
- **role hallucination 위험**: recruiter가 "quantum cryptography expert" 같은 그럴듯하지만 실제로 LLM이 그 분야 deep knowledge를 갖지 못한 역할을 만들면, 역할 명세가 빈 껍데기가 된다. AgentVerse는 이 현상을 명시적으로 다루지 않음.
- **dynamic recruitment의 직접 이득은 ablation으로 입증되지 않음**: AgentVerse §3의 Group vs Solo 비교는 *에이전트 수* ablation이지, *dynamic vs static role assembly* ablation이 아니다. "static 5역할로 같은 task를 풀면 얼마나 떨어지는가"는 미측정.
- **base LLM 의존성**: recruiter도 LLM이라, base 모델이 약하면 recruitment 품질도 약해진다.

## SOP 패턴과의 대비

| | 강한 SOP ([[metagpt]]) | 약한 SOP ([[chatdev]]) | **Dynamic Recruitment ([[agentverse]])** |
|---|---|---|---|
| 역할 정의 시점 | 디자인 (논문에 5개 fix) | 디자인 (논문에 5개 fix) | **runtime, recruiter LLM이 생성** |
| 그룹 변경 가능? | ❌ | ❌ | ✅ 라운드마다 evaluation feedback로 재구성 |
| 핸드오버 매개체 | 구조화 문서 (PRD/설계서) | dialogue + 솔루션 | task별 자유 (horizontal/vertical 선택) |
| 적합 도메인 | SOP가 잘 정립된 도메인 (SW) | 〃 | SOP가 약하거나 task-shape이 다양한 도메인 |
| 재현성 | 높음 | 중간 | 낮음 (sampling 의존) |

→ 같은 문제(자유 대화의 모호함, cascading hallucination)를 정반대 방향으로 푼다: SOP는 **모호함을 절차로 고정**, dynamic recruitment는 **모호함을 task-dependent하게 수용**.

## 결합 가능한가

원리상 'dynamic recruitment + task별 SOP 라이브러리' 같은 하이브리드도 가능해 보인다 (recruiter가 역할 풀을 만들고, 각 역할이 도메인 SOP에 따라 동작). AgentVerse 자체는 명시적으로 SOP를 거부하지만, 두 패턴이 본질적으로 배타적이지는 않다. 현재 위키에 1차 출처가 없는 상태이므로 추측으로만 표기.

## 대표 사례

- [[agentverse]] — 이 패턴을 4-stage MDP 루프로 명시 형식화. recruiter LLM이 goal 기반 그룹 생성, evaluation feedback이 다음 recruitment 입력.

## Related

- [[sop-for-llm-agents]] — 정반대 디자인 축. 두 패턴이 같은 모티베이션을 다른 방향으로 푼다.
- [[agentverse]] — 이 패턴의 대표 구현.
- [[metagpt]] — 정적 SOP의 대비점.
- [[chatdev]] — 정적 약한 SOP의 대비점.
- [[llm-multi-agent-frameworks]] — 비교 hub.

## Sources

- [[2308.10848-agentverse|AgentVerse (Chen et al., 2023)]] — 이 패턴을 명시 형식화한 1차 출처.
