#!/usr/bin/env bash
# Claude PreToolUse hook: git push / gh pr create 전에 knowledges/ 업데이트와 OKF 형식을 검사한다.
# 수동/로컬 CI 실행: ./.claude/hooks/check-knowledges.sh
# 예외: 범위 내 커밋 메시지에 [skip knowledge] 가 있으면 업데이트 검사만 건너뛴다.
set -uo pipefail

if [ "${1:-}" = --hook ]; then
  cmd=$(jq -r '.tool_input.command // empty')
  echo "$cmd" | grep -Eq '(^|[;&|(][[:space:]]*|[[:space:]])(git[[:space:]]+push|gh[[:space:]]+pr[[:space:]]+create)([[:space:]]|$)' || exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0
KDIR=knowledges
errors=()

# 1. OKF 형식: 예약 파일 외 모든 .md는 frontmatter와 비어있지 않은 type을 가져야 한다.
while IFS= read -r f; do
  awk 'NR==1 && $0!="---" {exit 1}
       NR>1 && $0=="---" {exit found?0:1}
       NR>1 && /^type:[[:space:]]*[^[:space:]]/ {found=1}
       END {if (NR<2) exit 1}' "$f" || errors+=("OKF 위반: $f 에 frontmatter 또는 type 이 없다")
done < <(find "$KDIR" -name '*.md' ! -name index.md ! -name log.md 2>/dev/null)

# 2. 모든 디렉터리에 index.md 가 있어야 한다.
while IFS= read -r d; do
  [ -f "$d/index.md" ] || errors+=("OKF 위반: $d/index.md 가 없다")
done < <(find "$KDIR" -type d 2>/dev/null)

# 3. 코드 변경이 있으면 knowledges/ 변경도 있어야 한다.
base_ref=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/main)
if base=$(git merge-base HEAD "$base_ref" 2>/dev/null); then
  changed=$(git diff --name-only "$base"...HEAD)
  if [ -n "$changed" ] \
     && echo "$changed" | grep -qv "^$KDIR/" \
     && ! echo "$changed" | grep -q "^$KDIR/" \
     && ! git log --format=%B "$base"..HEAD | grep -qF '[skip knowledge]'; then
    errors+=("$base_ref 이후 커밋에 코드 변경은 있지만 $KDIR/ 변경이 없다. AGENTS.md 규칙대로 concept 문서와 $KDIR/log.md 를 업데이트하고 커밋한 뒤 다시 시도하라.")
  fi
fi

if [ ${#errors[@]} -gt 0 ]; then
  printf 'knowledges 검사 실패:\n' >&2
  printf ' - %s\n' "${errors[@]}" >&2
  exit 2
fi
exit 0
