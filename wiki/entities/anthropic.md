---
title: Anthropic
type: entity
created: 2026-09-11
updated: 2026-09-21
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude, 2026-06-07-loop-engineering, 2026-08-14-practical-loop-engineering]
tags: [organization, ai-lab, claude, anthropic]
status: draft
---

# Anthropic

> Claude 모델군을 만드는 AI 연구·제품 조직. 이 위키의 소스 **7개 중 5개**가 Anthropic 발행이고, 나머지 둘도 벤더 원문을 실어 나르므로, **이 위키의 관점 편향을 추적하는 지점**이기도 하다.

## Overview

이 페이지는 Anthropic이라는 조직 전반을 다루지 않는다. **이 위키의 소스들이 드러내는 만큼만** 기록한다. 현재까지는 다섯 편의 실무 문서를 통해 네 가지 얼굴이 나타난다:

- **엔지니어링 조직으로서** — 자사 프로덕션 시스템(Research 기능)을 만들며 깨진 것들을 공개한다 ([[2025-06-13-multi-agent-research-system]]).
- **엔터프라이즈 조력자로서** — Applied AI 팀이 고객사와 일하며 얻은 패턴을 플레이북으로 낸다 ([[2026-08-21-the-ai-native-sdlc-playbook]]).
- **플랫폼 제공자로서** — 남의 에이전트 워크로드를 호스팅하며 겪은 아키텍처 전환을 공개한다 ([[2026-04-08-scaling-managed-agents]]). 앞의 둘과 성격이 다르다. 여기서는 Anthropic이 *에이전트를 만드는 쪽*이 아니라 **에이전트가 돌아갈 바닥을 까는 쪽**이다.
- **보안 사고 보고자로서** — 세 제품을 2년간 운영하며 **깨진 것들을 이름과 수치와 함께** 공개한다 ([[2026-05-25-how-we-contain-claude]]). 책임공개로 받은 취약점 3건, 자사 직원이 피싱당한 red-team, 서드파티가 찾아낸 유출 경로, 엔터프라이즈 도입 장애물. Anthropic 발행 다섯 소스 중 **홍보 인센티브와 가장 반대 방향으로 쓰인 글**이다.

## Key Points

### 언급되는 제품·모델

| 이름 | 이 위키에서의 등장 |
|---|---|
| **Claude Opus 4 / Sonnet 4** | 멀티에이전트 조합(Opus lead + Sonnet subagents)에서 단일 Opus 4 대비 90.2% 우위. Sonnet 3.7→4 업그레이드가 토큰 예산 2배보다 이득이 컸다. |
| **Research 기능** | 웹·Google Workspace·integration을 가로질러 검색하는 소비자 기능. [[orchestrator-worker]] 구조의 실제 구현체. |
| **[[claude-code]]** | [[2026-08-21-the-ai-native-sdlc-playbook]]의 축이 되는 에이전틱 코딩 도구. |
| **MCP** | 외부 도구 접근 프로토콜. 도구 설명 품질 편차가 에이전트를 잘못된 경로로 보낸다는 문제 제기의 맥락에서 등장. [[managed-agents]]에서는 자격증명을 vault 뒤에 두는 프록시 경로로도 쓰인다. |
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

## Sources

- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering 블로그 (2025-06-13).
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Claude Blog, Claude Code 팀 기술 스태프 (2026-08-20).
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Claude Blog, Applied AI 팀 (2026-08-21).
- [[2026-04-08-scaling-managed-agents]] — Anthropic Engineering 블로그, Lance Martin·Gabe Cemaj·Michael Cohen (2026-04-08).
- [[2026-05-25-how-we-contain-claude]] — Anthropic Engineering 블로그, Max McGuinness·Mikaela Grace·Jiri De Jonghe·Jake Eaton·Abel Ribbink (2026-05-25). Jake Eaton은 앞 소스의 감사문에도 등장.

**비-Anthropic 소스 (대조군):**

- [[2026-06-07-loop-engineering]] — Addy Osmani, 개인 블로그 (2026-06-07). 이 위키 최초의 외부 소스. Codex와 Claude Code를 대칭으로 다룬다.
- [[2026-08-14-practical-loop-engineering]] — Addy Osmani, 개인 블로그 (2026-08-14). 앞 글의 실전편. **내용의 상당 부분이 Claude Code 팀 X article의 인용**이므로 순수 외부 소스로 세면 안 된다.
