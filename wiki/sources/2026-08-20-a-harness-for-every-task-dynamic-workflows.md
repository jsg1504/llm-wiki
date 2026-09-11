---
title: "A harness for every task: dynamic workflows in Claude Code"
type: source
created: 2026-09-12
updated: 2026-09-12
source_file: ../../raw/articles/2026-08-20-a-harness-for-every-task-dynamic-workflows.md
source_url: https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code
author: Thariq Shihipar, Sid Bidasaria
publisher: Anthropic / Claude Blog
source_date: 2026-08-20
tags: [claude-code, dynamic-workflows, agentic-harness, subagent, orchestration, multi-agent, token-economics]
status: mature
---

# A harness for every task: dynamic workflows in Claude Code

> harness를 사람이 만드는 것에서 **Claude가 태스크마다 즉석에서 쓰는 것**으로 옮긴다. 조정 로직은 LLM의 판단이 아니라 **결정론적 JavaScript 프로그램**이 들고 있고, 그 프로그램이 독립 context window를 가진 subagent들을 spawn·조율한다. 대가는 토큰이며, 저자들 스스로 *"대부분의 전통적 코딩 태스크는 리뷰어 5명 패널이 필요 없다"*고 선을 긋는다.

## Context

Claude Code 팀의 Thariq Shihipar와 Sid Bidasaria(Anthropic 기술 스태프)가 dynamic workflows 출시 직후 쓴 사용 가이드. 기능 발표가 아니라 **"내가 먼저 써보고 배운 것"**의 형식이며, 저자들이 *"best practices are still developing"*이라고 명시한다.

배경: Anthropic은 그간 Research, security analysis, agent teams, Code Review 같은 태스크마다 Claude Code 위에 **커스텀 harness를 손으로 만들어** 성능을 끌어올려 왔다. 기본 Claude Code harness는 코딩용으로 설계됐지만 *"많은 태스크가 알고 보면 코딩 태스크를 닮았기 때문에"* 다른 일에도 잘 통했다. 그러나 특정 부류의 태스크는 전용 harness가 필요했고, 그 harness를 사람이 미리 만들어야 한다는 것이 병목이었다.

이 위키 기준으로 이 소스는 **세 번째 소스이자 첫 번째 "에이전트가 에이전트를 조정하는 코딩 작업"의 실증**이다. [[multi-agent-systems]]에 2026-09-11부터 열려 있던 모순의 판정 근거가 된다.

## Key Claims

### 1. Harness 제작의 주체가 사람에서 Claude로 이동한다

Dynamic workflow는 Claude가 **JavaScript 파일을 즉석에서 작성·실행**해 subagent를 spawn하고 조율하는 것이다. 파일은 저장(`~/.claude/workflows`)하거나 skill에 담아 배포할 수 있고, 워크플로 메뉴에서 `s`를 눌러 저장한다. 트리거는 그냥 부탁하거나 `ultracode`라는 트리거 단어를 쓰는 것.

기존의 **static workflow**(Agent SDK나 `claude -p`로 여러 Claude Code 인스턴스를 엮는 것)와의 대비가 이 주장의 핵심이다:

> *"because static workflows need to work for all edge cases, they are usually more generic. With Claude Opus 4.8 and dynamic workflows, Claude is now intelligent enough to write a custom harness tailor-made for your use case."*

즉 **일회용 맞춤 harness가 재사용 범용 harness를 이긴다**는 주장이며, 그 전제는 모델이 harness를 직접 쓸 만큼 똑똑해졌다는 것이다. 워크플로는 JSON·Math·Array 같은 표준 JS 함수를 쓸 수 있고, **어떤 모델을 쓸지와 subagent를 각자의 worktree에서 돌릴지**를 워크플로가 결정할 수 있다. 중단되면(사용자 개입, 터미널 종료) 세션 재개 시 이어서 돈다.

### 2. 조정을 LLM 컨텍스트 밖 결정론적 코드로 옮긴다

이 소스에서 가장 중요하지만 명시적으로 강조되지 않은 구조적 사실. 조정 로직은 **에이전트의 판단이 아니라 JS 프로그램의 제어 흐름**에 있다. sorting 사례에서 저자가 직접 서술한다:

> *"Each comparison is its own agent, so the deterministic loop holds the bracket and only the running order stays in context."*

fan-out-and-synthesize의 synthesize 단계도 같다 — *"The synthesize step is a barrier—it waits for all the fan-out agents, then merges their structured outputs into one result."* barrier는 에이전트가 협상해서 만드는 것이 아니라 프로그램이 강제하는 것이다.

이것이 [[subagent]]에 정리된 병렬성 세 층위 어디에도 정확히 들어맞지 않는 **네 번째 범주**다. → [[dynamic-workflows]]

### 3. 단일 context window의 세 가지 실패 모드가 존재 이유다

기본 harness는 **계획과 실행을 같은 context window에서** 한다. 많은 코딩 태스크에는 이것이 효과적이지만, 길고 대규모 병렬이며 고도로 구조화되었거나 적대적인(adversarial) 태스크에서는 무너진다. 한 컨텍스트에서 오래 일할수록 세 가지가 나타난다:

| 실패 모드 | 원문 정의 | 예시 |
|---|---|---|
| **Agentic laziness** | 복잡한 다부분 태스크를 끝내기 전에 멈추고 부분 진척으로 완료를 선언 | 보안 리뷰 50개 항목 중 35개만 처리하고 종료 |
| **Self-preferential bias** | 자기 결과·발견을 선호하는 경향. **특히 루브릭에 비추어 스스로 검증·판정하라고 했을 때** | 자기가 만든 답을 자기가 채점 |
| **Goal drift** | 여러 턴에 걸쳐 원 목표에 대한 충실도가 점진적으로 상실됨. **특히 compaction 이후** | 요약이 lossy해서 엣지케이스 요건이나 *"don't do X"* 제약이 유실 |

워크플로는 *"각자의 context window와 집중된 격리 목표를 가진 별개의 Claude subagent를 오케스트레이션함으로써"* 이것들에 대응한다. 프롬프트로 달래는 것이 아니라 **구조로 막는다**는 점이 요지다.

### 4. 조합 가능한 여섯 가지 오케스트레이션 패턴

Claude가 워크플로를 만들 때 쓰고 서로 조합하는 패턴들. 상세는 [[agent-orchestration-patterns]].

| 패턴 | 한 줄 |
|---|---|
| **Classify-and-act** | 분류 에이전트가 태스크 유형을 정하고 그에 따라 라우팅. 또는 끝단에서 출력을 결정 |
| **Fan-out-and-synthesize** | 잘게 쪼개 각각 에이전트를 돌리고 종합. synthesize는 **barrier** |
| **Adversarial verification** | spawn된 에이전트마다 별도 에이전트가 루브릭에 비추어 **적대적으로** 검증 |
| **Generate-and-filter** | 아이디어를 다수 생성 → 루브릭·검증으로 거르고 중복 제거 → 최상위만 반환 |
| **Tournament** | 일을 나누지 않고 **경쟁시킨다.** N개 에이전트가 서로 다른 접근으로 같은 태스크를 시도, 판정 에이전트가 pairwise로 우승자를 가림 |
| **Loop until done** | 작업량을 모를 때 고정 패스 수 대신 **정지 조건**(새 발견 없음, 로그에 에러 없음)까지 반복 spawn |

### 5. 코딩보다 비코딩에서 더 유용할 때가 많다

> *"I've found that workflows are sometimes even more useful for non-technical work."*

제시된 사용 사례 아홉 가지:

- **Migrations and refactors** — **Bun이 Zig에서 Rust로 재작성된 것이 워크플로를 통해서였다.** 방법: 태스크를 조작 단위(callsite, 실패 테스트, 모듈)로 쪼개고, 수정마다 worktree에서 subagent를 띄우고, 별도 에이전트가 적대적으로 리뷰한 뒤 머지. 팁 — 리소스 집약적 명령을 쓰지 말라고 지시해야 머신 자원 고갈 없이 최대 병렬화가 된다.
- **Deep research** — Claude Code의 `/deep-research` skill이 dynamic workflow로 구현되어 있다. 웹 검색을 fan-out → 소스 fetch → 주장을 적대적으로 검증 → 인용된 리포트로 종합. 웹 검색만이 아니라 Slack 컨텍스트에서 상태 리포트를 만들거나 코드베이스를 깊이 탐색하는 데도 같은 구조.
- **Deep verification** — 리포트의 모든 사실 주장을 에이전트 하나가 식별하고, 주장마다 subagent를 띄워 상세 확인. 검증 에이전트가 소스 subagent의 출처 품질까지 확인할 수 있다.
- **Sorting** — 정성적 기준(예: 버그 심각도순 지원 티켓)으로 정렬. 1000+ 행을 한 프롬프트에 넣으면 품질이 저하되고 컨텍스트에도 안 들어간다. 대신 tournament, pairwise 비교 에이전트 파이프라인, 또는 병렬 bucket-rank 후 머지. 근거: **비교 판단이 절대 점수보다 신뢰도가 높다**(*"comparative judgment is more reliable than absolute scoring"*).
- **Memory and rule adherence** — `CLAUDE.md`에 넣어도 Claude가 놓치는 규칙들에 대해, **규칙 하나당 verifier 에이전트 하나**를 두는 워크플로. false positive를 막으려면 **skeptic 페르소나 subagent**가 규칙 자체를 검토하게 한다. 역방향도 된다 — 최근 세션과 코드 리뷰 코멘트에서 반복되는 교정을 채굴하고, 병렬 에이전트로 클러스터링하고, 후보마다 적대적으로 검증한 뒤(*"이 규칙이 실제 실수를 막았겠는가?"*) 살아남은 것만 `CLAUDE.md`로 증류.
- **Root-cause investigation** — 디버깅은 독립 가설을 여럿 세워 검증할 때 잘 되지만 단일 컨텍스트에서는 self-preferential bias에 걸린다. 워크플로는 **서로 겹치지 않는(disjoint) 증거**에서 가설을 만드는 에이전트들(로그 담당, 파일 담당, 데이터 담당)을 띄우고, 각 가설이 검증자·반박자 패널을 거치게 한다. 코드만이 아니라 세일즈(3월 매출이 왜 떨어졌나), 데이터 엔지니어링(파이프라인이 왜 실패했나), 포스트모템 전반에 적용된다.
- **Triaging at scale** — 분류 → 이미 추적 중인 것과 중복 제거 → 수정 시도 또는 사람에게 에스컬레이션. **quarantine 패턴**: 신뢰할 수 없는 공개 콘텐츠를 읽는 에이전트가 고권한 행동을 하지 못하게 막고, 행동은 정보를 처리하는 별도 에이전트가 한다. `/loop`와 묶으면 상시 운영.
- **Exploration and taste** — 디자인·네이밍처럼 취향 기반이고 루브릭의 이득이 큰 영역. 여러 해법을 탐색시키고 리뷰 에이전트에 "좋은 해법이란 무엇인가" 루브릭을 준다. 리뷰 에이전트가 기준 충족을 인정하면 완료.
- **Evals** — worktree에서 에이전트를 띄워 결과를 만들고, 비교 에이전트가 루브릭에 비추어 채점. 예: 내가 만든 skill을 특정 기준으로 평가·개선.
- **Model and intelligence routing** — 분류 에이전트가 **어떤 모델을 쓸지** 결정. *"auth 모듈이 어떻게 동작하는지 설명해"*의 최적 모델은 auth 모듈의 파일 수와 코드베이스 형태에 달려 있고, 분류 에이전트가 그 조사를 한 뒤 Sonnet이나 Opus로 라우팅한다.

### 6. 쓰지 말아야 할 때 — 경제성 판단은 유지된다

> *"Workflows are new. While there are many use cases where it will create outsized results, they are not needed for every task and may end up using significantly more tokens."*
>
> *"For regular coding tasks, try and ask yourself: does it really need more compute? For example, most traditional coding tasks do not need a panel of 5 reviewers."*

그리고 본문이 스스로 아키텍처 층위로 일반화한다 — multi-agent vs single agent 결정도 같은 논리를 따르며, **병렬성과 전문화는 자신의 조정 비용을 벌어야 한다**(*"parallelism and specialization have to earn their coordination cost"*).

통제 수단으로 **명시적 토큰 예산**이 있다. *"use 10k tokens"*처럼 프롬프트에 쓰면 상한이 걸린다. 또 워크플로가 대형 태스크 전용은 아니어서 *"quick workflow"*(예: 어떤 가정에 대한 빠른 적대적 리뷰)를 요청할 수도 있다.

### 7. 반복 가능한 워크플로는 `/loop`·`/goal`과 묶는다

triage, research, verification처럼 반복되는 워크플로는 `/loop`로 정기 실행하고, `/goal`로 하드한 완료 요건을 건다.

## Notable Quotes / Passages

> "Claude can now write its own harness on the fly, custom-built for the task at hand."

> "Each comparison is its own agent, so the deterministic loop holds the bracket and only the running order stays in context."

> "**Self-preferential bias** refers to Claude's tendency to prefer its own results or findings, especially when asked to verify or judge them against a rubric."

> "Each summarization step is lossy, and details like edge-case requirements or 'don't do X' constraints can get lost."

> "I've found that workflows are sometimes even more useful for non-technical work."

> "most traditional coding tasks do not need a panel of 5 reviewers"

> "comparative judgment is more reliable than absolute scoring"

> "parallelism and specialization have to earn their coordination cost"

## Connections

- **새로 만든 페이지:** [[dynamic-workflows]] (개념·실패모드·경제성), [[agent-orchestration-patterns]] (6패턴 카탈로그)
- **모순 판정에 결정적:** [[multi-agent-systems]]의 *"코딩은 멀티에이전트에 맞는가"*. 이 소스가 적합성/경제성 두 축을 분리한다.
- **병렬성 층위를 확장:** [[subagent]]의 3층위 표에 "결정론적 harness가 조정" 행이 추가된다.
- **도구 차원의 구현:** [[claude-code]] — dynamic workflows, `ultracode`, `/deep-research`, `~/.claude/workflows`
- **평가 원리 보강:** [[agent-evaluation]] — pairwise > absolute, adversarial verification, skeptic 페르소나
- **아키텍처 원리와의 관계:** [[orchestrator-worker]] — fan-out-and-synthesize는 이 패턴의 일반화된 형태이고, loop-until-done은 "고정 패스 수" 한계의 완화책이다.
- **거버넌스:** [[agentic-governance]] — quarantine 패턴
- **코딩 도메인 적용:** [[ai-native-sdlc]] — 마이그레이션·리팩터, 리뷰 pass

## My Notes

- **저자가 강조하지 않은 것이 가장 중요했다.** 글의 무게중심은 "이런 것도 할 수 있다"(사용 사례 9개)에 있지만, 이 위키 입장에서 값진 것은 조정 주체가 결정론적 코드라는 구조적 사실이다. 이것이 1년 넘게 열려 있던 *"LLM agents are not yet great at coordinating and delegating to other agents in real time"*을 **반박하지 않고 우회한다.**
- **자기 경고를 포함한 소스다.** 기능 홍보 글이면서도 "대부분의 코딩 태스크엔 필요 없다", "토큰을 훨씬 더 쓴다", "best practices are still developing"을 직접 쓴다. [[multi-agent-systems]]의 15x 토큰 판단과 충돌하지 않고 보강한다.
- **검증되지 않은 수치가 없다는 점은 양날이다.** 이 소스는 [[2025-06-13-multi-agent-research-system]]과 달리 **정량 데이터를 전혀 제시하지 않는다.** 성능 비교, 토큰 실측, 성공률이 없다. Bun 재작성도 외부 X 스레드 링크로만 언급된다. 따라서 이 소스의 주장은 **경험 보고이지 측정이 아니다.** 위키에 반영할 때 이 차이를 흐리지 않아야 한다.
- **여전히 Anthropic 발행이다.** 이 위키의 소스 3개가 모두 Anthropic이다. [[anthropic]]의 편향 추적 항목이 유효하다.

## Raw Source

[원본 파일](../../raw/articles/2026-08-20-a-harness-for-every-task-dynamic-workflows.md) · [claude.com/blog](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
