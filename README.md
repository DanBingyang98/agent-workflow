# agent-workflow（中文版 Agent 编程工作流）

面向 **Codex** 与 **Claude Code** 的中文 agent 编程工作流套件：翻译自 [mattpocock/skills](https://github.com/mattpocock/skills) 的 27 个工程与效率技能、中文版项目级指令（AGENTS.md）、dev 中心分支模型脚本，以及拦截危险操作的 git hooks 与双 agent 钩子。

权威内容全部放在 `.agents/` 目录，各 agent 通过 `install.sh` 以符号链接接入——**不复制、不漂移**。

## 目录结构

```
.agents/
├── AGENTS.md            ← 用户级 AGENTS.md 的中文翻译（全局默认准则 + 工作流 + 代码发现决策流）
├── skills/              ← 27 个中文技能（name/目录名保持英文，正文中文）
│   └── <name>/SKILL.md  ← 附带的 references/ 已同步翻译，scripts/ 保持原样
├── scripts/
│   ├── install.sh       ← 接线：技能链接、AGENTS.md/CLAUDE.md 链接、钩子配置
│   ├── flow             ← dev 中心分支模型：start、finish[--push]、status
│   └── guard            ← 分支名/前缀白名单/工作区等前置检查
├── hooks/
│   ├── pre-commit       ← 拦截：冲突标记、疑似密钥、超大文件（>5MB）
│   ├── commit-msg       ← 校验 Conventional Commits（英文类型 + 中文主题）
│   ├── pre-push         ← PR-only 保护 main/develop + 落后基线出口铁闸 + 发布闸
│   └── block-dangerous.sh ← Codex 与 Claude Code 共用的 shell 危险命令策略
├── CONTEXT.md           ← 领域词汇表（套件/技能/dev 中心分支模型/钩子…）
└── docs/
    ├── adr/             ← 0001–0007（布局/翻译/分支模型/铁闸/文档边界/代码发现…）
    ├── dev-integration-workflow.md ← dev 中心分支模型完整流程
    ├── pr-template.md   ← 通用 PR 模板（发布 PR 硬字段）
    └── agent-conventions.md ← Codex / Claude Code 官方约定调研（含来源）
```

## 快速开始

```bash
# 1. 在目标项目里接入套件（符号链接 + 钩子配置 + core.hooksPath）
./.agents/scripts/install.sh          # 或先 --check 查看差异

# 2. 重启 Codex / Claude Code 会话，技能与指令即生效
```

安装脚本做四件事：

1. `.claude/skills/<skill>` → `.agents/skills/<skill>`（Claude Code 不认 `.agents/skills`，逐技能链接；Codex 原生读取 `.agents/skills`）
2. 根 `AGENTS.md` 与根 `CLAUDE.md` → `.agents/AGENTS.md`（两个 agent 都读到同一份中文指令）
3. `.codex/hooks.json` 与 `.claude/settings.json` 写入 PreToolUse，指向 `hooks/block-dangerous.sh`
4. `git config core.hooksPath .agents/hooks`（git 层保护对所有 git 客户端生效）

已有文件不会被覆盖：真实文件冲突只报告不动手；`settings.json`/`hooks.json` 已存在时用 `jq` 合并（无 `jq` 则提示手动添加）。

## 代码发现（Code Discovery）

`AGENTS.md` 的「代码发现 —— 决策流」优先使用两个**可选**的外部工具；都不可用时自动回退 `grep`，不会阻塞。两者都是用户级集成，**不在套件打包范围内**，`install.sh` 不安装、不配置它们。

- **codebase-memory-mcp**：维护项目代码知识图的 MCP 服务器，提供 `search_graph` / `trace_path` / `get_code_snippet` 等符号级查询。启用方式：连接 MCP server 后对项目运行 `index_repository` 建立索引；可用前提是「服务器已连接且项目已索引」。
- **graphify**：生成并查询代码知识图（`graphify-out/graph.json`）的 CLI 与用户级技能，提供 `query` / `path` / `explain` 做关系级/高层查询。启用方式：用户安装 graphify 后运行 `/graphify`（或 `graphify update .`）生成图；可用前提是 `graphify-out/graph.json` 存在。

graphify 为可选集成：用户安装后它出现在用户级技能目录，任何按技能约定读取的 CLI（Codex、Claude Code 等）理论上都能调用；codebase-memory-mcp 则以 MCP server 形式接入各 agent。两者都缺失时，决策流按 AGENTS.md 回退到 `grep`。

## dev 中心分支模型

分支模型：`main`（生产镜像，PR-only）+ `develop`（远程集成分支，PR-only）+ `feature/*` `fix/*` `docs/*` `chore/*`（从 `origin/develop` 切）+ `hotfix/*`（从 `origin/main` 切，合 main 后须回合 develop）。不设 `release/*`。合并只在托管平台 PR 服务端发生，本地不做整合合并；发布唯一通道 = `develop→main` 发布 PR（人工审合）+ `release/<日期>` tag。完整流程见 [dev-integration-workflow.md](.agents/docs/dev-integration-workflow.md)，PR 模板见 [pr-template.md](.agents/docs/pr-template.md)。

```bash
.agents/scripts/flow feature start 用户登录      # 从 origin/develop 建 feature/用户登录（校验分支名 + 工作区）
.agents/scripts/flow feature finish 用户登录     # 校验并汇报，默认不碰远程
.agents/scripts/flow feature finish --push 用户登录  # 显式授权后推送（PR 交给项目流程）
.agents/scripts/flow hotfix start 修复崩溃       # 从 origin/main 建 hotfix/修复崩溃
.agents/scripts/flow hotfix finish --push 修复崩溃   # 授权推送；合 main 后须回合 develop
.agents/scripts/flow status                      # 当前分支与仓库状态
```

## 危险操作拦截

| 层 | 覆盖 | 规则 |
| --- | --- | --- |
| git hooks（所有 git 客户端） | pre-commit / commit-msg / pre-push | 冲突标记、密钥、>5MB 文件；Conventional Commits；main/develop PR-only（禁一切直推/强推/删除）+ 落后基线出口铁闸 + 发布闸 + 落后软提醒 |
| PreToolUse（Codex + Claude Code） | shell 命令 | `rm -rf`、`git reset --hard`、`git clean -f`、裸 `git push --force`、`git branch -D`、`git merge --squash` 等；`--force-with-lease` 仅白名单工单分支放行 |

紧急放行（不推荐）：`GIT_FLOW_ALLOW_DANGEROUS=1`（shell 层）、`GIT_FLOW_SKIP_PRE_COMMIT=1` / `GIT_FLOW_SKIP_COMMIT_MSG=1`（单次跳过）。`main`/`develop` 直推无放行口。

## 技能清单（27）

工程（18）：ask-matt、code-review、codebase-design、diagnosing-bugs、domain-modeling、grill-with-docs、implement、improve-codebase-architecture、prototype、research、resolving-merge-conflicts、setup-matt-pocock-skills、tdd、to-spec、to-tickets、triage、wayfinder、wizard

效率（8）：grill-me、grilling、handoff、teach、to-questionnaire、wait-what、writing-for-agents、writing-great-skills

其他（1）：find-skills

> 注：`graphify` 不在上述 27 个套件技能内——它是可选集成，用户安装后出现在用户级技能目录，Codex、Claude Code 等任何 CLI 理论上均可用；`codebase-memory-mcp` 是 MCP server，同样非套件打包内容。见「代码发现」一节。

## 设计决策（ADR）

- [0001 套件布局与符号链接策略](.agents/docs/adr/0001-kit-layout-and-symlink-strategy.md)
- [0002 中文翻译策略](.agents/docs/adr/0002-chinese-translation-policy.md)
- [0003 轻量 Git Flow 与双钩子架构](.agents/docs/adr/0003-lightweight-gitflow-and-dual-hooks.md)
- [0004 代码发现工具链](.agents/docs/adr/0004-code-discovery-toolchain.md)
- [0005 dev 中心分支模型](.agents/docs/adr/0005-dev-centric-branch-model.md)
- [0006 同步铁闸与合并策略](.agents/docs/adr/0006-sync-gate-and-merge-only.md)
- [0007 规则文档边界](.agents/docs/adr/0007-rule-doc-boundary.md)

## 术语

见 [.agents/CONTEXT.md](.agents/CONTEXT.md)。
