#!/usr/bin/env bash
# bootstrap.sh
# 새 위키 인스턴스를 빠르게 셋업하는 스크립트.
# 이 프로젝트를 어딘가에 복사해두고 새 위키 만들 때마다 이 스크립트 실행.

set -euo pipefail

echo "🌱 LLM Wiki 부트스트랩"
echo

# 1. hook 실행 권한
echo "→ hook 실행 권한 부여..."
chmod +x .claude/hooks/*.sh
echo "  ✓ done"

# 2. 의존성 점검
echo "→ 의존성 점검..."
MISSING=()
for cmd in jq grep find sed awk realpath; do
  command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "  ⚠️  누락된 명령: ${MISSING[*]}"
  echo "     macOS: brew install ${MISSING[*]}"
  echo "     Ubuntu: sudo apt install ${MISSING[*]}"
fi
echo "  ✓ done"

# 3. git 초기화 (선택)
if [ ! -d .git ]; then
  echo "→ git 초기화..."
  read -p "  git init 할까요? [y/N] " GITINIT
  if [[ "$GITINIT" =~ ^[Yy]$ ]]; then
    git init -q
    git add -A
    git commit -q -m "bootstrap: llm-wiki scaffolding from karpathy pattern"
    echo "  ✓ done"
  else
    echo "  ⏭️  skip"
  fi
fi

# 4. 디렉토리 무결성 점검
echo "→ 디렉토리 구조 점검..."
REQUIRED_DIRS=(
  "raw/articles" "raw/papers" "raw/notes" "raw/assets"
  "wiki/entities" "wiki/concepts" "wiki/topics" "wiki/sources" "wiki/syntheses" "wiki/meta"
  ".claude/agents" ".claude/commands" ".claude/hooks" ".claude/skills"
)
for d in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$d" ]; then
    mkdir -p "$d"
    echo "  + created: $d"
  fi
done
echo "  ✓ done"

# 5. 필수 파일 점검
echo "→ 필수 파일 점검..."
for f in CLAUDE.md README.md wiki/meta/index.md wiki/meta/log.md; do
  if [ ! -f "$f" ]; then
    echo "  ⚠️  누락: $f"
  fi
done
echo "  ✓ done"

# 6. 다음 단계 안내
cat <<'EOF'

✅ 부트스트랩 완료

다음 단계:
  1. raw/articles/ 또는 raw/papers/에 첫 소스를 두세요.
  2. `claude` 명령으로 Claude Code 진입.
  3. SessionStart hook이 위키 현황을 자동 주입합니다.
  4. `/ingest <path>`로 첫 통합 시작.

선택:
  - Obsidian으로 이 디렉토리를 vault로 열어 그래프 뷰 활용.
  - `git remote add origin <url>` 로 리모트 연결.
EOF
