---
title: AI-Native SDLC
type: topic
created: 2026-09-11
updated: 2026-09-11
sources: [2026-08-21-the-ai-native-sdlc-playbook]
tags: [sdlc, agentic-coding, enterprise-ai, governance, ai-native]
status: draft
---

# AI-Native SDLC

> 코드 생성이 값싸지면 병목은 코드를 둘러싼 절차로 옮겨간다. AI-native SDLC는 6단계(Plan·Design·Build·Test·Deploy·Maintain)를 선형 핸드오프에서 **커밋된 아티팩트가 다음 단계를 트리거하는 루프**로 재설계한 것이다. agentic SDLC, AI SDLC라고도 불린다.

## Overview

전통 SDLC는 **구현이 가장 비싸고 느린 단계**라는 전제 위에서 효율을 최적화한 프로세스다. PRD, 추정 의식(estimation ritual), 제품 보안 리뷰는 몇 주에서 몇 분기에 달하는 개발 기간 동안 정렬을 강제하기 위해 존재했다. 각 단계는 별도 역할이 소유하고, 일은 문서·티켓·사인오프를 통해 이동한다.

에이전트가 그 전제를 깬다. Build가 몇 시간으로 붕괴하면 세 가지가 따라온다:

1. **병목이 좌우로 이동한다.** plan, review/test, deploy는 여전히 human speed로 돈다.
2. **통제가 현실과 어긋난다.** 사람이 한 줄씩 읽는 리뷰는 사람이 그 줄을 썼을 때 말이 됐다. 에이전트가 diff의 대부분을 쓰면 따라갈 수 없다.
3. **거버넌스 비용이 오히려 오른다.** 예외는 여전히 주·월 단위로 모이는 회의와 위원회를 통과해야 한다.

보안 팀이 전형적인 예다. 사람 산출량에 맞춰 인원이 잡혀 있으므로, 에이전트가 코드 산출을 몇 배로 늘리면 **리뷰 큐가 쌓이거나 미검토 코드가 나간다.** 규제 조직은 둘 다 수용할 수 없다.

따라서 AI-native SDLC의 목표는 "속도"가 아니라 **"감사 가능성과 승인 게이트를 유지한 채 얻는 속도"**다. 사람의 책임은 남고, 다만 그 주의가 어디에 놓이는지가 바뀐다. ([[2026-08-21-the-ai-native-sdlc-playbook]])

## 전통 SDLC와의 대비

대부분의 조직은 아래 두 열 사이 어딘가에 있다.

| Stage | Traditional | AI-native |
|---|---|---|
| **Plan** | 위원회가 요구사항을 모으고 워크숍·사인오프를 거쳐 손으로 작성 | 발안자가 Claude와 브레인스토밍해 자기 언어로 `intent.md`를 남긴다 |
| **Design** | 분석가가 spec을 쓰고 디자이너가 다시 파싱 (책임 분리를 위한 것이나 느리고 lossy) | 요구사항+설계가 한 세션으로 압축. 조직의 skill이 제약으로 작용하고 우려 지점은 **플래그된다** |
| **Build** | 테스트·코드 수작업. 문서는 개발이 끝난 뒤 | plan mode로 계획을 먼저 합의. 조직 지식은 `CLAUDE.md`와 skill로 버전 관리 |
| **Test** | 단계 경계의 QA 게이트 | 세션이 스스로 검증하는 피드백 루프 + 설정 변경에 걸리는 연속 eval |
| **Deploy** | 사람이 모든 줄을 리뷰. 거버넌스는 리뷰 사이클에서 일관성 없이 적용 | 계층화된 에이전트 리뷰. hook이 승인 게이트. 사람 리뷰는 규제·핵심 코드에 집중 |
| **Maintain** | 사람이 production을 지켜보고 티켓을 집어 올림 | 트리거가 사람 없이 Claude를 호출. 진단이 새 `intent.md`가 되어 루프에 되먹여짐 |

오른쪽 열을 관통하는 실은 **committed artifact**다. → [[artifact-chain]]

## 6단계

### Stage 1 — Plan: `intent.md`로 포착

아이디어가 누군가 받아 적어주기를 기다리지 않는다. 발안자가 Claude와 브레인스토밍하고, Claude가 조직 템플릿(skill로 인코딩)에 맞춰 `intent.md`를 쓰고, 발안자가 오해된 부분을 고쳐 커밋한다. 엔지니어가 아닌 사람도 참여하므로 인프라는 claude.ai 또는 Cowork + 버전 관리 커넥터(GitHub 등)면 충분하다 — git을 직접 쓸 필요는 없다.

아티팩트의 집은 보통 제품 repo 안 `intent/` 폴더다. 전용 intent repo는 intent가 여러 repo에 걸칠 때만 값어치를 한다.

- 구성: Problem / Proposed outcome / Affected users and systems / Constraints / Open questions
- leading: 첫 대화부터 커밋된 `intent.md`까지의 시간 (git history). 기대치는 몇 주 → 몇 시간
- lagging: **survival rate** — product owner가 Design으로 받아들인 `intent.md`의 비율

### Stage 2 — Design: 요구사항과 설계를 한 세션으로

승인된 `intent.md`를 입력으로 Claude가 `spec.md`를 생성한다. 조직의 brand·security·compliance·UX 정책이 **skill로** 로드되어 제약이 된다. product owner는 spec을 **리뷰하되 쓰지는 않는다.**

핵심은 프롬프트가 **"만족시킬 수 없는 상충 정책을 명확히 기술하라"**고 요구한다는 점이다. 플래그된 우려를 엔지니어링이 spec을 보기 전에 정책 소유자와 해소한다. 몇 주 뒤 리뷰에서 발견되는 대신 **spec이 쓰이는 동안 살아있는 정책이 읽히고 적용된다.**

프론트엔드는 가장 선명한 사례 — `intent.md`에서 Claude Design으로 목업을 만들고, 반복한 뒤 Claude Code로 내보내 구현한다.

- leading: `intent.md` 커밋 → `spec.md` 커밋 사이 경과 시간 (git timestamp 2개)
- lagging: build 시작 후 요구사항 재작업 — 첫 `plan.md` 이후 날짜의 `spec.md` 커밋 수

### Stage 3 — Build: 계획 없이 구현하지 않는다

**plan mode가 기본 출발점이다.** Claude는 코드베이스를 읽되 바꾸지 못하는 상태에서 계획을 세우고, 엔지니어가 "이 변경이 무엇을 깨뜨릴 수 있나", "가장 위험한 단계는", "선택하지 않은 대안은 무엇인가"를 물어 심문한다. 합격 기준이 구체적이다 — *대화를 본 적 없는 엔지니어가 계획만 보고 구현할 수 있을 때까지.* 승인된 계획은 `plan.md`로 커밋되고, 나중에 Deploy 단계의 PR 리뷰가 **실제 diff를 이 계획과 대조**한다.

거버넌스 관점에서 plan mode의 가치는 도구가 스스로 강제한다는 것이다 — 엔지니어가 계획을 수락하기 전에는 Claude가 파일을 편집할 수 없다. 즉 설계 리뷰가 **코드가 생성되기 전, 방향 전환이 아직 문서 편집으로 끝나는 시점에** 일어난다.

가드레일이 성숙하면(튜닝된 `CLAUDE.md`, 정책을 인코딩한 skill, 위험한 동작을 막는 hook, Claude가 돌릴 수 있는 테스트 suite) **auto mode**가 일상 작업의 기본이 된다. 이때 검토 대상은 "에이전트가 편집하는 것을 지켜보기"에서 "더 긴 자율 세션 이후의 아티팩트"로 옮겨간다.

이 단계의 하위 주제들:
- **`CLAUDE.md`** — 신규 입사자가 첫날 필요할 것. 한 페이지 이하. `/init`으로 시작해 잘라낸다. 규칙: **Claude가 같은 실수를 두 번 하면 교정이 여기 들어간다.**
- **skills as institutional knowledge** — 일관되게 적용되어야 하는 조직 지식을 skill로. 판단 기준: `CLAUDE.md`나 프롬프트에 속할 것은 skill로 쓰지 않는다.
- **hooks as build-time guardrails** — 보호 경로 편집 차단, 편집 후 포매터·린터 실행, 자격증명 유출 방지. 빠르고 변경된 파일에 스코프되어야 한다. 무거운 검사는 commit이나 PR로.
- **parallel sessions and subagents** — worktree로 격리된 병렬 세션 vs 세션 내부의 스코프된 subagent. → [[claude-code]]

### Stage 4 — Test: 세션이 스스로 검증한다

**모든 세션에 자기 작업을 검증할 방법을 준다** — 테스트, 빌드, 스크린샷 diff. Claude가 통과할 때까지 반복하므로 엔지니어에게 도달하는 것은 이미 검사를 통과한 것이다. 목표는 정량화되어야 한다("test_status.py의 모든 테스트 통과", "스크린샷이 첨부된 목업과 일치", "엔드포인트가 새 필드와 함께 200 반환").

피드백 루프(작업 내내 반복)와 verifier subagent(작업이 끝났다고 믿을 때 **신선한 컨텍스트로 한 번** 확인)는 다르다. 후자의 요점은 판정이 코드를 만든 가정에 오염되지 않는다는 것.

**루프 자체를 보호해야 한다.** 코드를 고치는 에이전트가 그 코드에 대한 검사를 약화시킬 수 있으면 안 된다. 버그 수정은 실패하는 테스트를 먼저 쓰고 커밋한 뒤, 테스트 파일 편집을 막는 hook 아래에서 통과시킨다.

**연속 eval**은 stage-gate QA의 AI-native 대응물이다. 실제 작업 20~50개를 프롬프트+합격 조건으로 만들고, `CLAUDE.md`·skills·hooks가 바뀔 때와 스케줄에 CI에서 비대화형으로 돌린다. 통과율을 떨어뜨리는 설정 변경은 머지 전에 리뷰된다. **production incident 하나당 eval 하나**를 추가해 영구 회귀 테스트로 남긴다. 모델이 좋아지면 변별력을 잃은 케이스를 교체해야 하는 살아있는 suite다.

### Stage 5 — Deploy: 리뷰는 양방향, 게이트는 hook

Claude는 리뷰를 **주기도 하고 받기도 한다.** 모든 PR이 동일한 리뷰 pass 집합을 받고 findings는 심각도로 랭크된다. 정책은 repo 루트의 `REVIEW.md`에 쓰인다 — pass 구분(Bugs/Security/Compliance), Important와 Nit의 경계, nit 상한, 보고 제외 대상(생성 파일, CI가 이미 강제하는 것).

- findings 자체는 PR을 승인하거나 차단하지 않는다. branch protection이 여전히 code owner 승인을 요구한다.
- `@claude` 태그로 리뷰 코멘트를 처리하고 수정을 푸시한다. PR 스레드가 요청과 변경을 모두 기록한다.
- **리뷰 findings가 `CLAUDE.md`로 되먹여진다.** 같은 실수가 두 번째로 플래그되면 그 리뷰의 일부로 교정이 `CLAUDE.md`에 들어가고, 리뷰가 `CLAUDE.md`를 읽으므로 다음 PR부터 잡힌다.
- 월 1회 tech lead가 findings를 평가해 튜닝하고 nit 양을 조절한다.

**hook은 승인 게이트다.** Build 단계의 hook이 사람 없이 allow/block 했다면, Deploy의 hook은 **ask** 한다 — 특정 인물이 승인할 때까지 동작을 멈춘다. 팀 hook은 git의 `.claude/settings.json`에, 협상 불가 hook은 개별 엔지니어가 끌 수 없는 managed settings에 둔다. 차단은 스스로를 설명해야 한다 — 이유와 승인 경로가 Claude 출력에 나타나야 한다.

**CI/CD 통합**의 지배 원칙: *에이전트는 production gate까지 행동할 수 있고 그것을 넘을 수 없다.* 읽기 전용 판단 작업(실패한 빌드 분류, flaky 테스트 요약, 체인지로그 초안)부터 시작해, 쓰기 작업은 기존 게이트 뒤에 추가한다. 배포는 MCP로 노출해 deploy·status·rollback이 환경별로 스코프된 **도구**가 되게 한다 — 자격증명을 쥔 셸 스크립트가 아니라 allowlist. 자율성은 환경별로 티어링한다(development는 자유, production은 release manager 승인). **rollback은 파이프라인에서 가장 많이 리허설된 경로여야 한다** — Stage 6이 이것을 호출하므로 미리 증명되어 있어야 한다.

→ [[agentic-governance]]

### Stage 6 — Maintain: 루프가 닫힌다

여기서 사람이 호출 경로에서 빠진다. 결정론적 스크립트가 production을 감시하다 **control band**가 깨지면 Claude를 부른다.

1. 안정적인 rolling baseline을 가진 지표 하나를 고른다 (CI 테스트 실패율, 배포 후 5xx율, PR cycle time).
2. 탐지 스크립트를 쓴다 — rolling window의 평균·표준편차에 Western Electric류 규칙. **버전 관리되고 단위 테스트되며, 모델이 전혀 개입하지 않는다.**
3. 대응 티어를 버전 관리 config(`bands.yaml`)에 정의: 1σ 로그만 / 2σ read-only 진단 / 3σ 행동 허용(단 PR을 열거나 사전 승인된 runbook 트리거로만).
4. Claude는 stateless·비대화형으로 돈다. 그래서 **아무도 시작하지 않아도 루프가 시작되고 끝난다.**
5. 에이전트는 진단을 Stage 1 형식의 `intent.md`로 쓴다. 거기서부터는 다른 모든 것과 같은 파이프라인을 탄다.
6. 서비스 오너가 큐를 triage한다 — 지금 고칠지, 스케줄할지, 기각할지. **기각은 band를 튜닝해 노이즈를 줄인다.**
7. 수정이 나가면 해당 사건에 대한 eval을 추가한다.

같은 패턴의 변주 둘:
- **recurring codebase scans** — 보안 스캔은 "특정 시점, 특정 모델 기준의 진술"이라 양쪽 다 낡는다. 코드는 매주 바뀌고, 각 모델 세대는 이전 세대가 놓친 취약점을 찾는다. 답은 스케줄 스캔. 한 PR에 들어가는 수정은 리뷰 게이트로, 그보다 큰 것은 `intent.md`로. Claude Security가 호스팅 형태.
- **Claude Tag** — Slack 등 채널에 Claude가 자기 정체성으로 참여해 야간 인시던트의 1차 대응자가 된다. 채널 히스토리가 audit trail이 되고, 사후 분석은 버전 관리되는 lessons 파일에 쓰여 다음 조사가 읽는다. 작고 경계가 분명한 수정은 PR로, 큰 것은 `intent.md`로.

## 도입 순서

play들은 의존성 그래프를 갖는다. 각 play가 "Prerequisites"로 자기 의존성을 명시하며, **선행 조건이 없는 play(`CLAUDE.md`, `intent.md` 포착, skill 작성, 피드백 루프, hook)부터 아무거나 시작할 수 있다.** 단계 순서와 도입 순서는 같지 않다.

주목할 의존성:
- CI/CD 통합은 **PR 리뷰와 승인 게이트가 먼저 존재해야 한다** — "게이트는 자동화가 무언가를 가속하기 전에 존재해야 하기 때문".
- 병렬 세션은 `CLAUDE.md`와 피드백 루프에 의존한다 — 세션이 자기 작업을 검증할 수 있어야 감독이 덜 필요하다.
- 루프 닫기는 `intent.md` 형식, 가속된 PR 리뷰, 행동 경계로서의 hook, 그리고 **증명된 rollback 경로**에 의존한다.

## 레거시 시스템과 source of truth

이미 Jira에 work item이, 규제 추적성을 갖춘 도구에 요구사항이, Figma에 디자인이, change board에 승인이 있다. 이들은 감사인과 규제기관이 이미 수용하고 다른 팀이 의존하므로 밀어내기 어렵다. AI-native SDLC는 **존재하는 것에 맞춰 들어가야 한다.**

규칙은 하나다 — **아티팩트마다 하나의 시스템을 source of truth로 지명하고, 나머지는 사본이나 링크를 갖는다.** 세 가지 구성:

- **repo가 source of truth** — 마크다운 아티팩트가 권위 있는 기록이고 레거시가 커밋 내 파일을 참조. 엔지니어링 주도 조직에 가장 깔끔하다(한 도구, 한 timestamp authority).
- **레거시가 source of truth** — Jira/ServiceNow가 권위 있고 마크다운은 작업 사본. Claude가 세션 시작에 기록을 읽고 MCP 커넥터로 결과를 되쓴다.
- **linkage가 최소선** — 모든 아티팩트가 record ID를, 모든 레거시 record가 마크다운 파일의 commit SHA를 갖는다. source of truth가 둘이라는 것을 받아들이는 전환기 출발점.

## Key Points

- **병목은 build가 아니라 그 주변이다.** 코드 생성 속도만 올리면 리뷰 큐가 쌓이거나 미검토 코드가 나간다.
- **단계 간 인터페이스는 회의가 아니라 커밋된 파일이다.** 그리고 그 커밋 체인이 audit trail을 공짜로 준다.
- **초기 단계가 마크다운인 이유는 product owner와 에이전트가 같은 파일을 읽을 수 있어서다.** 포맷 선택이 아니라 협업 구조의 선택.
- **탐지는 결정론적, 대응은 티어링.** 모델은 band가 깨진 뒤에만 부른다.
- **skill은 위반을 드물게, hook은 거의 불가능하게 만든다.** 어느 쪽이 필요한지는 "이 정책이 예외 없이 성립해야 하는가"로 결정된다.
- **에이전트는 production gate까지, 그리고 코드를 쓴 에이전트는 그것을 승인할 수 없다.**
- **측정 지표는 이미 있는 데이터에서 나온다** — git history, PR metadata, CI, incident tracker, OTel.
- **병렬성의 천장은 에이전트 수가 아니라 사람의 리뷰 능력이다.**

## Open Questions

- 이 플레이북에는 **정량 데이터가 없다.** "몇 주 → 몇 시간" 같은 기대치는 있으나 고객 사례 수치는 없다. 실제 도입 조직의 leading/lagging indicator 실측은 어디서 볼 수 있나?
- product owner가 spec을 "리뷰하되 쓰지 않는다"면, 리뷰 품질을 유지하는 역량은 어떻게 길러지나? 쓰지 않으면서 읽는 눈이 유지될까?
- "리뷰가 따라가는 동안에만 세션을 늘린다"는 실용적이지만, 리뷰 능력 자체를 측정하는 지표는 제시되지 않는다.
- eval suite의 유지 비용 — "모델이 좋아지면 변별력 잃은 케이스를 교체"해야 한다면 suite 자체가 지속적 부담 아닌가?

## Related

- [[artifact-chain]] — 이 토픽의 구조적 척추. 단계 간 인터페이스가 어떻게 작동하는지
- [[agentic-governance]] — Deploy·Build 단계 통제의 일반화. skill/hook/settings 계층과 production gate
- [[claude-code]] — 이 플레이북이 각 단계에 배치하는 도구

## Sources

- [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton, Anthropic / Claude Blog (2026-08-21)
