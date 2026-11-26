---
title: AI in Organizations
type: topic
created: 2026-11-27
updated: 2026-11-27
sources: [2026-11-23-working-with-ai, 2026-08-21-the-ai-native-sdlc-playbook, 2026-04-08-scaling-managed-agents, 2026-06-07-loop-engineering, 2026-09-30-loop-is-the-product]
tags: [ai-adoption, organizations, bottlenecks, roles, enterprise-ai]
status: draft
---

# AI in Organizations

> 에이전트를 잘 만드는 것과 조직이 그 가치를 얻는 것은 다른 문제다. 가치가 큰 적용일수록 조직을 바꿨다. 병목은 조직 안에서 생기고, 모델이 좋아질 때마다 자리를 옮긴다. 그래서 고정된 workflow를 짓는 것보다 **사람이 움직이는 병목을 따라갈 수 있게 조직을 짜는 것**이 낫다.

## Overview

이 위키의 다른 topic은 에이전트 **하나**([[agent-fundamentals]]), 여럿([[multi-agent-systems]]), context window 밖([[context-and-memory]]), 그리고 소프트웨어 조직의 절차([[ai-native-sdlc]])를 다룬다. 이 topic은 한 칸 바깥이다. **에이전트가 들어간 조직은 무엇이 바뀌어야 가치를 얻는가.**

중심 소스는 [[2026-11-23-working-with-ai]]다. Anthropic 고객사 58곳 인터뷰 66회를 바탕으로 한 질적 연구이고, 가치는 자기 보고이며 표본은 대표성이 없다. 이 topic의 주장은 **측정이 아니라 관찰된 패턴**이다. 정량 검증은 아직 없다.

## 1. 가치는 조직 변화와 함께 온다

AI 적용 약 300건을 "자기 보고 가치" × "조직 변화 정도"로 찍으면, 조직 구조를 건드리지 않는 적용(임시 데이터 분석, 슬라이드 디자인)은 대부분 가치가 낮다. 가치가 큰 쪽은 **프로세스나 역할을 바꿨다.** 예: 모든 커밋에 AI 리뷰를 붙인다, 마케터가 개별 문서 대신 브랜딩 `skill.md`를 편집한다. ([[2026-11-23-working-with-ai]])

인과의 방향은 셋이다.
- **구조 변화가 성공의 전제인 경우.** 에이전트가 정책을 엄격히 적용하려면 정책이 먼저 명확해야 한다.
- **성공이 더 큰 변화를 부르는 경우.**
- **성공이 하류를 깨뜨리는 경우.** 직원이 고객 문서를 직접 내보내자 "외부 자료는 마케팅을 거친다"는 SOP가 무너졌다.

가치의 형태도 예상과 다르다. 대부분 **비용 절감이 아니라 산출 증가**다. 그 절반은 기존 일을 빠르게 하거나 넓힌 것이고 나머지 절반은 품질 개선이나 새 제품이다.

> **엔지니어링 쪽과의 대응.** 마케터의 `skill.md`는 [[ai-native-sdlc]] Stage 2·3의 *"skills as institutional knowledge"* 와 같은 장치다. 그 플레이북은 brand·security·compliance 정책을 skill로 로드해 spec의 제약으로 삼는다. 이 소스는 같은 장치가 엔지니어링 밖에서 **역할 자체를 바꾼다**는 관찰을 더한다. 문서를 만드는 사람이 문서를 만드는 규칙을 관리하는 사람이 된다. *(대응은 이 위키의 정리다. 두 소스는 서로를 언급하지 않는다.)*

## 2. 세 가지 도입 방식과 각자의 실패

| 방식 | 하는 일 | 얻는 것 | 실패 양상 |
|---|---|---|---|
| **top-down 자동화** | workflow 하나를 골라 위에서 자동화 솔루션을 배포 | 외주·채용 축소, 처리량 | 빨리 낡는다 · 전문가가 저항한다 · 어려운 일이 다른 사람에게 쌓여 폐기된다 · 감시 불안 |
| **bottom-up 실험** | 도구를 나눠 주고 자발적 사용을 기다림 | 도메인 전문가 개인의 큰 성과 | 개인 구역을 넘지 못한다 · 유지보수가 남는다 · 고르지 않은 가속 · 비사용자에게 비용 |
| **재편** | 역할·배치·인프라를 AI에 맞춰 바꿈 | 위 둘의 한계를 넘는 가치 | (소스는 실패 사례를 따로 들지 않는다) |

### top-down이 낡는 방식

이 실패는 [[meta-harness]]의 전제와 같은 모양이다. **harness는 "모델이 아직 혼자 못 하는 것"에 대한 가정의 집합이고, 모델이 좋아지면 그 가정은 썩는다.** 조직에서 보면 이렇다.

- 고객 상담원 채점 시스템이 **2년 된 모델**로 돌고, 관리자들은 그 점수를 진지하게 받아들이지 않는다.
- 특정 산업·기능을 겨냥한 벤더 솔루션이 모델 개선으로 낡는다. *"It'll be obsolete in three months."*
- 문서 관리 자동화가 거의 안 쓰이는 "zombie" 앱으로 남는다.

([[2026-11-23-working-with-ai]]) meta-harness의 처방은 harness보다 오래 사는 **인터페이스**를 고정하는 것이다. 이 소스의 처방도 구조가 같다. 고정된 workflow 대신 역할 변경을 쉽게 만드는 **scaffolding**을 깐다(§4). *(구조가 같다는 것은 이 위키의 해석이다.)*

### 전문가의 역설

효과적인 workflow는 **전문가가 prompt를 설계하고 출력을 평가해야** 선다. 즉 전문가에게 자기를 대체할 시스템을 만들라는 요구가 된다. *"If I'm open to this, I'm essentially building my own coffin."* 이 저항이 top-down 자동화를 깨뜨리는 가장 직접적인 원인이다. ([[2026-11-23-working-with-ai]])

이 위키의 eval 페이지들이 전제하는 것이 정확히 그 전문가의 판단이다. [[agent-evaluation]]의 *"사람은 eval을 만들지 않고 보정한다"*, [[2026-09-30-loop-is-the-product]]의 *"자신을 higher-level judge로 자동화하라"*. 둘 다 전문가가 **협조한다**고 가정한다. 이 소스는 그 가정이 조직에서 공짜가 아니라는 첫 기록이다. 소스의 답은 이득을 직원과 나누는 것과 역할을 넓히는 것이다(§4). *(연결은 이 위키의 추론이다.)*

### bottom-up이 막히는 방식

개인은 자기 구역 안의 프로세스만 바꿀 수 있다. *"The individual doesn't have the authority to change the work."* 만든 것은 유지보수가 필요하고(비개발자가 만든 소프트웨어 대부분은 여전히 기술직의 인프라 지원이 필요하다), 한 기능의 가속은 다른 기능에서 막힌다. 10개 언어 번역을 만들었지만 그 언어로 전화받을 사람이 없어 출시하지 않았다. 저자들은 이를 Paul David의 전기 모터 사례에 비긴다. 공장 배치를 그대로 둔 채 모터만 갈아 끼우면 생산성이 늦게 온다. ([[2026-11-23-working-with-ai]])

## 3. 병목은 조직 안에서 생긴다

가장 자주 언급된 병목은 **AI 출력의 리뷰**다. 양이 희소한 사람의 주의를 압도한다. 그다음은 다른 기능이 코딩 속도를 못 따라가는 것, 고르지 않은 도입, context·인프라 부족이다. **고객 회의론과 규제는 드물었다.** ([[2026-11-23-working-with-ai]])

이것은 [[ai-native-sdlc]]의 출발점(*"병목은 build가 아니라 그 주변이다"*, *"병렬성의 천장은 사람의 리뷰 능력이다"*)을 **소프트웨어 바깥까지** 넓혀 확인한다. 그 플레이북은 정량 데이터가 없었다. 이 소스도 측정은 아니지만, 58개 조직에서 같은 병목이 반복해서 나왔다는 응답 분포를 준다.

> *"The closer you are to the money, the harder it is for models to excel in that job."* 프로토타입은 빠른데 배포가 느리거나, 생산은 빠른데 마케팅이 느리면, AI의 가치는 모델 평가와 능력이 시사하는 것보다 훨씬 작다.

리뷰 병목에 대한 대응은 회사마다 갈렸다. 리뷰를 자동화한 곳, 리뷰에 쓰는 시간을 늘린 곳, 공식 리뷰를 없애고 개발자가 **Claude 옆에 앉아 함께 평가하게** 한 곳이 있다. 마지막은 [[ai-native-sdlc]] Stage 5의 계층화된 리뷰 게이트와 반대 방향처럼 보인다. 모순으로 등록하지 않았다. 독자가 다르고(규제 엔터프라이즈 vs 한 회사), 그 회사도 리뷰를 없앤 게 아니라 비동기 게이트를 동기 페어링으로 바꿨다.

## 4. 재편의 세 경로

### 4.1 역할을 넓힌다

한 사람이나 작은 팀이 workflow 전체를 소유하면 조정 비용과 거부권이 사라진다. *"Two people plus Claude… if two people agree on something, just ship it."* 리드 소싱·AE·고객 성공을 한 역할로, designer·PM·engineer·QA·infra를 한 역할로 합친 사례가 나온다. AI는 각 단계의 세부를 따라가기 쉽게 하고, 동료에게 넘길 때의 **context loss를 더 비싸게** 만든다. ([[2026-11-23-working-with-ai]])

> **context loss는 이 위키의 다른 층위에서도 같은 이유로 비싸다.** [[subagent]]와 [[orchestrator-worker]]는 위임할 때마다 맥락이 압축되어 넘어가고, [[artifact-chain]]은 그 손실을 커밋된 파일로 줄인다. 이 소스는 같은 비용을 **사람 사이의 핸드오프**에서 본다. 해법도 비슷하다. 넘기는 횟수를 줄이거나(역할 확대), 넘기는 것을 공용 데이터로 만든다(§4.3). *(추론)*

넓어진 역할에는 **에이전트 운영**이 들어간다. 장애 알림 응답을 자동화한 엔지니어는 두 달간 모든 대화 전사본을 읽고 prompt·integration·문서를 고쳤다. 6개월 뒤에도 2주마다 표본을 읽었다. 이 일이 있기 때문에 전문가는 해고를 덜 두려워한다. 현재 모델 능력에서 agentic workflow는 전문가의 지속적 관여가 필요하다. 이 운영 방식은 [[loop-engineering]]의 comprehension debt 처방(*"루프가 만든 걸 읽는 것밖에 없다"*)을 실제로 돌린 모습이다.

### 4.2 사람을 병목 업무로 옮긴다

*"the entire job has switched right from writing code to making decisions."* 일은 대인·전략 업무, 그리고 taste로 옮겨간다. *"Claude is a terrible product manager... So it's a lot of taste deciding what features are important."* 새 업무도 생긴다. CPA가 금융 에이전트 출력을 채점하고, 마케팅 임원이 branding skill prompt를 편집하고, IT가 비개발자 앱 중 무엇을 production에 올릴지 정한다. ([[2026-11-23-working-with-ai]])

> **taste 모순에 관한 증언.** [[loop-engineering]]에 *"taste는 루프에 맞는가"* 모순이 미해결로 있다. 이 소스의 CTO 발언은 Osmani 쪽(taste는 사람에게 남는다)에 서는 현장 증언이다. 판정은 바꾸지 않는다. 증언 하나이고, Gavrilescu의 주장은 taste를 eval로 **코드화할 수 있다**는 것이지 지금의 모델이 PM을 잘한다는 것이 아니다.

병목은 계속 움직인다. *"3개월 기다리면 못 할 줄 알았던 게 된다."* *"If the world could just pause for a minute and let us get some harnesses in place."* 그래서 저자들의 결론은 **고정된 조직 계획**이 아니라 역할 변경을 쉽게 만드는 scaffolding이다. 가장 큰 회사들은 직원의 스킬을 체계적으로 인벤토리하고 인력 수요 변화를 추적한다.

### 4.3 공용 인프라, 특히 데이터

비기술직이 보안 구멍이나 엔지니어 유지보수 부담 없이 앱을 만들 수 있도록 공용 인프라를 깐다. *"Every single employee now is a developer… creating additional attack surface every day."* 이 공격 표면 문제는 [[agentic-governance]]의 통제 계층과 [[agent-containment]]의 환경 층위 방어가 다루는 것과 같다. 이 소스는 처방을 구체적으로 주지 않는다.

가장 중요한 공용 인프라는 **회사 데이터**다. 에이전트가 접근할 수 있는 data warehouse를 깔자 BI 큐(*"1~2년"*)를 거치던 분석을 현업이 직접 돌렸다. 전제는 데이터를 먼저 모으고 정리해 AI가 필요한 context를 갖게 하는 것이다. ([[2026-11-23-working-with-ai]]) 이것은 [[context-and-memory]]가 다루는 질문(context window 밖에 무엇을 두고 누가 가져오는가)의 **조직 규모** 판본이다. 그 topic의 답이 개별 에이전트의 memory라면, 여기서는 회사 전체의 데이터 접근 정책이 된다. *(추론)*

데이터 접근은 권력 문제이기도 하다. 같은 데이터와 도구가 경영진의 감독을 강화할 수도 있고 직원의 재량을 넓힐 수도 있다. 누구에게 접근을 여느냐가 방향을 정한다.

## 5. 고용 — 짧게

해고보다 **채용 축소**로 온다. 인터뷰한 회사의 3분의 2가 AI 때문에 채용을 줄였고, 자동화로 인한 실제 해고는 2곳이었다. 모듈화된 외주(특히 offshore)가 가장 먼저 줄었다. 상세 수치는 [[2026-11-23-working-with-ai]] Key Claim 13.

## Key Points

- **가치가 큰 AI 적용은 조직 변화를 동반했다.** 가벼운 적용은 대부분 가치가 낮다.
- **top-down 자동화는 모델 개선으로 낡는다.** [[meta-harness]]의 "가정은 썩는다"가 조직 규모에서 나타난다.
- **전문가가 협조해야 자동화가 선다.** 그런데 그 자동화가 전문가를 대체한다. eval·judge 설계가 전제하는 협조는 공짜가 아니다.
- **bottom-up은 개인 구역을 넘지 못한다.** 유지보수와 고르지 않은 가속이 막는다.
- **병목은 조직 안이다.** 가장 흔한 것은 AI 출력의 리뷰. 규제·고객은 드물다.
- **재편은 세 갈래다.** 역할 확대(핸드오프의 context loss를 줄인다), 병목 업무로 재배치, 공용 데이터·인프라.
- **에이전트 운영이 새 직무다.** 전사본을 읽고 prompt를 고치는 일이 넓어진 역할의 일부가 된다.

## Open Questions

- **측정이 없다.** 가치는 자기 보고, 분류는 자동 코더다. "조직 변화 ↔ 가치"의 상관이 인과인지, 성공한 사람이 조직 변화를 더 많이 이야기한 것인지 구분되지 않는다.
- **재편의 실패 사례가 없다.** top-down과 bottom-up은 실패를 자세히 다루지만, 재편은 성공 사례로만 나온다. 역할을 넓혔다가 실패한 회사는 어떤 모양인가?
- **역할 확대와 리뷰 능력.** 한 사람이 workflow 전체를 소유하면 리뷰도 그 사람이 한다. [[ai-native-sdlc]]의 *"리뷰 천장은 사람"* 과 충돌하지 않는가? 두 사람이 동의하면 ship한다는 원칙의 한계는 어디인가?
- **읽는 눈은 어떻게 길러지나.** 셋째 로펌은 AI 초안을 신입과 선임이 함께 고치는 것으로 답했다. [[ai-native-sdlc]]의 같은 질문(spec을 쓰지 않는 PO)에 이 방식이 통하는지는 아직 근거가 없다.
- **표본 편향.** 전원이 Anthropic 고객이고 연구 주체가 Anthropic이다. 다른 벤더 고객이나 AI를 도입하지 않은 회사와의 비교가 필요하다. → [[anthropic]]

## Related

- [[ai-native-sdlc]] — 이 topic의 소프트웨어 조직 판본. 병목 이동, skill로서의 조직 지식, 리뷰 천장
- [[meta-harness]] — top-down 자동화가 낡는 방식의 원리. 고정된 workflow 대신 오래 사는 인터페이스
- [[loop-engineering]] — 에이전트 운영(전사본 읽기)과 comprehension debt, taste 모순
- [[agent-evaluation]] — 전문가가 에이전트 출력을 채점하는 새 업무, 낡은 모델 채점기
- [[context-and-memory]] — 공용 데이터를 에이전트의 context로. 개별 에이전트 규모의 같은 질문
- [[agentic-governance]] — "모든 직원이 개발자"가 만드는 공격 표면을 다루는 통제 계층
- [[artifact-chain]] — 핸드오프의 context loss를 커밋된 파일로 줄이는 장치

## Sources

- [[2026-11-23-working-with-ai]] — Wilmers·Massenkoff·McCrory (Anthropic Institute, 2026-11-23). 중심 소스
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton (2026-08-21). skill로서의 조직 지식, 리뷰 게이트
- [[2026-04-08-scaling-managed-agents]] — Martin 외 (2026-04-08). harness 가정의 노후화 (meta-harness 경유)
- [[2026-06-07-loop-engineering]] — Addy Osmani (2026-06-07). comprehension debt, taste 모순
- [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu. judge로서의 자기 자동화
