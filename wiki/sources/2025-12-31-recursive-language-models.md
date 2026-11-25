---
title: "Recursive Language Models"
type: source
created: 2026-11-26
updated: 2026-11-26
source_file: ../../raw/papers/2025-12-31-recursive-language-models.pdf
source_url: https://arxiv.org/abs/2512.24601
author: Alex L. Zhang, Tim Kraska, Omar Khattab
source_date: 2025-12-31
tags: [recursive-language-model, long-context, context-rot, compaction, repl, inference-time-scaling, subagent, coding-agents, claude-code, post-training, external-perspective, academic, quantitative]
status: mature
---

# Recursive Language Models

> 긴 prompt를 모델의 창에 넣지 말고 **REPL 안의 변수**로 두라. 모델은 그 변수를 코드로 들여다보고 쪼개고, **코드 안에서 자기 자신을 재귀 호출**한다. 그러면 창의 100배 가까운 입력도 다룰 수 있고, 창 안에 들어가는 길이에서도 정보가 촘촘한 과제라면 base 모델과 기존 scaffold(compaction, CodeAct, Claude Code)를 크게 이긴다. 비용은 중앙값 기준으로 비슷하다.

## Context

- **저자:** Alex L. Zhang, Tim Kraska, Omar Khattab (MIT CSAIL). Khattab은 DSPy 창시자로, [[2025-07-25-gepa-reflective-prompt-evolution]]의 공저자이기도 하다.
- **발행:** arXiv 2512.24601. v1 2025-12-31, 이 위키가 읽은 판은 **v3 (2026-05-11)**. 본문 9쪽, 부록 포함 43쪽. **동료 심사 전 preprint.**
- **코드:** https://github.com/alexzhang13/rlm
- **이 위키에서의 위치:** [[2026-04-08-scaling-managed-agents]]가 *"Prior work has explored ways to address this by storing context as an object that lives outside the context window"* 라고 링크한 선행 연구가 **바로 이 논문**이다. 위키 안에 이미 이 논문을 가리키는 링크가 있었고, 이번 ingest로 그 실이 이어진다. → [[meta-harness]]
- **Claude Code를 외부에서 잰 데이터**가 들어 있다. 단, 측정한 쪽은 경쟁 방법을 내놓은 저자들이다. → [[anthropic]]

## Key Claims

1. **prompt는 신경망에 넣을 것이 아니라 환경의 일부다.** prompt P가 들어오면 RLM은 Python REPL을 띄우고 P를 변수에 담는다. root 모델은 P 자체가 아니라 **크기가 일정한 메타데이터**(길이, 짧은 앞부분, 접근법)만 본다. 코드를 실행한 결과(stdout)도 앞부분과 길이만 history에 붙는다. 최종 답은 REPL의 `Final` 변수에 담긴다. 바깥 인터페이스는 LLM과 같다. 문자열을 받아 문자열을 낸다.
2. **기존 scaffold와 갈리는 설계 결정 셋.** 논문은 "비슷해 보이지만 표현력이 훨씬 낮은" Algorithm 2와 대조한다.
   - **Flaw #1 — prompt를 창에 넣는다.** 창의 한계를 물려받고 compaction 같은 휴리스틱으로 후퇴한다. Search 같은 외부 접근 행동이 있어도 사용자 입력에 대해서는 유계다.
   - **Flaw #2 — 답을 직접 생성한다(Finish 행동).** 출력이 창보다 길 수 없다.
   - **Flaw #3 — 재귀가 코드 안에 없다.** sub-LLM 행동이 따로 있어도 코드에서 프로그래밍적으로 부를 수 없다. 그러면 말로 몇 개 위임할 수 있을 뿐, prompt의 조각마다 루프를 돌며 Ω(|P|)나 Ω(|P|²)개의 호출을 내는 짧은 프로그램을 쓸 수 없다.
3. **기존 self-delegation 비판.** Claude Code subagent(Anthropic 2025), ROMA, THREAD, Context Folding 등은 모델이 자기를 sub-agent로 부르게 하지만 *"they are designed to verbalize sub-calls autoregressively rather than producing them programmatically"* 이므로 **출력 길이가 상한**이 된다. 코딩·검색 에이전트도 파일시스템이나 문서 코퍼스를 환경으로 두지만, 가져온 조각으로 결국 창을 채우고 compaction에 이른다.
4. **유효 context window는 과제와 분리해 말할 수 없다.** 입력 길이에 따라 필요한 처리량이 어떻게 자라는지로 과제를 나눈다. S-NIAH는 O(1), OOLONG은 선형, OOLONG-Pairs는 제곱이다. GPT-5는 복잡한 과제일수록 **더 짧은 길이에서** 무너진다. RLM은 2¹⁴ token을 넘는 길이에서 일관되게 GPT-5를 이긴다(Figure 1).
5. **주요 결과 (Table 1, GPT-5 root + GPT-5-mini sub-call).**

   | 방법 | CodeQA | BrowseComp+ (1K문서, 6~11M token) | OOLONG | OOLONG-Pairs (F1) |
   |---|---|---|---|---|
   | GPT-5 base | 24.0* | 0.0* | 44.0 | 0.1 |
   | Compaction agent | 58.0 | 70.5 | 46.0 | 0.1 |
   | CodeAct (+ sub-calls) | 24.0* | 0.0* | 40.0 | 28.4 |
   | RLM depth=0 (sub-call 없음) | 58.0 | 88.0 | 36.0 | 43.9 |
   | RLM depth=1 | 62.0 | 91.3 | 56.0 | 58.0 |
   | RLM depth=3 | 58.0 | 92.0 | 58.0 | 76.0 |
   | Claude Code (Opus 4.1) | 12.0* | 0.0* | 40.2 | 0.1 |
   | Claude Code + context offloading | 62.0 | 84.0 | 48.0 | 6.5 |

   \* 입력이 context 한계에 (가끔) 걸린 실행. Qwen3-Coder-480B에서도 방향은 같지만, depth를 높이면 오히려 나빠진다(Claim 9).
6. **REPL은 길이를, 재귀는 밀도를 맡는다 (Observation 2).** sub-call이 없는 depth=0 RLM이나 파일로 offloading한 Claude Code·OpenCode도 창을 넘는 입력을 처리하고 대부분의 baseline을 이긴다. Qwen3-Coder의 CodeQA에서는 depth=0이 모든 재귀 변형보다 낫다. 하지만 OOLONG처럼 줄마다 의미 변환이 필요한 과제에서 sub-call이 없으면 키워드 휴리스틱으로 후퇴한다. OOLONG-Pairs에서는 깊은 재귀가 Claude Code·OpenCode를 큰 차이로 이긴다.
7. **비용은 중앙값에서 비슷하고 꼬리가 길다 (Observation 4, 부록 F).** 중앙값 RLM 실행은 base 모델 실행보다 싸지만, 답을 못 찾고 헤매는 궤적 때문에 평균은 더 비싸다. BrowseComp+에서 GPT-5-mini가 6~11M token을 그대로 읽는다고 선형 외삽한 비용은 $1.50~2.75, RLM 평균은 $0.99다. 모든 sub-call이 동기 실행이라 95분위 runtime이 매우 길다.
8. **long-context 밖에서도 작동한다 (Observation 5).** LongCoT-mini에서 GPT-5.2 base 38.7 → RLM 50.6 → 분해 힌트를 준 RLM 65.6(+69.5%). 힌트를 주면 RLM은 문제 그래프를 만들고 노드마다 sub-call로 푼다. 단, 힌트 없는 RLM은 MATH에서 base보다 크게 낮았다(26.0 → 5.6).
9. **RLM도 모델 능력에 묶인다 (§5, 부록 B "Negative Results").**
   - GPT-5용으로 쓴 시스템 프롬프트를 Qwen3-Coder에 그대로 쓰면 sub-call을 남발했다. 한 문장을 더해야 했다.
   - 코딩 능력이 부족한 작은 모델(Qwen3-8B)은 RLM으로 잘 작동하지 않는다.
   - thinking 모델(Qwen3-235B)은 thinking token이 호출당 출력 한도를 넘겨 궤적이 끊겼다.
   - `FINAL()`과 `FINAL_VAR()` 태그로 "다음 턴"과 "최종 답"을 가르는 방식이 불안정하다. 계획을 최종 답으로 내놓는 일이 있었다.
   - Qwen3-Coder는 문법 오류가 많고, 재귀가 깊어지면 오류가 sub-RLM으로 번진다. 그래서 깊이를 높이면 평균 성능이 떨어진다.
   - 첫 분해 시도가 성능을 크게 좌우한다. 과제와 무관한 in-context 예시라도 넣으면 첫 분해와 전체 성능이 좋아진다(Figure 4a).
10. **RLM 행동은 학습으로 모델에 넣을 수 있다 (Observation 6, 부록 A).** leaf sub-call은 일반 LLM 요청과 다를 바 없으므로 **root 역할만** 배우면 된다는 가설이다. Qwen3-Coder-480B의 RLM 궤적 2,250개를 1,072개로 거르고, 템플릿 실수를 프로그램으로 고친 뒤(턴의 16%가 FINAL을 잘못 씀), Qwen3-8B에 SFT했다(48 H100시간). RLM-Qwen3-8B는 base Qwen3-8B RLM보다 중앙값 **+28%**, 3배 이상 빠르다. 학습 데이터(LongBenchPro)는 평가 과제와 무관하다. 별도로 Qwen3-4B를 MRCRv2 64k/2-needle에서 RLVR로 학습했더니 1M/8-needle로 **길이 일반화**됐다. 저자들은 native RLM 학습을 *"a new axis of scale"* 로 본다.

## Notable Quotes / Passages

> *"The key insight is that arbitrarily long user prompts should not be fed into the neural network (e.g., Transformer) directly but should instead be treated as part of the environment that the LLM is tasked to symbolically and recursively interact with."*

> *"[Prior self-delegation approaches] are handicapped by the underlying LLM's limited output lengths because they are designed to verbalize sub-calls autoregressively rather than producing them programmatically."*

> *"RLMs differ from these works in that all context window management is implicitly handled by the LM itself."* — MemGPT·Mem0식 명시적 memory 계층과 자신을 구분하는 문장

> *"Broadly, RLMs add a layer of complexity on top of existing LMs that may lead to unintentional side-effects like exploding sub-call costs."*

## Connections

- [[recursive-language-model]] — 이 소스가 만든 concept 페이지.
- [[meta-harness]] — Managed Agents가 인용한 "창 밖 객체" 선행 연구. compaction 처방 표에 **(d) 애초에 넣지 않는다** 행을 더한다. 학습으로 scaffold를 가중치에 넣는다는 주장은 "harness 가정은 썩는다"의 반대 방향 사례다.
- [[dynamic-workflows]] — 조정과 중간값을 프로그램 변수에 두는 같은 원리. 차이는 코드를 한 번 쓰느냐, 실행 피드백을 보며 계속 쓰느냐다.
- [[subagent]] — "말로 하는 위임"과 "코드로 하는 위임"의 구분, 그리고 Claude Code subagent에 대한 표현력 비판.
- [[agent-memory]] — 창 밖 저장소를 **모델이** 관리하는 극단. 저자들은 MemGPT식 명시적 계층과 자신을 구분한다. 부록 B는 "memory 정책은 능력 가정이다"의 근거를 더한다.
- [[multi-agent-systems]] — 단일 에이전트가 길어질 때 무너지는 방식(context rot, goal drift)에 대한 측정 근거.
- [[claude-code]], [[anthropic]] — Claude Code를 외부에서 잰 데이터와 그 단서.

## My Notes

- **Claude Code 비교는 모델이 다르다.** RLM과 다른 baseline은 GPT-5(+GPT-5-mini)로, Claude Code는 **Claude Opus 4.1 + Claude Code v2.0.0**으로 돌렸다. 저자들은 "closed source agent는 대응 모델에 맞춰 설계됐다"는 이유를 대고 같은 시기의 모델을 골랐다. 합리적인 선택이지만 표의 Claude Code 행은 **harness 차이와 모델 차이가 섞인** 수치다. 표에 비용이 함께 있어 Claude Code의 비용이 가장 높게 보이는 점도(OOLONG-Pairs $6.75) Opus 가격의 영향을 받는다.
- **경쟁자가 측정했다.** Claude Code와 OpenCode는 RLM의 직접 경쟁 scaffold다. 프롬프트와 offloading 방식을 저자가 정했다. 그래도 offloading을 켠 Claude Code가 BrowseComp+ 84.0으로 강하게 나온 것을 숨기지 않았다.
- **자기 생태계 편향이 이어진다.** Khattab이 GEPA에 이어 두 번째 DSPy 계열 소스의 공저자다. 이 논문의 baseline에는 DSPy 계열 방법이 없으므로 GEPA 때와 같은 "자기 도구와 비교" 문제는 작다.
- **벤치마크 일부는 저자가 만들었다.** OOLONG-Pairs는 OOLONG을 고친 20문항이다. OOLONG-Pairs에서 RLM의 이득이 가장 크다. CodeQA·OOLONG은 50문항, BrowseComp+는 150문항이다. 신뢰구간은 없고 비용의 표준편차만 있다.
- **"comparable cost"는 중앙값 이야기다.** 평균은 꼬리 때문에 높고, 저자들도 sub-call 비용 폭발을 한계로 적는다. 실무에서는 예산 상한과 timeout이 필요하다. [[dynamic-workflows]]가 "예산을 명시적으로 걸라"고 한 것과 같은 문제다.
- **안전 장치가 비어 있다.** 저자들은 guardrail과 sandboxed REPL을 *"highly underexplored"* 라고 쓴다. 모델이 쓴 코드를 실행하는 구조이므로 [[agent-containment]]의 질문(blast radius)이 그대로 걸린다. 논문은 보안을 다루지 않는다. *(추론)*
- **초록 문구가 판마다 다르다.** arXiv 메타데이터의 초록은 *"two orders of magnitude"*, *"28.3% on average"* 라고 쓰고, 이 위키가 읽은 v3 PDF는 *"more than an order of magnitude"*, *"a median of 28%"* 라고 쓴다. 이 페이지는 PDF를 따랐다.

## Raw Source

[원본 PDF](../../raw/papers/2025-12-31-recursive-language-models.pdf)
