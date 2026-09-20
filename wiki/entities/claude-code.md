---
title: Claude Code
type: entity
created: 2026-09-11
updated: 2026-09-21
sources: [2026-08-21-the-ai-native-sdlc-playbook, 2025-06-13-multi-agent-research-system, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents, 2026-05-25-how-we-contain-claude]
tags: [claude-code, anthropic, agentic-coding, tooling, ai-native]
status: draft
---

# Claude Code

> Anthropic의 에이전틱 코딩 도구. 이 페이지는 [[ai-native-sdlc]] 플레이북이 SDLC 각 단계에 배치하는 기능들 — plan mode, auto mode, `CLAUDE.md`, skills, hooks, subagents, worktrees, permissions/sandbox, 비대화형 실행 — 을 **통제와 워크플로우 관점에서** 정리한다.

> ℹ️ **범위 주의:** 이 페이지의 기능 서술은 주로 [[2026-08-21-the-ai-native-sdlc-playbook]]에 기반하며, 그 출처가 SDLC 맥락에서 언급한 기능만 다룬다. 도구의 전체 기능 목록이 아니다. 병렬성 절의 일반 원리는 [[2025-06-13-multi-agent-research-system]]을, Dynamic workflows 절은 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]를 인용한다.

## Overview

Claude Code는 저장소에 접근해 코드를 읽고, 편집하고, 명령을 실행하는 에이전트다. 플레이북에서의 위치는 단순한 "코드 생성기"가 아니다 — **버전 관리되는 설정 파일들(`CLAUDE.md`, skill, hook, agent 정의)이 조직의 정책과 지식을 담고, 에이전트가 매 세션 그것을 읽는다.** 즉 도구의 행동이 repo에 커밋된 텍스트로 결정되고, 따라서 리뷰·감사·버전 관리의 대상이 된다.

이 설계가 [[agentic-governance]]의 전제다. 설정이 파일이므로 코드처럼 다룰 수 있다.

### 층위: Claude Code는 harness 중 하나다

[[2026-04-08-scaling-managed-agents]]는 Claude Code를 **harness**라는 일반 범주의 한 사례로 위치시킨다:

> *"Claude Code is an excellent harness that we use widely across tasks. We've also shown that task-specific agent harnesses excel in narrow domains. Managed Agents can accommodate any of these."*

**Harness**란 모델을 감싸고 무엇을 언제 할지를 정하는 바깥 껍질이다 — Claude를 호출하는 루프, tool call을 인프라로 라우팅하는 배선, 컨텍스트를 채우고 비우는 규칙. 이 페이지가 기술하는 거의 전부(plan mode, auto mode, `CLAUDE.md` 로딩, hook 실행 시점, subagent spawn)가 그 껍질의 내용물이다.

```
[[managed-agents]] (meta-harness)   ← 인터페이스. 가장 느리게 변함
  ├─ Claude Code                     ← 이 페이지. 범용, 코딩 중심
  ├─ 태스크 전용 harness             ← 좁은 도메인
  └─ dynamic workflow가 쓴 프로그램  ← 태스크마다 생성
```

이 구분이 실용적으로 중요한 이유는 [[meta-harness]]의 중심 주장 때문이다 — **harness에 들어간 모든 결정은 "모델이 아직 무엇을 못 하는지"에 대한 진술이고, 그 진술은 다음 모델에서 틀릴 수 있다.** 그쪽 소스의 사례는 Sonnet 4.5의 "context anxiety"를 막으려 넣은 context reset이 Opus 4.5에서 dead weight가 된 일이다.

아래 기능들을 읽을 때 유용한 질문: **이것은 모델의 무엇을 보완하고 있는가, 그리고 그 보완이 여전히 필요한가?** 일부는 그렇지 않다 — plan mode의 게이트나 hook의 차단은 *모델이 못 해서*가 아니라 **사람이 통제를 원해서** 있는 것이고, 모델이 좋아져도 이유가 사라지지 않는다. 둘을 구분해두면 기능이 낡았는지 판별하기 쉽다.

대화형 터미널 세션 외에 **비대화형 실행**(`claude -p`)이 있고, 이것이 CI/CD 파이프라인·스케줄 작업·모니터링 루프에서 쓰인다. 세션이 stateless하게 시작하고 끝나므로 *"아무도 시작하지 않아도 루프가 시작되고 끝난다."*

## 컨텍스트와 지식

### `CLAUDE.md`

세션 시작에 읽히는 프로젝트 메모리 파일. 신규 입사자가 첫날 필요할 컨텍스트를 담는다 — 규약, 명령, 아키텍처, 팀이 가장 자주 보는 실수.

- `/init`으로 생성한 뒤 **잘라낸다.** 빌드·테스트·린트 명령, 중요한 규약, Claude가 계속 틀리는 것만 남긴다.
- repo 루트에 커밋해 팀이 한 버전을 공유하고 변경이 코드처럼 리뷰되게 한다.
- **작업 규칙: Claude가 같은 실수를 두 번 하면 교정이 `CLAUDE.md`에 들어간다.** PR 리뷰가 실수를 두 번째로 플래그할 때도 마찬가지이며, 리뷰도 `CLAUDE.md`를 읽으므로 다음 PR부터 잡힌다.
- **한 페이지 이하로 유지한다.** Claude가 세션 시작에 전부 읽으므로 낡은 내용은 이득 없이 컨텍스트를 차지한다.
- 권장 섹션: Commands / Conventions / Architecture / **Things Claude gets wrong**
- 검증 블록을 두어 "완료 보고 전 무엇을 돌려야 하는지"를 명시한다.

측정: `CLAUDE.md`가 잡았어야 할 실수를 Claude가 반복하는 빈도(leading), 신규 팀원의 첫 머지 PR까지 시간(lagging).

> ⚠️ **`CLAUDE.md`는 공격 표면이기도 하다 (2026-09-21).** 위 서술과 [[agentic-governance]]는 *"설정이 파일이므로 리뷰·감사·버전 관리의 대상이 된다"* 를 장점으로 적는다. [[2026-05-25-how-we-contain-claude]]가 같은 속성의 반대편을 보고한다 — **파일이므로 공격자도 커밋할 수 있고, 커밋되면 매 세션 로드된다.** 저자들은 `CLAUDE.md`를 **persistent memory poisoning 벡터** 목록에 명시적으로 넣는다(product memory, 마운트된 workspace, 장기 실행 에이전트의 state 디렉토리와 함께).
>
> 모순은 아니다. 리뷰 가능성은 실재하고 **방어의 일부**다 — 악성 `CLAUDE.md` 변경은 PR에서 보인다. 다만 *"세션 시작 시의 좋은 classifier가 더 일반화되어야 한다"* 는 것이 저자들의 전망이다. 상세는 [[prompt-injection]].

### Skills

`.claude/skills/<name>/SKILL.md` — frontmatter가 **언제 트리거되는지**를, 본문이 **무엇을 할지**를 말한다.

- 용도: **일관되게 적용되어야 하는 조직 지식.** `CLAUDE.md`나 프롬프트에 속하는 것은 skill로 쓰지 않는다.
- 배포: repo의 `.claude/skills/`에 두어 코드와 함께 배송하거나, **plugin**으로 조직 전체에 배포.
- **트리거 테스트가 필수다.** 관련 작업을 여러 방식으로 요청해 skill이 매번 로드되는지 확인한다.
- 정책이 바뀌면 skill을 바꾸고 정책 소유자가 사인오프한다. 엔지니어는 다음 세션에서 새 버전을 자동으로 집는다.
- **성격은 advisory다.** 세션이 따르도록 강제하는 것은 없다. → [[agentic-governance]]

### Plugins / marketplaces

skill과 hook을 조직 전체에 배포하는 경로. 엔터프라이즈 설정에서는 `strictKnownMarketplaces`와 `disableSideloadFlags`로 **모든 skill·agent·hook·MCP 서버가 승인된 marketplace를 통해서만 도착하게** 고정할 수 있다.

## 실행 모드

### Plan mode

Claude가 **코드베이스를 읽되 바꾸지 못하는** 상태. 플레이북은 이것을 Build 단계의 기본 출발점으로 삼는다.

1. plan mode로 세션 시작, `intent.md`와 `spec.md`를 준다.
2. 바뀌는 파일, 작업 순서, 증명할 테스트를 명시한 구현 계획을 요구한다.
3. 계획을 심문한다 — 무엇이 깨질 수 있나, 가장 위험한 단계는, 선택하지 않은 대안은.
4. **대화를 본 적 없는 엔지니어가 계획만 보고 구현할 수 있을 때까지** 반복한다.
5. `plan.md`로 커밋. 나중에 PR 리뷰가 실제 diff를 이것과 대조한다.
6. 수락하면 구현. 좋은 계획이 있으면 구현은 종종 한 번에 끝난다.
7. 구현이 계획에서 벗어나면 **같은 커밋에서** `plan.md`를 갱신한다. hook으로 동기화를 강제할 수 있다.

거버넌스 가치: **도구가 스스로 강제한다.** 엔지니어가 계획을 수락하기 전에는 파일을 편집할 수 없으므로, 설계 리뷰가 코드 생성 전 — 방향 전환이 아직 문서 편집으로 끝나는 시점에 — 일어난다.

### Auto mode

엔지니어가 계획을 승인한 뒤 Claude가 **편집마다 묻지 않고** 각 변경을 적용한다.

가드레일이 성숙하면(튜닝된 `CLAUDE.md`, 정책을 인코딩한 skill, 위험한 동작을 막는 hook, Claude가 돌릴 수 있는 테스트 suite) 일상 작업의 기본이 된다. 조건은 **빡빡한 `spec.md`, 작은 blast radius, 테스트가 이미 덮고 있는 코드.**

**전제 하나 보강 (2026-09-21).** 위 목록은 [[2026-08-21-the-ai-native-sdlc-playbook]]에서 온 것이고 대부분 **model/config 층위**다. [[2026-05-25-how-we-contain-claude]]는 여기에 **환경 층위 전제를 명시적으로 건다.** auto mode는 명령 승인을 모델 기반 classifier에 위임하는 것이고, 각주에서 못 박는다:

> *"it's one layer of defense-in-depth **inside a sandbox**, not a substitute for one."*

수치가 그 이유를 말한다 — **overeager 행동의 약 83%를 실행 전에 포착하지만 ~17%는 통과한다.** 마찰은 낮다(benign 명령의 **0.4%**만 차단). 즉 **auto mode는 sandbox를 대체하는 것이 아니라 sandbox 안에서 쓰는 한 겹**이다. 정면충돌은 아니지만 우선순위가 다르다 — 플레이북은 sandbox를 별도로 다루면서 auto mode의 전제로는 걸지 않는다. → [[agent-containment]]

의미: 검토 대상이 "에이전트가 편집하는 것을 지켜보기"에서 **"더 긴 자율 세션 이후의 아티팩트"**로 옮겨간다. worktree와 함께 쓰면 개인·팀 차원의 병렬성을 가능하게 하고, SDLC를 자율적으로 돌려 루프를 닫는 데 근본적이다.

### 비대화형 실행 (`claude -p`)

CI 러너의 스텝이나 Agent SDK 서비스로 돈다. 쓰임:

- 읽기 전용 판단 작업 — 실패한 빌드 분류, flaky 테스트 요약, 체인지로그 초안
- 쓰기 작업 (기존 게이트 뒤에서) — lint 수정, 생성 문서 갱신, `@claude` 멘션으로 리뷰 코멘트 처리
- eval suite 실행
- 모니터링 루프의 진단 단계

실행은 sandbox된다 — 네트워크 정책 아래 컨테이너에서, 수명이 짧고 스코프된 토큰으로, **기본적으로 production 자격증명을 갖지 않는다.** 각 실행이 에이전트 자신의 identity로 동작하므로 파이프라인 로그가 에이전트의 행위와 트리거한 엔지니어의 행위를 분리한다.

## 병렬성

### Parallel sessions (worktrees)

병렬 세션은 **각자의 git worktree에서 별도 작업을 하는 완전한 Claude Code 인스턴스**다. 서로를 모르며, 공유하는 것은 그것들을 조종하는 엔지니어뿐이다. 이 점이 병렬 세션을 *에이전트 간 실시간 위임*과 구분한다 — 세 가지 병렬성의 구분은 [[subagent]] 참조. 멀티에이전트 일반의 경제성은 [[multi-agent-systems]].

- `claude --worktree feature-auth` 식으로 터미널마다 하나씩. worktree는 자기 브랜치의 별도 체크아웃이라 세션들이 파일에서 충돌하지 않는다.
- 작업을 **서로 다른 파일을 건드리는 단위로** 쪼갠다. 파일을 공유하는 작업은 한 세션에서 순차로.
- **2~3개가 합리적 출발점.** 실질적 천장은 *"한 사람이 제대로 리뷰할 수 있는 스트림 수"*이며, 리뷰가 따라가는 동안에만 늘린다.
- 전제: `CLAUDE.md`(모든 세션이 읽는다), 피드백 루프(세션이 자기 작업을 검증할 수 있으면 감독이 덜 필요하다), 안전한 명령에 대해 승인을 기다리지 않도록 튜닝된 permission 설정.

### Subagents

`.claude/agents/<name>.md`에 정의. **단일 세션 안에서** 자기 컨텍스트 윈도와 도구 제한을 갖고 도는 스코프된 헬퍼. 일반 개념은 [[subagent]], 이 장치를 쓰는 아키텍처 원리는 [[orchestrator-worker]].

- 정의 요소: name, 언제 쓰는지에 대한 description, 건드릴 수 있는 tools.
- git에 체크인해 팀이 공유한다.
- 플레이북의 예시: 메인 에이전트가 끝난 뒤 불필요한 복잡도를 걷어내는 **code simplifier**, 앱을 돌려 동작을 확인하는 **verifier**, 메인 컨텍스트를 채우지 않고 코드베이스를 탐색해 보고하는 **researcher**.

**병렬 세션 vs subagent:** 병렬 세션은 엔지니어가 동시에 진행할 수 있는 작업 수를 늘리고, subagent는 각 세션이 자기 작업에 집중하게 유지한다. 엔지니어의 일은 그 전부를 조종하고 리뷰하는 것.

**verifier subagent vs 피드백 루프:** 피드백 루프는 작업 내내 필요한 만큼 반복된다. verifier subagent는 세션이 작업이 끝났다고 믿을 때 **신선한 컨텍스트 윈도로 한 번** 도는 최종 확인이다. 요점은 **판정이 코드를 만든 가정에 오염되지 않는다는 것.** 이것은 [[agent-evaluation]]의 "경로가 아니라 결과를 본다" 원칙을 도구 차원에서 구현한 것이다.

### Dynamic workflows

Claude가 **태스크별 harness를 JavaScript로 즉석에서 작성·실행**하는 기능. 앞의 subagent가 "세션 안에서 부르는 헬퍼"라면, 워크플로는 **그 헬퍼들을 무엇을 어떤 순서로 몇 개 띄울지를 담은 프로그램**이다. 개념과 경제성은 [[dynamic-workflows]], 제어 구조는 [[agent-orchestration-patterns]].

- **트리거:** 그냥 워크플로를 만들어 달라고 하거나, 트리거 단어 **`ultracode`**를 쓴다.
- **저장:** 워크플로 메뉴에서 **`s`**. `~/.claude/workflows`에 체크인하거나 skill에 담아 배포한다. skill로 배포할 때는 스크립트가 아니라 **템플릿으로 취급하라고 프롬프트**하는 편이 유연하다.
- **모델·격리를 워크플로가 정한다.** 에이전트마다 어떤 모델을 쓸지, subagent를 각자의 worktree에서 돌릴지 결정할 수 있다.
- **중단 복구:** 사용자 개입이나 터미널 종료로 중단되어도 세션 재개 시 이어 간다.
- **`/deep-research`** skill이 dynamic workflow로 구현되어 있다 — 웹 검색 fan-out → 소스 fetch → 주장을 적대적으로 검증 → 인용된 리포트 종합.
- **`/loop`·`/goal`과의 조합:** 반복 가능한 워크플로(triage, research, verification)는 `/loop`로 정기 실행하고 `/goal`로 하드한 완료 요건을 건다.
- **토큰 예산:** *"use 10k tokens"*처럼 프롬프트에 쓰면 상한이 걸린다. 저자들이 명시적으로 권하는 통제 수단이다.

> **다른 병렬 장치와의 관계:** 병렬 세션은 **사람이**, orchestrator-worker는 **lead agent가**, dynamic workflow는 **프로그램이** 조정한다. 셋은 대체재가 아니라 조정 주체가 다른 층위다 → [[subagent]]

## 통제 표면

### Hooks

Claude가 행동하기 전에 실행되는 스크립트. **allow / ask / block** 중 하나를 한다. `.claude/settings.json`의 `PreToolUse` 등에 matcher와 함께 등록한다.

- 팀 hook은 git의 `.claude/settings.json`에, 협상 불가 hook은 엔지니어가 끌 수 없는 managed settings에.
- 차단은 **스스로를 설명해야 한다** — 이유와 승인 경로가 Claude 출력에 나타나야 한다. (예: exit 2로 차단하고 메시지를 stderr로)
- Claude가 행동하는 모든 곳에서 돈다. 특정 단계 전용이 아니다.

용도별 배치는 → [[agentic-governance]]

### Permissions / sandbox / managed settings

- `permissions.deny` / `allow` — 비밀을 컨텍스트에서 배제하고 안전한 inner loop는 미리 승인 (deny 목록이 프롬프트 피로가 되지 않게)
- `sandbox` — OS 수준 파일시스템·네트워크 격리(macOS **Seatbelt**, Linux **bubblewrap**). **permission이 닫지 못하는 구멍을 닫는다** (도구 수준 WebFetch deny는 셸 명령의 네트워크 접근을 막지 못한다). 정책은 **읽기 허용 / workspace 내 쓰기 허용 / 네트워크 기본 거부**이며, 도입 결과 **권한 프롬프트가 84% 줄었다.** 런타임은 오픈소스로 공개되어 경계가 감사 가능하다 ([[2026-05-25-how-we-contain-claude]])
- `credentials` — sandbox된 셸 명령이 `~/.ssh`, `~/.aws/credentials`를 읽거나 지정된 환경변수를 보는 것을 막는다
- managed settings — MDM이나 admin console로 배포되어 엔지니어·프로젝트 파일·CLI 플래그가 규칙을 넓히지 못하게 고정

### MCP

외부 시스템을 도구로 노출하는 경로. 플레이북에서의 용례:

- **레거시 시스템 연동** — Jira/ServiceNow가 source of truth일 때 세션 시작에 기록을 읽고 결과를 되쓴다. → [[artifact-chain]]
- **배포** — deploy·status·rollback을 환경별로 스코프된 도구로 노출. *"자격증명을 쥔 셸 스크립트가 아니라 allowlist."*
- **UI 검증** — 브라우저나 스크린샷 유틸리티를 물려 Claude가 결과를 볼 수 있게
- **인시던트 대응** — 지표가 baseline으로 돌아왔는지 확인

엔터프라이즈에서는 `allowManagedMcpServersOnly`로 에이전트의 도구 표면 전체를 플랫폼 팀이 소유하는 allowlist로 만들 수 있다.

### 격리 아키텍처와 보고된 취약점

[[2026-05-25-how-we-contain-claude]]는 Claude Code의 containment를 **HITL sandbox 패턴**으로 분류하고, 그것이 성립하는 조건과 깨진 지점을 기록한다.

**왜 이 도구에서 HITL이 성립하는가.** 평균 사용자가 **개발자**이기 때문이다 — bash를 읽고, `rm -rf`가 뭔지 알고, 이미 매주 신뢰할 수 없는 출처에서 `npm install`을 돌린다. "허용하시겠습니까" 대화상자가 떴을 때 판단할 전문성이 있을 가능성이 높다. 같은 전략이 비기술 사용자 제품(Cowork)으로는 전이되지 않으며, 거기서는 관리자가 **절대적이고 상시적인 경계**를 세운다. 세 패턴 비교는 [[agent-containment]].

**그런데 감독은 측정된 실패다.** 텔레메트리상 **사용자는 권한 프롬프트의 약 93%를 승인했다.** 승인을 많이 볼수록 각각에 덜 주의하게 된다 — *"감독을 제공하려고 설계된 기능이 오히려 반대 효과를 낼 수 있다."* 숙련도별 차이도 측정됐다: **경험 많은 사용자는 신규 대비 auto-approve를 약 2배 하지만 실행 중 중단(interrupt)은 더 자주 한다.** 단계별 게이팅 대신 이탈했을 때만 감독하는 쪽으로 진화한다. 저자들은 이것도 fallible하다고 본다 — 에이전트가 점점 야심찬 bash를 쓰고 멀티에이전트로 갈수록 드리프트를 알아채기 어려워진다.

> ⚠️ **구조적 취약점: 탈출 열쇠를 쥔 바깥 프로세스.** Claude Code는 **특권 프로세스가 sandbox 밖에서 명령마다 강제 여부를 결정**한다. 저자들의 지적 — *"설득력 있게 주입된 프롬프트나 피곤한 승인 클릭 하나가 그 프로세스에게 sandbox 없이 무언가를 실행시킬 수 있다."* Cowork의 초기 full-VM 모드에는 그런 바깥 프로세스가 아예 없었다(예외를 허가할 권한을 가진 컴포넌트가 없음). 대비는 [[agent-containment]].

**보고된 취약점 3건 — 신뢰 경계 이전에 실행되는 코드.** 2025 중반~2026년 1월, 책임공개 프로그램으로 받은 취약점 3건이 전부 **사용자가 아무것도 동의하기 전에 실행되는 코드**를 노렸다. 가장 직접적인 형태: 개발자가 PR 리뷰하려고 repo를 clone하는데 거기 `.claude/settings.json`이 hook을 정의하고 있고, **Claude Code가 시작 시 project settings를 읽는 시점이 "이 폴더를 신뢰합니까?" 프롬프트보다 앞서므로** 공격자가 커밋한 hook이 자동 실행된다. 나머지 둘도 구조가 같았다.

수정은 셋 다 같은 모양이었다 — **project-local 설정의 파싱과 실행을 trust 프롬프트 수락 이후로 미룬다.** 일반 처방:

> *"treat project-open, config-load, and localhost listeners the way you'd treat any inbound request from the internet."*

**사용자 자신이 injection 벡터가 될 수 있다.** 2026년 2월 내부 red-team에서 직원이 피싱당해 악성 프롬프트로 Claude Code를 띄웠고, `~/.aws/credentials` 유출이 **25회 중 24회** 성공했다. 사용자가 직접 친 지시이므로 **모델 층위 방어에 잡을 이상 징후가 없었다.** 이 도구의 `permissions.deny`·`credentials`·`sandbox` 설정이 장식이 아닌 이유다. → [[prompt-injection]]

## 통합과 관련 제품

플레이북이 언급하는 것들:

- **claude-code-action** — 자체 CI에서 리뷰와 수정 루프를 돌린다. 파이프라인 통제가 필요하거나 자체 클라우드 계약으로 모델 호출을 라우팅할 때.
- **Code Review** (research preview) — 관리형 리뷰 서비스. 관리자가 켜고 repo를 선택하면 되는 가장 빠른 출발점. `@claude review`로 새 리뷰 요청.
- **Claude Design** (beta) — `intent.md`에서 목업을 만들고 반복한 뒤 Claude Code로 내보내 구현.
- **Claude Security** (Enterprise public beta) — 스케줄된 코드베이스 스캔. Anthropic 인프라에서 Claude Mythos 5로 돌고, 각 finding이 보고 전에 검증되며 confidence rating이 붙는다. 제안된 패치는 Claude Code on the web에서 리뷰·적용.
- **Claude Tag** (public beta, Slack) — Claude가 자기 정체성으로 채널에 참여. 인시던트의 1차 대응자가 되고 채널 히스토리가 audit trail이 된다.
- **Cowork / claude.ai** — 엔지니어가 아닌 사람이 `intent.md`를 만드는 경로.
- **모델 접근 경로** — API, AWS Bedrock, Google Vertex, Microsoft Foundry (트래픽이 조직의 클라우드 계약 안에 머물러야 할 때).
- **OpenTelemetry export** — 세션 transcript, hook 결정(timestamp + allow/block verdict), 동시 세션 수 등이 조직 observability 스택으로 전달된다. 플레이북 측정 지표의 주요 출처 중 하나. [[agent-evaluation]]이 요구하는 "full production tracing"의 구체적 수단이다.

## Key Points

- **설정이 파일이고 파일이 repo에 있다.** 그래서 에이전트의 행동이 리뷰·감사·버전 관리의 대상이 된다.
- **plan mode는 도구가 강제하는 게이트다** — 계획 수락 전에는 파일을 편집할 수 없다.
- **auto mode는 가드레일이 성숙한 뒤의 기본값**이고, 그때 검토 대상은 행동이 아니라 아티팩트가 된다.
- **병렬 세션은 작업 수를, subagent는 집중을 늘린다.** 천장은 사람의 리뷰 능력.
- **skill은 advisory, hook은 deterministic.** 둘은 대체재가 아니라 계층이다.
- **비대화형 실행이 루프를 닫는 열쇠다** — stateless하게 시작하고 끝나므로 사람이 호출 경로에 없어도 된다.
- **dynamic workflow는 조정 로직을 컨텍스트 밖 코드로 옮긴다.** 병렬 세션(사람이 조정)·subagent(lead가 조정)와 구분되는 세 번째 조정 주체다.
- **Claude Code는 harness 중 하나다.** 여기 있는 기능의 상당수는 모델의 부족분을 메우는 구조이고, 모델이 좋아지면 일부는 불필요해진다. 통제 목적의 기능(plan mode, hook)은 그렇지 않다.
- **승인 기반 감독은 측정된 실패다** — 프롬프트의 93%가 승인된다. sandbox가 프롬프트를 84% 줄였고, auto mode는 sandbox **안에서 쓰는 한 겹**이지 대체재가 아니다(~17% 통과).
- **`CLAUDE.md`와 `.claude/settings.json`은 양면이다.** 리뷰 가능하다는 장점과 공격자가 커밋하면 매 세션 로드된다는 위험이 같은 속성에서 나온다.

## Related

- [[ai-native-sdlc]] — 이 기능들이 SDLC 6단계에 배치되는 방식
- [[agentic-governance]] — skill/hook/settings 계층과 production gate의 일반 원리
- [[artifact-chain]] — `CLAUDE.md`·`plan.md` 등이 만드는 아티팩트 체인
- [[dynamic-workflows]] — Dynamic workflows 기능의 개념·실패 모드·경제성
- [[agent-orchestration-patterns]] — 워크플로가 조합하는 여섯 가지 제어 구조
- [[subagent]] — 이 페이지의 subagent·병렬 세션이 속한 일반 개념
- [[orchestrator-worker]] — subagent를 쓰는 아키텍처의 일반 원리
- [[multi-agent-systems]] — 에이전트를 여럿 굴리는 것의 경제성과 적합 조건
- [[agent-evaluation]] — verifier subagent와 OTel export가 기여하는 평가 체계
- [[meta-harness]] — harness라는 범주 자체. 이 페이지의 기능들이 인코딩한 가정을 읽는 틀
- [[managed-agents]] — 이 harness가 얹힐 수 있는 하부 인터페이스. 경쟁 제품이 아니라 다른 층위
- [[agent-containment]] — 이 도구의 sandbox가 속한 세 격리 패턴 중 HITL 패턴
- [[prompt-injection]] — 보고된 취약점 3건과 피싱 사례가 속한 공격면

## Sources

- [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton, Anthropic / Claude Blog (2026-08-21)
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). Dynamic workflows 절의 출처
- [[2026-04-08-scaling-managed-agents]] — Lance Martin 외 2인 (Anthropic Engineering, 2026-04-08). "Claude Code는 harness 중 하나다" 절의 출처
- [[2026-05-25-how-we-contain-claude]] — Max McGuinness 외 4인 (Anthropic Engineering, 2026-05-25). 격리 아키텍처·취약점·sandbox 수치·auto mode 전제의 출처
