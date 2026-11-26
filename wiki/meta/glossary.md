---
title: Glossary
type: meta
created: 2026-04-28
updated: 2026-11-27
status: draft
---

# 📖 Glossary

> 이 위키 안에서 일관되게 쓰는 용어 정의. 너무 짧아서 자기 페이지를 가질 정도는 아닌 용어들의 모음. 어떤 용어가 자주 인용되기 시작하면 자기 페이지로 승격(`wiki/concepts/`).

## 위키 내부 용어

- **raw source** — `raw/` 아래의 원본 파일. 절대 수정 금지.
- **wiki page** — `wiki/` 아래의 LLM이 작성/유지하는 마크다운 파일. 5가지 type: entity, concept, topic, source, synthesis (+ meta).
- **wikilink** — `[[page-name]]` 형식의 위키 내부 참조.
- **stub** — frontmatter `status: stub`. 1~2 문장만 있는 미완성 페이지.
- **mature** — frontmatter `status: mature`. 다수 출처로 검증되어 안정적으로 인용 가능.
- **orphan** — 어떤 페이지로부터도 wikilink되지 않는 페이지. lint에서 식별.
- **hub** — inbound link가 많은 페이지. 위키의 "허브".
- **contradiction marker** — `> ⚠️ **Contradiction (YYYY-MM-DD): <질문>.**` blockquote. 페이지 간 모순을 명시할 때 사용. 등록 목록은 [[contradictions]].

## 에이전트 용어

- **harness** — 모델을 감싸고 *무엇을 언제 할지*를 정하는 바깥 껍질. Claude를 호출하는 루프, tool call 라우팅, 컨텍스트 관리 규칙. [[claude-code]]도 [[dynamic-workflows]]가 쓴 프로그램도 harness다.
- **meta-harness** — 특정 harness에 의견을 갖지 않고 그 **주변 인터페이스**만 고정하는 설계. → [[meta-harness]]
- **brain / hands / session** — 에이전트를 셋으로 가른 분할. brain = 모델과 그 harness, hands = sandbox와 도구, session = 이벤트 로그. 셋이 독립적으로 실패·교체된다.
- **pets vs cattle** — 인프라 유비. pet은 이름 붙여 손으로 돌보는, 잃으면 안 되는 개체. cattle은 교체 가능한 개체. 판별법: *그것이 죽으면 무엇이 같이 사라지는가.*
- **TTFT** (time-to-first-token) — 작업을 받고 첫 응답 토큰을 내기까지의 지연. 사용자가 가장 예민하게 느끼는 지연 지표.
- **context anxiety** — 모델이 컨텍스트 한계가 다가오는 것을 감지하고 작업을 조기 종료하는 행동. Sonnet 4.5에서 관측됐고 Opus 4.5에서 사라졌다. harness 가정이 노후화하는 대표 사례.
- **virtual context management** — context window를 운영체제의 RAM으로, 외부 저장소를 디스크로 보고 정보를 페이지처럼 넣고 빼서 고정 길이 context로 더 긴 context의 환상을 만드는 기법. MemGPT의 용어. → [[agent-memory]]
- **main context / external context** — MemGPT의 두 메모리 층. main context는 prompt token(system instructions, working context, FIFO queue)이라 모델이 바로 본다. external context(recall storage, archival storage)는 context 밖이라 함수로 가져와야 보인다.
- **memory pressure** — prompt가 context window의 일정 비율(MemGPT 예시 70%)을 넘을 때 모델에게 보내는 경고. 모델이 중요한 정보를 밖에 저장하도록 유도한다. context anxiety와 같은 신호를 반대로 쓴 사례다.
- **verbal reinforcement (언어 강화)** — 가중치를 바꾸지 않고, 실패에 대한 자연어 반성문을 memory에 넣어 다음 시도를 개선하는 것. Reflexion의 용어. 저자들은 반성문을 "semantic gradient"라 부른다. → [[2023-03-20-reflexion]], [[prompt-optimization]]
- **episodic memory** — 이 위키에서는 과거 시도(trajectory)나 그 시도에서 얻은 교훈을 담는 memory를 가리킨다. 사실을 담는 memory(MemGPT의 working context)와 구분한다. → [[agent-memory]]
- **knowledge update** — 사용자 정보가 바뀐 것을 알아채고 memory를 갱신하는 능력. LongMemEval의 다섯 능력 중 하나다. 재는 방법은 LongMemEval이, 구현하는 방법은 Zep(무효화)과 A-MEM(덮어쓰기)이 준다. 두 방식을 비교한 소스는 없다. → [[agent-memory]]
- **abstention** — memory에 없는 것을 물으면 지어내지 않고 모른다고 답하는 능력. LongMemEval은 기존 질문을 거짓 전제 질문으로 바꿔 잰다.
- **key expansion (document expansion)** — memory 항목을 색인할 때 원문에 요약·사실·keyphrase를 이어 붙여 key로 쓰는 것. LongMemEval에서는 원문 + 사용자 사실이 recall@k +9.4%였다. 압축본만 key로 쓰면 나아지지 않았다.
- **bi-temporal** — 사실에 시간 축 둘을 붙이는 모델. 사실이 실제로 참이었던 기간(t_valid, t_invalid)과 시스템이 그 사실을 받아들이고 무효화한 시점(t′_created, t′_expired)을 따로 기록한다. Zep의 용어. → [[agent-memory]]
- **edge invalidation** — 새 사실이 기존 사실과 모순될 때 기존 사실을 지우지 않고 t_invalid만 설정해 무효 표시하는 갱신 방식. 이전 상태가 남아 되돌릴 수 있다. → [[2025-01-20-zep]]
- **memory evolution** — 새 memory가 들어오면 가까운 기존 memory의 설명·keyword·tag를 LLM이 다시 쓰는 갱신 방식. 이전 버전은 남지 않는다. A-MEM의 용어. → [[2025-02-17-a-mem]]
- **Zettelkasten** — 원자적인 노트를 만들고 노트끼리 자유롭게 링크해 지식망을 키우는 메모 방법. A-MEM이 memory 구조로 빌렸고, 이 위키의 wikilink 구조도 같은 계열이다.
- **능력 가정 / 과제 규칙** — harness나 prompt에 들어간 규칙을 가르는 두 종류. 능력 가정은 *"모델은 X를 못 한다"* 는 진술이라 모델이 좋아지면 썩는다(예: context anxiety를 막는 reset). 과제 규칙은 과제 자체에 대한 지시라 모델을 바꿔도 남는다(예: GEPA prompt의 모델 간 전이 +9%). 모델 밖에 무엇을 쌓을지 고르는 기준이다. 이 구분은 위키가 붙인 것이고 소스의 용어가 아니다. → [[meta-harness]], [[what-to-accumulate-outside-the-model]]
- **context rot** — 입력이 길어질수록 모델 품질이 떨어지는 현상. 열화 속도는 과제가 요구하는 처리량에 달렸다. 바늘 하나 찾기(O(1))는 1M token에서도 버티고, 쌍마다 집계하는 과제(O(n²))는 창 안에서도 무너진다. → [[recursive-language-model]], [[context-and-memory]]
- **compaction 처방 (a)~(d)** — context window를 넘길 때의 네 처방. (a) 잘 요약한다, (b) 도달하지 않는다(subagent 격리), (c) 되돌릴 수 있게 한다(원본을 창 밖 로그에), (d) 애초에 넣지 않는다(REPL 변수). 함께 쓰인다. 이 분류는 위키가 붙인 것이다. → [[meta-harness]], [[context-and-memory]]
- **RLM (Recursive Language Model)** — 긴 입력을 REPL 변수로 두고, 모델이 코드로 그 변수를 잘라 읽으며 코드 안에서 자기 자신을 재귀 호출하는 추론 scaffold. 바깥에서 보면 문자열을 받아 문자열을 내는 LM이다. → [[recursive-language-model]]
- **recursion depth** — RLM에서 하위 호출이 다시 자기 REPL을 띄울 수 있는 깊이. depth=0은 하위 호출 없음, depth=1은 하위 호출이 일반 LM, depth≥2는 하위 호출도 RLM. 원 논문과 재현 모두 깊이가 늘면 대체로 나빠졌다(원 논문 GPT-5는 예외). → [[recursive-language-model]]
- **말로 하는 위임 / 코드로 하는 위임** — 하위 호출을 부모 LLM이 하나씩 생성해 내는가(orchestrator-worker, Claude Code subagent), 코드 루프 안에서 내는가(RLM). 앞쪽은 위임 수가 부모의 출력 길이에 묶인다. 이 구분은 위키가 붙인 이름이다. → [[subagent]]
- **overthinking (RLM)** — 깊은 재귀에서 하위 호출이 끝없이 재검증하거나, 입력을 버리고 사전지식으로 답하거나(context anchoring 상실), REPL 코드를 최종 답으로 내는 실패 모드. RLM 재현 논문의 용어. → [[2026-03-03-reproducing-recursive-language-models]]
- **quarantine** — 신뢰할 수 없는 콘텐츠를 읽는 에이전트에게 고권한 행동을 주지 않고, 행동은 별도 에이전트가 하게 하는 패턴. 무력화가 아니라 트레이드오프다(trust escalation). → [[agentic-governance]]
- **system distillation / agent recipe** — 루프가 낸 교훈(실패 패턴, 반복 행동, 사용자 불만)을 judge·eval·skill·prompt·harness 설정으로 증류하는 **과정**이 system distillation이고, 그 결과를 git에 버전 관리한 **묶음**이 agent recipe다. 모델이나 제공자에 묶이지 않는다. → [[agent-recipe]]
- **valued work per watt** — 에이전트 제품의 최적화 점수로 제안된 구호. 작업이 가치 있는가, 그 경제성이 맞는가의 두 단계. 측정 방법은 정의되지 않았다. → [[2026-09-30-loop-is-the-product]]
- **inner loop / outer loop** — 두 뜻이 있다. (1) 루프 엔지니어링: inner loop는 태스크를 수행하며 결과물을 내는 worker 루프이고, outer loop는 그 산출물을 signal로 되먹여 eval·skill·prompt를 고치는 루프다. 위키는 이것을 첫 번째/두 번째 루프로 기록한다. "outer loop"라는 말은 소스에 없고 위키가 대응시킨 것이다. → [[loop-engineering]], [[inner-outer-loop-verification]] (2) 소프트웨어 개발: inner loop는 개발자의 edit-build-test 순환, outer loop는 CI·리뷰·배포다. → [[agentic-governance]]
- **agentic system / workflow / agent** — [[2024-12-19-building-effective-agents]]의 구분. 둘 다 agentic system이다. **workflow**는 LLM과 도구가 미리 정한 코드 경로로 조율되고, **agent**는 LLM이 자기 과정과 도구 사용을 동적으로 지휘한다. 이 위키는 이분법보다 "제어 흐름의 어느 부분을 누가 쥐는가"의 연속선으로 읽는다. → [[agent-fundamentals]]
- **augmented LLM** — retrieval, tools, memory로 강화된 LLM. agentic system의 바닥 단위다. → [[agent-fundamentals]]
- **agent loop** — 한 실행 안에서 도는 thought → action → observation 루프. thought는 환경을 바꾸지 않고 context만 갱신한다. 실행 *사이*를 설계하는 [[loop-engineering]]과 구분한다. → [[agent-loop]]
- **ReAct** — 추론(thought)과 행동(action)을 번갈아 내게 하는 prompting 방식. 행동 공간에 언어를 더한다(Â = A ∪ L). agent loop의 원전이다. → [[2022-10-06-react]]
- **Toolformer** — 모델이 API 호출 후보를 스스로 만들고, 뒤 토큰 loss를 줄인 호출만 남겨 fine-tuning하는 방법. tool use를 가중치에 넣는 쪽의 이른 사례다. → [[2023-02-09-toolformer]], [[tool-use]]
- **ACI** (agent-computer interface) — 에이전트가 쓰는 도구의 정의·인자·형식. *"HCI에 들이는 만큼 ACI에 들여라."* → [[tool-use]]
- **poka-yoke** — 실수하기 어렵게 만드는 설계. 도구 맥락에서는 모델이 틀리기 어렵게 인자를 바꾸는 것(예: 상대 경로 대신 항상 절대 경로). → [[tool-use]]
- **evaluator-optimizer** — 한 호출이 생성하고 다른 호출이 평가·피드백하는 반복 workflow. 판정자 분리의 이른 판본이다. → [[agent-evaluation]]

## 보안 용어

- **blast radius** — 에이전트가 최악의 경우 입힐 수 있는 피해의 범위. 실패 *확률*과 달리 능력·접근 권한이 늘수록 커지기만 한다. → [[agent-containment]]
- **containment** — 에이전트가 무엇을 *하는지* 감독하는 대신 무엇을 할 수 *있는지*를 환경 층위에서 상한 짓는 것.
- **direct / indirect prompt injection** — 공격자 지시가 **사용자를 통해** 오면 direct, 도구 출력·파일·웹 콘텐츠를 타고 오면 indirect. direct는 모델 층위가 못 잡는다(잡을 이상 징후가 없다). → [[prompt-injection]]
- **capability grant** — allowlist를 읽는 올바른 방식. 도메인을 허용한다는 것은 **그 도메인 뒤의 모든 기능**을 허용한다는 뜻이다. 목적지 필터가 아니다.
- **memory poisoning** — 세션을 넘어 지속되는 컨텍스트(`CLAUDE.md`, product memory, state 디렉토리)에 injection이 착륙해 **매 시작마다 다시 로드되는** 것.
- **trust escalation** — subagent 출력이 "우리 것"이라는 이유로 raw tool result보다 높은 신뢰를 받을 때 생기는 벡터. 격리가 세탁이 된다.
- **approval fatigue (승인 피로)** — 권한 프롬프트를 많이 볼수록 각각에 덜 주의하게 되는 현상. 측정값: 승인율 약 93%.
- **egress control** — 에이전트 환경에서 **나가는** 트래픽의 통제. 두 주요 인시던트가 모두 egress였다.
- **pets vs cattle** → 위 에이전트 용어 절 참조. containment에서는 *"컨테이너가 죽으면 무엇이 같이 죽는가"* 로 쓰인다.

## 작업 종류
- **ingest** — 새 raw source를 읽고 위키에 통합하는 작업.
- **query** — 위키에 질문하는 작업. 의미 있는 답변은 synthesis로 저장 가능.
- **lint** — 위키 건강 검진.
- **curate** — 위키를 더 좋게 정리하는 작업 (rename, merge, split 등).

---

이 글로사리는 시간이 지나며 늘어난다. 새 용어가 쓰이기 시작하면 추가.
