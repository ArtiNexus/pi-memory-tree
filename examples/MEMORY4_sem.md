# MEMORY4_sem: Memory System Theory

> Last updated: 2026-05-30
> Created: 2026-05-30

═══ Association Links ═══
| Target File | Reason | Intersection |
|:------------|:-------|:-------------|
| MEMORY3_pro | Theory realized in tools | Memory system |

═══ Content ═══

§ [2026-05-29]
pi-memory v1 installed — inspired by Hermes Agent (Nous Research)
Original design: two bounded files MEMORY.md (2200 chars) + USER.md (1375 chars)
Storage: ~/.pi/memory/

§ [2026-05-30]
Upgraded to hierarchical memory tree (Level 0 + Level 1..N):
- Level 0 (MEMORY.md): Keyword index, always loaded
- Level 1 (MEMORY{N}_{type}.md): Detail files, loaded on demand
- Level 2+ (MEMORY{N}-{M}_{type}.md): Sub-branches, unlimited depth
- Fork rule: file >2000 chars → split, parent keeps core + sub-index
- Type tags: sem (semantic) / epi (episodic) / pro (procedural) / mix (mixed)

§ [2026-05-30]
Design rationale — cross-system analysis conclusion:
- Hermes/Mem0/Letta/Zep: fundamentally flat retrieval
- pi-memory-tree: tree path navigation, more precise as knowledge grows
- Zero-dependency pure filesystem, human-readable and editable
- Adopted MemGPT's "core memory (Level 0) + external storage (Level 1+)" layering
- Adopted LangMem's three memory type classification
- Adopted Zep's timestamp tracking (file-level, not graph DB)
