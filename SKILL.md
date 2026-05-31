---
name: pi-memory-tree
description: Three-layer hierarchical memory system for AI coding agents. Extends flat memory into a scalable tree with Focus (WATCH.md) → Index (MEMORY.md) → Detail branches (Level 1+N). Provides scripts for memory CRUD, cross-session search, raw transcript search, pattern recognition, and auto-consolidation. Use when your agent needs persistent, structured, infinitely-scalable memory with guaranteed recall. Trigger: "memory too big", "memory tree", "hierarchical memory", "persistent memory", "remember past conversations".
compatibility: pi + pi-memory skill
---

# 🌳 pi-memory-tree — Hierarchical Memory System

A filesystem-native, infinitely scalable hierarchical memory system for AI coding agents.
Built on top of the pi-memory skill.

## Architecture

```
  Layer F (always loaded)     Level 0 (always loaded)     Level 1..N (on demand)
  ┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
  │   WATCH.md        │        │   MEMORY.md       │        │ MEMORY1_sem.md   │
  │  Current focus    │───────▶│  Keyword index    │───────▶│ Environment       │
  │  ~500 chars       │        │  "Daemon→MEMORY2" │        │ MEMORY2_epi.md   │
  └──────────────────┘        └──────────────────┘        │ Daemon timeline   │
                                                           │ MEMORY3_pro.md    │
                                                           │ Tool manuals      │
                                                           └──────────────────┘
```

## Prerequisites

- **pi-memory skill** — provides `memory.sh`, `session.sh`, `pattern.sh` scripts.
  (The scripts in this skill's `scripts/` directory are copies; install whichever is newer.)

## Setup

### 1. Quick install

```bash
git clone https://github.com/ArtiNexus/pi-memory-tree.git ~/.pi/agent/skills/pi-memory-tree
bash ~/.pi/agent/skills/pi-memory-tree/install.sh
```

Or symlink for development:

```bash
git clone https://github.com/ArtiNexus/pi-memory-tree.git ~/dev/pi-memory-tree
ln -s ~/dev/pi-memory-tree ~/.pi/agent/skills/pi-memory-tree
```

### 2. Manual setup

```bash
# Create memory directories
mkdir -p ~/.pi/memory/{patterns,sessions}

# Copy scripts
cp scripts/*.sh ~/.pi/skills/pi-memory/scripts/
chmod +x ~/.pi/skills/pi-memory/scripts/*.sh

# Initialize memory tree
cp templates/WATCH_TEMPLATE.md ~/.pi/memory/WATCH.md
cp templates/LEVEL0_INDEX_TEMPLATE.md ~/.pi/memory/MEMORY.md

# Copy auto-execution protocol
cp AGENTS.md ~/.pi/agent/
```

### 3. Activate

Start a new pi session. The agent will:
1. Load `WATCH.md` (focus board) + `MEMORY.md` (keyword index) + `USER.md` (profile)
2. Preload Level 1 files linked from WATCH.md priorities
3. Save every Q&A pair to session logs
4. Cascade recall: memory tree → session summaries → raw transcripts

## Usage

### Core commands

```bash
# Add memory
~/.pi/skills/pi-memory/scripts/memory.sh add memory "[P0] <fact>"
~/.pi/skills/pi-memory/scripts/memory.sh add user "<preference>"

# Session logging (auto, every Q&A)
~/.pi/skills/pi-memory/scripts/session.sh save "<问: xxx> → <答: yyy>"

# Search session summaries
~/.pi/skills/pi-memory/scripts/session_search.sh "<keyword>"

# Search raw transcripts (guaranteed find)
~/.pi/agent/skills/pi-memory-tree/scripts/raw_search.sh "<keyword>"

# Pattern recognition
~/.pi/skills/pi-memory/scripts/pattern.sh add workflow "<title>" "<desc>"
~/.pi/skills/pi-memory/scripts/pattern.sh list

# Health check
~/.pi/skills/pi-memory/scripts/consolidate_memory.sh
```

### Capacity rules

| File | Max | Overflow |
|:-----|:---:|:---------|
| WATCH.md | ~500 chars | Remove oldest topics |
| MEMORY.md | ~2200 chars | Compact or fork |
| MEMORY*_{type}.md | ~2200 chars each | Create new file (no compression) |
| USER.md | 1375 chars | Consolidate |

## Contents

```
pi-memory-tree/
├── SKILL.md                    ← This file (pi skill entry point)
├── AGENTS.md                   ← Auto-execution protocol
├── README.md                   ← GitHub project page
├── install.sh                  ← One-command setup
├── LICENSE                     ← MIT
├── scripts/                    ← Shell scripts (7 files)
│   ├── memory.sh               Core CRUD
│   ├── session.sh              Session logging
│   ├── session_search.sh       Summary search
│   ├── raw_search.sh           Raw transcript search
│   ├── pattern.sh              Pattern management
│   └── consolidate_memory.sh   Health checks
├── templates/                  ← Starter templates (4 files)
│   ├── WATCH_TEMPLATE.md
│   ├── LEVEL0_INDEX_TEMPLATE.md
│   ├── LEVEL1_DETAIL_TEMPLATE.md
│   └── AGENTS_PROTOCOL.md
├── examples/                   ← Example files (10 files)
│   └── MEMORY.md, MEMORY1_sem.md, ...
└── docs/                       ← Documentation (3 files)
    ├── ARCHITECTURE.md
    ├── COMPARISON.md
    └── QUICKSTART.md
```

## Design Inspirations

- **Hermes Agent (Nous Research)**: Persistent agent memory as a first-class system
- **MemGPT/Letta**: Core memory + external storage layering
- **LangMem**: Three memory types — semantic, episodic, procedural
- **Zep**: Timestamp tracking and temporal knowledge graphs
- **File system hierarchy**: Tree branching mirrors directory nesting

## License

MIT
