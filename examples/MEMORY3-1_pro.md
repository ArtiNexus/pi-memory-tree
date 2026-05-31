# MEMORY3-1_pro: session_search User Manual

> Last updated: 2026-05-30
> Created: 2026-05-30

═══ Association Links ═══
| Target File | Reason | Intersection |
|:------------|:-------|:-------------|
| MEMORY3_pro | Parent toolset | Memory tools |

═══ Content ═══

§ [2026-05-30]
Path: ~/.pi/skills/pi-memory/scripts/session_search.sh

Basic usage:
  session_search.sh "<keyword>"

Filters:
  --date YYYY-MM-DD    Search specific date
  --last N             Search last N sessions

Utility:
  --list               List all sessions
  --stats              View statistics

§ [2026-05-30] 💡 Tips
- Supports AND search (space-separated terms auto-AND)
- Results highlighted with context preview
