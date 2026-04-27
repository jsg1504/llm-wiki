---
name: wiki-lint
description: Use this skill when the user asks to check the health of the wiki, runs /lint, or asks for suggestions on what to investigate next. Performs a comprehensive audit covering contradictions, stale claims, orphan pages, missing concept pages, missing cross-references, broken links, frontmatter validity, and suggests new questions to investigate. Do NOT use this skill for individual page edits or single source ingestion. The deliverable is always a dated lint report saved to wiki/meta/lint-YYYY-MM-DD.md plus a prioritized action list presented to the user.
---

# wiki-lint skill

위키의 건강을 정기적으로 점검하는 스킬. 위키는 자라면서 자연스럽게 부패한다 — lint는 부패를 잡아낸다.

## 1. 점검 항목

다음 7가지 카테고리를 차례로 점검한다.

### 1.1 Frontmatter 유효성
모든 위키 페이지가 다음 필수 필드를 가지는가?
- `title`, `type`, `created`, `updated`, `status`
- `sources` (메타 페이지 제외)

### 1.2 Broken links (깨진 wikilink)
`wiki-link` 스킬의 VALIDATE 위임. 결과를 lint 보고서에 합본.

### 1.3 Orphan pages (고아 페이지)
`wiki-link` 스킬의 ORPHANS 위임.

### 1.4 Contradictions (모순)
페이지를 cross-read 하여 같은 사실에 대해 다른 주장이 있는지 점검:
- 의심스러운 페이지 쌍을 식별하는 휴리스틱:
  - 같은 entity를 다루는 페이지들 (frontmatter `tags` 또는 본문 언급)
  - 같은 source를 인용하나 결론이 다른 페이지들
- `> ⚠️ Contradiction:` 마커가 이미 있는 페이지는 그대로 보고하되 "기존 표시됨"으로 분류.

### 1.5 Stale pages (오래된 페이지)
- 어떤 페이지의 `sources:`가 오래된 source만 가리키는데, 그 후에 새 관련 source가 들어왔다면 이 페이지는 stale.
- 휴리스틱: source 페이지의 frontmatter `tags`와 다른 페이지의 `tags`를 비교. 같은 tag를 가진 새 source가 있는데 이를 인용 안 하는 페이지는 stale 후보.

### 1.6 Missing concept pages
- 여러(예: 3개 이상) 페이지에서 plain text로 언급되지만 자기 페이지가 없는 용어를 찾는다.
- 예: 5개 페이지에서 "context window"라고 적는데 `[[context-window]]` 페이지가 없음.

### 1.7 Missing cross-references
`wiki-link` 스킬의 SUGGEST 위임.

### 1.8 (보너스) Data gaps
사용자가 더 조사하면 위키가 더 풍부해질 영역. 휴리스틱:
- "TODO", "TBD", "?"가 본문에 있는 페이지
- topic 페이지의 "미해결 질문" 섹션
- contradiction이 unresolved로 표시된 페이지

---

## 2. 출력 형식

`wiki/meta/lint-YYYY-MM-DD.md`에 다음 형식으로 저장:

```markdown
---
title: Lint Report YYYY-MM-DD
type: meta
created: YYYY-MM-DD
status: mature
---

# Lint Report — YYYY-MM-DD

> 위키의 N 페이지를 점검. 우선순위 액션 K개.

## 0. 요약
| 카테고리 | 항목 수 | 우선순위 |
|---|---|---|
| Frontmatter 오류 | 2 | 🔴 High |
| 깨진 링크 | 5 | 🔴 High |
| 고아 페이지 | 3 | 🟡 Medium |
| 모순 (unresolved) | 1 | 🔴 High |
| Stale 후보 | 4 | 🟡 Medium |
| 누락 concept 페이지 | 6 | 🟢 Low |
| Cross-ref 제안 | 12 | 🟢 Low |

## 1. Frontmatter 오류
- `wiki/concepts/foo.md` — `updated` 누락
- ...

## 2. 깨진 링크
- `wiki/topics/bar.md:42` → `[[deleted-page]]`
- ...

## 3. 고아 페이지
- `wiki/concepts/baz.md` — 어떤 페이지로 흡수?
- ...

## 4. 모순
- `[[foo]]`와 `[[bar]]`: X에 대해 다른 주장
  - foo: "X는 A이다" (출처: [[wiki/sources/2025-..]])
  - bar: "X는 B이다" (출처: [[wiki/sources/2026-..]])
  - **권장:** [[bar]]가 더 최신이므로 [[foo]]에 contradiction 마커 추가하고 [[bar]]를 우선.

## 5. Stale 후보
...

## 6. 누락 concept 페이지
- "context window" — 5개 페이지에서 plain text로 언급
- ...

## 7. Cross-ref 제안
- [[foo]] ↔ [[bar]]: 같은 tag 'rag', 서로 링크 없음
- ...

## 8. 데이터 갭 / 다음 조사 거리
- [[topic-X]]의 "미해결 질문" 섹션이 답 없이 6주 이상 정체. 새 소스를 찾아볼 만함.
- [[entity-Y]]가 stub로 남음. 1차 출처 필요.

---

## 9. 우선순위 액션 리스트

다음 순서로 처리 권장:
1. 🔴 깨진 링크 5개 수정 (커널 비용 작음, 임팩트 큼)
2. 🔴 모순 1건 해결 (사용자 판단 필요)
3. 🟡 frontmatter 오류 2건 수정
4. 🟡 고아 3개 처리
5. 🟢 새 concept 페이지 6개 stub 생성
6. 🟢 cross-ref 12개 추가

각 액션을 진행할까요? 일부만 골라도 됩니다.
```

---

## 3. 사용자에게 액션 요청

lint 보고서를 보고한 후, **자동으로 고치지 않고** 사용자에게 우선순위 액션 리스트를 제시한다. 사용자가 어느 항목을 진행할지 고르면, 각 항목에 대해 적절한 스킬 호출:

- 깨진 링크 / 고아 / cross-ref → `wiki-link` 스킬
- 페이지 합치기/분할 → `wiki-page` + `wiki-link`
- 새 stub 생성 → `wiki-page`
- 모순 해결 → 사용자와 토론 후 페이지 직접 수정

---

## 4. lint 빈도

- **소규모 위키** (~50 페이지): 한 달에 한 번 또는 30개 ingest당 한 번.
- **중규모** (~200 페이지): 2주에 한 번.
- **대규모** (500+ 페이지): 매주.

이 빈도는 사용자가 정한다. lint 자체는 비용이 작으므로 부담 없이 자주 돌릴 수 있다.

---

## 5. 안티패턴

- ❌ lint가 끝나자마자 모든 항목을 자동 수정 — 사용자 승인 필수.
- ❌ lint 보고서를 log.md에 쓰지 않기 — `## [date] lint | <count>` 한 줄은 남겨야 추적 가능.
- ❌ 같은 lint 보고서를 매번 덮어쓰기 — 날짜별로 별도 파일. 시계열 추적이 필요.
- ❌ 세부 점검에만 매몰 — "다음 조사 거리" 항목이 가장 중요한 산출물일 수 있다.
