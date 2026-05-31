#!/usr/bin/env bash
# pi-memory session management
# Usage: session.sh save <summary>
#        session.sh list

set -euo pipefail

SESSION_DIR="$HOME/.pi/memory/sessions"
TODAY=$(date "+%Y-%m-%d")
SESSION_FILE="$SESSION_DIR/$TODAY.md"
NOW=$(date "+%Y-%m-%d %H:%M")

action_save() {
  mkdir -p "$SESSION_DIR"
  if [ ! -f "$SESSION_FILE" ]; then
    echo "# Session: $TODAY" > "$SESSION_FILE"
    echo "" >> "$SESSION_FILE"
    echo "| Time | Summary |" >> "$SESSION_FILE"
    echo "|------|---------|" >> "$SESSION_FILE"
  fi
  echo "| $NOW | $* |" >> "$SESSION_FILE"
  echo "OK: Session logged"
}

action_list() {
  if [ ! -d "$SESSION_DIR" ]; then
    echo "No sessions yet."
    return
  fi
  echo "═══ Session History ═══"
  for f in "$SESSION_DIR"/*.md; do
    local date_str
    date_str=$(basename "$f" .md)
    local count
    count=$(grep -c '^|' "$f" 2>/dev/null || echo 0)
    echo "  $date_str ($count entries)"
  done | sort
}

action_view() {
  local date_arg="${1:-$TODAY}"
  local file="$SESSION_DIR/$date_arg.md"
  if [ -f "$file" ]; then
    cat "$file"
  else
    echo "No session for $date_arg"
  fi
}

main() {
  local cmd="${1:-help}"
  shift 2>/dev/null || true

  case "$cmd" in
    save)   action_save "$*" ;;
    list)   action_list ;;
    view)   action_view "$*" ;;
    *)      echo "Usage: session.sh save <summary> | list | view [date]" ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
