# Domain Docs（领域文档）

工程 skills 探索代码库时应如何消费本仓库的领域文档。

## 探索前先读这些

- 仓库根的 **`CONTEXT.md`**，或
- 仓库根的 **`CONTEXT-MAP.md`**（如果存在）——它指向每个 context 的一份 `CONTEXT.md`。读与主题相关的每一份。
- **`docs/adr/`** —— 读触及你将工作区域的 ADRs。多 context 仓库里还要检查 `src/<context>/docs/adr/` 的 context 内决策。

如果这些文件不存在，**默默继续**。不要标记缺失；不要建议提前创建。/`domain-modeling` 技能（经 `/grill-with-docs` 和 `/improve-codebase-architecture` 到达）在术语或决策实际落地时惰性创建它们。

## 文件结构

单 context 仓库（大多数仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多 context 仓库（根存在 `CONTEXT-MAP.md`）：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## 使用词汇表的词汇

当你的输出命名领域概念时（issue 标题、重构提案、假设、测试名），使用 `CONTEXT.md` 定义的那个术语。不要漂移到词汇表明确避免的同义词。

如果你需要的概念还没进词汇表，那是个信号——要么你在发明项目不用的语言（重新考虑），要么存在真实缺口（记下来给 `/domain-modeling`）。

## 标记 ADR 冲突

如果你的输出与现有 ADR 矛盾，明确浮出它，而不是默默覆盖：

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
