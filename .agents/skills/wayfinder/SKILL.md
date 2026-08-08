---
name: wayfinder
description: 把一大块工作——超过单个 agent 会话能容纳的量——规划成 issue tracker 上的一张决策 tickets 共享地图，逐个解决，直到通往目标的路清晰。
disable-model-invocation: true
---

一个松散的想法来了——对单个 agent 会话太大，而且裹在迷雾里：从这里到**目标（destination）**的路还看不见。Wayfinding 就是找这条路，不是冲向目标。本技能把路绘成仓库 issue tracker 上的**共享地图（shared map）**，然后逐个解决它的**决策 tickets**——其解决是决策、不是要执行的构建切片的问题——直到路线清晰。

目标因努力而异，命名它是绘图的第一个动作——它塑造每个 ticket。它可能是一份要交接并迭代的规范、一个在规划开始前要锁定的决策、或一个原地进行的变更（如数据结构迁移）。地图与领域无关——工程工作、课程内容，任何符合这个形态的东西。

## 规划，不做

Wayfinder 默认是**规划**：每个 ticket 解决一个决策，地图在路清晰时完成——在某人去做这件事之前没有要决定的东西了。想做活的冲动通常就是你已到达地图边缘、该交接的信号。一次努力可以在其 **Notes** 中覆盖这一点——把执行带进地图本身——但缺省地，产出决策，而不是交付物。

## 用名字引用

每张地图和 ticket 都是 issue，所以它有**名字**——它的标题。在人类读到的一切里——叙述、地图的 Decisions-so-far——都用名字引用它，绝不用裸 id、编号或 slug。一墙 `#42, #43, #44` 没法读；名字一眼可读。id 和 URL 没有消失——名字包裹着它的链接——但它们骑在名字_里面_，绝不代替名字。

## 地图

地图是本仓库 issue tracker 上的单个 issue，标 `wayfinder:map`——规范工件。它的 tickets 是地图的子 issues。

地图是**索引**，不是仓库。它列出已做的决策并指向承载其细节的 tickets；一个决策恰好活在一个地方——它的 ticket——所以地图从不复述它，只给要点和链接。

**地图、其子 tickets、阻塞、frontier 查询物理上住在哪里，取决于 tracker。** 应该已经向你提供了 issue tracker——如果没有，运行 `/setup-matt-pocock-skills`。查阅 tracker 文档的「Wayfinding operations」部分，看_这个_仓库如何表达它们。如果没有提供 tracker，默认用本地 markdown tracker。

### 地图正文

整张地图的低分辨率视图，每会话加载一次。开放 tickets **不**列出来——它们是开放的子 issues，靠查询发现。

```markdown
## Destination

<到达这张地图终点是什么样——这份努力正在找路走向的规范、决策或变更。一两行；每个会话在选 ticket 前都先据此定向。>

## Notes

<领域；每个会话应查阅的技能；本次努力的常设偏好>

## Decisions so far

<!-- 索引——每个已关闭 ticket 一行：足以判断相关性，然后放大链接看 ticket 承载的细节 -->

- [<closed ticket title>](link) — <一行答案要点>

## Not yet specified

<!-- 见「迷雾（Fog of war）」：范围内的、你还无法 ticket 化的迷雾；随 frontier 推进而升级 -->

## Out of scope

<!-- 见「Out of scope」：被裁定超出目标的活；已关闭，永不升级 -->
```

### Tickets

每个 ticket 是地图的**子 issue**；tracker 的 issue id 是它的身份。它的正文是问题，大小适合一个 100K token 的 agent 会话：

```markdown
## Question

<这个 ticket 解决的决策或调查>
```

每个 ticket 带一个 `wayfinder:<type>` 标签——`research`、`prototype`、`grilling`、`task` 之一（见 [Ticket Types](#ticket-types)）。

会话**认领**一个 ticket 的方式是，在任何工作之前**先**把它分配给自己——驱动地图的开发者——让并发会话跳过它。那个 assignee 就是认领：开放、未分配的 ticket 就是未认领。

阻塞用 tracker 的**原生**依赖关系——这至关重要，因为它让 frontier 在 tracker 自己的 UI 里_可视化_，人类不用打开地图就能看到什么可捡。只有缺乏原生阻塞的 tracker 才回退到正文约定。当阻塞它的每个 ticket 都已关闭时，ticket 就是**未阻塞**的；**frontier** 是开放、未阻塞、未认领的子 issues——已知的边缘。

答案不是正文的一部分——它在解决时记录（见 [Work through the map](#work-through-the-map)）。解决 ticket 时产生的资产从 issue 链接，不粘贴进来。

## Ticket 类型

每个 ticket 要么是 **HITL**——人类在环里，_与_一个为自己说话的人类一起做——要么是 **AFK**——由 agent 独自驱动。HITL ticket 只能通过那种实时交流解决；agent 绝不代替人类那一侧（一个回答自己问题的 grilling agent 已经破坏了这条）。

- **Research（AFK）**：阅读文档、第三方 API 或本地资源（如知识库），浮出一个决策等待的事实。由 `/research` **子代理**解决。当需要当前工作目录之外的知识时使用。
- **Prototype（HITL）**：通过做一个便宜、粗糙、具体的工件来提高讨论的分辨率——大纲、粗稿、stub，或经 /prototype 技能的 UI/逻辑代码。把原型链接为资产。当「应该长什么样」或「应该怎么表现」是关键问题时使用。
- **Grilling（HITL）**：对话。默认情况。总是调用 /grilling 和 /domain-modeling 技能。
- **Task（HITL 或 AFK）**：必须在_决策_之前发生的动手工作——没有要决定的、原型化的或研究的，但讨论被它阻塞直到完成。注册一个服务以便评判它的 API、配置访问权、搬数据以便看到它的形态。这是唯一_做_而不是_决定_的类型——它靠解锁一个决策挣得位置，而不是靠交付目标。agent 能独立驱动的就自己驱动（AFK）；否则给人类一份精确清单（HITL）。工作完成时解决；答案记录做了什么，以及后续 tickets 依赖的任何结果事实（凭据位置、新 URL、行数）。

## 迷雾（Fog of war）

地图_刻意_不完整：不要绘出你还看不见的东西。在活跃 tickets 之外是**迷雾**——你能说会来但还钉不住的决策和调查的模糊视野，因为它们悬在仍然开放的问题上。解决一个 ticket 会清开它前面的雾，把现在能明确的升级成新 tickets——一次一个，直到通往目标的路清晰、没有 tickets 剩下。

地图的 **Not yet specified** 部分就是写下那个模糊视野的地方：怀疑中的问题、以后要重访的区域。它是_通向_目标的未发现 frontier——这里的一切都在范围内，只是还不够锐利到 ticket 化。按视野允许的松散或完整程度写；它同时充当协作者阅读努力方向的指路牌。

**雾还是 ticket？** 测试是你能不能现在就精确说出问题——_不是_你能不能现在就回答它。

- **能 ticket 化当**问题已经锐利——即使它被阻塞、你还不能对它行动。
- **Not yet specified 当**你还不能说得那么锐利。不要把雾预切成 ticket 大小的块：它比 ticket 粗，一块补丁在 frontier 到达后可能升级成几个 tickets，或一个都没有。

**Not yet specified** 排除已经决定的（Decisions so far）、已经是活跃 ticket 的、以及范围外的（下一节）。

## Out of scope

雾只会_朝着_目标聚集。目标固定了范围，所以它之外的工作**超出范围**——它不是雾，不属于 **Not yet specified**。它在地图上拥有自己的 **Out of scope** 部分：你自觉排除在_本次_努力之外的工作。是范围，不是锐利度，把它放到这里。

范围外的工作永不升级——frontier 在目标处停止——所以只有目标被重画时它才回来，而且是以全新努力的形式，不是恢复。

把某样东西裁定为范围外是划界行为，不是路线上的步骤。当已经存在的 ticket 被发现坐在目标之外——绘图时误纳入、或由一次解决暴露——**关闭它**（关闭的 ticket 明确地不在 frontier 上），并在 **Out of scope** 部分留一行：要点加为什么超范围，链接关闭的 ticket。它不进 **Decisions so far**，那记录的是实际走过的路——范围边界不是路上的步骤。

## 调用

两种模式。无论哪种，**每个会话绝不多于一个 ticket**——research tickets 除外。

### 绘制地图

用户带着松散想法调用。

1. **命名目标。** 运行 `/grilling` 和 `/domain-modeling` 会话，钉住这张地图在找路走向什么——规范、决策或变更。目标固定范围，所以先定它。
2. **绘制 frontier。** 再拷问，这次**广度优先**：在整个空间铺开而不是深挖任何一条线，浮出开放决策和现在能迈的第一步。**如果没有浮出迷雾**——通往目标的路已经清晰、整个旅程小到单会话装得下——你不需要地图。停下，问用户想怎么进行。
3. **创建地图**（标签 `wayfinder:map`）：填好 Destination 和 Notes，Decisions-so-far 留空，把雾勾进 **Not yet specified**。
4. **创建你现在能明确的 tickets** 作为地图的子 issues——然后在**第二遍**接线阻塞边界（issues 需要 id 才能互相引用）。接线把它们排成 frontier 和被阻塞；现在还不能明确的都留在雾里——**Not yet specified** 部分。
5. **发射 research 子代理。** 对你刚创建的每个 `research` ticket，启动一个 `/research` 子代理并行解决它，把发现捕获在临时 `research/<name>` 分支上，并从 ticket 留下上下文指针。
6. 停下——绘图是一个会话的活；它手工解决不了任何东西。

### 走地图

用户带地图（URL 或编号）调用。ticket 是**可选**的——没有的话，你挑下一个决策，不是用户。

1. 加载**地图**——低分辨率视图，不是每个 ticket 正文。
2. 选 ticket。用户指名就用它。否则按顺序取第一个 frontier ticket。**认领它**：在任何工作之前分配给自己。
3. 解决它——**按需缩放**：按需抓取任何相关或已关闭 ticket 的完整正文；调用 `## Notes` 块点名的技能。拿不准就用 `/grilling` 和 `/domain-modeling`。
4. 记录解决：把答案发成**解决评论**，**关闭** issue，并向地图的 Decisions-so-far **追加上下文指针**。
5. 添加新浮出的 tickets（create-then-wire）；把答案已使其可明确的雾升级，从 **Not yet specified** 清掉每个升级的补丁，让它只作为新 ticket 存在。如果答案揭示某个 ticket——这个或另一个——坐在目标之外，**裁定它超范围**，而不是在路线上解决它。如果决策使地图其它部分失效，更新或删除那些 tickets。

用户可能并行运行未阻塞的 tickets，所以预期其它会话在并发编辑 tracker。
