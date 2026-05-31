# MEMORY2_epi: Background Daemon

> Last updated: 2026-05-30
> Created: 2026-05-29

═══ Association Links ═══
| Target File | Reason | Intersection |
|:------------|:-------|:-------------|
| MEMORY1_sem | Daemon runtime environment | OS version/Proxy |
| MEMORY3_pro | Daemon includes memory bridge | Memory system |

═══ Content ═══

§ [2026-05-29]
Daemon v1 deployed — PM2 managed, Express web panel on :3742
File watching enabled for live reload

§ [2026-05-29]
Modules:
- server.js — Web management panel
- channels/lark.js — Lark messaging (config pending)
- scheduler.js — Cron task framework
- watcher.js — File change monitoring
- memory-bridge.js — Memory system integration

§ [2026-05-29]
Remote channel: Lark (Feishu)
Using lark-mcp for MCP communication
