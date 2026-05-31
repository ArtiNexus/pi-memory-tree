# 🧠 持久记忆系统 — 自动执行协议

> 本文件是 pi-memory-tree 的核心协议。
> 每次新会话自动执行，确保记忆树三层架构（焦点 → 索引 → 详情）正常运作。

---

## ⚡ 会话开始 — 立即执行（不可跳过）

在每！一！次！新会话开始时，必须立即执行以下步骤：

### Step 1: 加载三层记忆架构（焦点 → 索引 → 画像）

```bash
cat ~/.pi/memory/WATCH.md       # Layer F (焦点): 当前关注话题，驱动智能加载
cat ~/.pi/memory/MEMORY.md      # Level 0 (索引): 关键词索引（总目录）
cat ~/.pi/memory/USER.md        # USER    (画像): 身份、偏好
```
> **三层架构**: WATCH.md(焦点→驱动) → MEMORY.md(索引→定位) → Level 1(详情→按需)
> 小皮根据 WATCH.md 自动预加载对应 Level 1 文件，无需手动逐个加载。

#### 智能加载 Level 1（由 WATCH.md 驱动）

WATCH.md 中的活跃话题会触发小皮自动预加载其关联的 Level 1 文件。
同时根据 MEMORY.md 的关键词映射精确查找：

```bash
cat ~/.pi/memory/MEMORY1_sem.md   # 环境配置
cat ~/.pi/memory/MEMORY2_epi.md   # 小皮 Daemon
cat ~/.pi/memory/MEMORY3_pro.md   # 记忆系统工具集
cat ~/.pi/memory/MEMORY4_sem.md   # 记忆系统理论
# 子枝杈: MEMORY1-1_sem, MEMORY3-1_pro, MEMORY3-2_pro...
```
> 关键：WATCH.md + MEMORY.md 每次会话必加载（~1500 chars）
> Level 1 文件按需加载，WATCH 驱动 + 关键词定位双重机制确保只加载需要的。

### Step 2: 告知用户已加载
在回复第一句话中包含类似：
> "记忆已加载 ✓ — 上次我们讨论了 [xxx]，你正在做 [yyy]..."

### Step 3: 加载模式库（patterns）
```bash
cat ~/.pi/memory/patterns/patterns.md
```
> 注意：如果文件不存在，忽略即可。

### Step 4: 检查是否要为今天创建会话日志
```bash
ls ~/.pi/memory/sessions/$(date "+%Y-%m-%d").md 2>/dev/null
```
如果不存在，用 session.sh 初始化：
```bash
~/.pi/skills/pi-memory/scripts/session.sh save "会话开始"
```

---

## 🔄 会话中 — 自动记忆规则

以下 **强制** 规则，每次用户提问 + 你回复后执行：

### 重要度分级

| 级别 | 标签 | 含义 | 保存位置 | 保存时机 |
|:----:|:----:|:------|:---------|:---------|
| 🔴 P0 | 核心 | 用户身份/偏好、项目架构决策、环境变更、"记住这个" | MEMORY1..N.md | **立即**追加到对应的 Level 1 文件 |
| 🟡 P1 | 重要 | 有用的技术发现、工作流技巧、重要讨论结论 | MEMORY1..N.md | **会话中或结束时**追加到对应的 Level 1 文件 |
| 🔵 P2 | 一般 | 日常问答、临时调试、普通操作 | session 日志 | 会话结束时批量保存 |
| 📝 日常 | 日志 | 普通问答摘要 | session.sh save | **每次用户提问+你回复后** |

### 自动执行命令

**P0/P1 信息 — 追加到 Level 1 文件：**
```bash
# 追加到对应的层级文件（而不是 MEMORY.md，它现在是索引）
echo "[内容]" >> ~/.pi/memory/MEMORY1_sem.md
echo "[内容]" >> ~/.pi/memory/MEMORY2_epi.md
# 同时在 Level 0 MEMORY.md 里加关键词
```

**P0 用户信息 — 立即保存（USER.md 保持不变）：**
```bash
~/.pi/skills/pi-memory/scripts/memory.sh add user "[P0] yyyy-mm-dd: <内容>"
```

**日常日志 — 每次问答后立即执行：**
```bash
~/.pi/skills/pi-memory/scripts/session.sh save "<用户问: xxx> → <你做了: yyy>"
```
> 注意：每次用户提问 + 你回复后**必须**执行一次，不等到会话结束批量保存。
> 格式示例: `session.sh save "用户问余额问题 → 小皮查了DeepSeek API余额(¥2.10)"`

**搜索记忆树（当需要从所有层级中找信息时）：**
```bash
# 搜索 Level 0 + Level 1 所有文件
~/.pi/skills/pi-memory/scripts/memory.sh search "<关键词>"

# 搜索历史会话摘要
~/.pi/skills/pi-memory/scripts/session_search.sh "<关键词>"

# 直接跨全部记忆文件搜索
grep -ri "<关键词>" ~/.pi/memory/MEMORY*.md ~/.pi/memory/USER.md 2>/dev/null
```

---

## 🧠 记忆级联检索协议（询问过去话题时的自动流程）

当主人问"还记得 xxx 吗"或类似问题时，**自动执行以下级联**，不需要主人指定搜索方式：

```
Step 1: 查记忆树（已加载的上下文）
  ├─ WATCH.md → 当前焦点话题（已加载）
  ├─ MEMORY.md → 关键词索引（已加载）→ 定位 Level 1 文件
  └─ 按需加载 Level 1 文件 → 找详细内容
        ↓ 如果 Level 1 不够详细

Step 2: 搜会话摘要
  └─ session_search.sh "<关键词>" → 搜 session.sh save 的要点
        ↓ 如果摘要不匹配

Step 3: 搜原始日志（黑匣子）
  └─ raw_search.sh "<关键词>" → 搜 pi 自动记录的完整问答
      默认搜所有消息（用户+助手），覆盖概念同义词
```

**注意**：Step 1 中的 Level 1 文件按需加载，不是每步都做。
发现匹配后立即返回，不继续往下搜。

### 具体命令

**搜会话摘要（要点级）：**
```bash
~/.pi/skills/pi-memory/scripts/session_search.sh "<关键词>"
# 也支持：--date YYYY-MM-DD, --last N, --list, --stats
```

**搜原始日志（字词级）：**
```bash
~/.pi/agent/skills/memory-tree/scripts/raw_search.sh "<关键词>"
# 也支持：--last N（最近N个文件）, --user-only（仅用户消息）, --context（带上下文）
```

---

## 📦 会话结束 — 必须执行

无论会话如何结束，执行：
1. 汇总本次会话所有 P1 及以上要点
2. 追加到对应的 Level 1 文件（去重合并）
3. 检查容量：Level 1 文件 >80%则分叉创建新文件
4. 更新 MEMORY.md（Level 0 索引，如果有新关键词）
5. 更新 WATCH.md（如果有新增关注话题或状态变更）
6. 检查是否有重复模式 → 有则 pattern.sh add

---

## 🧪 容量管理（层级记忆树）

| 层级 | 文件 | 上限 | 溢出处理 |
|:----:|:-----|:----:|:---------|
| Layer F | WATCH.md | ~500 chars (焦点) | 新旧替换，固定小容量 |
| Level 0 | MEMORY.md | ~2200 chars (索引) | 精简关键词，移除低频词 |
| Level 1 | MEMORY*_{type}.md | 各 2200 chars | 满了就创建 MEMORY(N+1)_{type}.md |
| User | USER.md | 1375 chars | 整合压缩 |
| 日志 | sessions/*.md | 无上限 | — |
| 模式 | patterns/*.md | 无上限 | — |

**关键区别**：WATCH.md 固定小容量，新旧话题自然替换。Level 1 满了直接创建下一个。
记忆容量可以无限扩展，只有 Level 0 索引需要保持精简。

---

## 🧘 记忆主动提醒（Self-Nudge）

在空闲轮次（等待用户输入时），主动做以下检查：

1. **容量检查**：`memory.sh list memory` → 是否 >80%？是则整合
2. **一致性检查**：当前记忆条目是否仍然准确？过时的替换掉
3. **模式发现**：最近的对话中是否有重复出现的操作模式？有则 `pattern.sh add`
4. **关联检查**：新学到的信息是否能和已有记忆条目合并？

> 提示词示例：在回复末尾可以加一句"📝 小皮注意到...这个操作出现过两次，已记录为模式"

---

## 📚 参考

- 记忆文件位置：`~/.pi/memory/`
- 管理脚本：`~/.pi/skills/pi-memory/scripts/memory.sh`
- 日志脚本：`~/.pi/skills/pi-memory/scripts/session.sh`
