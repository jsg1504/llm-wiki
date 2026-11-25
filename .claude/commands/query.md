---
description: Ask the wiki a question. Answers index-first with a citation for every claim, surfaces contradictions, and offers to file valuable answers back as a synthesis page.
argument-hint: <question>
---

# /query — 위키에 질문하기

`wiki-query` 스킬을 호출하여 다음 질문에 답한다:

**질문:** `$ARGUMENTS`

## 절차

1. `wiki-query` 스킬의 SKILL.md를 읽고 절차를 그대로 따름.
2. 질문 분류 → `wiki/meta/index.md` 먼저 → 관련 페이지 정독.
3. 모든 주장에 `[[출처]]`. 위키 근거 / `*(추론)*` / `*(위키 외)*` 구분.
4. 관련 `⚠️ Contradiction`이 있으면 양쪽 모두 제시.
5. 답변 끝에:
   - 참고한 페이지 목록
   - 위키의 빈틈 (있으면)
   - 보존 가치가 있으면 synthesis 저장 제안 (`/save-as-synthesis`)
   - 기존 페이지 개선 후보 (있으면, 자동 수정하지 않음)

질문이 비어있으면 최근 ingest한 소스(`log.md` tail)와 topic 페이지의 미해결 질문을 바탕으로 물어볼 만한 질문 3개를 제안한다.
