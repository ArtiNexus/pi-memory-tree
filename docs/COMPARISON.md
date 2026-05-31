# 🔬 Cross-System Comparison

Comparison of pi-memory-tree with six major agent memory systems
as of mid-2026.

## Systems Analyzed

| System | Creator | Architecture | Language | License | Stars |
|:-------|:--------|:-------------|:---------|:-------:|:-----:|
| **pi-memory-tree** | This project | Hierarchical file tree | Bash + Markdown | MIT | — |
| **Hermes Agent** | Nous Research | Two bounded files + SQLite | Python | MIT | ~100K |
| **Mem0** | Mem0 Inc | Vector + Graph + Key-Value | Python | Apache 2.0 | ~47K |
| **Letta/MemGPT** | Letta AI | Virtual memory (OS model) | Python | Apache 2.0 | ~20K |
| **Zep** | Zep AI | Temporal knowledge graph | Python | MIT | ~8K |
| **LangMem** | LangChain | Key-Value + Vector (flat) | Python | MIT | ~1.3K |
| **Hindsight** | Vectorize.io | Four semantic networks | Python | MIT | ~3K |

## Feature Matrix

| Feature | pi-tree | Hermes | Mem0 | Letta | Zep | LangMem | Hindsight |
|:--------|:-------:|:------:|:----:|:-----:|:---:|:-------:|:---------:|
| Cross-session persistence | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Focus board (Layer F) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Keyword INDEX (Level 0) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Hierarchical tree storage | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Infinite capacity | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Lazy loading (save context) | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Zero dependencies | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Human-readable files | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Full-text search (summaries + raw) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Memory cascade (index → summaries → raw) | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Self-improvement / patterns | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Memory types (sem/epi/pro) | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| Association/cross-file links | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Version tracking | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Auto-fork on capacity | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Proactive self-nudge | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Security filtering | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Agent manages own memory | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Memory type tags (sem/epi/pro/mix) | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| External provider plugins | ❌ | ✅ | — | — | — | — | ✅ |

## Architectural Differences

### Hermes Agent — Flat Two-File Model

```
MEMORY.md (2,200 chars)  ──── always in context
USER.md  (1,375 chars)  ──── always in context
  │
  └── When full → consolidate (compress/merge), no expansion
```

**Limitation**: Hard capacity ceiling. Compression loses detail. All memory loaded at every session start regardless of relevance.

### Mem0 — Vector Database Model

```
User input → Embedding → Vector search → Top-K results
               │
          Graph DB ──── Entity relationships
```

**Limitation**: Needs Python runtime, embedding models, database servers. Opaque — you can't read/modify memories directly. Relevance depends on embedding quality.

### Letta/MemGPT — Virtual Memory Model

```
Core Memory (always in context, managed blocks)
    │
Recall Memory (full conversation history, searchable)
    │
Archival Memory (external storage, compressed)
```

**Limitation**: Complex runtime. Memory management logic is in code, not in files — you need the Letta server to read memories.

### pi-memory-tree — Hierarchical File Tree

```
MEMORY.md (1-2KB INDEX, always in context)
    │
    ├── MEMORY1_sem.md (loaded on demand, topic: environment)
    ├── MEMORY2_epi.md (loaded on demand, topic: project A)
    └── MEMORY3_pro.md (loaded on demand, topic: tools)
          │
          └── MEMORY3-1_pro.md (auto-forked sub-branch)
```

**Advantage**: Grows without limit. Context stays efficient. Every file is plain Markdown. No dependencies. Human-readable, machine-searchable.

## Summary

pi-memory-tree's unique differentiator is **tree-structured, filesystem-native memory**. No other system combines:
- A compact always-in-context keyword index
- On-demand detail loading by topic
- File-based infinite scalability
- Zero dependencies

The trade-off is that it requires an agent harness that reads AGENTS.md and can execute shell scripts — which Pi provides natively.
