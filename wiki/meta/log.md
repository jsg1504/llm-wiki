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

## [2026-09-11 23:58] ingest | How we built our multi-agent research system
- source: [[2025-06-13-multi-agent-research-system]] — Jeremy Hadfield, Barry Zhang, Kenneth Lien, Florian Scholz, Jeremy Fox, Daniel Ford (Anthropic Engineering, 2025-06-13)
- created: [[2025-06-13-multi-agent-research-system]] (source), [[multi-agent-systems]] (topic), [[orchestrator-worker]] (concept), [[agent-evaluation]] (concept), [[anthropic]] (entity)
- updated: [[index]]
- contradictions: [[multi-agent-systems]] — 코딩 도메인에서의 멀티에이전트 적합성. 이 소스(2025-06)는 코딩을 부적합 사례로 명시("most coding tasks involve fewer truly parallelizable tasks than research"), [[ai-native-sdlc]](2026-08)는 worktree 병렬 세션과 에이전트 리뷰 pass를 권장. 해소 가설 2개(오케스트레이터 주체가 사람이냐 에이전트냐 / 14개월 시차)를 페이지에 기록, 미검증.
- notes: 사용자 승인으로 5페이지 안. 핵심 takeaway는 "멀티에이전트가 이기는 이유는 지능이 아니라 토큰"(BrowseComp 분산의 80%를 token usage 단독 설명). 비용 15x와 코딩 부적합 판정을 함께 기록해 무비판적 채택을 막았다. [[anthropic]]은 stub으로 시작 — 조직 전반이 아니라 이 위키의 소스 편향 추적용 앵커.
- caveat: 작업 중 다른 세션이 SDLC ingest를 완결(커밋 e0abf6c, 23:54)했다. 그 결과 존재하게 된 [[claude-code]]·[[ai-native-sdlc]]에 이번 새 페이지들의 cross-reference를 사후 보정했다. 역방향 링크(SDLC 페이지 → 이번 페이지들)는 사용자 지시로 이번에 손대지 않았다 — 후속 /lint 대상.

## [2026-09-12 00:20] lint | 10페이지 점검 — 기계적 0건, 의미 층위 2건 High
- report: [[lint-2026-09-12]]
- touched: 없음 (lint는 읽기 전용. 자동 수정하지 않음)
- clean: 깨진 링크 0, 고아 0, frontmatter 오류 0 (10/10 통과)
- findings: 🔴 단방향 클러스터 다리 — SDLC 클러스터 5페이지 → 멀티에이전트 클러스터 5페이지 링크가 0개 (역방향은 6개). 고아는 아니나 [[ai-native-sdlc]]에서 출발하면 [[multi-agent-systems]]에 도달 경로 없음. 🔴 모순 1건이 [[multi-agent-systems]]에만 표시되고 [[ai-native-sdlc]]엔 대칭 마커 없음.
- discovery: **기록된 모순의 해소 근거가 이미 위키 안에 있었다.** [[claude-code]]의 병렬성 절이 "병렬 세션은 서로를 모르며 공유하는 것은 그것들을 조종하는 엔지니어뿐", subagent는 "단일 세션 안에서"라고 명시 → 2025-06 소스가 부정한 '에이전트 간 실시간 위임'과 2026-08이 권하는 '사람이 조종하는 병렬'은 서로 다른 대상. 실질적 모순 아님. 해소 확정은 사용자 승인 대기.
- stale: [[claude-code]] ↔ [[orchestrator-worker]] — 같은 패턴의 구현과 원리인데 상호 참조 0. 위키 편입 순서 때문이지 내용상 이유 아님.
- gaps: 미통합 raw 1건(2026-08-20-a-harness-for-every-task-dynamic-workflows), 소스 2개 모두 Anthropic 발행(외부 관점 0), 미해결 Open Questions 6건.
- next: 우선순위 액션 8개 제시. 추천 조합 #1(모순 해소) → #2(역링크) 또는 #3([[subagent]] 페이지 신설) → #4(stale 상호 보강).

## [2026-09-12 00:40] curate | lint 액션 #2·#3·#4·#6 수행 — 두 클러스터 연결
- report: [[lint-2026-09-12]] (액션 #1은 사용자 판단으로 보류)
- created: [[subagent]] (concept) — 두 클러스터의 공통 노드. 리서치형/코딩형 subagent 용어 정렬 + 병렬성 세 층위(subagent / 병렬 세션 / 에이전트 간 실시간 위임) 구분표
- updated: [[claude-code]], [[ai-native-sdlc]], [[artifact-chain]], [[orchestrator-worker]], [[agent-evaluation]], [[multi-agent-systems]], [[anthropic]], [[index]]
- #2 A→B 역링크: SDLC 클러스터 → 멀티에이전트 클러스터 링크가 0 → 16개. 단방향 다리 해소.
- #3 [[subagent]] 신설: 양쪽 클러스터에서 inbound 6개.
- #4 stale 보강: [[claude-code]]와 [[orchestrator-worker]]가 서로의 소스를 sources에 추가하고 본문 교차 — 같은 패턴의 원리(리서치)와 구현(.claude/agents/, verifier/researcher/simplifier)이 이어짐. [[ai-native-sdlc]]·[[artifact-chain]]도 2025-06 소스를 인용하게 되어 sources 갱신.
- #6 cross-ref 6건: 파일시스템 출력↔artifact-chain(가장 값진 쌍, 양방향), verifier subagent↔end-state evaluation, 노력 스케일↔리뷰 천장, full tracing↔OTel export, 토큰 경제성↔SDLC 지표 공백, anthropic→concept 3개.
- contradictions: **여전히 1건, 미판정 유지(사용자 판단).** [[ai-native-sdlc]]에 대칭 마커를 추가해 양쪽 페이지에서 보이게 함(이전엔 [[multi-agent-systems]]에만). lint에서 발견한 증거([[claude-code]]의 병렬 세션 정의가 해소 가설 ①과 일관)를 마커에 기록하되 결론은 내리지 않음 — 3번째 소스 대기.
- notes: 총 8페이지 수정 + 1페이지 신설. 검증: 깨진 링크 0, frontmatter 10/11 필수 필드 통과, 고아 0.
- next: lint 액션 #5(2026-08-20-a-harness-for-every-task-dynamic-workflows ingest), #7(`MCP` 페이지), #8(비-Anthropic 소스 확보) 미수행.


## [2026-09-12 01:10] ingest | A harness for every task: dynamic workflows in Claude Code
- source: [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — Thariq Shihipar, Sid Bidasaria (Anthropic / Claude Blog, 2026-08-20)
- created: [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] (source), [[dynamic-workflows]] (concept), [[agent-orchestration-patterns]] (concept)
- updated: [[multi-agent-systems]], [[ai-native-sdlc]], [[subagent]], [[claude-code]], [[agent-evaluation]], [[orchestrator-worker]], [[agentic-governance]], [[anthropic]], [[index]]
- contradictions: **[[multi-agent-systems]]의 "코딩은 멀티에이전트에 맞는가"가 부분 판정됨.** 하나의 질문이 아니라 두 개였다. ① 적합성 — 가능해졌으나 2025-06의 판단이 **반증이 아니라 우회**됐다: dynamic workflow는 조정을 LLM이 아니라 결정론적 JS 프로그램에 맡기므로 *"LLM agents are not yet great at coordinating"*을 건드리지 않는다. ② 경제성 — **모순 없음**, 세 소스 일치(새 소스도 "most traditional coding tasks do not need a panel of 5 reviewers"). [[multi-agent-systems]]에 2축 구조로 재작성하고 원문 주장은 한 줄도 삭제하지 않음. [[ai-native-sdlc]]·[[subagent]]의 마커도 동기화.
- notes: 사용자 승인으로 새 페이지 2개안(A). takeaway 7개 중 #4를 #1에 흡수, #7(quarantine)은 [[agentic-governance]] 한 절로 강등, **새 #8을 최상위로 승격** — 조정 주체가 에이전트가 아니라 결정론적 코드라는 구조적 사실. 소스가 강조하지 않았으나 위키의 열린 모순을 푸는 열쇠였다. 근거: *"the deterministic loop holds the bracket and only the running order stays in context."*
- discovery: [[subagent]]의 병렬성 **세** 층위 표가 **네** 층위로 확장됐다. "조정 상태가 어디에 사는가"(부모 컨텍스트 / 사람의 머리 / 에이전트 간 합의 / 프로그램 변수)로 보면 네 층위가 한 축에 정렬된다.
- caveat: **이 소스에는 정량 데이터가 전혀 없다.** [[2025-06-13-multi-agent-research-system]]의 BrowseComp 분산 분석·90.2% 같은 수치와 달리 성능 비교·토큰 실측·성공률이 없고, Bun 재작성도 외부 X 스레드 링크로만 언급된다. 저자들도 "best practices are still developing"이라고 명시. 경험 보고와 측정의 차이를 [[dynamic-workflows]]와 source 페이지에 배너로 박아두었다.
- open: ① *LLM이 LLM에게 실시간 위임*하는 구조의 데이터는 세 소스 어디에도 여전히 없다. ② 결정론적 조정 vs LLM 조정은 개선인가 트레이드오프인가. ③ [[agent-evaluation]]의 "단일 호출·단일 루브릭 절대 점수" vs 이 소스의 "pairwise가 더 신뢰도 높다" — 용도 구분으로 읽히나 어느 쪽도 측정되지 않았다.
- gaps: 소스 3/3이 Anthropic. 미통합 raw 1건(2025-07-25 GEPA 논문, raw/papers/). lint 액션 #7(`MCP` 페이지)·#8(비-Anthropic 소스) 미수행.

## [2026-09-21 01:30] ingest | Scaling Managed Agents: Decoupling the brain from the hands
- source: [[2026-04-08-scaling-managed-agents]] — Lance Martin, Gabe Cemaj, Michael Cohen (Anthropic Engineering, 2026-04-08)
- created: [[2026-04-08-scaling-managed-agents]] (source), [[managed-agents]] (entity), [[meta-harness]] (concept)
- updated: [[anthropic]], [[claude-code]], [[dynamic-workflows]], [[agentic-governance]], [[subagent]], [[multi-agent-systems]], [[glossary]], [[index]]
- contradictions: **경미 1건** — [[subagent]]의 *"subagent끼리 협력할 수 없다"* 단정 vs 이 소스의 *"brains can pass hands to one another"*. 뒤집히지 않음(자원 양도 ≠ 메시징). 양쪽 병기 + ⚠️ 부분 예외 노트로 기록.
- notes:
  - 중심 개념은 **meta-harness** — harness는 "모델이 아직 못 하는 것"에 대한 가정의 집합이고 모델이 좋아지면 썩는다(context anxiety → context reset → Opus 4.5에서 dead weight). 해법은 더 좋은 harness가 아니라 session/harness/sandbox 세 인터페이스를 고정하는 것.
  - takeaway 5(세션 ≠ context window)는 사용자 결정에 따라 **meta-harness 안의 한 절**로 배치. compaction 실의 **세 번째 처방**으로 표에 정리 — (a) 잘 요약한다 / (b) 도달하지 않는다 / (c) 되돌릴 수 있게 한다. 소스가 더 쌓이면 `concepts/external-context-store`로 분할 후보.
  - [[dynamic-workflows]]와는 **모순이 아니라 반대 방향의 처방**. 소스 결론부가 직접 화해시킨다(Claude Code = *"an excellent harness"*). 양쪽 페이지에 층위 다이어그램 추가.
  - [[agentic-governance]]에 판별 기준 추가: *"이 방어는 모델이 X를 못 한다는 가정에 기대는가?"* — 좁은 스코핑 vs 도달 불가.
  - [[anthropic]] status stub → draft. **소스 4/4 전부 Anthropic** 편향 노트 갱신 + 새 경계 하나(중심 주장의 전제인 "모델은 계속 좋아진다"의 이해관계자가 저자와 동일).
  - [[glossary]]에 "에이전트 용어" 절 신설 — harness, meta-harness, brain/hands/session, pets vs cattle, TTFT, context anxiety, quarantine.

## [2026-09-21 02:15] ingest | How we contain Claude across products
- source: [[2026-05-25-how-we-contain-claude]] — Max McGuinness, Mikaela Grace, Jiri De Jonghe, Jake Eaton, Abel Ribbink (Anthropic Engineering, 2026-05-25)
- created: [[2026-05-25-how-we-contain-claude]] (source), [[agent-containment]] (concept), [[prompt-injection]] (concept)
- updated: [[agentic-governance]], [[claude-code]], [[subagent]], [[meta-harness]], [[managed-agents]], [[ai-native-sdlc]], [[artifact-chain]], [[anthropic]], [[multi-agent-systems]], [[glossary]], [[index]]
- contradictions:
  - **⚠️ 정정 1건 (실질적):** [[agentic-governance]]가 quarantine 패턴을 *"prompt injection을 아키텍처 층위에서 무력화"*한다고 적었으나, 이 소스가 **multi-agent trust escalation**을 보고 — subagent 출력이 raw tool result보다 높은 신뢰를 받으면 새 벡터가 된다. **무력화 → 트레이드오프**로 정정. 원 기록은 보존하고 ⚠️ 블록으로 병기. [[subagent]]·[[prompt-injection]]에도 반영.
  - **보강 1건 (마커 없음, 사용자 결정):** auto mode의 전제조건. [[ai-native-sdlc]]·[[claude-code]]는 플레이북을 따라 model/config 층위(CLAUDE.md·skill·hook·테스트)만 적었으나, 이 소스는 *"one layer of defense-in-depth **inside a sandbox**, not a substitute for one"* + 수치(~17% 통과). 정면충돌이 아니라 우선순위 차이로 판단해 ⚠️ 마커 없이 양쪽에 보강.
  - **긴장 2건 (새 축):** (a) `CLAUDE.md`가 persistent memory poisoning 벡터 — [[claude-code]]·[[artifact-chain]]이 장점으로만 적던 "설정이 파일"의 반대편. 취약점 3건이 `.claude/settings.json` 경유. (b) 격리 ↔ 관측가능성 — [[agentic-governance]]의 OTel 증거 체계에 "격리를 강화하면 EDR이 못 본다, pull OTLP는 live monitoring이 아니다" 추가.
- notes:
  - 중심 개념 둘을 나눠 신설(사용자 결정): **[[agent-containment]]**(방어 — blast radius, 위험 3종 × 방어 3층, 세 격리 패턴, 격리↔관측가능성, "직접 만든 것이 가장 약하다")와 **[[prompt-injection]]**(공격 — direct vs indirect, 사용자가 벡터, capability grant, memory poisoning, trust escalation, agent identity). prompt-injection은 기존 3페이지가 설명 없이 쓰던 용어라 lint가 잡을 간극이었다.
  - **[[2026-04-08-scaling-managed-agents]]의 자매편.** 공통 저자(Jake Eaton). 그쪽의 *"토큰이 sandbox에 닿지 않게"* 논증을 실패 사례로 실증. [[meta-harness]]의 "방어가 모델 능력의 함수인가" 기준에 ✅ 실증 블록 추가.
  - **가장 무거운 한 문장:** *"The sandbox worked perfectly, and yet the data was exfiltrated."* 경계를 제대로 긋고도 졌다 → **allowlist = capability grant** 재개념화. 이 위키의 기존 보안 서술(세 계층, 도달 불가, quarantine)이 전부 "경계를 제대로 그으면 이긴다" 형태였던 것에 대한 반례.
  - **정량 데이터 대량 유입** (위키가 계속 아쉬워하던 것): 승인율 93%, sandbox 도입 후 프롬프트 −84%, auto mode 83% 포착/~17% 통과/benign 0.4% 차단, Gray Swan 단발 0.1%·100회 적응 후 5~6%, 피싱 red-team 25중 24.
  - [[anthropic]]에 **네 번째 얼굴(보안 사고 보고자)** 추가 + 편향 노트 재구조화 — 이 소스는 홍보 인센티브와 반대 방향이라 기존 경계가 덜 적용된다. 대신 새 경계 둘: 공개된 것은 *발견되고 수정된* 것들, 그리고 완화 이후 재측정이 없다. **이 위키에 처음으로 외부 기관 참조(NIST/ACSC·CISA·NCSC/ISO 42001)가 등장** — 외부 관점 부재를 메울 단서로 기록.
  - [[glossary]]에 "보안 용어" 절 신설 9개 (blast radius, containment, direct/indirect injection, capability grant, memory poisoning, trust escalation, approval fatigue, egress control 등).
  - [[agent-containment]]에 소스 판단 하나를 비판적으로 기록: Cowork가 에이전트 루프를 VM 밖으로 뺀 것을 *"보안 영향 최소"*라 평가하는데 근거가 없고, 글이 스스로 세운 "탈출 열쇠를 쥔 바깥 프로세스" 기준에서 한 걸음 물러난 것이다.

## [2026-09-21 03:05] ingest | Loop Engineering
- source: [[2026-06-07-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-06-07)
- created: [[2026-06-07-loop-engineering]] (source), [[loop-engineering]] (concept)
- updated: [[meta-harness]], [[dynamic-workflows]], [[agent-evaluation]], [[agent-orchestration-patterns]], [[subagent]], [[claude-code]], [[anthropic]], [[index]]
- contradictions: **없음.** 긴장 1건은 모순 아님으로 판정 — [[dynamic-workflows]]는 "조정이 LLM 컨텍스트 → 결정론적 코드"인데 루프는 골격 설계를 사람에게 올린다. 대상이 다르다(루프 골격 = 사람이 한 번, 한 턴 내부 조정 = 프로그램). ⚠️ 마커 없이 양쪽 페이지에 층위 절로 기록.
- notes:
  - **이 위키 최초의 비-Anthropic 소스.** [[anthropic]]의 편향 추적 노트를 5/5 → 6개 중 5개로 갱신하고, 새 블록에서 "메우는 것(벤더 단일 시점 해소, 반대 방향 톤) vs 못 메우는 것(독립 벤치마크 없음, 저자가 인용한 권위 하나가 Boris Cherny — 순환 참조)"을 구분해 기록. **관점의 외부성이지 증거의 외부성이 아니다.**
  - 중심 개념 [[loop-engineering]] 신설. 핵심은 다섯 primitive 목록이 아니라 **층위** — 저자 본인 표현 *"sits one floor above the harness."* [[meta-harness]]의 층위 다이어그램 맨 위에 `loop` 칸을 얹고, 그 배치가 소스의 단정이 아니라 이 위키의 연장임을 명시.
  - **위키가 비어 있던 축을 채운다:** 그동안 [[subagent]](누가 조정하는가 네 층위)와 [[agent-orchestration-patterns]](여섯 제어 구조) 모두 *한 번의 실행 내부*만 다뤘다. 루프가 더하는 것은 **cadence**(무엇이 실행을 시작시키는가)와 **연속성**(실행 사이에 무엇이 남는가 = 외부 state). orchestration-patterns의 "카탈로그에 없는 것"에 항목 추가.
  - `/goal` 항목이 기존 주장을 **벤더 밖에서 확증한다** — [[agent-evaluation]] §2b의 판정자 분리가 "끝났는가"라는 메타 판정에까지 제품 기능으로 구현됨. Codex에도 같은 이름. §2b 아래 소절로 추가.
  - [[subagent]]에 새 분화 축 기록: 지금까지 컨텍스트·도구로만 구분했으나 Codex의 subagent TOML은 **model과 reasoning effort**를 받는다("security reviewer는 강한 모델 high effort, explorer는 빠른 read-only").
  - [[claude-code]]에 `/loop`·`/goal` 절 신설 + skill↔plugin 구분(저작 포맷 vs 배포 수단) 보강. **Claude Code가 이 기능군의 유일한 구현이 아니라는 첫 기록.**
  - 반대급부 3종(verification은 사람 몫 / comprehension debt / cognitive surrender)은 [[loop-engineering]] 안의 절로 유지. 저자의 인접 글들이 더 들어오면 분할 후보. [[ai-native-sdlc]]에 comprehension debt 대응 경계가 없다는 점을 그 절에 기록만 해둠(그 페이지는 미수정).
  - 사용자 결정: `addy-osmani`·`openai-codex` entity는 **만들지 않음** — 이 소스 하나로는 stub이라 고아 페이지 위험. [[loop-engineering]] 안에서 언급만.
  - 정량 데이터 0. 증거 두께는 [[2026-08-20-a-harness-for-every-task-dynamic-workflows]]와 같은 급(경험 보고).

## [2026-09-21 04:20] ingest | Practical Loop Engineering
- source: [[2026-08-14-practical-loop-engineering]] — Addy Osmani (addyosmani.com, 2026-08-14)
- created: [[2026-08-14-practical-loop-engineering]] (source)
- updated: [[loop-engineering]], [[agent-evaluation]], [[claude-code]], [[agent-orchestration-patterns]], [[subagent]], [[anthropic]], [[index]]
- contradictions:
  - **⚠️ 정정 1건 (실질적, 자기 정정):** 3시간 전 [[2026-06-07-loop-engineering]] ingest에서 `/goal`을 [[agent-evaluation]] §2b 판정자 분리의 *"정지 조건이라는 메타 판정으로의 확장"* 이라 기록했으나 **그 기술이 넓었다.** 같은 저자가 두 달 뒤 직접 좁힌다 — evaluator는 *"대화 transcript를 보고 내가 명시한 하드 룰 충족 여부만"* 판정하며 산출물의 좋고 나쁨을 보지 않는다. 차이 두 겹: (a) 대상이 품질이 아니라 룰 충족, (b) 보는 것이 코드가 아니라 transcript. **self-preferential bias는 품질 판정에서만 나는 문제이므로 evaluator는 그것을 겪지도 풀지도 않는다.** 원 기록은 보존하고 ⚠️ 블록으로 병기. [[loop-engineering]]·[[agent-evaluation]]·[[claude-code]]·[[subagent]]·[[agent-orchestration-patterns]] 다섯 곳에 반영. 실무적 함의로 "루프에 evaluator를 걸었으니 검증은 됐다"는 잘못된 안심을 명시.
  - **긴장 1건 (마커 없음):** 병렬 세션 수. [[claude-code]]는 플레이북을 따라 *"2~3개가 합리적 출발점"*, 이 소스는 매일 5~10개(동시 5개). 엔터프라이즈 도입 초기 ↔ 숙련자 개인 상한이고 **양쪽 다 천장은 리뷰 능력**이라는 데 동의하므로 ⚠️ 없이 양쪽 병기.
- notes:
  - 새 페이지 없음 (사용자 승인). 이 소스는 [[loop-engineering]]의 **실무 층**이라 그 페이지를 174 → 260줄로 보강. CLAUDE.md 적정 범위(100~400) 안.
  - **네 종류의 루프** 표 신설 — turn-based(agentic loop) / goal-based / time-based / proactive. 축 넷: 트리거·정지·primitive·맞는 태스크. 위로 갈수록 사람이 멀어진다.
  - **`/loop` ≠ `/schedule`.** `/loop`는 로컬·세션 스코프·**7일 만료**(저자가 "3일이라 말해왔는데 7일"이라고 자기 정정), `--resume`로 복귀. 세션보다 오래 살려면 `/schedule` 클라우드 routine. 어제 [[claude-code]]에 "스케줄 태스크와 cron"으로 뭉뚱그렸던 것 정밀화.
  - **위키에 없던 축 추가 — 위임 경계.** 기존 페이지들은 *병렬화 가능한가*(기술)와 *지불할 가치가 있는가*(경제성)만 다뤘고 **무엇을 사람이 봐야 하는가**(태스크 민감도)는 비어 있었다. 완전 위임(문서·테스트 커버리지) vs 밀착 감시(인증·보안·금융, 시스템 접근, 스펙 좋아도 신뢰 안 서는 것) + evergreen↔brownfield 구분.
  - **cognitive surrender 절에 실물 사례.** 경쟁사 gap 분석 → 로컬 PR → 거의 푸시. 리서치는 읽고 구현은 안 봄. **실패의 형태가 정확하다 — 검증 실패가 아니라 취향 판단의 위임이다.** 코드는 동작했을 것이고 문제는 "만들 가치가 있는 변경인가"였으며 그건 어떤 정지 조건으로도 표현되지 않는다. 규율: task는 위임하고 judgment는 되가져온다.
  - [[agent-orchestration-patterns]] #6에 실무 판정 기준 — 나쁜 목표의 형태(*"keep going until this UI design is good"*), 3회 무변화면 정지.
  - [[claude-code]] Skills 절에 `verify-frontend-change` 실물(dev server → 직접 조작 → before/after 스크린샷 → 콘솔 0 에러 → DevTools MCP로 Core Web Vitals → 실패 시 1단계부터).
  - **[[anthropic]]에 새 경계 (사용자 결정):** 이 소스 내용의 상당 부분이 **Claude Code 팀 X article 인용**이다. 발행처로는 외부 2개지만 내용 출처로는 아니므로 "비-Anthropic 소스 2개 확보"는 착시. 저자 고유 기여는 운용 경험 쪽(위임 경계·실패담·triage·3회 신호). 다만 이 경로가 값을 하나 냈다 — 저자가 벤더 문서를 정확히 읽은 덕에 위키의 오독이 잡혔다.
  - 팀의 composed example(`/schedule` + `/goal` + skills + dynamic workflows + auto mode)이 **루프가 위, 워크플로가 아래**라는 층위 배치를 벤더 쪽에서 확인해준다. 어제 세운 층위 다이어그램의 근거 보강.
  - 정량 데이터 여전히 0. 80k stars·하루 80~90 PR·5~10 에이전트·7일은 사실 진술이지 효과 측정이 아니다.
