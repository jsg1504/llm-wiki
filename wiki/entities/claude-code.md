---
title: Claude Code
type: entity
created: 2026-09-11
updated: 2026-09-11
sources: [2026-08-21-the-ai-native-sdlc-playbook]
tags: [claude-code, anthropic, agentic-coding, tooling, ai-native]
status: draft
---

# Claude Code

> Anthropic의 에이전틱 코딩 도구. 이 페이지는 [[ai-native-sdlc]] 플레이북이 SDLC 각 단계에 배치하는 기능들 — plan mode, auto mode, `CLAUDE.md`, skills, hooks, subagents, worktrees, permissions/sandbox, 비대화형 실행 — 을 **통제와 워크플로우 관점에서** 정리한다.

> ℹ️ **범위 주의:** 현재 이 페이지의 내용은 단일 출처([[2026-08-21-the-ai-native-sdlc-playbook]])에 기반하며, 그 출처가 SDLC 맥락에서 언급한 기능만 다룬다. 도구의 전체 기능 목록이 아니다. 새 소스가 들어오면 보강한다.

## Overview

Claude Code는 저장소에 접근해 코드를 읽고, 편집하고, 명령을 실행하는 에이전트다. 플레이북에서의 위치는 단순한 "코드 생성기"가 아니다 — **버전 관리되는 설정 파일들(`CLAUDE.md`, skill, hook, agent 정의)이 조직의 정책과 지식을 담고, 에이전트가 매 세션 그것을 읽는다.** 즉 도구의 행동이 repo에 커밋된 텍스트로 결정되고, 따라서 리뷰·감사·버전 관리의 대상이 된다.

이 설계가 [[agentic-governance]]의 전제다. 설정이 파일이므로 코드처럼 다룰 수 있다.

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

병렬 세션은 **각자의 git worktree에서 별도 작업을 하는 완전한 Claude Code 인스턴스**다. 서로를 모르며, 공유하는 것은 그것들을 조종하는 엔지니어뿐이다.

- `claude --worktree feature-auth` 식으로 터미널마다 하나씩. worktree는 자기 브랜치의 별도 체크아웃이라 세션들이 파일에서 충돌하지 않는다.
- 작업을 **서로 다른 파일을 건드리는 단위로** 쪼갠다. 파일을 공유하는 작업은 한 세션에서 순차로.
- **2~3개가 합리적 출발점.** 실질적 천장은 *"한 사람이 제대로 리뷰할 수 있는 스트림 수"*이며, 리뷰가 따라가는 동안에만 늘린다.
- 전제: `CLAUDE.md`(모든 세션이 읽는다), 피드백 루프(세션이 자기 작업을 검증할 수 있으면 감독이 덜 필요하다), 안전한 명령에 대해 승인을 기다리지 않도록 튜닝된 permission 설정.

### Subagents

`.claude/agents/<name>.md`에 정의. **단일 세션 안에서** 자기 컨텍스트 윈도와 도구 제한을 갖고 도는 스코프된 헬퍼.

- 정의 요소: name, 언제 쓰는지에 대한 description, 건드릴 수 있는 tools.
- git에 체크인해 팀이 공유한다.
- 플레이북의 예시: 메인 에이전트가 끝난 뒤 불필요한 복잡도를 걷어내는 **code simplifier**, 앱을 돌려 동작을 확인하는 **verifier**, 메인 컨텍스트를 채우지 않고 코드베이스를 탐색해 보고하는 **researcher**.

**병렬 세션 vs subagent:** 병렬 세션은 엔지니어가 동시에 진행할 수 있는 작업 수를 늘리고, subagent는 각 세션이 자기 작업에 집중하게 유지한다. 엔지니어의 일은 그 전부를 조종하고 리뷰하는 것.

**verifier subagent vs 피드백 루프:** 피드백 루프는 작업 내내 필요한 만큼 반복된다. verifier subagent는 세션이 작업이 끝났다고 믿을 때 **신선한 컨텍스트 윈도로 한 번** 도는 최종 확인이다. 요점은 **판정이 코드를 만든 가정에 오염되지 않는다는 것.**

## 통제 표면

### Hooks

Claude가 행동하기 전에 실행되는 스크립트. **allow / ask / block** 중 하나를 한다. `.claude/settings.json`의 `PreToolUse` 등에 matcher와 함께 등록한다.

- 팀 hook은 git의 `.claude/settings.json`에, 협상 불가 hook은 엔지니어가 끌 수 없는 managed settings에.
- 차단은 **스스로를 설명해야 한다** — 이유와 승인 경로가 Claude 출력에 나타나야 한다. (예: exit 2로 차단하고 메시지를 stderr로)
- Claude가 행동하는 모든 곳에서 돈다. 특정 단계 전용이 아니다.

용도별 배치는 → [[agentic-governance]]

### Permissions / sandbox / managed settings

- `permissions.deny` / `allow` — 비밀을 컨텍스트에서 배제하고 안전한 inner loop는 미리 승인 (deny 목록이 프롬프트 피로가 되지 않게)
- `sandbox` — OS 수준 파일시스템·네트워크 격리. **permission이 닫지 못하는 구멍을 닫는다** (도구 수준 WebFetch deny는 셸 명령의 네트워크 접근을 막지 못한다)
- `credentials` — sandbox된 셸 명령이 `~/.ssh`, `~/.aws/credentials`를 읽거나 지정된 환경변수를 보는 것을 막는다
- managed settings — MDM이나 admin console로 배포되어 엔지니어·프로젝트 파일·CLI 플래그가 규칙을 넓히지 못하게 고정

### MCP

외부 시스템을 도구로 노출하는 경로. 플레이북에서의 용례:

- **레거시 시스템 연동** — Jira/ServiceNow가 source of truth일 때 세션 시작에 기록을 읽고 결과를 되쓴다. → [[artifact-chain]]
- **배포** — deploy·status·rollback을 환경별로 스코프된 도구로 노출. *"자격증명을 쥔 셸 스크립트가 아니라 allowlist."*
- **UI 검증** — 브라우저나 스크린샷 유틸리티를 물려 Claude가 결과를 볼 수 있게
- **인시던트 대응** — 지표가 baseline으로 돌아왔는지 확인

엔터프라이즈에서는 `allowManagedMcpServersOnly`로 에이전트의 도구 표면 전체를 플랫폼 팀이 소유하는 allowlist로 만들 수 있다.

## 통합과 관련 제품

플레이북이 언급하는 것들:

- **claude-code-action** — 자체 CI에서 리뷰와 수정 루프를 돌린다. 파이프라인 통제가 필요하거나 자체 클라우드 계약으로 모델 호출을 라우팅할 때.
- **Code Review** (research preview) — 관리형 리뷰 서비스. 관리자가 켜고 repo를 선택하면 되는 가장 빠른 출발점. `@claude review`로 새 리뷰 요청.
- **Claude Design** (beta) — `intent.md`에서 목업을 만들고 반복한 뒤 Claude Code로 내보내 구현.
- **Claude Security** (Enterprise public beta) — 스케줄된 코드베이스 스캔. Anthropic 인프라에서 Claude Mythos 5로 돌고, 각 finding이 보고 전에 검증되며 confidence rating이 붙는다. 제안된 패치는 Claude Code on the web에서 리뷰·적용.
- **Claude Tag** (public beta, Slack) — Claude가 자기 정체성으로 채널에 참여. 인시던트의 1차 대응자가 되고 채널 히스토리가 audit trail이 된다.
- **Cowork / claude.ai** — 엔지니어가 아닌 사람이 `intent.md`를 만드는 경로.
- **모델 접근 경로** — API, AWS Bedrock, Google Vertex, Microsoft Foundry (트래픽이 조직의 클라우드 계약 안에 머물러야 할 때).
- **OpenTelemetry export** — 세션 transcript, hook 결정(timestamp + allow/block verdict), 동시 세션 수 등이 조직 observability 스택으로 전달된다. 플레이북 측정 지표의 주요 출처 중 하나.

## Key Points

- **설정이 파일이고 파일이 repo에 있다.** 그래서 에이전트의 행동이 리뷰·감사·버전 관리의 대상이 된다.
- **plan mode는 도구가 강제하는 게이트다** — 계획 수락 전에는 파일을 편집할 수 없다.
- **auto mode는 가드레일이 성숙한 뒤의 기본값**이고, 그때 검토 대상은 행동이 아니라 아티팩트가 된다.
- **병렬 세션은 작업 수를, subagent는 집중을 늘린다.** 천장은 사람의 리뷰 능력.
- **skill은 advisory, hook은 deterministic.** 둘은 대체재가 아니라 계층이다.
- **비대화형 실행이 루프를 닫는 열쇠다** — stateless하게 시작하고 끝나므로 사람이 호출 경로에 없어도 된다.

## Related

- [[ai-native-sdlc]] — 이 기능들이 SDLC 6단계에 배치되는 방식
- [[agentic-governance]] — skill/hook/settings 계층과 production gate의 일반 원리
- [[artifact-chain]] — `CLAUDE.md`·`plan.md` 등이 만드는 아티팩트 체인

## Sources

- [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton, Anthropic / Claude Blog (2026-08-21)
