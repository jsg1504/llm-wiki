---
name: wiki-query
description: Use this skill when the user asks a question that should be answered FROM the wiki — "X에 대해 알려줘", "A와 B는 뭐가 달라?", "위키에서 Y는 어떻게 정리돼 있어?", "/query ...", or any question about topics the wiki covers (agents, loops, harnesses, evaluation, etc.). Answers index-first, cites a wiki page for every claim, separates wiki-backed claims from Claude's own inference, and ends by deciding whether the answer deserves to be filed back as a synthesis page. Do NOT use for ingesting new sources (source-ingest), health checks (wiki-lint), or questions about the repo's tooling itself (skills, hooks, CLAUDE.md).
---

# wiki-query skill

위키에 질문하고 답하는 표준 절차. Karpathy 패턴의 세 operation 중 **Query**에 해당한다.

> 핵심: 좋은 답은 채팅에서 사라지면 안 된다. Ingest가 소스를 쌓듯, Query는 **탐색 결과를 쌓는다.**

## 0. 질문 분류

질문을 먼저 분류한다. 분류에 따라 읽을 범위와 출력 형식이 정해진다.

| 유형 | 예시 | 읽을 범위 | 기본 형식 |
|---|---|---|---|
| **lookup** | "agent-recipe가 뭐야?" | 페이지 1~2개 | 짧은 산문 |
| **synthesis** | "loop engineering의 핵심 주장들을 묶어줘" | topic + 관련 concept 3~6개 | 구조화된 산문 |
| **comparison** | "Osmani와 Gavrilescu의 taste 관점 비교" | 비교 대상 각각 + 공통 source | 비교 표 + 해설 |
| **relation** | "A와 B는 어떤 관계야?" | 두 페이지 + 공유 링크 | 산문 + mermaid 다이어그램 |
| **gap** | "위키에 X 관련 내용 있어?" | index + grep | 있음/없음 + 후보 소스 |

## 1. LOCATE — 인덱스 우선

1. **`wiki/meta/index.md`를 먼저 읽는다.** 임베딩 검색 대신 인덱스를 쓰는 것이 이 위키의 원칙이다.
2. 인덱스에서 후보 페이지를 고른다. 한 줄 요약과 ⚠️ 표시(모순·정정)를 함께 본다.
3. 인덱스로 부족하면 보조 수단을 쓴다:
   ```bash
   # 용어가 어디서 언급되는지 (aliases 포함)
   grep -rli "<term>" wiki/ --include="*.md"
   grep -n -i "<term>" wiki/meta/glossary.md
   grep -rn "aliases:.*<term>" wiki/
   ```
4. 후보 페이지를 읽는다. 페이지의 `## Related`, 본문 wikilink를 **1홉만** 따라간다. 무한히 따라가지 않는다.
5. 주장이 정말 소스에 있는지 확인이 필요하면 `wiki/sources/<id>.md`까지 내려간다.
6. **`raw/`는 마지막 수단이다.** 위키에 없는 디테일이 필요할 때만 읽는다. raw에서 가져온 내용은 "위키에 아직 반영 안 된 내용"이라는 뜻이므로, 답변 끝에 반영(curate) 후보로 보고한다.

## 2. ANSWER — 출처를 단 답변

### 2.1 출처 규칙 (가장 중요)

- **위키 근거가 있는 모든 주장에 wikilink를 단다.** 문장 또는 bullet 끝에 `([[page]])`.
  - 원 소스까지 확인했다면 `([[loop-engineering]], [[2026-06-07-loop-engineering]])`처럼 둘 다.
- **세 층위를 섞지 않는다.** 섞어야 하면 표시한다.
  - 위키 근거 → 출처 링크
  - Claude의 추론·연결 (위키 여러 페이지를 엮어 새로 도출한 것) → `*(추론)*` 표시. 이것이 synthesis의 원재료다.
  - 위키 밖 일반 지식 → `*(위키 외)*` 표시. 최소한으로만.
- **위키에 없으면 없다고 말한다.** 일반 지식으로 조용히 메우지 않는다. "위키에는 X에 대한 내용이 없다"고 쓴 뒤, 채울 만한 소스 종류를 제안한다.

### 2.2 모순 처리

- 관련 페이지에 `> ⚠️ Contradiction:` 블록이 있으면 **답변에 반드시 드러낸다.** 한쪽 주장만 골라 답하지 않는다.
- 양쪽 주장, 각 출처, 위키에 기록된 판정 상태(부분 판정, 미해결 등)를 함께 제시한다.
- 답변 중 **새 모순**을 발견하면 (두 페이지가 같은 사실을 다르게 말함) 따로 보고한다. 직접 고치지 않는다.

### 2.3 형식 선택

질문 유형(§0)의 기본 형식을 따르되, 사용자가 형식을 지정하면 그것을 우선한다.

- **비교 표:** comparison 질문의 기본. 행 = 비교 축, 열 = 대상. 각 셀에 출처 링크.
- **mermaid 다이어그램:** 개념 간 관계, 루프·파이프라인 구조. Obsidian이 바로 렌더링한다.
- **Marp 슬라이드:** 사용자가 "발표자료", "슬라이드"를 요청할 때만. frontmatter에 `marp: true`. 저장 시 `wiki/syntheses/<name>.marp.md`.
- **차트 (matplotlib):** 정량 데이터가 위키에 실제로 있을 때만. 이 위키는 정량 데이터가 드물다. 없는 숫자를 만들지 않는다.

### 2.4 답변 구조

```markdown
<핵심 답 1~3문장>

<본문: 분류에 맞는 형식, 모든 주장에 출처>

**참고한 페이지:** [[a]], [[b]], [[c]]
**위키의 빈틈:** (있으면) <위키에 없어서 답할 수 없던 부분>
```

## 3. FILE BACK — 보존할지 판단

답변 후 **매번** 보존 가치를 판단한다. Karpathy 패턴에서 가장 자주 빠지는 단계다.

### 3.1 저장을 제안하는 경우 (하나라도 해당)

- 2개 이상 소스를 엮어 **어느 페이지에도 없는 연결**을 만들었다 (`*(추론)*` 표시가 핵심인 답).
- 비교 표를 새로 만들었다.
- 모순을 정리하거나 판정을 진전시켰다.
- 사용자가 같은 주제를 두 번 이상 물었다.
- 사용자가 "좋다", "저장해줘" 등으로 가치를 표현했다.

### 3.2 저장을 제안하지 않는 경우

- 단순 lookup. 답이 한 페이지 내용을 그대로 옮긴 것이면 그 페이지 링크로 충분하다.
- 위키에 없어서 답하지 못한 경우. 이때는 저장 대신 **ingest할 소스**를 제안한다.

### 3.3 제안 형식

```
💾 이 답변은 [[a]]와 [[b]]를 엮은 새 연결을 담고 있습니다.
   `wiki/syntheses/<suggested-name>.md`로 저장할까요? (/save-as-synthesis)
```

승인하면 `/save-as-synthesis` 절차(`.claude/commands/save-as-synthesis.md`)를 따른다. synthesis 페이지는 `wiki-page` skill §3.4 템플릿을 쓴다.

### 3.4 기존 페이지 개선 제안

답하다 보면 기존 페이지의 문제가 보인다. **직접 고치지 않고 목록으로 제안한다.**
- 서로 관련 있는데 링크가 없는 페이지 → `wiki-link` 후보
- raw에서 가져와야 했던 디테일 → 해당 페이지 보강 후보
- 새로 발견한 모순 → `⚠️ Contradiction` 블록 후보

## 4. LOG

- **synthesis를 저장했을 때만** `wiki/meta/log.md`에 기록한다. 저장하지 않은 질문은 기록하지 않는다 (로그 노이즈 방지).
  ```
  ## [YYYY-MM-DD HH:MM] query | <질문>
  - created: [[<synthesis-page>]] (synthesis)
  - cited: [[a]], [[b]], [[c]]
  - notes: <새로 만든 연결 한 줄>
  ```
- §3.4 제안을 사용자가 승인해 페이지를 고쳤다면, 같은 항목에 `- updated:`로 함께 적는다.

## 모범 사례

- 인덱스 → 페이지 → source → raw 순서로 **필요한 만큼만** 내려간다.
- 사용자의 질문이 모호하면 분류(§0)를 먼저 확인한다: "비교를 원하시나요, 관계 설명을 원하시나요?"
- 답의 확신도는 출처 수와 모순 유무로 판단한다. hedge를 늘어놓지 말고 근거를 보여준다.

## 안티 패턴

- ❌ 인덱스를 건너뛰고 기억이나 일반 지식으로 답하기
- ❌ 출처 없는 주장 (특히 그럴듯한 일반론)
- ❌ `⚠️ Contradiction`이 있는 주제에서 한쪽만 답하기
- ❌ 답변 중 발견한 문제를 묻지 않고 위키에 바로 반영하기
- ❌ 모든 답변을 저장하자고 조르기. 기준(§3.1)에 맞을 때만 제안한다.
