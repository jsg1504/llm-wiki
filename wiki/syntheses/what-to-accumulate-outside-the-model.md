---
title: 모델 밖에 무엇을 쌓는가 — 모델이 좋아져도 썩지 않는 로컬 자산
type: synthesis
created: 2026-11-26
updated: 2026-11-26
sources: [2026-04-08-scaling-managed-agents, 2025-07-25-gepa-reflective-prompt-evolution, 2026-09-30-loop-is-the-product, 2026-06-07-loop-engineering, 2026-08-14-practical-loop-engineering, 2026-08-21-the-ai-native-sdlc-playbook, 2026-05-25-how-we-contain-claude, 2025-06-13-multi-agent-research-system, 2023-10-12-memgpt, 2023-03-20-reflexion, 2024-10-14-longmemeval, 2025-01-20-zep, 2025-02-17-a-mem]
question: "LLM 모델은 점점 좋아지고 agent는 점점 발전하고 있어. 이 agent의 성능을 계속 발전적으로 좋게 만들기 위해 모델이 아닌 로컬에도 쌓을 것이 있다면 어떤게 있을까?"
aliases: [로컬에 쌓을 것, durable local assets, 능력 가정과 과제 규칙]
tags: [agent-recipe, system-distillation, meta-harness, agent-evaluation, external-state, synthesis]
status: draft
---

# 모델 밖에 무엇을 쌓는가 — 모델이 좋아져도 썩지 않는 로컬 자산

> 모델 밖에 쌓을 가치가 있는 것은 **다음 모델이 나와도 썩지 않는 것**이다. "Claude는 X를 못 한다" 같은 **능력 가정**은 모델이 좋아지면 낡는다. **과제에 대한 규칙과 판단 기준**은 모델이 바뀌어도 남는다. 그래서 쌓을 것은 판단(eval·skill·prompt), 실행 사이에 남는 state, 그 재료인 trace다. harness 안의 우회 코드는 쌓을 대상이 아니다.

## 판별 기준: 능력 가정 vs 과제 규칙

[[meta-harness]]는 harness를 "모델이 아직 혼자 못 하는 것에 대한 가정의 집합"으로 본다. 그 가정은 모델이 좋아지면 썩는다. 사례가 있다. Sonnet 4.5의 "context anxiety"를 막으려고 harness에 context reset을 넣었는데, Opus 4.5에서는 그 행동이 사라져 reset이 dead weight가 됐다 ([[meta-harness]], [[2026-04-08-scaling-managed-agents]]).

반대 방향의 근거도 있다. GEPA로 Qwen3 8B에서 최적화한 prompt를 GPT-4.1 Mini에 **수정 없이** 쓰자 +9.00%가 나왔다. GPT-4.1 Mini에서 직접 최적화한 다른 optimizer(+3~6%)보다 높다 ([[prompt-optimization]], [[2025-07-25-gepa-reflective-prompt-evolution]]). trace에서 뽑은 지시문은 특정 모델의 버릇이 아니라 **과제에 대한 규칙**을 담기 때문으로 읽힌다 ([[prompt-optimization]] §5).

[[meta-harness]]는 이 둘을 모순이 아니라 판별 기준으로 정리한다. **능력 가정은 썩고, 과제 규칙은 남는다.** *(이 기준은 위키의 추론이다. 두 소스 모두 이렇게 말하지는 않는다.)*

> **썩는 방향은 한쪽이 아니다 (2026-11-26).** [[2023-10-12-memgpt]]에서는 memory를 모델이 스스로 관리하게 했더니 **더 새로운** GPT-4 Turbo가 GPT-4보다 다단계 조회를 못 했다. context 한계를 경고하는 정책도 GPT-4 계열에서는 기능이었지만 Sonnet 4.5에서는 조기 종료를 불렀다. 능력 가정은 모델이 좋아지면 쓸모없어질 뿐 아니라 **새 모델에서 오히려 해가 될 수도 있다.** 그래서 아래 4번의 재검증은 "아직 필요한가"만이 아니라 "아직 맞는가"도 묻는다. → [[agent-memory]] *(추론)*

> **썩는 구조와 올라타는 구조 (2026-11-26).** 지금까지의 썩는 사례(context reset)는 모델의 **부족분을 메우는** 구조였다. [[2023-03-20-reflexion]]의 반성 루프는 반대로 모델의 **강점에 올라타는** 구조다. starchat-beta에서는 개선이 0이었고(0.26 → 0.26), 저자들은 자기 수정을 *"더 강하고 큰 모델의 emergent quality"* 로 본다. 그래서 *"LLM 능력이 좋아질수록 이 패러다임은 더 좋아질 것"* 이라고 전망한다.
>
> **전망과 관측을 나란히 둔다.** 이 전망은 측정이 아니다. 같은 "모델에게 맡기는" 설계인 MemGPT에서는 더 새로운 GPT-4 Turbo가 GPT-4보다 나빴다(위 노트). 모델의 강점에 올라타는 구조라도 **그 강점이 다음 모델에서 유지된다는 것 자체가 가정**이다. 따라서 올라타는 구조도 썩는 구조처럼 모델을 바꿀 때 eval로 재검증한다. 다른 점은 기대하는 방향뿐이다. 썩는 구조는 "이제 빼도 되는가"를 묻고, 올라타는 구조는 "여전히 이득인가"를 묻는다. *(추론)*

## 무엇을 쌓는가: 수명 순서

| 쌓을 것 | 무엇을 담나 | 왜 모델보다 오래 사나 | 근거 |
|---|---|---|---|
| **Eval / judge** | 실패 패턴, 제작자의 taste를 코드화한 것 | "좋은 결과란 무엇인가"는 모델이 바뀌어도 그대로다. 오히려 새 모델을 검증하는 도구가 된다 *(추론)* | [[agent-recipe]], [[agent-evaluation]] §3b |
| **Skill / prompt** | 반복 행동, 에이전트가 짐작해야 했을 프로젝트 지식 | trace에서 증류한 지시문이 모델 간에 전이됐다 (+9%) | [[prompt-optimization]] §5, [[loop-engineering]] |
| **외부 state / artifact** | 무엇이 끝났고 무엇이 남았는가, 단계별 산출물 | *"The agent forgets, the repo doesn't."* 메모리는 컨텍스트가 아니라 디스크에 둔다 | [[loop-engineering]], [[artifact-chain]] |
| **Memory 내용** | 사용자에 대한 사실, 과거 대화 원본 | 모델과 무관한 사실이다. 단 그것을 **언제 넣고 뺄지 정하는 정책**은 능력 가정이라 수명이 짧다 *(추론)*. 저장은 **원문을 남기고 추출한 사실로 색인을 보강**하는 쪽이 가장 좋았다. 요약만 남긴 상용 memory는 원문보다 37% 낮았다 | [[agent-memory]], [[2024-10-14-longmemeval]] |
| **Trace / session log (원본)** | 실행 기록 전체 | 두 번째 루프의 signal이 된다. compaction은 되돌릴 수 없으니 원본을 창 밖에 둔다 | [[meta-harness]], [[agent-evaluation]] §5 |
| **인터페이스** | session / harness / sandbox 경계 | harness는 갈아 끼우고 경계선만 고정한다 | [[meta-harness]] |
| **Harness profile / memory** | 사용자 불만에서 나온 harness 확장 | 가장 빨리 낡는다. 모델별로 따로 둔다 | [[agent-recipe]] |

이 묶음 전체를 git에 버전 관리한 것이 [[agent-recipe]]다. 루프의 교훈을 recipe로 옮기는 과정은 **system distillation**이라고 부른다. 변환 규칙은 세 가지다. 실패 패턴은 judge와 eval이 된다. 반복 행동은 skill과 prompt가 된다. 사용자 불만은 harness 확장과 memory가 된다 ([[agent-recipe]], [[2026-09-30-loop-is-the-product]]).

세 처방은 상태를 모델과 context window **밖**에 둔다는 점에서 같다. 밖에 두는 대상만 다르다. [[meta-harness]]는 경계선을, [[artifact-chain]]은 산출물을, [[agent-recipe]]는 판단을 밖에 둔다 ([[agent-recipe]]).

## 각 항목을 잘 쌓는 법

### 1. Eval이 가장 중요한 자산이다

- **production incident 하나마다 eval을 하나** 추가해 영구 회귀 테스트로 남긴다. 모델이 좋아져 변별력을 잃은 케이스는 교체한다. eval suite는 계속 고쳐 쓰는 대상이다 ([[agent-evaluation]] §6, [[2026-08-21-the-ai-native-sdlc-playbook]]).
- 케이스를 교체하는 대신 **난이도를 올릴 수 있게** 설계하는 길도 있다. LongMemEval은 같은 질문의 대화 이력 길이를 자유롭게 늘려, 시스템이 좋아져도 벤치마크가 쉬워지지 않게 했다 ([[agent-evaluation]] §6, [[2024-10-14-longmemeval]]). 판정자를 쓴다면 사람과 대조한 일치율을 함께 남긴다(97~98%). 판정자도 모델이 바뀌면 다시 확인할 대상이다. *(뒤 문장은 추론이다.)*
- 채점 함수는 **점수와 함께 텍스트**를 돌려준다. 컴파일러 에러, 통과 못 한 루브릭 항목, 사람이 쓴 채점 근거 같은 것이다. 이 텍스트를 반성해 prompt를 고치면 train rollout 6~179회로 가중치 RL(24,000 rollout)의 최고 점수에 도달했다 ([[agent-evaluation]] §7, [[prompt-optimization]]). 단, 텍스트를 끄고 돌린 직접 비교는 논문에 없다.
- 사람은 eval을 직접 쓰지 않고 **보정**한다. 에이전트가 trace를 클러스터링해 judge를 만들고, 사람은 그 판정에 동의하는지만 답한다 ([[agent-evaluation]] §3b).
- 보상을 뒤집어 성능을 떨어뜨리는 지시문을 찾으면, 사고가 나기 **전에** 회귀 케이스를 만들 수 있다 ([[agent-evaluation]] §7).

### 2. 반복하던 확인은 skill로 옮긴다

사람이 반복하던 확인을 skill로 코드화하는 것은 system distillation 한 단계를 손으로 하는 것이다 ([[loop-engineering]]). prompt 층은 GEPA 같은 optimizer로 자동화할 수 있다. 다만 채점 함수가 먼저 있어야 돈다 ([[prompt-optimization]], [[agent-recipe]]).

**반성문은 그대로는 자산이 아니다.** [[2023-03-20-reflexion]]의 반성문은 과제 하나를 다시 시도할 때만 쓰이고, 최근 1~3개만 남는다. 쌓을 자산이 되려면 GEPA처럼 여러 인스턴스의 반성을 **과제 규칙**(지시문, skill)으로 증류해야 한다 ([[prompt-optimization]]). *(추론)*

### 3. trace를 버리지 않는다

두 번째 루프는 첫 루프의 trace·실패·사용자 불만을 signal로 받아 루프 자체를 고친다. 순서는 trace 패턴 → judge 보정 → recipe 후보 → offline eval → A/B → promote다 ([[loop-engineering]], [[inner-outer-loop-verification]]). signal의 품질이 루프의 성공률을 정한다. trace는 내용을 보지 않고 결정 패턴만 모니터링하는 방식으로도 쌓을 수 있다 ([[agent-evaluation]] §5, [[2025-06-13-multi-agent-research-system]]).

### 4. 능력 가정에는 유효기간을 단다 *(추론)*

harness 규칙을 쌓을 때는 **어떤 모델의 어떤 약점을 막으려는 규칙인지**를 함께 적는다. 모델을 바꿀 때 그 규칙을 끈 상태로 eval을 돌리면 아직 필요한지 판별할 수 있다. 1번의 eval suite가 이 판별 도구가 된다. context reset 사례([[meta-harness]])를 미리 잡아내는 장치다.

### 5. 쌓인 것은 지우지 않고 무효화한다 *(추론)*

쌓는 자산은 시간이 지나면 틀린 것이 섞인다. 사용자 정보가 바뀌고, eval 케이스가 변별력을 잃고, harness 규칙이 썩는다. 그때 **덮어쓰거나 지우지 말고 "언제부터 유효하지 않은지"를 표시**하는 편이 안전하다.

- memory에서 이 처방을 구현한 것이 Zep이다. 사실마다 참이었던 기간을 기록하고, 모순되는 새 사실이 오면 옛 사실을 지우지 않고 무효 표시한다. 원본에서 사실로, 사실에서 원본으로 거슬러 올라갈 수 있다 ([[agent-memory]] §3, [[2025-01-20-zep]]).
- 반대 설계는 A-MEM이다. 새 정보가 오면 기존 노트의 설명을 **덮어쓰고** 이전 버전은 남기지 않는다 ([[2025-02-17-a-mem]]). LongMemEval이 관측한 ChatGPT memory는 이력을 압축하며 정보를 바꿔 원문보다 37% 낮았다 ([[2024-10-14-longmemeval]]). 덮어쓰기는 잘못 갱신했을 때 되돌릴 근거가 없다.
- 두 방식은 같은 벤치마크로 비교된 적이 없다. 그래서 "무효화가 더 정확하다"는 근거는 없다. 근거가 있는 것은 **되돌릴 수 있다**는 성질뿐이다. 모델이 바뀌면 판정이 틀릴 수 있다는 1~4번의 전제에서는 그 성질이 값을 한다.

이 원칙은 이 위키 자체의 운영 원칙과 같다. `CLAUDE.md`는 모순을 조용히 덮어쓰지 말고 양쪽을 보존하라고 하고, `log.md`는 append-only이며, 모든 변경이 git에 남는다. 4번의 "능력 가정에 유효기간을 단다"도 같은 처방을 harness 규칙에 적용한 것이다. 규칙을 지우는 대신 **어느 모델까지 유효했는지**를 남긴다.

## 쌓을수록 커지는 위험

- **쌓인 것이 공격 표면이다.** persistent memory poisoning의 표적 목록에 `CLAUDE.md`와 장기 실행 에이전트의 state 디렉토리가 명시돼 있다. 커밋과 리뷰가 방어의 일부지만, 저자들은 그것만으로 부족하다고 본다 ([[artifact-chain]], [[prompt-injection]], [[2026-05-25-how-we-contain-claude]]).
- **comprehension debt.** 루프와 recipe가 매끄러울수록 시스템에 실제로 있는 것과 내가 아는 것의 간격이 빨리 벌어진다 ([[loop-engineering]]).

## 모순: taste를 recipe에 실을 수 있는가

> ⚠️ **Contradiction** ([[loop-engineering]]에 기록된 모순을 그대로 옮긴다)
> - Osmani: taste와 주관적 판단은 루프에 맞지 않는다. task는 위임하고 judgment는 되가져온다 ([[2026-06-07-loop-engineering]], [[2026-08-14-practical-loop-engineering]]).
> - Gavrilescu: taste를 eval로 코드화하는 것이 루프의 핵심이고, 사람은 보정만 한다 ([[2026-09-30-loop-is-the-product]]).
> - 판정 상태: **부분 화해, 미해결.** GEPA는 정답이 있는 과제에서 증류가 자동화된다는 것만 보였다. taste 영역의 데이터는 아니다 ([[loop-engineering]]).

이 모순은 이 페이지의 표 첫 행에 직접 걸린다. eval이 "누구나 같게 판정하는 기준"이면 가장 오래 사는 자산이다. eval이 "제작자의 taste"이면 그 수명은 taste를 코드로 옮길 수 있는지에 달려 있다. *(추론)*

## 적용: 이 위키 자체 *(추론)*

이 repo도 같은 구조다. `CLAUDE.md`와 skill 파일은 skill·prompt 층이고, hook은 검증 규칙이다. `log.md`와 `index.md`는 외부 state이고, `raw/`는 원본 trace에 해당한다. 비어 있는 칸은 **eval**이다. "ingest를 잘했는가"를 판정하는 채점 함수가 없다. 다음에 쌓을 것으로는 이것이 가장 유력하다.

## 빈틈

- ~~**장기 memory 시스템** 자체를 다룬 소스가 없다.~~ **부분적으로 채워짐 (2026-11-26):** [[2023-10-12-memgpt]]가 들어와 [[agent-memory]]가 생겼다. 무엇을 어떻게 저장하고 다시 가져오는가는 다룬다. 이후 LongMemEval(측정), Zep·A-MEM(갱신 구현)이 들어와 **갱신**과 **측정**은 채워졌다. **삭제**는 여전히 구현도 측정도 없다.
- **모델 간 전이의 근거가 얇다.** prompt 하나, 모델 두 개, 약한 모델에서 강한 모델 방향만 확인됐다. skill·harness profile·eval의 전이와 Claude 계열 데이터는 없다 ([[agent-recipe]]).
- **recipe를 묶음으로 도입한 전후 비교**도, eval suite가 시간이 지나며 변별력을 잃는 속도에 대한 수치도 없다. 변별력을 **지키는 설계** 하나(이력 길이를 늘릴 수 있는 벤치마크)는 [[2024-10-14-longmemeval]]로 생겼다. 벤치마크 전체가 낡은 사례 하나(DMR: 2023년 기준이 2025년엔 단순 baseline에 진다)는 [[2025-01-20-zep]]로 생겼다. 속도에 대한 수치는 여전히 없다.
- 채울 만한 소스 후보: agent memory 관련 논문이나 글, eval suite를 모델 교체에 걸쳐 유지한 실무 회고.

## Related

- [[agent-recipe]] — 이 페이지가 말하는 "쌓을 것"의 묶음 단위. 수명 순서 표의 출발점
- [[meta-harness]] — "능력 가정은 썩고 과제 규칙은 남는다"는 판별 기준의 출처
- [[agent-evaluation]] — 가장 오래 사는 자산인 eval을 어떻게 만들고 보정하는가
- [[prompt-optimization]] — prompt 층 증류의 자동화와 모델 간 전이 수치
- [[loop-engineering]] — 외부 state, 두 번째 루프, taste 모순
- [[artifact-chain]] — 산출물을 파일로 빼는 처방. 지속성은 공격 표면이기도 하다
- [[inner-outer-loop-verification]] — 바깥쪽 loop가 판단 기준을 검증하는 방식
- [[prompt-injection]] — 쌓인 state를 노리는 memory poisoning
- [[agent-memory]] — memory 내용과 memory 정책의 수명 차이. 능력 가정이 새 모델에서 해가 된 사례

## Sources

- [[2026-04-08-scaling-managed-agents]] — context anxiety 사례, 세션 로그를 창 밖에 두는 설계
- [[2025-07-25-gepa-reflective-prompt-evolution]] — prompt 증류, 텍스트 피드백, 모델 간 전이 +9%
- [[2026-09-30-loop-is-the-product]] — agent recipe, system distillation, 사람은 eval을 보정한다
- [[2026-06-07-loop-engineering]] — 외부 state ("The agent forgets, the repo doesn't"), taste 모순의 한쪽
- [[2026-08-14-practical-loop-engineering]] — task는 위임하고 judgment는 되가져온다
- [[2026-08-21-the-ai-native-sdlc-playbook]] — incident 하나당 eval 하나, eval을 CI에
- [[2026-05-25-how-we-contain-claude]] — persistent memory poisoning
- [[2025-06-13-multi-agent-research-system]] — production tracing과 관측성
- [[2023-10-12-memgpt]] — memory 계층, 능력 가정이 새 모델에서 거꾸로 작용한 사례 (2026-11-26)
- [[2023-03-20-reflexion]] — 모델의 강점에 올라타는 구조, 인스턴스용 반성문 (2026-11-26)
- [[2024-10-14-longmemeval]] — 원문 + 사실로 저장하기, 난이도를 늘릴 수 있는 eval, 판정자 대조 (2026-11-26)
- [[2025-01-20-zep]] — 무효화하되 지우지 않는 갱신(bi-temporal) (2026-11-26)
- [[2025-02-17-a-mem]] — 덮어쓰는 갱신의 반대 사례 (2026-11-26)
