# 词汇表 —— Building Great Skills

什么让技能伟大的领域模型。技能的存在是为了从随机系统里驯出确定性；根本美德是**Predictability（可预测性）**，下面每个术语都是它上面的一个杠杆。这是 [`writing-great-skills`](SKILL.md) 的披露参考。

术语按轴分组：**Invocation（调用）**（技能如何被到达）、**Information Hierarchy（信息层级）**（内容如何排列）、**Steering（操控）**（agent 运行时行为如何被塑造）、**Pruning（修剪）**（如何保持精瘦）。每个**失败模式**住在治愈它的杠杆旁边，标着 _failure mode_。

任何定义里的**加粗术语**都在这份词汇表里定义；按标题找它们。

## Predictability

技能让 agent 每次运行以同样_方式_行为的程度——同样的过程，不是同样的输出（头脑风暴技能应该_可预测地_发散；它的 token 变，行为不变）。每个其他术语服务的根本美德——成本与可维护性是它的症状，不是对手。

_Avoid_: consistency, reliability, robustness, output-determinism

## Invocation

技能如何被到达——以及你为这个选择付的两种负载。

### Model-Invoked

保留 **description** 字段的技能，让 agent 能看到并自主触发——人类仍能输入它的名字，所以模型调用总是_包含_用户触及。没有纯模型状态：description 只_增加_ agent 发现，从不移除人类的。为那种可发现性在每轮付永久 **context load**。其他技能可达，因为让它 agent 可发现的 description 也让它可调用。内容全是 **reference** 的模型可调用技能也是共享参考的一个家：另一个技能能调用它，所以几个技能需要的参考住在同一个地方。只有 agent 必须自己触及技能时才选模型调用；如果它除了手动从不触发，去掉 description，不付上下文负载。

_Avoid_: ability, tool, capability

### User-Invoked

**description** 被剥掉的技能——对 agent 不可见，只有人类输入它的名字才能到达（用户_仅_，而 **model-invoked** 是用户_和_ agent）。把 agent 可发现性换成零 **context load**。因为它没有 description，除了人类没人能触及它：其他技能不能触发它。

_Avoid_: procedure, workflow, command

### Description

技能的机器可读触发词，也是 **model-invoked** 技能被迫一直保持加载的那个 **context pointer**。它的存在_就是_调用轴：保留它，技能是模型可调用的（其他技能可达）；删除它，技能是 **user-invoked**，只有人类可达。模型可调用技能 **context load** 的来源。

_Avoid_: frontmatter, summary

### Context Pointer

agent 上下文里持有的引用，命名某些上下文外的材料并编码到达它的条件。**description** 是顶层上下文指针（上下文窗口 → 技能）；指向披露文件的指针是下一层的同一个对象。它的措辞，不是目标，决定 agent _何时_到达——以及_多可靠_。必须到达的目标后面跟措辞弱的指针是方差 bug：先修措辞，只有磨锐失败才把材料内联。

_Avoid_: link, reference, import

### Context Load

**model-invoked** 技能强加给 agent 上下文窗口的成本——它的 **description** 常载，既花 token 又花注意力。**user-invoked** 技能靠没有 description 逃掉的东西，也是拆出更多模型可调用技能的刹车。

_Avoid_: token cost, context bloat

### Cognitive Load

**user-invoked** 技能强加给人类的成本——他们必须装在脑子里：存在哪些技能、何时伸手拿每个（人是索引）。**model-invocation** 靠 agent 可发现移除的东西，也是拆出更多用户可调用技能的刹车。不是要最小化的成本：它是人类能动性的价格，是有些技能保持用户可调用的原因。花在人的判断重要的地方；不需要就移除。

_Avoid_: human index, burden, overhead

### Router Skill

工作是指向你的其他用户可调用技能的 **user-invoked** 技能——点名每个和何时用它——让人只需记一个技能而不是许多。它只能提示，永远不能触发它们：用户可调用技能没有 **description**，所以除了人类没人能触及它们。用户可调用技能倍增时 **cognitive load** 的疗法。

_Avoid_: dispatcher, menu, registry, index, router procedure

### Granularity

你把技能分多细。更细的划分花两种负载之一：更多 **model-invoked** 技能花 **context load**（更多 description 挤窗口、抢注意力）；更多 **user-invoked** 技能花 **cognitive load**（更多要人记住和伸手拿）。两种切法引导划分。按**调用**，当你有单独触发它的不同 **leading word**——一个你实际在 prompts 里用的触发词——时拆出模型可调用技能。按**序列**，拆一段 **steps**，当一个步骤的 **post-completion steps** 需要隐藏时，因为把它隔离在自己的上下文里清掉后面。当心反向：合并序列把每个步骤的 post-completion steps 暴露给后面，招来过早完成。

_Avoid_: chunking, modularity

## Information Hierarchy

技能的内容如何排列，每块材料在梯子上坐多深。

### Information Hierarchy

技能内容按 agent 多快需要它排名——单个梯子，由两种切法产生：文件内或位移针后，以及步骤或参考。梯级：

- **Steps** —— 文件内，主层
- **Reference**，文件内 —— 次层
- **Reference**，披露的 —— 在 **context pointer** 后

没有 **steps** 的技能只用底下两个梯级——常常是合法的平级集合（例如审查的每条规则在同一级），是好安排，不是坏味道。层级独立于调用：无论全是 steps、全 reference、或两者，技能都可以模型或用户可调用。当技能有 steps 时，本该披露的 in-file reference 埋掉它们，把注意它们变成抛硬币——方差杠杆，不只是可读性杠杆。保持梯顶可读；能推下去的都推下去。

_Avoid_: structure, organization, layout

### Steps

agent 按顺序执行的有序动作——当技能有它们时，内容的顶层，也是挣得在 SKILL.md 里位置的部分。不是每个技能都有 steps：技能可以全是 steps（`tdd`）、全是 **reference**（审查）、或两者都有，独立于调用。每个 step 以 **completion criterion** 结束，清晰或含糊。

_Avoid_: workflow, instructions, choreography

### Reference

agent 按需查阅的材料——定义、事实、参数、示例、条件指令。当技能有 **steps** 时它次于它们；当没有时它是全部内容；或者它完全住在任何技能之外——见 **External Reference**。通过 **context pointers** 到达，是 **progressive disclosure** 的首要候选。

_Avoid_: supporting material, docs, background

### External Reference

住在技能系统外的 **reference**——普通文件、没有 **description**、没有 **steps**、不可调用——任何技能都能指向它。不需要自己触发的共享参考的家，也是两个 **user-invoked** 技能能用的唯一共享家，因为都没有 description、谁都触发不了对方。

_Avoid_: doc, resource, knowledge base

### Progressive Disclosure

把 **reference** 往梯子下移——出 SKILL.md、到 **context pointer** 后——让顶部保持可读。主要不是 token 优化；它是 **information hierarchy** 被保护的方式。由 **branching** 许可：披露只有部分分支需要的东西，内联每条路径都需要的，如果指针在必须材料上触发不可靠，先磨锐措辞，只有那失败才把它拉回内联。

_Avoid_: lazy loading, chunking

### Co-location

把 agent 同时需要的材料放在一个地方——概念的定义、规则和注意事项在单个标题下，不在文件里散落——让读一部分带进邻居。**Information Hierarchy** 的文件内伴侣：层级排一块材料_落多深_；共置决定它落下去后_旁边坐什么_。一块 **reference** 的正确格式没有公式；测试是技能应该读起来像写给 agent 的文档，分组材料那样读、散落的不。与 **Duplication** 不同：那个在一个地方重复一个含义，散落则把一个含义碎成许多。

_Avoid_: grouping, clustering, cohesion

### Sprawl

_Failure mode._ 就是太长的技能——SKILL.md 行数太多——无论它们是否过期或重复。即使全活、全唯一的技能也会臃肿。它花可读性（agent 在能行动前涉过更多，注意力在多余之上变稀）、可维护性（每多一行要保 **relevant**）和 token。疗法是 **information hierarchy**：把 **reference** 推到 **context pointers** 后，按 **branch** 或序列拆分，让每条路径只带它需要的。与 **sediment**（来自过期积累的长度）和 **duplication**（来自重复含义的长度）不同——臃肿是长度本身，无论什么原因。

_Avoid_: bloat, length, size, verbosity

## Steering

把 agent 运行时行为朝 **Predictability** 塑造的杠杆。

### Branch

技能可以被调用的不同方式——技能处理的一个用例——让不同运行走不同路径。许多 steps 的技能可以带许多分支；线性技能没有。

_Avoid_: path, case, fork

### Leading Word

一个紧凑概念——也叫 _Leitwort_——已活在模型预训练里，agent 运行技能时用它思考。它用最少 token 编码一个行为原则，通过调用模型已持有的先验（例如 _lesson_、_proximal zone of development_、_fog of war_、_tracer bullets_）。作为 token 重复，从不作为句子，它跨技能累积一个分布式定义，锚定一整片行为。自己造词如果定义清楚也行，但造词不征召先验——你为定义付的 token 是预训练词免费给的。先伸手拿现有词。

引导词两次服务 **predictability**。正文里它锚定**执行**——概念每次出现 agent 都取同样行为，在平铺参考内部它把注意力聚焦在一类要找的东西上，每次运行征召正确的检查。**description** 里它锚定**调用**——而且不止在技能内部：当同一个词活在你的 prompts、docs 和代码库里，agent 把那套共享语言链接到技能，更可靠地触发它。用你实际想触发技能时用的引导词来措辞 description。

_Avoid_: keyword, term, motif

### Completion Criterion

告诉 agent 一个工作单元完成的条件——它对着判断的目标。两个属性让它成为杠杆，不只是质量。它的**清晰度**（agent 能分辨做完没做完？）抵抗**premature completion**——含糊的边界（「understanding reached」）让 agent 宣布完成、滑到下一步；这个轴需要 _steps_ 才能咬合，因为过早完成是步骤之间的失败。它的**要求度**（要求多少）设定 **legwork**——「every modified model accounted for」逼出彻底工作，而「produce a change list」不会——这个轴_不_受步骤束缚：它也能绑定一片平铺参考，这就是没有 steps 的技能仍带穷尽杠（「every rule applied」）的方式。最强的标准既可检查又穷尽。

_Avoid_: done condition, exit condition, stopping rule

### Legwork

agent 在单个步骤内幕后做的工作——读文件、探索代码库、做改动、挖掘它需要的而不是甩给用户。它活在步骤结构之下：从不写为自己的步骤，潜伏在措辞里，由 agent 而不是技能控制。**post-completion steps** 跨步骤拉力的步骤内对应物。由 **leading word**（_comprehensive_、_thorough_）或要求工作穷尽的 **completion criterion** 提高——包括施加于平铺参考的要求轴，那是驱动平铺参考技能覆盖所有梯级的东西。当要求缺失或 **premature completion** 把步骤截短时，它变薄。

_Avoid_: scope, effort, diligence, coverage

### Post-Completion Steps

当前步骤之后跟的 **steps**。可见时，它们把 agent 向前拉进 **premature completion**——看得越多，拉力越强；防御是把步骤序列拆成两半藏起它们。

_Avoid_: horizon, fog of war, lookahead

### Premature Completion

_Failure mode._ 在真正完成前结束当前步骤，因为 agent 的注意力滑向做完而不是工作。步骤之间的失败：它需要 _steps_ 才发生——没有 steps、提前退出的技能不是过早完成，而是在未满足的要求下的薄 **legwork**。两股力量的拔河：可见的 **post-completion steps**（向前的拉力）和 **completion criterion** 的清晰度（阻力——锐利、可检查的杠站得住；含糊的让路）。模糊是必要条件：锐利的边界无论后面可见多少步骤都抵抗拉力，所以从不赶工的步骤不需要防御。两个杠杆稳住会赶工的步骤，但按序伸手：**先磨锐边界**——它便宜、局部。只有标准不可救药地模糊_并且_你实际观察到赶工，才**藏起后面的步骤**——而且隐藏只在真实上下文边界（用户可调用的交接或子代理派发；内联的模型可调用调用把后面的步骤留在上下文里、什么也没清掉）上有效。薄 legwork 的一个原因，但与之不同：即使步骤跑到完整完成，legwork 也可能薄。

_Avoid_: premature closure, the rush, rushing, shortcutting

### Negation

_Failure mode._ 用禁止操控——告诉 agent _不要_做什么——把被禁行为拖进上下文、让它_更_可得，不是更不可得。_别想大象_，大象就是全部；_永远不要写冗长注释_，冗长就是 agent 刚读到的模式。否定是强激活概念会压过的弱修饰，所以禁令半读成做那件事的指令。它的 **leading word** 是_大象_：禁令点名进框架的任何东西。疗法：提示**正面**——描述目标行为（「write one-line comments」），让被禁的永不开口。禁令只在无法正面表述的硬护栏时挣得位置；即便如此也配上正面目标，让注意力落在做什么上。

_Avoid_: ironic rebound, don't-prompting, the pink elephant

## Pruning

保持技能精瘦——每个疗法配上它治愈的失败。

### Single Source of Truth

每个含义恰好活在一个权威位置、改变技能行为是一处编辑的期望状态。**Duplication** 是它的违反。

_Avoid_: home, canonical location

### Duplication

_Failure mode._ 同一含义被给出不止一个 **single source of truth**。花维护（改一处，必须改其他处）、花 token，并抬升显眼程度——重复一个含义把它在梯子上的权重抬过真实等级。**leading word** 的偶然反例：它靠刻意重复 token 提高注意力，从不重复含义。

_Avoid_: repetition, redundancy

### Relevance

一行是否还影响技能做什么——留什么的透镜。一行要么因为从不影响任务（纯铺陈，或该披露的 **branch**）失去相关性，要么因为过时：随它描述的行为或世界变化而漂出日期。更短的技能更容易保相关，因为每行更便宜检查。与 **no-op** 不同：相关性问一行是否影响任务，不问它是否改变行为。

_Avoid_: load-bearing, staleness, freshness

### Sediment

_Failure mode._ 在技能里沉淀、从不清除的旧内容层，因为加感觉安全、删感觉冒险——所以过期和不相关的行积累，你必须钻穿它们找还活着的。没有修剪纪律的技能默认命运；**relevance** 的缓慢侵蚀，相对于 **duplication** 的重复含义。

_Avoid_: accretion, bloat, cruft, rot

### No-Op

_Failure mode._ 什么都没改变、因为模型默认已经做它的指令——你付 load 告诉 agent 它反正会做的。测试：一行对比默认改变行为吗？一行可以完全 **relevant** 仍然是 no-op。让 **leading word** 免费的同样先验，让 no-op 一文不值。

引导词是_技术_；No-Op 是对_一行_的_裁决_——它们交叉。太弱打不过默认的引导词是 no-op（agent 已经大致彻底时 _be thorough_），修法是通过裁决的更强词（_relentless_），不是不同技术。所以 No-Op 测试——它对比默认改变行为吗？——也是你分级引导词是否挣得它的重复的方式。这是模型相对的，不是读者相对的：两个人对一行是否 no-op 意见不同，是对默认意见不同，靠运行技能解决，不靠辩论。

_Avoid_: redundant instruction, restating the obvious, belaboring
