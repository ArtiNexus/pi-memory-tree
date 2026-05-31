# 🚀 Quick Start Guide

Get pi-memory-tree running in 5 minutes.

## Prerequisites

- [Pi coding agent](https://pi.dev) installed
- Bash shell (Linux, macOS, WSL2)
- Git (for cloning)

## Installation

### Step 1: Clone and install

```bash
git clone https://github.com/ArtiNexus/pi-memory-tree.git
cd pi-memory-tree
bash install.sh
```

The installer will:
1. Copy scripts to `~/.pi/skills/pi-memory/scripts/`
2. Copy the AGENTS.md protocol to `~/.pi/agent/`
3. Create the memory directory at `~/.pi/memory/`
4. Initialize with template files

### Step 2: Verify

```bash
# Check scripts are installed
ls ~/.pi/skills/pi-memory/scripts/
# Should show: memory.sh session.sh session_search.sh pattern.sh consolidate_memory.sh

# Check memory directory
ls ~/.pi/memory/
# Should show: MEMORY.md MEMORY_TEMPLATE.md USER.md patterns/ sessions/

# Check AGENTS.md
ls ~/.pi/agent/AGENTS.md
```

### Step 3: Start using it

Simply start a new Pi session. The AGENTS.md protocol will automatically:

```
Session start
    │
    ▼
Load MEMORY.md (keyword index)
Load USER.md (user profile)
    │
    ▼
Agent says: "Memory loaded — I see we discussed X before..."
    │
    ▼
Every Q&A → auto-saved to session log
Important facts → auto-saved to the relevant branch file
Recurring patterns → auto-registered in pattern library
```

## Manual Setup (Without Installer)

If you prefer to set up manually:

```bash
# 1. Create directories
mkdir -p ~/.pi/memory/{patterns,sessions}
mkdir -p ~/.pi/skills/pi-memory/scripts

# 2. Copy scripts
cp scripts/*.sh ~/.pi/skills/pi-memory/scripts/
chmod +x ~/.pi/skills/pi-memory/scripts/*.sh

# 3. Copy AGENTS.md
cp AGENTS.md ~/.pi/agent/

# 4. Initialize memory
cp template/MEMORY_TEMPLATE.md ~/.pi/memory/
cp examples/MEMORY.md ~/.pi/memory/
```

## First Memory

Your first session will automatically create a session log. To add your first curated memory:

```bash
bash ~/.pi/skills/pi-memory/scripts/memory.sh add memory \
  "[P0] 2026-06-01: First memory entry — system ready"
```

## What Happens Next

| After | The system will |
|:------|:----------------|
| **1 session** | Create your first session log with Q&A entries |
| **5 sessions** | Have a small tree of important facts |
| **20 sessions** | Start forking branches as files approach capacity |
| **100 sessions** | Have a rich knowledge tree with associations between branches |
| **Ongoing** | Automatically detect and record recurring patterns |

## Key Commands Reference

```bash
# Memory management
memory.sh add memory "<content>"        # Add a memory entry
memory.sh add user "<preference>"       # Add user preference
memory.sh list memory                   # List all entries
memory.sh search "<keyword>"            # Search across all memories

# Session logging
session.sh save "<summary>"              # Log this Q&A
session.sh list                          # List all sessions
session.sh view YYYY-MM-DD               # View specific session

# Cross-session search (summaries)
session_search.sh "<query>"              # Search session summaries
session_search.sh --date YYYY-MM-DD      # Search specific date
session_search.sh --stats                # View statistics

# Raw log search (full transcripts — guaranteed find)
raw_search.sh "<query>"                  # Search user + assistant messages
raw_search.sh "<query>" --context        # Show surrounding context
raw_search.sh "<query>" --last 3         # Last 3 sessions only

# Pattern recognition
pattern.sh add workflow "<title>" "<desc>"  # Record a pattern
pattern.sh list                               # List all patterns
pattern.sh stats                              # Pattern statistics

# Maintenance
consolidate_memory.sh                     # Check memory health
```

## Daemon Integration (Optional)

For automatic daily memory health checks:

```bash
# Using PM2 (recommended for Pi daemon)
pm2 start ecosystem.config.js
# This runs consolidate_memory.sh every day at 4:00 AM
```

Or via simple cron:

```bash
crontab -e
# Add: 0 4 * * * bash ~/.pi/skills/pi-memory/scripts/consolidate_memory.sh
```
