---
title: Recursive Language Model (RLM)
type: concept
created: 2026-11-26
updated: 2026-11-26
sources: [2025-12-31-recursive-language-models, 2026-04-08-scaling-managed-agents]
aliases: [RLM, recursive language models, context offloading, prompt as environment, symbolic recursion]
tags: [recursive-language-model, long-context, context-rot, compaction, repl, inference-time-scaling, subagent, context-engineering]
status: draft
---

# Recursive Language Model (RLM)

> 긴 입력을 창에 넣지 않고 **REPL 변수로 두고**, 모델이 코드로 그 변수를 다루며 **코드 안에서 자기 자신을 재귀 호출**하게 하는 추론 scaffold다. REPL은 길이 문제를, 재귀는 정보 밀도 문제를 푼다. 비용은 모델의 코딩 능력에 묶이고 꼬리가 길다.

## Overview

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

### 비용과 위험

- **중앙값은 싸고 꼬리가 길다.** 중앙값 RLM 실행은 base 모델보다 싸지만 평균은 더 비싸다. sub-call이 동기 실행이라 95분위 runtime이 매우 길다. 저자들은 *"exploding sub-call costs"* 를 한계로 적는다 ([[2025-12-31-recursive-language-models]]). 예산과 timeout이 필요하다. [[multi-agent-systems]]의 경제성 판단(조정 비용을 벌어야 한다)이 여기에도 걸린다.
- **모델이 쓴 코드를 실행한다.** guardrail과 sandboxed REPL은 *"highly underexplored"* 다. [[agent-containment]]의 blast radius 질문과 [[prompt-injection]]의 경로가 그대로 걸린다. 긴 입력 안에 섞인 지시문이 REPL 코드로 이어질 수 있다. 논문은 보안을 다루지 않는다. *(추론)*

## 한계와 읽을 때의 주의

- **소스가 하나다.** 구현·측정 모두 저자 측정이고 preprint다. arXiv에는 후속 연구(재현, 일반화, RLMOpt 등)가 있으나 이 위키에는 아직 없다.
- **Claude Code 비교는 모델이 다르다.** Claude Code 행은 Opus 4.1, 나머지는 GPT-5다. → [[2025-12-31-recursive-language-models]] My Notes
- **벤치마크가 작고 일부는 저자 제작이다.** 이득이 가장 큰 OOLONG-Pairs가 저자가 만든 20문항이다.

## Related

- [[meta-harness]] — compaction 처방 표의 (d) 행. Managed Agents가 이 논문을 선행 연구로 인용한다. 학습으로 scaffold를 가중치에 넣는 반대 방향 사례
- [[dynamic-workflows]] — 조정을 프로그램 변수에 두는 같은 원리. 한 번 쓰는 코드 vs 계속 고치는 코드
- [[subagent]] — 말로 하는 위임 vs 코드로 하는 위임. 표현력 비판의 대상
- [[agent-memory]] — 창 밖 저장소를 모델이 관리하는 극단. 능력 가정의 사례
- [[multi-agent-systems]] — 단일 에이전트가 길어질 때의 실패와 그 경제성
- [[claude-code]] — 외부에서 잰 baseline. offloading의 효과와 한계
- [[agent-containment]] — 모델이 쓴 코드를 실행하는 구조의 격리 문제

## Sources

- [[2025-12-31-recursive-language-models]] — Zhang, Kraska, Khattab (MIT CSAIL), arXiv 2512.24601 v3. 이 페이지 전체의 1차 출처
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). 이 논문을 "창 밖 객체" 선행 연구로 인용한 지점
