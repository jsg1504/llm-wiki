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

## [2026-09-11 00:00] ingest | The AI-Native SDLC playbook
- source: [[2026-08-21-the-ai-native-sdlc-playbook]] — Louis Claxton, Anthropic / Claude Blog (2026-08-21)
- created: [[2026-08-21-the-ai-native-sdlc-playbook]] (source), [[ai-native-sdlc]] (topic), [[artifact-chain]] (concept), [[agentic-governance]] (concept), [[claude-code]] (entity)
- updated: [[index]]
- contradictions: 없음 (첫 콘텐츠 ingest — 기존 페이지 0개)
- notes: 위키의 첫 실질 ingest. 1049줄 플레이북에서 합의한 takeaway 7개를 3개 축으로 분할 — 아티팩트 체인(구조), 거버넌스 계층(통제), Claude Code(도구). 사용자 승인으로 5페이지 안 채택(CLAUDE.md 권장치 1~3개보다 많으나, 빈 위키의 앵커 확보 목적). [[claude-code]]는 단일 출처 기반이라 범위 주의 배너를 달았다.
