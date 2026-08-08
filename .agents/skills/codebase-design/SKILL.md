---
name: codebase-design
description: 设计深模块的共享词汇。当用户想设计或改进模块接口、寻找加深机会、决定接缝放在哪里、让代码更可测试或更易被 AI 导航，或其它技能需要深模块词汇时使用。
---

# Codebase Design（代码库设计）

设计**深模块（deep modules）**：小接口背后藏大量行为，放在干净的接缝上，通过该接口可测试。在任何设计或重构代码的地方使用这套语言和原则。目标是调用者的 leverage、维护者的 locality、所有人的可测试性。

## 词汇表

严格使用这些术语——不要替换成「component」「service」「API」或「boundary」。语言一致正是全部意义。

**Module（模块）** —— 任何有接口和实现的东西。刻意与规模无关：一个函数、类、包，或跨层切片。_Avoid_: unit、component、service。

**Interface（接口）** —— 调用者正确使用模块所需知道的一切：类型签名，也包括不变量、顺序约束、错误模式、所需配置和性能特征。_Avoid_: API、signature（太窄——它们只指类型层面的表面）。

**Implementation（实现）** —— 模块内部的东西，它的代码本体。与 **Adapter** 区分：一个东西可以是小 adapter 配大实现（一个 Postgres repo），也可以是大 adapter 配小实现（一个内存 fake）。当主题是接缝时说「adapter」；否则说「implementation」。

**Depth（深度）** —— 接口处的 leverage：调用者（或测试）每学一单位接口就能调用的行为量。当大量行为藏在小接口后面时模块是**深**的，当接口几乎和实现一样复杂时是**浅**的。

**Seam（接缝）** _(Michael Feathers)_ —— 一个无需在该处编辑就能改变行为的地方；模块接口所在的*位置*。接缝放哪里本身是一个设计决定，与它后面放什么无关。_Avoid_: boundary（与 DDD 的 bounded context 重载）。

**Adapter（适配器）** —— 在接缝处满足接口的具体东西。描述*角色*（它填补哪个槽位），而不是实质（里面是什么）。

**Leverage（杠杆）** —— 调用者从深度得到的东西：每学一单位接口获得更多能力。一份实现回馈 N 个调用点和 M 个测试。

**Locality（局部性）** —— 维护者从深度得到的东西：变更、bug、知识、验证集中在同一个地方，而不是散布在调用者之间。修一次，到处修好。

## 深 vs 浅

**深模块** = 小接口 + 大量实现：

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**浅模块** = 大接口 + 少量实现（避免）：

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

设计接口时，问：

- 我能减少方法数量吗？
- 我能简化参数吗？
- 我能把更多复杂性藏进内部吗？

## 原则

- **深度是接口的属性，不是实现的。** 深模块内部可以由小的、可 mock 的、可替换的部件组成——它们只是不属于接口。模块可以有**内部接缝**（实现私有、供自己的测试用）和接口处的**外部接缝**。
- **删除测试（The deletion test）。** 想象删除这个模块。如果复杂性消失，它是透传。如果复杂性在 N 个调用者处重现，它物有所值。
- **接口就是测试面。** 调用者和测试穿过同一个接缝。如果你想测试到接口*里面去*，模块的形态大概错了。
- **一个 adapter 意味着假设性接缝；两个意味着真实接缝。** 除非有什么东西真的跨接缝变化，否则不要引入接缝。

## 为可测试性设计

好接口让测试变得自然：

1. **接受依赖，不要创建依赖。**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **返回结果，不要制造副作用。**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **小表面。** 方法更少 = 需要的测试更少。参数更少 = 测试设置更简单。

## 关系

- 一个 **Module** 恰好有一个 **Interface**（它呈现给调用者和测试的表面）。
- **Depth** 是 **Module** 的属性，对着它的 **Interface** 衡量。
- **Seam** 是 **Module** 的 **Interface** 所在之处。
- **Adapter** 坐在 **Seam** 上并满足 **Interface**。
- **Depth** 为调用者产生 **Leverage**，为维护者产生 **Locality**。

## 被拒绝的框架

- **把深度当实现行数与接口行数之比**（Ousterhout）：奖励注水实现。我们用 depth-as-leverage 代替。
- **把「Interface」当 TypeScript 的 `interface` 关键字或类的公共方法**：太窄——这里的 interface 包含调用者需要知道的每一条事实。
- **「Boundary」**：与 DDD 的 bounded context 重载。说 **seam** 或 **interface**。

## 深入

- **给定依赖簇的加深**——见 [DEEPENING.md](DEEPENING.md)：依赖分类、接缝纪律、replace-don't-layer 测试。
- **探索替代接口**——见 [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md)：启动并行子代理，用几种截然不同的方式设计接口，然后在 depth、locality 和接缝位置上比较。
