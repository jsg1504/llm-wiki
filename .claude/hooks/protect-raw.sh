#!/usr/bin/env bash
# protect-raw.sh
# PreToolUse hook: Edit/Write 등으로 raw/ 디렉토리에 변경을 가하려 하면 차단.
# raw/는 immutable이라는 위키의 핵심 불변식을 강제한다.
#
# Claude Code는 PreToolUse hook의 stdin으로 JSON을 보낸다:
#   { "tool_name": "Edit"|"Write"|...,  "tool_input": { "file_path": "...", ... } }
# exit 0  → 허용
# exit 2  → 차단 (Claude에게 stderr 메시지 전달)

set -euo pipefail

INPUT="$(cat)"
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# 변경 도구만 검사
case "$TOOL_NAME" in
  Edit|Write|MultiEdit|NotebookEdit|str_replace|create_file)
    ;;
  *)
    exit 0
    ;;
esac

# 빈 path는 통과
[ -z "$FILE_PATH" ] && exit 0

# 절대 경로 정규화 시도
RESOLVED_PATH=$(realpath -m "$FILE_PATH" 2>/dev/null || echo "$FILE_PATH")

# raw/ 아래에 쓰려고 하면 차단
case "$RESOLVED_PATH" in
  */raw/*|*/raw)
    echo "🛡️  BLOCKED: raw/ 디렉토리는 immutable입니다." >&2
    echo "    경로: $FILE_PATH" >&2
    echo "    raw/는 원본 소스의 신성불가침 영역이며, Claude는 읽기만 할 수 있습니다." >&2
    echo "    위키 변경은 wiki/ 아래에서 수행하세요." >&2
    echo "    (이 정책은 CLAUDE.md §1.1에서 정의됨)" >&2
    exit 2
    ;;
esac

exit 0
