---
name: code-review
description: 从固定点（commit、分支、tag 或 merge-base）起，沿两个轴审查变更——Standards（代码是否遵循本仓库记录的编码标准？）与 Spec（代码是否匹配原始 issue/规范的要求？）。两个审查并行跑在子代理里并排报告。当用户想审查分支、PR、进行中的改动，或说「review since X」时使用。
---

对 `HEAD` 与用户提供的固定点之间的 diff 做双轴审查：

- **Standards（标准）** —— 代码是否符合本仓库记录的编码标准？
- **Spec（规范）** —— 代码是否忠实实现了原始 issue / 规范？

两个轴以**并行子代理**运行，互不污染上下文，然后本技能汇总它们的发现。

应该已经向你提供了 issue tracker——如果缺少 `docs/agents/issue-tracker.md`，运行 `/setup-matt-pocock-skills`。

## 流程

### 1. 固定基准点

用户说的任何固定点——commit SHA、分支名、tag、`main`、`HEAD~5` 等。如果没指定，就问。

只记下 diff 命令：`git diff <fixed-point>...HEAD`（三点，比较对象是 merge-base）。同时用 `git log <fixed-point>..HEAD --oneline` 记下提交列表。

继续之前，确认固定点可解析（`git rev-parse <fixed-point>`）且 diff 非空。坏引用或空 diff 应该在这里失败——而不是在两个并行子代理内部。

### 2. 定位规范来源

按这个顺序找原始规范：

1. 提交信息里的 issue 引用（`#123`、`Closes #45`、GitLab `!67` 等）——按 `docs/agents/issue-tracker.md` 中的工作流获取。
2. 用户作为参数传入的路径。
3. `docs/`、`specs/` 或 `.scratch/` 下与分支名或 feature 匹配的规范文件。
4. 找不到就问用户规范在哪。如果用户说没有，**Spec** 子代理跳过并报告「no spec available」。

### 3. 定位标准来源

仓库中任何记录代码怎么写的东西，例如 `CODING_STANDARDS.md` 或 `CONTRIBUTING.md`。

在仓库记录的基础上，Standards 轴始终携带下面的**气味基线（smell baseline）**——一组固定的 Fowler 代码坏味道（《重构》第 3 章），即使仓库没有任何文档也适用。两条规则约束它：

- **仓库标准优先。** 文档化的仓库标准永远赢；当它支持基线会标记的东西时，抑制该气味。
- **永远是判断。** 每种气味都是有标签的启发式（「可能的 Feature Envy」），绝不是硬性违规——并且与这里的任何标准一样，跳过工具已经强制的东西。

每种气味读作 *是什么* → *怎么修*；把它与 diff 对照：

- **神秘命名（Mysterious Name）** —— 函数、变量或类型的名字看不出它做什么或装什么。→ 重命名；如果想不出诚实名字，说明设计是浑浊的。
- **重复代码（Duplicated Code）** —— 相同逻辑形态出现在改动中的多个 hunk 或文件里。→ 抽取共享形态，两处都调用它。
- **依恋情结（Feature Envy）** —— 方法伸手去拿另一个对象的数据多于自己的。→ 把方法移到它嫉妒的数据上。
- **数据泥团（Data Clumps）** —— 同样的几个字段或参数总是一起旅行（一个想诞生的类型）。→ 打包成一个类型，传那个。
- **基本类型偏执（Primitive Obsession）** —— 用基本类型或字符串代替一个配得上自己类型的领域概念。→ 给概念一个自己的小类型。
- **重复的 switch（Repeated Switches）** —— 同一类型上的相同 `switch`/`if` 级联在改动中反复出现。→ 用多态替换，或用两处共享的一张 map。
- **霰弹式修改（Shotgun Surgery）** —— 一个逻辑变更迫使 diff 里散落许多文件的改动。→ 把一起变的东西收进一个模块。
- **发散式变化（Divergent Change）** —— 一个文件或模块因为几个不相关的原因被修改。→ 拆分，让每个模块只为一个原因变化。
- **投机性泛化（Speculative Generality）** —— 为规范没有的需求加的抽象、参数或钩子。→ 删掉；内联回来，直到真实需求出现。
- **消息链（Message Chains）** —— 调用者不该依赖的长 `a.b().c().d()` 导航。→ 把这段走查藏到第一个对象的一个方法后面。
- **中间人（Middle Man）** —— 一个类或函数大多只是转发。→ 砍掉它，直接调用真正的目标。
- **拒绝遗赠（Refused Bequest）** —— 子类或实现者忽略或覆盖了继承来的一大半东西。→ 放弃继承，用组合。

### 4. 并行启动两个子代理

用一次消息发两个 `Agent` 工具调用。两个都用 `general-purpose` 子代理。

**Standards 子代理提示** —— 包含：

- 完整 diff 命令和提交列表。
- 第 3 步找到的标准来源文件列表，**加上第 3 步的气味基线全文**——子代理没有其它途径拿到它。
- 简报：「Report — per file/hunk where relevant — (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls — documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words.」

**Spec 子代理提示** —— 包含：

- diff 命令和提交列表。
- 规范的路径或抓取到的内容。
- 简报：「Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words.」

如果规范缺失，跳过 Spec 子代理并在最终报告中注明。

### 5. 汇总

在两个标题 `## Standards` 和 `## Spec` 下展示两份报告，逐字或轻度清理。**不要**合并或重新排名发现——两个轴刻意分开（见《为什么是两个轴》）。

结尾给一行摘要：每轴发现总数，以及每轴内最严重的问题（如果有）。不要跨轴挑一个赢家——那正是分离要阻止的重新排名。

## 为什么是两个轴

一个改动可以过一个轴、挂另一个轴：

- 遵守所有标准但实现错了东西 → **Standards 过，Spec 挂。**
- 完全按 issue 做了但破坏了项目约定 → **Spec 过，Standards 挂。**

分开报告能阻止一个轴掩盖另一个轴。
