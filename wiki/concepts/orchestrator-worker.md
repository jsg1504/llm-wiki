---
title: Orchestrator-Worker 패턴
type: concept
created: 2026-09-11
updated: 2026-11-27
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude, 2025-12-31-recursive-language-models, 2024-12-19-building-effective-agents]
tags: [multi-agent, architecture, orchestration, context-window, agent-design]
status: draft
---

# Orchestrator-Worker 패턴

> 하나의 lead agent가 태스크를 분해·위임·종합하고, 복수의 subagent가 **각자의 독립 context window에서** 병렬로 일한다. 핵심 효용은 지능이 아니라 **압축**이다 — subagent가 넓게 탐색한 뒤 중요한 토큰만 추려 lead에게 올린다.

## Overview

멀티에이전트 시스템의 가장 단순하고 실전적인 형태. Anthropic Research 기능이 채택한 구조이며, 구성은 다음과 같다 ([[2025-06-13-multi-agent-research-system]]):

```
User query
    │
    ▼
┌─────────────────┐
│ LeadResearcher  │──▶ plan을 Memory에 저장 (200k 토큰 초과 시 truncation 대비)
└────────┬────────┘
         │ spawn (병렬, 보통 3-5개)
    ┌────┴────┬─────────┐
    ▼         ▼         ▼
 Subagent  Subagent  Subagent     각자 독립 context window
 (검색 →   (검색 →   (검색 →       interleaved thinking으로 결과 평가
 평가 →    평가 →    평가 →
 findings) findings) findings)
    └────┬────┴─────────┘
         ▼
┌─────────────────┐
│ LeadResearcher  │──▶ 종합 → 충분한가? ──아니오──▶ subagent 추가 / 전략 수정
└────────┬────────┘
         │ 예
         ▼
┌─────────────────┐
│  CitationAgent  │──▶ 모든 주장에 출처 매핑
└────────┬────────┘
         ▼
    최종 답변 + 인용
```

### 첫 정의 — workflow로 분류됐다 (2026-11-27)

Anthropic이 이 구조를 처음 이름 붙인 곳은 [[2024-12-19-building-effective-agents]]다. Research 시스템 글보다 반년 앞선다. 정의는 이렇다. *"중앙 LLM이 과제를 동적으로 쪼개 worker LLM에 위임하고 결과를 종합한다."* 맞는 경우는 **필요한 하위 과제를 미리 알 수 없을 때**다. 예시는 매번 여러 파일을 고치는 코딩 제품과 여러 출처를 모으는 검색 과제다. parallelization과 모양은 같지만 하위 과제가 미리 정해지지 않는다는 점이 다르다.

그 글은 이 구조를 **workflow**(미리 정한 코드 경로)로 분류한다. 그런데 하위 과제를 orchestrator가 정한다는 설명은 같은 글의 **agent** 정의(LLM이 자기 과정을 동적으로 지휘)에 더 가깝다. 이 페이지는 2025년 소스를 따라 이 구조를 multi-agent로 다룬다. 이 긴장은 workflow/agent를 이분법이 아니라 연속선으로 읽어야 하는 근거 중 하나다. → [[agent-fundamentals]] §1 *(분류에 대한 판단은 이 위키의 것이다.)*

## Key Points

### 왜 작동하는가 — 압축과 관심사 분리

- **압축.** 검색의 본질은 방대한 코퍼스에서 통찰을 증류하는 것이다. subagent가 각자의 context window에서 다른 측면을 동시에 탐색하고, 가장 중요한 토큰만 응축해 lead에게 올린다.
- **관심사 분리.** subagent마다 도구·프롬프트·탐색 궤적이 다르므로 **path dependency가 줄고** 독립적이고 철저한 조사가 가능해진다.
- **토큰 용량 확장.** 진짜 이유는 이것이다 — 분리된 context window로 작업을 분산하면 병렬 추론에 쓸 수 있는 토큰 총량이 늘어난다. 자세한 근거는 [[multi-agent-systems]] 참조.

### 위임에는 사양서가 필요하다

lead가 subagent에게 주는 태스크 기술이 부실하면 **중복 수행·누락·오해**가 곧바로 발생한다. 최소 네 가지를 줘야 한다:

| 슬롯 | 내용 |
|---|---|
| **objective** | 무엇을 알아내야 하는가 |
| **output format** | 어떤 형태로 돌려줘야 하는가 |
| **tools / sources** | 어떤 도구와 출처를 쓸 것인가 |
| **task boundaries** | 어디까지가 내 몫이고 어디부터가 남의 몫인가 |

실패 사례: "반도체 부족 사태를 조사해"라는 짧은 지시에 subagent 3개 중 1개는 2021 자동차 칩 위기를, 나머지 2개는 똑같이 2025 공급망을 조사했다. 분업이 성립하지 않은 것이다.

### 노력을 쿼리 복잡도에 맞춰 스케일한다

에이전트는 "이 일에 얼마나 힘을 써야 하는가"를 스스로 판단하지 못한다. 초기 시스템은 단순한 쿼리에 subagent 50개를 띄웠다. 해법은 규칙을 프롬프트에 직접 박는 것:

| 쿼리 유형 | 에이전트 수 | tool call |
|---|---|---|
| 단순 사실확인 | 1 | 3–10 |
| 직접 비교 | 2–4 | 각 10–15 |
| 복잡한 연구 | 10+ (책임 명확히 분할) | — |

### 병렬성은 두 층위에서 나온다

1. lead가 subagent를 **순차가 아니라 3-5개 동시에** 띄운다.
2. 각 subagent가 **도구를 3개 이상 동시에** 호출한다.

이 두 가지로 복잡한 연구의 소요 시간이 최대 90% 줄었다.

> 병렬성의 천장을 무엇이 정하는가는 도메인에 따라 다르다. 리서치에서는 위와 같이 **프롬프트에 박은 노력 규칙**이 정하지만, 코딩 SDLC에서는 *"한 사람이 제대로 리뷰할 수 있는 스트림 수"*, 즉 **사람의 리뷰 능력**이 천장이 된다 ([[ai-native-sdlc]]). 둘 다 "에이전트는 적정 노력을 스스로 못 정한다"는 같은 전제에서 출발해 한쪽은 프롬프트 규칙으로, 다른 쪽은 사람 게이트로 푼다.

### 알려진 한계

- **동기 실행 병목.** lead는 subagent 묶음이 끝날 때까지 기다린다. 조정은 단순해지지만 ⓐ lead가 진행 중인 subagent를 조종할 수 없고 ⓑ subagent끼리 협력할 수 없고 ⓒ느린 하나가 전체를 막는다. 비동기화하면 병렬성은 늘지만 결과 조정·상태 일관성·에러 전파가 어려워진다. ⓑ에는 부분 예외가 있다. Managed Agents에서는 brain끼리 실행 환경(hand)을 넘겨줄 수 있다. 넘어가는 것은 결과가 아니라 자원이다 ([[2026-04-08-scaling-managed-agents]], [[subagent]] 알려진 한계).
- **game of telephone.** 모든 결과가 lead를 통과하면 정보가 손실되고 큰 출력이 대화 히스토리에 복사되며 토큰을 낭비한다. 완화책은 **subagent가 산출물을 외부(파일시스템 등)에 저장하고 lead에게는 참조만 넘기는 것** — 코드·리포트·데이터 시각화처럼 구조화된 출력에 특히 잘 맞는다. 이 처방은 [[artifact-chain]]이 *세션 사이의* 기억에 대해 내리는 것과 같다: 대화가 아니라 파일이 인터페이스가 되게 하라.
- **창발적 행동.** lead 프롬프트의 작은 변경이 subagent 행동을 예측 불가능하게 바꾼다. 개별 에이전트 행동이 아니라 **상호작용 패턴**을 이해해야 한다.
- **컨텍스트 공유가 필요한 도메인엔 부적합.** 에이전트 간 의존성이 크면 이 패턴의 전제(독립 탐색)가 무너진다.
- **압축은 세탁이 될 수 있다 (2026-11-26).** 이 패턴의 효용인 "subagent가 추려서 올린다"에는 이면이 있다. subagent 출력이 *"우리 것"* 이라는 이유로 raw tool result보다 높은 신뢰를 받으면, subagent가 읽은 웹 페이지의 주입된 지시가 구조화된 findings로 포장되어 lead에 닿는다(multi-agent trust escalation, [[2026-05-25-how-we-contain-claude]]). 리서치형 subagent는 정의상 미신뢰 콘텐츠를 읽는다. 완화 방향은 subagent 출력을 raw tool result와 같은 등급으로 검사하는 것이다. → [[prompt-injection]]

### 조정을 누가 들고 있는가 — LLM 주도 조정의 대안

이 패턴에서 **조정 상태는 lead agent의 context window에 산다.** 계획, 누가 무엇을 맡았는지, 무엇이 돌아왔는지가 전부 LLM의 컨텍스트에 있다. 위의 "상태를 다루는 법"이 Memory·요약·핸드오프를 동원하는 이유가 이것이다 — 조정 상태가 컨텍스트 한계와 compaction의 lossy함에 노출되어 있다.

[[dynamic-workflows]]는 같은 fan-out 구조를 쓰되 **조정 상태를 프로그램 변수로 옮긴다** ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]). 이 패턴의 일반화된 형태가 [[agent-orchestration-patterns]]의 **fan-out-and-synthesize**이고, 차이는 barrier를 누가 들고 있는가다 — 여기서는 lead의 컨텍스트, 저기서는 코드.

| | 이 패턴 | dynamic workflow |
|---|---|---|
| 조정 주체 | lead agent (LLM) | 결정론적 프로그램 |
| 조정 상태의 거처 | lead의 context window (+ Memory) | 프로그램 변수 |
| 실행 중 전략 변경 | **가능** — 종합 후 *"충분한가?"*를 판단해 subagent를 더 띄운다 | **제한적** — 정지 조건을 미리 표현할 수 있어야 한다 (loop-until-done 패턴) |
| 취약점 | 컨텍스트 포화, goal drift, self-preferential bias | 잘못 설계된 harness가 잘못을 병렬로 확대 |

**트레이드오프이지 개선이 아니다.** LLM 주도 조정은 유연하고 프로그램 주도 조정은 견고하다. 위의 "알려진 한계" 중 **동기 실행 병목**은 양쪽에 공통이다 — fan-out의 종합 단계도 barrier여서 가장 느린 하나가 전체를 막는다.

### 위임을 말로 낸다 — 표현력의 상한 (2026-11-26)

이 패턴에서 lead는 subagent를 **하나씩 말로** 띄운다. 태스크 기술을 생성하는 것이 곧 위임이다. [[2025-12-31-recursive-language-models]]는 Claude Code subagent를 포함한 이 방식을 이렇게 비판한다. 하위 호출을 *"verbalize … autoregressively"* 하므로 **위임 수가 lead의 출력 길이에 묶인다.** 위의 노력 규칙이 "복잡한 연구에 10+"인 것도 같은 규모다.

반대편은 위임을 **코드 안에서** 내는 [[recursive-language-model]]이다. 입력 조각마다 루프를 돌며 LM을 부르므로 수백 번도 가능하다(Qwen3-Coder는 OOLONG 정답 궤적에서 평균 약 500회). 쌍마다 집계하는 과제(OOLONG-Pairs)에서 입력을 파일로 넘긴 Claude Code는 F1 6.5, RLM은 58~76이었다. 단 Claude Code 행은 모델이 Opus 4.1로 달랐다.

**이 패턴이 틀렸다는 뜻은 아니다.** 하위 단위가 다르다. 여기 subagent는 도구를 쓰며 넓게 탐색하는 무거운 에이전트이고, RLM의 하위 호출은 문자열을 받아 문자열을 내는 LM 호출이다. 하위 작업이 크고 이질적이면 이 패턴이, 같은 변환을 입력 전체에 반복해야 하면 코드 위임이 맞는다. 구분표는 [[subagent]] "말로 하는 위임 vs 코드로 하는 위임". *(적용 범위의 구분은 이 위키의 정리다.)*

### 상태를 다루는 법

lead는 접근법을 사고한 직후 **계획을 Memory에 저장한다.** context window가 200,000 토큰을 넘으면 잘려나가므로, 잘린 뒤에도 계획만은 되읽을 수 있어야 하기 때문이다. 같은 발상의 확장이 **긴 대화 관리 패턴**이다 — 완료된 단계를 요약해 외부 메모리에 넣고, context 한계에 다가가면 깨끗한 context의 새 subagent로 핸드오프한다.

이 처방들은 [[context-and-memory]]의 compaction 지도에서 (a) 요약과 (b) 격리에 해당한다. 원본을 되돌릴 수 있게 남기는 (c)는 이 소스에 없다. [[meta-harness]]의 세션 로그가 그 자리다. 조정 상태를 lead의 창에 두는 한, lead가 죽으면 상태도 같이 사라진다. 세션 로그는 그 상태를 durable한 거처로 옮겨 `wake(sessionId)`로 이어 가게 한다 ([[2026-04-08-scaling-managed-agents]]). 다만 그 소스는 단일 brain의 복구를 설명할 뿐, lead와 여러 subagent의 조정 상태를 어떻게 기록하는지는 말하지 않는다. *(대응은 이 위키의 해석이다.)*

## 코딩 도구에서의 구현

이 패턴은 리서치 시스템에만 있는 것이 아니다. [[claude-code]]는 같은 구조를 두 갈래로 제공한다 ([[2026-08-21-the-ai-native-sdlc-playbook]]):

- **세션 내부 subagent** — `.claude/agents/<name>.md`에 **사전 정의**되고 git에 체크인된다. lead가 런타임에 태스크를 기술해 생성하는 리서치형과 달리 역할이 파일로 고정되어 팀이 공유한다. 대표 역할은 **verifier**(신선한 컨텍스트로 최종 확인), **researcher**(메인 컨텍스트를 채우지 않고 코드베이스를 탐색해 보고), **code simplifier**.
- **병렬 세션(worktree)** — 이것은 이 패턴이 **아니다.** 각 세션이 완전한 독립 인스턴스이고 서로를 모르며 조정 주체가 사람이다.

두 갈래의 구분과 용어 정렬은 [[subagent]]에 모아두었다.

## Related

- [[multi-agent-systems]] — 이 패턴이 속한 상위 주제. 언제 쓸 가치가 있는지(경제성)를 다룬다.
- [[agent-evaluation]] — 이 구조는 실행 경로가 매번 달라지므로 전통적 스텝 검증이 불가능하다. 그래서 평가 방식이 함께 바뀐다.
- [[subagent]] — 이 패턴의 worker 단위. 리서치형과 코딩형의 용어 정렬.
- [[claude-code]] — 이 패턴의 코딩 도구 구현(subagent 정의 파일, verifier/researcher).
- [[artifact-chain]] — "파일을 인터페이스로" 처방의 세션 간 판본.
- [[dynamic-workflows]] — 같은 구조를 조정 주체만 바꿔 구현한 대안.
- [[agent-orchestration-patterns]] — 이 패턴이 한 항목으로 들어가는 상위 카탈로그.
- [[anthropic]] — 이 패턴을 프로덕션에서 운영하며 기록을 공개한 주체.
- [[meta-harness]] — lead의 조정 상태를 durable한 세션 로그로 옮기는 처방. brain끼리 hand를 넘기는 구조
- [[prompt-injection]] — subagent 출력의 trust escalation. 압축이 세탁이 되는 경로
- [[recursive-language-model]] — 위임을 말이 아니라 코드로 내는 반대편. 이 패턴의 표현력 비판
- [[context-and-memory]] — lead의 Memory 저장과 핸드오프가 속한 compaction 지도
- [[agent-memory]] — 계획을 Memory에 저장하는 발상의 장기 판본
- [[agent-fundamentals]] — workflow vs agent 구분. 이 구조가 그 경계에 선다

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — 조정 주체를 프로그램으로 옮긴 대안 구조. "조정을 누가 들고 있는가" 절.
- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering (2025-06-13). 이 페이지 전체의 출처.
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). 세션 로그와 brain 간 hand 전달 (2026-11-26)
- [[2026-05-25-how-we-contain-claude]] — Max McGuinness 외 4인 (Anthropic Engineering, 2026-05-25). multi-agent trust escalation (2026-11-26)
- [[2025-12-31-recursive-language-models]] — Zhang, Kraska, Khattab (MIT CSAIL, arXiv 2512.24601). 말로 하는 위임 비판, Claude Code 외부 측정 (2026-11-26)
- [[2024-12-19-building-effective-agents]] — Erik S., Barry Zhang (Anthropic Engineering, 2024-12-19). Anthropic의 첫 정의와 workflow 분류 (2026-11-27)
