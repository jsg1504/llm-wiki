---
title: Agentic Governance
type: concept
created: 2026-09-11
updated: 2026-09-12
sources: [2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows]
tags: [governance, enterprise-ai, agentic-coding, security, compliance, ai-native]
status: draft
---

# Agentic Governance

> 에이전트가 코드를 쓰는 환경에서 통제를 유지하는 방법. 핵심은 **통제가 계층이라는 것** — skill은 advisory, hook은 deterministic, managed settings는 강제. 그리고 하나의 경계: 에이전트는 production gate까지 행동하고 그것을 넘지 못한다.

## Overview

에이전트가 diff의 대부분을 쓰기 시작하면 기존 통제가 무너지는 방식은 두 가지다.

**리뷰 기반 통제는 산출량에 깔린다.** 사람이 한 줄씩 읽는 리뷰는 사람이 그 줄을 썼을 때 성립했다. 보안 팀은 사람 산출량에 맞춰 인원이 잡혀 있으므로, 코드 산출이 몇 배가 되면 리뷰 큐가 쌓이거나 미검토 코드가 나간다. 규제 조직은 둘 다 수용할 수 없다.

**사후 발견 기반 통제는 타이밍이 어긋난다.** 정책 위반을 몇 주 뒤 리뷰에서 발견하는 모델은, 그 사이 에이전트가 생산한 양을 감당하지 못한다.

agentic governance의 답은 **통제를 리뷰에서 행동 시점으로 옮기는 것**이다. 정책은 코드가 쓰이는 동안 읽히고 적용되며, 예외 없이 성립해야 하는 것은 애초에 실행 불가능하게 만든다. ([[2026-08-21-the-ai-native-sdlc-playbook]])

## 통제의 세 계층

이 구분이 이 개념의 핵심이다.

| 계층 | 성격 | 보장 수준 | 누가 소유 | 우회 가능성 |
|---|---|---|---|---|
| **skill** | advisory | 정책이 적용될 **가능성이 높다** | 정책 소유자 (엔지니어가 작성) | 세션이 따르지 않을 수 있음 |
| **hook** | deterministic | 매칭되는 모든 동작에 **매번 실행** | 팀 (`.claude/settings.json`, git) | repo 설정을 바꾸면 가능 |
| **managed settings** | 강제 | 조직 차원에서 **고정** | 플랫폼/IT 관리자 (MDM·admin console) | 엔지니어·프로젝트 파일·CLI 플래그 어느 것도 불가 |

원문의 정식화: *"A skill is a control, though an advisory one... nothing forces a session to comply with it. A policy that must always hold needs something deterministic behind the skill, such as a hook that blocks the action or a review pass that re-checks the policy at the PR. **The skill makes violations rare and the hook makes them close to impossible.**"*

판단 기준은 하나다 — **"이 정책이 예외 없이 성립해야 하는가?"** 그렇다면 skill만으로는 부족하고 뒤에 결정론적 계층이 필요하다.

### skill — 조직 지식을 작동시키는 층

skill은 조직의 제도적 지식(institutional knowledge)을 실행 가능하게 만드는 방법이다. 지시가 명시적이고, 버전 관리되고, 넓게 적용되고, 정책이 바뀌면 중앙에서 갱신된다. 엔지니어는 다음 세션에서 새 버전을 자동으로 집는다.

- 작성 기준: **일관되게 적용되어야 하는 조직 지식**은 skill로. `CLAUDE.md`나 프롬프트에 속하는 것은 skill로 쓰지 않는다.
- 출발점: 오늘 **일관성 없이 강제되고 있는** 지식 하나를 고른다 (보안 표준, API 설계 규약, 브랜드 규칙).
- 배포: repo의 `.claude/skills/<name>/`에 두어 코드와 함께 배송하거나, plugin으로 조직 전체에 배포.
- **트리거 테스트가 필수다.** 관련 작업을 여러 방식으로 요청해 skill이 매번 로드되는지 확인한다.
- 측정: PR 리뷰 findings 중 해당 정책을 인용하는 것의 수. skill이 코드 작성 중 정책을 적용하고 있다면 0으로 수렴해야 한다. **수렴하지 않으면 skill이 트리거되지 않거나 텍스트가 공식 정책에서 드리프트한 것이다.**

### hook — 결정론적 층

hook은 Claude가 행동하기 전에 실행되어 **allow, ask, block** 중 하나를 한다. 이 세 동작이 서로 다른 단계에 대응한다.

**Build 단계 — 사람 없이 allow/block (guardrail):**
- 보호 경로 편집 차단 (생성된 클래스, 동결된 패키지)
- 파일 편집 후 포매터·린터 실행해 드리프트가 누적되지 않게
- 자격증명이 diff에 들어가지 않게

Claude의 동작 대부분이 구현 중의 파일 편집과 셸 명령이므로 build 단계가 hook이 가장 자주 발사되는 곳이다. 따라서 **빠르고 변경된 파일에 스코프**되어야 한다. 전체 테스트 suite 같은 무거운 검사는 commit이나 PR에 속한다.

**Deploy 단계 — 사람에게 ask (approval gate):**
- change management 사인오프, release authorization, 보호 경로 편집
- 차단은 **스스로를 설명해야 한다** — 이유와 승인 경로가 Claude 출력에 나타나야 한다

중요한 배치 원칙: **승인을 요구하는 hook은 build에 두지 않는다.** 빌드 중의 승인 프롬프트는 병렬로 도는 모든 세션의 critical path에 사람을 다시 올려놓는다.

**Test 단계 — 피드백 루프 보호:**
버그 수정 중 테스트 파일 편집을 막는다. *"코드를 고치는 에이전트가 그 코드에 대한 검사를 약화시킬 수 있으면 안 된다."* 수정 이전에 존재했고 에이전트가 고쳐 쓸 수 없었던 테스트만이 버그가 사라졌다는 증거가 된다.

hook은 특정 단계에 속하지 않는다 — **Claude가 행동하는 모든 곳에서 돈다.**

### managed settings — 조직 차원의 고정

규제 엔터프라이즈에서는 플랫폼 팀이 MDM이나 admin console로 배포하고 엔지니어가 편집·무시할 수 없게 한다. 플레이북의 워크드 예시가 보여주는 통제 축:

- `permissions.deny` / `allow` — 비밀을 에이전트 컨텍스트에서 배제하고, 안전한 inner loop는 미리 승인해 **deny 목록이 프롬프트 피로로 변하지 않게** 한다.
- `disableBypassPermissionsMode` + `allowManagedPermissionRulesOnly` — 엔지니어·프로젝트 파일·CLI 플래그 어느 것도 규칙을 넓히지 못한다.
- `sandbox` — **permission이 닫지 못하는 구멍을 닫는다.** WebFetch에 대한 도구 수준 deny는 셸 명령이 네트워크에 닿는 것을 막지 못한다. OS 수준 도메인 allowlist가 egress를 원천 차단한다.
- `failIfUnavailable` + `allowUnsandboxedCommands: false` — sandbox를 게이트로 만든다. 초기화 실패 시 Claude Code가 시작을 거부하고, sandbox 안에서 실패한 명령을 밖에서 재시도할 수 없다.
- `credentials` — deny 규칙이 남긴 구멍을 닫는다. `permissions.deny`는 Claude의 **파일 도구**를 지배하지만 sandbox된 셸 명령은 기본적으로 `~/.ssh`나 `~/.aws/credentials`를 읽을 수 있다.
- `allowManagedHooksOnly` — 승인 게이트가 돌아가는 **유일한** hook이 된다.
- `disableSideloadFlags` + `strictKnownMarketplaces` + `allowManagedMcpServersOnly` — 모든 skill·agent·hook·MCP 서버가 조직의 승인된 marketplace를 통해서만 도착한다.
- `requiredMinimumVersion` — 조직이 실제로 평가한 빌드에서만 통제가 강제되게 한다.

핵심 패턴이 반복된다: **각 계층은 이전 계층이 남긴 구멍을 닫는다.** permission → sandbox → credentials가 그 예다. 통제 하나가 완결적이라고 가정하지 않는 설계.

문서 자신의 단서: 이것은 *"복사하라는 권고가 아니라 재단할 출발점"*이며 **모든 deny는 capability와의 트레이드오프**다. 올바른 균형은 repo의 데이터 분류에 달려 있다.

## 경계: production gate

지배 원칙 하나로 요약된다.

> **에이전트는 production gate까지 행동할 수 있고, 그것을 넘을 수 없다.**
> *(the agent may act up to the production gate and cannot pass it)*

이를 강제하는 통제들:
- **branch protection** — 에이전트가 쓴 모든 것이 PR이 된다. main으로 가는 직접 경로가 없다.
- **production deploy hook** — 지명된 release manager가 승인할 때까지 릴리스를 막는다.
- **환경별 permission 티어** — development에서는 자유롭게 배포, staging은 중간, production은 에이전트가 릴리스를 준비하고 사람이 승인.
- **에이전트 고유 identity** — 각 비대화형 실행이 자기 정체성으로 동작하므로, 파이프라인 로그가 에이전트가 한 일과 트리거한 엔지니어가 한 일을 분리한다.

### separation of duties

> *"the agent that wrote the code has no way to approve it"*

이 원칙이 여러 곳에서 반복된다:
- PR 리뷰에서 — findings는 PR을 승인하거나 차단하지 **않는다.** branch protection이 여전히 code owner 승인을 요구하고, 사람이 findings를 참고해 판단한다.
- 보안 스캔에서 — *"수정을 제안한 에이전트는 그것을 승인할 route가 없다."* 수정은 스캔 자체가 아니라 PR 리뷰 게이트와 branch protection을 통해 production에 도달한다.

즉 에이전트의 산출량이 아무리 늘어도 **승인의 병목은 의도적으로 사람에 남긴다.** 이것이 "속도를 위해 통제를 포기하지 않는다"는 문서 전체의 입장이다.

## Quarantine: 권한을 에이전트 단위로 쪼갠다

앞의 세 계층(skill / hook / managed settings)이 **한 에이전트가 무엇을 할 수 있는가**를 통제한다면, 여러 에이전트를 돌릴 때는 **어떤 에이전트가 무엇을 할 수 있는가**라는 축이 하나 더 생긴다.

[[2026-08-20-a-harness-for-every-task-dynamic-workflows]]가 대규모 triage 워크플로에서 권하는 **quarantine 패턴**:

> 신뢰할 수 없는 공개 콘텐츠를 읽는 에이전트가 **고권한 행동을 하지 못하게 막고**, 행동은 그 정보를 넘겨받은 별도 에이전트가 한다.

읽기와 행동을 다른 에이전트에 둔다는 것이 전부다. 효과는 **prompt injection을 아키텍처 층위에서 무력화**하는 것 — 주입된 지시를 읽은 에이전트에게는 실행할 권한이 없고, 권한을 가진 에이전트는 주입된 텍스트를 보지 않는다.

이것은 위 **separation of duties** 절의 원리를 **에이전트 사이로** 확장한 것이다. 사람과 에이전트의 역할을 나누는 것과 같은 발상이며, 통제 수단도 이미 있는 것들이다 — subagent 정의의 `tools` 제한([[subagent]]), `permissions.deny`, sandbox. 새로운 것은 **그 제한을 워크플로 설계 시점에 역할별로 배치한다**는 점이다.

> ⚠️ 소스가 이 패턴을 한 문단으로만 언급하며, 구현 예시나 실패 사례는 제시하지 않는다. 원리는 분명하지만 이 위키에는 아직 **검증된 레시피가 없다.**

## 인간 주의의 재배치

통제를 옮기는 것의 목적은 사람을 빼는 것이 아니라 **사람의 주의를 값어치 있는 곳에 놓는 것**이다.

- 리뷰에서 사람이 판단하는 것: **"이 변경이 plan이 의도한 것을 하는가"**와 **"리스크가 수용 가능한가"** — intent와 risk.
- 기계적 증거(테스트 출력, 빌드 로그, 스크린샷 diff)는 이미 첨부되어 있다. 리뷰어가 그것을 재생산할 필요가 없다.
- Build 단계에서는 주의가 "에이전트가 편집하는 것을 지켜보기"에서 **"더 긴 자율 세션 이후의 아티팩트 리뷰"**로 옮겨간다.
- 처음에는 각 단계를 손으로 프롬프팅하다가, 종착점은 각 승인된 아티팩트가 다음 게이트를 발사하는 루프다. **사람의 주의는 게이트에 집중되어, 매 단계를 처음부터 시작하는 대신 에이전트가 플래그한 것을 검토한다.**

*"Humans remain accountable for every decision that requires judgment."*

## 증거와 감사

거버넌스가 성립하려면 증거가 있어야 한다. 이 접근의 강점은 **증거가 이미 존재하는 시스템에서 나온다**는 것이다.

| 무엇이 강제되나 | 증거는 무엇인가 | 어디에 기록되나 | 누가 승인하나 |
|---|---|---|---|
| 완료 보고 전 검증 | `make test`의 실제 출력, 빌드 로그, 스크린샷 diff | 세션 transcript (OTel export), PR check run | PR을 리뷰하는 code owner |
| spec이 정책을 준수 | spec, 그것을 만든 프롬프트, 적용된 skill 버전 | 버전 관리 | product owner, 플래그는 정책 소유자에게 라우팅 |
| 코드 생성 전 설계 리뷰 | `plan.md`와 그 리비전, 수락한 사람 | git history | 엔지니어, 고위험은 tech lead |
| 승인 게이트 | allow/block 결정과 timestamp | OTel export | hook이 정의한 승인 주체 |
| 릴리스 경계 | PR history, 파이프라인 로그 | GitHub, CI | release manager |

세 가지 로그가 반복 등장한다 — **git history, PR metadata, OpenTelemetry export.** 새 감사 인프라를 만들지 않고 이미 감사받고 있는 것을 재사용한다. → [[artifact-chain]]

## 설정도 회귀 테스트한다

`CLAUDE.md`·skills·hooks는 에이전트를 조종하는 설정이므로 **코드가 받는 회귀 테스트를 받아야 한다.**

- 실제 작업 20~50개를 프롬프트 + 합격 조건(테스트 통과, lint 청결, 동작 불변, 정책 준수)으로 만든다.
- 설정 변경 PR과 스케줄에 CI에서 비대화형으로 돌린다.
- **통과율을 떨어뜨리는 설정 변경은 머지 전에 리뷰된다.** 이것이 eval을 merge check로 만드는 지점.
- production incident 하나당 eval 하나를 추가해 영구 회귀 테스트로 남긴다.

이것은 governance의 메타 계층이다 — 통제 자체가 작동하는지를 통제한다.

## Key Points

- **여러 에이전트를 돌리면 통제 축이 하나 늘어난다** — 무엇을 할 수 있는가에 더해 **누가** 할 수 있는가. quarantine 패턴이 그 최소 형태다.

- **통제는 계층이다.** skill(advisory) < hook(deterministic) < managed settings(강제). 판단 기준은 "이 정책이 예외 없이 성립해야 하는가".
- **각 계층은 이전 계층이 남긴 구멍을 닫는다.** permission → sandbox → credentials. 통제 하나가 완결적이라 가정하지 않는다.
- **hook의 세 동작이 단계에 대응한다.** build는 allow/block, deploy는 ask. 승인 프롬프트를 build에 두면 병렬 세션 전체의 critical path에 사람이 올라간다.
- **에이전트는 production gate까지.** 그리고 코드를 쓴 에이전트는 그것을 승인할 route가 없다.
- **사람의 주의는 라인에서 게이트로.** 판단 대상은 intent와 risk이고, 기계적 증거는 이미 첨부되어 있다.
- **증거는 기존 시스템에서 나온다** — git history, PR metadata, OTel export.
- **모든 deny는 capability와의 트레이드오프다.** 올바른 균형은 repo의 데이터 분류에 달려 있다.
- 설정(`CLAUDE.md`, skills, hooks)도 eval suite로 회귀 테스트한다.

## Open Questions

- skill이 "트리거되지 않는 것"과 "텍스트가 정책에서 드리프트한 것"을 어떻게 구분해 진단하나? 플레이북은 findings가 0으로 수렴하지 않으면 둘 중 하나라고만 말한다.
- hook이 늘어날수록 세션 지연이 쌓인다. "빠르고 스코프되어야 한다"는 지침은 있으나 예산이나 측정 방법은 제시되지 않는다.
- 승인 게이트가 사람에 남는다면, 에이전트 산출량이 늘 때 **승인자**의 병목은 어떻게 다루나? 리뷰는 에이전트에 위임했지만 승인은 위임할 수 없다.

## Related

- [[dynamic-workflows]] — quarantine이 등장하는 맥락. 여러 에이전트를 돌릴 때의 통제
- [[agent-orchestration-patterns]] — 역할별 에이전트 배치의 제어 구조

- [[ai-native-sdlc]] — 이 통제들이 배치되는 6단계 프로세스
- [[artifact-chain]] — 승인 게이트가 걸리는 대상이자 audit trail의 기반
- [[claude-code]] — skill·hook·permission·sandbox·managed settings의 구현

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — quarantine 패턴 (Quarantine 절)
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton, Anthropic / Claude Blog (2026-08-21)
