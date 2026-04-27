---
description: Ingest a new source from raw/ into the wiki. Discusses takeaways with you first, then writes a source page and updates affected entity/concept/topic pages.
argument-hint: <path-to-raw-file>
---

# /ingest — 새 소스 통합

`source-ingest` 스킬을 호출하여 다음 raw 파일을 위키에 통합한다:

**대상:** `$ARGUMENTS`

## 절차

1. 위 파일이 `raw/` 아래 존재하는지 확인.
2. `source-ingest` 스킬의 SKILL.md를 읽고 절차를 그대로 따름.
3. 핵심 takeaway를 **사용자와 합의한 후**에만 위키 변경 수행.
4. 작업 완료 후 종합 보고:
   - 작성/업데이트된 페이지 목록
   - 발견된 모순
   - 제안되는 후속 질문

대상 파일 경로가 비어있으면 `raw/` 아래 가장 최근에 추가된 파일을 후보로 제시하고 사용자 확인을 받는다.
