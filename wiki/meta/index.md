---
title: Wiki Index
type: meta
created: 2026-04-28
updated: 2026-09-11
status: mature
---

# 📚 Wiki Index

> 이 위키의 모든 페이지를 카테고리별로 나열. 새 페이지가 생길 때마다 Claude가 자동 갱신한다. 위키의 1차 진입점.

위키 페이지 수가 적을 땐 이 인덱스만으로 navigation 충분. 100+ 페이지가 되면 검색 도구(qmd 등) 도입 검토.

---

## 🧠 Topics (큰 주제 영역)

- [[ai-native-sdlc]] — SDLC 6단계를 선형 핸드오프에서 커밋된 아티팩트가 다음 단계를 트리거하는 루프로 재설계한 것 (소스 1개, 2026-09-11)

---

## 💡 Concepts (개념·패턴·알고리즘)

- [[agentic-governance]] — 에이전트가 코드를 쓸 때의 통제 계층(skill/hook/managed settings)과 production gate 경계 (소스 1개, 2026-09-11)
- [[artifact-chain]] — 각 단계가 커밋된 파일로 끝나고 다음 단계가 그것을 읽는 패턴. 커밋 체인이 곧 audit trail (소스 1개, 2026-09-11)

---

## 👤 Entities (사람·조직·제품·도구·모델)

- [[claude-code]] — Anthropic의 에이전틱 코딩 도구. plan/auto mode, CLAUDE.md, skills, hooks, subagents, worktrees (소스 1개, 2026-09-11)

---

## 📄 Sources (원본 소스 1:1 요약)

- [[2026-08-21-the-ai-native-sdlc-playbook]] — *The AI-Native SDLC playbook*, Louis Claxton (Anthropic / Claude Blog, 2026-08-21). 규제 엔터프라이즈 대상 SDLC 6단계 재설계 플레이북 (2026-09-11)

---

## 🧩 Syntheses (Q&A에서 나온 보존할 만한 답변)

*아직 synthesis 페이지가 없습니다.*

---

## 🔧 Meta

- [[log]] — 시간순 활동 기록
- [[glossary]] — 이 위키 안에서 자주 쓰는 용어 정의
- [[index]] — (이 페이지)

---

## 사용 팁

- **Obsidian으로 보면 그래프 뷰가 가장 유용.** Settings → Files and links → Use [[Wikilinks]] = ON.
- **새 소스 추가 시:** `raw/articles/` 또는 `raw/papers/`에 두고 Claude에게 `/ingest <path>` 또는 "이거 정리해줘".
- **위키 점검:** `/lint` 또는 "위키 점검해줘".
- **현황 보기:** `/wiki-status`.
