---
title: Recursive Language Model (RLM)
type: concept
created: 2026-11-26
updated: 2026-11-26
sources: [2025-12-31-recursive-language-models, 2026-04-08-scaling-managed-agents, 2026-03-03-reproducing-recursive-language-models]
aliases: [RLM, recursive language models, context offloading, prompt as environment, symbolic recursion]
tags: [recursive-language-model, reproduction, long-context, context-rot, compaction, repl, inference-time-scaling, subagent, context-engineering]
status: draft
---

# Recursive Language Model (RLM)

> 긴 입력을 창에 넣지 않고 **REPL 변수로 두고**, 모델이 코드로 그 변수를 다루며 **코드 안에서 자기 자신을 재귀 호출**하게 하는 추론 scaffold다. REPL은 길이 문제를, 재귀는 정보 밀도 문제를 푼다. 비용은 모델의 코딩 능력에 묶이고 꼬리가 길다. 외부 재현에서는 실패는 재현됐고 이득은 확인되지 않았으며, 단순 과제와 강한 모델에서는 오히려 손해였다 ⚠️.

## Overview

이 개념은 [[context-and-memory]]의 처방 지도에서 (d) "애초에 넣지 않는다"에 해당하고, "누가 가져오나" 표에서 **모델이 쓴 코드**가 정하는 주체다.

### 무엇을 푸는가: context rot는 과제에 따라 다르게 온다

frontier 모델도 prompt가 길어지면 품질이 떨어진다(context rot). [[2025-12-31-recursive-language-models]]는 그 열화 속도가 **과제가 요구하는 처리량**에 달렸다고 본다.

| 과제 | 입력 길이에 대한 처리량 | GPT-5의 열화 |
|---|---|---|
| S-NIAH (바늘 하나 찾기) | O(1) | 1M token에서도 거의 유지 |
| OOLONG (줄마다 의미 분류 후 집계) | O(\|P\|) | 더 짧은 길이에서 무너짐 |
| OOLONG-Pairs (쌍마다 집계) | O(\|P\|²) | 창 안에서도 F1 ≈ 0.1 |

그래서 "유효 context window"는 과제와 분리해 말할 수 없다. 창 크기를 늘리는 것만으로는 밀도 높은 과제가 풀리지 않는다.

### 어떻게 작동하는가

```
prompt P ──► REPL: context = P, llm_query() 함수 등록
                │
root LM ◄── 메타데이터만 (len(P), 앞부분, 접근법)
   │  code 생성
   ▼
REPL 실행 ── 변수 갱신, 루프 안에서 llm_query(P[i:j]) 수백 번 가능
   │  stdout은 앞부분·길이만 history에 붙음
   ▼
Final 변수가 채워지면 반환
```

바깥에서 보면 RLM은 그냥 LM이다. 문자열을 받아 문자열을 낸다. root 모델의 창에는 P가 한 번도 통째로 들어가지 않는다 ([[2025-12-31-recursive-language-models]]).

## Key Points

### 기존 scaffold와 가르는 세 결정

| 결정 | RLM | 흔한 scaffold (논문의 Algorithm 2) | 깨지는 것 |
|---|---|---|---|
| prompt의 위치 | REPL 변수 (**이름으로 참조**) | 모델의 창 | 창 한계를 물려받고 compaction으로 후퇴 |
| 출력의 위치 | REPL 변수 `Final` | `Finish` 행동으로 직접 생성 | 출력이 창보다 길 수 없음 |
| 재귀의 위치 | **코드 안** (루프에서 호출) | 별도 sub-LLM 행동 (말로 호출) | 하위 호출 수가 출력 길이에 묶임. Ω(\|P\|)개를 낼 수 없음 |

셋째가 이 개념의 정의적 특징이다. 저자들은 Claude Code subagent를 포함한 기존 self-delegation이 하위 호출을 *"verbalize … autoregressively"* 하므로 표현력이 모자란다고 비판한다. → [[subagent]]

### REPL과 재귀는 다른 일을 한다

Table 1의 depth 비교가 둘을 가른다 ([[2025-12-31-recursive-language-models]]).

- **REPL만 있어도 길이는 풀린다.** sub-call이 없는 depth=0 RLM은 BrowseComp+ (6~11M token)에서 88.0이다. 파일로 offloading한 Claude Code도 0.0에서 84.0으로 올랐다. 창 밖에 두기만 해도 길이 한계는 사라진다.
- **밀도는 재귀가 푼다.** OOLONG-Pairs에서 depth=0은 43.9, depth=1은 58.0, depth=3은 76.0이다. offloading한 Claude Code는 6.5에 머문다. sub-call이 없으면 모델은 줄마다 의미를 읽는 대신 키워드 휴리스틱으로 후퇴한다.
- **깊이가 늘 이득은 아니다.** Qwen3-Coder는 문법 오류가 많아 깊은 재귀에서 오류가 하위로 번졌고, CodeQA에서는 depth=0이 가장 좋았다.

### 창 밖 저장소를 누가 다루나 — 모델이, 코드로

[[agent-memory]]는 창 밖 저장소를 **누가** 관리하느냐로 설계를 가른다. MemGPT는 모델이 function call로, Managed Agents는 harness가 정한다. RLM은 모델 쪽 극단이다. 저자들은 MemGPT·Mem0식 명시적 memory 계층과 자신을 구분한다. *"all context window management is implicitly handled by the LM itself."* 차이는 **도구 목록**에 있다. MemGPT는 미리 정한 paging 함수를 주고, RLM은 범용 Python을 준다. 무엇을 어떻게 잘라 읽을지가 함수 목록이 아니라 모델이 쓰는 프로그램으로 정해진다. *(대응은 이 위키의 해석이다.)*

### 조정이 코드로 이동한다 — 단, 계속 다시 쓴다

[[dynamic-workflows]]도 조정 상태를 LLM 컨텍스트가 아니라 프로그램 변수에 둔다. 원리는 같고 방식이 다르다.

| | dynamic workflow | RLM |
|---|---|---|
| 코드를 쓰는 횟수 | harness를 **한 번** 쓰고 실행 | 턴마다 쓰고, 실행 결과를 보고 **다시** 씀 |
| 실행 중 전략 변경 | 불가 (정지 조건을 미리 표현해야 함) | 가능 (REPL 피드백으로 분해를 고침) |
| 하위 호출 단위 | subagent (도구를 가진 에이전트) | LM 또는 sub-RLM (문자열 → 문자열) |
| 출처 | [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] | [[2025-12-31-recursive-language-models]] |

저자들은 한 번에 프로그램을 생성하는 DisCIPL을 *"cannot recover from generation mistakes"* 라고 비판한다. 같은 비판이 dynamic workflow의 "유연성 대가"와 겹친다. *(대응은 이 위키의 해석이다.)*

### RLM도 능력 가정이다

부록 B의 실패 목록은 [[agent-memory]] §6과 [[meta-harness]]가 말하는 **능력 가정**의 사례다 ([[2025-12-31-recursive-language-models]]).

- 같은 시스템 프롬프트가 모델마다 다르게 작동했다. Qwen3-Coder는 sub-call을 남발해 한 문장을 더해야 했다.
- 코딩 능력이 약한 모델은 RLM으로 작동하지 않는다.
- thinking token이 호출당 출력 한도를 넘기면 궤적이 끊긴다.
- 최종 답과 생각을 `FINAL()` 태그로 가르는 방식이 불안정하다.
- 첫 분해 시도가 성능을 좌우하고, in-context 예시에 민감하다.

### 그리고 학습으로 넣을 수 있다

저자들의 가설은 이렇다. leaf sub-call은 평범한 LLM 요청이라 **root 역할만** 배우면 된다. 큰 모델의 RLM 궤적 1,000개 남짓을 SFT하자 Qwen3-8B가 중앙값 +28%, 3배 이상 빨라졌다. 학습 과제는 평가 과제와 무관했다. RL로는 64k에서 1M token으로 길이 일반화가 나타났다 ([[2025-12-31-recursive-language-models]]).

이 위키의 기존 논지와 반대 방향이다. [[meta-harness]]는 *harness에 넣은 가정은 모델이 좋아지면 썩는다*고 보고, 인터페이스를 고정하고 harness를 갈아 끼우라고 처방한다. RLM은 scaffold의 행동을 **가중치로 옮기고** 바깥 인터페이스(문자열 → 문자열)는 그대로 둔다. 둘은 모순이 아니다. 둘 다 "무엇이 오래 사는가"에 답하는데, meta-harness는 인터페이스를, RLM은 학습된 행동을 꼽는다. *(추론)*

### 외부 재현: 실패는 재현됐고, 이득은 확인되지 않았다 (2026-11-26)

[[2026-03-03-reproducing-recursive-language-models]](CUHK, 단독 저자)가 원 저자 그룹 밖에서 처음 재현했다. 모델은 DeepSeek v3.2와 Kimi K2, 과제는 S-NIAH와 OOLONG이다. 조건당 20문항, 1회 실행이고 context는 64k token 이하로 제한했다.

| | S-NIAH (base → d=1 → d=2) | OOLONG (base → d=1 → d=2) |
|---|---|---|
| DeepSeek v3.2 | 100 → 85 → 70 | 0.0 → 42.1 → 33.7 |
| Kimi K2 | 100 → 90 → — | **86.6** → 60.0 → 55.0 |

- **재현된 것: 실패.** 원 논문 부록 B의 실패가 다른 모델 둘에서 다시 나왔다. 최종 답 대신 `print()` 코드를 반환했고, thinking 태그가 파서를 깼고, 깊은 재귀에서 오류가 번졌다. 원 논문에서 Qwen3-Coder가 깊이가 늘면 나빠진 것처럼, depth=2는 모든 조건에서 depth=1보다 나빴다. **depth 결과는 원 논문과 일치한다.** 깊이가 이득이었던 모델은 원 논문의 GPT-5뿐이다.
- **확인되지 않은 것: 이득.** 저자는 DeepSeek OOLONG 0.0 → 42.1을 핵심 결과의 재현으로 든다. 하지만 부록에서 저자 스스로 base의 0%는 답을 찾고도 형식을 어긴 결과라고 적는다. 이 차이로는 형식 효과와 추론 효과를 가를 수 없다.
- **새로 보인 것: 깊은 재귀의 실패 모드.** depth=2에서 DeepSeek은 입력에 숨긴 가상의 "magic number" 대신 핵물리 magic number를 사전지식으로 답했다(context anchoring 상실). 이미 뽑은 답을 재검증하는 sub-call을 멈추지 않고 띄워 한 문항에 741초를 썼다.

> ⚠️ **Contradiction (2026-11-26): 단순한 과제와 강한 모델에서도 RLM은 손해가 작은가.** [[2025-12-31-recursive-language-models]]는 Figure 1에서 RLM(GPT-5)이 S-NIAH를 포함한 세 과제 모두에서 *"maintains strong performance"* 하고, 2¹⁴ token을 넘으면 base GPT-5를 *"consistently"* 이긴다고 보고한다. [[2026-03-03-reproducing-recursive-language-models]]에서는 base가 100%인 S-NIAH에서 RLM이 70~90%로 떨어졌다. 이미 long-context에 강한 Kimi K2는 OOLONG에서 86.6 → 60.0으로 떨어졌다.
>
> **판정 보류.** 조건이 다르다. 모델(GPT-5 vs DeepSeek·Kimi), 문항 수(50 vs 20, 1회 실행), 길이(원 논문은 2¹³~2²⁰, 재현은 64k 이하)가 다르다. 재현의 하락에는 형식 실패(REPL과 최종 출력의 혼동)가 섞였을 수 있다. 정면으로 겹치는 구간은 16k~64k다. **"긴 입력에서 RLM이 이긴다"는 이 재현이 시험하지 않았으므로 이 모순의 범위 밖이다.**
>
> 판정에 필요한 것: 같은 모델로 원 논문과 같은 길이 구간을 재고, 형식 실패와 오답을 따로 집계한 측정.

모순이 어느 쪽으로 풀리든 실무상 함의는 같다. **RLM은 켜고 끄는 선택지여야 한다.** base 모델이 이미 푸는 과제나 강한 long-context 모델에 기본값으로 씌우면 손해일 수 있다. *(추론)* [[meta-harness]]의 "harness 가정은 모델이 좋아지면 썩는다"와 같은 모양이다.

### 비용과 위험

- **지연은 재현에서 더 나쁘게 나왔다.** DeepSeek의 S-NIAH 한 문항은 base 3.6초, depth=1 89.3초, depth=2 344.5초였다. Kimi는 depth=2에서 문항당 545.5초였다. sub-call이 동기 실행이고, REPL에는 정지 장치가 없다 ([[2026-03-03-reproducing-recursive-language-models]]).
- **중앙값은 싸고 꼬리가 길다.** 중앙값 RLM 실행은 base 모델보다 싸지만 평균은 더 비싸다. sub-call이 동기 실행이라 95분위 runtime이 매우 길다. 저자들은 *"exploding sub-call costs"* 를 한계로 적는다 ([[2025-12-31-recursive-language-models]]). 예산과 timeout이 필요하다. [[multi-agent-systems]]의 경제성 판단(조정 비용을 벌어야 한다)이 여기에도 걸린다.
- **모델이 쓴 코드를 실행한다.** guardrail과 sandboxed REPL은 *"highly underexplored"* 다. [[agent-containment]]의 blast radius 질문과 [[prompt-injection]]의 경로가 그대로 걸린다. 긴 입력 안에 섞인 지시문이 REPL 코드로 이어질 수 있다. 논문은 보안을 다루지 않는다. *(추론)*

## 한계와 읽을 때의 주의

- **소스가 둘이고, 독립 재현은 작다.** 원 논문은 저자 측정 preprint다. 외부 재현([[2026-03-03-reproducing-recursive-language-models]])은 조건당 20문항, 1회 실행, 64k 이하라 원 논문의 긴 구간을 재지 않았다. 다른 후속 연구(일반화, RLMOpt 등)는 이 위키에 아직 없다.
- **Claude Code 비교는 모델이 다르다.** Claude Code 행은 Opus 4.1, 나머지는 GPT-5다. → [[2025-12-31-recursive-language-models]] My Notes
- **벤치마크가 작고 일부는 저자 제작이다.** 이득이 가장 큰 OOLONG-Pairs가 저자가 만든 20문항이다.

## Related

- [[context-and-memory]] — 상위 topic. compaction 처방 지도와 누가 가져오나의 네 주체
- [[meta-harness]] — compaction 처방 표의 (d) 행. Managed Agents가 이 논문을 선행 연구로 인용한다. 학습으로 scaffold를 가중치에 넣는 반대 방향 사례
- [[dynamic-workflows]] — 조정을 프로그램 변수에 두는 같은 원리. 한 번 쓰는 코드 vs 계속 고치는 코드
- [[subagent]] — 말로 하는 위임 vs 코드로 하는 위임. 표현력 비판의 대상
- [[agent-memory]] — 창 밖 저장소를 모델이 관리하는 극단. 능력 가정의 사례
- [[multi-agent-systems]] — 단일 에이전트가 길어질 때의 실패와 그 경제성
- [[claude-code]] — 외부에서 잰 baseline. offloading의 효과와 한계
- [[agent-containment]] — 모델이 쓴 코드를 실행하는 구조의 격리 문제
- [[contradictions]] — 위 ⚠️ Contradiction이 등록된 목록

## Sources

- [[2025-12-31-recursive-language-models]] — Zhang, Kraska, Khattab (MIT CSAIL), arXiv 2512.24601 v3. 이 페이지 전체의 1차 출처
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). 이 논문을 "창 밖 객체" 선행 연구로 인용한 지점
- [[2026-03-03-reproducing-recursive-language-models]] — Daren Wang (CUHK, arXiv 2603.02615). 외부 재현, depth=2, ⚠️ Contradiction의 한쪽 (2026-11-26)
