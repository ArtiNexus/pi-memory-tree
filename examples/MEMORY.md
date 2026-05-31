# 🧠 Memory Index (Level 0)

> Keyword lookup table. Loaded at every session start.
> For details, load the mapped file by topic.

---

## Keywords → File Mapping

| Keyword | File | Priority | Summary |
|:--------|:-----|:--------:|:--------|
| Environment/OS/Hardware | MEMORY1_sem | 🔴P0 | System configuration |
| Dev tools/Languages | MEMORY1-1_sem | 🟡P1 | Tool version details |
| Daemon/Background | MEMORY2_epi | 🔴P0 | Background service setup |
| Memory system/Protocol | MEMORY3_pro | 🔴P0 | Agent memory protocol |
| Search | MEMORY3-1_pro | 🔴P0 | Cross-session search tool |
| Patterns | MEMORY3-2_pro | 🔴P0 | Pattern recognition |
| Memory Theory | MEMORY4_sem | 🟡P1 | Architecture rationale |
| User Profile | USER | 🔴P0 | Preferences, identity |

---

## File Status

| File | Type | Size | Status |
|:-----|:-----|:----:|:------|
| MEMORY1_sem | semantic | ~0.5KB | normal |
| MEMORY1-1_sem | semantic | ~0.5KB | normal |
| MEMORY2_epi | episodic | ~0.5KB | normal |
| MEMORY3_pro | procedural | ~0.8KB | normal |
| MEMORY3-1_pro | procedural | ~0.5KB | normal |
| MEMORY3-2_pro | procedural | ~0.5KB | normal |
| MEMORY4_sem | semantic | ~0.8KB | normal |

---

## Usage

```bash
# Load a detail file
cat ~/.pi/memory/MEMORY1_sem.md
cat ~/.pi/memory/MEMORY3_pro.md

# Search across all levels
grep -ri "keyword" ~/.pi/memory/MEMORY*.md ~/.pi/memory/USER.md 2>/dev/null
```
