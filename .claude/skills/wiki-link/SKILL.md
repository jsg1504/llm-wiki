---
name: wiki-link
description: Use this skill whenever wiki page links need to be created, validated, repaired, or analyzed. Triggers include: renaming a page (must update all backlinks), checking for broken links, finding orphan pages, suggesting cross-references between semantically related pages that aren't yet linked, and analyzing the wiki graph structure. Do NOT use for creating page content itself (that's wiki-page) or for ingesting new sources (that's source-ingest). The deliverable depends on the operation: a list of fixed links, a rename plan, a list of suggested cross-references, or a graph analysis report.
---

# wiki-link skill

위키의 링크 무결성과 그래프 구조를 관리하는 스킬. 위키의 가치는 페이지 자체보다 **페이지 사이의 링크**에서 나온다 — 링크가 깨지면 위키는 무너진다.

## 1. 작업 종류

이 스킬은 다음 5가지 작업 중 하나를 수행한다.

### 1.1 RENAME — 페이지 이름 변경 (백링크 함께 갱신)
### 1.2 VALIDATE — 깨진 링크 검사
### 1.3 ORPHANS — 고아 페이지 찾기
### 1.4 SUGGEST — 누락된 cross-reference 제안
### 1.5 GRAPH — 그래프 통계/구조 분석

---

## 1.1 RENAME

### 입력
사용자가 "X 페이지를 Y로 이름 바꿔줘"라고 함.

### 절차
1. **모든 백링크 찾기:**
   ```bash
   grep -rn "\[\[X\]\]" wiki/ --include="*.md"
   grep -rn "\[\[X|" wiki/ --include="*.md"  # alias가 있는 경우
   ```
2. **변경 계획을 사용자에게 제시:**
   ```
   "X" → "Y"로 이름 변경 시 영향받는 파일 N개:
   - wiki/concepts/foo.md (line 42)
   - wiki/topics/bar.md (line 17, 89)
   - ...
   진행할까요?
   ```
3. **승인 후:**
   - 파일 자체를 이동: `wiki/.../X.md` → `wiki/.../Y.md`
   - 모든 백링크에서 `[[X]]` → `[[Y]]`, `[[X|...]]` → `[[Y|...]]`
   - frontmatter `aliases:`에 X 추가 (선택, 안전망)
   - `wiki/meta/index.md` 갱신
   - `wiki/meta/log.md`에 `## [date] curate | rename X → Y` 기록

### 주의
- 해당 페이지의 frontmatter `title:`도 함께 갱신.
- raw 소스 파일은 절대 건드리지 않음.

---

## 1.2 VALIDATE

### 트리거
사용자가 "링크 검사해줘" 또는 lint 일부로 호출.

### 절차
1. 모든 위키 페이지의 wikilink를 추출:
   ```bash
   grep -rohE "\[\[[^]]+\]\]" wiki/ --include="*.md" | sort -u
   ```
2. 각 링크 타겟이 실제로 존재하는지 확인. wikilink는 파일명 매칭이므로:
   - `[[foo]]` → 어떤 디렉토리든 `foo.md`가 있는가?
   - `[[wiki/sources/2026-04-04-bar]]` → 정확한 경로
3. **깨진 링크 보고:**
   ```
   ❌ 깨진 링크 N개:
   - wiki/concepts/foo.md:42 → [[bar]] (해당 파일 없음)
   - ...
   
   대처:
   - 오타라면 수정
   - 만들기로 했던 페이지라면 stub 생성
   - 더 이상 필요 없으면 링크 제거
   ```
4. 수정은 사용자 승인 후 일괄 적용.

---

## 1.3 ORPHANS

### 정의
**고아 페이지** = 어떤 다른 페이지로부터도 링크되지 않는 페이지. (단, source 페이지와 meta 페이지는 inbound link가 적어도 무방)

### 절차
1. 모든 위키 페이지 목록 만들기.
2. 모든 wikilink 타겟 목록 만들기.
3. 차집합: `pages - linked_targets` = 고아 후보.
4. `wiki/meta/`와 `wiki/sources/`는 제외 (이들은 진입점/터미널이라 OK).
5. 사용자에게 보고:
   ```
   고아 페이지 N개:
   - wiki/concepts/foo.md — 어떤 페이지로 흡수?
   - wiki/entities/bar.md — 어떤 topic에 속함?
   ...
   
   각각에 대해:
   (a) 다른 페이지에서 링크 추가
   (b) 다른 페이지로 흡수 후 삭제
   (c) 그대로 둠 (이유 명시)
   ```

---

## 1.4 SUGGEST — 누락된 cross-reference

### 트리거
사용자가 "cross-ref 제안해줘" 또는 lint 일부로 호출.

### 휴리스틱
1. 페이지 A가 페이지 B의 제목 또는 alias를 본문에서 **plain text**로 언급하는데 링크가 안 되어 있는 경우.
   ```bash
   # 예: foo.md가 본문에 "Karpathy"라고 적었는데 [[andrej-karpathy]] 링크 없음
   ```
2. 같은 tag를 공유하지만 서로 링크 안 된 페이지들.
3. 같은 source를 인용하는 페이지들 (sources frontmatter 비교).

### 보고
```
누락 가능 cross-reference N개:
- [[foo]] ↔ [[bar]] (둘 다 'rag' 태그, 서로 링크 없음)
- [[baz]]: 본문에 'Karpathy'를 언급하나 [[andrej-karpathy]] 링크 없음
...

각각 (a) 추가 (b) 무시 (c) 보류
```

---

## 1.5 GRAPH — 그래프 분석

### 통계
- 총 페이지 수
- 총 링크 수
- 평균 outbound / inbound degree
- **Hub 페이지** (inbound degree 상위 10): 위키의 "허브"
- **Leaf 페이지** (outbound degree 0이거나 1): 막다른 페이지

### 보고 예시
```
📊 위키 그래프 (YYYY-MM-DD):
- 페이지 N개, 링크 M개
- 평균 in-degree: 2.3, out-degree: 4.1
- Top hubs:
  1. [[wiki-pattern]] — 17 inbound
  2. [[andrej-karpathy]] — 12 inbound
  ...
- 고아 (in=0): K개 → [[a]], [[b]], ...
- 외딴 leaf (out=0): L개 → [[c]], [[d]], ...

💡 통찰: [[wiki-pattern]]이 너무 큰 hub다. 분할을 검토하라.
```

---

## 2. wikilink 파싱 규칙

이 위키에서 인정하는 링크 형식:

| 형식 | 의미 |
|---|---|
| `[[page-name]]` | 같은 위키 내 페이지 (디렉토리 무관, 파일명 매칭) |
| `[[page-name\|표시 텍스트]]` | alias |
| `[[wiki/sources/2026-04-04-foo]]` | 명시적 경로 (디렉토리에서 모호하면 사용) |
| `[[wiki/sources/2026-04-04-foo#section]]` | 섹션 앵커 |
| `[원본 파일](../../raw/...)` | raw 소스로의 링크 (markdown 문법, **wikilink 사용 금지**) |

### 안티패턴
- ❌ `[Karpathy](./entities/andrej-karpathy.md)` — wikilink 써야 함.
- ❌ `[[../../raw/...]]` — raw로의 wikilink는 의미가 깨짐. markdown 링크 사용.
- ❌ 절대 경로 (`[[/Users/.../wiki/...]]`) — 위키는 portable해야 함.

---

## 3. 자주 묻는 시나리오

### Q. 한 페이지를 둘로 분할하려면?
1. 분할 계획을 사용자에게 제시 (어떤 섹션을 어느 새 페이지로).
2. 새 페이지 2개를 `wiki-page` 스킬로 생성.
3. 원본은 hub 페이지로 축약 (각 분할 페이지로 링크).
4. 백링크 갱신: 원본 페이지를 가리키던 링크 중 어느 새 페이지로 보낼지 결정.
5. log에 기록.

### Q. 두 페이지를 합치려면?
1. 어느 쪽을 흡수자(canonical)로 할지 결정.
2. 흡수자에 다른 쪽 내용 병합.
3. 흡수되는 쪽 페이지 삭제, 그 페이지의 모든 백링크를 흡수자로 변경.
4. 흡수자 frontmatter `aliases:`에 흡수된 페이지명 추가.
5. log에 기록.

### Q. 한국어 페이지명과 영어 페이지명 혼용 가능?
가능. 단 같은 카테고리 안에선 통일. alias로 양쪽 모두 등록 가능.
