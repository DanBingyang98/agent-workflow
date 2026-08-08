# agent-workflow 套件

面向 Codex 与 Claude Code 的中文 agent 编程工作流：可复用的中文技能集、项目级指令、dev 中心分支模型脚本与危险操作钩子。中文为权威语言，本仓库（`.agents/`）为权威内容所在地。

## Language

**套件（Kit）**:
本仓库的交付形态——可克隆/安装到任意项目的中文 agent 编程工作流，包含中文技能、AGENTS.md、dev 中心分支模型脚本与钩子。
_Avoid_: 项目配置、模板

**技能（Skill）**:
一个自包含的指令包（SKILL.md，可附带 references/、scripts/、assets/），agent 按需加载。中文技能以 `.agents/skills/` 为权威存放位置（Codex 原生读取，Claude Code 经安装脚本链接接入）。
_Avoid_: 插件、提示词

**AGENTS.md**:
项目级 agent 指令文件。本套件以 `.agents/AGENTS.md`（中文）为权威版本，各 agent 通过安装脚本引用，不做复制。
_Avoid_: CLAUDE.md（Claude Code 的项目记忆入口，仅引用 AGENTS.md，不承载权威内容）

**dev 中心分支模型（Dev-Centric Branch Model）**:
本套件的分支模型——`main`（生产镜像）与 `develop`（远程集成分支）为常驻分支，两者均为 PR-only 保护分支；`feature/*`、`fix/*`、`docs/*`、`chore/*` 为从 `origin/develop` 切出的工单分支，`hotfix/*` 从 `origin/main` 切出并须回合 `develop`；不设 `release/*`。
_Avoid_: 完整 Git Flow、本地 master 整合池、主干开发

**远程集成分支（Remote Integration Branch）**:
`develop`——工单 PR 合入的对象、发版前本地测试的载体；禁直推。区别于本地整合池：整合状态必须在远程可见、可测。
_Avoid_: 本地整合池

**发布 PR（Release PR）**:
`develop→main` 的 Pull Request，是改动进入 `main`（生产镜像）的唯一通道。一律人工审合，PR 描述必填工单列表与测试记录；合并后打 `release/<日期>` tag。
_Avoid_: 直推发布、release 分支

**工单分支（Ticket Branch）**:
`feature/`、`fix/`、`docs/`、`chore/`（基线 `origin/develop`）与 `hotfix/`（基线 `origin/main`）开头的分支。push 受出口铁闸约束：落后基线硬拦；rebase 后允许 `--force-with-lease`。
_Avoid_: 自由命名分支

**出口铁闸（Exit Gate）**:
pre-push 对落后基线的硬拦——工单分支落后 `origin/develop`（hotfix 落后 `origin/main`）时拒绝推送，保证「跳不过同步」。配套 pre-commit 落后软提醒。
_Avoid_: 自动 rebase、自动解冲突

**发布闸（Release Gate）**:
hotfix 合入 `main` 后未回合 `develop` 时（develop 落后 main），指向 main 的推送会被拦并提示先同步——把「hotfix 必须回合」变成机器可验证的不变式。
_Avoid_: 靠纪律自觉

**同步 = 自动阻断（Sync = Auto-Block）**:
本套件的同步哲学——机器只检测落后并拦截（软提醒 + 硬拦两层），不替你 fetch+rebase 解冲突；冲突是语义判断，自动合 = 静默选边。
_Avoid_: 自动同步

**规范前置 → Hook 兜底（Norms First, Hooks as Backstop）**:
防御哲学——先靠 AGENTS.md 让 agent 做对，hook 只在没遵守时拦；规范承担语义，hook 承担机器可验证的部分。
_Avoid_: 全靠 hook、全靠自觉

**合并方法 = merge（Merge-Only）**:
PR 合并一律用 merge，禁 squash/rebase——改写 commit sha 会让本地 `git branch -d` 误判未合并，叠加 `branch -D` 拦截后形成清理死锁。
_Avoid_: squash merge、rebase merge

**危险操作（Dangerous Operation）**:
不可逆或越过保护边界的操作，包括裸 force-push、直推 PR-only 保护分支、强删分支、`rm -rf`、`git reset --hard`、`git merge --squash` 等；由钩子拦截。
_Avoid_: 拦截器、守卫脚本

**钩子（Hook）**:
拦截危险操作的执行点。git hooks（pre-commit、commit-msg、pre-push）对所有 agent 生效——pre-push 承担 PR-only 保护与出口铁闸；Codex 与 Claude Code 的 PreToolUse 钩子（共用 `hooks/block-dangerous.sh`）额外拦截 shell 级危险命令。
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
