---
title: Working with AI
type: source
created: 2026-11-27
updated: 2026-11-27
source_file: ../../raw/papers/2026-11-23-working-with-ai.pdf
source_url: https://www.anthropic.com/research/working-with-ai
author: Nathan Wilmers, Maxim Massenkoff, Peter McCrory
publisher: The Anthropic Institute (Technical Report)
source_date: 2026-11-23
tags: [ai-adoption, organizations, labor, bottlenecks, enterprise-ai, qualitative-research]
status: mature
---

# Working with AI

> Anthropic 엔터프라이즈 고객사 58곳을 66번 인터뷰한 질적 연구다. AI의 가치가 큰 적용일수록 조직을 바꿨다. top-down 자동화는 깨지기 쉽고 bottom-up 실험은 개인 범위를 넘지 못한다. 둘을 넘은 회사는 역할을 넓히고, 사람을 병목 업무로 옮기고, 데이터와 인프라를 공용으로 깔았다.

## Context

The Anthropic Institute의 기술 보고서다. 저자 셋은 경제학·조직 연구자다(Wilmers, Massenkoff, McCrory). McCrory는 Anthropic Economic Index 보고서의 공저자이기도 하다. **이 위키의 첫 조직·노동경제 소스이고, 첫 Institute 소스다.** 지금까지 들어온 Anthropic 소스는 모두 엔지니어링 블로그나 제품 블로그였다.

**방법.** 미국 기업 58곳의 경영진·관리자·실무자와 25~40분짜리 화상 인터뷰를 66회 했다. 산업은 AI-native 스타트업부터 100년 된 제조사, 로펌, 치과, 운송사까지 넓다. 인터뷰 전사본에서 적용 사례·병목·역할 변화를 **자동 코더(automated coder)** 가 분류했다. 그림 1은 AI 적용 약 300건을 "자기 보고 가치" × "조직 변화 정도(0~100)"로 찍는다.

**읽을 때 주의할 것.**
- **표본은 대표성이 없다.** 저자들이 다양성을 기준으로 골랐고, 연락한 회사 중 일부만 응했다. Census BTOS의 AI 도입 기업과 비교하면 규모가 크고 소프트웨어·금융 쪽으로 치우쳤다.
- **가치는 자기 보고다.** A/B 테스트나 정량 측정에 기반하지 않는다(각주 1).
- **전원이 Anthropic 고객이다.** 다른 AI 도구도 쓰지만, 연구 주체가 자기 고객을 인터뷰한 구조다. → [[anthropic]]
- 저자들 스스로 *"stories and a framework"* 를 내놓고 정량 후속 연구가 검증하길 기대한다고 쓴다.

## Key Claims

1. **가치가 큰 적용일수록 조직 변화를 요구했다.** 조직을 그대로 두고 끼워 넣을 수 있는 가벼운 적용(임시 데이터 분석, 슬라이드 디자인)은 대부분 가치가 낮게 평가됐다. 가치가 큰 쪽은 프로세스를 바꾸거나(*모든 커밋에 AI 리뷰*) 역할을 바꿨다(*개별 문서를 디자인하는 대신 브랜딩 가이드라인이 든 `skill.md`를 편집하는 마케팅 매니저*). 성공이 하류 변화를 강제하기도 한다. 직원이 고객 문서를 직접 내보내기 시작하자 "외부 자료는 마케팅을 거친다"는 SOP가 무너졌다.

2. **가치는 대부분 비용 절감이 아니라 산출 증가다.** 산출 증가의 절반은 기존 일을 빠르게 하거나 넓힌 것이고, 나머지 절반은 품질 개선이나 새 제품이다(보험 적용 후 비용 사전 견적, 야간 AI 응답 서비스). 약 10분의 1은 직원이 가치를 가져갔다. 일이 즐거워졌거나 일을 덜 하게 됐다.

3. **AI로 만든 소프트웨어 100건 중 80%는 수작업을 자동화했고, 20%는 기존 소프트웨어를 대체했다.** 140건을 역할 × 목적으로 나누면 제품 기능과 기술 인프라는 여전히 기술직이 맡는다. 비기술직은 내부 앱과 대시보드를 만든다. 즉 비개발자가 만든 소프트웨어 대부분은 **여전히 기술직의 지원이나 인프라가 필요하다.**

4. **top-down 자동화는 고용을 바꾸지만 깨지기 쉽다.** 외주 계약 축소(9곳)와 채용 축소가 여기서 나온다. 문제는 셋이다.
   - **빨리 낡는다.** 고객 상담원을 수십 개 차원으로 채점하는 시스템이 **2년 된 모델**로 돌고, 관리자들은 그 점수를 진지하게 받아들이지 않는다. 문서 관리 자동화는 거의 안 쓰이는 "zombie" 앱으로 남았다. *"It'll be obsolete in three months."* *"spinning dart board에 다트를 던지는 것 같다."*
   - **전문가가 저항한다.** 효과적인 workflow는 전문가가 prompt를 설계하고 출력을 평가해야 선다. 전문가에게 자기를 대체할 시스템을 만들라는 요구다. *"If I'm open to this, I'm essentially building my own coffin."* 승인 workflow를 자동화해 리뷰어 채용을 90% 넘게 줄이려던 회사는 리뷰어들이 따르지 않아 기프트카드를 검토했다.
   - **어려운 일을 다른 사람에게 떠넘기면 무너진다.** 이해충돌 검사 에이전트는 예전엔 변호사에게 넘어가던 복잡한 건을 검사 담당 직원 앞에 쌓았고, 직원들이 반발해 폐기됐다.

5. **감시(monitoring)도 top-down 적용의 한 형태다.** 한 경영자는 *"이제는 관리자가 쓰는 에이전트에게 내 일을 legible하게 만들어야 한다"* 고 했다. 정확한 피드백과 *"panopticon effect"* 사이에서 양가적이었다. 보고서는 Anthropic Usage Policy가 감시의 고지와 범위 제한, 고용 결정에서의 human-in-the-loop를 요구한다고 적고, 들은 사례는 이를 준수한 것으로 보였다고 쓴다.

6. **bottom-up 실험은 개인을 강하게 만들지만 조직으로 번지지 않는다.** 도메인 전문성이 깊은 비기술직이 가장 큰 가치를 얻었다. 80시간 걸리던 401(k) 감사를 앱으로 만든 회계사가 그 예다. 그러나 그 앱은 외부 벤더가 다시 구현해야 했고 몇 달 뒤에도 쓰이지 않았다. 한계는 셋이다.
   - **유지보수.** *"그 돈은 vibe coding으로 아낄 수 있다. 하지만 유지보수 비용도 오른다."*
   - **고르지 않은 가속.** 10개 언어 번역 기능을 만들었지만 그 언어로 전화를 받을 사람이 없어 출시하지 않았다.
   - **비사용자에게 비용을 지운다.** 파워 유저가 *"Claude grenades"* 를 던진다. *"A mediocre engineer with an AI is a menace to society."*
   
   개인은 자기 구역 안에서만 바꿀 수 있다. *"Not 'Claude, write the email,' but, 'Why are you even getting the email?'"* 저자들은 이를 Paul David의 전기 모터 사례에 비긴다. 공장이 증기 시대의 배치를 유지한 채 모터만 갈아 끼우는 동안 생산성이 늦게 올랐다.

7. **병목은 조직 안에서 생긴다(그림 4).** 가장 자주 나온 것은 **AI 출력의 리뷰**다. 양이 희소한 사람의 주의를 압도한다. API endpoint에 잘못 붙은 "S" 하나가 계획된 출시를 깨뜨렸다. 그다음이 코딩은 빨라졌는데 다른 기능이 못 따라가는 것, 고르지 않은 도입, context·인프라 부족이다. **고객 회의론과 규제는 드물게 언급됐다.**

8. **재편의 첫 경로: 역할을 넓힌다.** 한 사람이나 작은 팀이 workflow 전체를 소유하면 조정 비용과 거부권이 사라진다. *"Two people plus Claude is the most amazing thing… if two people agree on something, just ship it."* 리드 소싱·AE·고객 성공을 한 역할로 합친 회사, *"designer, PM, engineer, QA, infrastructure를 하나의 역할로 접은"* 회사가 나온다. AI는 각 단계의 세부를 따라가기 쉽게 만들고, 동료에게 넘길 때의 *"context loss"* 를 더 비싸게 만든다.

9. **넓어진 역할에는 에이전트 운영이 들어간다.** 장애 알림 티켓 응답을 자동화한 엔지니어는 배포 후 두 달간 **모든 대화 전사본을 읽고** prompt를 고치고, 깨진 integration을 고치고, 빠진 벤더 문서를 채우고, 에이전트의 권한 요청을 승인했다. 6개월 뒤 시스템이 잘 돌 때도 **2주마다 전사본을 표본으로 읽었다.** 그 에이전트는 회사 전체의 Slack 에이전트가 됐고, 다시 모든 노트북의 skill과 context를 최신으로 유지하는 에이전트가 됐다. 현재 모델 능력에서 agentic workflow는 전문가의 적극적 관여와 지속적 유지보수가 필요하고, 그래서 역할이 넓어진 전문가는 해고를 덜 두려워한다.

10. **재편의 두 번째 경로: 사람을 병목 업무로 옮긴다.** *"the entire job has switched right from writing code to making decisions."* 일은 대인·전략 업무로 옮겨간다. 한 CTO는 PM을 product-market fit을 알아보는 일로 돌렸다. *"Claude is a terrible product manager... So it's a lot of taste deciding what features are important."* 엔지니어에게는 **코드 리뷰가 결정적 병목**이 됐다. 리뷰를 자동화한 회사, 리뷰 시간을 늘린 회사, **공식 코드 리뷰를 아예 없애고 Claude 옆에 앉아 함께 코드를 평가하는** 회사가 있었다. 새로운 일도 생긴다. CPA가 금융 에이전트의 출력을 채점하고, 생산 계획자가 에이전트에게 숫자의 맥락을 주는 data labeler가 된다.

11. **고정된 조직 계획은 모델 개선을 따라가지 못한다.** *"3개월 기다리면 AI가 못 할 줄 알았던 게 된다. 그러면 계획 전체를 고쳐야 한다."* *"If the world could just pause for a minute and let us get some harnesses in place, that would be great."* 저자들의 결론은 역할 변경을 쉽게 만드는 **scaffolding**이다. 병목은 계속 움직인다.

12. **재편의 세 번째 경로: 공용 인프라, 특히 데이터.** 비기술직이 보안 취약점이나 엔지니어 유지보수 부담 없이 앱을 만들 수 있는 공용 인프라를 깐다(*"Every single employee now is a developer… creating additional attack surface every day"*). 가장 중요한 공용 인프라는 **회사 데이터**다. 에이전트가 접근할 수 있는 data warehouse를 깔자 BI 팀의 큐(*"1~2년"*)를 거치던 분석을 현업이 직접 SQL로 돌렸다. 전제는 데이터를 먼저 모으고 정리해 AI가 필요한 context를 갖게 하는 것이다. AI-native 스타트업은 *"모든 것을 전사한다"*. 데이터 접근을 누구에게 여느냐가 같은 기술을 직원 쪽으로 기울일 수도, 경영진의 감독 쪽으로 기울일 수도 있다.

13. **고용 영향은 해고보다 채용 축소로 온다.** 자동화로 실제 해고가 난 곳은 2곳, AI를 안 쓰는 직원을 내보낸 곳은 5곳, AI 때문에 채용을 늘린 곳은 10곳이다. **3분의 2가 AI 때문에 채용을 줄였다.** *"We may not be firing, but we're not hiring."* 9곳이 외주(특히 offshore)를 끊었다. 모듈화된 과업이라 넘기기 쉬웠기 때문이다. 추정치를 준 스타트업 6곳은 AI 없이는 평균 **4배** 인원이 필요하다고 했다. 운영 예산의 90%가 토큰, 10%가 인건비라는 COO도 있었다. *"We've added a lot of capacity by buying tokens instead of hiring people."*

14. **결론: 같은 기술을 같은 산업에 쓰고도 결과가 갈린다.** 도입 서두의 세 로펌이 그 예다. 첫째는 우편실을 자동화했고, 둘째는 병목에 막혔고, 셋째는 아무도 해고하지 않고 재편했다. 셋째 로펌은 신입이 초안을 쓰지 않게 되자 *"그러면 신입은 좋은 초안과 나쁜 초안을 어떻게 구별하나?"* 를 묻고, **AI가 쓴 초안을 신입과 선임이 함께 고치는** workflow를 새로 만들었다. 저자들은 이득을 직원과 나누는 것이 전문가가 workflow 재설계에 기여할 동기가 된다고 보고, 고용주가 *"AI가 일을 어떻게 바꿀지에 대해 어느 정도 발언권을 갖는다"* 고 맺는다. 강한 정책 대응을 대신하지는 않는다는 단서를 단다.

## Notable Quotes / Passages

> *"The closer you are to the money, the harder it is for models to excel in that job."*

> *"You want to make your work legible to your manager. But nowadays I think you want to make your work legible to the agents your manager uses."*

> *"You find a bottleneck. Find out how to tackle that. Have someone own that. …Code's no longer the problem."*

## Connections

- [[ai-in-organizations]] — 이 소스로 세운 topic. 세 도입 방식, 조직 안의 병목, 재편 경로 셋.
- [[ai-native-sdlc]] — "병목은 build 주변으로 옮겨간다"를 소프트웨어 조직 바깥까지 넓혀 확인한다. 이 소스의 셋째 로펌은 그 토픽의 Open Question("spec을 쓰지 않는 PO의 읽는 눈")과 같은 질문에 처방을 낸다.
- [[meta-harness]] — 2년 된 모델로 채점하는 시스템, 3개월이면 낡는 벤더 솔루션. "harness의 가정은 썩는다"의 조직 규모 판본이다.
- [[loop-engineering]] — taste 모순에 Osmani 쪽 현장 증언을 하나 더한다(*"Claude is a terrible product manager"*). 전사본 전수 읽기 → 표본 읽기는 comprehension debt를 줄이는 실제 운영 형태다.
- [[agent-evaluation]] — 전문가가 에이전트 출력을 채점하는 일이 새 직무로 생긴다. 낡은 모델 채점기는 신뢰를 잃는다.
- [[anthropic]] — 이 위키의 Anthropic 발행 소스 중 처음으로 엔지니어링이 아닌 연구 조직의 글이다.

## My Notes

- **엔지니어링 위키에 들어온 조직 소스.** 2026-11-27 합의에 따라 새 topic [[ai-in-organizations]]를 세웠다. 고용 영향(Key Claim 13)은 이 페이지에 두고 topic에는 짧게만 넣는다. 위키의 중심은 에이전트 엔지니어링이다.
- **리뷰를 없앤 회사.** Key Claim 10의 "공식 코드 리뷰 폐지"는 [[ai-native-sdlc]]가 리뷰 게이트를 전제하는 것과 어긋나 보인다. 모순으로 등록하지 않았다. 그쪽은 규제 엔터프라이즈를 독자로 두고, 이쪽은 한 회사의 관찰이다. 그리고 그 회사도 리뷰를 없앤 게 아니라 **비동기 리뷰를 동기 페어링으로** 바꿨다.
- **이 위키의 "수치"와 성격이 다르다.** 퍼센트(80%, 3분의 2, 4배)는 인터뷰 응답의 집계이고, 분류는 자동 코더가 했다. 측정값이 아니라 응답 분포로 읽어야 한다.
- 보고서는 Claude Code 사용 연구(*"Agentic Coding and Persistent Returns to Expertise"*, 비기술 전문가의 과업 성공률이 가장 높았다)와 Economic Index 보고서를 인용한다. 둘 다 아직 이 위키에 없다.

## Raw Source

[원본 파일](../../raw/papers/2026-11-23-working-with-ai.pdf)
