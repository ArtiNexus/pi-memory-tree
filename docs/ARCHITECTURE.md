# 🏗️ Architecture — pi-memory-tree

## Core Concept: Knowledge Tree

Agent memory is organized as a **tree**, not a flat list. Each piece of knowledge lives at a specific node in the tree, connected to related nodes via explicit links.

```
Layer F: Focus (always loaded, ~500 chars)
┌───────────────────────────┐
│     WATCH.md               │ ← Current priorities
│  "Daemon → ⏳ 待启动"      │    drives smart Level 1 loading
└───────────┬───────────────┘
            │
            ▼
Level 0: Index (always loaded, ~1-2KB)
┌───────────────────────────┐
│     MEMORY.md              │ ← Keyword → file mapping
│  "Daemon → MEMORY2_epi"   │
└───────────┬───────────────┘
            │
    ┌───────┼───────────┐
    ▼       ▼           ▼
┌────────┐┌────────┐┌────────┐ Level 1: Details (on-demand)
│MEMORY1 ││MEMORY2 ││MEMORY3 │ ~1-2KB each
│_sem.md ││_epi.md ││_pro.md │
└───┬────┘└────────┘└───┬────┘
    │                   │
    ▼                   ├──────────┐
┌────────┐             ▼          ▼
│MEMORY1│          ┌────────┐ ┌────────┐ Level 2+: Sub-branches
│-1_sem │          │MEMORY3 │ │MEMORY3 │ (split when parent >2KB)
│开发工具│          │-1_pro  │ │-2_pro  │
└───────┘          │ search │ │pattern │
                   └────────┘ └────────┘
```

## The Three Layers

### Layer F — FOCUS (`WATCH.md`)

A compact ~500 char board of current priorities, loaded at every session start.
Contains:
- Current focus topics with status tags (✅ done / ⏳ pending / 🔴 blocked)
- Associated Level 1 file references for smart preloading
- Pending task backlog with priority levels

The agent preloads Level 1 files linked from WATCH.md active topics,
keeping context focused on what matters now.

**Size limit**: ~500 chars, fixed. Topics naturally replace as priorities shift.

### Level 0 — INDEX (`MEMORY.md`)

Loaded at every session start. Contains:
- Keyword→file mapping table (e.g., "Proxy → MEMORY1_sem")
- Priority tags (P0 critical / P1 important / P2 reference)
- File status summary

**Size target**: ~1-2 KB. Compact enough to never overflow context.

### Level 1 — Detail Files (`MEMORY{N}_{type}.md`)

Files organized by **topic** and **memory type**:

| Type | Suffix | Description | Example |
|:-----|:------:|:------------|:--------|
| Semantic | `_sem` | Facts, configurations, static data | `MEMORY1_sem.md` — Environment config |
| Episodic | `_epi` | Events, timelines, experiences | `MEMORY2_epi.md` — Project history |
| Procedural | `_pro` | Instructions, workflows, how-tos | `MEMORY3_pro.md` — Tool manuals |
| Mixed | `_mix` | Combination of types | `MEMORY4_mix.md` — General topic |

Each Level 1 file has a fixed format:

```markdown
# MEMORY1_sem: Environment Config

> Last updated: 2026-05-30
> Created: 2026-05-29

═══ Association Links ═══
| Target File | Reason | Intersection |
|:------------|:-------|:-------------|
| MEMORY2_epi | Daemon depends on this env | OS version/Proxy |

═══ Sub-Index ═══
| Sub-Topic | File | Summary |
|:----------|:-----|:--------|
| Dev Tools | MEMORY1-1_sem | Language/tool versions |

═══ Content ═══

§ [2026-05-29]
macOS 15.7.3, x86_64, 8-core CPU, 16GB RAM

§ [2026-06-15] ⬆ Updated
Java upgraded: 26.0.1 → 27.0.0

═══ History ═══

2026-06-15: Java 26.0.1 → 27.0.0
```

### Level 2+ — Sub-Branches (`MEMORY{N}-{M}_{type}.md`)

When a Level 1 file exceeds **2,000 characters**, it splits:
1. Parent keeps the core overview + adds sub-index entries
2. Child file(s) take the detailed content
3. Naming follows: `MEMORY{N}-{M}_{type}.md`, then `MEMORY{N}-{M}-{K}_{type}.md`
4. No depth limit — the tree grows as needed

## Key Design Decisions

### Why Filesystem?

| Alternative | Problem | Our Solution |
|:------------|:--------|:-------------|
| Vector DB | Heavy dependency, opaque embeddings | Pure Markdown, human-readable |
| SQLite | Need schema, migration, tooling | Plain files, any editor works |
| Single flat file | Capacity ceiling, all-or-nothing loading | Tree: index small, details lazy-loaded |

### Why Three Layers (Focus + Index + Details)?

Most agent memory systems are flat — all or nothing. Our three-layer design:

| Layer | Purpose | Always loaded? | Size |
|:------|:---------|:--------------:|:----:|
| **WATCH.md** (Focus) | What to care about NOW | ✅ Yes | ~500 chars |
| **MEMORY.md** (Index) | Where to find things | ✅ Yes | ~1-2 KB |
| **Level 1** (Details) | The actual knowledge | ❌ On demand | Per file |

This separation means the agent always knows **what's important** and **where things are**
without carrying the full memory in context.

### Why Association Links?

Flat keyword search can't capture **relationships** between topics. Association links:
- Turn the memory store into a **graph** (not a bag of files)
- Enable follow-the-chain discovery (find related information you didn't know existed)
- Make the agent smarter about what to look at next

### Why Type Tags?

Different knowledge types need different retrieval strategies:
- **Semantic**: exact match, keyword lookup → read and answer
- **Episodic**: chronological, causal relationships → read in order
- **Procedural**: step-by-step, conditional branches → read as instructions

## Memory Cascade (Data Flow)

When the user asks "remember X?", the agent automatically cascades:

```
User: "还记得 xxx 吗？"
       │
       ▼
Step 1: Check memory tree (already-loaded context)
  ├── WATCH.md (Layer F) — current focus
  ├── MEMORY.md (Level 0) — keyword index → locate Level 1 file
  └── Load & search the mapped Level 1 file
       │
       ├── Found? → Answer from memory tree
       │
       └── Not found? →
              │
              ▼
       Step 2: session_search across summary logs
              │
              ├── Found? → Answer with context
              │
              └── Not found? →
                     │
                     ▼
              Step 3: raw_search across raw JSONL transcripts
                     (guaranteed find — every word is recorded)
```

**No data loss guarantee**:
- Memory tree → curated knowledge (P0/P1)
- Session summaries → every Q&A pair (session.sh save)
- Raw transcripts → every word spoken (pi auto-records)

```
Agent learns something new
       │
       ▼
Classify: P0 (critical) / P1 (important) / P2 (routine)
       │
       ├── P0 → Append to the appropriate Level 1 file immediately
       │         If file > 2KB → fork: create sub-branch file
       │
       ├── P1 → Append during or after session
       │
       └── P2 → Log to daily session file only
       
Every Q&A pair → session.sh save (searchable via session_search)
Recurring pattern → pattern.sh add (reusable knowledge)
```

## File Lifecycle

```
Created (first entry)
    │
    ▼
Growing (entries accumulate, < 2KB)
    │
    ▼
Threshold (approaches 2KB)
    │
    ▼
Fork (2KB reached)
    ├── Parent keeps overview + sub-index
    └── Child created with detailed content
         │
         ▼
         Growing (child now accumulates)
              │
              ▼
              Threshold → Fork → Grandchild created
                              (any depth)
```

## Integration with Agent Harnesses

The system is designed for [Pi](https://pi.dev) coding agent but works with any agent that:
1. Reads files on startup (AGENTS.md protocol)
2. Can execute shell scripts
3. Supports file-based context injection

To integrate with a different agent:
1. Copy the scripts to a scripts directory
2. Copy AGENTS.md (or equivalent) to the agent's startup config
3. Ensure the agent loads `MEMORY.md` at session start
