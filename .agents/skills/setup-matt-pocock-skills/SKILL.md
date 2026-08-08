---
name: setup-matt-pocock-skills
description: 为工程 skills 配置本仓库——设置 issue tracker、triage 标签词汇和领域文档布局。在首次使用其它工程 skills 之前运行一次。
disable-model-invocation: true
---

# Setup Matt Pocock's Skills

搭建工程 skills 假设的每仓库配置：

- **Issue tracker** —— issues 住哪里（默认 GitHub；开箱也支持本地 markdown）
- **Triage labels** —— 五个规范 triage 角色使用的标签字符串
- **Domain docs** —— `CONTEXT.md` 和 ADRs 住哪里，以及消费规则

这是一个提示驱动的技能，不是确定性脚本。探索、呈现你找到的、与用户确认、然后写入。

## 流程

### 1. 探索

看当前仓库以了解它的起点状态。读任何存在的东西；不要假设：

- `git remote -v` 和 `.git/config` —— 这是 GitHub 仓库吗？哪个？
- 仓库根的 `AGENTS.md` 和 `CLAUDE.md` —— 存在吗？两者里是否已有 `## Agent skills` 部分？
- 仓库根的 `CONTEXT.md` 和 `CONTEXT-MAP.md`
- `docs/adr/` 和任何 `src/*/docs/adr/` 目录
- `docs/agents/` —— 本技能此前的产出是否已存在？
- `.scratch/` —— 本地 markdown issue tracker 约定已在用的信号
- `triage` 技能是否已安装？（一个与本技能相邻的 `triage` 技能文件夹，或可用技能里的 `triage`。）这决定 B 部分是否运行。
- Monorepo 信号 —— `pnpm-workspace.yaml`、`package.json` 里的 `workspaces` 字段、或带自己 `src/` 的充实 `packages/*`。只有真正大型多包仓库才有；它们的缺席意味着单 context，几乎每个仓库都是。

### 2. 呈现发现并询问

总结有什么、缺什么。然后按顺序一节一节来——一节、一个答案、然后下一节。

每节以推荐答案开头，让用户一个字就能接受。只在选择真的分支时给一行解释；探索已定论时整节跳过（`triage` 未安装时跳过 B 节，无 monorepo 时跳过 C 节）。

**A 节 —— Issue tracker。**

> 解释：「issue tracker」是这个仓库 issues 住的地方。`to-tickets`、`triage`、`to-spec` 等技能读写它——它们需要知道是调 `gh issue create`、在 `.scratch/` 下写 markdown 文件、还是遵循你描述的其他工作流。挑你实际为这个仓库跟踪工作的地方。

默认姿态：这些技能为 GitHub 设计。如果 `git remote` 指向 GitHub，提议它。如果指向 GitLab（`gitlab.com` 或自托管），提议 GitLab。否则（或如果用户偏好），提供：

- **GitHub** —— issues 住在仓库的 GitHub Issues 里（用 `gh` CLI）
- **GitLab** —— issues 住在仓库的 GitLab Issues 里（用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI）
- **Local markdown** —— issues 作为 `.scratch/<feature>/` 下的文件住在本仓库（适合单人项目或无 remote 的仓库）
- **Other**（Jira、Linear 等）—— 请用户用一段话描述工作流；技能把它记为自由文本

把选择记在 `docs/agents/issue-tracker.md`。GitHub 和 GitLab 模板带一个「PRs as a request surface」标志，默认**关**——保持关着，不要提它；想要外部 PR 进 triage 队列的用户以后可以在文件里翻这个标志。

**B 节 —— Triage 标签词汇。** 如果 `triage` 技能未安装（探索告诉你了），整节跳过——未安装的技能不需要标签。

如果已安装，恰好问一个问题：

> Do you want to keep the default triage labels? (recommended: **yes**)

默认是五个规范角色，每个标签字符串等于它的名字：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`。答**是**就原样写入。只有用户说不——通常因为他们的 tracker 已用其他名字（例如 `bug:triage` 代替 `needs-triage`）——才收集覆盖，让 `triage` 应用现有标签而不是创建重复。

**C 节 —— Domain docs。** 默认**单 context**——仓库根一份 `CONTEXT.md` + `docs/adr/`。这适合几乎每个仓库；不问直接写。

只有探索发现 monorepo 信号时才提供**多 context**——根 `CONTEXT-MAP.md` 指向各 context 的 `CONTEXT.md` 文件。然后确认他们要哪种布局。

### 3. 确认并编辑

向用户展示草稿：

- 要加进 `CLAUDE.md` / `AGENTS.md` 之一的 `## Agent skills` 块（选择规则见步骤 4）
- `docs/agents/issue-tracker.md`、`docs/agents/domain.md`、`docs/agents/triage-labels.md` 的内容（最后一个只在 `triage` 已安装时）

让他们先编辑再写入。

### 4. 写入

**挑要编辑的文件：**

- 如果 `CLAUDE.md` 存在，编辑它。
- 否则如果 `AGENTS.md` 存在，编辑它。
- 如果都不存在，问用户创建哪个——不要替他们挑。

`CLAUDE.md` 已存在时绝不创建 `AGENTS.md`（反之亦然）——总是编辑已经在那里的那个。

如果所选文件里已有 `## Agent skills` 块，就地更新其内容而不是追加重复。不要覆盖用户对周边部分的编辑。

这个块：

```markdown
## Agent skills

### Issue tracker

[一行总结 issues 在哪里跟踪]。See `docs/agents/issue-tracker.md`.

### Triage labels

[一行总结标签词汇]。See `docs/agents/triage-labels.md`.

### Domain docs

[一行总结布局——"single-context" 或 "multi-context"]。See `docs/agents/domain.md`.
```

包含 `### Triage labels` 子块、并写 `docs/agents/triage-labels.md`，仅当 `triage` 已安装且 B 节运行过。否则两者都省略。

然后用本技能文件夹里的种子模板作为起点写文档文件：

- [issue-tracker-github.md](./issue-tracker-github.md) —— GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) —— GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) —— 本地 markdown issue tracker
- [triage-labels.md](./triage-labels.md) —— 标签映射（只在 `triage` 已安装时）
- [domain.md](./domain.md) —— 领域文档消费规则 + 布局

对「其他」issue tracker，用用户的描述从零写 `docs/agents/issue-tracker.md`。

### 5. 完成

告诉用户设置完成、哪些工程 skills 现在会读这些文件。提及他们以后可以直接编辑 `docs/agents/*.md`——只有想切换 issue tracker 或从头重来时才需要重跑本技能。
