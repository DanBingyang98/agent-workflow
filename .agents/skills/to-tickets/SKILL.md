---
name: to-tickets
description: 把计划、规范或当前对话拆成一组曳光弹 ticket，每个 ticket 声明其阻塞边界，发布到配置好的 tracker——本地是每个 ticket 一个文件、边界写成文本，真实 tracker 上用原生阻塞链接。
disable-model-invocation: true
---

# To Tickets（拆 Ticket）

把计划、规范或对话拆成一组 **tickets**——曳光弹垂直切片，每个声明**阻塞**它的 tickets。

应该已经向你提供了 issue tracker 和 triage 标签词汇——如果没有，运行 `/setup-matt-pocock-skills`。

## 流程

### 1. 收集上下文

基于对话上下文中已有的内容工作。如果用户传了引用（规范路径、issue 编号或 URL）作为参数，获取并读它的完整正文和评论。

### 2. 探索代码库（可选）

如果还没探索过代码库，做一遍以了解代码当前状态。ticket 标题和描述使用项目的领域词汇表词汇，并尊重所触及区域的 ADR。

寻找预重构机会，让实现更容易。「Make the change easy, then make the easy change.」

### 3. 起草垂直切片

把工作拆成**曳光弹** tickets。

<vertical-slice-rules>

- 每个切片穿过每一层（schema、API、UI、tests）的一条窄但**完整**的路径——垂直，不是某一层的水平切片
- 完成的切片能独立演示或验证
- 每个切片大小适合单个全新上下文窗口
- 任何预重构应该先做

</vertical-slice-rules>

给每个 ticket 它的**阻塞边界（blocking edges）**——开始前必须完成的其它 tickets。没有阻塞项的 ticket 可以立即开始。

**宽重构是垂直切片的例外。** **宽重构（wide refactor）** 是一次机械变更——重命名一列、改一个共享符号的类型——其**爆炸半径**扇遍整个代码库，一次编辑同时破坏几千个调用点，没有垂直切片能落地变绿。别把它硬塞进曳光弹；按 **expand–contract** 排序。先 expand：在旧形态旁边加新形态，什么都不破坏。然后按爆炸半径分批迁移调用点（按包、按目录），每批是独立 ticket、被 expand 阻塞，因为旧形态还在，批与批之间保持 CI 绿。最后 contract：没有调用者残留后删旧形态，用一个被所有迁移批阻塞的 ticket 做这件事。当连批都不能单独保持绿时，保留序列，但让它们共享一个集成分支，所有批共同阻塞一个最终的 integrate-and-verify ticket——只有在那里承诺绿。

### 4. 考问用户

把拟议拆分呈现为编号列表。对每个 ticket 展示：

- **Title（标题）**：简短描述性名称
- **Blocked by（被谁阻塞）**：必须先完成的其它 tickets（如果有）
- **What it delivers（交付什么）**：这个 ticket 让什么端到端行为可用

问用户：

- 粒度感觉对吗？（太粗 / 太细）
- 阻塞边界正确吗——每个 ticket 是否只依赖真正门控它的 tickets？
- 有 tickets 应该合并或进一步拆分吗？

迭代直到用户批准拆分。

### 5. 把 tickets 发布到配置好的 tracker

发布已批准的 tickets。**方式**取决于 `/setup-matt-pocock-skills` 配置的 tracker——tickets 本身无论哪种都一样，只有阻塞边界的形态不同：

- **本地文件** → 在 `.scratch/<feature-slug>/issues/<NN>-<slug>.md` 下每个 ticket 写一个文件，按依赖顺序从 `01` 编号（阻塞项在前）。每个文件的「Blocked by」列出它依赖的编号/标题。用下面的每-ticket 文件模板——一个 ticket 一个文件，绝不用单个合并文件。
- **真实 issue tracker（GitHub、Linear…）** → 按依赖顺序（阻塞项在前）为每个 ticket 发一个 issue，让每个 ticket 的阻塞边界能引用真实标识符。平台有原生阻塞/子 issue 关系就用；否则把每个 ticket 的「Blocked by」设为阻塞 issue。除非另有指示，打上 `ready-for-agent` triage 标签——这些 tickets 构造上就是 agent 可捡起的。

工作 **frontier**：任何阻塞项全部完成的 ticket。对纯线性链就是从顶到底。

**不要**关闭或修改任何父 issue。

<local-ticket-template>

# <NN> — <Ticket title>

**What to build（要构建什么）：** 这个 ticket 让什么端到端行为可用，从用户视角——不是一层层的实现清单。

**Blocked by（被谁阻塞）：** 门控本 ticket 的 tickets 的编号/标题，或「None — can start immediately」。

**Status（状态）：** ready-for-agent

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent（父 issue）

对 tracker 上父 issue 的引用（如果来源是现有 issue，否则省略本部分）。

## What to build（要构建什么）

这个 ticket 让什么端到端行为可用，从用户视角——不是逐层实现。

## Acceptance criteria（验收标准）

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by（被谁阻塞）

- 对每个阻塞 ticket 的引用，或「None — can start immediately」。

</issue-template>

两种形态都避免具体文件路径或代码片段——它们过时很快。例外：如果原型产出的片段比散文更精确地编码了一个决策（状态机、reducer、schema、类型形态），内联它并简短注明来自原型。裁到决策丰富的部分——不是能跑的演示，只是重要的部分。
