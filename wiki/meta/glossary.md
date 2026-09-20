---
title: Glossary
type: meta
created: 2026-04-28
updated: 2026-09-21
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
- **contradiction marker** — `> ⚠️ Contradiction:` blockquote. 페이지 간 모순을 명시할 때 사용.

## 에이전트 용어

- **harness** — 모델을 감싸고 *무엇을 언제 할지*를 정하는 바깥 껍질. Claude를 호출하는 루프, tool call 라우팅, 컨텍스트 관리 규칙. [[claude-code]]도 [[dynamic-workflows]]가 쓴 프로그램도 harness다.
- **meta-harness** — 특정 harness에 의견을 갖지 않고 그 **주변 인터페이스**만 고정하는 설계. → [[meta-harness]]
- **brain / hands / session** — 에이전트를 셋으로 가른 분할. brain = 모델과 그 harness, hands = sandbox와 도구, session = 이벤트 로그. 셋이 독립적으로 실패·교체된다.
- **pets vs cattle** — 인프라 유비. pet은 이름 붙여 손으로 돌보는, 잃으면 안 되는 개체. cattle은 교체 가능한 개체. 판별법: *그것이 죽으면 무엇이 같이 사라지는가.*
- **TTFT** (time-to-first-token) — 작업을 받고 첫 응답 토큰을 내기까지의 지연. 사용자가 가장 예민하게 느끼는 지연 지표.
- **context anxiety** — 모델이 컨텍스트 한계가 다가오는 것을 감지하고 작업을 조기 종료하는 행동. Sonnet 4.5에서 관측됐고 Opus 4.5에서 사라졌다. harness 가정이 노후화하는 대표 사례.
- **quarantine** — 신뢰할 수 없는 콘텐츠를 읽는 에이전트에게 고권한 행동을 주지 않고, 행동은 별도 에이전트가 하게 하는 패턴. 무력화가 아니라 트레이드오프다(trust escalation). → [[agentic-governance]]

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
