---
name: ask-matt
description: 询问哪个技能或流程适合你的情况。本仓库内各技能的路由器。
disable-model-invocation: true
---

# Ask Matt

你记不住每个技能，所以问。

**流程（flow）** 是穿过技能的一条路径。大多数路径沿着一条**主干流程**走，两条**入口匝道（on-ramp）**并入其中。其余的都是独立的，或是跑在底下的词汇层。

## 主干流程：想法 → 交付

大部分工作走的路线。你有一个想法，想把它做出来。

1. **`/grill-with-docs`** —— 通过访谈打磨想法。只要你在**工作目录**里就从这里开始：它是有状态的，把学到的东西留在 `CONTEXT.md` 和 ADR 里。（不在工作目录？用 `/grill-me`——见「独立技能」。两者跑的是同一个 `/grilling` 原语；`grill-with-docs` 是会留下纸面痕迹的那个，因此只要有仓库可留，它就是更好的选择。）
2. **分支——所有问题都能在对话里解决吗？** 如果某个问题需要可运行的答案（状态、业务逻辑、必须亲眼看到的 UI），就绕道原型，用 **`/handoff`** 双向衔接（原型住在自己的目录里，这正是 `/handoff` 的用途——见「阶段边界」）：
   - 先 **`/handoff`** 出去，然后针对那个文件开一个全新会话，
   - **`/prototype`** 用临时代码回答问题，
   - 把学到的 **`/handoff`** 回来，并在原始想法线程里引用它。
3. **分支——这是多会话构建吗？**
   - **是** → **`/to-spec`**（把线程变成规范），再 **`/to-tickets`** 拆成曳光弹 ticket，每个 ticket 声明它的**阻塞边界（blocking edges）**。本地 tracker 上就是 `.scratch/<feature>/issues/` 下每个 ticket 一个文件，先手工解决阻塞项；真实 tracker 上边界变成原生阻塞链接，任何阻塞项已完成的 ticket 都能被捡起——每个 ticket 启动 **`/implement`**，ticket 之间 **`/clear`** 上下文。每个 ticket 自包含，所以上一个的上下文可以丢弃。
   - **否** → 就在当前上下文窗口里 **`/implement`**。

   无论哪种，**`/implement`** 通过内部驱动 **`/tdd`** 逐个构建 issue——一次一个 red-green 切片——然后以运行 **`/code-review`**（对 diff 的 Standards + Spec 双轴审查）收尾，之后才提交。想只针对具体行为做测试优先开发、不需要完整规范时，单独用 **`/tdd`**；想针对固定点审查分支或 PR 时，单独用 **`/code-review`**。

### 上下文卫生

把步骤 1–3 放在**一个不间断的上下文窗口**里——在 `/to-tickets` 之前不要 compact 或 clear——让拷问、规范和 tickets 都建立在同一份思考上。之后每个 `/implement` 从 ticket 出发、全新开始。

这里的上限是**[智能区（smart zone）](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**：模型仍能敏锐推理的窗口（最新模型约 150k tokens）。如果会话在 `/to-tickets` 前逼近它，不要在退化状态下硬撑——在最近的阶段边界 **`/compact`** 并继续（见「阶段边界」）。

## 入口匝道

产生工作的起始情境，然后并入主干流程。

- **bug 和请求堆积** → **`/triage`**。它让 issue 走完 triage 角色，产出 agent-ready 的 issue，之后由 **`/implement`** 接手。

  Triage 只用于**不是你创建的** issue——bug 报告、外部进来的功能请求、一切原始流入的东西。`/to-tickets` 产出的 tickets 已经 agent-ready，**不要 triage 它们**。

- **什么东西坏了** → **`/diagnosing-bugs`**。针对难啃的：一眼看不透的 bug、间歇性 flake、两个已知良好状态之间潜入的回归。它拒绝在没有**紧密反馈回路**——一条已经能在这个 bug 上变红的命令——之前空谈理论，然后用回归测试修复。当真正的问题是没有好接缝来锁死 bug 时，它的事后复盘会交接给 **`/improve-codebase-architecture`**。

- **巨大而模糊的努力——全新项目或巨大功能，单个会话装不下** → **`/wayfinder`**，这里认知负担最高的流程。当从这里到目标的路径还看不见时，它在 issue tracker 上绘制一张**共享地图**的**决策 tickets**，并逐个解决——产出**决策而不是交付物**——直到迷雾被推开、道路清晰。**`/grill-with-docs`** 打磨的是你能在单个会话里握住的想法，wayfinder 处理的是握不住的——它更慢更密，所以只在这种时候用它，绝不用在范围清晰的 feature 上。

  地图清晰后，**它交接，不构建**：在 **`/to-spec`** 并入主干流程，把地图上关联的决策折叠成可构建的计划，然后照常 `/to-tickets`、`/implement`。直接把地图循环进 `/implement` 会跳过折叠、丢掉关联细节——只有确认工作量真的很小时才直接进 `/implement`。

## 代码库健康

不是功能工作，是维护。

- **`/improve-codebase-architecture`** —— 只要有空就运行，让代码库保持适合 agent 作业。它找出**加深机会（deepening opportunities）**；挑一个_产生想法_，可以带入主干流程的 `/grill-with-docs`。它是发现候选的勘察；**`/codebase-design`**（见下）是你设计选中项的工作台。

## 底下的词汇层

两个模型可调用、跑在其它技能_底下_的参考——各自是其词汇的唯一事实来源。当问题是**词汇**而不是流程时直接用它们；或让上面的技能引入它们。

- **`/domain-modeling`** —— 打磨项目的*领域*语言：质疑模糊术语、解决重载词（一个「account」干三份活）、把难逆转的决策记成 ADR。它是 `/grill-with-docs` 用来保持 `CONTEXT.md` 干净词汇表的主动纪律。
- **`/codebase-design`** —— 深模块词汇（module、interface、depth、seam、adapter、leverage、locality），用于设计模块的*形态*：小接口后面藏大量行为、落在干净接缝上。`/tdd` 和 `/improve-codebase-architecture` 都说这种语言。

## 阶段边界

**阶段（phase）** 是会话内的一块工作——拷问、实施、QA。两个阶段的**边界**处你有五个选项，而在这张地图里挑哪一个是最模糊的决定：

- **Continue（继续）** —— 原地不动。零成本，零损失。
- **`/clear`** —— 清空窗口，当这里没有任何东西对下一步重要时。
- **`/handoff`** —— 写一个可移植的 markdown 文件。窄用途：只用于**新 harness**、**新目录**、**同事**，或**阶段中途**分叉一个旁支任务。它买到的是可移植性。
- **Subagent（子代理）** —— 把一个边界清晰的任务送进它自己的窗口，拿回一份报告。
- **`/compact`** —— 压缩这份上下文，用它播种新会话。**默认选项**，在树底而不是首选。

读 [PHASE-BOUNDARIES.md](PHASE-BOUNDARIES.md) 了解完整决策树——五个问题、每个分支背后的理由，以及为什么一手来源成本让 **Continue** 必须先被排除。**在**边界处做决定；阶段中途要么继续，要么把剩下的拆给子代理。

## 独立技能

完全在主干流程之外。

- **`/grill-me`** —— 与 `/grill-with-docs` 相同的不留情面访谈，但**无状态**：本地不保存任何东西，也不建 `CONTEXT.md`。当你**不在工作目录**里时用它——打磨计划、设计、文字，任何没有仓库垫底的东西。如果在工作目录里，用 `/grill-with-docs` 代替：它跑同样的访谈并留下纸面痕迹，严格更好。
- **`/grilling`** —— 访谈原语本身：轮次、frontier，事实是 agent 的活、决定是你的。`/grill-me` 和 `/grill-with-docs` 是两条具名入口，`/triage`、`/wayfinder` 和 `/improve-codebase-architecture` 内部都跑它。只有当你想不带任何包装地做访谈时才直接用它。
- **`/resolving-merge-conflicts`** —— 逐 hunk 处理进行中的 merge/rebase 冲突，按**意图**追到两侧各自的一手来源来解，而不是挑行，然后完成操作。它从不运行 `--abort`。独立于所有流程：已经处于冲突中时用它。
- **`/prototype`** —— 一个回答单个设计问题的小型临时程序：这个状态模型感觉对吗，或这个 UI 应该长什么样。临时是对代码写法的约束，不是删除的承诺：答案折进真实代码，原型本身作为**一手来源**保留在 main 之外的 `prototype/<name>` 分支，从实现 issue 指向它。它是主干流程第 2 步的绕道，但任何时候设计问题难以在纸上定论时都可以用。
- **`/research`** —— 把阅读跑腿委托给**后台 agent**：它对照**一手来源**调查问题，然后在仓库里留下一份带引用的 Markdown 文件。它读的时候你继续干活。它产出的文件是带入主干流程 `/grill-with-docs` 的东西——研究喂养思考，不取代思考。
- **`/to-questionnaire`** —— 当挡住你的东西不在你脑子里也不在代码库里、而在**别人**那里时，这个技能给他们写一份要填的问卷。它是 `/grill-me` 的反向：不访谈你关于主题，而是访谈你关于**发送**——发给谁、你需要拿回什么——并瞄准缺口提问。拿回来的是 `/grill-with-docs` 或 `/to-spec` 的素材。
- **`/wizard`** —— 用于只有**人类**能做的步骤：配置基础设施、设置凭据或 CI secrets、点陌生第三方后台、运行一次性迁移或切换。它生成一个交互式 bash 脚本，打开每个 URL、捕获每个值、写进 `.env` 和 GitHub secrets——让流程不再需要你每次都向 agent 重新解释。模型可调用，所以 agent 一碰到只有你能越过的墙就会去找它。如果 agent 自己能做，就应该自己做；这是给人类真正在环上的场景。
- **`/wait-what`** —— 对没接住的消息的纠正。在会话中途、任何技能内部使用，agent 会用你缺失的上下文、用 `CONTEXT.md` 的词汇、用大白话重新讲一遍它刚说的东西。它是事后补救；`/grill-with-docs` 是事前治疗，因为及早达成共享语言才是让术语根本不出现的东西。
- **`/teach`** —— 跨多个会话学习一个概念，把当前目录当作有状态的工作区。
- **`/writing-for-agents`** —— 写 agent 消费的文档（skills、AGENTS.md、被指向的文档）的参考。

## 前置条件

**`/setup-matt-pocock-skills`** —— 在第一次工程流程之前运行，配置其它技能假设的 issue tracker、triage 标签和文档布局。自定义 issue tracker 也可以。
