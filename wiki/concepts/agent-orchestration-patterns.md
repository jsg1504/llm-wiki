---
title: 에이전트 오케스트레이션 패턴
type: concept
created: 2026-09-12
updated: 2026-09-12
sources: [2026-08-20-a-harness-for-every-task-dynamic-workflows, 2025-06-13-multi-agent-research-system]
tags: [orchestration, multi-agent, agent-design, patterns, evaluation, dynamic-workflows]
status: draft
---

# 에이전트 오케스트레이션 패턴

> 여러 에이전트를 엮는 **조합 가능한 여섯 가지 제어 구조**. 각각이 막으려는 실패 모드가 다르고, 그래서 서로 겹쳐 쓸 수 있다. [[orchestrator-worker]]가 이 중 fan-out-and-synthesize의 LLM 주도 구현이라는 점에서, 이 페이지는 그 패턴의 상위 카탈로그다.

## Overview

[[dynamic-workflows]]에서 Claude가 harness를 쓸 때 사용하고 서로 조합하는 패턴들이다 ([[2026-08-20-a-harness-for-every-task-dynamic-workflows]]). 소스는 이것을 *"a few common patterns that Claude might use and **compose together**"*라고 소개한다 — 배타적 선택지가 아니라 조합 재료다.

패턴을 알아야 하는 이유는 직접 코딩하기 위해서가 아니라, **무엇을 요청할지 프롬프트로 유도하기 위해서**다. 소스의 표현: *"building a mental model for how dynamic workflows work will help you understand when to use them and how you might nudge Claude via prompts."*

## 여섯 패턴

### 1. Classify-and-act

분류 에이전트가 **태스크의 유형**을 정하고, 그 판정에 따라 서로 다른 에이전트나 동작으로 라우팅한다. 끝단에 두어 **출력 형태를 결정**하는 데 쓸 수도 있다.

- **막는 것:** 이질적인 입력을 하나의 프롬프트로 처리할 때의 품질 저하.
- **대표 용례:** 모델 라우팅. 분류 에이전트가 *"auth 모듈이 어떻게 동작하는지 설명해"*의 실제 복잡도(파일 수, 코드베이스 형태)를 먼저 조사한 뒤 Sonnet 또는 Opus로 보낸다. 조사 자체가 비용이므로, 뒤따르는 작업이 도구 호출을 많이 할 때 이득이 난다.
- **주의:** 분류가 틀리면 이후 전부가 틀린 경로로 간다. 분기 수가 적을수록 안전하다.

### 2. Fan-out-and-synthesize

태스크를 작은 단계로 쪼개 **각 단계마다 에이전트를 돌리고**, 결과를 종합한다. 단계가 많거나 각 단계가 **자기만의 깨끗한 컨텍스트**로 이득을 볼 때(서로 간섭·교차오염하지 않아야 할 때) 특히 유용하다.

종합 단계는 **barrier**다 — fan-out 에이전트 전부를 기다린 뒤 그들의 구조화된 출력을 하나로 병합한다.

- **막는 것:** agentic laziness(프로그램이 항목 목록을 들고 있으므로 빠뜨릴 자리가 없다), 컨텍스트 교차오염.
- **관계:** [[orchestrator-worker]]가 바로 이 패턴을 **lead agent가 조정하는 형태**로 구현한 것이다. 차이는 barrier를 누가 들고 있는가 — 거기서는 lead의 컨텍스트, 여기서는 프로그램.
- **비용 구조:** barrier가 있으므로 **가장 느린 하나가 전체를 막는다.** [[orchestrator-worker]]가 "동기 실행 병목"으로 기록한 한계가 그대로 상속된다.

### 3. Adversarial verification

spawn된 에이전트마다 **별도의 에이전트를 띄워 그 출력을 루브릭·기준에 비추어 적대적으로 검증**한다.

- **막는 것:** **self-preferential bias** — Claude가 자기 결과를 편애하는 경향, 특히 스스로 판정하라고 했을 때. 검증자를 분리하는 것이 이 패턴의 전부이자 요점이다.
- **[[agent-evaluation]]과의 관계:** 같은 원리의 두 층위다. 그쪽의 verifier subagent가 *"판정이 코드를 만든 가정에 오염되지 않게"* 신선한 컨텍스트로 한 번 도는 것이라면, 이쪽은 그것을 **모든 산출물에 대해 체계적으로** 건다.
- **false positive 관리:** 검증자를 촘촘히 걸면 과잉 지적이 나온다. 소스의 처방은 **skeptic 페르소나 subagent**를 두어 규칙·판정 자체가 타당한지 되묻게 하는 것이다.

### 4. Generate-and-filter

한 주제에 대해 아이디어를 **다수 생성**한 뒤, 루브릭이나 검증으로 거르고 중복을 제거해 **최고 품질의 검증된 것만** 반환한다.

- **막는 것:** 단일 컨텍스트에서 아이디어를 내면 초기 방향에 고착되는 path dependency.
- **핵심은 필터가 생성과 분리되어 있다는 것.** 생성기는 양을, 필터는 질을 담당한다. 같은 에이전트가 둘 다 하면 3번 패턴이 막으려던 편향이 돌아온다.

### 5. Tournament

일을 **나누지 않고 경쟁시킨다.** N개 에이전트가 **서로 다른 접근으로 같은 태스크**를 시도하고, 프롬프트나 모델이 **pairwise로 판정**해 우승자가 남을 때까지 진행한다.

- **막는 것:** 절대 점수 매기기의 불안정성. 소스의 근거 — ***"comparative judgment is more reliable than absolute scoring"***.
- **대표 용례:** 정성적 정렬. 1000+ 행을 심각도순으로 정렬할 때 한 프롬프트에 다 넣으면 품질이 떨어지고 컨텍스트에도 안 들어간다. 대신 pairwise 비교 에이전트 파이프라인을 돌리거나, 병렬로 bucket-rank한 뒤 머지한다. **각 비교가 자기 에이전트이고, 결정론적 루프가 브래킷을 들고 있어 컨텍스트에는 진행 순서만 남는다.**
- **취향 판단에도 쓰인다** — 디자인·네이밍처럼 루브릭 기반 선택.

> ⚠️ *"comparative judgment is more reliable than absolute scoring"*은 이 소스가 **근거를 대지 않고 단언한 명제**다. 널리 받아들여지는 심리측정 원리이긴 하나, 이 소스 안에서는 측정되지 않았다. [[agent-evaluation]]의 LLM-as-judge 절이 권하는 *"단일 호출·단일 루브릭 + 0.0~1.0 점수"*와 방법이 다르므로, 둘 중 무엇이 언제 나은지는 **미해결**이다.

### 6. Loop until done

작업량을 **모를 때** 고정된 패스 수 대신 **정지 조건**(새 발견 없음, 로그에 에러 없음)이 충족될 때까지 에이전트를 계속 spawn한다.

- **막는 것:** "3번 돌린다" 같은 임의의 상한이 만드는 미완성. agentic laziness의 프로그램 버전.
- **[[orchestrator-worker]]와의 관계:** 그쪽에서 lead agent가 종합 후 *"충분한가?"*를 판단해 subagent를 더 띄우는 루프와 같은 자리다. 차이는 판단 주체 — LLM의 재량 대신 **미리 표현된 정지 조건**이 결정한다. 그래서 정지 조건을 표현할 수 없는 태스크에는 못 쓴다.
- **비용이 가장 예측하기 어려운 패턴이다.** 명시적 토큰 예산과 함께 쓰는 것이 안전하다.

## 조합하기

패턴들은 겹쳐 쓰라고 있는 것이다. 소스의 사용 사례들이 실제로 그렇게 되어 있다:

| 사용 사례 | 조합 |
|---|---|
| **Deep research** (`/deep-research` skill) | fan-out(웹 검색) → adversarial verification(주장 검증) → synthesize(인용된 리포트) |
| **마이그레이션** (Bun의 Zig→Rust) | fan-out(callsite·테스트·모듈 단위, 각자 worktree) → adversarial verification(리뷰) → 머지 |
| **규칙 준수** | fan-out(규칙당 verifier 1개) + skeptic 페르소나로 false positive 억제 |
| **`CLAUDE.md` 규칙 채굴** | fan-out(세션 클러스터링) → adversarial verification(*"이 규칙이 실제 실수를 막았겠는가?"*) → generate-and-filter(살아남은 것만 증류) |
| **근본원인 조사** | fan-out(**disjoint한 증거원**: 로그/파일/데이터) → generate-and-filter(가설) → adversarial verification(검증자·반박자 패널) |
| **대규모 triage** | classify-and-act(분류·중복 제거·라우팅) + loop-until-done, `/loop`와 결합 |
| **Eval** | fan-out(worktree에서 산출물 생성) → tournament/루브릭 채점 |
| **탐색과 취향** | generate-and-filter + tournament, 리뷰 에이전트가 완료를 선언 |

**설계 순서는 대체로 하나다:** 무엇을 병렬화할지(fan-out 단위) 정하고 → 누가 검증할지(분리된 검증자) 정하고 → 언제 멈출지(정지 조건 또는 barrier) 정한다.

## 무엇이 이 카탈로그에 없는가

- **에이전트끼리 직접 협상하는 패턴이 없다.** 여섯 개 전부 부모(또는 프로그램)를 거친다. [[subagent]]에 기록된 *"subagent끼리 협력할 수 없다"*는 제약이 여기서도 유지된다.
- **사람이 루프 안에 있는 패턴이 없다.** 소스는 별도로 `AskUserQuestion`을 쓰는 예시 프롬프트("루브릭을 만들기 위해 나를 인터뷰해")를 들지만 패턴 목록에는 넣지 않았다.
- **실패·재시도 패턴이 없다.** [[multi-agent-systems]]가 프로덕션 요건으로 기록한 resume·checkpoint·retry에 대응하는 항목이 이 카탈로그에는 없다. (워크플로 자체는 중단 후 재개를 지원한다.)

## Related

- [[dynamic-workflows]] — 이 패턴들이 사는 곳. "왜"와 "언제 쓰지 말아야 하는가"
- [[orchestrator-worker]] — fan-out-and-synthesize의 LLM 주도 구현. 이 카탈로그의 한 항목이 독립 페이지가 된 셈
- [[subagent]] — 모든 패턴의 실행 단위
- [[agent-evaluation]] — adversarial verification과 tournament가 평가 방법론으로서 갖는 함의
- [[multi-agent-systems]] — 이 패턴들을 쓸 경제적 조건

## Sources

- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). 여섯 패턴과 사용 사례 전부의 출처
- [[2025-06-13-multi-agent-research-system]] — subagent 간 협력 제약, 동기 실행 병목, 프로덕션 요건(resume·checkpoint·retry)의 출처
