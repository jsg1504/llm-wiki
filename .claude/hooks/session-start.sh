#!/usr/bin/env bash
# session-start.sh
# SessionStart hook: 새 세션이 시작될 때 위키의 최근 상태를 컨텍스트에 추가.
# stdout으로 출력하면 Claude의 시스템 컨텍스트에 추가된다.

set -euo pipefail

# 위키 루트 추정
WIKI_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

cd "$WIKI_ROOT" 2>/dev/null || exit 0

# 위키가 아직 비어있으면 안내만
if [ ! -f "wiki/meta/log.md" ]; then
  cat <<EOF
## 📚 LLM Wiki — 첫 세션

이 위키는 비어있습니다. 시작하려면:
1. \`raw/\` 아래에 첫 소스를 두세요 (예: \`raw/articles/\`).
2. \`/ingest <path>\` 또는 "이 파일 정리해줘"라고 요청하세요.
3. CLAUDE.md를 한 번 훑어보세요 — 위키의 헌법입니다.
EOF
  exit 0
fi

# 페이지 카운트
ENTITIES=$(find wiki/entities -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
CONCEPTS=$(find wiki/concepts -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
TOPICS=$(find wiki/topics -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
SOURCES=$(find wiki/sources -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
SYNTHESES=$(find wiki/syntheses -name '*.md' 2>/dev/null | wc -l | tr -d ' ')

# 최근 활동
RECENT=$(grep "^## \[" wiki/meta/log.md 2>/dev/null | tail -5 | sed 's/^/  /')

# 미해결 모순 카운트
# `^> ⚠️ Contradiction`로 정확히 모순 마커만 잡고 meta는 제외 (glossary가 용어 정의용으로 마커 텍스트를 포함할 수 있음)
# `|| true` chain으로 grep 매치 없을 때의 exit 1 (set -e 트리거)을 무력화.
CONTRADICTIONS=$( { grep -rl "^> ⚠️ Contradiction" wiki/ --include="*.md" 2>/dev/null || true; } \
  | { grep -v "^wiki/meta/" || true; } | wc -l | tr -d ' ')

# 출력 (Claude의 컨텍스트에 추가됨)
cat <<EOF
## 📚 위키 현황 스냅샷

규모: entities=$ENTITIES, concepts=$CONCEPTS, topics=$TOPICS, sources=$SOURCES, syntheses=$SYNTHESES
미해결 모순: $CONTRADICTIONS

최근 활동 (log.md tail -5):
$RECENT

세션 시작 체크:
- [ ] CLAUDE.md를 읽었는가? (위키의 스키마)
- [ ] 사용자의 요청이 INGEST/QUERY/LINT/CURATE 중 무엇인지 분류했는가?
EOF

exit 0
