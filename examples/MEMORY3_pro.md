# MEMORY3_pro: Memory System Tools

> Last updated: 2026-05-30
> Created: 2026-05-30

═══ Association Links ═══
| Target File | Reason | Intersection |
|:------------|:-------|:-------------|
| MEMORY4_sem | Design philosophy behind the tools | Memory theory |
| MEMORY2_epi | Daemon includes memory bridge | Memory system |

═══ Sub-Index ═══
| Sub-Topic | File | Summary |
|:----------|:-----|:--------|
| session_search | MEMORY3-1_pro | Cross-session search tool |
| pattern | MEMORY3-2_pro | Pattern recognition tool |

═══ Content ═══

§ [2026-05-30]
AGENTS.md protocol (located at ~/.pi/agent/AGENTS.md):
- Loads Level 0 index (MEMORY.md) at session start
- Loads USER.md + patterns.md
- Auto-saves session log after every Q&A
- P0/P1 information appended to appropriate Level 1 file
- Recurring patterns → auto-registered via pattern.sh
- Idle self-nudge for memory health
- Session-end consolidation

§ [2026-05-30]
Upgrade roadmap:
- Phase 1: session_search — cross-session full-text search ✅
- Phase 2: pattern — self-improvement pattern recognition ✅
- Phase 3: SQLite upgrade + lineage tracking ⏳
- Phase 4: External memory provider integration 📅
