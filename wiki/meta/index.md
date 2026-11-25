---
title: Wiki Index
type: meta
created: 2026-04-28
updated: 2026-11-26
status: mature
---

# 📚 Wiki Index

> 이 위키의 모든 페이지를 카테고리별로 나열. 새 페이지가 생길 때마다 Claude가 자동 갱신한다. 위키의 1차 진입점.

위키 페이지 수가 적을 땐 이 인덱스만으로 navigation 충분. 100+ 페이지가 되면 검색 도구(qmd 등) 도입 검토.

---

## 🧠 Topics (큰 주제 영역)

- [[ai-native-sdlc]] — SDLC 6단계를 선형 핸드오프에서 커밋된 아티팩트가 다음 단계를 트리거하는 루프로 재설계한 것 (소스 7개, updated 2026-11-25) ⚠️ 모순 1건 *부분 판정*
- [[multi-agent-systems]] — 여러 에이전트가 협력하는 시스템. 중심 질문은 "어떻게"가 아니라 "언제 15배 토큰을 낼 가치가 있는가" + 인프라 비용 + 신뢰 경계 비용 (소스 7개, updated 2026-11-25) ⚠️ 모순 1건 *부분 판정 (적합성 ✅ / 경제성 ✅, 잔여 질문 5건)*

---

## 💡 Concepts (개념·패턴·알고리즘)

- [[agent-recipe]] — **system distillation**(과정)과 **agent recipe**(결과물). 루프의 교훈을 eval·skill·prompt·harness profile로 증류해 git에 버전 관리한다. prompt 증류는 GEPA가 자동화했고, 모델 간 전이에 첫 정량 근거가 있다 (소스 3개, updated 2026-11-26) ⚠️ "그릇이 없다"는 부분적으로만 맞음
- [[agent-containment]] — 에이전트를 **감독**하는 대신 무엇을 할 수 있는지를 환경 층위에서 상한 짓는다. blast radius, 위험 3종 × 방어 3층, 세 격리 패턴 (소스 2개, 2026-09-21) 🆕
- [[agent-memory]] — context window 밖에 무엇을 남기고, 어떻게 갱신하고, 언제 다시 가져오는가. **원문을 남기고 추출한 것은 찾는 길로**. 갱신은 무효화(Zep, bi-temporal)와 덮어쓰기(A-MEM)로 갈리고 비교 데이터는 없다. 세 단계·네 조정점, 다섯 능력, 모델 vs harness, memory 정책도 능력 가정이다, 자동 갱신이 넓히는 poisoning 경로. 삭제는 여전히 빈칸 (소스 8개, updated 2026-11-26) 🆕
- [[agent-evaluation]] — 경로가 매번 달라지는 에이전트를 결과 기준으로 평가하는 법. LLM-as-judge, end-state evaluation, 판정자 분리, **사람은 eval을 만들지 않고 보정한다 + 프로덕션 A/B**, **채점 함수는 점수와 함께 텍스트를 낸다** (소스 11개, updated 2026-11-26) ⚠️ 정정 1건 — `/goal` evaluator는 룰 체커
- [[agent-orchestration-patterns]] — 여러 에이전트를 엮는 여섯 가지 제어 구조. classify / fan-out / adversarial verification / generate-filter / tournament / loop-until-done. 카탈로그에 없는 것: cadence (소스 4개, updated 2026-09-21)
- [[agentic-governance]] — 통제 계층(skill/hook/managed settings), production gate 경계, quarantine, 자격증명 격리, 환경 층위 우선 (소스 4개, updated 2026-09-21) ⚠️ quarantine 정정 1건
- [[artifact-chain]] — 각 단계가 커밋된 파일로 끝나고 다음 단계가 그것을 읽는 패턴. 커밋 체인이 곧 audit trail. **지속성은 공격 표면이기도 하다** (소스 6개, updated 2026-11-26)
- [[dynamic-workflows]] — 에이전트가 태스크별 harness를 즉석에서 작성. 조정이 LLM 컨텍스트에서 결정론적 코드로 이동한다 (소스 4개, updated 2026-09-21)
- [[loop-engineering]] — 프롬프트를 던지는 사람 자리를 시스템으로 대체한다. 다섯 primitive + 외부 state, 네 종류의 루프, 위임 경계. **실행 하나가 아니라 실행 사이를 설계하는 층.** OODA와 두 번째 루프 (소스 8개, updated 2026-11-26) ⚠️ 모순 1건 — taste는 루프에 맞는가
- [[meta-harness]] — harness의 가정은 모델이 좋아지면 썩는다. 더 좋은 harness 대신 **harness보다 오래 사는 인터페이스**를 고정한다 (소스 8개, updated 2026-11-26)
- [[orchestrator-worker]] — lead agent가 분해·위임·종합하고 subagent가 독립 context window에서 병렬 탐색하는 구조 (소스 3개, 2026-09-12)
- [[prompt-optimization]] — 가중치는 두고 prompt만 자동으로 고친다. GEPA: trace와 채점 텍스트를 반성하고 인스턴스별 Pareto frontier에서 진화. GRPO보다 최대 35배 적은 rollout으로 평균 +6% (소스 2개, updated 2026-11-26) 🆕
- [[prompt-injection]] — 에이전트 공격면. direct vs indirect, 사용자가 벡터(25중 24), capability grant, memory poisoning, trust escalation (소스 6개, updated 2026-11-26)
- [[subagent]] — 부모가 호출하는 독립 context window의 하위 에이전트. 리서치형↔코딩형 용어 정렬, 조정 주체 **네** 층위 구분 (소스 7개, updated 2026-09-21) ⚠️ 부분 예외 1건 + trust escalation

---

## 👤 Entities (사람·조직·제품·도구·모델)

- [[anthropic]] — Claude를 만드는 조직. **소스 14개 중 5개가 여기 발행**이므로 관점 편향 추적 지점. 엔지니어링·엔터프라이즈·플랫폼·보안 사고 보고자 네 얼굴. **외부 소스 9개 — 둘은 벤더 원문 경유, 하나는 스타트업 제품 발표, 여섯은 스스로 측정(그중 Zep은 벤더 자사 측정). Claude를 외부에서 잰 데이터는 A-MEM 부록의 Haiku 결과 하나뿐이고 신뢰도가 낮다** (소스 14개, updated 2026-11-26)
- [[claude-code]] — Anthropic의 에이전틱 코딩 도구. plan/auto mode, CLAUDE.md, skills, hooks, subagents, worktrees, dynamic workflows, `/loop`·`/goal`·`/schedule`. **harness 중 하나**로 위치 지어짐. sandbox 수치·보고된 취약점 3건 (소스 7개, updated 2026-09-21)
- [[managed-agents]] — Claude Platform의 호스팅 에이전트 서비스. session/harness/sandbox 세 인터페이스, 자격증명 격리, TTFT −60%/−90% (소스 2개, 2026-09-21) 🆕

---

## 📄 Sources (원본 소스 1:1 요약)

- [[2023-03-20-reflexion]] — *Reflexion: Language Agents with Verbal Reinforcement Learning*, Shinn 외 5인 (Northeastern·MIT·Princeton, arXiv 2023-03-20, v4 2023-10-10, NeurIPS 2023). 실패를 자연어로 반성해 memory에 쌓고 재시도한다. 검증자(self-generated test)가 성능 상한을 정하고, 반성은 강한 모델에서만 작동했다. **Berkeley 계열이 아닌 첫 학술 소스** (2026-11-26) 🆕
- [[2023-10-12-memgpt]] — *MemGPT: Towards LLMs as Operating Systems*, Packer 외 6인 (UC Berkeley, arXiv 2023-10-12, v2 2024-02-12). context를 RAM, 외부 저장소를 디스크로 보고 모델이 function call로 직접 paging한다. **이 위키의 첫 장기 memory 소스이자 가장 오래된 소스.** preprint, 2023년 GPT 모델만 실험 (2026-11-26) 🆕
- [[2024-10-14-longmemeval]] — *LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory*, Di Wu 외 5인 (UCLA·Tencent AI Lab·UCSD, arXiv 2024-10-14, ICLR 2025). 장기 memory 다섯 능력 500문항, 상용 memory는 원문 대비 37~64% 낮음, 원문 + 사실 색인이 최선. **memory 클러스터의 첫 측정 도구 소스** (2026-11-26) 🆕
- [[2025-01-20-zep]] — *Zep: A Temporal Knowledge Graph Architecture for Agent Memory*, Rasmussen 외 4인 (Zep AI, arXiv 2025-01-20). 원본 보존 + 사실의 유효 기간을 기록하는 bi-temporal graph, 모순이면 지우지 않고 무효화. DMR을 다시 재 대화 전체 baseline이 MemGPT보다 높음을 보임. **벤더 자사 제품 preprint** (2026-11-26) 🆕
- [[2025-02-17-a-mem]] — *A-MEM: Agentic Memory for LLM Agents*, Xu 외 5인 (Rutgers 등, arXiv 2025-02-17). Zettelkasten식 노트·링크·memory evolution(검색용 설명을 덮어씀). LoCoMo multi-hop 2배, 단순 사실은 GPT-4o에서 baseline보다 낮음. **외부 소스가 Claude(Haiku)를 잰 첫 데이터** (2026-11-26) 🆕
- [[2025-06-13-multi-agent-research-system]] — *How we built our multi-agent research system*, Jeremy Hadfield 외 5인 (Anthropic Engineering, 2025-06-13). Research 기능의 orchestrator-worker 아키텍처·토큰 경제성·평가·프로덕션 회고 (2026-09-11)
- [[2025-07-25-gepa-reflective-prompt-evolution]] — *GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning*, Agrawal 외 16인 (UC Berkeley·Stanford·Databricks 등, arXiv 2025-07-25, ICLR 2026 Oral). **이 위키 최초의 동료 심사 학술 소스이자 대규모 정량 소스.** 실험에 Claude 없음 (2026-11-25) 🆕
- [[2026-04-08-scaling-managed-agents]] — *Scaling Managed Agents: Decoupling the brain from the hands*, Lance Martin·Gabe Cemaj·Michael Cohen (Anthropic Engineering, 2026-04-08). harness 가정의 노후화, brain/hands/session 분리, 자격증명 격리, 창 밖 컨텍스트 (2026-09-21)
- [[2026-05-25-how-we-contain-claude]] — *How we contain Claude across products*, Max McGuinness 외 4인 (Anthropic Engineering, 2026-05-25). blast radius, 세 격리 패턴, 실패 사례 4건, 이 위키에서 가장 두꺼운 보안 수치 (2026-09-21)
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — *A harness for every task: dynamic workflows in Claude Code*, Thariq Shihipar·Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20). Claude가 harness를 직접 쓴다. 여섯 패턴·아홉 사용 사례·세 실패 모드 (2026-09-12)
- [[2026-08-21-the-ai-native-sdlc-playbook]] — *The AI-Native SDLC playbook*, Louis Claxton (Anthropic / Claude Blog, 2026-08-21). 규제 엔터프라이즈 대상 SDLC 6단계 재설계 플레이북 (2026-09-11)
- [[2026-06-07-loop-engineering]] — *Loop Engineering*, Addy Osmani (addyosmani.com, 2026-06-07). **이 위키 최초의 비-Anthropic 소스.** 다섯 primitive + 외부 state, Codex↔Claude Code 대응표, 그리고 저자 자신의 유보 세 가지 (2026-09-21) 🆕
- [[2026-08-14-practical-loop-engineering]] — *Practical Loop Engineering*, Addy Osmani (addyosmani.com, 2026-08-14). 앞 글의 실전편. 네 종류의 루프, `/goal` evaluator의 정체, 위임 경계, judgment 위임 실패담. **내용 상당 부분이 Claude Code 팀 원문 인용** (2026-09-21) 🆕
- [[2026-09-30-loop-is-the-product]] — *The Loop Is the Product*, Roland Gavrilescu (Introspection, AI Engineer World's Fair 발표, 한영자막 클리핑). 루프가 제품, system distillation이 해자, valued work per watt. taste를 eval로 코드화하고 사람은 보정만 한다. **Anthropic을 전혀 거치지 않는 첫 소스.** 단 자사 제품 발표 (2026-09-30) 🆕

---

## 🧩 Syntheses (Q&A에서 나온 보존할 만한 답변)

- [[inner-outer-loop-verification]] — 안쪽 loop는 결과를, 바깥쪽 loop는 판단 기준(eval·skill·prompt)을 검증한다. 검증 skill → system distillation → GEPA 텍스트 피드백으로 두 층위를 잇는다 (소스 4개, 2026-11-25) 🆕
- [[what-to-accumulate-outside-the-model]] — 모델이 좋아져도 썩지 않는 로컬 자산. 능력 가정은 썩고 과제 규칙은 남는다. eval > skill/prompt > state > trace > 인터페이스 > harness profile 순의 수명 표 (소스 13개, updated 2026-11-26) 🆕

---

## 🔧 Meta

- [[log]] — 시간순 활동 기록
- [[lint-2026-09-12]] — 2026-09-12 건강 검진 보고서 (기계적 0건, 의미 층위 2건 High)
- [[lint-2026-11-25]] — 2026-11-25 건강 검진 보고서 (기계적 0건, loop 클러스터 단절 High, GEPA 미통합)
- [[glossary]] — 이 위키 안에서 자주 쓰는 용어 정의
- [[index]] — (이 페이지)

---

## 사용 팁

- **Obsidian으로 보면 그래프 뷰가 가장 유용.** Settings → Files and links → Use [[Wikilinks]] = ON.
- **새 소스 추가 시:** `raw/articles/` 또는 `raw/papers/`에 두고 Claude에게 `/ingest <path>` 또는 "이거 정리해줘".
- **위키 점검:** `/lint` 또는 "위키 점검해줘".
- **현황 보기:** `/wiki-status`.
