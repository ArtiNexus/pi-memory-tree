#!/usr/bin/env bash
# pi-memory: Agent memory management (Hermes Agent inspired)
# Usage: memory.sh <action> <target> [args...]

set -euo pipefail

MEMORY_DIR="$HOME/.pi/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
USER_FILE="$MEMORY_DIR/USER.md"
MEMORY_LIMIT=2200
USER_LIMIT=1375

show_usage() {
  echo "Usage:"
  echo "  add <memory|user> <content>              # Add entry"
  echo "  replace <memory|user> <old> <new>         # Replace by substring"
  echo "  remove <memory|user> <substring>          # Remove by substring"
  echo "  list <memory|user>                        # List entries"
  echo "  show <memory|user>                        # Show raw file"
  echo "  search <query>                            # Search memory + sessions"
}

get_file() {
  case "$1" in
    memory) echo "$MEMORY_FILE" ;;
    user)   echo "$USER_FILE" ;;
    *)      echo "bad_target" ;;
  esac
}

get_limit() {
  case "$1" in
    memory) echo "$MEMORY_LIMIT" ;;
    user)   echo "$USER_LIMIT" ;;
  esac
}

# Read entries (non-header, non-§, non-empty lines)
read_entries() {
  local file="$1"
  sed -n '4,$ p' "$file" | grep -v '^§$' | grep -v '^$' || true
}

# Count actual content size (chars in entries only)
content_size() {
  local file="$1"
  read_entries "$file" | wc -c | tr -d ' '
}

# Update the header line with current usage
update_header() {
  local file="$1"
  local limit="$2"
  local size
  size=$(content_size "$file")
  local pct=$((size * 100 / limit))
  # Header on line 2. The file has commas in large numbers (e.g. 2,200).
  # Match any number format and replace with the current size.
  sed -i '' "2s|\[[0-9]*% — [-,0-9]*/[-,0-9]* chars\]|[$pct% — $size/$limit chars]|" "$file"
}

# Check if content already exists (exact duplicate check)
has_duplicate() {
  local file="$1"
  local content="$2"
  read_entries "$file" | grep -qF "$content" 2>/dev/null
}

# Security check — filter sensitive patterns
security_check() {
  local content="$1"
  # Block patterns that look like secrets
  local sensitive_patterns=(
    'sk-[A-Za-z0-9]{20,}'     # OpenAI/DeepSeek API keys
    'api[_-]?key[=: ][A-Za-z0-9]{16,}'
    'AKIA[0-9A-Z]{16}'         # AWS Access Key
    '-----BEGIN.*PRIVATE KEY-----'  # Private keys
    'ghp_[A-Za-z0-9]{36}'      # GitHub PAT (old)
    'github_pat_[A-Za-z0-9]{36,}'  # GitHub PAT (new)
    'password[=: ][^ ]{6,}'
  )
  for pattern in "${sensitive_patterns[@]}"; do
    if echo "$content" | grep -qiE "$pattern" 2>/dev/null; then
      echo "WARN: 内容包含敏感信息 (匹配: $pattern)，已阻止保存"
      echo "如需保存，请先去除敏感信息后再试"
      return 1
    fi
  done
  return 0
}

action_add() {
  local target="$1"; shift
  local content="$*"
  local file; file=$(get_file "$target")
  local limit; limit=$(get_limit "$target")

  if [ "$file" = "bad_target" ]; then echo "Error: target must be 'memory' or 'user'"; exit 1; fi
  if [ -z "$content" ]; then echo "Error: content cannot be empty"; exit 1; fi

  # Security check
  if ! security_check "$content"; then
    return 1
  fi

  # Duplicate check
  if has_duplicate "$file" "$content"; then
    echo "OK: No duplicate added (entry already exists)"
    return 0
  fi

  # Capacity check
  local cur_size
  cur_size=$(content_size "$file")
  local new_size=$((cur_size + ${#content} + 2))
  if [ "$new_size" -gt "$limit" ]; then
    local pct=$((cur_size * 100 / limit))
    echo "Error: Memory at $cur_size/$limit chars ($pct%). Adding would exceed limit. Consolidate first."
    echo "Entries:"
    list_entries "$file"
    return 1
  fi

  # Append new entry
  echo "§" >> "$file"
  echo "$content" >> "$file"
  update_header "$file" "$limit"
  echo "OK: Added to $target"
}

action_replace() {
  local target="$1"; shift
  local old_text="$1"; shift
  local content="$*"
  local file; file=$(get_file "$target")
  local limit; limit=$(get_limit "$target")

  if [ "$file" = "bad_target" ]; then echo "Error: target must be 'memory' or 'user'"; exit 1; fi

  # Find matching line (must match exactly one)
  local matches=0 match_line=""
  while IFS= read -r line; do
    if echo "$line" | grep -qF "$old_text"; then
      matches=$((matches + 1))
      match_line="$line"
    fi
  done < <(read_entries "$file")

  if [ "$matches" -eq 0 ]; then echo "Error: No entry matches '$old_text'"; return 1; fi
  if [ "$matches" -gt 1 ]; then echo "Error: '$old_text' matches $matches entries. Be more specific."; return 1; fi

  # Escape for sed
  local escaped_old
  escaped_old=$(printf '%s\n' "$match_line" | sed 's/[\/&]/\\&/g')
  local escaped_new
  escaped_new=$(printf '%s\n' "$content" | sed 's/[\/&]/\\&/g')

  sed -i '' "s/^$escaped_old\$/$escaped_new/" "$file"
  update_header "$file" "$limit"
  echo "OK: Replaced in $target"
}

action_remove() {
  local target="$1"; shift
  local old_text="$1"
  local file; file=$(get_file "$target")
  local limit; limit=$(get_limit "$target")

  if [ "$file" = "bad_target" ]; then echo "Error: target must be 'memory' or 'user'"; exit 1; fi

  # Find matching line
  local matches=0 match_line=""
  while IFS= read -r line; do
    if echo "$line" | grep -qF "$old_text"; then
      matches=$((matches + 1))
      match_line="$line"
    fi
  done < <(read_entries "$file")

  if [ "$matches" -eq 0 ]; then echo "Error: No entry matches '$old_text'"; return 1; fi
  if [ "$matches" -gt 1 ]; then echo "Error: '$old_text' matches $matches entries. Be more specific."; return 1; fi

  # Get line number in the file
  local line_num
  line_num=$(grep -nF "$match_line" "$file" | head -1 | cut -d: -f1)

  # Remove the entry line and the § before it
  # The § is either at line_num-1 (before the entry) or line_num+? depends
  # Remove entry line first
  sed -i '' "${line_num}d" "$file"

  # Now remove the § that's closest (it was at line_num-1 in original)
  # After the d, the § is at line_num-1 in the modified file (if it was before)
  local prev_line=$((line_num - 1))
  local prev_content
  prev_content=$(sed -n "${prev_line}p" "$file")
  if [ "$prev_content" = "§" ]; then
    sed -i '' "${prev_line}d" "$file"
  fi

  update_header "$file" "$limit"
  echo "OK: Removed from $target"
}

list_entries() {
  local file="$1"
  local count=1
  while IFS= read -r line; do
    echo "  [$count] $line"
    count=$((count + 1))
  done < <(read_entries "$file")
}

action_list() {
  local target="$1"
  local file; file=$(get_file "$target")
  local limit; limit=$(get_limit "$target")
  local size; size=$(content_size "$file")

  echo "═══ $target ($size/$limit chars, $((size * 100 / limit))%) ═══"
  list_entries "$file"
}

action_show() {
  local file; file=$(get_file "$1")
  cat "$file"
}

action_search() {
  local query="$*"
  echo "─── Searching memory files ───"
  while IFS= read -r line; do
    if echo "$line" | grep -qi "$query"; then
      echo "  MEMORY: $line"
    fi
  done < <(read_entries "$MEMORY_FILE")
  while IFS= read -r line; do
    if echo "$line" | grep -qi "$query"; then
      echo "  USER: $line"
    fi
  done < <(read_entries "$USER_FILE")

  local sdir="$MEMORY_DIR/sessions"
  if [ -d "$sdir" ]; then
    echo ""
    echo "─── Session matches ───"
    for sf in "$sdir"/*.md; do
      [ -f "$sf" ] || continue
      local date_s
      date_s=$(basename "$sf" .md)
      local matches
      matches=$(grep -in "$query" "$sf" 2>/dev/null || true)
      if [ -n "$matches" ]; then
        echo "  $date_s:"
        echo "$matches" | sed 's/^/    /'
      fi
    done
  fi
}

main() {
  if [ $# -lt 1 ]; then show_usage; exit 1; fi
  local action="$1"; shift

  case "$action" in
    add)     [ $# -lt 2 ] && { show_usage; exit 1; } ; action_add "$1" "${@:2}" ;;
    replace) [ $# -lt 3 ] && { show_usage; exit 1; } ; action_replace "$1" "$2" "${@:3}" ;;
    remove)  [ $# -lt 2 ] && { show_usage; exit 1; } ; action_remove "$1" "$2" ;;
    list|ls) action_list "$1" ;;
    show|cat) action_show "$1" ;;
    search)  action_search "$*" ;;
    *)       show_usage; exit 1 ;;
  esac
}

# Only run main if executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
