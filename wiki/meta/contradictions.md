---
title: Contradictions
type: meta
created: 2026-11-26
updated: 2026-11-26
sources: []
tags: [meta, contradictions]
status: draft
---

# Contradictions

> 위키에 기록된 모순을 한곳에 모은 목록이다. 본문과 근거는 각 페이지의 ⚠️ 노트에 있고, 여기서는 위치와 상태만 관리한다. lint는 이 목록과 페이지의 ⚠️ 노트를 대조한다.

| 등록 | 모순 | 위치 | 상태 |
|---|---|---|---|
| 2026-09-11 | 코딩은 멀티에이전트에 맞는가 | [[multi-agent-systems]] Contradiction 절, [[ai-native-sdlc]] | **부분 판정** (2026-09-12) — 적합성 ✅ 우회됨, 경제성 ✅ 모순 없음, 잔여 질문 있음 |
| 2026-09-30 | taste는 루프에 맞는가 (Osmani vs Gavrilescu) | [[loop-engineering]] "루프가 안 맞는 일" 절 | **미해결** |
| 2026-11-26 | 단순한 과제와 강한 모델에서도 RLM은 손해가 작은가 ([[2025-12-31-recursive-language-models]] vs [[2026-03-03-reproducing-recursive-language-models]]) | [[recursive-language-model]] "외부 재현" 절 | **미해결 (판정 보류)** — 모델·표본·길이가 달라 같은 조건의 측정이 필요 |

## 등록 규칙

- 새 모순은 페이지 본문에 `> ⚠️ **Contradiction (YYYY-MM-DD): <질문>.**` 노트로 달고, 이 표에 한 줄을 더한다.
- 판정이 나면 본문 노트는 지우지 않고 판정을 덧붙이며, 이 표의 상태만 바꾼다.
- 한 모순을 다른 페이지가 옮겨 적은 경우(예: [[what-to-accumulate-outside-the-model]], [[inner-outer-loop-verification]]의 taste 모순)는 원 위치만 등록한다.
