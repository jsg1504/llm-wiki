# LLM Wiki — Claude Code 프로젝트

[Karpathy의 LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (2026-04-04)을 Claude Code 위에서 실전 동작 가능한 형태로 구체화한 프로젝트.

## 핵심 아이디어

**RAG가 아니라 wiki다.** RAG는 매 질문마다 raw chunk를 다시 끌어와 답한다. 이 프로젝트는 LLM이 **점진적으로 누적되는 markdown 위키**를 유지보수한다. 새 소스가 들어오면 단순히 인덱싱하는 게 아니라, 읽고 핵심을 뽑아 기존 위키와 통합한다 — 새 페이지를 만들고, 기존 페이지를 갱신하고, 모순을 표시하고, cross-reference를 더하면서.

> 사용자는 sourcing/curation/questioning을 한다. Claude는 모든 bookkeeping을 한다.

Obsidian으로 위키를 보면서 Claude Code로 위키를 키워간다.

---

## 디렉토리 구조

```
.
├── CLAUDE.md                     # 위키의 헌법 (스키마)
├── README.md                     # 이 파일
├── .claude/
│   ├── settings.json             # hook + permission
│   ├── agents/                   # 3개 sub-agent
│   │   ├── librarian.md          # 큰 작업 orchestrator
│   │   ├── editor.md             # 페이지 본문 작성 전담
│   │   └── linker.md             # 그래프 무결성 전담
│   ├── commands/                 # 슬래시 커맨드
│   │   ├── ingest.md             # /ingest <path>
│   │   ├── lint.md               # /lint
│   │   ├── wiki-status.md        # /wiki-status
│   │   └── save-as-synthesis.md  # /save-as-synthesis
│   ├── hooks/                    # 4개 hook
│   │   ├── protect-raw.sh        # raw/ 쓰기 차단 (PreToolUse)
│   │   ├── validate-frontmatter.sh  # frontmatter 검증 (PostToolUse)
│   │   ├── session-start.sh      # 세션 시작 시 위키 현황 주입
│   │   └── log-tracker.sh        # log.md 갱신 누락 경고 (Stop)
│   └── skills/                   # 4개 skill
│       ├── source-ingest/SKILL.md   # 새 소스 통합
│       ├── wiki-page/SKILL.md       # 페이지 작성/리라이트
│       ├── wiki-link/SKILL.md       # rename, validate, orphan, suggest
│       └── wiki-lint/SKILL.md       # 종합 건강 검진
├── raw/                          # 원본 소스 (IMMUTABLE)
│   ├── articles/                 # 웹 클리핑, 블로그 포스트
│   ├── papers/                   # 논문
│   ├── notes/                    # 사용자 메모
│   └── assets/                   # 이미지 등
├── wiki/                         # LLM이 소유하는 layer
│   ├── entities/                 # 사람·조직·제품·도구·모델
│   ├── concepts/                 # 추상 개념·패턴
│   ├── topics/                   # 큰 주제 영역 (hub 페이지)
│   ├── sources/                  # 각 raw 소스의 1:1 요약
│   ├── syntheses/                # Q&A에서 나온 보존할 답변
│   └── meta/                     # index.md, log.md, glossary.md, lint-*.md
└── scripts/                      # 보조 스크립트 (선택)
```

---

## 빠른 시작

### 1. 프로젝트 초기화

```bash
cd llm-wiki
chmod +x .claude/hooks/*.sh
git init
git add -A && git commit -m "bootstrap: llm-wiki scaffolding"
```

### 2. Claude Code로 진입

```bash
claude
```

`SessionStart` hook이 위키 현황을 자동 주입한다.

### 3. 첫 소스 ingest

```bash
# 1. raw/에 소스 두기
cp ~/Downloads/some-article.md raw/articles/2026-04-28-some-article.md

# 2. Claude에게 통합 요청
> /ingest raw/articles/2026-04-28-some-article.md
```

Claude는:
1. 소스를 읽고
2. 핵심 takeaway 후보를 사용자에게 제시 → **합의**
3. `wiki/sources/`에 1:1 요약 페이지 작성
4. 영향받는 entity/concept/topic 페이지 갱신
5. `wiki/meta/index.md`와 `log.md` 갱신
6. 종합 보고

### 4. 위키에 질문

```
> 이 위키에서 X에 대해 알려줘
```

답변이 가치 있으면:
```
> /save-as-synthesis
```

### 5. 정기 점검

```
> /lint
```

---

## 주요 명령어 cheatsheet

| 명령 | 용도 |
|---|---|
| `/ingest <path>` | raw 파일 통합 |
| `/lint` | 종합 건강 검진 |
| `/wiki-status` | 빠른 현황 스냅샷 |
| `/save-as-synthesis` | 마지막 답변을 wiki/syntheses/에 보존 |

| 자연어 표현 | 자동 호출되는 스킬/에이전트 |
|---|---|
| "이거 정리해줘" + 파일 언급 | `source-ingest` |
| "이 페이지 다시 써줘" | `editor` 에이전트 + `wiki-page` |
| "X를 Y로 이름 바꿔" | `linker` 에이전트 + `wiki-link` |
| "위키 어디가 부족해?" | `wiki-lint` |
| "5개 논문 한번에 ingest" | `librarian` 에이전트가 plan |

---

## Obsidian 통합 (선택)

이 위키는 그냥 markdown 폴더이므로 Obsidian이 그대로 동작한다.

1. Obsidian에서 이 디렉토리를 vault로 열기.
2. Settings → Files and links → Use [[Wikilinks]] = **ON**.
3. Settings → Files and links → Default location for new attachments → `raw/assets/`.
4. (선택) Obsidian Web Clipper 확장으로 `raw/articles/`에 직접 클리핑.

그래프 뷰가 가장 강력한 사용처. 클러스터링과 hub/orphan을 시각적으로 본다.

---

## 설계 원칙

### 1. Three-layer immutability
- `raw/` = immutable (hook으로 차단)
- `wiki/` = LLM이 소유
- `CLAUDE.md` = 사용자와 LLM이 공동 소유

### 2. 항상 사용자 합의 먼저
Ingest 시 takeaway를 합의 없이 위키에 쏟지 않는다. 큰 변경(5+ 페이지)은 plan을 먼저 제시한다.

### 3. Append-only log
`wiki/meta/log.md`는 절대 과거 항목을 수정하지 않는다. 위키의 추적성은 git + log.md의 이중 보장.

### 4. 모순은 보존, 침묵하지 않음
새 소스가 기존과 어긋나면 한쪽을 지우지 않고 `> ⚠️ Contradiction:` 마커로 양쪽을 남긴다. 사용자가 판단.

### 5. 출처 없는 사실 금지
모든 사실 주장은 `[[wiki/sources/...]]` 또는 footnote로 출처를 인용한다. 출처 없으면 위키에 들어갈 수 없다.

---

## 자주 묻는 질문

**Q. 한국어 페이지명을 써도 되나요?**
A. 됩니다. 단 한 카테고리 안에선 통일하세요. entity는 보통 영어, concept/topic은 한글이 자연스러우면 한글.

**Q. raw/ 안의 파일을 바꾸면 어떻게 되나요?**
A. `protect-raw.sh` hook이 Edit/Write 도구로 바꾸려는 시도를 차단합니다. 직접 파일 시스템에서 바꾸면 차단되지 않지만 위키 추적성이 깨집니다.

**Q. 위키가 100+ 페이지를 넘으면?**
A. index.md만으로는 부족할 수 있습니다. [qmd](https://github.com/tobi/qmd) 같은 markdown 검색 도구 도입을 검토하세요.

**Q. 여러 명이 함께 쓰려면?**
A. 그냥 git repo입니다. 일반 git 워크플로우로 협업. 단, Claude가 동시에 여러 사람 컨텍스트로 위키를 바꾸면 충돌이 생기므로 lint를 자주 돌리세요.

**Q. Obsidian 없이 쓸 수 있나요?**
A. 가능. wikilink는 그냥 텍스트로 보입니다. 단 그래프 뷰의 가치가 큽니다.

---

## Inspiration

- Andrej Karpathy, *llm-wiki* gist (2026-04-04)
- Vannevar Bush, *As We May Think* (1945) — Memex
- Ward Cunningham — original wiki (1995)
- 댓글 토론에서 나온 여러 구현체들 (Beever Atlas, Synthadoc, Link, claude-obsidian 등)
