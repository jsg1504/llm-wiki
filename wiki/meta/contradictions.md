---
title: Contradictions Registry
type: meta
created: 2026-04-28
updated: 2026-04-28
status: mature
---

# ⚠️ Contradictions Registry

> 위키 안에서 **서로 다른 1차 출처가 같은 사실에 대해 반대로 주장**하는 경우들의 통합 레지스트리. CLAUDE.md §6의 anti-pattern("모순을 조용히 덮어쓰지 말 것")에 따라, 어느 한쪽으로 결론짓지 않고 양쪽 주장을 병기한다.

## 운영 원칙

1. **양쪽 주장 다 보존.** 원본 페이지에 `> ⚠️ Contradiction (YYYY-MM-DD):` blockquote로 명시하고, 본 레지스트리에 한 줄 추가.
2. **자체 벤치 cross-citation은 약한 증거.** 논문이 자기 방법을 자기 벤치에서 비교하면 selection bias 위험이 크다. third-party 벤치(HumanEval, MBPP, …) 결과만 cross-validation에 신뢰.
3. **결론 짓지 않음.** 새 1차 출처 또는 독립 재현 결과가 들어와야 닫는다 (`status: resolved`).

## 등록된 모순

### C-001: MetaGPT ↔ ChatDev — cross-evaluation 충돌

- **상태**: open
- **등록**: 2026-04-28
- **관련 페이지**: [[metagpt]] · [[chatdev]] · [[2308.00352-metagpt]] · [[2307.07924-chatdev]] · [[llm-multi-agent-frameworks]]

**충돌 지점**: 두 논문이 자기 자체 벤치에서 자기가 상대를 이긴다고 보고.

| 출처 | 벤치 | ChatDev Executability | MetaGPT Executability |
|---|---|---|---|
| [[2308.00352-metagpt]] (Hong et al., ICLR 2024) | SoftwareDev (자체, 70 task, /4 scale) | 2.25 | **3.75** |
| [[2307.07924-chatdev]] (Qian et al., 2024) | SRDD (자체, 1,200 task, [0,1] scale) | **0.8800** | 0.4145 |

토큰 사용량 보고치도 다름:
- MetaGPT 논문 보고: ChatDev 19,292 / MetaGPT 31,255
- ChatDev 논문 보고: ChatDev 22,949 / MetaGPT 29,278

**가능한 원인 (확정 아님)**:
1. 서로 다른 task 분포 — 각자 자기 방법에 친화적인 task domain을 골랐을 수 있음 (selection bias).
2. 서로 다른 metric 정의 — SoftwareDev은 1~4 정수 등급, SRDD는 [0,1] 비율. 직접 비교 불가.
3. 서로 다른 base LLM / 평가 환경 — ChatDev은 GPT-3.5 + temp 0.2 + Python 3.11.4 명시. MetaGPT 논문의 ChatDev 측 환경은 명세 약함.
4. 평가 시점/구현 버전 차이 — 두 논문이 평가한 상대 프레임워크의 버전이 다를 수 있음.

**해소 조건 (proposed)**:
- 독립 third-party가 두 프레임워크를 동일 task set + 동일 base LLM + 동일 metric으로 평가한 결과가 들어오면 close.
- 또는 양 논문의 후속 버전이 서로의 결과를 명시적으로 인정/반박하면 close.

**위키 포지션**: 둘 다 "자기 self-reported 벤치에서 우월"하다고만 적고, 두 프레임워크의 실제 우열은 미확정으로 둔다. 직접 비교가 필요한 결정에서는 third-party 벤치(예: MetaGPT 논문이 보고한 HumanEval/MBPP — 이건 ChatDev 논문에서 반박되지 않음)를 우선 신뢰.

**메타 정황 (2026-04-28 [[2308.10848-agentverse]] ingest 후 추가)**: AgentVerse 저자 그룹은 [[chatdev]] 저자 그룹과 상당 부분 겹친다 (Chen Qian, Yusheng Su, Cheng Yang, Zhiyuan Liu, Maosong Sun 등 공저, 같은 OpenBMB 우산). 그럼에도 AgentVerse는 SoftwareDev/SRDD에서 ChatDev/MetaGPT와의 직접 비교를 하지 않는다. 새 데이터를 더하지 않으므로 이 모순을 해소하지는 않지만, 같은 그룹에서 만든 시스템들임에도 자체 벤치 cross-comparison이 통합되지 않은 정황은 자체 벤치 비교의 신뢰도에 대한 위키의 회의적 입장을 약하게 강화한다.

## 다음 등록 시 양식

```markdown
### C-NNN: <짧은 제목>

- **상태**: open | resolved (YYYY-MM-DD, 해결 근거)
- **등록**: YYYY-MM-DD
- **관련 페이지**: [[…]]

**충돌 지점**: …
**가능한 원인**: …
**해소 조건**: …
**위키 포지션**: …
```
