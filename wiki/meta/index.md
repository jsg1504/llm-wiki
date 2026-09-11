---
title: Wiki Index
type: meta
created: 2026-04-28
updated: 2026-09-12
status: mature
---

# 📚 Wiki Index

> 이 위키의 모든 페이지를 카테고리별로 나열. 새 페이지가 생길 때마다 Claude가 자동 갱신한다. 위키의 1차 진입점.

위키 페이지 수가 적을 땐 이 인덱스만으로 navigation 충분. 100+ 페이지가 되면 검색 도구(qmd 등) 도입 검토.

---

## 🧠 Topics (큰 주제 영역)

- [[ai-native-sdlc]] — SDLC 6단계를 선형 핸드오프에서 커밋된 아티팩트가 다음 단계를 트리거하는 루프로 재설계한 것 (소스 3개, 2026-09-12) ⚠️ 모순 1건 *부분 판정*
- [[multi-agent-systems]] — 여러 에이전트가 협력하는 시스템. 중심 질문은 "어떻게"가 아니라 "언제 15배 토큰을 낼 가치가 있는가" (소스 3개, 2026-09-12) ⚠️ 모순 1건 *부분 판정 (적합성 ✅ / 경제성 ✅, 잔여 질문 2건)*

---

## 💡 Concepts (개념·패턴·알고리즘)

- [[agent-evaluation]] — 경로가 매번 달라지는 에이전트를 결과 기준으로 평가하는 법. LLM-as-judge, end-state evaluation, 판정자 분리 (소스 3개, 2026-09-12)
- [[agent-orchestration-patterns]] — 여러 에이전트를 엮는 여섯 가지 제어 구조. classify / fan-out / adversarial verification / generate-filter / tournament / loop-until-done (소스 2개, 2026-09-12) 🆕
- [[agentic-governance]] — 에이전트가 코드를 쓸 때의 통제 계층(skill/hook/managed settings)과 production gate 경계, quarantine (소스 2개, 2026-09-12)
- [[artifact-chain]] — 각 단계가 커밋된 파일로 끝나고 다음 단계가 그것을 읽는 패턴. 커밋 체인이 곧 audit trail (소스 2개, 2026-09-12)
- [[dynamic-workflows]] — 에이전트가 태스크별 harness를 즉석에서 작성. 조정이 LLM 컨텍스트에서 결정론적 코드로 이동한다 (소스 2개, 2026-09-12) 🆕
- [[orchestrator-worker]] — lead agent가 분해·위임·종합하고 subagent가 독립 context window에서 병렬 탐색하는 구조 (소스 3개, 2026-09-12)
- [[subagent]] — 부모가 호출하는 독립 context window의 하위 에이전트. 리서치형↔코딩형 용어 정렬, 조정 주체 **네** 층위 구분 (소스 3개, 2026-09-12)

---

## 👤 Entities (사람·조직·제품·도구·모델)

- [[anthropic]] — Claude를 만드는 조직. 현재 이 위키의 모든 소스의 발행처이므로 관점 편향 추적 지점 (소스 2개, 2026-09-11) *stub*
- [[claude-code]] — Anthropic의 에이전틱 코딩 도구. plan/auto mode, CLAUDE.md, skills, hooks, subagents, worktrees, dynamic workflows (소스 3개, 2026-09-12)

---

## 📄 Sources (원본 소스 1:1 요약)

- [[2025-06-13-multi-agent-research-system]] — *How we built our multi-agent research system*, Jeremy Hadfield 외 5인 (Anthropic Engineering, 2025-06-13). Research 기능의 orchestrator-worker 아키텍처·토큰 경제성·평가·프로덕션 회고 (2026-09-11)
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — *A harness for every task: dynamic workflows in Claude Code*, Thariq Shihipar·Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). Claude가 harness를 직접 쓴다. 여섯 패턴·아홉 사용 사례·세 실패 모드 (2026-09-12)
- [[2026-08-21-the-ai-native-sdlc-playbook]] — *The AI-Native SDLC playbook*, Louis Claxton (Anthropic / Claude Blog, 2026-08-21). 규제 엔터프라이즈 대상 SDLC 6단계 재설계 플레이북 (2026-09-11)

---

## 🧩 Syntheses (Q&A에서 나온 보존할 만한 답변)

*아직 synthesis 페이지가 없습니다.*

---

## 🔧 Meta

- [[log]] — 시간순 활동 기록
- [[lint-2026-09-12]] — 2026-09-12 건강 검진 보고서 (기계적 0건, 의미 층위 2건 High)
- [[glossary]] — 이 위키 안에서 자주 쓰는 용어 정의
- [[index]] — (이 페이지)

---

## 사용 팁

- **Obsidian으로 보면 그래프 뷰가 가장 유용.** Settings → Files and links → Use [[Wikilinks]] = ON.
- **새 소스 추가 시:** `raw/articles/` 또는 `raw/papers/`에 두고 Claude에게 `/ingest <path>` 또는 "이거 정리해줘".
- **위키 점검:** `/lint` 또는 "위키 점검해줘".
- **현황 보기:** `/wiki-status`.
