# AGENTS

> **范围**：全局默认。
减少常见 LLM 编码错误的行为准则。按需与项目特定指令结合使用。

> **元约束（最高优先级）**：本文件只承载**导航**与**长期约束**，不是事实手册。凡涉及具体值（端口、版本、业务码、路径、接口签名），一律以代码现状为准；发现文档与代码矛盾，当场修正本文件。决策背景见 `.agents/docs/adr/0007-rule-doc-boundary.md`。

**取舍：** 这些准则偏向谨慎而非速度。对琐碎任务，自行判断。

## 1. 先思考，后编码

**不要假设。不要隐藏困惑。把取舍摆到台面上。**

实现之前：
- 明确陈述你的假设。不确定就问。
- 存在多种解读时，把它们都摆出来——不要默默选一个。
- 存在更简单的方案时，说出来。理由充分时提出异议。
- 有什么不清楚，停下。点名困惑。问。

## 2. 简单优先

**解决问题所需的最少代码。不要投机。**

- 不添加超出要求的功能。
- 不为一次性代码做抽象。
- 不要未经请求的「灵活性」或「可配置性」。
- 不为不可能的场景做错误处理。
- 如果写了 200 行而 50 行能完成，重写它。

问自己：「资深工程师会说这过度复杂吗？」会就简化。

## 3. 外科手术式修改

**只碰必须碰的。只清理自己的烂摊子。**

编辑现有代码时：
- 不要「改进」相邻的代码、注释或格式。
- 不要重构没坏的东西。
- 匹配现有风格，即使你会写得不一样。
- 发现无关的死代码，提出来——不要删。

当你的改动制造孤儿时：
- 移除因**你的**改动而不再使用的导入/变量/函数。
- 除非被要求，不要移除既有的死代码。

检验：每一行改动都应能直接追溯到用户的请求。

## 4. 目标驱动执行

**定义成功标准。循环直到验证。**

把任务变成可验证的目标：
- 「加校验」→「为无效输入写测试，然后让它们通过」
- 「修 bug」→「写复现它的测试，然后让它们通过」
- 「重构 X」→「重构前后确保测试通过」

多步骤任务，陈述简要计划：
1. [步骤] → 验证：[检查]
2. [步骤] → 验证：[检查]
3. [步骤] → 验证：[检查]

强成功标准让你独立循环。弱标准（「让它跑起来」）需要不断澄清。

---

**这些准则生效的标志是：** diff 里不必要的改动更少、因过度复杂造成的重写更少、澄清问题出现在实现之前而不是犯错之后。

---

## 工作流：dev 中心分支模型（套件默认）

合并只在托管平台 PR 服务端发生，本地不做整合合并。

- **分支**：`main` = 生产镜像，`develop` = 远程集成分支，两者 PR-only（禁直推/强推/删除）。工单分支 `feature/*`、`fix/*`、`docs/*`、`chore/*` 从 `origin/develop` 切；`hotfix/*` 从 `origin/main` 切，PR 合 `main` 后当天必须回合 `develop`（发布闸兜底）。
- **发布**：唯一通道 = `develop→main` 发布 PR，一律人工审合，PR 描述必填工单列表与测试记录；合并后打 `release/<日期>` tag。
- **合并方法**：一律 merge，禁 squash/rebase（改写 sha 会与 `branch -D` 拦截互锁成清理死锁）。
- **提交与同步**：Conventional Commits，一次提交只干一件事。动 git 前先 `git fetch`；工单分支落后基线会被 pre-push 硬拦（pre-commit 软提醒），rebase 后 `--force-with-lease` 重推（仅白名单工单分支）。
- **人工闸门**：工单分支完成后暂停，汇报改动、测试与 commit 列表；未经用户明确授权，不推送、不开 PR；发布 PR 禁 AI 自合。
- **危险操作**：shell 层拦截 `rm -rf`、`git reset --hard`、`git clean -f`、裸 `git push --force`、`git branch -D`、`git merge --squash` 等；受保护分支任何直推都被 pre-push 拦截。

完整流程见 `.agents/docs/dev-integration-workflow.md`，PR 模板见 `.agents/docs/pr-template.md`。

---

## 代码发现 —— 决策流

先按问题主题选工具，再按可用性选。各工具的能力与命令见下方对应部分。

| 问题主题 | 首选 | 然后 |
| --- | --- | --- |
| 精确、符号级：按名字找函数/类/文件、谁调用它、它调用什么、死代码、影响分析 | `codebase-memory-mcp` | Graphify → grep |
| 关系或高层：模块/服务/架构关系、跨文件或跨仓库连接、「X 与 Y 怎么相关」、广泛导航 | Graphify（当 `graphify-out/graph.json` 存在） | `codebase-memory-mcp` → grep |
| 字符串字面量、错误消息、配置值、非代码文件 | grep | — |

平局裁决：
- 问题点名具体符号就是符号级；问结构、层或关系就是关系级。跨两者时按主题分类。
- 首选与回退矛盾时，信任 `codebase-memory-mcp` 结果（实时索引胜过可能过期的图），并报告冲突而不是默默选一个。

可用性：
- `codebase-memory-mcp` 只在服务器已连接且项目已索引时算可用；Graphify 只在 `graphify-out/graph.json` 存在时可用。只有一个可用就用它，无论主题；都不可用就用 grep，不要卡住。
- 首选工具缺失但可初始化（给项目建索引；运行 `/graphify`），暂时回退并记下初始化命令——不要在任务中途自动构建。

<!-- codebase-memory-mcp:start -->
# Codebase Knowledge Graph (codebase-memory-mcp)

本项目用 codebase-memory-mcp 维护代码库知识图。
ALWAYS 优先用 MCP 图工具而不是 grep/glob/文件搜索做代码发现。

## 优先级顺序
1. `search_graph` —— 按模式找函数、类、路由、变量
2. `trace_path` —— 追踪谁调用某函数或它调用什么
3. `get_code_snippet` —— 读具体函数/类源码
4. `query_graph` —— 用 Cypher 查询复杂模式
5. `get_architecture` —— 高层项目摘要

## 何时回退到 grep/glob
- 搜索字符串字面量、错误消息、配置值
- 搜索非代码文件（Dockerfile、shell 脚本、配置）
- MCP 工具结果不足时

## 示例
- 找 handler：`search_graph(name_pattern=".*OrderHandler.*")`
- 谁调用它：`trace_path(function_name="OrderHandler", direction="inbound")`
- 读源码：`get_code_snippet(qualified_name="pkg/orders.OrderHandler")`
<!-- codebase-memory-mcp:end -->

## Graphify

规则：
- 用户直接调用 `/graphify`（构建/更新）时，加载 graphify 技能并按它执行；不要走上面的决策流。
- 高层/关系型代码库问题（见决策流），当 `graphify-out/graph.json` 存在时运行 `graphify query "<question>"`。关系用 `graphify path "<A>" "<B>"`，聚焦概念用 `graphify explain "<concept>"`。它们返回一个受限子图，通常比 GRAPH_REPORT.md 或原始 grep 输出小得多。
- `graphify-out/` 有脏文件时照常查询——图仍可用。除非查询结果明显错误或用户明确说不要用，不要请用户清理。
- 存在 `graphify-out/wiki/index.md` 时，用它做广泛导航而不是直接浏览源码。
- 只有做广泛架构审查或 query/path/explain 没有浮出足够上下文时，才读 `graphify-out/GRAPH_REPORT.md`。
- 修改代码后，如果项目有图，运行 `graphify update .` 保持图最新（仅 AST，无 API 成本）。
