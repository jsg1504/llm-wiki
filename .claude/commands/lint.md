---
description: Run a comprehensive health check on the wiki. Detects broken links, orphans, contradictions, stale pages, missing concept pages, and suggests cross-references. Saves a dated report to wiki/meta/ and proposes a prioritized action list.
---

# /lint — 위키 건강 검진

`wiki-lint` 스킬을 호출하여 위키 전체를 점검한다.

## 절차

1. `wiki-lint` 스킬의 SKILL.md를 그대로 따름.
2. 결과를 `wiki/meta/lint-YYYY-MM-DD.md`에 저장.
3. `wiki/meta/log.md`에 `## [<date>] lint | <summary>` 한 줄 추가.
4. 사용자에게 우선순위 액션 리스트 제시.
5. **자동 수정하지 않음.** 사용자가 어느 항목을 처리할지 고르면 그제서야 적절한 스킬/에이전트로 위임.
