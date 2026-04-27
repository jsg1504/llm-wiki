#!/usr/bin/env bash
# log-tracker.sh
# Stop hook: 세션이 끝날 때, wiki/ 안에서 변경이 있었으나 log.md에 새 항목이 없으면 경고.
# 위키의 추적성(traceability)을 보장.

set -euo pipefail

WIKI_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$WIKI_ROOT" 2>/dev/null || exit 0

# git이 없으면 통과 (이 hook은 git에 의존)
command -v git >/dev/null 2>&1 || exit 0
[ -d .git ] || exit 0

# 이번 세션에서 wiki/ 아래(meta/log.md 제외) 변경이 있었는가?
CHANGED=$(git diff --name-only HEAD 2>/dev/null \
  | grep "^wiki/" | grep -v "^wiki/meta/log.md$" || true)

if [ -z "$CHANGED" ]; then
  exit 0
fi

# log.md가 이번에 수정되었는가?
LOG_CHANGED=$(git diff --name-only HEAD 2>/dev/null \
  | grep "^wiki/meta/log.md$" || true)

if [ -z "$LOG_CHANGED" ]; then
  cat >&2 <<EOF

⚠️  로그 누락 가능성

이번 세션에서 wiki/ 아래 다음 파일이 변경되었습니다:
$(echo "$CHANGED" | sed 's/^/  - /')

하지만 wiki/meta/log.md에 해당 변경에 대한 항목이 없습니다.
log.md는 위키의 추적성을 보장합니다 (CLAUDE.md §4.2).

다음 형식으로 한 줄 추가하세요:
  ## [YYYY-MM-DD HH:MM] <op> | <title>
  - touched: [[page1]], [[page2]]
  - notes: ...
EOF
fi

exit 0
