---
description: Show a quick snapshot of the wiki's current state — page counts by category, recent activity from log.md, and any open contradictions.
---

# /wiki-status — 위키 현황 요약

빠른 스냅샷을 사용자에게 보여준다. lint와 달리 건강 점검이 아니라 **현재 상태 요약**이다.

## 출력 항목

```markdown
## 위키 현황 (YYYY-MM-DD)

**규모**
- 총 N 페이지
  - entities: K
  - concepts: K
  - topics: K
  - sources: K
  - syntheses: K

**최근 활동** (log.md tail -5)
- [date] ingest | <title>
- [date] query | <q>
- ...

**미해결 모순** (`> ⚠️ Contradiction:` 마커 있는 페이지)
- [[page-X]]: ...
- ...

**가장 큰 hub 페이지** (inbound link 기준 top 5)
- [[wiki-pattern]]: 17
- ...

**stub 상태로 오래된 페이지** (status: stub, created > 30일 전)
- [[X]]: 45일째 stub
- ...
```

## 구현

다음 bash 명령들을 활용:

```bash
# 페이지 카운트
for d in entities concepts topics sources syntheses; do
  echo "$d: $(find wiki/$d -name '*.md' 2>/dev/null | wc -l)"
done

# 최근 log
grep "^## \[" wiki/meta/log.md | tail -5

# 모순
grep -rln "⚠️ Contradiction" wiki/ --include="*.md"

# Hub (inbound 카운트는 별도 grep)
```

종합해서 마크다운으로 출력. 출력 후 "이 중 처리할 항목이 있으면 말씀해주세요"로 마무리.
