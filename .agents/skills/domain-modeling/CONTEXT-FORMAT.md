# CONTEXT.md 格式

## 结构

```md
# {Context 名称}

{一两句：这个 context 是什么、为什么存在。}

## Language

**Order**:
{一两句定义}
_Avoid_: Purchase、transaction

**Invoice**:
发给客户、在交付后请求付款的单据。
_Avoid_: Bill、payment request

**Customer**:
下订单的人或组织。
_Avoid_: Client、buyer、account
```

## 规则

- **要有主见。** 多个词表达同一概念时，选最好的一个，把其它列在 `_Avoid_` 下。
- **定义要紧。** 一两句封顶。定义它 IS 什么，不是它做什么。
- **只包含本项目 context 特有的术语。** 通用编程概念（timeout、error types、utility patterns）即使项目大量使用也不该进来。加术语前问：这是这个 context 独有的概念，还是通用编程概念？只有前者属于。
- **出现自然聚类时就分小标题分组。** 如果所有术语属于单一内聚领域，平铺列表也行。

## 单 context vs 多 context 仓库

**单 context（大多数仓库）：** 仓库根一份 `CONTEXT.md`。

**多 context：** 根目录一份 `CONTEXT-MAP.md` 列出 contexts、它们住哪里、如何关联：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — 接收并跟踪客户订单
- [Billing](./src/billing/CONTEXT.md) — 生成发票并处理付款
- [Fulfillment](./src/fulfillment/CONTEXT.md) — 管理仓库拣货与配送

## Relationships

- **Ordering → Fulfillment**: Ordering 发出 `OrderPlaced` 事件；Fulfillment 消费它开始拣货
- **Fulfillment → Billing**: Fulfillment 发出 `ShipmentDispatched` 事件；Billing 消费它生成发票
- **Ordering ↔ Billing**: 共享 `CustomerId` 和 `Money` 类型
```

技能推断用哪种结构：

- 存在 `CONTEXT-MAP.md` 就读它找 contexts
- 只有根 `CONTEXT.md` 就是单 context
- 都没有，就在第一个术语定下来时惰性创建根 `CONTEXT.md`

存在多个 contexts 时，推断当前主题属于哪个。不清楚就问。
