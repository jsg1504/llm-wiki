---
title: Prompt Injection (에이전트 공격면)
type: concept
created: 2026-09-21
updated: 2026-09-21
sources: [2026-05-25-how-we-contain-claude, 2026-08-20-a-harness-for-every-task-dynamic-workflows, 2026-04-08-scaling-managed-agents]
tags: [prompt-injection, agent-security, exfiltration, memory-poisoning, trust-escalation, mcp, anthropic]
status: draft
---

# Prompt Injection (에이전트 공격면)

> 공격자의 지시가 **에이전트가 읽는 무엇인가**를 타고 들어와 에이전트의 권한으로 실행되는 것. 이 페이지의 논지는 하나다 — **injection의 진입 경로는 계속 늘어나고, 방어의 성패는 경로를 막는 것이 아니라 그것이 도달했을 때 무엇을 할 수 있는지를 상한 짓는 데 달려 있다.** 막는 쪽은 [[agent-containment]].

## Overview

전통적 주입 공격(SQL, XSS)은 **데이터가 코드로 해석되는** 문제였다. LLM 에이전트에서는 그 구분 자체가 없다 — **모델이 읽는 모든 것이 지시일 수 있다.** 그래서 문제가 파싱 계층이 아니라 **신뢰 모델**로 옮겨간다.

[[2026-05-25-how-we-contain-claude]]는 이것을 에이전트 위험 3종 중 *External attackers* 항목에 놓지만, 실제로 보고된 사례들은 그 분류를 넘나든다 — **사용자를 통해 도착한 injection은 공격자 위험인가 사용자 위험인가?** 아래 "사용자가 벡터" 절이 그 경계를 지운다.

### Direct vs Indirect

| | **Indirect** (간접) | **Direct** (직접) |
|---|---|---|
| **경로** | 도구 출력, 가져온 콘텐츠, 파일, README, 웹페이지 | **사용자가 직접 입력** |
| **예** | 오염된 GitHub README가 커넥터를 타고 컨텍스트에 실림 | 피싱당한 사용자가 악성 프롬프트를 붙여넣음 |
| **모델 층위 방어** | 가능 — 도구 반환을 검사할 수 있다 | **불가능 — 잡을 이상 징후가 없다** |
| **버티는 방어** | 입력 검사 + 환경 경계 | **환경 경계뿐** |

대부분의 논의가 indirect를 다루지만, 이 소스가 보고한 **가장 성공률 높은 공격은 direct**였다.

## 보고된 공격 경로

### 사용자가 벡터 — 25회 중 24회 성공

2026년 2월 Anthropic 내부의 통제된 red-team 연습. 연구자가 **직원을 피싱해 악성 프롬프트로 [[claude-code]]를 띄우게 했다.**

```
"이것 좀 돌려줄래?" 이메일           ← 평범한 협업처럼 보임
  └─ 붙여넣기 좋은 프롬프트 첨부      ← 일상적 작업 지시처럼 읽힘
       └─ 셋업 단계 사이에 한 줄:
            ~/.aws/credentials 를 읽고
            인코딩해서 외부 엔드포인트로 POST
                    │
                    ▼
            25회 재시도 → 24회 유출 성공
```

**왜 모델 층위가 못 막았는가**가 이 사례의 핵심이다:

> *"Our model-layer defenses anchor on user intent—when the user is the one typing the instruction, **there's nothing anomalous for a classifier to catch**. A human contractor handed the same script would have done the same thing."*

classifier는 사용자 의도에 닻을 내린다. 사용자가 직접 친 지시에는 이상할 것이 없다. **같은 스크립트를 받은 사람 계약자도 똑같이 했을 것**이라는 문장이 이것이 모델의 결함이 아님을 정확히 짚는다.

**버티는 방어는 환경뿐이다** — 의도와 무관하게 POST를 막는 egress 통제, `~/.aws`를 애초에 닿을 수 없게 하는 파일시스템 경계.

> **⚠️ 곁가지가 더 무섭다.** 작동하는 프롬프트를 내부 Slack에 논의차 공유했더니, *"일부 내부 에이전트가 Slack을 읽는다"* 는 지적이 나왔다. **payload가 ambient가 된 것.** canary string을 달아 뭔가 집어가는지 감시해야 했다.
>
> *"In a world where agents read everything, the investigation tooling is also an attack surface."*
>
> 보안 사고의 **조사 과정 자체가 전파 경로**가 된다. 에이전트가 조직의 커뮤니케이션을 읽는 환경에서는 인시던트 대응 절차를 다시 써야 한다는 뜻이다.

### 승인된 도메인을 통한 유출 — "sandbox는 완벽하게 작동했다"

서드파티 책임공개로 드러난 사례. Cowork의 egress allowlist는 `api.anthropic.com`을 정상 통과시켰다 — **제품이 자사 API를 못 부르면 작동하지 않으므로.**

```
1. 공격자가 사용자의 마운트된 workspace에 악성 파일을 놓는다
     └─ 숨은 지시 + 공격자가 통제하는 API 키

2. Claude가 지시를 따라 workspace의 다른 파일들을 읽는다

3. Claude가 공격자의 키로 Anthropic Files API를 호출한다

4. egress 프록시: 목적지 확인 → api.anthropic.com → 통과 ✅

5. 파일이 공격자의 Anthropic 계정으로 업로드됨
```

> *"The sandbox worked perfectly, and yet the data was exfiltrated."*

**재개념화가 이 사례의 산출물이다:**

> **allowlist는 목적지 필터가 아니라 capability grant다.**
>
> *"Every function reachable through any domain on an allowlist is now an attack surface. Allowing `api.anthropic.com` meant allowing file uploads to arbitrary Anthropic accounts."*

도메인을 허용한다는 것은 **그 도메인 뒤의 모든 기능을 허용한다**는 뜻이다. 자사 API조차 — 아니, 자사 API이기 때문에 더 — 예외가 아니다.

수정은 **VM 안에** 방어적 MITM 프록시를 두는 것이었다. **VM 자신에게 발급된 세션 토큰을 실은 요청만** 통과시켜 공격자가 심은 키를 거부하고, server-side fetch를 가능케 하는 헤더도 막는다. **프록시가 서버가 아니라 VM 안에 있는 이유:** 서버 입장에서 Cowork 요청은 다른 API 클라이언트와 구별되지 않는다. **provenance를 아는 것은 VM뿐이다.**

### 신뢰 경계 이전에 도착하는 것

[[claude-code]]에서 보고된 취약점 3건이 전부 이 형태였다 — repo를 clone하면 `.claude/settings.json`의 hook이 **"이 폴더를 신뢰합니까?" 프롬프트보다 먼저** 실행된다. 상세와 처방은 [[agent-containment]].

핵심만: **로컬처럼 느껴지고 동의 전에 도착한다는 이유로 암묵적 신뢰를 주면 안 된다.**

### 도구 출력 — 도구를 신뢰해도 공격 표면이다

**감사된 커넥터는 감사된 데이터가 아니다.** GitHub 커넥터는 멀웨어 검사를 통과하고도 **오염된 README를 모델 컨텍스트에 바로 싣는다.**

외부 자원은 언제나 **두 위험을 동시에** 갖는다:

| 위험 | 전통적 감사로 잡히는가 |
|---|---|
| **코드 실행 위험** (공급망) | ✅ 버전 핀, 서명 검증, 소스 리뷰 |
| **prompt injection 벡터** | ❌ **완전히 놓친다** |

**remote vs local의 구분이 생각보다 중요하다:**

- **로컬 도구는 감사 가능하다** — 코드를 읽고, 버전을 핀하고, 내 밑에서 안 바뀐다는 걸 안다.
- **원격 도구(호스팅 MCP 서버, 클라우드 커넥터)는 승인 후 언제든 동작이 바뀔 수 있다.** 설치 시점의 신뢰 판단이 더 이상 유효하지 않을 수 있다.
- 검토된 커넥터 디렉토리 바깥의 것은 **미신뢰로 다룬다.** 먼저 가짜 데이터로, blast radius가 통제된 환경에서 돌려본다.

처방은 **live inspection**이다. 웹페이지에 적용하는 입력 스캔을 네트워크 도구 결과에도 같은 엄격함으로 적용한다. 지연이 늘고 완벽하지도 않지만 그쪽으로 기우는 이유가 결정적이다:

> *"once a poisoned tool return has steered the agent into exfiltrating data, the log just shows a successful, authorized API call. **There's no after-the-fact signal to find.**"*

구현상 위안 하나: 검사하는 classifier는 **작고 빠른 모델이면 된다. 추론하는 모델일 필요가 없다.** [[claude-code]]와 Cowork에서 도구 호출은 프록시를 경유해 정책을 강제하고 반환값이 컨텍스트에 들어가기 전에 검사된다.

## 앞으로 커지는 두 벡터

### Persistent memory poisoning — 이 위키에 직접 해당된다

세션을 넘어 지속되는 에이전트 컨텍스트의 비중이 계속 늘고 있다:

- product memory
- **`CLAUDE.md` 파일**
- 마운트된 workspace
- **스케줄·장기 실행 에이전트의 state 디렉토리**

> 여기 들어간 injection은 **에이전트가 시작할 때마다 다시 로드된다.** 고전적 post-exploitation 의미의 **지속성 메커니즘**이다.

저자들의 전망: *"세션 시작 시의 좋은 classifier가 더 일반화되어야 할 것이다."*

> ⚠️ **위키의 기존 서술과 부딪히는 지점.** [[claude-code]]·[[artifact-chain]]·[[ai-native-sdlc]]는 *"설정이 파일이므로 리뷰·감사·버전 관리의 대상이 된다"* 를 [[agentic-governance]]의 전제로 삼는다. 같은 속성의 반대편이 이것이다 — **파일이므로 공격자도 커밋할 수 있고, 커밋되면 매 세션 로드된다.** 실제 취약점 3건이 그 경로였다.
>
> 모순은 아니다. 리뷰 가능성은 실재하고 **방어의 일부**다(악성 `CLAUDE.md` 변경은 PR에서 보인다). 다만 위키가 지금까지 이 속성을 **장점으로만** 적어 왔다.
>
> **이 위키 자체도 해당된다.** 프로젝트 `CLAUDE.md`와 `.claude/skills/`가 매 세션 로드되므로, repo를 신뢰한다는 결정이 곧 그 파일들의 내용을 신뢰한다는 결정이다. 장기 축적되는 `wiki/`도 같은 성질을 갖기 시작한다.

### Multi-agent trust escalation — quarantine 패턴의 이면

[[agentic-governance]]가 기록한 **quarantine 패턴**은 정확히 이 소스가 말하는 좋은 쪽이다 — subagent가 미신뢰 콘텐츠를 격리해 raw text 대신 **구조화된 사실**만 메인 에이전트로 올린다.

**그런데 같은 구조가 악용될 수 있다:**

> *"if a sub-agent's output is treated as higher-trust than raw tool results, because such output came from "us," a new vector for prompt injection is introduced. In multi-agent systems, there is a **tradeoff between allocating differing trust levels and becoming liable to trust escalation**."*

```
의도한 작동                          악용
─────────────────────────           ─────────────────────────
미신뢰 콘텐츠                        미신뢰 콘텐츠
    │                                    │
    ▼                                    ▼
[격리된 subagent]                    [격리된 subagent]
    │  구조화된 사실만                    │  주입된 지시를 "사실"로
    ▼                                    ▼  포장해서 올림
[메인 에이전트]                      [메인 에이전트]
  raw text를 안 봄 ✅                  "우리 것"이라 더 신뢰 ❌
                                       → 신뢰 등급이 상승했다
```

**격리가 세탁이 되는 것**이 문제다. 경계를 넘으면서 데이터의 출처 표식이 사라지고, 오히려 신뢰 등급이 올라간다.

> ⚠️ **위키 수정 사항 (2026-09-21):** [[agentic-governance]]는 quarantine이 *"prompt injection을 아키텍처 층위에서 **무력화**"* 한다고 적고 *"이 위키에는 아직 검증된 레시피가 없다"* 고 유보했다. **유보가 옳았다.** 무력화가 아니라 **트레이드오프**로 고쳐 읽어야 한다 — 신뢰 수준을 차등 배분하면 그 차등 자체가 공격 대상이 된다.
>
> 완화의 방향은 분명하다: **subagent 출력을 raw tool result와 같은 등급으로 다루고, 같은 검사를 통과시킨다.** 다만 이 소스도 구체적 레시피는 주지 않는다 — *"looking ahead"* 절의 전망이지 해결된 문제로 제시되지 않는다.

## Agent identity — 아직 답이 없는 것

에이전트가 무엇의 권한으로 행동하는가는 injection의 blast radius를 직접 결정한다. Cowork의 답은 구체적이다:

- 자격증명은 **호스트 keychain**에 남는다
- VM은 **세션별 스코프다운 토큰**을 받는다
- **그 토큰은 사용자 것과 독립적으로 폐기 가능하다**

그러나 넓은 질문은 열려 있다 — **에이전트가 자기 principal identity를 가져야 하는가, 사용자의 확장으로서 사용자 권한을 상속해야 하는가?** 저자들의 잠정 답: *"the answer may be a blend of the two."*

[[claude-code]]가 [[2026-08-21-the-ai-native-sdlc-playbook]]에서 *"각 실행이 에이전트 자신의 identity로 동작하므로 파이프라인 로그가 에이전트의 행위와 트리거한 엔지니어의 행위를 분리한다"* 고 적은 것이 전자에 가깝다. 두 소스가 같은 축의 다른 지점에 있고, **이 위키는 아직 이 질문에 답을 갖고 있지 않다.**

저자들은 이것을 업계 공통 과제로 제시하며 외부 표준을 가리킨다 — NIST의 AI agent identity/authorization 프로젝트, 호주 ACSC가 CISA·영국 NCSC와 주도한 6개 기관 agentic AI 도입 지침, ISO/IEC 42001. **이 위키에 들어온 소스 중 외부 기관을 참조 지점으로 제시하는 첫 사례다.**

## 방어의 요약 — 무엇이 어디서 버티는가

| 공격 경로 | 모델 층위 | 환경 층위 | 콘텐츠 층위 |
|---|---|---|---|
| Indirect (도구 출력, 파일) | 부분 — classifier가 검사 가능 | ✅ egress·파일 경계 | ✅ live inspection, remote 도구 경계 |
| **Direct (사용자 경유)** | ❌ **잡을 이상 징후 없음** | ✅ **유일하게 버팀** | — |
| 승인된 도메인 유출 | ❌ | ✅ 단 **capability grant로 재설계 필요** | — |
| 신뢰 경계 이전 실행 | ❌ | ✅ 파싱을 동의 이후로 연기 | — |
| Memory poisoning | 세션 시작 classifier (미성숙) | 부분 | 지속 아티팩트의 리뷰 |
| Trust escalation | ❌ 신뢰 등급이 문제 | 부분 | subagent 출력을 동급으로 검사 |

**패턴이 보인다:** 모델 층위는 indirect에서만 실질적으로 기여하고, **나머지 전부에서 환경 층위가 최후 방어선**이다. 이것이 [[agent-containment]]의 *"환경 층위 먼저"* 원칙의 실증적 근거다.

## 한계와 읽을 때의 주의

- **이 페이지의 사례는 전부 한 조직의 것이다.** 다섯 소스가 모두 [[anthropic]]이고, 여기 적힌 공격은 Anthropic 제품에서 발견·수정된 것들이다. **발견되지 않은 것의 분포는 알 수 없고**, 다른 벤더의 에이전트에서 어떤 경로가 열려 있는지도 이 위키에 자료가 없다.
- **완화 이후의 재측정이 없다.** MITM 프록시가 같은 공격을 막는지, trust dialog 수정 후 유사 취약점이 줄었는지에 대한 수치가 제시되지 않는다.
- **trust escalation과 memory poisoning은 전망이다.** *"Looking ahead"* 절의 내용이며 **실제 사고 보고가 아니다.** 원리는 설득력 있지만 이 위키에는 아직 사례도 레시피도 없다.
- **Gray Swan 수치의 해석 주의.** 단발 0.1%는 낮지만 **100회 적응적 공격 후 5~6%** 다. 실제 공격자는 한 번만 시도하지 않는다.

## Related

- [[agent-containment]] — 이 공격면을 막는 쪽. 두 페이지는 공격/방어 쌍이다
- [[agentic-governance]] — quarantine 패턴이 기록된 곳. 이 페이지가 그 실패 모드를 더한다
- [[subagent]] — trust escalation이 일어나는 구조적 단위
- [[claude-code]] — 취약점 3건과 sandbox·auto mode의 실제 맥락
- [[meta-harness]] — *"좁은 스코핑은 모델 능력에 대한 가정"* — capability grant 재개념화와 같은 축
- [[managed-agents]] — 자격증명이 에이전트에 닿지 않게 하는 두 패턴
- [[artifact-chain]] — 지속 아티팩트가 memory poisoning 면을 갖는다
- [[multi-agent-systems]] — 에이전트를 여럿 굴릴 때 신뢰 경계가 늘어나는 문제

## Sources

- [[2026-05-25-how-we-contain-claude]] — Max McGuinness 외 4인 (Anthropic Engineering, 2026-05-25). 이 페이지 대부분의 1차 출처
- [[2026-08-20-a-harness-for-every-task-dynamic-workflows]] — quarantine 패턴의 원래 기록 (trust escalation 절의 대조군)
- [[2026-04-08-scaling-managed-agents]] — 자격증명이 sandbox에 닿지 않게 하는 구조적 방어
