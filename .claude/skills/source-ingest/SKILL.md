---
name: source-ingest
description: Use this skill when the user asks to ingest, integrate, or process a new source file into the wiki. Triggers include any of "ingest", "integrate", "정리해줘", "위키에 넣어줘", "이 글 분석해서 추가해줘", or when a user references a file under raw/ and wants it incorporated. Do NOT use this skill for ad-hoc summarization that won't be filed; for that, just summarize inline. The deliverable is always: (1) a source page under wiki/sources/, (2) updates to affected entity/concept/topic pages, (3) an index.md update, and (4) a log.md entry. Always discuss takeaways with the user BEFORE writing anything.
---

# source-ingest skill

새 소스를 위키에 통합하는 작업의 표준 절차. 이것은 위키의 가장 중요한 작업이다 — 잘못 통합된 소스 하나가 위키 전체의 신뢰도를 떨어뜨린다.

## 0. 사전 점검

이 스킬을 호출하기 전에 다음을 확인:

- [ ] 통합할 소스 파일이 `raw/` 아래 어딘가에 있는가? 없으면 먼저 사용자에게 어디 있는지 묻거나, 직접 적절한 하위 디렉토리에 두도록 안내.
- [ ] 파일명이 `YYYY-MM-DD-slug.md` 또는 적어도 일관된 형식인가? 아니라면 사용자에게 리네임 제안.
- [ ] 이전에 같은 소스를 통합한 적이 없는가? `wiki/sources/`에서 동일 이름 확인.

## 1. READ — 소스 정독

```
Read raw/<path-to-source>
```

소스 종류에 따라:
- 텍스트(.md, .txt): 그대로 읽음.
- PDF: 가능하면 텍스트로 추출. 실패 시 사용자에게 `pdf` 스킬 사용 요청.
- 이미지가 inline으로 참조된 마크다운: 본문 텍스트 먼저 읽고, 핵심 이미지를 별도로 view.

## 2. EXTRACT — 핵심 추출 (사용자와 합의)

소스를 다 읽은 후, 다음을 사용자에게 제시한다:

```markdown
**소스 요약:** <Title> by <Author> (<Date>)

**핵심 takeaway 후보:**
1. ...
2. ...
3. ...
4. ...
5. ...

**예상 영향 페이지:**
- 새로 만들 페이지: [[new-page-1]] (entity), [[new-page-2]] (concept)
- 업데이트할 페이지: [[existing-1]], [[existing-2]]
- **잠재적 모순:** [[existing-3]]에서 X라고 주장하는데 이 소스는 Y라고 함

**진행할까요?** 강조하거나 빼야 할 부분이 있으면 말씀해주세요.
```

**사용자 승인 없이 다음 단계로 가지 않는다.**

## 3. WRITE SOURCE PAGE — 1:1 요약 페이지 작성

`wiki/sources/<same-filename-as-raw>.md`에 작성:

```markdown
---
title: <Source Title>
type: source
created: <today>
updated: <today>
source_file: ../../raw/<path>
source_url: <원본 URL if any>
author: <author>
source_date: <YYYY-MM-DD>
tags: [...]
status: mature
---

# <Source Title>

> 한 줄 요약 — 이 소스가 무엇을 주장하는지.

## Context
이 소스가 누구에 의해, 언제, 어떤 맥락에서 쓰였는가.

## Key Claims
1. **주장 1** — 부연.
2. **주장 2** — …

## Notable Quotes / Passages
> 인용문 (옵션)

## Connections
- 이 소스는 [[concept-X]]를 다룬다.
- [[entity-Y]]를 언급한다.
- [[topic-Z]] 토픽에 속한다.

## My Notes
사용자와 논의 중 나온 의견, 비판, 메모.

## Raw Source
[원본 파일](../../raw/<path>)
```

## 4. UPDATE AFFECTED PAGES — 영향받은 페이지 갱신

각 영향받은 페이지에 대해:

### 4.1 새 entity/concept/topic 페이지를 만드는 경우
`wiki-page` 스킬 호출. 새 페이지의 frontmatter `sources:`에 이 source 페이지 ID 포함.

### 4.2 기존 페이지를 업데이트하는 경우
- 해당 섹션을 정확히 짚어 추가/수정.
- frontmatter `updated:` 갱신.
- frontmatter `sources:` 배열에 새 source ID 추가.
- 변경이 큰 경우, 페이지 하단에 `## Changelog` 섹션을 두고 `- YYYY-MM-DD: <new source>로부터 <변경 요약>` 추가 (선택).

### 4.3 모순이 있는 경우
**절대 기존 주장을 지우지 않는다.** 대신:

```markdown
> ⚠️ **Contradiction (YYYY-MM-DD):** [[old-source]]는 X라 주장하나, [[new-source]]는 Y라 주장한다. 어느 쪽이 맞는지 추가 조사 필요.
```

이런 경우 `wiki/meta/contradictions.md`라는 통합 페이지에도 한 줄 추가하면 좋다 (없으면 만들어도 됨).

### 4.4 역링크 점검 — 단방향 다리 막기

**새 페이지나 갱신한 페이지가 링크를 건 기존 페이지는, 거꾸로 이쪽을 링크하는가?**

새 페이지는 기존 페이지를 링크하면서 태어난다. 반대로 기존 페이지에서 새 페이지로 돌아오는 링크는 빠지기 쉽다. 이 위키는 이 문제로 lint에서 두 번 지적받았다 (2026-09-12, 2026-11-25). 매번 새 클러스터가 기존 topic에서 들어갈 수 없는 **단방향 다리**가 됐다.

**절차:**

1. 이번 ingest에서 **만들거나 실질적으로 바꾼** 페이지마다, 그 페이지가 링크하는 기존 페이지 목록을 뽑는다.
   ```bash
   # <page>가 링크하는 페이지 중 <page>를 역링크하지 않는 것
   P=<page-name>
   for t in $(grep -o '\[\[[^]|#]*' wiki/*/$P.md | sed 's/\[\[//' | sort -u); do
     f=$(find wiki -name "$t.md" -not -path "wiki/meta/*" | head -1)
     [ -n "$f" ] && ! grep -q "\[\[$P[]|#]" "$f" && echo "$t → $P 역링크 없음"
   done
   ```
2. 결과마다 판단한다. **모든 링크에 역링크가 필요한 건 아니다.**
   - **넣는다:** 대상이 **topic** 페이지인 경우. topic은 hub라서 빠지면 새 페이지가 섬이 된다. 또는 새 페이지가 대상의 주장을 **보강·반박·확장**하는 경우.
   - **넣지 않는다:** 대상이 entity(`anthropic`, `claude-code` 등)라 링크가 단순 언급일 뿐인 경우, 그리고 source 페이지인 경우.
3. 역링크를 넣을 때는 `## Related`에 한 줄만 달지 않는다. 가능하면 **본문의 관련 절에 한두 문장으로** 연결 이유를 쓴다. Related 한 줄만으로는 다음 lint에서 "연결은 있으나 내용 반영 안 됨"(stale)으로 다시 걸린다.
4. 역링크로 기존 페이지 본문을 고쳤다면, 그 페이지도 4.2를 따라 `updated:`와 `sources:`를 갱신한다.
5. 역링크를 넣을 대상은 **§2 takeaway 합의 때 "예상 영향 페이지"에 미리 포함**해 사용자 승인을 받는다. 4.4에서 처음 발견한 대상이면 쓰기 전에 사용자에게 묻는다.

## 5. UPDATE INDEX

`wiki/meta/index.md`에:
- 새 페이지가 있으면 적절한 카테고리 섹션에 추가.
- 업데이트된 페이지는 `(updated YYYY-MM-DD)` 표시.
- 카테고리는 알파벳 또는 한글 가나다 순.

## 6. APPEND LOG

`wiki/meta/log.md`에 append-only로 추가:

```markdown
## [YYYY-MM-DD HH:MM] ingest | <Source Title>
- source: [[wiki/sources/<source-page>|<title>]]
- created: [[new-page-1]], [[new-page-2]]
- updated: [[existing-1]], [[existing-2]]
- contradictions: [[existing-3]] (X vs Y)
- notes: <짧은 요약>
```

## 7. REPORT — 사용자에게 보고

작업 완료 후 사용자에게:

```markdown
✅ ingest 완료: <Title>

- 작성한 페이지 N개: [[a]], [[b]]
- 업데이트한 페이지 M개: [[c]], [[d]]
- 역링크 점검(§4.4): 추가 J개 [[f]], 의도적으로 생략 L개 (이유)
- 발견된 모순 K개: [[e]] (X vs Y)
- 제안되는 후속 질문:
  - "...에 대해 더 알아볼까요?"
  - "[[X]]와 [[Y]]의 관계를 더 파헤쳐볼까요?"
```

## 모범 사례

- **하나씩 처리:** 한 세션에서 여러 소스를 동시에 ingest하는 것보다 한 번에 하나씩 사용자와 대화하며 처리하는 것이 위키의 품질을 높인다.
- **takeaway는 사용자의 것:** Claude가 일방적으로 결정한 takeaway만 반영하면 위키는 Claude의 위키가 된다. 사용자의 강조점을 반영해야 사용자의 위키가 된다.
- **링크 우선:** 새 페이지를 만들기 전에 기존 페이지에 흡수시킬 수 있는지 항상 먼저 검토.
- **frontmatter 정확하게:** `sources:` 배열은 거짓말을 하면 안 된다. 사용한 소스만 정확히 기록.

## 안티 패턴

- ❌ "이거 ingest해줘"라고 했다고 바로 페이지를 쏟아내기 — 항상 takeaway 합의 먼저.
- ❌ raw 파일을 수정하기 — 절대 금지.
- ❌ 한 소스에서 너무 많은 새 페이지 만들기 — 보통 1 소스 = 1~3 새 페이지가 적절. 그 이상이면 위키 구조를 다시 검토할 신호.
- ❌ index.md / log.md 갱신 잊기 — 이 두 파일이 깨지면 위키는 navigability를 잃는다.
- ❌ 새 페이지에서 기존 페이지로만 링크하고 끝내기 — 특히 topic에서 들어오는 링크가 없으면 새 클러스터는 섬이 된다 (§4.4).
