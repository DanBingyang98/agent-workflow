---
name: improve-codebase-architecture
description: 扫描代码库寻找加深机会，以可视化 HTML 报告呈现，然后对你挑中的那个进行拷问。
disable-model-invocation: true
---

# Improve Codebase Architecture（改进代码库架构）

浮出架构摩擦并提议**加深机会（deepening opportunities）**——把浅模块变成深模块的重构。目标是可测试性和 AI 可导航性。

这条命令_由_项目的领域模型提供信息，并建立在共享设计词汇上：

- 运行 `/codebase-design` 技能获取架构词汇（**module**、**interface**、**depth**、**seam**、**adapter**、**leverage**、**locality**）及其原则（删除测试、「接口就是测试面」、「一个 adapter = 假设性接缝，两个 = 真实」）。每条建议都严格使用这些术语——不要漂移到「component」「service」「API」或「boundary」。
- `CONTEXT.md` 中的领域语言给好接缝命名；`docs/adr/` 中的 ADR 记录这条命令不应重新争论的决策。

## 流程

### 1. 探索

**扫描前先定范围——YAGNI。** 加深一个模块的回报是让未来对它改动更容易，所以给最近变化多的代码库部分更多权重。在看之前先决定*看哪里*：

- 如果用户指明了方向——模块、子系统、痛点——照做，跳过下面的推断。
- 否则，往回走一段 commit 历史（`git log --oneline`），找代码库的热点——反复出现的文件和区域——让这些路径先吸引你的注意力。如果改动分散、没有明确热点，就把网撒大。

先读项目的领域词汇表（`CONTEXT.md`）和所触及区域的任何 ADR。

然后用 `subagent_type=Explore` 的 Agent 工具走查代码库。不要跟死板的启发式——有机探索，记录你在哪里感到摩擦：

- 哪里理解一个概念需要在许多小模块之间来回跳？
- 哪里模块是**浅**的——接口几乎和实现一样复杂？
- 哪里纯函数只是为了可测试性被抽出来，但真正的 bug 藏在它们怎么被调用里（没有 **locality**）？
- 哪里紧耦合的模块跨接缝泄漏？
- 代码库的哪些部分没测试，或难以通过当前接口测试？

对你怀疑是浅的任何东西应用**删除测试**：删除它会集中复杂性，还是只是移动它？「是，会集中」就是你想要的信号。

### 2. 把候选呈现为 HTML 报告

写一个自包含的 HTML 文件到 OS 临时目录，让仓库不留任何东西。从 `$TMPDIR` 解析临时目录，回退到 `/tmp`（Windows 是 `%TEMP%`），写到 `<tmpdir>/architecture-review-<timestamp>.html`，每次运行一个全新文件。为用户打开它——Linux 用 `xdg-open <path>`，macOS 用 `open <path>`，Windows 用 `start <path>`——并告诉他们绝对路径。

报告用 **CDN 的 Tailwind** 做布局和样式，**CDN 的 Mermaid** 在图形/流程/序列能可靠传达结构时画图。把 Mermaid 与手写 CSS/SVG 视觉混用——关系是图状（调用图、依赖、序列）时用 Mermaid，想要更编辑风格（质量图、截面、折叠动画）时用手工 div/SVG。每个候选有**前后对照可视化**。要有视觉。

每个候选渲染一张卡片：

- **Files（文件）** —— 涉及哪些文件/模块
- **Problem（问题）** —— 当前架构为什么造成摩擦
- **Solution（方案）** —— 会用大白话描述什么会变
- **Benefits（收益）** —— 用 locality 和 leverage 解释，以及测试会怎么改善
- **Before / After diagram（前后图）** —— 并排、手绘，说明浅与加深
- **Recommendation strength（建议强度）** —— `Strong`、`Worth exploring`、`Speculative` 之一，渲染为徽章

报告以 **Top recommendation（首选建议）** 部分收尾：你会先做哪个候选、为什么。

**领域用 `CONTEXT.md` 词汇，架构用 `/codebase-design` 词汇。** 如果 `CONTEXT.md` 定义了「Order」，就说「the Order intake module」——不要说「the FooBarHandler」，也不要说「the Order service」。

**ADR 冲突**：如果候选与现有 ADR 矛盾，只在摩擦真实到值得重开该 ADR 时才浮出它。在卡片里明确标记（例如警告 callout：_"contradicts ADR-0007 — but worth reopening because…"_）。不要列出 ADR 禁止的每个理论性重构。

完整 HTML 脚手架、图形模式、样式指导见 [HTML-REPORT.md](HTML-REPORT.md)。

先**不要**提议接口。文件写完后，问用户：「Which of these would you like to explore?」

### 3. 拷问循环

用户挑中候选后，运行 `/grilling` 技能与他们走决策树——约束、依赖、加深模块的形态、接缝后面放什么、哪些测试存活。

副作用在决策结晶时内联发生——边做边运行 `/domain-modeling` 技能保持领域模型最新：

- **要给不在 `CONTEXT.md` 里的概念命名加深后的模块？** 把术语加进 `CONTEXT.md`。文件不存在就惰性创建。
- **对话中磨锐了一个模糊术语？** 就地更新 `CONTEXT.md`。
- **用户以承重理由拒绝候选？** 提供 ADR，这样措辞：「Want me to record this as an ADR so future architecture reviews don't re-suggest it?」只在理由确实会被未来探索者需要、以避免重新建议同样的东西时才提供——跳过短暂理由（「现在不值得」）和不言自明的理由。
- **想为加深后的模块探索替代接口？** 运行 `/codebase-design` 技能，用它的 design-it-twice 并行子代理模式。
