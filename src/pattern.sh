#!/usr/bin/env bash
# pattern.sh — Pattern recognition for self-improvement loop
# Phase 2 of Hermes-inspired memory upgrades
#
# When the agent notices a recurring pattern (same type of request/task
# appearing 2+ times), it can save it as a reusable "pattern" for future use.
#
# Usage:
#   pattern.sh add <category> <title> <description>    # Add a new pattern
#   pattern.sh list [category]                          # List patterns
#   pattern.sh search <query>                           # Search patterns
#   pattern.sh suggest <query>                          # Suggest matching patterns
#   pattern.sh remove <title>                           # Remove a pattern
#   pattern.sh stats                                    # Pattern statistics

set -euo pipefail

PATTERNS_DIR="$HOME/.pi/memory/patterns"
PATTERNS_FILE="$PATTERNS_DIR/patterns.md"

ensure_file() {
  mkdir -p "$PATTERNS_DIR"
  if [ ! -f "$PATTERNS_FILE" ]; then
    cat > "$PATTERNS_FILE" << 'EOF'
# 🧩 可复用模式库 (Pattern Library)
>
> 小皮自动管理的模式记忆。当某个操作重复出现时，自动保存为可复用的模式。
> 每次会话开始时加载，让小皮越来越聪明。

---

## 模式格式

每条模式包含：
- **类别**：工作流 / 技术栈 / 偏好 / 解决方案 / 其他
- **标题**：简短描述
- **触发条件**：什么情况下使用这个模式
- **步骤**：具体操作
- **来源会话**：首次发现的日期

---

EOF
  fi
}

show_usage() {
  echo "Usage:"
  echo "  pattern.sh add <category> <title> <description>     # Add pattern"
  echo "  pattern.sh list [category]                          # List patterns"
  echo "  pattern.sh search <query>                           # Search patterns"
  echo "  pattern.sh remove <title>                           # Remove pattern"
  echo "  pattern.sh stats                                    # Statistics"
  echo ""
  echo "Categories: workflow | tech | preference | solution | other"
  echo ""
  echo "Example:"
  echo '  pattern.sh add workflow "Code Review流程" "每次PR提交后，先跑lint→再跑test→再review"'
}

action_add() {
  ensure_file
  local category="$1"
  local title="$2"
  shift 2
  local description="$*"
  local date_str
  date_str=$(date "+%Y-%m-%d")

  # Validate category
  case "$category" in
    workflow|tech|preference|solution|other) ;;
    *) echo "Error: invalid category. Valid: workflow, tech, preference, solution, other"; exit 1 ;;
  esac

  # Check for duplicate
  if grep -q "### $title" "$PATTERNS_FILE" 2>/dev/null; then
    echo "OK: Pattern '$title' already exists (no duplicate added)"
    return 0
  fi

  # Append pattern
  cat >> "$PATTERNS_FILE" << EOF

### $title

| 属性 | 值 |
|:----|:----|
| **类别** | $category |
| **发现日期** | $date_str |
| **描述** | $description |

EOF

  echo "OK: Pattern '$title' added [$category]"
}

action_list() {
  ensure_file
  local filter="${1:-}"

  local count=0
  while IFS= read -r line; do
    if echo "$line" | grep -q "^### "; then
      local title
      title=$(echo "$line" | sed 's/^### //')
      if [ -z "$filter" ] || grep -qF "| **类别** | $filter" <(sed -n "/^### $title/,/^###/p" "$PATTERNS_FILE" 2>/dev/null); then
        local cat_val
        cat_val=$(grep -A 10 "^### $title" "$PATTERNS_FILE" | grep "类别" | sed 's/.*| //' | sed 's/ |//' || echo "unknown")
        echo "  📌 $title [$cat_val]"
        count=$((count + 1))
      fi
    fi
  done < "$PATTERNS_FILE"

  if [ "$count" -eq 0 ]; then
    echo "No patterns found${filter:+ for category '$filter'}."
    echo "Patterns are auto-created when the agent detects recurring patterns."
  else
    echo ""
    echo "Total: $count patterns${filter:+ in '$filter'}"
  fi
}

action_search() {
  ensure_file
  local query="$*"
  local matches
  matches=$(grep -i -B 2 -A 6 "$query" "$PATTERNS_FILE" 2>/dev/null || true)

  if [ -z "$matches" ]; then
    echo "No patterns match '$query'"
    return 1
  fi

  echo "═══ Pattern search: '$query' ═══"
  echo ""
  while IFS= read -r line; do
    if echo "$line" | grep -q "^### "; then
      echo -e "\033[1;33m$(echo "$line" | sed 's/^### /📌 /')\033[0m"
    else
      echo "  $line"
    fi
  done <<< "$matches"
}

action_remove() {
  ensure_file
  local title="$1"

  if ! grep -q "^### $title" "$PATTERNS_FILE" 2>/dev/null; then
    echo "Error: No pattern matches '$title'"
    return 1
  fi

  # Use sed to remove the pattern block
  sed -i '' "/^### $title/,/^###/{
    /^### $title/d
    /^###/!d
  }" "$PATTERNS_FILE"

  # Clean up extra blank lines
  sed -i '' '/^$/{ N; /^\n$/d; }' "$PATTERNS_FILE"

  echo "OK: Removed pattern '$title'"
}

action_stats() {
  ensure_file
  local total
  total=$(grep -c "^### " "$PATTERNS_FILE" 2>/dev/null || true)
  total=${total%%[!0-9]*}
  total=${total:-0}
  local size
  size=$(wc -c < "$PATTERNS_FILE" | tr -d ' ')

  echo "═══ Pattern Library Stats ═══"
  echo ""
  echo "  Total patterns: $total"
  echo "  File size: $size chars"

  if [ "$total" -gt 0 ]; then
    echo ""
    echo "  By category:"
    for cat in workflow tech preference solution other; do
      local ccount
      ccount=$(grep -cF "| **类别** | $cat" "$PATTERNS_FILE" 2>/dev/null || true)
      ccount=${ccount:-0}
      if [ "$ccount" -gt 0 ] 2>/dev/null; then
        echo "    $cat: $ccount"
      fi
    done
  fi
}

main() {
  if [ $# -lt 1 ]; then show_usage; exit 1; fi

  case "$1" in
    add)     [ $# -lt 3 ] && { show_usage; exit 1; } ; action_add "$2" "$3" "${@:4}" ;;
    list|ls) action_list "${2:-}" ;;
    search)  shift; action_search "$*" ;;
    remove|rm) [ $# -lt 2 ] && { show_usage; exit 1; } ; action_remove "$2" ;;
    stats)   action_stats ;;
    --help|-h) show_usage ;;
    *)       show_usage; exit 1 ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
