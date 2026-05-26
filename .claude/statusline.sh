#!/usr/bin/env bash
# Claude Code status line — model, context bar, tokens, cost, duration, git
set -euo pipefail

INPUT=$(cat)

# ── Data extraction ──────────────────────────────────────────────
MODEL=$(echo "$INPUT"   | jq -r '.model.display_name // empty')
DIR=$(echo "$INPUT"     | jq -r '.workspace.current_dir // empty')
PCT=$(echo "$INPUT"     | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
COST=$(echo "$INPUT"    | jq -r '.cost.total_cost_usd // 0')
DUR_MS=$(echo "$INPUT"  | jq -r '.cost.total_duration_ms // 0')
IN_T=$(echo "$INPUT"    | jq -r '.context_window.total_input_tokens // 0')
OUT_T=$(echo "$INPUT"   | jq -r '.context_window.total_output_tokens // 0')

# ── ANSI colors ──────────────────────────────────────────────────
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'
RED='\033[31m';  MAGENTA='\033[35m'; RESET='\033[0m'
BOLD='\033[1m'

# ── Token formatter ──────────────────────────────────────────────
fmt_tokens() {
  local n=$1
  if   [ "$n" -ge 1000000 ]; then echo "$(awk "BEGIN { printf \"%.1f\", $n/1000000 }")M"
  elif [ "$n" -ge 1000 ];    then echo "$(awk "BEGIN { printf \"%.0f\", $n/1000 }")K"
  else                            echo "$n"
  fi
}
IN_FMT=$(fmt_tokens "$IN_T")
OUT_FMT=$(fmt_tokens "$OUT_T")

# ── Context progress bar ─────────────────────────────────────────
if [ -n "$PCT" ] && [ "$PCT" -ge 0 ] 2>/dev/null; then
  [ "$PCT" -ge 90 ] && BAR_COLOR="$RED"
  [ "$PCT" -ge 70 ] && [ "$PCT" -lt 90 ] && BAR_COLOR="$YELLOW"
  [ "$PCT" -lt 70 ] && BAR_COLOR="$GREEN"

  FILLED=$((PCT / 10)); [ "$FILLED" -gt 10 ] && FILLED=10
  EMPTY=$((10 - FILLED))
  BAR=$(printf "%${FILLED}s" | tr ' ' '#')$(printf "%${EMPTY}s" | tr ' ' '-')
  CTX="${BAR_COLOR}${BAR}${RESET} ${PCT}%"
else
  CTX="ctx:--%"
fi

# ── Duration formatter ────────────────────────────────────────────
MINS=$((DUR_MS / 60000))
SECS=$(((DUR_MS % 60000) / 1000))
DUR_FMT="${MINS}m${SECS}s"
[ "$MINS" -eq 0 ] && DUR_FMT="${SECS}s"

# ── Cost ──────────────────────────────────────────────────────────
COST_FMT="$(printf '$%.2f' "$COST")"
[ "$COST" = "0" ] && COST_FMT='$0.00'

# ── Git info ──────────────────────────────────────────────────────
GIT=""
STAGED=0; MODIFIED=0
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "HEAD")
  STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
fi

GIT="${CYAN}${BRANCH:-}${RESET}"
[ "$STAGED" -gt 0 ]   && GIT="${GIT} ${GREEN}+${STAGED}${RESET}"
[ "$MODIFIED" -gt 0 ] && GIT="${GIT} ${YELLOW}~${MODIFIED}${RESET}"
[ -z "$BRANCH" ] && GIT=""

# ── Directory name ────────────────────────────────────────────────
DIRNAME="${DIR##*/}"
[ -z "$DIRNAME" ] && DIRNAME="~"

# ── Build output ──────────────────────────────────────────────────
LINE="${BOLD}${CYAN}${MODEL}${RESET}"
LINE="${LINE}  ${DIRNAME}"
[ -n "$GIT" ] && LINE="${LINE}  ${GIT}"
LINE="${LINE}  ${CTX}"
LINE="${LINE}  ${CYAN}↑${IN_FMT}${RESET} ${YELLOW}↓${OUT_FMT}${RESET}"
LINE="${LINE}  ${MAGENTA}${COST_FMT}${RESET}"
LINE="${LINE}  ⏱ ${DUR_FMT}"

echo -e "$LINE"
