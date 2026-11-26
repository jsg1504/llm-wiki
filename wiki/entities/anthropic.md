---
title: Anthropic
type: entity
created: 2026-09-11
updated: 2026-11-27
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude, 2026-06-07-loop-engineering, 2026-08-14-practical-loop-engineering, 2026-09-30-loop-is-the-product, 2025-07-25-gepa-reflective-prompt-evolution, 2023-10-12-memgpt, 2023-03-20-reflexion, 2024-10-14-longmemeval, 2025-01-20-zep, 2025-02-17-a-mem, 2025-12-31-recursive-language-models, 2026-03-03-reproducing-recursive-language-models, 2024-12-19-building-effective-agents, 2022-10-06-react, 2023-02-09-toolformer, 2026-11-23-working-with-ai]
tags: [organization, ai-lab, claude, anthropic]
status: draft
---

# Anthropic

> Claude 모델군을 만드는 AI 연구·제품 조직. 이 위키의 소스 **20개 중 7개**가 Anthropic 발행이다(2026-11-27 기준). 비-Anthropic 13개 중 하나는 벤더 원문을 실어 나른다. 그래서 이 페이지는 **이 위키의 관점 편향을 추적하는 지점**이기도 하다.

## Overview

이 페이지는 Anthropic이라는 조직 전반을 다루지 않는다. **이 위키의 소스들이 드러내는 만큼만** 기록한다. 현재까지는 다섯 편의 실무 문서를 통해 네 가지 얼굴이 나타난다:

- **엔지니어링 조직으로서** — 자사 프로덕션 시스템(Research 기능)을 만들며 깨진 것들을 공개한다 ([[2025-06-13-multi-agent-research-system]]).
- **엔터프라이즈 조력자로서** — Applied AI 팀이 고객사와 일하며 얻은 패턴을 플레이북으로 낸다 ([[2026-08-21-the-ai-native-sdlc-playbook]]).
- **플랫폼 제공자로서** — 남의 에이전트 워크로드를 호스팅하며 겪은 아키텍처 전환을 공개한다 ([[2026-04-08-scaling-managed-agents]]). 앞의 둘과 성격이 다르다. 여기서는 Anthropic이 *에이전트를 만드는 쪽*이 아니라 **에이전트가 돌아갈 바닥을 까는 쪽**이다.
- **보안 사고 보고자로서** — 세 제품을 2년간 운영하며 **깨진 것들을 이름과 수치와 함께** 공개한다 ([[2026-05-25-how-we-contain-claude]]). 책임공개로 받은 취약점 3건, 자사 직원이 피싱당한 red-team, 서드파티가 찾아낸 유출 경로, 엔터프라이즈 도입 장애물. Anthropic 발행 다섯 소스 중 **홍보 인센티브와 가장 반대 방향으로 쓰인 글**이다.
- **고객을 연구하는 연구 조직으로서 (2026-11-27)** — The Anthropic Institute의 경제·조직 연구자들이 자사 엔터프라이즈 고객 58곳을 인터뷰한 질적 보고서를 낸다 ([[2026-11-23-working-with-ai]]). 이 위키에서 처음으로 **엔지니어링이 아닌** Anthropic 글이다. 자사 Usage Policy(직원 감시의 고지·범위 제한, 고용 결정의 human-in-the-loop)를 본문에서 직접 인용하는 것도 처음이다. → [[ai-in-organizations]]

## Key Points

### 언급되는 제품·모델

| 이름 | 이 위키에서의 등장 |
|---|---|
| **Claude Opus 4 / Sonnet 4** | 멀티에이전트 조합(Opus lead + Sonnet subagents)에서 단일 Opus 4 대비 90.2% 우위. Sonnet 3.7→4 업그레이드가 토큰 예산 2배보다 이득이 컸다. |
| **Research 기능** | 웹·Google Workspace·integration을 가로질러 검색하는 소비자 기능. [[orchestrator-worker]] 구조의 실제 구현체. |
| **[[claude-code]]** | [[2026-08-21-the-ai-native-sdlc-playbook]]의 축이 되는 에이전틱 코딩 도구. |
| **MCP** | 외부 도구 접근 프로토콜. 도구 설명 품질 편차가 에이전트를 잘못된 경로로 보낸다는 문제 제기의 맥락에서 등장. [[managed-agents]]에서는 자격증명을 vault 뒤에 두는 프록시 경로로도 쓰인다. 2024년 글은 augmented LLM의 구현 방법으로 소개한다. → [[tool-use]] |
| **[[managed-agents]]** | Claude Platform의 호스팅 에이전트 서비스. [[meta-harness]] 사상의 유일한 구현 사례. |
| **Claude Sonnet 4.5 / Opus 4.5** | "context anxiety"와 그 소멸의 사례로 등장. harness 가정이 모델 세대를 넘어 노후화한다는 증거. |
| **Claude Opus 4.7** | Gray Swan Agent Red Teaming 수치의 대상. 단발 공격 성공률 ~0.1%, 100회 적응적 공격 후 5~6%. |
| **Claude Cowork** | 비기술 지식 노동자용 데스크톱 제품. 로컬 VM 격리(sealed VM)의 사례. → [[agent-containment]] |
| **claude.ai** | gVisor 기반 서버측 코드 실행(ephemeral container). 세 격리 패턴 중 blast radius가 가장 작다. |

### 문서 작성 방식의 특징

세 소스에서 공통으로 보이는 패턴:

- **실패 사례를 구체적으로 공개한다.** subagent 50개를 띄운 초기 에이전트, 중복 검색을 한 3개 중 2개, SEO 콘텐츠팜 편향, 자사 초기 아키텍처가 사실상 디버깅 불가능했다는 고백, **책임공개로 받은 취약점 3건과 자사 직원이 피싱당한 red-team 결과(25회 중 24회 유출 성공)** 등.
- **자사 제품에 불리한 한계도 명시한다.** 멀티에이전트의 15배 토큰 비용, 코딩 도메인 부적합 판정, 자사 harness에 넣은 구조가 다음 모델에서 dead weight가 됐다는 기록, **권한 프롬프트의 93%가 승인된다는 텔레메트리(자사 UX의 실패)**, **격리가 고객의 EDR도 막는다는 도입 장애물.**
- **주장의 강도를 수치로 제한한다.** *"모델 층위 방어는 결코 100%가 아니다"*, *"auto mode는 sandbox 대체재가 아니다(~17% 통과)"* 처럼 자사 기능의 상한을 명시한다.
- **단, 핵심 수치는 내부 eval이고 루브릭은 비공개다.** 90.2% 같은 숫자는 외부 재현이 불가능하다.

> 이 위키의 소스가 한 조직에 편중되어 있다는 점을 의식할 것. **소스 7개 중 5개가 Anthropic 발행이며**, [[multi-agent-systems]]의 모순 판정도 전부 이 출처들에 기대고 있다. 정량 근거의 두께는 소스마다 다르다 — [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]는 수치를 전혀 제시하지 않는 경험 보고이고, [[2026-04-08-scaling-managed-agents]]의 검증 가능한 숫자는 TTFT 개선 하나뿐이며, [[2026-05-25-how-we-contain-claude]]가 이 위키에서 가장 두꺼운 수치를 낸다.

> **편향의 성격이 소스마다 다르다 (2026-09-21).** "Anthropic 발행이니 자사에 유리하게 쓰였을 것"이라는 경계가 모든 소스에 같은 무게로 적용되지는 않는다.
>
> - [[2026-05-25-how-we-contain-claude]]는 **홍보 인센티브와 반대 방향**이다. 자사 취약점·red-team 실패·도입 장애물을 구체적으로 공개한다. 이 소스에는 그 경계가 덜 적용된다.
> - **대신 다른 경계가 필요하다:** 여기 공개된 것은 **발견되고 수정된 것들**이다. 발견되지 않은 것의 분포는 알 수 없다. 그리고 **완화 이후의 재측정이 없다** — 93%, 84%, 83%, 0.1% 같은 숫자는 전부 문제를 진단하는 쪽이고 해결을 검증하는 쪽이 아니다.
> - 같은 소스가 이 위키에 들어온 소스 중 **처음으로 외부 기관을 참조 지점으로 제시한다** — NIST의 AI agent identity/authorization 프로젝트, 호주 ACSC·CISA·영국 NCSC 등 6개 기관의 agentic AI 도입 지침, ISO/IEC 42001. *"partners and competitors 양쪽과 함께 일하기를 기대한다"* 고 쓴다. 외부 관점 부재를 메울 **구체적 단서**다.

> **자기 고객을 연구한 소스 (2026-11-27) — 편향이 두 겹이다.** [[2026-11-23-working-with-ai]]는 Anthropic 연구자가 **Anthropic 고객**을 인터뷰했다. 응답자 전원이 Claude를 쓰고(다른 도구도 쓴다), 표본은 연구자가 다양성 기준으로 골랐고, 연락한 회사 중 일부만 응했다. 가치 평가는 자기 보고이고 분류는 자동 코더가 했다. 경계할 것은 둘이다.
>
> - **선택 편향.** AI 도입에 적극적인 고객이 더 응했을 가능성이 있다. 저자들은 Census BTOS와 비교해 규모·산업 편향을 스스로 밝힌다(소프트웨어·금융 과대, 소매·운송 과소).
> - **톤은 홍보 쪽이 아니다.** 해고 사례, 감시의 *"panopticon effect"*, 깨지기 쉬운 자동화, *"Claude grenades"*, *"Claude is a terrible product manager"* 같은 자사 제품에 불리한 증언을 그대로 싣는다. [[2026-05-25-how-we-contain-claude]]와 같은 방향의 공개다. 다만 결론(조직 재편이 해법이고 Anthropic이 교육과 지원으로 도와야 한다)은 벤더의 이해와 어긋나지 않는다.
>
> 이 소스의 퍼센트(80%, 3분의 2, 4배)는 **측정값이 아니라 응답 분포**로 세야 한다. 이 위키에서 Claude를 외부에서 잰 데이터의 목록에는 넣지 않는다.

> **첫 외부 소스가 들어왔다 (2026-09-21) — 그러나 관점의 외부성이지 증거의 외부성은 아니다.** [[2026-06-07-loop-engineering]](Addy Osmani, 개인 블로그)이 이 위키 최초의 비-Anthropic 소스다. 무엇을 메우고 무엇을 못 메우는지를 구분해 기록한다.
>
> - **메우는 것 — 벤더 단일 시점의 해소.** Codex와 Claude Code를 대칭으로 놓고 다섯 primitive(automations·worktrees·skills·connectors·subagents)가 양쪽에 다 있다고 기록한다. [[claude-code]]가 이 기능군의 유일한 구현이 아니라는 첫 근거다. 그리고 maker/checker 분리를 벤더 밖에서 재확인한다 → [[subagent]], [[agent-evaluation]]
> - **메우는 것 — 반대 방향의 톤.** 처방을 제시하면서 결론을 유보로 끝낸다(검증 책임, comprehension debt, cognitive surrender, 토큰 비용). 위 목록의 *"비판"* 항목에 부분적으로 해당한다. → [[loop-engineering]]
> - **못 메우는 것 — 독립 벤치마크.** 저자는 두 벤더의 제품 문서와 X 포스트를 읽고 정리했지 **스스로 측정하지 않았다.** 정량 데이터가 하나도 없다. 위 목록의 *"독립 벤치마크"* 와 *"경쟁 아키텍처"* 는 여전히 비어 있다.
> - **못 메우는 것 — 순환 참조.** 이 소스가 인용하는 두 권위 중 하나가 Claude Code 책임자 Boris Cherny다. 외부 소스가 내부 주장을 전달하는 경로도 섞여 있다.

> **외부 소스가 벤더 원문을 실어 나른다 (2026-09-21) — 세는 법에 주의.** 두 번째 외부 소스 [[2026-08-14-practical-loop-engineering]]의 상당 부분이 **Claude Code 팀의 X article을 그대로 인용한 것**이다 — 네 종류의 루프 분류, goal/time/proactive 각각의 설명, `verify-frontend-change` skill, composed example. 즉 Anthropic 원문이 외부 저자를 **경유해** 들어온다.
>
> - 이 위키가 가진 것은 **인용본이지 원문이 아니다.** 원문(X article)은 raw에 없고, 인용된 범위 밖은 확인할 수 없다.
> - **"비-Anthropic 소스 2개 확보"로 세면 착시다.** 발행처로는 2개지만 내용의 출처로는 그렇지 않다.
> - 저자 고유의 기여는 **운용 경험** 쪽이다 — 위임 경계(무엇을 완전 위임하고 무엇을 감시하는가), judgment 위임 실패담, PR triage 사례, "3회 무변화면 멈춰라". 이쪽은 벤더가 말하지 않는 것이고, 실제로 벤더 톤과 다르다.
> - **다만 이 경로가 값을 하나 냈다.** 저자가 벤더 문서를 정확히 읽은 덕에 이 위키의 오독 하나가 잡혔다 — `/goal`의 evaluator를 품질 판정자로 적은 것. → [[agent-evaluation]] §2b의 정정, [[loop-engineering]]

> **처음으로 Anthropic을 전혀 거치지 않는 소스 (2026-09-30).** [[2026-09-30-loop-is-the-product]](Roland Gavrilescu, Introspection)는 발행처도 Anthropic이 아니고, Anthropic 원문을 인용하지도 않는다. Claude Code는 **사용자가 떠나올 경쟁 대상**으로 한 번 언급될 뿐이다.
>
> - **메우는 것 — 순환 참조의 해소.** 앞의 두 외부 소스가 가진 문제(내부 권위 인용, 벤더 원문 전달)가 없다.
> - **못 메우는 것 — 편향의 종류만 바뀌었다.** 벤더 편향 대신 **스타트업 제품 편향**이다. 개념 설명이 곧바로 자사 `pi.recipes` 소개로 이어진다. 정량 데이터는 여전히 0이다.
> - **값을 낸 것 — 실질적 반론 하나.** Osmani의 *"taste는 루프에 맞지 않는다"* 에 정면으로 반대한다. → [[loop-engineering]]의 Contradiction 절

> **처음으로 학술적이고 정량적인 독립 소스 (2026-11-25).** [[2025-07-25-gepa-reflective-prompt-evolution]](UC Berkeley·Stanford·Databricks 등, ICLR 2026 Oral)은 Anthropic을 발행처로도 인용 경로로도 거치지 않는다. 실험 모델에 Claude가 없다(Qwen3 8B, GPT-4.1 Mini, GPT-4o, GPT-5 Mini).
>
> - **메우는 것 — 동료 심사와 수치.** 이 위키가 계속 비어 있다고 적어 온 *"독립 벤치마크"* 칸에 처음으로 들어오는 소스다. 6개 benchmark, 2개 모델, 공개 코드, baseline 4종 비교가 있다.
> - **못 메우는 것 — 이 위키의 중심 주제.** 다루는 대상은 고정된 파이프라인의 prompt 최적화다. 멀티에이전트 조정, 격리, 장기 실행 코딩 에이전트에 대한 Anthropic 소스들의 주장을 직접 검증하지는 않는다.
> - **편향의 종류가 또 바뀐다.** 벤더나 스타트업 제품이 아니라 **자기 도구 편향**이다. 주요 비교 대상(MIPROv2)의 저자와 DSPy 창시자가 공저자이고, 벤치마크도 같은 연구 계열에서 왔다.
> - **세는 법:** 소스 9개 중 Anthropic 발행 5개, 비-Anthropic 4개. 비-Anthropic 중 **스스로 측정한 소스는 이것 하나**다.

> **두 번째 독립 측정 소스, 그러나 같은 연구실 계열 (2026-11-26).** [[2023-10-12-memgpt]](UC Berkeley, arXiv preprint)도 Anthropic을 발행처로도 인용 경로로도 거치지 않는다. 실험 모델은 GPT-3.5/GPT-4/GPT-4 Turbo이고 Claude는 없다.
>
> - **메우는 것 — 장기 memory.** 이 위키가 비어 있다고 적어 온 칸이다. 스스로 만든 과제 네 개에서 수치를 낸다. → [[agent-memory]]
> - **못 메우는 것 — 동료 심사와 공정한 비교.** preprint이고, baseline은 원본 대화 대신 손실 요약을 받았으며, 판정자에게 후하게 채점하라고 했다. 2023년 모델만 실험했다.
> - **외부 소스끼리의 독립성.** Ion Stoica가 GEPA와 MemGPT 양쪽의 공저자다. 둘 다 UC Berkeley 계열이다. 비-Anthropic 소스가 늘었지만 **학술 소스 두 개는 같은 연구 그룹에서 나왔다.** 서로를 독립적인 확인으로 세면 안 된다.
> - **세는 법:** 소스 10개 중 Anthropic 발행 5개, 비-Anthropic 5개. 비-Anthropic 중 스스로 측정한 소스는 GEPA와 MemGPT 둘이다.

> **처음으로 다른 연구 그룹의 학술 소스 (2026-11-26).** [[2023-03-20-reflexion]](Northeastern·MIT·Princeton)은 Anthropic을 거치지 않고, GEPA·MemGPT의 UC Berkeley 계열과도 저자가 겹치지 않는다. 실험 모델은 GPT-3/3.5/4, text-davinci-003, starchat-beta다.
>
> - **메우는 것 — 학술 소스의 독립성.** 앞의 두 학술 소스가 같은 연구 그룹이라는 문제를 완화한다. 텍스트 반성을 끈 ablation처럼 GEPA에 없던 비교도 있다.
> - **못 메우는 것 — 최신 모델.** 2023년 모델만 실험했다. 위키의 정량 학술 소스 셋 중 둘이 2023년 것이다.
> - **세는 법:** 소스 11개 중 Anthropic 발행 5개, 비-Anthropic 6개. 비-Anthropic 중 스스로 측정한 소스는 GEPA, MemGPT, Reflexion 셋이다.

> **경쟁사 제품을 실측한 학계·산업 공동 소스 (2026-11-26).** [[2024-10-14-longmemeval]](UCLA·Tencent AI Lab·UCSD, ICLR 2025)은 Anthropic을 거치지 않는다. 대신 **OpenAI의 ChatGPT memory**와 ByteDance 계열 Coze를 직접 쟀다. 판정자도 GPT-4o다. Claude는 실험 어디에도 없다.
>
> - **메우는 것 — 동료 심사와 측정 도구.** ICLR 게재이고, 판정자를 사람과 대조한 결과를 공개한다. 위키의 memory 클러스터에서 처음으로 "재는 법"을 준다.
> - **못 메우는 것 — Anthropic 제품에 대한 독립 측정.** 이 위키는 여전히 Claude 계열을 외부에서 잰 소스가 없다. 외부 학술 소스 넷 모두 OpenAI·오픈 모델로 실험했다.
> - **편향의 종류.** 제1저자가 Tencent 인턴이고 Tencent 연구자 셋이 공저다. 자사 제품을 평가하지는 않는다.
> - **세는 법:** 소스 12개 중 Anthropic 발행 5개, 비-Anthropic 7개. 비-Anthropic 중 스스로 측정한 소스는 GEPA, MemGPT, Reflexion, LongMemEval 넷이다.

> **처음으로 Claude를 외부에서 잰 데이터, 그리고 두 번째 벤더 소스 (2026-11-26).** 두 소스가 함께 들어왔다.
>
> - [[2025-02-17-a-mem]](Rutgers 등, preprint)의 부록에 **Claude 3.0 Haiku와 3.5 Haiku** 실험이 있다. 위에 적은 "Claude를 외부에서 잰 소스는 아직 없다"가 처음으로 부분 해소된다. 단 신뢰도가 낮다. 대화 전체를 넣은 baseline의 F1이 Claude 3.0 Haiku에서 0.82~4.56으로, 같은 baseline의 GPT-4o-mini 수치(12~69)보다 비정상적으로 낮다. 원인 설명은 없다. Haiku 등급만 있고 주력 모델(Sonnet, Opus)은 없다.
> - [[2025-01-20-zep]](Zep AI)은 **자사 제품을 소개하는 벤더 preprint**다. Anthropic 소스들이 가진 것과 같은 종류의 편향(자사 시스템을 자사가 측정)을 다른 회사가 갖는다. 비교 대상, 보고 범위(abstention 제외), 측정 조건을 모두 저자가 정했다.
> - **세는 법:** 소스 14개 중 Anthropic 발행 5개, 비-Anthropic 9개. 비-Anthropic 중 스스로 측정한 소스는 GEPA, MemGPT, Reflexion, LongMemEval, Zep, A-MEM 여섯이다. 그중 Zep은 벤더 자사 측정이다.

> **Claude Code를 외부에서 잰 첫 데이터, 그리고 DSPy 계열 두 번째 소스 (2026-11-26).** [[2025-12-31-recursive-language-models]](MIT CSAIL, preprint)가 들어왔다.
>
> - **메우는 것 — 주력 모델과 제품의 외부 측정.** Claude Code v2.0.0 + **Opus 4.1**을 long-context baseline으로 쟀다. A-MEM의 Haiku 결과에 이어 Claude를 외부에서 잰 두 번째 데이터이고, 주력 모델과 Anthropic 제품을 잰 것은 처음이다. offloading한 Claude Code는 BrowseComp+ 84.0으로 강했고, OOLONG-Pairs에서는 6.5로 약했다. → [[claude-code]]
> - **못 메우는 것 — 중립성.** 측정한 쪽은 Claude Code의 **경쟁 scaffold**(RLM)를 낸 저자들이다. Claude Code만 Opus 4.1로, 나머지는 GPT-5로 돌려 모델 차이가 섞인다. 논문은 Anthropic 2025(Claude Code subagent 문서)를 *"verbalize sub-calls"* 하는 방식의 예로 비판한다.
> - **외부 소스끼리의 독립성.** Omar Khattab이 GEPA에 이어 이 소스의 공저자다. GEPA와 이 소스를 서로 독립적인 확인으로 세면 안 된다. 이 소스는 MemGPT를 인용하지만 같은 그룹은 아니다.
> - **순환 하나가 닫혔다.** Anthropic 소스 [[2026-04-08-scaling-managed-agents]]가 이 논문을 선행 연구로 링크했다. 벤더가 학술 연구를 인용한 경로가 위키 안에서 양쪽 끝이 다 보이는 첫 사례다.
> - **세는 법:** 소스 15개 중 Anthropic 발행 5개, 비-Anthropic 10개. 비-Anthropic 중 스스로 측정한 소스는 GEPA, MemGPT, Reflexion, LongMemEval, Zep, A-MEM, RLM 일곱이다. 그중 Zep은 벤더 자사 측정이다.

> **첫 독립 재현 (2026-11-26).** [[2026-03-03-reproducing-recursive-language-models]](CUHK, 단독 저자, 과제 보고서 형식)가 RLM을 원 저자 그룹 밖에서 재현했다.
>
> - **메우는 것 — 저자 측정만 있던 상태.** 이 위키의 비-Anthropic 측정 소스는 지금까지 전부 자기 방법을 자기가 쟀다. 남의 방법을 다시 잰 것은 이것이 처음이다(Zep의 DMR 재측정은 경쟁 제품을 다시 잰 것이라 성격이 다르다).
> - **못 메우는 것 — 규모와 Claude.** 조건당 20문항, 1회 실행이다. 실험 모델은 DeepSeek v3.2와 Kimi K2로, Claude는 없다.
> - **세는 법:** 소스 16개 중 Anthropic 발행 5개, 비-Anthropic 11개. 비-Anthropic 중 스스로 측정한 소스는 여덟이다. 그중 Zep은 벤더 자사 측정, 이 소스는 남의 방법의 재현이다.

> **바닥을 까는 세 소스 — 둘은 경쟁 연구소 (2026-11-27).** 에이전트 기초를 채우려고 세 소스를 함께 넣었다. [[2024-12-19-building-effective-agents]](Anthropic, 2024-12), [[2022-10-06-react]](Princeton·Google Brain, ICLR 2023), [[2023-02-09-toolformer]](Meta AI, 2023-02).
>
> - **메우는 것 — 다른 연구소의 원전.** ReAct와 Toolformer는 Anthropic을 발행처로도 인용 경로로도 거치지 않는다. 이 위키 처음으로 **Google과 Meta**, 즉 다른 프런티어 모델 연구소에서 나온 소스다. 지금까지 학술 소스는 대학, 일부 기업 연구소(GEPA의 Databricks, LongMemEval의 Tencent AI Lab), 스타트업 벤더(Zep)에서 나왔다. 다만 둘 다 Claude가 나오기 전의 모델(PaLM, GPT-3, GPT-J)로 쟀다. Claude에 대한 데이터는 아니다.
> - **못 메우는 것 — 정의는 여전히 Anthropic 글.** [[agent-fundamentals]]의 workflow vs agent 구분, 다섯 workflow, ACI는 모두 [[2024-12-19-building-effective-agents]]에서 왔다. 그 글은 수치가 없는 실무 조언이고, 받은 판본은 2026년 개정판이다. 개정 주석은 자사 제품([[managed-agents]])을 가리킨다. 이 긴장은 [[meta-harness]]에 부분 판정 모순으로 기록했다.
> - **세는 법:** 소스 19개 중 Anthropic 발행 6개, 비-Anthropic 13개. 비-Anthropic 중 스스로 측정한 소스는 열이다. 그중 Zep은 벤더 자사 측정, RLM 재현은 남의 방법의 재현이다.

> **추가로 의식할 것 (2026-09-21):** [[2026-04-08-scaling-managed-agents]]의 중심 주장 — *harness의 가정은 모델이 좋아지면 썩는다* — 는 **"모델은 계속 좋아진다"를 전제**하며, 그 전제의 최대 이해관계자가 저자 조직이다. 반례(context reset)가 구체적이라 주장 자체는 튼튼하지만, **"따라서 모델 능력에 기대는 방어는 버려라"** 는 규범적 결론까지 같은 무게로 받아들일지는 별개 판단이다. 이 논증 구조는 [[agentic-governance]]의 자격증명 절과 [[meta-harness]] 전체를 관통한다.

## Related

- [[multi-agent-systems]] — Anthropic이 이 위키에 기여한 주된 주제.
- [[orchestrator-worker]] — Anthropic Research 기능이 채택한 구조.
- [[agent-evaluation]] — Anthropic이 공개한 평가 실무.
- [[claude-code]] — Anthropic의 에이전틱 코딩 도구.
- [[ai-native-sdlc]] — Applied AI 팀이 낸 엔터프라이즈 SDLC 플레이북의 주제 페이지.
- [[artifact-chain]] — 여러 소스가 각자 도달한 "파일을 인터페이스로" 패턴.
- [[dynamic-workflows]] — 세 번째 소스가 소개하는, harness 제작을 모델에게 넘기는 접근.
- [[agentic-governance]] — Claude Code의 통제 표면을 조직 정책으로 쓰는 방식.
- [[subagent]] — 소스들이 같은 단어로 다른 것을 가리키는 지점.
- [[managed-agents]] — 플랫폼 제공자로서의 얼굴이 드러나는 제품.
- [[meta-harness]] — 네 번째 소스의 중심 개념.
- [[agent-containment]] — 다섯 번째 소스의 중심 개념. 세 제품의 격리 아키텍처.
- [[prompt-injection]] — 같은 소스가 보고한 공격면과 실패 사례.
- [[loop-engineering]] — 이 위키 최초의 비-Anthropic 소스가 들어온 개념. 편향 추적의 대조군.
- [[prompt-optimization]] — 최초의 학술·정량 독립 소스가 들어온 개념. 실험에 Claude가 없다.
- [[agent-memory]] — 두 번째 학술·정량 독립 소스(MemGPT)가 들어온 개념. GEPA와 같은 연구 그룹 계열이다.
- [[recursive-language-model]] — Claude Code(Opus 4.1)를 외부에서 잰 데이터가 들어온 개념. 측정자는 경쟁 scaffold의 저자다.
- [[agent-fundamentals]] — workflow vs agent 정의가 Anthropic 글에서 왔다. 처음으로 Google·Meta 원전이 함께 들어온 topic.
- [[ai-in-organizations]] — Anthropic Institute가 자사 고객을 연구한 소스로 세운 topic. 편향이 두 겹이다.

## Sources

- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering 블로그 (2025-06-13).
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Claude Blog, Claude Code 팀 기술 스태프 (2026-08-20).
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Claude Blog, Applied AI 팀 (2026-08-21).
- [[2026-04-08-scaling-managed-agents]] — Anthropic Engineering 블로그, Lance Martin·Gabe Cemaj·Michael Cohen (2026-04-08).
- [[2026-05-25-how-we-contain-claude]] — Anthropic Engineering 블로그, Max McGuinness·Mikaela Grace·Jiri De Jonghe·Jake Eaton·Abel Ribbink (2026-05-25). Jake Eaton은 앞 소스의 감사문에도 등장.
- [[2024-12-19-building-effective-agents]] — Anthropic Engineering 블로그, Erik S.·Barry Zhang (2024-12-19). 2026-11-27 받은 개정판. 편향 노트: 정의를 제공하지만 수치가 없고, 개정 주석이 자사 제품을 가리킨다 (2026-11-27)
- [[2026-11-23-working-with-ai]] — The Anthropic Institute, Nathan Wilmers·Maxim Massenkoff·Peter McCrory (2026-11-23). 편향 노트: 자사 고객 58곳 인터뷰, 자기 보고 가치, 엔지니어링이 아닌 첫 Anthropic 소스 (2026-11-27)

**비-Anthropic 소스 (대조군):**

- [[2026-06-07-loop-engineering]] — Addy Osmani, 개인 블로그 (2026-06-07). 이 위키 최초의 외부 소스. Codex와 Claude Code를 대칭으로 다룬다.
- [[2026-08-14-practical-loop-engineering]] — Addy Osmani, 개인 블로그 (2026-08-14). 앞 글의 실전편. **내용의 상당 부분이 Claude Code 팀 X article의 인용**이므로 순수 외부 소스로 세면 안 된다.
- [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu, Introspection (AI Engineer World's Fair 발표). **Anthropic을 발행처로도 인용 경로로도 거치지 않는 첫 소스.** 단 자사 제품 발표다.
- [[2025-07-25-gepa-reflective-prompt-evolution]] — Agrawal 외 16인 (ICLR 2026 Oral). 편향 노트: 최초의 학술·정량 독립 소스 (2026-11-25)
- [[2023-10-12-memgpt]] — Packer 외 6인 (UC Berkeley, arXiv preprint). 편향 노트: 두 번째 독립 측정 소스, GEPA와 Stoica 공저 (2026-11-26)
- [[2023-03-20-reflexion]] — Shinn 외 5인 (Northeastern·MIT·Princeton). 편향 노트: Berkeley 계열이 아닌 첫 학술 소스 (2026-11-26)
- [[2024-10-14-longmemeval]] — Wu 외 5인 (UCLA·Tencent AI Lab·UCSD, ICLR 2025). 편향 노트: OpenAI 제품을 실측한 학계·산업 공동 소스 (2026-11-26)
- [[2025-01-20-zep]] — Rasmussen 외 4인 (Zep AI). 편향 노트: 벤더 자사 제품 preprint (2026-11-26)
- [[2025-02-17-a-mem]] — Xu 외 5인 (Rutgers 등). 편향 노트: 외부 소스가 Claude(Haiku)를 잰 첫 데이터, 신뢰도 낮음 (2026-11-26)
- [[2025-12-31-recursive-language-models]] — Zhang, Kraska, Khattab (MIT CSAIL, arXiv preprint). 편향 노트: Claude Code(Opus 4.1)를 경쟁 scaffold 저자가 잰 외부 측정, GEPA와 Khattab 공저 (2026-11-26)
- [[2026-03-03-reproducing-recursive-language-models]] — Daren Wang (CUHK, arXiv preprint). 편향 노트: 원 저자 밖의 첫 독립 재현, 표본 작음 (2026-11-26)
- [[2022-10-06-react]] — Yao 외 6인 (Princeton·Google Brain, ICLR 2023). 편향 노트: 이 위키의 첫 Google 소스, Claude 이전 모델 (2026-11-27)
- [[2023-02-09-toolformer]] — Schick 외 7인 (Meta AI, arXiv preprint). 편향 노트: 이 위키의 첫 Meta 소스, Claude 이전 모델 (2026-11-27)
