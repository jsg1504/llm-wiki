#!/usr/bin/env bash
# validate-frontmatter.sh
# PostToolUse hook: wiki/ 아래 .md 파일이 작성/수정된 후 frontmatter 검증.
# 필수 필드가 누락되면 경고를 띄운다 (차단하지는 않음 — Claude가 후속 수정).

set -euo pipefail

INPUT="$(cat)"
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

case "$TOOL_NAME" in
  Edit|Write|MultiEdit|str_replace|create_file)
    ;;
  *)
    exit 0
    ;;
esac

# wiki/ 안의 .md 파일만 검사
case "$FILE_PATH" in
  *wiki/*.md)
    ;;
  *)
    exit 0
    ;;
esac

# meta 페이지(log.md, index.md, lint-*.md)는 frontmatter 규칙이 다름. 통과.
case "$FILE_PATH" in
  *wiki/meta/log.md|*wiki/meta/index.md)
    exit 0
    ;;
esac

# 파일이 존재하지 않으면 (삭제된 경우) 통과
[ -f "$FILE_PATH" ] || exit 0

# frontmatter 추출 (첫 --- 부터 두 번째 ---까지)
FM=$(awk '/^---$/{c++; next} c==1' "$FILE_PATH" 2>/dev/null || echo "")

if [ -z "$FM" ]; then
  echo "⚠️  frontmatter 누락: $FILE_PATH" >&2
  echo "    위키 페이지는 ---로 둘러싼 frontmatter가 필요합니다 (CLAUDE.md §1.3)." >&2
  exit 0  # 경고만, 차단하지 않음
fi

REQUIRED=("title" "type" "created" "updated" "status")
MISSING=()

for field in "${REQUIRED[@]}"; do
  if ! echo "$FM" | grep -qE "^${field}:"; then
    MISSING+=("$field")
  fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "⚠️  frontmatter 필수 필드 누락: $FILE_PATH" >&2
  echo "    누락: ${MISSING[*]}" >&2
  echo "    (필수 필드 정의: CLAUDE.md §1.3)" >&2
fi

exit 0
