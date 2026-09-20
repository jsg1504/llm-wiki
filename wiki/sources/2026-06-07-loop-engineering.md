---
title: Loop Engineering
type: source
created: 2026-09-21
updated: 2026-09-21
source_file: ../../raw/articles/2026-06-07-loop-engineering.md
source_url: https://addyosmani.com/blog/loop-engineering/
author: Addy Osmani
source_date: 2026-06-07
tags: [loop-engineering, agentic-workflows, agent-harness, automations, worktrees, agent-skills, subagents, mcp, claude-code, codex, verification, external-perspective]
status: mature
---

# Loop Engineering

> 프롬프트를 잘 쓰는 능력이 아니라 **프롬프트를 대신 던지는 루프를 설계하는 능력**으로 레버리지가 옮겨갔다. 루프는 다섯 개의 primitive와 하나의 외부 state로 이루어지며, Codex와 Claude Code가 이름만 다르게 같은 다섯을 이미 다 갖췄다. 단, 저자는 낙관하지 않는다 — 검증 책임과 이해의 부채는 루프가 좋아질수록 커진다.

## Context

Addy Osmani의 개인 블로그 글(2026-06-07). **이 위키에 들어온 첫 비-[[anthropic]] 소스**이자, Codex와 Claude Code를 대칭으로 놓고 본 첫 소스다.

> ℹ️ 저자는 Google에서 Chrome 개발자 경험을 이끄는 엔지니어링 리더로 알려져 있으나, **이 소스 본문에 소속 표기는 없다.** 이 위키에 기록되는 것은 "벤더가 아닌 외부 실무자의 관찰"이라는 위치뿐이다.

글의 출발점은 두 개의 인용이다. Peter Steinberger — *"You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents."* 그리고 Claude Code 책임자 Boris Cherny — *"I don't prompt Claude anymore. I have loops running that prompt Claude and figuring out what to do. My job is to write loops."*

저자는 이 주장을 소개하면서도 **거리를 둔다.** 첫 문단부터 *"its still early, I'm skeptical and you absolutely* have *to be careful about token costs"* 라고 쓰고, 마지막 절에서 다시 *"프롬프팅도 여전히 효과적이다, 균형의 문제"* 로 돌아온다. 이 위키의 다른 소스들이 대체로 처방을 제시하는 글인 반면, 이 소스는 **처방 + 그 처방에 대한 유보**의 구조다.

글은 저자 자신의 인접 글들을 계속 참조한다 — agent harness engineering, factory model, long-running agents, orchestration tax, agent skills, intent debt, code agent orchestra, agentic code review, comprehension debt, cognitive surrender, code review in the age of AI. 즉 **하나의 연재 안의 한 편**이며, 이 위키는 그중 이 한 편만 갖고 있다.

## Key Claims

1. **루프는 harness보다 한 층 위다.** 저자의 표현 그대로: *"Loop engineering sits one floor above the harness."* Harness는 에이전트 하나가 그 안에서 도는 환경이고, 루프는 *"the harness but it runs on a timer, it spawns little helpers, and it feeds itself."* → [[loop-engineering]], [[meta-harness]]

2. **루프에는 다섯 개의 primitive와 하나의 state가 필요하다.** automations(스케줄 기반 discovery·triage) / worktrees(병렬 격리) / skills(프로젝트 지식 기록) / plugins·connectors(실제 도구 접근) / sub-agents(제안자와 검증자 분리). 여섯 번째는 **대화 밖에 사는 메모리** — 마크다운 파일이든 Linear 보드든. *"The agent forgets, the repo doesnt."*

3. **도구 선택은 더 이상 논점이 아니다.** 1년 전이면 bash 더미를 직접 쌓아 영원히 유지해야 했지만 *"Now the pieces just ship inside the products."* Codex와 Claude Code 양쪽에 다섯 개가 전부 있으므로, *"you stop arguing about which tool, you just design a loop that still works no matter which one you happen to be sitting in."*

4. **정지 조건의 판정자도 분리해야 한다.** `/loop`는 주기적으로 재실행하고, `/goal`은 **조건이 참이 될 때까지** 계속하되 매 턴 후 **별도의 작은 모델**이 완료 여부를 판정한다 — *"so the agent that wrote the code isnt the one grading it."* 두 도구 모두 `/goal`을 같은 이름으로 갖고 있다. → [[agent-evaluation]]

5. **skill은 저작 포맷이고 plugin은 배포 수단이다.** 둘 다 `SKILL.md`를 쓰는 폴더 구조이며, Codex는 `$name`이나 `/skills`로 호출하거나 description이 매칭되면 자동 호출한다 — *"wich is the reason a tight boring description beats a clever one."* 여러 repo에 공유하려면 plugin으로 묶는다. Codex와 Claude Code 양쪽에서 같다.

6. **skill이 없으면 루프는 매 사이클마다 프로젝트를 처음부터 재추론한다.** 에이전트는 매 세션 차갑게 시작하고 의도의 구멍을 자신 있는 추측으로 메운다("intent debt"). Skill은 그 의도를 바깥에 한 번 적어두는 것 — 컨벤션, 빌드 스텝, *"we dont do it like this because of that one incident."* 그래야 루프가 **누적**된다.

7. **반대급부 세 가지는 루프가 좋아질수록 커진다.** (a) **검증은 여전히 사람 몫이다** — 감독 없이 도는 루프는 감독 없이 실수하는 루프이기도 하고, verifier를 분리해도 *"'done' is a claim and not a proof."* (b) **이해가 썩는다** — 루프가 빨리 짤수록 존재하는 것과 내가 아는 것의 간격이 벌어진다(comprehension debt). (c) **편안한 자세가 위험하다** — 루프가 알아서 돌면 의견 갖기를 그만두고 나온 걸 그대로 받게 된다(cognitive surrender).

8. **같은 루프가 사람에 따라 정반대 결과를 낸다.** *"One uses it to move faster on work they understand deeply. The other uses it to avoid understanding the work at all. The loop doesn't know the difference. You do."* 저자의 결론은 루프 설계가 프롬프트 엔지니어링보다 **쉬워진 게 아니라 어려워졌다**는 것이다 — *"It's that the leverage point moved."*

## 다섯 primitive 대응표 (소스 원문)

| Primitive | 루프에서의 역할 | Codex app | Claude Code |
|---|---|---|---|
| **Automations** | 스케줄 기반 discovery + triage | Automations 탭: 프로젝트·프롬프트·주기·환경 선택, 결과는 Triage inbox로, `/goal`로 완료까지 실행 | 스케줄 태스크와 cron, `/loop`, `/goal`, hooks, GitHub Actions |
| **Worktrees** | 병렬 기능 격리 | thread마다 내장 worktree | `git worktree`, `--worktree`, subagent의 `isolation: worktree` |
| **Skills** | 프로젝트 지식 코드화 | Agent Skills (`SKILL.md`), `$name` 또는 암묵 호출 | Agent Skills (`SKILL.md`) |
| **Plugins / connectors** | 실제 도구 연결 | Connectors(MCP) + 배포용 plugin | MCP 서버 + plugin |
| **Sub-agents** | 제안과 검증의 분리 | `.codex/agents/`의 TOML 정의 | `.claude/agents/`의 Task subagent, agent teams |
| **State** | 무엇이 끝났는지 추적 | 마크다운 또는 connector 경유 Linear | 마크다운(`AGENTS.md`, progress 파일) 또는 MCP 경유 Linear |

소스는 Codex 쪽에 subagent 정의의 세부를 하나 더 준다 — name·description·instructions와 **선택적 model·reasoning effort**. 그래서 *"your security reviewer can be a strong model on high effort while your explorer is some fast read-only thing."*

## 저자가 제시한 루프 하나

> An automation runs every morning on the repo. Its prompt calls a triage skill that reads yesterdays CI failures, the open issues, the recent commits, and writes the findings into a markdown file or a Linear board. For each finding that is worth doing the thread opens an isolated worktree and sends a sub-agent to draft the fix, and a second sub-agent reviews that draft against the project skills and the existing tests.

Connector가 PR을 열고 티켓을 갱신한다. 루프가 처리 못 한 것만 triage inbox로 사람에게 온다. **state 파일이 척추다** — 무엇을 시도했고 무엇이 통과했고 무엇이 남았는지를 기억하므로 내일 아침 실행이 오늘 멈춘 자리에서 이어간다.

*"You designed it one time. You did not prompt any of those steps."*

## Notable Quotes

> Loop engineering is replacing yourself as the person who prompts the agent. You design the system that does it instead.

> Loop engineering sits one floor above the harness. The harness but it runs on a timer, it spawns little helpers, and it feeds itself.

> The agent forgets, the repo doesnt.

> A loop running unattended is also a loop making mistakes unattended.

> Designing the loop is the cure when you do it with judgement and the accelerant when you do it to avoid thinking, same action, opposite result.

> Build the loop. But build it like someone who intends to stay the engineer, not just the person who presses go.

## Connections

- 중심 개념은 [[loop-engineering]]. 이 소스가 그 페이지의 1차 출처다.
- [[meta-harness]]·[[dynamic-workflows]]가 만든 harness 층위 논의에 **세 번째 층**을 얹는다.
- [[agent-evaluation]]의 *"판정자는 산출물을 만든 에이전트와 분리되어야 한다"* 를 **정지 조건**에까지 적용한 사례(`/goal`).
- [[agent-orchestration-patterns]]의 loop-until-done(#6)과 adversarial verification(#3)이 제품 기능으로 결합된 모습.
- [[claude-code]]의 `/loop`·`/goal`·worktree·skill·plugin·MCP를 **외부 관찰자 시점**에서 다시 기술한다.
- [[subagent]]의 maker/checker 분리 논거를 벤더 밖에서 재확인한다.
- [[anthropic]] — 이 위키 최초의 비-Anthropic 소스로서, 그 페이지의 편향 추적 노트를 갱신하는 근거.

## My Notes

- **이 소스의 가장 큰 기여는 다섯 primitive 목록이 아니라 층위다.** 위키는 그동안 *한 번의 실행 안에서 누가 조정하는가*(사람 / lead agent / 프로그램 / 플랫폼)만 다뤘고, **실행과 실행 사이를 무엇이 잇는가**(cadence + 디스크 state)는 비어 있었다. 이 소스가 그 자리를 채운다.
- **`/goal` 항목은 이 위키에 이미 있는 주장과 정확히 맞물린다.** [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]가 self-preferential bias 때문에 판정자를 분리하라고 했고, 이 소스는 그 원리가 *"끝났는가"* 라는 메타 판정에까지 제품 기능으로 구현됐음을 보고한다. 벤더가 아닌 쪽에서 나온 확인이라는 점에 값이 있다.
- **정량 데이터는 없다.** 대응표는 기능 존재 여부이지 성능 비교가 아니고, 토큰 비용도 *"usage patterns can vary wildly"* 라는 정성 경고에 그친다. 이 점에서 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]와 같은 급(경험 보고)이고 [[2026-05-25-how-we-contain-claude]]보다 훨씬 얇다.
- **외부 소스이지만 독립 검증은 아니다.** 저자는 두 벤더의 제품 문서와 X 포스트를 읽고 정리했지, 스스로 측정하지 않았다. "외부 관점 부재"를 메우는 정도는 **관점**의 층위이고 **증거**의 층위가 아니다. [[anthropic]] 페이지에 그렇게 구분해 기록해야 한다.
- 저자의 인접 글 다수(comprehension debt, cognitive surrender, orchestration tax, intent debt)는 아직 이 위키에 없다. 하나씩 들어오면 `concepts/comprehension-debt` 같은 페이지가 정당화될 수 있다. 지금은 [[loop-engineering]] 안의 한 절로 둔다.

## Raw Source

[원본 파일](../../raw/articles/2026-06-07-loop-engineering.md) · [addyosmani.com/blog/loop-engineering](https://addyosmani.com/blog/loop-engineering/)
