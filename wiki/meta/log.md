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

## [2026-09-30 23:30] ingest | The Loop Is the Product
- source: [[2026-09-30-loop-is-the-product]] — Roland Gavrilescu (Introspection, AI Engineer World's Fair 발표; Tech Bridge 한영자막 클리핑)
- created: [[2026-09-30-loop-is-the-product]] (source), [[agent-recipe]] (concept, stub)
- updated: [[loop-engineering]], [[agent-evaluation]], [[meta-harness]], [[anthropic]], [[glossary]], [[index]]
- contradictions:
  - **⚠️ 모순 1건 (실질적): taste는 루프에 맞는가.** Osmani([[2026-06-07-loop-engineering]], [[2026-08-14-practical-loop-engineering]])는 *"사람의 taste는 루프에 맞지 않는다"*, *"task는 위임하고 judgment는 되가져온다"* 고 했다. Gavrilescu는 *"상위 judge로서의 자신을 자동화하라"* 고 하며 taste를 eval로 코드화하는 것을 루프의 핵심으로 둔다. **부분 화해:** 양쪽 다 사람을 남긴다(매번의 판단 vs judge 보정과 promote). 맥락도 다르다(개인 코드베이스의 일회성 판단 vs 제품의 반복 판단 + A/B 신호). **남는 불일치:** "이 변경이 가치 있는가"를 judge로 표현할 수 있는가. 양쪽 주장 보존, [[loop-engineering]]에 ⚠️ 블록, [[agent-evaluation]] §3b에 교차 참조.
- notes:
  - raw 파일명이 규칙에 어긋나(`한영자막 루프 자체가 제품입니다 — …md`) **사용자가 직접** `2026-09-30-loop-is-the-product.md`로 rename했다. 날짜는 클리핑일이고 발표일은 불명이다.
  - 새 concept 이름은 `agent-recipe`(Claude 추천, 사용자 동의). ingest 도중 사용자 요청으로 **`system-distillation`도 살렸다.** 별도 페이지 대신 한 페이지에 `aliases: [system-distillation]`을 넣고 제목·TL;DR·glossary에 병기했다. 근거: 과정(distillation)과 결과물(recipe)은 같은 것의 두 면이고, 나누면 stub 두 개가 된다. 주 이름을 `system-distillation`으로 바꾸고 싶다면 백링크가 적은 지금이 가장 싸다.
  - [[loop-engineering]]에 **두 번째 루프** 절 신설. OODA, signal 품질이 성공률을 정하고 verifier 품질이 그 성공을 보정한다는 두 끝의 논리, 산출물 → signal 되먹임. 기존 "검증을 skill로 코드화한다"를 **system distillation 한 단계를 손으로 한 것**으로 재위치했다.
  - [[agent-evaluation]] §3b 신설. 사람은 eval을 **만들지 않고 보정한다.** eval의 내용물이 공통 기준이 아니라 **제작자의 taste**다. **세 번째 검증 층(프로덕션 A/B)**이 들어왔다. §3의 "SEO 콘텐츠팜" 편향과 이 소스의 "빅테크만" 편향이 같은 모양이다. 차이는 발견 경로(사람 테스터 vs trace 클러스터링)다.
  - [[anthropic]]: **Anthropic을 발행처로도 인용 경로로도 거치지 않는 첫 소스.** 순환 참조는 풀렸지만 편향의 종류가 스타트업 제품 편향으로 바뀌었을 뿐이다.
  - 자동 생성 자막이다("Cloud Code" = Claude Code, "Pie Harness" = pi harness). 정량 데이터 0. valued work per watt는 정의되지 않은 구호다.

## [2026-11-25 22:47] manual | Query operation 도구화 — `/query` + `wiki-query` skill
- touched: CLAUDE.md (§2.2 Trigger/Flow, §8 표), `.claude/skills/wiki-query/SKILL.md` (신규), `.claude/commands/query.md` (신규)
- notes: Karpathy 패턴 3 operation 중 Query만 전용 skill/명령이 없었고, syntheses 0개·log의 query 항목 0건이었다. 새 skill은 인덱스 우선, 주장마다 출처, 위키 근거/*(추론)*/*(위키 외)* 구분, 모순 노출, 답변마다 synthesis 보존 판단(§3.1 기준)을 강제한다. log 기록은 기존 규칙대로 synthesis 저장 시에만.

## [2026-11-25 22:56] lint | 25페이지 점검 — 기계적 0건, loop 클러스터 단절 High, GEPA 두 주기째 미통합
- touched: [[lint-2026-11-25]]
- notes: 깨진 링크·고아 0. 9/21·9/30 loop 소스 3개가 두 topic([[ai-native-sdlc]], [[multi-agent-systems]])과 연결되지 않은 세 번째 섬이 됐다. 지난 lint와 같은 패턴의 재발이다. 미해결 모순 1건(taste)은 위키 안에 판정 근거가 없다. 지난 lint 액션 #7(MCP)·#8(비-Anthropic 소스)과 GEPA 논문 통합이 미수행이다. 자동 수정 없음.

## [2026-11-25 22:59] curate | lint 2026-11-25 액션 #1 — loop 클러스터를 topic에 연결
- touched: [[ai-native-sdlc]], [[multi-agent-systems]], [[artifact-chain]], [[index]]
- notes: lint에서는 섬으로 봤지만 실제로는 단방향 다리였다. [[loop-engineering]]은 이미 세 페이지를 링크하고 있었고 역방향만 없었다. 2026-09-12 lint와 같은 패턴이다. 그래서 loop-engineering과 agent-recipe는 수정하지 않았다.
  - [[ai-native-sdlc]]: Stage 6을 loop engineering의 조직 규모 판본(automations와 state 대응)으로, 6·7번을 두 번째 루프/[[agent-recipe]]로 연결했다. 둘 다 *(추론)* 표시. Stage 3에 병렬 세션 수(2~3 vs 최대 5) ℹ️ 노트. Open Questions에 comprehension debt 추가. sources +3.
  - [[multi-agent-systems]]: Overview에 다섯 번째 축(시간) 추가, "세 축" 오기를 "다섯 축"으로 고침. Contradiction 가설 ①에 Osmani 운용 사례와 태스크 민감도 축을 추가했다. **판정 상태는 바꾸지 않았다.** "다섯 소스 모두 Anthropic" 편향 문장은 원문을 보존하고 갱신 노트를 달았다(관점의 외부성 ≠ 증거의 외부성). sources +2.
  - [[artifact-chain]]: 💡 블록에 세 번째·네 번째 층위(loop state, agent recipe) 추가. sources +2.
  - raw에서 새로 가져온 사실 없음. 전부 기존 source 페이지와 [[loop-engineering]]에 있던 내용의 역방향 반영이다.

## [2026-11-25 23:07] manual | source-ingest skill에 역링크 점검(§4.4) 추가
- touched: `.claude/skills/source-ingest/SKILL.md` (§4.4 신설, §7 보고 항목, 안티 패턴 1줄)
- notes: lint 2026-09-12와 2026-11-25에서 두 번 연속 같은 문제가 나왔다. 새 클러스터가 기존 페이지로 링크만 걸고 역방향이 없어 단방향 다리가 됐다. 이제 ingest 때마다 만들거나 바꾼 페이지의 링크 대상을 점검한다. topic이 대상이거나 기존 주장을 보강·반박하는 경우에는 본문에 역링크를 넣고, entity 단순 언급과 source 페이지는 생략한다. 역링크 대상은 takeaway 합의 때 미리 승인받는다. 점검 스니펫을 [[agent-recipe]]와 [[loop-engineering]]에 돌려 보니 걸린 것은 entity 1개와 source 3개뿐이었다. 둘 다 규칙상 생략 대상이라 직전 curate 결과와 맞는다.

## [2026-11-25 23:18] ingest | GEPA: Reflective Prompt Evolution Can Outperform Reinforcement Learning
- source: [[2025-07-25-gepa-reflective-prompt-evolution]] — Agrawal 외 16인 (UC Berkeley·Stanford·Databricks·MIT 등, arXiv 2507.19457, ICLR 2026 Oral)
- created: [[2025-07-25-gepa-reflective-prompt-evolution]] (source), [[prompt-optimization]] (concept, draft)
- updated: [[agent-recipe]] (stub → draft), [[loop-engineering]], [[agent-evaluation]] (§7 신설), [[meta-harness]], [[anthropic]], [[index]]
- contradictions:
  - **⚠️ 긴장 1건 (모순까지는 아님): "AI 시스템에는 recipe 같은 그릇이 없다".** [[agent-recipe]]가 Gavrilescu를 따라 적은 진술에 GEPA와 DSPy 계열이 반례가 된다. 양쪽 주장을 보존했다. "부품을 자동으로 증류하는 방법은 있다. 그것들을 묶는 그릇은 없다"로 부분 화해하고 이 위키의 해석으로 표시했다. 사용자 승인.
  - 기존 모순 **taste는 루프에 맞는가**([[loop-engineering]])는 판정 상태를 바꾸지 않았다. GEPA의 과제는 전부 정답이 있어 taste 영역의 데이터가 아니다.
- backlinks (§4.4, 처음 적용): 새 페이지가 링크한 대상 6개 중 5개([[agent-recipe]], [[loop-engineering]], [[agent-evaluation]], [[meta-harness]], [[anthropic]])에는 본문과 Related에 역링크를 넣었다. [[prompt-injection]] 1개는 사전 승인 목록에 없어 보류하고 사용자에게 물었다. topic 직접 링크는 없다. [[agent-recipe]] → [[ai-native-sdlc]] 경로로 이어진다.
- notes:
  - lint 2026-11-25 액션 #2 수행. 9/12 lint부터 두 주기 동안 미통합이었다.
  - **이 위키 최초의 동료 심사, 학술, 대규모 정량 소스다.** Anthropic을 전혀 거치지 않고 실험 모델에 Claude가 없다. 편향의 종류는 **자기 도구 편향**이다. MIPROv2 저자와 DSPy 창시자가 공저자다.
  - 핵심 주장("텍스트 피드백이 스칼라보다 풍부하다")을 직접 검증하는 비교가 본문에 없다. GRPO 비교는 다른 파라미터 공간끼리다. test set이 과제당 300개 수준이다. AIME에서는 GRPO가 이겼다. 모두 source 페이지 My Notes에 기록했다.
  - [[agent-recipe]]의 provider-agnostic 주장에 첫 정량 근거가 생겼다(Qwen3 8B → GPT-4.1 Mini +9%). 한 방향, 두 모델, prompt 하나뿐이라는 한계를 같이 적었다.
  - [[meta-harness]]에 추론 하나를 더했다. 썩는 것은 **능력 가정**이고, 남는 것은 **과제 규칙**이다.

## [2026-11-25 23:20] curate | GEPA ingest 보류 역링크 — prompt-injection
- touched: [[prompt-injection]], [[index]]
- notes: 직전 ingest에서 §4.4로 보류했던 역링크를 사용자 승인으로 반영했다. Related 한 줄로 끝내지 않고 "열린 질문" 절을 새로 만들었다. Gray Swan 적응적 공격(100회 후 5~6%)과 GEPA adversarial 탐색(AIME 76% → 10%)을 연결했다. 위협 모델이 다르다는 점(신뢰 경계를 넘는가)을 명시했고, injection 탐색에 쓸 수 있는지는 *(추론)*으로 표시한 질문으로만 남겼다. sources +1.

## [2026-11-25 23:40] manual | Karpathy gist 대조 점검 후속 — librarian 도구 정비 + 문서·skill 소규모 보강
- touched: `.claude/agents/librarian.md`, CLAUDE.md (§8 에이전트 위임 문장), `.claude/skills/wiki-lint/SKILL.md` (§1.8, 출력 §8), `.claude/hooks/validate-frontmatter.sh` (주석), README.md
- notes: librarian `tools:`의 존재하지 않는 `SkillsetCall`을 `Skill`로 교체하고, owner인 index.md·log.md를 직접 갱신하도록 `Edit`/`Write`를 추가했다. subagent는 subagent를 띄울 수 없으므로 editor/linker 작업은 "위임 plan"으로 반환하고 메인 세션이 실행하도록 바꿨다. wiki-lint 데이터 갭에 웹 검색 기반 ingest 후보와 `/query` 후보 질문 제안을 추가했다(검색 결과는 raw/ 경유 ingest로만 위키에 들어감). README에 `/query`·`wiki-query`를 반영했고, hook 주석을 실제 동작(lint-*.md도 검사)에 맞췄다. overview 페이지는 현 규모(25페이지)에서 index.md로 충분하다고 보고 만들지 않았다.

## [2026-11-25 23:50] manual | hook 경고가 Claude에게 전달되도록 exit 코드 수정
- touched: `.claude/hooks/validate-frontmatter.sh`, `.claude/hooks/log-tracker.sh`
- notes: 두 hook은 경고를 stderr에 쓰고 exit 0으로 끝나서 Claude가 경고를 보지 못했다. 경고 시 exit 2로 바꿨다. validate-frontmatter(PostToolUse)는 쓰기를 되돌리지 않고 stderr만 Claude에 전달한다. log-tracker(Stop)는 Claude가 멈추지 않고 log.md를 보강하게 하며, `stop_hook_active=true`면 통과해 무한 루프를 막는다. log-tracker는 이제 untracked 새 wiki 페이지도 변경으로 잡는다. 시뮬레이션 입력으로 frontmatter 누락/불완전/정상, Stop clean/dirty/active 6케이스를 확인했다.

## [2026-11-25 23:58] manual | Obsidian vault 설정을 위키 규칙에 맞춰 커밋
- touched: `.obsidian/app.json` (신규), `.obsidian/core-plugins.json` (신규), `.gitignore`
- notes: Karpathy gist 점검 4번 후속. 첨부 폴더를 `raw/assets`로, 링크 형식을 wikilink(`useMarkdownLinks: false`, `newLinkFormat: shortest`)로 지정했다. Obsidian에서 rename하면 백링크가 자동 갱신되도록 `alwaysUpdateLinks: true`(CLAUDE.md §3.2)도 켰다. `appearance.json`은 개인 취향이라 ignore했고, `graph.json`의 zoom(`scale`) 변경은 되돌렸다. Web Clipper 저장 경로는 브라우저 확장 설정이라 repo 밖에 있다.

## [2026-11-25 23:34] query | loop engineering의 바깥쪽 loop, 안쪽 loop는 무엇이고 검증과 관련 있는가
- created: [[inner-outer-loop-verification]] (synthesis)
- updated: [[loop-engineering]] (Related에 역링크 1줄), [[index]]
- cited: [[loop-engineering]], [[agent-recipe]], [[prompt-optimization]], [[agentic-governance]], [[agent-evaluation]], [[2026-09-30-loop-is-the-product]], [[2026-08-14-practical-loop-engineering]], [[2025-07-25-gepa-reflective-prompt-evolution]], [[2026-08-21-the-ai-native-sdlc-playbook]]
- notes: 위키의 첫 번째/두 번째 루프를 Gavrilescu 원문의 "inner loop"와 대응시켰다. 안쪽 loop는 결과를, 바깥쪽 loop는 판단 기준을 검증한다는 비교 표를 만들었다. outer loop라는 용어는 어느 소스에도 없어 *(추론)*으로 표시했다. 시스템 시각(23:34)이 직전 항목들(23:40~23:58)보다 이르다. 시각을 지어내지 않고 실제 시각을 그대로 적었다.

## [2026-11-25 23:36] curate | inner/outer loop synthesis 후속 — loop-engineering 보강, glossary 항목 추가
- touched: [[loop-engineering]], [[glossary]]
- notes: 직전 query 답변의 개선 후보 두 건을 사용자 승인으로 반영했다. loop-engineering "두 번째 루프" 절에 Gavrilescu 원문의 inner loop 인용(11:42)과 두 루프의 검증 대상 차이를 추가했고, aliases에 inner loop / outer loop를 넣었다. glossary에 inner/outer loop의 두 뜻(루프 엔지니어링 / 소프트웨어 개발)을 구분해 적었다.

## [2026-11-25 23:53] curate | loop-engineering 중복 헤더 제거
- touched: [[loop-engineering]]
- notes: "loop engineering이란?" query 중 발견한 중복 헤더(`### skill은 저작 포맷, plugin은 배포 수단`) 1개를 사용자 승인으로 삭제했다. 내용 변경 없음. updated 날짜는 이미 2026-11-25라 그대로 두었다.

## [2026-11-26 00:07] query | 모델이 아닌 로컬에 쌓아 agent를 계속 개선할 것은 무엇인가
- created: [[what-to-accumulate-outside-the-model]] (synthesis)
- updated: [[agent-recipe]] (Related에 역링크 1줄), [[index]]
- cited: [[meta-harness]], [[agent-recipe]], [[loop-engineering]], [[prompt-optimization]], [[agent-evaluation]], [[artifact-chain]], [[inner-outer-loop-verification]], [[prompt-injection]]
- notes: meta-harness의 "능력 가정은 썩고 과제 규칙은 남는다" 기준을 recipe·artifact-chain·eval에 적용해 로컬 자산의 수명 순서 표를 만들었다. 능력 가정에 유효기간을 달고 eval로 재검증하자는 제안은 *(추론)*으로 표시했다. taste 모순은 판정 변경 없이 옮겼다.

## [2026-11-26 00:09] curate | 로컬 자산 synthesis 후속 — glossary 항목 추가, agent-recipe에 수명 기준 연결
- touched: [[glossary]], [[agent-recipe]]
- notes: 직전 query 답변의 개선 후보 두 건을 사용자 승인으로 반영했다. glossary 에이전트 용어 절에 "능력 가정 / 과제 규칙" 항목을 넣었다. 위키가 붙인 구분임을 명시했다. agent-recipe "오래 사는 것" 대비표 아래에 recipe 부품별 수명 차이 노트를 *(추론)*으로 추가하고 synthesis로 연결했다.

## [2026-11-26 00:22] ingest | MemGPT: Towards LLMs as Operating Systems
- source: [[wiki/sources/2023-10-12-memgpt|MemGPT (Packer 외, arXiv 2310.08560)]]
- created: [[2023-10-12-memgpt]], [[agent-memory]]
- updated: [[meta-harness]], [[loop-engineering]], [[prompt-injection]], [[what-to-accumulate-outside-the-model]], [[glossary]], [[index]]
- contradictions: 없음. context 한계 경고(MemGPT에서는 기능) vs context anxiety(Sonnet 4.5에서는 조기 종료)는 사용자 합의에 따라 ⚠️ 모순이 아니라 "능력 가정이 썩는 두 번째 사례"로 meta-harness·agent-memory에 기록했다.
- notes: raw 원문은 사용자 승인을 받아 arXiv에서 v2 PDF를 내려받았다(`raw/papers/2023-10-12-memgpt.pdf`, 파일명 날짜는 v1 공개일 기준). 위키의 첫 장기 memory 소스다. memory를 모델이 관리하느냐 harness가 관리하느냐의 대비, MemGPT 위에서 GPT-4 Turbo가 GPT-4보다 못했다는 결과(능력 가정은 새 모델에서 해가 될 수도 있다)를 추가했다. 역링크 점검: source 페이지와 entity(anthropic)는 의도적으로 생략했다. agent-recipe·artifact-chain·orchestrator-worker로 가는 역링크는 사용자 확인 대기.

## [2026-11-26 00:25] curate | MemGPT ingest 후속 — agent-memory 역링크, Anthropic 편향 집계 갱신
- touched: [[agent-recipe]], [[artifact-chain]], [[anthropic]], [[index]]
- notes: 직전 ingest 보고의 후속 1·2번을 사용자 승인으로 반영했다. (1) agent-recipe "오래 사는 것" 대비표에 agent-memory 행과 "사실 vs 판단" 노트를 추가했다. artifact-chain 공격 표면 노트에 "리뷰를 거치는 쓰기 vs 모델이 스스로 쓰는 memory"의 대비를 *(추론)*으로 넣었다. orchestrator-worker 역링크는 단순 언급이라 생략했다. (2) anthropic의 소스 집계를 10개 중 5개로 고쳤다. TL;DR은 이미 "7개 중 5개"로 낡아 있었는데 함께 고쳤다. MemGPT 편향 노트를 추가했다. Ion Stoica가 GEPA·MemGPT 공저자라 두 학술 소스를 독립적 확인으로 세면 안 된다는 점을 적었다.

## [2026-11-26 00:53] ingest | Reflexion: Language Agents with Verbal Reinforcement Learning
- source: [[wiki/sources/2023-03-20-reflexion|Reflexion (Shinn 외, arXiv 2303.11366)]]
- created: [[2023-03-20-reflexion]]
- updated: [[prompt-optimization]], [[agent-memory]], [[agent-evaluation]], [[loop-engineering]], [[what-to-accumulate-outside-the-model]], [[anthropic]], [[glossary]], [[index]]
- contradictions: 없음. 저자들의 전망("모델이 좋아질수록 더 좋아진다")과 MemGPT의 관측(새 모델이 더 나빴다)은 사용자 합의에 따라 모순이 아니라 "전망 vs 관측"으로 synthesis에 나란히 기록했다.
- notes: raw는 arXiv v4 PDF를 내려받았다(파일명 날짜는 v1 기준). 새 concept 페이지 없이 흡수했다. 반성 엔진의 결과를 어디에 두는가(Reflexion은 episodic memory, GEPA는 지시문)로 agent-memory와 prompt-optimization을 이었다. self-generated test의 false positive 16.3%와 테스트 없는 반성의 역효과(0.52 < 0.60)를 agent-evaluation §2b에 정량 사례로 넣었다. 재시도 루프와 두 번째 루프를 구분했다. agent-memory 초안에 원문에 없는 반성문 예시를 썼다가 원문 Figure 1 예시로 바로잡았다. 역링크 점검: agent-containment는 source 페이지의 단순 언급(격리 실행 권고)이라 생략했다.

## [2026-11-26 00:59] ingest | LongMemEval: Benchmarking Chat Assistants on Long-Term Interactive Memory
- source: [[wiki/sources/2024-10-14-longmemeval|LongMemEval (Wu 외, ICLR 2025)]]
- created: [[2024-10-14-longmemeval]]
- updated: [[agent-memory]], [[meta-harness]], [[agent-evaluation]], [[prompt-injection]], [[what-to-accumulate-outside-the-model]], [[anthropic]], [[glossary]], [[index]]
- contradictions: 없음. MemGPT의 재귀 요약과 "압축하면 나빠진다"는 결과는 MemGPT가 원본도 보존하므로 일치로 기록했다.
- notes: raw는 arXiv v2 PDF를 내려받았다(파일명 날짜는 arXiv 페이지에서 확인한 v1 제출일). 새 concept 없이 agent-memory에 흡수했고 페이지가 약 120줄에서 189줄로 커졌다(사용자 승인). 세 단계·네 조정점 틀로 MemGPT·Reflexion을 다시 놓았고, 다섯 능력, 설계 실험 표, 모델 순서가 뒤집힌 세 번째 사례(GPT-4o-mini > GPT-4o, Llama 70B < 8B)를 넣었다. memory poisoning은 *(추론)*에서 소스 근거로 올렸다. agent-evaluation §6에 "교체 대신 늘린다"와 판정자 대조(97~98%)를 넣으면서 MemGPT도 대조 사례로 인용해 sources에 추가했다.

## [2026-11-26 01:08] ingest | Zep: A Temporal Knowledge Graph Architecture for Agent Memory + A-MEM: Agentic Memory for LLM Agents
- source: [[wiki/sources/2025-01-20-zep|Zep (Rasmussen 외, arXiv 2501.13956)]], [[wiki/sources/2025-02-17-a-mem|A-MEM (Xu 외, arXiv 2502.12110)]]
- created: [[2025-01-20-zep]], [[2025-02-17-a-mem]]
- updated: [[agent-memory]], [[2023-10-12-memgpt]], [[agent-evaluation]], [[what-to-accumulate-outside-the-model]], [[anthropic]], [[glossary]], [[index]]
- contradictions: 없음. 갱신 방식의 대립(Zep 무효화 vs A-MEM 덮어쓰기)은 같은 벤치마크 비교가 없어 사용자 합의에 따라 "비교 데이터 없는 설계 선택의 대립"으로 기록했다.
- notes: 사용자 요청으로 두 소스를 한 번에 처리했다. raw는 arXiv PDF를 내려받았다(파일명 날짜는 arXiv 페이지에서 확인한 v1 제출일). agent-memory는 사용자 승인으로 절 순서를 다시 짰다(무엇을 남기나 → 담나 → 갱신 → 찾고 읽기 → 누가 관리 → 능력 가정 → cadence → 위험). 내용은 지우지 않았고 236줄이 됐다. 섹션 번호를 참조하는 외부 링크가 없음을 먼저 확인했다. 새 §3 "어떻게 갱신하나"에 원문·key·이전 상태 비교 표를 넣었다. Zep의 DMR 재측정(대화 전체 baseline 94.4% > MemGPT 93.4%)으로 MemGPT source 페이지의 *(추론)*이 실측으로 확인됐다고 적었다. "무효화하되 지우지 않는다" 원칙은 artifact-chain이 아니라 synthesis §5에 일반화해 넣었다(사용자와 합의). A-MEM 부록의 Claude Haiku 데이터를 anthropic에 "외부 소스가 Claude를 잰 첫 데이터, 신뢰도 낮음"으로 기록했다.

## [2026-11-26 01:19] ingest | Recursive Language Models
- source: [[wiki/sources/2025-12-31-recursive-language-models|Recursive Language Models (Zhang·Kraska·Khattab, arXiv 2512.24601)]]
- created: [[2025-12-31-recursive-language-models]], [[recursive-language-model]]
- updated: [[meta-harness]], [[dynamic-workflows]], [[subagent]], [[agent-memory]], [[multi-agent-systems]], [[claude-code]], [[anthropic]], [[index]]
- contradictions: 없음. RLM의 subagent 비판(말로 하는 위임은 출력 길이에 묶인다)은 사용자 합의에 따라 ⚠️ 대신 "표현력 상한 지적" 보강 노트로 기록했다([[subagent]] 새 절).
- notes: Claude가 arXiv API로 찾아 v3 PDF(2026-05-11, 43쪽)를 받았다. raw 복사는 권한 거부돼 사용자가 직접 `raw/papers/2025-12-31-recursive-language-models.pdf`로 옮겼다(파일명 날짜는 v1 제출일). Managed Agents 원문의 "Prior work has explored" 링크가 이 논문임을 확인해 meta-harness의 compaction 처방 표에 (d) "애초에 넣지 않는다"를 별도 행으로 넣고 (c)와 같은 줄기임을 명시했다. scaffold를 가중치로 옮기는 학습 결과를 meta-harness의 반대 방향 사례로 기록했다. Claude Code(Opus 4.1) 측정은 "외부 측정, 모델 상이·경쟁자 측정" 단서와 함께 claude-code와 anthropic에 넣었다. concept 이름은 `context-offloading` 대신 `recursive-language-model`로 했다(소스 하나뿐이라 넓은 hub는 보류). §4.4 역링크: agent-containment, prompt-injection은 RLM 페이지의 *(추론)* 언급뿐이라 승인 범위 밖으로 두고 생략했다. source 페이지 역링크는 규칙대로 생략했다.

## [2026-11-26 01:24] ingest | Think, But Don't Overthink: Reproducing Recursive Language Models
- source: [[wiki/sources/2026-03-03-reproducing-recursive-language-models|Reproducing RLMs (Daren Wang, arXiv 2603.02615)]]
- created: [[2026-03-03-reproducing-recursive-language-models]], [[contradictions]]
- updated: [[recursive-language-model]], [[2025-12-31-recursive-language-models]], [[meta-harness]], [[anthropic]], [[index]]
- contradictions: [[recursive-language-model]] — "단순한 과제와 강한 모델에서도 RLM은 손해가 작은가" (원 논문 Figure 1·Observation 3 vs 재현의 S-NIAH 100 → 70~90, Kimi K2 OOLONG 86.6 → 60.0). 조건(모델·표본·길이)이 달라 판정 보류. "긴 입력에서 RLM이 이긴다"는 재현이 64k 이하만 재서 범위 밖으로 명시했다. depth 결과는 원 논문 Qwen3-Coder와 일치로 기록했다.
- notes: 사용자 합의에 따라 이득의 재현은 "확인 안 됨"으로 기록했다. 근거 수치(DeepSeek OOLONG 0.0 → 42.1)의 base 0%가 부록 A.3에서 형식 실패로 밝혀졌기 때문이다. 실패의 재현(최종 답 태그 혼동, thinking 태그 파서 문제, 깊은 재귀 오류 전파, 꼬리 비용)은 "확인됨"으로 기록했다. Zep → MemGPT 선례를 따라 원 source 페이지에 "후속 검증" 절을 넣었다. dynamic-workflows의 정지 장치 연결은 저자 해석일 뿐이라 빼고 concept의 비용 절에 한 줄로 넣었다. 기존 ⚠️ 모순 셋을 모은 `wiki/meta/contradictions.md`를 새로 만들었다(기존 둘 + 이번 하나). session-start 훅은 `^> ⚠️ Contradiction`을 세는데 위키의 실제 마커는 `> ⚠️ **Contradiction`이라 미해결 모순이 0으로 나온다. 훅은 고치지 않았다. raw는 사용자가 직접 복사했다.

## [2026-11-26 01:27] manual | 모순 카운트 수정 (session-start 훅, wiki-status)
- touched: `.claude/hooks/session-start.sh`, `.claude/commands/wiki-status.md`, [[log]]
- notes: 두 곳 모두 `⚠️ Contradiction`을 찾았지만 위키의 실제 마커는 `> ⚠️ **Contradiction`(굵게)이라 늘 0건으로 나왔다. 이제 [[contradictions]] 표의 상태 열(`**미해결`, `**부분 판정`)을 1차 기준으로 세고, 페이지 마커는 `\*{0,2}` 패턴으로 교차 확인용으로만 센다. 현재 출력: 미해결 2, 부분 판정 1, 마커 페이지 6개(synthesis 사본 포함). 사용자 승인.

## [2026-11-26 01:30] manual | frontmatter 검증 훅의 경로 패턴 수정
- touched: `.claude/hooks/validate-frontmatter.sh`, [[log]]
- notes: 패턴 `*wiki/*.md`가 프로젝트 폴더명 `llm-wiki/`에도 걸려 `.claude/commands/wiki-status.md` 같은 비-위키 파일까지 검사했다(오탐). `*/wiki/*.md|wiki/*.md`로 좁혔다. 확인: 명령 파일·CLAUDE.md는 통과(0), 정상 위키 페이지는 통과(0), 필드가 빠진 위키 페이지는 차단(2). 사용자 승인.

## [2026-11-26 01:40] lint | 44페이지 점검 — 기계적 0건, memory·context 클러스터 topic 공백 High, 모순 목록·마커 일치
- touched: [[lint-2026-11-26]], [[index]]
- notes: 깨진 링크·고아·frontmatter 오류 0. 모순 미해결 2(taste, RLM), 부분 판정 1. [[contradictions]]와 페이지 마커 일치 확인. topic 2개 모두 [[agent-memory]]·[[prompt-optimization]]을 링크하지 않아 세 번째 "topic과 끊긴 클러스터"가 됐다. 이번엔 기존 topic 보강 대신 topic 신설을 권장했다. stale 5(orchestrator-worker 두 lint 연속, agent-containment·managed-agents·glossary는 RLM ingest 누락분, what-to-accumulate synthesis). 지난 lint 액션 #3·#4·#5 미처리. 지난 보고에서 RLM 모순 판정 후보로 든 arXiv 2609.20831이 이론 논문이라 후보에서 정정했다. ingest 후보 5개를 arXiv에서 찾아 제시(읽지 않음). 자동 수정 없음.

## [2026-11-26 01:52] curate | lint 2026-11-26 액션 #1 — topic 신설: context-and-memory
- created: [[context-and-memory]]
- updated: [[agent-memory]], [[meta-harness]], [[recursive-language-model]], [[prompt-optimization]], [[multi-agent-systems]], [[index]]
- notes: 사용자 승인한 계획대로 진행. memory·context 클러스터(소스 8개, concept 3개)가 어느 topic에서도 들어오지 않던 문제를 기존 topic 보강 대신 새 topic으로 풀었다. 이름은 `context-management` 대신 실행 사이의 기억까지 포함하는 `context-and-memory`. hub 역할만 하도록 내용은 요약·링크로 두고, 새로 쓴 것은 "누가 가져오나" 네 주체 표(모델 / harness / 고정 검색 + LLM 추출 / 모델이 쓴 코드) 하나다. *(정리)* 표시. 두 시간 척도(실행 안/사이)와 "재현된 주장 2건" 표를 더했다. compaction 단독 concept은 만들지 않고 흡수했다. 역링크 5개는 본문 문장으로 넣었다. prompt-optimization에는 "밖에 쌓기 vs 가중치에 넣기" 소절을 넣으며 RLM을 sources에 추가했다. topic이 링크하는 나머지 concept 8개(agent-containment, agent-evaluation, agent-recipe, artifact-chain, dynamic-workflows, loop-engineering, prompt-injection, subagent)의 역방향은 승인 범위 밖이라 생략했다. status draft (네 주체를 직접 비교한 데이터 없음).

## [2026-11-26 01:50] curate | lint 2026-11-26 액션 #2·#3·#4 + topic 역링크
- updated: [[orchestrator-worker]], [[glossary]], [[agent-containment]], [[managed-agents]], [[loop-engineering]], [[artifact-chain]], [[recursive-language-model]], [[context-and-memory]]
- notes: (#2) orchestrator-worker를 09-12 이후 처음 갱신했다. "위임을 말로 낸다 — 표현력의 상한" 절(RLM 비판과 적용 범위 구분), trust escalation 한계 항목, 상태 절에 compaction 지도·세션 로그 연결, brain 간 hand 전달 부분 예외를 넣고 sources에 managed-agents·containment·RLM을 추가했다. (#3) glossary에 context rot, compaction 처방 (a)~(d), RLM, recursion depth, 말로/코드로 하는 위임, overthinking을 추가했다. 오래된 정의 둘도 고쳤다: contradiction marker를 실제 형식(굵게, 날짜)과 [[contradictions]]로, knowledge update의 "구현 소스 없음"을 Zep·A-MEM으로. agent-containment에 "모델이 쓴 코드를 실행하는 scaffold" 절(*(추론)* 표시), managed-agents에 RLM 선행 연구 연결. managed-agents의 열린 질문(getEvents 슬라이스 주체)과 topic의 "누가 가져오나" 표가 어긋날 수 있어 양쪽에 근거 범위를 명시했다. (#4) CLAUDE.md §1.3에 source·meta 페이지 frontmatter 예외를 적었다 — 아래 manual 항목. topic 역링크: loop-engineering, artifact-chain, agent-containment 본문에 문장으로. topic이 링크하는 agent-evaluation·agent-recipe·dynamic-workflows·prompt-injection·subagent의 역방향은 여전히 범위 밖으로 남겼다. 바로 앞 curate 항목의 시각 01:52는 실제 시각보다 늦게 적힌 것이다(append-only라 고치지 않음).

## [2026-11-26 01:50] manual | CLAUDE.md §1.3 — source·meta 페이지 frontmatter 예외 명시
- touched: `CLAUDE.md`
- notes: lint 2026-11-25·11-26 연속 지적. source 페이지는 `sources:` 대신 `source_file:`·`source_url:`·`author:`·`source_date:`를 쓴다는 관례와, meta 페이지의 `sources:`는 비우거나 생략할 수 있다는 점을 스키마에 적었다. validate-frontmatter.sh는 이미 이 관례대로 동작한다. 사용자 승인.

## [2026-11-26 01:53] curate | lint 2026-11-26 액션 #5 + context-and-memory 역링크 5개
- updated: [[prompt-optimization]], [[recursive-language-model]], [[agent-evaluation]], [[agent-orchestration-patterns]], [[agent-recipe]], [[dynamic-workflows]], [[prompt-injection]], [[subagent]]
- notes: (#5) cross-ref 셋. prompt-optimization §5에 "전이되지 않은 prompt" 노트(RLM 시스템 프롬프트, 과제 규칙 vs 운용 규칙 구분, 모순 아님)와 RLM 쪽 대응 문장. agent-evaluation §6에 "채점이 형식과 능력을 섞으면 결론이 뒤집힌다" 노트(재현 논문 base 0%, 처방은 *(추론)*)와 sources 추가. agent-orchestration-patterns의 fan-out에 RLM을 극단으로 놓는 노트(*(해석)*)와 sources 추가, 09-21 이후 첫 갱신. 역링크: agent-evaluation·agent-recipe·dynamic-workflows·prompt-injection·subagent 본문에 [[context-and-memory]] 연결 문장. 이로써 topic이 링크하는 concept·synthesis 중 역링크가 없는 것은 what-to-accumulate-outside-the-model(synthesis, 의도적 생략)만 남는다.

## [2026-11-27 02:13] ingest | ReAct · Toolformer · Building effective agents (에이전트 기초 3종)
- source: [[wiki/sources/2022-10-06-react|ReAct]], [[wiki/sources/2023-02-09-toolformer|Toolformer]], [[wiki/sources/2024-12-19-building-effective-agents|Building effective agents]]
- created: [[agent-loop]], [[tool-use]], [[agent-fundamentals]]
- updated: [[agent-orchestration-patterns]], [[orchestrator-worker]], [[dynamic-workflows]], [[agent-evaluation]], [[meta-harness]], [[anthropic]], [[glossary]], [[loop-engineering]], [[multi-agent-systems]], [[contradictions]], [[index]]
- contradictions: [[meta-harness]] — 2024 "API를 직접 써라" vs 2026 개정 주석·Managed Agents "호스팅 harness 위에서". **부분 판정**: 층위가 다름(prompt를 가리는 추상화 vs 인프라 경계), 권고의 무게 이동은 실재, 같은 벤더
- notes: 커버리지 갭 질의(1번 — 에이전트 기초)에서 출발. raw 원문은 사용자 요청으로 Claude가 받았다. arXiv v3(ReAct)·v1(Toolformer) PDF, Anthropic 글은 현재 페이지를 pandoc으로 변환. **Anthropic 글은 개정판이다** — 편집 주석과 2024-12 이후 이름(Claude Agent SDK, Haiku 4.5)이 있어 raw frontmatter `note:`와 source 페이지에 표시했다. raw frontmatter 저자 "Erik Schluntz"는 Claude가 보충한 이름이고 페이지 표기는 "Erik S."다(raw는 고치지 않음). 중심 축은 "같은 능력을 어디에 두는가"(prompt/가중치/인터페이스) — tool-use 페이지의 뼈대. 쓰는 중에 [[2025-06-13-multi-agent-research-system]]에 이미 있던 ACI 수치(도구 설명 재작성 후 완료 시간 40% 단축)를 발견해 tool-use에 넣고 "ACI 정량 근거 없음" 서술을 고쳤다. anthropic 페이지의 학술 소스 소속 서술도 쓰는 중에 정정했다(Databricks·Tencent AI Lab 포함). index의 소스 수를 frontmatter 기준으로 다시 셌다(orchestrator-worker 3→7 등 기존 불일치 포함). 수치(PaLM-540B, GPT-J)는 "구조는 남고 수치는 낡는다" 주석과 함께 비중을 낮췄다. 역링크(§4.4): 승인된 loop-engineering·multi-agent-systems는 본문에 문장으로. 범위 밖 후보(context-and-memory topic, what-to-accumulate-outside-the-model, recursive-language-model 등)는 사용자 확인 대기.

## [2026-11-27 02:20] curate | 에이전트 기초 ingest의 범위 밖 역링크 5개
- updated: [[context-and-memory]], [[what-to-accumulate-outside-the-model]], [[recursive-language-model]], [[prompt-optimization]], [[agent-containment]], [[index]]
- notes: 바로 앞 ingest의 §4.4 점검에서 승인 범위 밖으로 남긴 후보. 사용자 승인으로 모두 본문 문장으로 넣었다. context-and-memory "밖에 쌓기 vs 가중치에 넣기"에 Toolformer(가중치)·ReAct(prompt) 대비. what-to-accumulate 판별 기준에 "도구를 주는 것도 능력 가정이다"(775M 문턱, 세 층위 수명) *(추론)*. recursive-language-model에 ReAct의 scaffold 손해 노트와 Toolformer를 학습 절의 선례로. prompt-optimization에 "도구 설명도 최적화 대상이다" 절(40% 단축, 사람이 고치던 2024년 판본). agent-containment에 ReAct 윤리 절의 행동 공간 축소를 blast radius 원리의 이른 판본으로. 모두 *(해석)* 표시. 각 페이지 sources·updated 갱신, index 소스 수 재계산.

## [2026-11-27 02:27] ingest | Working with AI (Anthropic Institute)
- source: [[wiki/sources/2026-11-23-working-with-ai|Working with AI]]
- created: [[ai-in-organizations]]
- updated: [[ai-native-sdlc]], [[loop-engineering]], [[meta-harness]], [[agent-evaluation]], [[anthropic]], [[index]]
- contradictions: 없음. [[ai-native-sdlc]] Stage 5에 "공식 코드 리뷰를 없애고 Claude와 페어링한 회사" ℹ️ 노트(독자·맥락이 다르고, 비동기 게이트 → 동기 페어링으로 읽음). [[loop-engineering]] taste 모순에 Osmani 쪽 현장 증언 추가, 판정 유지(미해결)
- notes: URL(assets.claude.com PDF)로 받은 기술 보고서. 이 위키의 첫 조직·노동경제 소스이자 첫 Institute 소스. 사용자 합의로 안 A(새 topic) 채택, 고용 영향은 source 페이지에 두고 topic에는 짧게. raw 복사는 권한에서 막혀 사용자가 `raw/papers/2026-11-23-working-with-ai.pdf`로 직접 넣기로 함. 퍼센트는 측정값이 아니라 응답 분포로 표기. ai-native-sdlc Open Question 두 개(정량 데이터, PO의 읽는 눈)에 부분 답을 달았다. 역링크(§4.4): 합의된 ai-native-sdlc·loop-engineering·meta-harness·agent-evaluation·anthropic은 본문 문장으로. source 페이지 4개는 규칙상 생략. 범위 밖 후보 topic 3개(context-and-memory, agent-fundamentals, multi-agent-systems)와 concept 다수(agentic-governance, artifact-chain, subagent 등)는 사용자 확인 대기.
