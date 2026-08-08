# agent-workflow 套件

面向 Codex 与 Claude Code 的中文 agent 编程工作流：可复用的中文技能集、项目级指令、Git Flow 脚本与危险操作钩子。中文为权威语言，本仓库（`.agents/`）为权威内容所在地。

## Language

**套件（Kit）**:
本仓库的交付形态——可克隆/安装到任意项目的中文 agent 编程工作流，包含中文技能、AGENTS.md、Git Flow 脚本与钩子。
_Avoid_: 项目配置、模板

**技能（Skill）**:
一个自包含的指令包（SKILL.md，可附带 references/、scripts/、assets/），agent 按需加载。中文技能以 `.agents/skills/` 为权威存放位置（Codex 原生读取，Claude Code 经安装脚本链接接入）。
_Avoid_: 插件、提示词

**AGENTS.md**:
项目级 agent 指令文件。本套件以 `.agents/AGENTS.md`（中文）为权威版本，各 agent 通过安装脚本引用，不做复制。
_Avoid_: CLAUDE.md（仅作为 Claude Code 的引用入口）

**轻量 Git Flow**:
本套件的分支模型——`main`（受保护，仅发布）与 `develop`（集成分支）为常驻分支，`feature/*`、`hotfix/*` 为短命分支；不设 `release/*`。
_Avoid_: 完整 Git Flow、主干开发

**危险操作（Dangerous Operation）**:
不可逆或越过保护边界的操作，包括 force-push、直接推送受保护分支、删除分支、`rm -rf`、`git reset --hard` 等；由钩子拦截。

**钩子（Hook）**:
拦截危险操作的执行点。git hooks（pre-commit、commit-msg、pre-push）对所有 agent 生效；Codex 与 Claude Code 的 PreToolUse 钩子（共用 `hooks/block-dangerous.sh`）额外拦截 shell 级命令。
_Avoid_: 拦截器、守卫脚本

**安装脚本（Install Script）**:
套件内置的 `scripts/install.sh`（bash，`--check/--sync` 模式）：把 `.agents/` 中的权威内容以符号链接接入各 agent 目录（`.claude/skills/`、根 `AGENTS.md`/`CLAUDE.md`）并写入钩子配置，不复制内容。
_Avoid_: 同步工具、部署脚本

**代码发现决策流（Code Discovery Decision Flow）**:
AGENTS.md 内置的工具选择规则：符号级查询首选 codebase-memory-mcp，关系级/高层查询首选 graphify，字符串与配置用 grep；前两者不可用时一律回退 grep，不阻塞。
_Avoid_: 代码检索策略、导航指南

**codebase-memory-mcp**:
维护项目代码知识图（函数、类、调用关系）的 MCP 服务器，提供 search_graph、trace_path、get_code_snippet 等符号级查询；需连接服务器并对项目索引后可用。
_Avoid_: 语义搜索引擎、grep 替代品

**graphify**:
生成并查询代码知识图（graphify-out/graph.json）的 CLI 与用户级技能，提供 query/path/explain 做关系级查询；用户安装后 Codex、Claude Code 等 CLI 理论上均可调用。
_Avoid_: 架构图生成器、类图工具
