# 🌳 pi-memory-tree — Hierarchical Agent Memory

A **filesystem-native, infinitely scalable hierarchical memory system** for AI coding agents.

Unlike flat two-file systems (Hermes), vector databases (Mem0), or virtual memory management (Letta), pi-memory-tree organizes agent memory as a **knowledge tree** — keywords index → detail files → sub-branches, growing naturally as knowledge accumulates.

```
  Layer F (always loaded) — What to focus on
  ┌──────────────────────┐
  │     WATCH.md          │ ← Current focus topics
  │  "Daemon → 待启动"    │    drives smart loading
  └──────────┬───────────┘
             │
             ▼
  Level 0 (always loaded) — Where to find it
  ┌──────────────────────┐
  │     MEMORY.md         │ ← Keywords → file mapping
  │  "Daemon → MEMORY2"   │
  └──────────┬───────────┘
             │
    ┌────────┼────────────┐
    ▼        ▼            ▼
 ┌────────┐┌────────┐┌────────┐
 │MEMORY1 ││MEMORY2 ││MEMORY3 │  Level 1 (on-demand)
 │_sem.md ││_epi.md ││_pro.md │
 │环境配置 ││ Daemon  ││ 工具集  │
 └───┬────┘└────────┘└───┬────┘
     │                   │
     ▼                   ├──────────┐
 ┌────────┐             ▼          ▼
 │MEMORY1│          ┌────────┐ ┌────────┐
 │-1_sem │          │MEMORY3 │ │MEMORY3 │  Level 2+
 │开发工具│          │-1_pro  │ │-2_pro  │
 └───────┘          │ search │ │pattern │
                    └────────┘ └────────┘
```

## ✨ Features

| Feature | Description |
|:--------|:------------|
| 🏗️ **Hierarchical Tree** | Keywords index (Level 0) → detail files (Level 1) → sub-branches (Level 2+) |
| ♾️ **Infinite Scale** | No capacity limit — new files grow like tree branches |
| ⚡ **Lazy Loading** | Only the index is loaded at session start; details loaded on demand |
| 👁️ **Focus Layer** | `WATCH.md` — a compact ~500 char board of current priorities, driving smart Level 1 preloading |
| 🔗 **Cross-Branch Links** | Each file tracks related files via `🔗 关联枝` (association links) |
| 🏷️ **Memory Types** | Semantic (facts), Episodic (timeline), Procedural (steps), Mixed |
| ⏱️ **Version Tracking** | Timestamps on every entry; history preserved on updates |
| 🔌 **Zero Dependencies** | Pure Bash + Markdown — no databases, no npm packages |
| 🔍 **Full-Text Search** | `session_search.sh` searches summaries; `raw_search.sh` searches raw transcripts |
| 🔄 **Memory Cascade** | Auto: memory tree → session summaries → raw logs (no data loss) |
| 🔄 **Self-Improvement** | `pattern.sh` captures recurring patterns as reusable knowledge |
| 🤖 **Auto-Consolidation** | Daemon scheduler checks memory health daily |
| 🛡️ **Security Filtering** | Automatic blocking of API keys, passwords, and secrets |

## 🔬 Comparison with Other Memory Systems

| Capability | pi-memory-tree | Hermes | Mem0 | Letta/MemGPT | Zep |
|:-----------|:--------------:|:------:|:----:|:------------:|:---:|
| Hierarchical tree | ✅ | ❌ | ❌ | ❌ | ❌ |
| Infinite capacity | ✅ | ❌ | ✅ | ✅ | ✅ |
| Zero dependencies | ✅ | ❌ | ❌ | ❌ | ❌ |
| Human-readable | ✅ | ✅ | ❌ | ❌ | ❌ |
| Cross-session persistence | ✅ | ✅ | ✅ | ✅ | ✅ |
| Full-text search | ✅ | ✅ | ✅ | ✅ | ✅ |
| Memory types | ✅ | ❌ | ❌ | ❌ | ❌ |
| Association links | ✅ | ❌ | ❌ | ❌ | ✅ |
| Version tracking | ✅ | ❌ | ❌ | ❌ | ✅ |
| Pattern recognition | ✅ | ✅ | ❌ | ❌ | ❌ |
| Self-nudge / proactive | ✅ | ✅ | ❌ | ❌ | ❌ |

## 🚀 Quick Start

```bash
# 1. Install
git clone https://github.com/ArtiNexus/pi-memory-tree.git
cd pi-memory-tree
bash install.sh

# 2. Start your next session — the agent will automatically:
#    - Load the focus board (WATCH.md) + index (MEMORY.md)
#    - Remember past conversations via 3-level cascade
#    - Save every Q&A as searchable session log
#    - Record important facts to the right branch file
```

## 📦 What's Included

```
pi-memory-tree/
├── AGENTS.md           ← Protocol: auto-load memory at session start
├── install.sh          ← One-command setup
│
├── src/                ← Shell scripts (copy to ~/.pi/skills/pi-memory/scripts/)
│   ├── memory.sh           Core: add/replace/remove/list/search
│   ├── session.sh          Session logging
│   ├── session_search.sh   Full-text cross-session search
│   ├── pattern.sh          Pattern recognition / self-improvement
│   └── consolidate_memory.sh  Daemon-driven health check
│
├── template/
│   └── MEMORY_TEMPLATE.md  ← Format spec for all branch files
│
├── examples/            ← Example memory tree (rename/adapt)
│   ├── MEMORY.md            Level 0 index
│   ├── MEMORY1_sem.md       Semantic: environment config
│   ├── MEMORY2_epi.md       Episodic: project timeline
│   ├── MEMORY3_pro.md       Procedural: tool manuals
│   └── ...
│
└── docs/
    ├── ARCHITECTURE.md      ← Full design doc
    ├── COMPARISON.md        ← Cross-system analysis
    └── QUICKSTART.md        ← Detailed setup guide
```

## 🧠 How It Works

Every session, the agent loads the **three-layer core**:
1. **WATCH.md** (Layer F) — current focus board, drives smart Level 1 preloading
2. **MEMORY.md** (Level 0) — compact keyword → file index
3. **USER.md** — user profile and preferences

When a topic comes up, the agent follows the index to the relevant Level 1 file and loads only that file — keeping context efficient. It also preloads Level 1 files linked from WATCH.md priorities.

**Memory Cascade**: When asked "remember X?", the agent automatically cascades:
1. Memory tree (already-loaded context + Level 1 files)
2. Session summaries (`session_search.sh`)
3. Raw transcripts (`raw_search.sh`) — no data loss guarantee

When new knowledge is learned:
- **P0 (critical)** → saved immediately to the appropriate branch
- **P1 (important)** → saved during or after the session
- **Daily log** → every Q&A pair is timestamped in session files

## 📜 License

MIT — free to use, modify, share, and commercialize.

---

> Built for [Pi](https://pi.dev) coding agent. Inspired by Hermes Agent (Nous Research),
> Mem0, Letta/MemGPT, and Zep. Distilled from cross-system analysis.
