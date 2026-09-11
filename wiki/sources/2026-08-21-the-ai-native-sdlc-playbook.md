---
title: The AI-Native SDLC playbook
type: source
created: 2026-09-11
updated: 2026-09-11
source_file: ../../raw/articles/2026-08-21-the-ai-native-sdlc-playbook.md
source_url: https://claude.com/blog/the-ai-native-sdlc-playbook
author: Louis Claxton
publisher: Anthropic / Claude Blog
source_date: 2026-08-21
tags: [sdlc, claude-code, agentic-coding, enterprise-ai, governance, ai-native]
status: mature
---

# The AI-Native SDLC playbook

> 코드 작성이 더 이상 병목이 아니게 되자 병목은 그 좌우(plan·review·deploy)로 옮겨갔다. 답은 SDLC 6단계를 전부 에이전트 중심으로 재설계하고, 각 단계가 **커밋된 아티팩트**로 끝나 다음 단계를 트리거하는 루프로 바꾸는 것이다.

## Context

Anthropic Applied AI 팀이 엔터프라이즈 고객사와 일하며 축적한 실무를 정리한 플레이북. 저자 Louis Claxton, 2026-08-21 Claude Blog 게재. Jim Blackhurst, Will Steuk, Jamal Arif의 선행 작업에 기반한다고 밝히고 있다.

독자 상정은 명확히 **규제 산업의 대규모 조직**이다. "속도를 올려라"가 아니라 "감사(audit) 가능성과 승인 게이트를 유지한 채로 속도를 올려라"가 문서 전체의 제약 조건이다. 이 전제를 놓치면 문서의 절반(governance considerations 섹션들)이 과잉으로 보인다.

문서는 자기 자신을 "playbook"이라 부르며 6단계 × 복수의 **play**로 구성된다. 각 play는 동일한 5개 슬롯을 갖는다: What changes / Getting started(Prerequisites·Infrastructure) / How to execute it / Governance considerations / How to measure it(leading·lagging indicator).

## Key Claims

1. **코드는 더 이상 병목이 아니다.** Build 단계가 몇 시간으로 붕괴하면 세 가지가 참이 된다 — (a) 병목이 build의 좌우, 즉 plan·review/test·deploy로 이동한다, (b) 통제가 현실과 맞지 않게 된다("사람이 썼을 때 한 줄씩 읽는 것은 말이 됐지만, 에이전트가 diff의 대부분을 쓰면 따라갈 수 없다"), (c) 예외가 여전히 주·월 단위로 모이는 위원회를 거치므로 거버넌스 비용이 **증가**한다.

2. **committed artifact가 단계 간 인터페이스다.** 각 단계는 아티팩트를 버전 관리에 커밋하며 끝나고, 다음 단계는 그것을 읽으며 시작한다: `intent.md` → `spec.md` → `plan.md` → diff와 테스트 → PR과 review findings → incident record. 초기 단계가 `.md`인 이유는 **product owner와 에이전트가 같은 파일을 읽고 행동할 수 있기 때문**이다. Build 이후로는 아티팩트가 코드와 그 기록이 된다. → [[artifact-chain]]

3. **커밋 체인이 곧 audit trail이다.** "누가 무엇을 요청했고, 에이전트가 무엇을 만들었고, 누가 승인했는가"가 git history에 그대로 남는다. 별도의 추적 시스템을 만드는 대신 이미 감사받고 있는 시스템을 재사용한다.

4. **선형 프로세스가 루프가 된다.** 승인된 `intent.md`가 design pass를 트리거하고, 승인된 `spec.md`가 plan mode를 트리거하고, 머지된 PR이 파이프라인을 트리거하고, production에서 **breached control band**가 다음 `intent.md`를 쓴다. 처음에는 각 단계를 손으로 프롬프팅하다가, 종착점은 각 승인된 아티팩트가 다음 게이트를 발사하는 루프다.

5. **탐지는 결정론적으로 유지하고 모델은 band가 깨진 뒤에 부른다.** 감시 스크립트는 rolling window의 평균·표준편차에 Western Electric류 규칙을 적용하며 "모델이 개입하지 않는다(detection stays entirely deterministic, with no model involved)". 대응만 티어링한다 — 1σ는 로그만, 2σ는 read-only 진단, 3σ는 PR을 열거나 사전 승인된 runbook을 트리거하는 것까지 허용.

6. **통제는 계층이다: skill은 advisory, hook은 deterministic.** 원문: *"A skill is a control, though an advisory one... nothing forces a session to comply with it. A policy that must always hold needs something deterministic behind the skill... The skill makes violations rare and the hook makes them close to impossible."* 엔터프라이즈에서는 그 위에 managed settings를 올려 엔지니어가 끌 수 없게 한다. → [[agentic-governance]]

7. **에이전트는 production gate까지 하고 그 너머는 못 간다.** 원문: *"the agent may act up to the production gate and cannot pass it."* 그리고 separation of duties — *"the agent that wrote the code has no way to approve it."* branch protection이 에이전트가 쓴 모든 것을 PR로 만들고, main으로 가는 직접 경로는 없다.

8. **인간의 주의는 라인에서 게이트로 이동한다.** PR 리뷰에서 사람이 판단하는 것은 "이 변경이 plan이 의도한 것을 하는가"와 "리스크가 수용 가능한가" — 즉 intent와 risk. 기계적 증거(테스트 출력, 빌드 로그, 스크린샷 diff)는 이미 첨부되어 있다.

9. **에이전트 설정도 코드처럼 회귀 테스트 대상이다.** `CLAUDE.md`·skills·hooks가 바뀌면 eval suite가 CI에서 돌아 통과율을 보고한다. 실제 작업 20~50개를 eval로 만들고, **production incident 하나당 eval 하나**를 추가해 영구 회귀 테스트로 남긴다. 모델이 좋아지면 변별력을 잃은 케이스는 교체해야 하는 살아있는 suite다.

10. **측정은 이미 있는 데이터로 한다.** 모든 play가 leading/lagging indicator 쌍을 갖는데 출처가 대부분 git history, PR metadata, CI 시스템, incident tracker, OpenTelemetry export다. 새 계측 없이 시작할 수 있다는 것이 이 문서의 실무적 강점.

11. **레거시를 걷어내라고 하지 않는다.** Jira·ServiceNow·Figma·change board는 감사인과 규제기관이 이미 수용하고 있어 대체가 어렵다. 대신 **아티팩트마다 source of truth를 하나만 지정**한다. 세 가지 구성: repo가 authoritative(엔지니어링 주도 조직에 가장 깔끔), 레거시 시스템이 authoritative(Claude가 MCP로 읽고 되쓴다), 또는 최소선으로 **linkage**(아티팩트는 record ID를, 레거시 record는 commit SHA를 갖는다). linkage는 source of truth가 둘이라는 것을 받아들이는 전환기 출발점.

12. **병렬성의 천장은 리뷰 능력이다.** worktree로 격리된 병렬 세션 2~3개가 합리적 출발점이고, *"the practical ceiling is how many streams one person can review properly"* — 리뷰가 따라가는 동안에만 세션을 늘린다.

13. **피드백 루프 자체를 보호해야 한다.** *"an agent fixing code must not be able to weaken the check on that code."* 버그 수정 시 실패하는 테스트를 먼저 쓰고 커밋한 뒤, 테스트 파일 편집을 막는 hook을 걸고 통과시키게 한다. 수정 이전에 존재했고 에이전트가 고쳐 쓸 수 없었던 테스트만이 버그가 사라졌다는 증거가 된다.

## Notable Quotes / Passages

> "Build is no longer the constraint — the human-speed steps around it are."

> "Reviewing each line by hand made sense when a person had written it, but it can't keep up once agents write most of the diff."

> "The skill makes violations rare and the hook makes them close to impossible."

> "Separation of duties is preserved, because the agent that wrote the code has no way to approve it."

> "The loop keeps running. Human judgement stays above it."

## 6단계 요약표

문서가 제시하는 전통 SDLC ↔ AI-native SDLC 대비 (원문 표 요약):

| Stage | Traditional | AI-native |
|---|---|---|
| Plan | 위원회가 요구사항을 모으고 워크숍·사인오프를 거쳐 손으로 작성 | Claude가 소스에서 직접 pain point를 종합해 `intent.md`로 — 사람이 읽고 기계가 실행 가능 |
| Design | 분석가가 spec을 쓰고 디자이너가 다시 파싱 | 요구사항+설계를 에이전트와의 한 세션으로 압축, 조직의 skill이 제약으로 작용, git에 버전 관리 |
| Build | 테스트·코드 수작업, 문서는 개발 후에 | 테스트·코드를 AI가 생성, 조직 지식은 버전 관리되는 `CLAUDE.md`와 skill로 유지 |
| Test | 단계 경계의 QA 게이트 | 구현 전반에 짜여든 연속 eval |
| Deploy | 사람이 모든 줄을 리뷰, 거버넌스는 리뷰 사이클에서 일관성 없이 | 계층화된 에이전트 리뷰 + 규제·핵심 코드에 한정된 사람 리뷰. hook이 승인 게이트 |
| Maintain | 사람이 production을 지켜봄 | 에이전트가 배포를 모니터링, 깨진 control band는 진단되어 새 `intent.md`로 루프에 되먹여짐 |

## 구체적 산출물 (문서가 제시하는 파일들)

- `intent.md` — Problem / Proposed outcome / Affected users and systems / Constraints / Open questions
- `spec.md` — 조직 skill을 제약으로 적용한 요구사항+설계, **areas of concern 플래그 필수**
- `plan.md` — Files that change / Order of work / Risks / Proof
- `CLAUDE.md` — Commands / Conventions / Architecture / **Things Claude gets wrong**. 한 페이지 이하 유지. 규칙: Claude가 같은 실수를 두 번 하면 교정이 여기 들어간다
- `REVIEW.md` — 리뷰 pass 정의(Bugs/Security/Compliance), Important와 Nit의 경계, nit 상한, 보고 제외 대상
- `bands.yaml` — metric, baseline, rules, 티어별 action
- `.claude/skills/<name>/SKILL.md`, `.claude/agents/<name>.md`, `.claude/settings.json`

## Connections

- 이 소스는 [[ai-native-sdlc]] 토픽 전체의 1차 출처다.
- [[artifact-chain]] 개념(Key Claim 2·3·4)의 출처.
- [[agentic-governance]] 개념(Key Claim 6·7·8)의 출처.
- [[claude-code]]의 기능 대부분(plan mode, auto mode, CLAUDE.md, skills, hooks, subagents, worktrees, managed settings)이 여기서 SDLC 맥락에 배치된다.

## My Notes

- 문서의 서술 강도에 비해 **정량 데이터는 없다.** "multi-week에서 hours로" 같은 기대치는 제시하지만 고객 사례 수치나 벤치마크는 제시되지 않는다. Anthropic이 자사 제품을 축으로 쓴 문서라는 점을 감안해 읽을 것.
- 가장 이식성 높은 아이디어는 제품 중립적이다: **아티팩트 체인**, **skill/hook의 advisory-deterministic 구분**, **탐지는 결정론적으로 유지**. 이 셋은 Claude Code가 아니어도 성립한다.
- 반대로 managed settings 워크드 예시나 Claude Security 절은 제품 종속적이라 다른 스택으로 옮기기 어렵다.
- 문서 스스로 인정하는 부분: 이것은 "recommendation to copy"가 아니라 "starting point to tailor"이며, 모든 deny는 capability와의 트레이드오프다.
- 후속으로 볼 만한 문서로 두 편을 지목한다 — *how Anthropic secures its AI-native SDLC*, *how Claude Tag runs on-call for CI/CD at Anthropic*.

## Raw Source

[원본 파일](../../raw/articles/2026-08-21-the-ai-native-sdlc-playbook.md) · [claude.com/blog/the-ai-native-sdlc-playbook](https://claude.com/blog/the-ai-native-sdlc-playbook)
