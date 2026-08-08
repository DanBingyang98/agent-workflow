---
name: writing-great-skills
description: 写好和编辑好技能——让技能可预测的词汇与原则的参考。
disable-model-invocation: true
---

技能的存在是为了从随机系统里驯出确定性。**可预测性（Predictability）**——agent 每次运行走同一个_过程_，而不是产出相同输出——是根本美德；下面的每个杠杆都为它服务。

**加粗术语**在 [`GLOSSARY.md`](GLOSSARY.md) 里定义；完整含义去那里查。

## 调用

两个选择，交易不同的成本：

- **模型可调用（model-invoked）** 技能保留 **description**，让 agent 能自主触发它，_而且_其他技能能触及它（你也能输入它的名字）。它贡献 **context load**——description 每轮都坐在窗口里。机制：省略 `disable-model-invocation`，写面向模型的 description，带丰富的触发措辞（「Use when the user wants…, mentions…」）。
- **用户可调用（user-invoked）** 技能把 description 从 agent 的触及范围剥掉：只有你输入它的名字才能调用——其他技能不能。零 context load，但花 **cognitive load**：_你_是必须记住它存在的索引。机制：设 `disable-model-invocation: true`；`description` 变成面向人类的——一行摘要，触发列表剥掉。

只有 agent 必须自己触及技能、或另一个技能必须触及它时，才选模型可调用。如果它只能手动触发，就做成用户可调用，不付 context load。

当用户可调用技能多到你记不住，堆积的 cognitive load 由**路由器技能（router skill）** 治愈：一个用户可调用技能，点名其他技能和何时用每个。

## 写 description

模型可调用的 **description** 做两件事——陈述技能是什么，列出应触发它的**分支（branches）**。每个词都增加 **context load**，所以它比正文更需要修剪：

- **前置技能的 leading word** —— description 是它做调用工作的地方。
- **每分支一个触发词。** 给同一分支换同义词是 **duplication**——「build features using TDD … asks for test-first development」是同一个分支写两遍。合并；只留真正不同的分支。
- **砍掉正文已经承载的身份。** 让 description 只留触发词，加任何「when another skill needs…」的触及条款。

## 信息层级

技能由两种内容类型构建——**steps（步骤）** 和 **reference（参考）**——自由混合：技能可以全是 steps、全是 reference、或两者都有。核心决策是用哪个、每个坐在**信息层级（information hierarchy）** 的哪里，一个按 agent 多快需要材料排名的梯子：

1. **In-skill step** —— `SKILL.md` 里的有序动作，主层：agent 按顺序做什么。每个 step 以**完成标准（completion criterion）** 结束，告诉 agent 工作完成的条件。让它_可检查_（agent 能分辨做完没做完）以及、在重要处、_穷尽_（「every modified model accounted for」，不是「produce a change list」）——含糊的标准招来**过早完成（premature completion）**。
2. **In-skill reference** —— `SKILL.md` 里的定义、规则或事实，按需查阅。常常是合法的平级集合（例如审查的每条规则在同一级）——好安排，不是坏味道。_本技能全是 reference。_
3. **External reference（外部参考）** —— 从 `SKILL.md` 推出去、放在单独文件的 reference，由 **context pointer** 到达，只有指针触发时才加载。（横跨_披露的_参考——同目录的兄弟文件如 `GLOSSARY.md`，仍是技能一部分——到完全**外部参考**，住在技能系统之外、任何技能都能指向。）

高要求的完成标准驱动彻底的 **legwork（跑腿）**——agent 在工作内做的挖掘——无论技能有没有 steps，因为「every rule applied」像「every step done」绑定序列一样绑定平铺 reference。

推得太少，顶部臃肿；推得太多，你藏起 agent 真正需要的材料。那个张力就是整个决策。

**渐进披露（Progressive disclosure）** 是往梯子下走的动作——出 `SKILL.md`、进链接文件——让顶部保持可读。机制：技能文件夹里一个链接的 `.md` 文件，按它装的内容命名（本技能把完整定义披露给 `GLOSSARY.md`）。有些技能有不止一种用法，每种不同用法是一个**分支（branch）**——不同运行走技能里的不同路径。分支是最干净的披露测试：内联每个分支都需要的，把只有部分分支触达的推到位移指针后面。**context pointer** 的_措辞_，不是目标，决定 agent 何时、多可靠地到达材料。

梯子决定一块材料_落多深_，**共置（co-location）** 决定它落下去后_旁边坐什么_：把概念的定义、规则和注意事项放在一个标题下而不是散落，让读一部分把邻居带进来。

## 何时拆分

**粒度（Granularity）** 是你把技能分多细，每次切割花两种 load 之一，所以只在切割挣得它时拆。两种切法：

- **按调用** —— 当你有应该单独触发它的不同 **leading word**、或另一个技能必须触及它时，拆出一个**模型可调用**技能。你为新的常载 **description** 付 **context load**，所以那个独立触及必须值得。
- **按序列** —— 当仍在前面的 steps（一个 step 的 **post-completion steps**）诱使 agent 赶工眼前的那个（**premature completion**）时，拆一段 **steps**。让它们看不见会鼓励 agent 在当前任务上做更多 **legwork**。

## 修剪

让每个含义保持**单一事实来源（single source of truth）**：一个权威位置，改变行为就是一处编辑。

逐行检查**相关性（relevance）**：它还对技能做什么有影响吗？

然后逐句、不只逐行猎**no-ops**：孤立地对每句跑 no-op 测试，一句失败就删整句，而不是从它里面修剪词。要激进——失败的大部分散文该走，不是重写。

## Leading words

**leading word（引导词）** 是一个已活在模型预训练里的紧凑概念，agent 运行技能时用它思考（例如 _lesson_、_fog of war_、_tracer bullets_）。在文本中反复出现（虽然不必然——强引导词可能只需一次），它以最少 token 累积一个分布式定义，通过征召模型已持有的先验锚定一整片行为。

它两次服务可预测性。在正文里锚定_执行_：词每次出现 agent 都取同样行为。在 description 里锚定_调用_：当同一个词活在你的 prompts、docs 和代码里，agent 把那套共享语言链接到技能，更可靠地触发它。

猎取重构技能用 leading words 的机会。在三个地方展开的三元组（**duplication**）、花一句话指向一个想法的 description——每个都是乞求**折叠**成单个 token 的段落。例子：

- "fast, deterministic, low-overhead" -> _tight_ —— 把一个阶段里重述的一个品质收进一个预训练词（a _tight_ loop）。
- "a loop you believe in" -> _red_ —— 把模糊门变成二值可观察状态（loop 在这个 bug 上 _red_，或不红）。

你赢两次：更少 token，_以及_一个让 agent 挂思考的更锐利钩子。假设每个技能都带着 leading words 会退休的重述——去找它们。

## 失败模式

用这些诊断用户对技能可能遇到的问题。

- **过早完成（Premature completion）** —— 在真正完成前结束一个 step，注意力滑向_做完_。按序防御：先磨锐完成标准（便宜、局部）；只有它不可救药地模糊_并且_你观察到赶工，才通过拆分（序列切法）藏起 post-completion steps。
- **重复（Duplication）** —— 同一含义出现在不止一个地方。花维护和 token，并把含义在梯子上的显眼程度抬过它真实等级。
- **沉积（Sediment）** —— 旧层沉淀下来从不清理，因为加感觉安全、删感觉冒险。没有修剪纪律的技能默认命运。
- **臃肿（Sprawl）** —— 技能就是太长，即使每行都活且唯一。伤害可读性和可维护性，浪费 token。疗法是梯子：把 **reference** 披露到位移指针后，按 **branch** 或序列拆分，让每条路径只带它需要的。
- **No-op** —— 一行模型默认已经遵守的东西，你付 load 说废话。测试：它对默认行为有改变吗？弱的 leading word（agent 已经大致彻底时 _be thorough_）是 no-op；修法是更强的词（_relentless_），不是不同技术。
- **否定（Negation）** —— 用禁止来操控会反弹：_don't think of an elephant_ 点出大象、让它更可得，不是更不可得。提示**正面**——陈述目标行为，让被禁的永不开口；只有你不能正面表述的硬护栏才保留禁止，即便如此也要配上该做什么。
