# Wiki Log

> 이 위키에서 일어난 모든 작업의 시간순 기록. **append-only**: 절대 과거 항목을 수정하지 않는다. 각 항목은 `## [YYYY-MM-DD HH:MM] <op> | <title>` 형식이며, grep으로 빠르게 훑을 수 있다.

빠른 조회:
```bash
# 최근 5건
grep "^## \[" wiki/meta/log.md | tail -5

# 특정 날짜 이후
grep "^## \[2026-04" wiki/meta/log.md

# ingest 작업만
grep "^## \[.*\] ingest" wiki/meta/log.md
```

`<op>` ∈ {`ingest`, `query`, `lint`, `curate`, `manual`}

---

## [2026-04-28 00:00] manual | wiki bootstrap
- created: 프로젝트 스캐폴딩
- notes: CLAUDE.md, 4개 스킬 (source-ingest, wiki-page, wiki-link, wiki-lint), 3개 에이전트 (librarian, editor, linker), 4개 슬래시 커맨드 (/ingest, /lint, /wiki-status, /save-as-synthesis), 4개 hook (protect-raw, validate-frontmatter, session-start, log-tracker), 초기 meta 페이지(index, glossary).
- next: 첫 source를 raw/에 두고 /ingest로 시작.

## [2026-11-25 23:42] manual | pure 브랜치: 콘텐츠 초기화
- touched: [[index]], [[glossary]], [[log]]
- notes: agentic(2b67522)에서 분기. raw/ 소스와 wiki/ 콘텐츠 페이지·lint 리포트를 모두 제거하고, index·glossary는 bootstrap 템플릿으로 복원(index 사용 팁에 /query 추가). 도구(.claude/, CLAUDE.md, README, scripts, Obsidian 설정)는 agentic 최신 상태 유지. 이전 로그와 콘텐츠는 agentic 브랜치 이력에 보존됨.
- next: 첫 source를 raw/에 두고 /ingest로 시작.
