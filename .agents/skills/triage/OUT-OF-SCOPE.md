# Out-of-Scope 知识库

仓库里的 `.out-of-scope/` 目录存储被拒绝功能请求的持久记录。它有两个用途：

1. **机构记忆** —— 功能为什么被拒，让 issue 关闭后推理不丢失
2. **去重** —— 新 issue 匹配先前拒绝时，技能能浮出先前决策，而不是重新争论

## 目录结构

```
.out-of-scope/
├── dark-mode.md
├── plugin-system.md
└── graphql-api.md
```

每个**概念**一个文件，不是每个 issue 一个。请求同一件事的多个 issue 归入一个文件。

## 文件格式

文件用松弛、可读的风格写——更像一份短设计文档，而不是数据库条目。用段落、代码示例和例子让推理对第一次遇到它的人清晰有用。

```markdown
# Dark Mode

This project does not support dark mode or user-facing theming.

## Why this is out of scope

The rendering pipeline assumes a single color palette defined in
`ThemeConfig`. Supporting multiple themes would require:

- A theme context provider wrapping the entire component tree
- Per-component theme-aware style resolution
- A persistence layer for user theme preferences

This is a significant architectural change that doesn't align with the
project's focus on content authoring. Theming is a concern for downstream
consumers who embed or redistribute the output.

```ts
// The current ThemeConfig interface is not designed for runtime switching:
interface ThemeConfig {
  colors: ColorPalette; // single palette, resolved at build time
  fonts: FontStack;
}
```

## Prior requests

- #42 — "Add dark mode support"
- #87 — "Night theme for accessibility"
- #134 — "Dark theme option"
```

### 命名文件

为概念用简短、描述性的 kebab-case 名字：`dark-mode.md`、`plugin-system.md`、`graphql-api.md`。名字要足够可辨认，让浏览目录的人不用打开文件就知道拒绝的是什么。

### 写理由

理由要有实质——不是「我们不想要」，而是为什么。好理由引用：

- 项目范围或理念（「This project focuses on X; theming is a downstream concern」）
- 技术约束（「Supporting this would require Y, which conflicts with our Z architecture」）
- 战略决策（「We chose to use A instead of B because...」）

理由要持久。避免引用临时情况（「we're too busy right now」）——那些不是真拒绝，是延期。

## 何时检查 `.out-of-scope/`

triage 期间（步骤 1：收集上下文），读 `.out-of-scope/` 里所有文件。评估新 issue 时：

- 检查请求是否匹配现有 out-of-scope 概念
- 匹配按概念相似性，不是关键词——「night theme」匹配 `dark-mode.md`
- 有匹配就浮出给维护者：「This is similar to `.out-of-scope/dark-mode.md` — we rejected this before because [reason]. Do you still feel the same way?」

维护者可以：

- **确认** —— 新 issue 被加进现有文件的「Prior requests」列表，然后关闭
- **重新考虑** —— out-of-scope 文件被删除或更新，issue 走正常 triage
- **不同意** —— issues 相关但不同，走正常 triage

## 何时写 `.out-of-scope/`

只有**enhancement**（不是 bug）被作为 `wontfix` *拒绝*时。这同样适用于 enhancement PR——被拒的 PR 在这里记录，让同样的请求不会作为新代码回来。

当东西因为**已实现**而被 `wontfix` 关闭时，**不要**写这里。那是已构建的功能，不是被拒绝的；记录它会用假拒绝毒化去重检查。关闭评论应指向功能已存在的位置。

流程：

1. 维护者判定功能请求超出范围
2. 检查是否已有匹配的 `.out-of-scope/` 文件
3. 有：把新 issue 追加到「Prior requests」列表
4. 没有：用概念名、决策、理由和第一个 prior request 创建新文件
5. 在 issue 上发评论解释决策并提及 `.out-of-scope/` 文件
6. 用 `wontfix` 标签关闭 issue

## 更新或移除 out-of-scope 文件

如果维护者改变了对先前拒绝概念的想法：

- 删除 `.out-of-scope/` 文件
- 技能不需要重开旧 issues——它们是历史记录
- 触发重新考虑的新 issue 走正常 triage
