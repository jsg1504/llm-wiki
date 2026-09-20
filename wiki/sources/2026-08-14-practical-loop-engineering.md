---
title: Practical Loop Engineering
type: source
created: 2026-09-21
updated: 2026-09-21
source_file: ../../raw/articles/2026-08-14-practical-loop-engineering.md
source_url: https://addyosmani.com/blog/practical-loop-engineering/
author: Addy Osmani
source_date: 2026-08-14
tags: [loop-engineering, goal, loop, scheduled-tasks, routines, verification, maker-checker, delegation, pr-triage, claude-code, external-perspective]
status: mature
---

# Practical Loop Engineering

> [[2026-06-07-loop-engineering]]의 **실전편.** 개념이 아니라 운용을 다룬다 — `/goal`·`/loop`·`/schedule`의 분업, Claude Code 팀이 분류한 네 종류의 루프, 매일 5~10개 에이전트를 돌리며 무엇을 완전 위임하고 무엇을 지켜보는가. 중심 규율 하나: **task는 위임하되 judgment는 위임하지 않는다.**

## Context

같은 저자의 2026-06-07 글에서 두 달 뒤(2026-08-14). 원본은 Substack 게재. 앞 글이 *"루프란 무엇이고 왜 층위가 하나 더 생겼는가"* 였다면 이 글은 *"그래서 매일 어떻게 돌리는가"* 다. 서술 톤도 다르다 — 앞 글이 정리라면 이쪽은 **구술에 가까운 경험담**이고, 자기 실패담이 하나 들어 있다.

역사적 배경을 한 문단 준다. primitive가 제품에 들어오기 전에는 손으로 짠 bash 루프였고, 그해 초 여럿이 Geoff Huntley의 **Ralph loop**를 갖고 놀았다. 개인 프로젝트에서 실험했으므로 벽에 부딪혀도 비용이 없었다는 것이 요점이다. 지금은 *"I can now largely rely on the output of the primitives in Claude Code and Codex"* 이지만, 그래서 오히려 **목표와 제약을 제대로 정의했는지** 따지는 규율이 필요해졌다고 말한다.

> ⚠️ **출처 성격 주의.** 이 글의 상당 부분이 **Claude Code 팀의 X article을 그대로 인용한 것**이다(네 종류의 루프, goal/time/proactive 각각의 설명, verification skill 예시, composed example). 즉 외부 저자를 거쳐 **[[anthropic]] 원문이 들어온다.** 이 위키가 가진 것은 Osmani의 인용본이고 원문 자체는 아니다. "비-Anthropic 소스 2개 확보"로 세면 안 된다. → [[anthropic]]

## Key Claims

1. **`/goal`의 evaluator는 품질 검사기가 아니다.** 이 소스에서 가장 중요한 한 문장이며, 이 위키의 기존 기록을 **좁힌다.**

   > *"The evaluator sitting behind goal is not that checker, by the way. It doesn't look at the content to see if it's good or bad in any way, shape, or form. All it does is examine the conversation transcript to see if the hard rules you specified have been met."*

   즉 판정자가 분리된 것은 맞지만, 판정 대상은 **루브릭 품질이 아니라 하드 룰 충족**이다. 그래서 maker/checker는 **따로** 세워야 한다 — evaluator가 그 자리를 대신하지 않는다. → [[agent-evaluation]], [[loop-engineering]]

2. **루프는 네 종류다 (Claude Code 팀 분류).** 트리거 방식·정지 방식·쓰는 primitive·맞는 태스크의 네 축으로 나뉜다.
   - **turn-based (agentic loop)** — 모든 프롬프트가 이걸 연다. Claude가 컨텍스트를 모으고, 행동하고, 자기 작업을 확인하고, 필요하면 반복하고, 답한다. 사람이 매 턴을 지시한다.
   - **goal-based (`/goal`)** — 한 턴으로 부족한 복잡한 작업. **완료의 정의**를 사람이 쓰면 Claude가 *"이만하면 됐다"* 를 스스로 판단해 조기 종료하지 않는다. 멈추려 할 때마다 evaluator 모델이 조건을 확인하고 되돌려보낸다. 목표 달성 또는 지정한 턴 수 도달까지.
   - **time-based (`/loop`)** — 태스크는 그대로이고 입력만 바뀌는 반복 작업, 또는 외부 시스템을 주기적으로 확인해 변화에 반응하는 일.
   - **proactive (`/schedule` routine)** — 이벤트나 스케줄이 트리거하고 **실시간으로 사람이 없다.** 각 태스크는 목표 달성 시 종료되지만 routine 자체는 끌 때까지 돈다. 버그 리포트·이슈 triage·마이그레이션·의존성 업그레이드 같은 **잘 정의된 작업의 정기 스트림**에 맞는다.

   팀의 단서 하나: *"Not all tasks require complex loops; start with the simplest solution and use these patterns selectively."* 그리고 proactive 루프의 비용 관리법 — **routine은 작고 빠른 모델로 라우팅하고, 판단이 필요한 대목에만 가장 유능한 모델을 쓴다.**

3. **`/loop`와 `/schedule`은 다른 물건이다.** `/loop`는 **내 컴퓨터에서** 돈다 — 끄면 멈춘다. **세션 스코프**라 새 대화를 시작하면 정지하고, `--resume`/`--continue`로 세션을 되살리면 아직 유효한 반복 태스크가 같이 돌아온다. 그리고 **생성 후 7일에 만료된다.** 세션보다 오래 살아야 하면 `/schedule`로 클라우드 routine을 만든다.

   > 저자의 자기 정정: *"I'd been telling people this was three days. It's seven."*

4. **정지 조건은 결정론적일수록 강하다.** 팀의 표현으로 *"deterministic criteria, such as number of tests passed or clearing a certain score threshold, are so effective."* 예시: `/goal get the homepage Lighthouse score to 90 or above, stop after 5 tries.` 저자 자신의 실제 목표들 — 마지막 이슈 10개 리뷰·정리, *"이 페이지 로딩을 50% 빠르게"*. 후자에 대해 솔직하다: *"Sometimes that works well, sometimes it doesn't, but it's really about the experimentation."*

5. **위임 경계는 태스크의 성격으로 나뉜다.** 매일 5~10개 에이전트, 동시 실행은 보통 **최대 5개**.
   - **완전 위임해도 되는 것:** 구현한 기능의 문서 작성, 테스트 커버리지 충분한지 점검 — *"a little bit safer"* 한 것들.
   - **밀착 감시:** 복잡한 문제, 좋은 스펙과 정지 조건을 줬어도 **다 맞히지 못할 여지가 큰** 것, 그리고 **민감한 것** — 시스템 접근을 줬거나, 인증·보안·금융을 건드리는 기능.
   - 코드베이스의 성격도 변수다 — 유저도 히스토리도 없는 evergreen 프로젝트와 **brownfield 은행 코드베이스**는 다르다.

6. **작업한 에이전트가 작업의 좋고 나쁨을 정하게 두지 않는다.** 한 subagent가 변경을 초안하고 **별도의 하나가 검증한다.** 저자가 드는 실패 양상이 구체적이다 — 에이전트가 자기가 만든 경험의 성능이 괜찮다고 확신하는데 **데스크톱만 보고 평가했고** 정작 중요한 건 모바일인 경우. *"very confident about one dimension of the problem, but not the other."*

7. **task는 위임하되 judgment는 위임하지 않는다 — 저자의 실패담.** 사용자 피드백에 안 잡힌 빈틈을 찾으려고 경쟁 제품을 조사시키고, 그 격차를 메우는 변경을 **로컬 PR로** 만들게 했다. 그리고 **거의 푸시할 뻔했다.** 리서치는 읽었지만 구현을 충분히 들여다보지 않았기 때문이다. 열어보니 사용자에게 **복잡도만 상당히 늘리고 얻는 건 별로 없는** 변경이었다.

   > *"So I delegated the task, but I was close to delegating the judgment as well."*

8. **루프에 안 맞는 일이 있다.** 완료·done·good이 무엇인지 명확하지 않으면 애초에 틀린 패턴이다. 나쁜 목표의 예: *"keep going until this UI design is good"* — **누구에게 good이고 무엇으로 평가되는가.** 사람의 taste, 주관적 디자인, 열린 창작 탐색은 맞지 않는다.

9. **멈춰야 할 신호 하나.** 루프가 제자리에서 도는 전형적 징후는 **같은 명령이 결과 변화 없이 반복되는 것**이다. 세 번째에도 두 번째와 같으면 멈출 때다.

10. **검증을 skill로 코드화한다.** 팀이 제시한 `verify-frontend-change` SKILL.md가 전문 인용된다 — 편집 성공만으로 UI 변경을 완료 보고하지 말고 **사람 리뷰어가 하듯** 확인하라: dev server를 띄워 브라우저로 열고, 직접 조작하고(새 컨트롤은 클릭해 상태 변화 확인 + before/after 스크린샷), 콘솔에 새 에러·경고 0을 확인하고, Chrome DevTools MCP로 performance trace와 Core Web Vitals를 감사한다. **어느 단계든 실패하면 고치고 1단계부터 다시** — 부분 검증된 작업을 넘기지 않는다.

11. **조합이 최종 형태다.** `/loop`로 점검을 스케줄하고 `/goal`로 문제를 푼다: `/loop every 24h "Check GitHub for issues labeled 'bug'. If one exists, use /goal to implement a fix until all local tests pass and push the branch."` 팀의 composed example은 한 겹 더 간다 — `/schedule`(정기 확인) + `/goal`(완료 정의) + skills(검증 방법) + **dynamic workflows**(각 리포트를 triage·수정·리뷰하는 에이전트 조율) + **auto mode**(권한 질문으로 멈추지 않게). 그 예시 프롬프트는 *"버그를 고칠 때는 워크플로로 세 가지 해법을 병렬 worktree에서 탐색하고 judge가 적대적으로 리뷰하게 하라"* 까지 포함한다.

## Notable Quotes

> A loop is an autonomous, self-correcting feedback cycle where an AI agent repeatedly acts, tests its results and adjusts its approach until a specific goal is met

> The evaluator sitting behind goal is not that checker, by the way. It doesn't look at the content to see if it's good or bad in any way, shape, or form. All it does is examine the conversation transcript to see if the hard rules you specified have been met.

> So I delegated the task, but I was close to delegating the judgment as well.

> Give the same command a third time with no change from the second and it's probably time to stop.

> If there's a check you already run every morning by hand, that's your first loop. Mine was the pull request pile.

## 저자가 실제로 돌리는 루프

Agent Skills 저장소(80,000+ stars)에 하루 최대 80~90개의 PR이 들어왔고, 매일 손으로 확인했다. 지금은:

```
/loop every 1h "Check the GitHub repository for any new open issues. Provide a bulleted summary of their urgency."
```

triage가 실제로 하는 일은 **양을 줄이는 것**이다. 기여 가이드라인에 *"현재 번역 PR은 받지 않는다"* 같은 규칙이 문서로 있으면 — 성의가 없어서가 아니라 들어오는 언어를 다 못 해서 유지보수가 안 되기 때문 — 그 규칙을 **정지 조건으로 삼아** 해당하는 PR을 닫게 한다. **문서화된 규칙이 곧 강제 가능한 정지 조건이 된다.** 여기에 cross-reference가 더해진다: 시스템 한 부분을 재작업할 때 그것을 건드리는 이슈들이 그 결과로 닫히는지, 남의 작업과 겹치지 않는지를 정의해둘 수 있다.

## Connections

- [[loop-engineering]]의 실무 층. 그 페이지의 `/goal` 절을 **정정**하고 네 종류 루프·위임 경계를 더한다.
- [[agent-evaluation]] — §2b의 판정자 분리 논의를 좁힌다. evaluator는 룰 체커이지 품질 판정자가 아니다.
- [[claude-code]] — `/loop`의 7일 만료·세션 스코프, `/schedule`과의 분리, verification skill의 실물.
- [[agent-orchestration-patterns]] — #6 loop-until-done에 실무 판정 기준(나쁜 정지 조건의 형태, 3회 무변화)을 준다.
- [[subagent]] — maker/checker를 evaluator와 구분해야 한다는 요구.
- [[dynamic-workflows]] — 팀의 composed example에서 **루프 안에서 호출되는 것**으로 명시적으로 등장한다. [[loop-engineering]]이 세운 층위 배치를 벤더 쪽에서 확인해준다.
- [[anthropic]] — 이 소스를 통해 벤더 원문이 간접 유입된다는 사실 자체가 편향 추적 대상.

## My Notes

- **이 소스의 최대 기여는 정정이다.** 어제 [[2026-06-07-loop-engineering]]을 ingest하며 `/goal`을 *"판정자 분리 원칙이 정지 조건에까지 확장된 것"* 으로 기록했는데, 그건 과장이었다. 같은 저자가 두 달 뒤 스스로 좁힌다. **분리는 맞지만 판정하는 것이 다르다** — 품질이 아니라 룰 충족. 이 구분을 놓치면 "루프에 evaluator를 걸었으니 검증은 됐다"는 잘못된 안심에 도달한다. 저자가 명시적으로 경계하는 것이 정확히 그것이다.
- **위임 경계는 위키에 없던 축이다.** 기존 페이지들은 *무엇을 병렬화할 수 있는가*(기술적 가능성)와 *얼마를 지불할 가치가 있는가*(경제성)는 다뤘지만, **무엇을 사람이 봐야 하는가**(태스크 민감도)는 다룬 적이 없다. 인증·보안·금융이라는 구체적 목록과 evergreen↔brownfield 구분이 처음 들어온다.
- **숫자 하나가 기존 기록과 어긋나 보인다.** [[claude-code]]는 [[2026-08-21-the-ai-native-sdlc-playbook]]을 따라 병렬 세션을 *"2~3개가 합리적 출발점"* 이라 적었는데 여기는 5~10개(동시 5개)다. 모순은 아니다 — 플레이북은 엔터프라이즈 도입 초기를 말하고 이쪽은 숙련자의 개인 상한이며, 양쪽 다 **천장은 사람의 리뷰 능력**이라는 데 동의한다. 다만 위키에 둘 다 적어두는 편이 정직하다.
- **실패담이 값지다.** 위키의 [[loop-engineering]] cognitive surrender 절이 지금은 추상적 경고인데, 여기 "리서치는 읽고 구현은 안 봤다"는 구체적 실패 형태가 붙는다. 그리고 그 실패가 **검증 실패가 아니라 취향 판단의 위임**이었다는 점이 더 정확하다 — 코드는 아마 동작했을 것이다. 문제는 그게 **만들 가치가 있는 변경인가**였다.
- **정량 데이터는 여전히 없다.** 80,000 stars, 하루 80~90 PR, 5~10 에이전트, 7일 만료는 사실 진술이지 효과 측정이 아니다. 루프 도입 전후 비교는 없다. 앞 소스와 같은 급이다.
- **벤더 인용 비중이 높다는 점을 잊지 말 것.** 네 종류 분류, goal/time/proactive 설명, verification skill, composed example이 전부 Claude Code 팀 원문이다. 저자의 고유 기여는 운용 경험(위임 경계, 실패담, triage 사례, 3회 무변화 신호)이다. 이 위키는 **그 둘을 구분해 적어야** 한다.

## Raw Source

[원본 파일](../../raw/articles/2026-08-14-practical-loop-engineering.md) · [addyosmani.com/blog/practical-loop-engineering](https://addyosmani.com/blog/practical-loop-engineering/) · [Substack 원본](https://addyo.substack.com/p/practical-loop-engineering)
