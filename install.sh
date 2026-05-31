#!/usr/bin/env bash
# pi-memory-tree — Installer
# Usage: bash install.sh [--prefix ~/.pi]

set -euo pipefail

PREFIX="${1:-$HOME/.pi}"
SCRIPTS_DIR="$PREFIX/skills/pi-memory/scripts"
MEMORY_DIR="$PREFIX/memory"
AGENT_DIR="$PREFIX/agent"

echo "══════════════════════════════════════════════"
echo "  🌳 pi-memory-tree — Installing"
echo "══════════════════════════════════════════════"
echo ""
echo "  Target: $PREFIX"

# Create directories
mkdir -p "$SCRIPTS_DIR" "$MEMORY_DIR/patterns" "$MEMORY_DIR/sessions" "$AGENT_DIR"

# Copy scripts
echo ""
echo "  📦 Copying scripts..."
for script in scripts/*.sh; do
  cp "$script" "$SCRIPTS_DIR/"
  chmod +x "$SCRIPTS_DIR/$(basename "$script")"
  echo "    ✅ $(basename "$script")"
done

# Copy AGENTS.md
echo ""
echo "  📄 Copying AGENTS.md..."
cp AGENTS.md "$AGENT_DIR/"
echo "    ✅ AGENTS.md"

# Copy templates
echo ""
echo "  📐 Copying templates..."
cp template/MEMORY_TEMPLATE.md "$MEMORY_DIR/"
echo "    ✅ MEMORY_TEMPLATE.md"
cp template/WATCH_TEMPLATE.md "$MEMORY_DIR/"
echo "    ✅ WATCH_TEMPLATE.md"

# Initialize WATCH.md if not exists (copy from template)
if [ ! -f "$MEMORY_DIR/WATCH.md" ]; then
  cp template/WATCH_TEMPLATE.md "$MEMORY_DIR/WATCH.md"
  echo "    ✅ WATCH.md initialized from template"
fi

# Initialize MEMORY.md if not exists
if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
  echo ""
  echo "  📝 Initializing MEMORY.md..."
  cat > "$MEMORY_DIR/MEMORY.md" << 'INITEOF'
# 🧠 Memory Index (Level 0)

> Keyword lookup table. Loaded at every session start.
> For details, load the mapped file by topic.

---

## Keywords → File Mapping

| Keyword | File | Priority | Summary |
|:--------|:-----|:--------:|:--------|
| *(Add your first keyword here)* | MEMORY1 | 🔴P0 | — |

## File Status

| File | Type | Size | Status |
|:-----|:-----|:----:|:------|

## Usage

```bash
# Load detail
cat ~/.pi/memory/MEMORY1_sem.md

# Search everything
grep -ri "keyword" ~/.pi/memory/MEMORY*.md
```
INITEOF
  echo "    ✅ MEMORY.md initialized"
fi

# Initialize patterns.md if not exists
if [ ! -f "$MEMORY_DIR/patterns/patterns.md" ]; then
  cat > "$MEMORY_DIR/patterns/patterns.md" << 'PATEOF'
# 🧩 Pattern Library

> Reusable patterns discovered by the agent over time.
> Loaded at every session start.

---

*(Patterns are auto-created when the agent detects recurring behavior)*

## Usage

```bash
pattern.sh add workflow "Pattern Title" "Description"
pattern.sh list
pattern.sh search "keyword"
```
PATEOF
  echo "    ✅ patterns.md initialized"
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  ✅ Installation complete!"
echo ""
echo "  📂 Scripts:  $SCRIPTS_DIR"
echo "  📂 Memory:   $MEMORY_DIR"
echo "  📂 Config:   $AGENT_DIR"
echo ""
echo "  🚀 Start your next Pi session to activate."
echo "══════════════════════════════════════════════"
