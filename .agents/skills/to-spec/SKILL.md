---
name: to-spec
description: 把当前对话变成规范并发布到项目 issue tracker——不访谈，只综合已经讨论过的东西。
disable-model-invocation: true
---

本技能拿当前对话上下文和代码库理解，产出一份规范。**不要**访谈用户——只综合你已经知道的。

应该已经向你提供了 issue tracker 和 triage 标签词汇——如果没有，运行 `/setup-matt-pocock-skills`。

## 流程

1. 如果还没探索过，探索仓库了解代码库当前状态。整个规范使用项目的领域词汇表词汇，并尊重所触及区域的任何 ADR。

2. 勾画你将测试该功能的接缝。现有接缝应优先于新接缝。用尽可能高的接缝。如果需要新接缝，在你能到的最高点提议。跨代码库的接缝越少越好——理想数量是一。

   与用户确认这些接缝符合他们的预期。

3. 用下面的模板写规范，然后发布到项目 issue tracker。打上 `ready-for-agent` triage 标签——无需额外 triage。

<spec-template>

## Problem Statement（问题陈述）

用户面临的问题，从用户视角出发。

## Solution（方案）

问题的解决方案，从用户视角出发。

## User Stories（用户故事）

一份**很长的**、编号的用户故事列表。每个用户故事的格式：

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

这份用户故事列表应该极其详尽，覆盖该功能的方方面面。

## Implementation Decisions（实现决策）

已做出的实现决策列表。可以包括：

- 将构建/修改的模块
- 将修改的模块接口
- 来自开发者的技术澄清
- 架构决策
- 模式变更
- API 契约
- 具体交互

**不要**包含具体文件路径或代码片段。它们可能很快就过时。

例外：如果原型产出的片段比散文更精确地编码了一个决策（状态机、reducer、schema、类型形态），把它内联进相关决策，并简短注明它来自原型。裁到决策丰富的部分——不是能跑的演示，只是重要的部分。

## Testing Decisions（测试决策）

已做出的测试决策列表。包括：

- 好测试是什么的描述（只测外部行为，不测实现细节）
- 将测试哪些模块
- 测试的先例（即代码库中相似类型的测试）

## Out of Scope（范围外）

对这份规范范围外内容的描述。

## Further Notes（补充说明）

关于该功能的任何进一步说明。

</spec-template>
