#!/usr/bin/env bash
# session_search.sh — Full-text search across all session history
# Phase 1 of Hermes-inspired memory upgrades
#
# Usage:
#   session_search.sh <query>                     # Search all sessions
#   session_search.sh <query> --date YYYY-MM-DD   # Search specific date
#   session_search.sh <query> --last N            # Search last N sessions
#   session_search.sh --list                      # List available sessions
#   session_search.sh --stats                     # Show session statistics

set -euo pipefail

MEMORY_DIR="$HOME/.pi/memory"
SESSION_DIR="$MEMORY_DIR/sessions"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

show_usage() {
  echo "Usage:"
  echo "  session_search.sh <query>                    # Search all sessions"
  echo "  session_search.sh <query> --date YYYY-MM-DD  # Search specific date"
  echo "  session_search.sh <query> --last N           # Search last N sessions"
  echo "  session_search.sh --list                     # List available sessions"
  echo "  session_search.sh --stats                    # Session statistics"
  echo "  session_search.sh --help                     # This help"
}

# Build a grep pattern that handles multi-word queries with AND logic
build_grep_pattern() {
  local query="$1"
  # Replace spaces with regex to match lines containing ALL words
  # Use lookahead if available, else pipe through multiple greps
  echo "$query" | sed 's/ /.*/g'
}

search_sessions() {
  local query="$1"
  local date_filter="${2:-}"
  local last_n="${3:-0}"

  if [ -z "$query" ]; then
    echo "Error: query cannot be empty"
    exit 1
  fi

  local results=0
  local total_matches=0
  local match_details=()

  # Collect session files
  local files=()
  if [ -n "$date_filter" ]; then
    local f="$SESSION_DIR/$date_filter.md"
    if [ -f "$f" ]; then
      files+=("$f")
    else
      echo -e "${RED}❌ No session found for $date_filter${NC}"
      exit 1
    fi
  else
    while IFS= read -r f; do
      files+=("$f")
    done < <(ls -t "$SESSION_DIR"/*.md 2>/dev/null || true)
  fi

  # If --last N, take only the N most recent
  if [ "$last_n" -gt 0 ] && [ "${#files[@]}" -gt "$last_n" ]; then
    files=("${files[@]:0:$last_n}")
  fi

  if [ "${#files[@]}" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No session files found in $SESSION_DIR${NC}"
    return 1
  fi

  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  🔍 Session Search: \"$query\"${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo ""

  for f in "${files[@]}"; do
    local date_str
    date_str=$(basename "$f" .md)
    local title
    title=$(head -1 "$f" 2>/dev/null | sed 's/^# Session: //' || echo "Untitled")

    # Split query into words for AND matching across multiple greps
    local terms=($query)
    local matches

    # Use chained grep for AND search
    if [ "${#terms[@]}" -gt 1 ]; then
      matches=$(grep -in -B 1 -A 2 -i "${terms[0]}" "$f" 2>/dev/null || true)
      for ((i=1; i<${#terms[@]}; i++)); do
        local term="${terms[$i]}"
        if [ -n "$matches" ]; then
          matches=$(echo "$matches" | grep -i "$term" 2>/dev/null || true)
        fi
      done
    else
      matches=$(grep -in -B 1 -A 2 -i "$query" "$f" 2>/dev/null || true)
    fi

    if [ -n "$matches" ]; then
      local count
      count=$(echo "$matches" | grep -ic "$query" 2>/dev/null || echo 1)
      total_matches=$((total_matches + count))
      results=$((results + 1))

      echo -e "${YELLOW}📅 $date_str — $title (${count} matches)${NC}"

      # Display context with highlighting
      local line_num=0
      while IFS= read -r line; do
        line_num=$((line_num + 1))
        if echo "$line" | grep -qi "$query"; then
          # Highlight the matched term in the line
          local highlighted
          highlighted=$(echo "$line" | sed "s/$query/\\${GREEN}&\\${NC}/gi" 2>/dev/null || echo "$line")
          echo -e "  ${GREEN}▶${NC} $highlighted"
        elif [ -n "$line" ] && ! echo "$line" | grep -qE '^--$'; then
          echo -e "  ${BLUE}│${NC} $line"
        fi
      done <<< "$matches"
      echo ""
    fi
  done

  if [ "$results" -eq 0 ]; then
    echo -e "  ${RED}✗ No matches found${NC}"
    echo ""
    echo "  💡 Suggestions:"
    echo "  - Try different keywords"
    echo "  - Try 'memory.sh search <keyword>' to search MEMORY.md/USER.md"
    echo "  - List all sessions: session_search.sh --list"
    return 1
  else
    echo -e "${GREEN}✅ Found $total_matches matches across $results session(s)${NC}"
  fi
}

list_sessions() {
  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  📋 All Session Records${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo ""

  local total=0
  local total_entries=0

  for f in $(ls -t "$SESSION_DIR"/*.md 2>/dev/null || true); do
    [ -f "$f" ] || continue
    local date_str
    date_str=$(basename "$f" .md)
    local entries
    entries=$(grep -c '^|' "$f" 2>/dev/null || echo 0)
    local title
    title=$(head -1 "$f" 2>/dev/null | sed 's/^# Session: //' || echo "Untitled")
    local first_entry
    first_entry=$(grep '^|' "$f" 2>/dev/null | head -1 || true)

    total=$((total + 1))
    total_entries=$((total_entries + entries))

    echo -e "  ${GREEN}📅${NC} ${YELLOW}$date_str${NC} — $title"
    echo -e "     ${BLUE}├─${NC} Entries: $entries"
    if [ -n "$first_entry" ]; then
      echo -e "     ${BLUE}└─${NC} Latest: $(echo "$first_entry" | sed 's/^|//' | sed 's/|.*//' | xargs)"
    fi
    echo ""
  done

  if [ "$total" -eq 0 ]; then
    echo -e "  ${YELLOW}No session files yet.${NC}"
    echo "  Sessions are created when you use: session.sh save"
  else
    echo -e "${GREEN}📊 Total: $total sessions, $total_entries entries${NC}"
  fi
}

show_stats() {
  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo -e "${CYAN}  📊 Session Statistics${NC}"
  echo -e "${CYAN}══════════════════════════════════════════════${NC}"
  echo ""

  local total_sessions=0
  local total_entries=0
  local total_chars=0
  local first_date=""
  local last_date=""

  for f in $(ls -t "$SESSION_DIR"/*.md 2>/dev/null || true); do
    [ -f "$f" ] || continue
    local date_str
    date_str=$(basename "$f" .md)
    local entries
    entries=$(grep -c '^|' "$f" 2>/dev/null || echo 0)
    local chars
    chars=$(wc -c < "$f" | tr -d ' ')

    total_sessions=$((total_sessions + 1))
    total_entries=$((total_entries + entries))
    total_chars=$((total_chars + chars))

    [ -z "$first_date" ] && first_date="$date_str"
    last_date="$date_str"
  done

  echo -e "  ${YELLOW}Session span:${NC}     $first_date → $last_date"
  echo -e "  ${YELLOW}Total sessions:${NC}   $total_sessions"
  echo -e "  ${YELLOW}Total entries:${NC}    $total_entries"
  echo -e "  ${YELLOW}Total size:${NC}       $total_chars chars"
  echo ""

  # MEMORY.md and USER.md stats
  if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
    local mem_size
    mem_size=$(wc -c < "$MEMORY_DIR/MEMORY.md" | tr -d ' ')
    echo -e "  ${BLUE}MEMORY.md:${NC}        $mem_size chars (limit: 2200)"
  fi
  if [ -f "$MEMORY_DIR/USER.md" ]; then
    local user_size
    user_size=$(wc -c < "$MEMORY_DIR/USER.md" | tr -d ' ')
    echo -e "  ${BLUE}USER.md:${NC}          $user_size chars (limit: 1375)"
  fi
  if [ -f "$MEMORY_DIR/WATCH.md" ]; then
    local watch_size
    watch_size=$(wc -c < "$MEMORY_DIR/WATCH.md" | tr -d ' ')
    echo -e "  ${BLUE}WATCH.md:${NC}        $watch_size chars (limit: ~500)"
  fi
}

main() {
  if [ $# -lt 1 ]; then show_usage; exit 1; fi

  case "$1" in
    --list|-l)  list_sessions ;;
    --stats|-s) show_stats ;;
    --help|-h)  show_usage ;;
    *)
      local query="$1"
      shift
      local date_filter=""
      local last_n=0

      while [ $# -gt 0 ]; do
        case "$1" in
          --date|-d)   date_filter="$2"; shift 2 ;;
          --last|-n)   last_n="$2"; shift 2 ;;
          *) echo "Unknown option: $1"; show_usage; exit 1 ;;
        esac
      done

      search_sessions "$query" "$date_filter" "$last_n"
      ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
