---
name: find-skills
description: 当用户问「我怎么做 X」「找一个做 X 的技能」「有没有技能能……」或表示想扩展能力时，帮助他们发现并安装 agent 技能。当用户寻找可能以可安装技能形式存在的功能时使用本技能。
---

# Find Skills（找技能）

本技能帮你从开放 agent 技能生态中发现并安装技能。

## 何时使用本技能

当用户：

- 问「我怎么做 X」，而 X 可能是已有技能的常见任务
- 说「找一个做 X 的技能」或「有没有做 X 的技能」
- 问「你能做 X 吗」，而 X 是专业能力
- 表示有兴趣扩展 agent 能力
- 想搜索工具、模板或工作流
- 提到希望某个特定领域（设计、测试、部署等）有帮手

## 什么是 Skills CLI？

Skills CLI（`npx skills`）是开放 agent 技能生态的包管理器。技能是可扩展 agent 能力的模块化包，带专业知识、工作流和工具。

**关键命令：**

- `npx skills find [query] [--owner <owner>]` - 交互式或按关键字搜索技能，可选限定 GitHub owner
- `npx skills add <package>` - 从 GitHub 或其它来源安装技能
- `npx skills update` - 更新所有已安装技能

**浏览技能：** https://skills.sh/

## 如何帮用户找技能

### 第 1 步：理解他们需要什么

用户请求帮助时，识别：

1. 领域（例如 React、测试、设计、部署）
2. 具体任务（例如写测试、做动画、审 PR）
3. 这是否是足够常见的任务、很可能已有技能

### 第 2 步：先看排行榜

跑 CLI 搜索之前，先看 [skills.sh 排行榜](https://skills.sh/)，看该领域是否已有知名技能。排行榜按总安装量给技能排名，浮出最流行、经过实战检验的选项。

例如，web 开发的头部技能：
- `vercel-labs/agent-skills` — React、Next.js、web 设计（各 100K+ 安装）
- `anthropics/skills` — 前端设计、文档处理（100K+ 安装）

### 第 3 步：搜索技能

排行榜没覆盖用户需求时，运行 find 命令：

```bash
npx skills find [query] [--owner <owner>]
```

例如：

- 用户问「怎么让我的 React app 更快？」→ `npx skills find react performance`
- 用户问「你能帮我审 PR 吗？」→ `npx skills find pr review`
- 用户问「我需要生成 changelog」→ `npx skills find changelog`

### 第 4 步：推荐前验证质量

**不要仅凭搜索结果推荐技能。** 始终验证：

1. **安装量** —— 偏好 1K+ 安装的技能。低于 100 的要多加小心。
2. **来源声誉** —— 官方来源（`vercel-labs`、`anthropics`、`microsoft`）比未知作者可信。
3. **GitHub stars** —— 检查源仓库。来自 <100 stars 仓库的技能要持怀疑态度。

### 第 5 步：向用户呈现选项

找到相关技能时，呈现：

1. 技能名和它做什么
2. 安装量和来源
3. 他们可以运行的安装命令
4. skills.sh 上的了解更多链接

示例回应：

```
I found a skill that might help! The "react-best-practices" skill provides
React and Next.js performance optimization guidelines from Vercel Engineering.
(185K installs)

To install it:
npx skills add vercel-labs/agent-skills@react-best-practices

Learn more: https://skills.sh/vercel-labs/agent-skills/react-best-practices
```

### 第 6 步：提议安装

用户想继续时，你可以替他们安装：

```bash
npx skills add <owner/repo@skill> -g -y
```

`-g` 标志全局安装（用户级），`-y` 跳过确认提示。

## 常见技能类别

搜索时考虑这些常见类别：

| 类别 | 示例查询 |
| --- | --- |
| Web 开发 | react、nextjs、typescript、css、tailwind |
| 测试 | testing、jest、playwright、e2e |
| DevOps | deploy、docker、kubernetes、ci-cd |
| 文档 | docs、readme、changelog、api-docs |
| 代码质量 | review、lint、refactor、best-practices |
| 设计 | ui、ux、design-system、accessibility |
| 效率 | workflow、automation、git |

## 高效搜索提示

1. **用具体关键词**：「react testing」好过只搜「testing」
2. **试替代词**：「deploy」不行就试「deployment」或「ci-cd」
3. **查热门来源**：很多技能来自 `vercel-labs/agent-skills` 或 `ComposioHQ/awesome-claude-skills`

## 没找到技能时

如果不存在相关技能：

1. 承认没找到现有技能
2. 提议用你的通用能力直接帮忙完成任务
3. 建议用户可以用 `npx skills init` 创建自己的技能

示例：

```
I searched for skills related to "xyz" but didn't find any matches.
I can still help you with this task directly! Would you like me to proceed?

If this is something you do often, you could create your own skill:
npx skills init my-xyz-skill
```
