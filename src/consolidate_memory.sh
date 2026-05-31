#!/usr/bin/env bash
# consolidate_memory.sh — 自动记忆检查与整合
# 由 Daemon scheduler 每日定时调用
#
# 功能:
# 1. 检查所有 Level 1 文件的容量状态
# 2. 如果 >80% 则触发整合提醒
# 3. 检查 INDEX.md 关键词是否需要补充
# 4. 记录检查结果到会话日志

set -euo pipefail

MEMORY_DIR="$HOME/.pi/memory"
MEMORY_SH="$HOME/.pi/skills/pi-memory/scripts/memory.sh"
SESSION_SH="$HOME/.pi/skills/pi-memory/scripts/session.sh"
DATE_TAG=$(date "+%Y-%m-%d %H:%M")

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "══════════════════════════════════════════════"
echo "  小皮 记忆整合检查 — $DATE_TAG"
echo "══════════════════════════════════════════════"

issues=0
consolidated=0

# 检查所有 Level 1 文件
echo ""
echo "📂 扫描 Level 1 文件..."
for f in "$MEMORY_DIR"/MEMORY*_*.md; do
  [ -f "$f" ] || continue
  fname=$(basename "$f")
  [ "$fname" = "MEMORY_TEMPLATE.md" ] && continue
  
  size=$(wc -c < "$f" | tr -d ' ')
  pct=$((size * 100 / 2000))
  
  if [ "$pct" -ge 90 ]; then
    echo -e "  ${RED}🔴 $fname: ${size}chars (${pct}%) — 接近上限，建议分叉${NC}"
    consolidated=$((consolidated + 1))
    issues=$((issues + 1))
  elif [ "$pct" -ge 80 ]; then
    echo -e "  ${YELLOW}🟡 $fname: ${size}chars (${pct}%) — 注意容量${NC}"
    issues=$((issues + 1))
  else
    echo -e "  ${GREEN}✅ $fname: ${size}chars (${pct}%)${NC}"
  fi
done

# 检查 INDEX.md 是否有空引用
echo ""
echo "📋 验证 INDEX.md 引用..."
miss_ref=0
for target in $(grep -o 'MEMORY[^ ]*' "$MEMORY_DIR/MEMORY.md" | grep -v 'MEMORY_TEMPLATE\|MEMORY{N}\|MEMORY\*\|\.\.\.' | tr -d '`|' | sort -u); do
  # 去掉可能附带的 .md 后缀
  tclean=$(echo "$target" | sed 's/\.md$//')
  if [ ! -f "$MEMORY_DIR/${tclean}.md" ]; then
    if echo "$tclean" | grep -qE '^MEMORY[0-9]'; then
      echo -e "  ${RED}❌ ${tclean}.md → 引用的文件不存在${NC}"
      miss_ref=$((miss_ref + 1))
    fi
  fi
done
[ "$miss_ref" -eq 0 ] && echo -e "  ${GREEN}✅ 所有引用有效${NC}"

# 记录结果
if [ "$issues" -gt 0 ]; then
  bash "$SESSION_SH" save "🔔 记忆整合检查: $issues 个文件需关注 ($consolidated 个接近分叉线)"
  echo ""
  echo -e "${YELLOW}⚠️  $issues 个文件需要注意${NC}"
else
  bash "$SESSION_SH" save "✅ 记忆整合检查: 所有文件容量正常"
  echo ""
  echo -e "${GREEN}✅ 所有文件容量正常${NC}"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  检查完成"
echo "══════════════════════════════════════════════"
