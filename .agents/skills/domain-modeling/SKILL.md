---
name: domain-modeling
description: 构建并磨锐项目的领域模型。当用户想钉住领域术语或统一语言、记录架构决策，或其它技能需要维护领域模型时使用。
---

# Domain Modeling（领域建模）

在设计过程中主动构建并磨锐项目的领域模型。这是*主动*的纪律——质疑术语、发明边界用例、在术语结晶的那一刻把词汇表和决策写下来。（仅仅*读* `CONTEXT.md` 获取词汇不算本技能——那是任何技能都能做的一行习惯。本技能用于你在*改变*模型，而不只是消费它。）

## 文件结构

大多数仓库只有一个 context：

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

如果根目录存在 `CONTEXT-MAP.md`，仓库有多个 contexts。地图指向每个 context 的位置：

```
/
├── CONTEXT-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── CONTEXT.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── CONTEXT.md
│       └── docs/adr/
```

惰性创建文件——只有有东西要写时才创建。如果 `CONTEXT.md` 不存在，第一个术语定下来时创建它。如果 `docs/adr/` 不存在，第一个 ADR 需要时创建它。

## 会话期间

### 对照词汇表质疑

当用户使用的术语与 `CONTEXT.md` 中现有语言冲突时，立即指出。「你的词汇表把 'cancellation' 定义为 X，但你似乎指的是 Y——到底是哪个？」

### 磨锐模糊语言

当用户使用模糊或重载的术语时，提出精确的规范术语。「你说的 'account'——是指 Customer 还是 User？它们是不同的东西。」

### 讨论具体场景

讨论领域关系时，用具体场景压力测试。发明探针边界情况的场景，逼用户对概念之间的边界精确起来。

### 与代码交叉对照

当用户陈述某东西如何工作时，检查代码是否同意。发现矛盾就摆出来：「你的代码取消整个 Orders，但你刚说可以部分取消——哪个是对的？」

### 就地更新 CONTEXT.md

术语定下来时就在那里更新 `CONTEXT.md`。不要攒批——发生时即刻捕获。使用 [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md) 中的格式。

`CONTEXT.md` 必须完全不含实现细节。不要把 `CONTEXT.md` 当规范、草稿纸或实现决策的仓库。它是词汇表，仅此而已。

### 克制地提供 ADR

只有三条同时成立时才主动提出创建 ADR：

1. **难逆转** —— 以后改主意的成本有实际意义
2. **没有上下文会令人惊讶** —— 未来读者会想「他们为什么这么做？」
3. **真实取舍的结果** —— 存在真实替代方案，你出于具体原因选了其中一个

三条缺一就跳过 ADR。使用 [ADR-FORMAT.md](./ADR-FORMAT.md) 中的格式。
