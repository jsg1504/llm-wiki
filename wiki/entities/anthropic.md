---
title: Anthropic
type: entity
created: 2026-09-11
updated: 2026-09-12
sources: [2025-06-13-multi-agent-research-system, 2026-08-21-the-ai-native-sdlc-playbook, 2026-08-20-a-harness-for-every-task-dynamic-workflows]
tags: [organization, ai-lab, claude, anthropic]
status: stub
---

# Anthropic

> Claude 모델군을 만드는 AI 연구·제품 조직. 이 위키에 현재 들어온 소스는 전부 Anthropic이 발행한 것이므로, **이 위키의 관점 편향을 추적하는 지점**이기도 하다.

## Overview

이 페이지는 Anthropic이라는 조직 전반을 다루지 않는다. **이 위키의 소스들이 드러내는 만큼만** 기록한다. 현재까지는 세 편의 실무 문서를 통해 두 가지 얼굴이 나타난다 — 자기 시스템을 만든 기록([[2025-06-13-multi-agent-research-system]], [[2026-08-20-a-harness-for-every-task-dynamic-workflows]])과 고객에게 방법을 파는 문서([[2026-08-21-the-ai-native-sdlc-playbook]]):

- **엔지니어링 조직으로서** — 자사 프로덕션 시스템(Research 기능)을 만들며 깨진 것들을 공개한다 ([[2025-06-13-multi-agent-research-system]]).
- **엔터프라이즈 조력자로서** — Applied AI 팀이 고객사와 일하며 얻은 패턴을 플레이북으로 낸다 ([[2026-08-21-the-ai-native-sdlc-playbook]]).

## Key Points

### 언급되는 제품·모델

| 이름 | 이 위키에서의 등장 |
|---|---|
| **Claude Opus 4 / Sonnet 4** | 멀티에이전트 조합(Opus lead + Sonnet subagents)에서 단일 Opus 4 대비 90.2% 우위. Sonnet 3.7→4 업그레이드가 토큰 예산 2배보다 이득이 컸다. |
| **Research 기능** | 웹·Google Workspace·integration을 가로질러 검색하는 소비자 기능. [[orchestrator-worker]] 구조의 실제 구현체. |
| **[[claude-code]]** | [[2026-08-21-the-ai-native-sdlc-playbook]]의 축이 되는 에이전틱 코딩 도구. |
| **MCP** | 외부 도구 접근 프로토콜. 도구 설명 품질 편차가 에이전트를 잘못된 경로로 보낸다는 문제 제기의 맥락에서 등장. |

### 문서 작성 방식의 특징

세 소스에서 공통으로 보이는 패턴:

- **실패 사례를 구체적으로 공개한다.** subagent 50개를 띄운 초기 에이전트, 중복 검색을 한 3개 중 2개, SEO 콘텐츠팜 편향 등.
- **자사 제품에 불리한 한계도 명시한다.** 멀티에이전트의 15배 토큰 비용, 코딩 도메인 부적합 판정.
- **단, 핵심 수치는 내부 eval이고 루브릭은 비공개다.** 90.2% 같은 숫자는 외부 재현이 불가능하다.

> 이 위키의 소스가 한 조직에 편중되어 있다는 점을 의식할 것. 멀티에이전트·에이전틱 코딩에 대한 **외부 관점(비판, 독립 벤치마크, 경쟁 아키텍처)** 이 현재 위키에 없다. **소스 3개 중 3개가 Anthropic이며**, [[multi-agent-systems]]의 모순 판정도 전부 이 출처들에 기대고 있다. 게다가 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]는 정량 데이터를 제시하지 않는 경험 보고다.

## Related

- [[multi-agent-systems]] — Anthropic이 이 위키에 기여한 주된 주제.
- [[orchestrator-worker]] — Anthropic Research 기능이 채택한 구조.
- [[agent-evaluation]] — Anthropic이 공개한 평가 실무.
- [[claude-code]] — Anthropic의 에이전틱 코딩 도구.
- [[ai-native-sdlc]] — Applied AI 팀이 낸 엔터프라이즈 SDLC 플레이북의 주제 페이지.
- [[artifact-chain]] — 여러 소스가 각자 도달한 "파일을 인터페이스로" 패턴.
- [[dynamic-workflows]] — 세 번째 소스가 소개하는, harness 제작을 모델에게 넘기는 접근.
- [[agentic-governance]] — Claude Code의 통제 표면을 조직 정책으로 쓰는 방식.
- [[subagent]] — 소스들이 같은 단어로 다른 것을 가리키는 지점.

## Sources

- [[2025-06-13-multi-agent-research-system]] — Anthropic Engineering 블로그 (2025-06-13).
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Claude Blog, Claude Code 팀 기술 스태프 (2026-08-20).
- [[2026-08-21-the-ai-native-sdlc-playbook]] — Claude Blog, Applied AI 팀 (2026-08-21).
