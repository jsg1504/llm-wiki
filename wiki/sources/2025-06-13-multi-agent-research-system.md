---
title: How we built our multi-agent research system
type: source
created: 2026-09-11
updated: 2026-09-11
source_file: ../../raw/articles/2025-06-13-multi-agent-research-system.md
source_url: https://www.anthropic.com/engineering/multi-agent-research-system
author: Jeremy Hadfield, Barry Zhang, Kenneth Lien, Florian Scholz, Jeremy Fox, Daniel Ford
publisher: Anthropic Engineering
source_date: 2025-06-13
tags: [multi-agent, research, orchestrator-worker, prompt-engineering, evaluation, production, anthropic]
status: mature
---

# How we built our multi-agent research system

> Anthropic Research 기능을 프로토타입에서 프로덕션까지 끌고 간 기록. 핵심 주장은 하나다 — **멀티에이전트가 이기는 이유는 똑똑해서가 아니라 병렬 context window로 토큰을 더 쓸 수 있기 때문이며**, 그 대가(챗 대비 15x 토큰)를 감당할 가치가 있는 태스크는 제한적이다.

## Context

Anthropic 엔지니어링 블로그, 2025-06-13. Research 기능(웹·Google Workspace·integration을 가로질러 검색하는 기능)을 만든 apps 엔지니어링 팀이 직접 썼다.

장르는 회고형 엔지니어링 포스트다. "이렇게 하세요"가 아니라 "우리는 이렇게 했고 이런 것이 깨졌다"에 가깝다. 실패 사례가 구체적이라는 것이 이 문서의 가장 큰 가치다 — 간단한 쿼리에 subagent 50개를 띄운 초기 에이전트, 3개 중 2개가 똑같은 검색을 반복한 사례, SEO 콘텐츠팜을 학술 PDF보다 선호하던 편향 등.

[[claude-code]] 같은 개발 도구가 아니라 **소비자용 리서치 제품**을 다룬다는 점이 중요하다. 저자들이 코딩 도메인을 명시적으로 멀티에이전트 부적합 사례로 분류하기 때문에(Key Claim 3), 이 문서의 결론을 코딩 에이전트로 그대로 옮기면 안 된다.

## Key Claims

1. **Orchestrator-worker 아키텍처.** LeadResearcher가 접근법을 사고한 뒤 **계획을 Memory에 저장한다** — context window가 200,000 토큰을 넘으면 잘려나가기 때문에 계획만은 보존해야 한다. 그다음 전문화된 Subagent를 2개 이상 생성하고, 각 subagent는 독립 context window에서 검색하고 interleaved thinking으로 결과를 평가한 뒤 findings를 반환한다. Lead가 종합해 더 필요한지 판단하고(추가 subagent 생성 또는 전략 수정), 충분하면 루프를 빠져나와 **CitationAgent**에게 넘겨 모든 주장에 출처를 매핑시킨다. → [[orchestrator-worker]]

2. **static RAG가 아니라 dynamic multi-step search.** 전통적 RAG는 입력 쿼리와 유사한 chunk를 고정적으로 가져와 답을 만든다. 이 아키텍처는 "동적으로 관련 정보를 찾고, 새 발견에 적응하고, 결과를 분석해 답을 구성"한다. 문서가 자기 위치를 RAG 대비로 정의한다는 점이 중요하다.

3. **성능 분산의 80%를 토큰 사용량 단독으로 설명한다.** BrowseComp 평가 분석에서 세 요인이 성능 분산의 95%를 설명했는데, **token usage 하나가 80%**, 나머지는 tool call 수와 모델 선택. 즉 멀티에이전트가 작동하는 주된 이유는 "문제를 풀 만큼 충분한 토큰을 쓰게 해주기 때문"이다. 내부 research eval에서 **Claude Opus 4 lead + Claude Sonnet 4 subagents 조합이 단일 Opus 4 대비 90.2% 우위**. 단, 최신 모델은 토큰의 효율 배수로 작동한다 — Sonnet 3.7에서 Sonnet 4로 올리는 것이 **토큰 예산을 2배로 늘리는 것보다 큰 이득**이었다.

4. **비용과 적용 한계.** 에이전트는 챗 대비 약 4x, 멀티에이전트는 약 **15x 토큰**을 태운다. 따라서 태스크 가치가 그 비용을 정당화해야 경제성이 성립한다. 그리고 적합 조건을 명시한다 — 무거운 병렬화, 단일 context window를 넘는 정보량, 복잡한 도구가 다수인 경우. 반대로 **모든 에이전트가 같은 컨텍스트를 공유해야 하거나 에이전트 간 의존성이 많은 도메인은 부적합**이며, 원문은 코딩을 그 예로 든다: *"most coding tasks involve fewer truly parallelizable tasks than research, and LLM agents are not yet great at coordinating and delegating to other agents in real time."*

5. **조정 복잡도가 폭증하므로 프롬프트가 주 레버가 된다.** 8개 원칙 중 무게가 실린 것들:
   - **위임을 가르쳐라.** 각 subagent에게 objective·output format·도구와 소스 지침·명확한 task 경계를 줘야 한다. "반도체 부족 사태를 조사해"처럼 짧으면 subagent가 오해하거나 중복 수행한다(실제로 1개는 2021 자동차 칩 위기를, 2개는 똑같이 2025 공급망을 조사).
   - **노력을 쿼리 복잡도에 맞춰 스케일하라.** 에이전트는 적정 노력을 스스로 판단하지 못하므로 규칙을 프롬프트에 박아넣는다 — 단순 사실확인은 1 에이전트 3-10 tool call, 직접 비교는 2-4 subagent × 10-15 call, 복잡한 연구는 10+ subagent.
   - **넓게 시작해 좁혀라.** 에이전트는 기본적으로 지나치게 길고 구체적인 쿼리를 던져 결과를 거의 못 얻는다.
   - **병렬 tool call.** lead가 subagent 3-5개를 동시에 띄우고, subagent가 도구 3개 이상을 동시에 호출 → 복잡 쿼리의 연구 시간 **최대 90% 단축**.
   - **에이전트가 스스로 개선하게 하라.** 결함 있는 MCP 도구를 주고 수십 번 써보게 한 뒤 도구 설명을 다시 쓰게 했더니, 이후 에이전트의 **task 완료 시간이 40% 감소**했다.
   - **도구 설계는 human-computer interface만큼 중요하다.** *"an agent searching the web for context that only exists in Slack is doomed from the start."*

6. **평가는 경로가 아니라 결과를 본다.** 같은 출발점에서도 에이전트는 서로 다른 유효한 경로를 밟으므로 "정해진 스텝을 따랐는가"를 검사할 수 없다. 대응 세 가지 — 실사용 패턴 **20개 쿼리로 즉시 시작**(초기엔 프롬프트 한 줄이 30%→80%를 만들 만큼 효과가 커서 소표본으로 충분하다), **LLM-as-judge는 단일 호출·단일 루브릭**(factual accuracy / citation accuracy / completeness / source quality / tool efficiency를 0.0~1.0 점수 + pass-fail로)이 판정자를 여럿 두는 것보다 일관적이고 사람 판단과 잘 맞았다, 그리고 **사람 테스트는 자동화가 못 잡는 것을 잡는다**(SEO 콘텐츠팜 편향이 여기서 발견됐다). 상태를 변경하는 에이전트는 턴별이 아니라 **end-state evaluation**으로 평가한다. → [[agent-evaluation]]

7. **프로덕션의 본질적 어려움은 "상태"다.** 에이전트는 장시간 상태를 유지하며 돌기 때문에 사소한 실패가 복합되어 치명적이 된다. 처음부터 재시작은 비싸고 사용자에게 괴로우므로 **중단 지점에서 resume**하고, retry 로직과 정기 checkpoint 같은 결정론적 안전장치를 AI의 적응력과 결합한다(도구가 실패 중이라고 에이전트에게 알려주면 놀랍도록 잘 적응한다). 비결정성 때문에 디버깅이 어려우므로 **full production tracing**을 붙이되 개인정보 보호를 위해 대화 내용은 보지 않고 **에이전트의 결정 패턴과 상호작용 구조만** 모니터링한다. 배포 시에는 진행 중인 에이전트를 깨뜨리지 않기 위해 **rainbow deployment**로 트래픽을 점진 이전한다.

8. **현재 남은 구조적 병목: 동기 실행.** lead는 subagent 묶음이 끝날 때까지 기다린다. 조정은 단순해지지만 lead가 subagent를 도중에 조종할 수 없고, subagent끼리 협력할 수 없고, 느린 하나가 전체를 막는다. 비동기로 가면 병렬성은 늘지만 결과 조정·상태 일관성·에러 전파가 어려워진다 — 저자들은 모델이 좋아지면 그 복잡도를 감수할 가치가 생길 것으로 본다.

9. **부록의 두 패턴.** (a) **장기 대화 관리** — 완료된 작업 단계를 요약해 외부 메모리에 저장하고, context 한계에 다가가면 깨끗한 context의 새 subagent를 띄워 핸드오프한다. 연구 계획 같은 것은 잃어버리는 대신 메모리에서 되읽는다. (b) **subagent 출력을 파일시스템으로** — 모든 것을 lead를 통해 전달하면 정보가 손실되고("game of telephone") 큰 출력이 대화 히스토리에 복사되며 토큰을 낭비한다. subagent가 결과를 외부에 저장하고 lead에게는 가벼운 **참조만** 넘긴다. 코드·리포트·데이터 시각화처럼 구조화된 산출물에 특히 잘 맞는다.

## Notable Quotes / Passages

> "The essence of search is compression: distilling insights from a vast corpus."

> "Multi-agent systems work mainly because they help spend enough tokens to solve the problem."

> "Even with identical starting points, agents might take completely different valid paths to reach their goal."

> "In agentic systems, minor changes cascade into large behavioral changes."

> "When building AI agents, the last mile often becomes most of the journey."

> "The best prompts for these agents are not just strict instructions, but frameworks for collaboration that define the division of labor, problem-solving approaches, and effort budgets."

## 인용된 수치 한눈에

| 수치 | 맥락 |
|---|---|
| **90.2%** | 내부 research eval에서 (Opus 4 lead + Sonnet 4 subagents) vs 단일 Opus 4 우위폭 |
| **80% / 95%** | BrowseComp 성능 분산 중 token usage 단독 설명력 / (token + tool call 수 + 모델) 합산 설명력 |
| **4x / 15x** | 챗 대비 단일 에이전트 / 멀티에이전트 토큰 소비 |
| **200,000** | 이 초과 시 context 잘림 → 계획을 Memory에 저장하는 이유 |
| **최대 90%** | 병렬화(lead가 subagent 3-5개 동시 + subagent가 도구 3+개 동시)로 줄인 연구 시간 |
| **40%** | 에이전트가 도구 설명을 다시 쓴 뒤 후속 에이전트의 task 완료 시간 감소폭 |
| **~20개** | eval을 시작하기에 충분했던 쿼리 수 |
| **1 / 2-4 / 10+** | 단순 사실확인 / 직접 비교 / 복잡 연구에 배정하는 에이전트 수 |

## Connections

- [[orchestrator-worker]] 개념의 1차 출처 (Key Claim 1·2·8).
- [[agent-evaluation]] 개념의 1차 출처 (Key Claim 6).
- [[multi-agent-systems]] 토픽에 속하며, 이 토픽의 경제성 논의(Key Claim 3·4)의 근거다.
- 발행처는 [[anthropic]].
- [[2026-08-21-the-ai-native-sdlc-playbook]] / [[ai-native-sdlc]]와 **코딩 도메인에서의 멀티에이전트 적합성**을 두고 긴장 관계에 있다. 상세는 [[multi-agent-systems]]의 Contradiction 절 참조.

## My Notes

- **가장 중요한 한 문장은 Key Claim 3이다.** "멀티에이전트가 더 똑똑하다"가 아니라 "멀티에이전트는 토큰을 더 쓰는 장치이고 토큰이 성능의 80%를 설명한다"는 것. 이 프레이밍을 받아들이면 설계 질문이 바뀐다 — "에이전트를 몇 개 둘까"가 아니라 "이 태스크에 토큰을 얼마나 쓸 가치가 있고, 그 토큰을 병렬 context에 나눠 담는 것이 이득인가"가 된다.
- **자기 제품 홍보 글이지만 반증 가능한 수치를 낸다.** 15x 토큰 비용과 코딩 부적합을 스스로 명시한 것은 신뢰도를 높이는 대목. 다만 90.2%는 **내부 eval**이고 루브릭이 공개되지 않았다 — 외부 재현 불가.
- **코딩 부적합 주장은 작성 시점(2025-06)에 묶어 읽어야 한다.** 원문 자체가 *"not yet great at coordinating"*, *"not a good fit ... today"*로 시점을 한정했다. 14개월 뒤 문서인 [[2026-08-21-the-ai-native-sdlc-playbook]]은 반대 방향을 권한다.
- **부록이 본문보다 실전적일 수 있다.** subagent 출력을 파일시스템에 쓰고 참조만 넘기는 패턴은 이 위키 자체에도 적용 가능한 발상이다(에이전트가 페이지를 직접 쓰고 오케스트레이터는 경로만 받는 구조).
- 원문은 프롬프트를 Anthropic Cookbook에 공개했다고 언급하나 이 raw 파일에는 링크가 없다. 후속 조사 대상.

## Raw Source

[원본 파일](../../raw/articles/2025-06-13-multi-agent-research-system.md) · [anthropic.com/engineering/multi-agent-research-system](https://www.anthropic.com/engineering/multi-agent-research-system)
