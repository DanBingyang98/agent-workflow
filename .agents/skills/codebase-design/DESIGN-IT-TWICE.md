# Design It Twice（设计两次）

当用户想为选中的加深候选探索替代接口时，用这个并行子代理模式。基于「Design It Twice」（Ousterhout）——你的第一个想法不太可能是最好的。

使用 [SKILL.md](SKILL.md) 中的词汇——**module**、**interface**、**seam**、**adapter**、**leverage**。

## 流程

### 1. 框定问题空间

启动子代理之前，为选中候选写一份面向用户的问题空间解释：

- 任何新接口必须满足的约束
- 它依赖什么，以及这些依赖属于哪一类（见 [DEEPENING.md](DEEPENING.md)）
- 一个粗略的示意代码草图来落地约束——不是提案，只是让约束具体化的方式

把这个给用户看，然后立即进入步骤 2。子代理并行工作时用户阅读和思考。

### 2. 启动子代理

用 Agent 工具并行启动 3+ 个子代理。每个必须为加深后的模块产出**截然不同**的接口。

给每个子代理一份独立的技术简报（文件路径、耦合细节、[DEEPENING.md](DEEPENING.md) 的依赖类别、接缝后面是什么）。简报与步骤 1 面向用户的问题空间解释无关。给每个 agent 不同的设计约束：

- Agent 1：「Minimize the interface — aim for 1–3 entry points max. Maximise leverage per entry point.」
- Agent 2：「Maximise flexibility — support many use cases and extension.」
- Agent 3：「Optimise for the most common caller — make the default case trivial.」
- Agent 4（如适用）：「Design around ports & adapters for cross-seam dependencies.」

在简报里同时包含 [SKILL.md](SKILL.md) 词汇和 CONTEXT.md 词汇，让每个子代理的命名与架构语言和项目领域语言一致。

每个子代理输出：

1. 接口（类型、方法、参数——加上不变量、顺序、错误模式）
2. 展示调用者如何使用它的用法示例
3. 实现藏在接缝后面的东西
4. 依赖策略和 adapters（见 [DEEPENING.md](DEEPENING.md)）
5. 取舍——哪里 leverage 高、哪里薄

### 3. 呈现并比较

逐个呈现设计，让用户能吸收每个，然后用散文比较。按 **depth**（接口处的 leverage）、**locality**（变更集中在哪里）、**seam placement**（接缝位置）对比。

比较后给出你自己的推荐：你认为哪个设计最强、为什么。如果不同设计的元素能很好组合，提出混合方案。要有主见——用户要的是强判断，不是菜单。
