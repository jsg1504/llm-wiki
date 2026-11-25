---
title: Context와 Memory
type: topic
created: 2026-11-26
updated: 2026-11-26
sources: [2023-10-12-memgpt, 2023-03-20-reflexion, 2024-10-14-longmemeval, 2025-01-20-zep, 2025-02-17-a-mem, 2025-12-31-recursive-language-models, 2026-03-03-reproducing-recursive-language-models, 2026-04-08-scaling-managed-agents, 2025-06-13-multi-agent-research-system, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-06-07-loop-engineering, 2025-07-25-gepa-reflective-prompt-evolution, 2026-05-25-how-we-contain-claude]
aliases: [context management, context engineering, long-context, 장기 기억, compaction]
tags: [context-window, agent-memory, compaction, long-context, context-rot, context-engineering, recursive-language-model]
status: draft
---

# Context와 Memory

> 모델은 창 안의 것만 보고, 실행이 끝나면 전부 잊는다. 이 주제의 중심 질문은 **context window 밖에 무엇을 두고, 누가, 어떻게 다시 가져오는가**다. 소스들이 모이는 답은 둘이다. **원문은 버리지 말고 창 밖에 둔다.** 그리고 **무엇을 다시 가져올지 정하는 주체(모델·harness·코드)는 모두 능력 가정을 안고 있다.** 주체끼리 같은 조건에서 비교한 데이터는 아직 없다.

## Overview

이 위키는 이 주제를 네 축으로 다룬다.

1. **무엇을 남기나** — 원문, 요약, 추출한 사실, 교훈 → [[agent-memory]] §1·§2
2. **언제 창을 넘나** — 한 실행 안(긴 입력, 긴 궤적)과 실행 사이(세션, 루프) → 아래 "두 시간 척도"
3. **누가 가져오나** — 모델, harness, 고정 검색, 모델이 쓴 코드 → 아래 표
4. **얼마나 믿나** — 측정, 재현, 그리고 쓰기 경로의 위험 → 아래 "측정과 재현", "위험"

### 두 시간 척도

| | 한 실행 안 | 실행 사이 |
|---|---|---|
| 문제 | 입력이나 궤적이 창을 넘고, 창 안에서도 열화한다 | 다음 실행은 이전 실행을 모른다 |
| 처방 | compaction, subagent 격리, 세션 로그, REPL 변수 | memory 저장소, 외부 state, 커밋된 아티팩트, recipe |
| 주 페이지 | [[meta-harness]] compaction 절, [[recursive-language-model]] | [[agent-memory]], [[loop-engineering]], [[artifact-chain]], [[agent-recipe]] |

두 척도는 같은 구조를 공유한다. MemGPT는 대화 하나 안의 eviction과 세션을 넘는 recall storage를 같은 계층으로 다룬다 ([[2023-10-12-memgpt]]). Managed Agents의 세션 로그도 한 실행 안에서는 창 밖 context 객체로, harness가 죽은 뒤에는 `wake(sessionId)`로 이어 가는 근거로 함께 쓰인다 ([[2026-04-08-scaling-managed-agents]]). *(두 척도로 나눈 것은 이 위키의 정리다.)*

## Key Points

### 열화는 과제에 따라 다르게 온다

창에 들어간다고 다 읽히는 것이 아니다.

- **과제 처리량이 열화 속도를 정한다.** 바늘 하나 찾기(O(1))는 1M token에서도 버틴다. 줄마다 분류해 모으는 과제(선형)는 더 짧은 길이에서 무너진다. 쌍마다 모으는 과제(제곱)에서 GPT-5는 창 안에서도 F1 0.1이었다 ([[2025-12-31-recursive-language-models]]). 그래서 "유효 context window"는 과제와 떼어 말할 수 없다.
- **요약은 정보를 바꾼다.** ChatGPT memory는 원문 전체를 읽힌 같은 모델보다 37% 낮았다. 처음엔 증거를 바로 기록했지만, 이력을 압축하면서 그 정보를 바꿔 버렸다 ([[2024-10-14-longmemeval]]).
- **긴 단일 실행의 실패 모드.** goal drift는 특히 compaction 뒤에 온다. 요약이 *"don't do X"* 같은 제약을 잃는다 ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]). → [[multi-agent-systems]] "단일 에이전트가 길어질 때"

### 처방 지도 — compaction의 네 갈래

| 처방 | 한 줄 | 대표 | 상세 |
|---|---|---|---|
| (a) 잘 요약한다 | 창에 들어갈 것을 압축 | compaction, memory tool | [[meta-harness]] |
| (b) 도달하지 않는다 | 목표를 짧게 나눠 각자의 창에서 | subagent 격리, dynamic workflow | [[subagent]], [[dynamic-workflows]] |
| (c) 되돌릴 수 있게 한다 | 밀어내되 원본은 로그에 | Managed Agents 세션 로그, MemGPT recall storage | [[meta-harness]], [[agent-memory]] |
| (d) 애초에 넣지 않는다 | 입력을 REPL 변수로, 코드로 잘라 읽기 | RLM | [[recursive-language-model]] |

넷은 함께 쓰인다. (c)는 (a)의 되돌릴 수 없음을 지운다. MemGPT는 2023년에 이미 (a)와 (c)를 같이 썼다 ([[2023-10-12-memgpt]]). 표는 [[meta-harness]]의 compaction 절을 줄인 것이다.

### 누가 가져오나 — 네 주체 *(정리)*

창 밖에 둔 것을 **언제, 무엇을** 다시 창에 넣을지 누가 정하는가. 소스마다 답이 다르고, 서로를 비교하지 않는다.

| 주체 | 대표 | 결정하는 방식 | 근거 | 묶이는 것 |
|---|---|---|---|---|
| **모델** (도구 호출) | MemGPT | 미리 정한 paging 함수를 모델이 호출 | 모델이 현재 목표를 가장 잘 안다 | 모델의 function calling 능력. GPT-3.5에서 크게 떨어졌다 |
| **harness** | Managed Agents | harness가 세션 로그를 슬라이스해 변형 후 주입. 인터페이스는 "durable하고 interrogable하다"만 보장 | 미래 모델에 어떤 context engineering이 필요할지 예측할 수 없다 | harness 설계자의 판단. 모델이 바뀔 때마다 다시 짠다 |
| **고정 검색 + LLM 추출** | Zep, A-MEM | 검색 절차는 코드(Cypher 질의, 임베딩 top-k)로 고정. 무엇을 추출·연결·갱신할지는 LLM | 검색은 예측 가능하게, 구조화는 유연하게 | 추출 LLM의 능력. Zep의 갱신 이득은 gpt-4o에서만 나왔다 |
| **모델이 쓴 코드** | RLM | 모델이 범용 Python으로 입력을 잘라 읽고, 루프에서 자기를 재귀 호출 | 무엇을 읽을지를 함수 목록이 아니라 프로그램이 정한다 | 모델의 코딩 능력과 sub-call 비용. 재현에서 강한 모델은 오히려 손해 ⚠️ |

출처: [[2023-10-12-memgpt]], [[2026-04-08-scaling-managed-agents]], [[2025-01-20-zep]], [[2025-02-17-a-mem]], [[2025-12-31-recursive-language-models]], [[2026-03-03-reproducing-recursive-language-models]]. 처음 두 행의 대비는 [[agent-memory]] §5에 있고, 나머지 두 행을 더해 한 표로 묶은 것은 이 페이지다. Managed Agents를 harness 행에 둔 근거는 *가져온 context의 변형*을 harness에 맡긴다는 문장이다. `getEvents()` 슬라이스를 누가 호출하는지는 원문이 분명히 하지 않는다 ([[managed-agents]] 열린 질문).

**네 주체 모두 능력 가정을 안는다.** 모델에게 맡기면 모델 능력에, harness에 맡기면 설계자의 예측에 묶인다. 같은 신호(context가 차고 있다)가 MemGPT에서는 핵심 기능이었고 Claude Sonnet 4.5에서는 작업을 일찍 끝내는 원인이었다 ([[agent-memory]] §6, [[meta-harness]]). RLM 시스템 프롬프트는 GPT-5에서 Qwen3-Coder로 그대로 옮겨지지 않았다 ([[2025-12-31-recursive-language-models]]). → 판별 기준은 [[what-to-accumulate-outside-the-model]]의 "능력 가정은 썩고 과제 규칙은 남는다"

### 실행 사이에 남는 것

실행 사이의 연속성은 memory 저장소만의 일이 아니다. 이 위키에는 창 밖에 두는 것이 여럿 있다.

- **외부 state** — *"The agent forgets, the repo doesn't."* 무엇이 끝났고 무엇이 남았는가 ([[loop-engineering]], [[2026-06-07-loop-engineering]])
- **커밋된 아티팩트** — 단계마다 파일로 끝나고 다음 단계가 읽는다. 리뷰를 거치는 쓰기 경로 ([[artifact-chain]])
- **memory 내용** — 사용자에 대한 사실, 대화 원본. 원문을 남기고 추출한 사실로 색인을 보강하는 쪽이 가장 좋았다 ([[agent-memory]], [[2024-10-14-longmemeval]])
- **교훈** — 실패를 자연어로 반성해 다음 시도에 넣는다 ([[2023-03-20-reflexion]]). 같은 반성을 지시문으로 증류하면 prompt가 된다 ([[prompt-optimization]])

이들의 수명 순서(eval > skill/prompt > state > trace > 인터페이스 > harness profile)는 [[what-to-accumulate-outside-the-model]]에 있다.

### 갱신 — 지우지 않는 쪽과 덮어쓰는 쪽

Zep은 바뀐 사실을 지우지 않고 유효 기간을 닫는다(무효화). A-MEM은 이웃 노트의 설명을 새로 쓴다(덮어쓰기). 같은 벤치마크로 비교한 소스가 없다 ([[2025-01-20-zep]], [[2025-02-17-a-mem]]). 상세는 [[agent-memory]] §3.

### 밖에 쌓기 vs 가중치에 넣기

창 밖에 두는 것의 반대편에 **학습**이 있다.

- **밖에 쌓는다.** GEPA는 trace를 반성해 prompt를 고친다. 결과 지시문은 약한 모델에서 강한 모델로 전이됐다 ([[prompt-optimization]]).
- **가중치에 넣는다.** RLM 궤적 1,000개 남짓을 SFT하자 Qwen3-8B가 RLM으로서 +28% 올랐다. scaffold의 행동이 모델 안으로 들어간다 ([[2025-12-31-recursive-language-models]]).

[[meta-harness]]는 둘을 "무엇이 오래 사는가"의 두 답으로 놓는다. 인터페이스를 고정하는 쪽과 학습된 행동을 남기는 쪽이다. *(추론)*

## 측정과 재현

이 주제는 위키에서 정량 소스가 가장 많은 영역이다. 그래도 남이 다시 잰 주장은 둘뿐이다.

| 주장 | 원 측정 | 다시 잰 것 | 결과 |
|---|---|---|---|
| MemGPT가 DMR에서 baseline을 이긴다 | [[2023-10-12-memgpt]] (baseline은 요약만 받음) | [[2025-01-20-zep]] (대화 전체 baseline) | **뒤집힘.** 대화 전체 baseline 94.4% > MemGPT 93.4% |
| RLM이 long-context에서 base와 scaffold를 이긴다 | [[2025-12-31-recursive-language-models]] | [[2026-03-03-reproducing-recursive-language-models]] (20문항, 64k 이하) | **실패는 재현, 이득은 미확인.** 단순 과제·강한 모델에서 손해 ⚠️ |

나머지는 저자 측정이다. Zep은 벤더 자사 측정이고, A-MEM의 Claude Haiku 결과는 baseline이 비정상적으로 낮다 ([[anthropic]] 편향 노트).

## 위험

- **쓰기 경로는 공격 경로다.** 자동으로 memory에 쓰는 구조에는 리뷰 단계가 없다. 갱신이 자동이면 오염된 입력 하나가 기존 memory까지 바꾼다 ([[agent-memory]] §8). LongMemEval 저자들도 저장소 오염을 경고한다. 실험한 소스는 아직 없다. → [[prompt-injection]]
- **창 밖을 코드로 다루면 코드를 실행한다.** RLM은 모델이 쓴 코드를 REPL에서 돌린다. 저자들은 guardrail과 sandboxed REPL을 *"highly underexplored"* 라고 쓴다 ([[2025-12-31-recursive-language-models]]). → [[agent-containment]]
- **지속되는 설정 파일.** `CLAUDE.md`나 state 디렉토리에 들어간 injection은 매 세션 다시 로드된다 ([[2026-05-25-how-we-contain-claude]]).

## Open Questions

- **누가 가져오는 게 나은가?** 위 표의 네 주체를 같은 과제·같은 모델로 비교한 데이터가 없다.
- **삭제는 어떻게 하나?** 구현도 측정도 없다 ([[agent-memory]] 한계 절).
- **무효화 vs 덮어쓰기**, 어느 쪽이 knowledge update에 나은가?
- **RLM은 언제 켜야 하나?** ⚠️ 단순 과제와 강한 모델에서의 손해 → [[contradictions]]
- **memory poisoning은 실제로 얼마나 쉬운가?** 경고만 있고 실험이 없다.
- **(a)~(d) 처방의 비용 비교.** 토큰·지연·정확도를 같은 과제에서 잰 소스가 없다. RLM 재현이 지연(3.6초 → 344초)을 처음 쟀다.

## Related

- [[agent-memory]] — 실행 사이의 기억. 이 topic의 가장 큰 concept
- [[recursive-language-model]] — 한 실행 안의 긴 입력. 처방 (d)
- [[meta-harness]] — compaction 처방 (a)~(c)의 출처. 세션 로그, 인터페이스 vs 학습된 행동
- [[prompt-optimization]] — 반성을 지시문으로 밖에 쌓는 쪽
- [[loop-engineering]] — 외부 state, 실행 사이의 연속성
- [[artifact-chain]] — 리뷰를 거치는 쓰기 경로
- [[agent-recipe]] — 누적된 판단을 밖에 둔다
- [[subagent]], [[dynamic-workflows]] — 처방 (b) 격리
- [[orchestrator-worker]] — lead가 계획을 Memory에 저장하고 핸드오프하는 (a)+(b)의 실전 사례
- [[what-to-accumulate-outside-the-model]] — 밖에 쌓을 것의 수명 순서와 판별 기준
- [[multi-agent-systems]] — 단일 에이전트가 길어질 때의 실패와 독립 context window의 경제성
- [[prompt-injection]], [[agent-containment]] — 쓰기 경로와 코드 실행의 위험
- [[agent-evaluation]] — memory를 재는 벤치마크, 판정자 검증

## Sources

- [[2023-10-12-memgpt]] — 메모리 계층, 모델이 관리하는 쪽, (a)+(c)
- [[2023-03-20-reflexion]] — 교훈을 담는 episodic memory
- [[2024-10-14-longmemeval]] — 다섯 능력, 요약의 약점(−37%), 원문 + 색인
- [[2025-01-20-zep]] — 무효화, DMR 재측정
- [[2025-02-17-a-mem]] — 덮어쓰기, 고정 검색 + LLM 추출
- [[2025-12-31-recursive-language-models]] — context rot 측정, 처방 (d), 학습으로 넣기
- [[2026-03-03-reproducing-recursive-language-models]] — 첫 독립 재현, 지연 측정
- [[2026-04-08-scaling-managed-agents]] — 세션 로그, harness가 관리하는 쪽
- [[2025-06-13-multi-agent-research-system]] — 처방 (a)의 lossy함
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — goal drift, 처방 (b)
- [[2026-06-07-loop-engineering]] — 외부 state
- [[2025-07-25-gepa-reflective-prompt-evolution]] — prompt 증류와 모델 간 전이
- [[2026-05-25-how-we-contain-claude]] — 지속 파일의 injection
