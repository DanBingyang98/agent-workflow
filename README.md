# agent-workflow（中文版 Agent 编程工作流）

面向 **Codex** 与 **Claude Code** 的中文 agent 编程工作流套件：翻译自 [mattpocock/skills](https://github.com/mattpocock/skills) 的 27 个工程与效率技能、中文版项目级指令（AGENTS.md）、轻量 Git Flow 脚本，以及拦截危险操作的 git hooks 与双 agent 钩子。

权威内容全部放在 `.agents/` 目录，各 agent 通过 `install.sh` 以符号链接接入——**不复制、不漂移**。

## 目录结构

```
.agents/
├── AGENTS.md            ← 用户级 AGENTS.md 的中文翻译（全局默认准则 + 代码发现决策流）
├── skills/              ← 27 个中文技能（name/目录名保持英文，正文中文）
│   └── <name>/SKILL.md  ← 附带的 references/ 已同步翻译，scripts/ 保持原样
├── scripts/
│   ├── install.sh       ← 接线：技能链接、AGENTS.md/CLAUDE.md 链接、钩子配置
│   ├── flow             ← 轻量 Git Flow：feature/hotfix start|finish、status
│   └── guard            ← 分支名/工作区等前置检查
├── hooks/
│   ├── pre-commit       ← 拦截：冲突标记、疑似密钥、超大文件（>5MB）
│   ├── commit-msg       ← 校验 Conventional Commits（英文类型 + 中文主题）
│   ├── pre-push         ← 保护 main/develop：禁 force/删除/非快进
│   └── block-dangerous.sh ← Codex 与 Claude Code 共用的 shell 危险命令策略
├── CONTEXT.md           ← 领域词汇表（套件/技能/轻量 Git Flow/钩子…）
└── docs/
    ├── adr/             ← 0001 布局与符号链接策略、0002 翻译策略、0003 Git Flow+双钩子
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
2. 根 `AGENTS.md` 与 `.claude/CLAUDE.md` → `.agents/AGENTS.md`（两个 agent 都读到同一份中文指令）
3. `.codex/hooks.json` 与 `.claude/settings.json` 写入 PreToolUse，指向 `hooks/block-dangerous.sh`
4. `git config core.hooksPath .agents/hooks`（git 层保护对所有 git 客户端生效）

已有文件不会被覆盖：真实文件冲突只报告不动手；`settings.json`/`hooks.json` 已存在时用 `jq` 合并（无 `jq` 则提示手动添加）。

## 轻量 Git Flow

分支模型：`main`（受保护，仅发布）+ `develop`（集成分支）+ `feature/*` + `hotfix/*`，不设 `release/*`。

```bash
.agents/scripts/flow feature start 用户登录      # 从 develop 建 feature/用户登录（校验分支名 + 工作区）
.agents/scripts/flow feature finish 用户登录     # 合并到 develop，删除分支
.agents/scripts/flow hotfix start 修复崩溃       # 从 main 建 hotfix/修复崩溃
.agents/scripts/flow hotfix finish 修复崩溃      # 合并到 main 与 develop
.agents/scripts/flow status                      # 当前分支与仓库状态
```

## 危险操作拦截

| 层 | 覆盖 | 规则 |
| --- | --- | --- |
| git hooks（所有 git 客户端） | pre-commit / commit-msg / pre-push | 冲突标记、密钥、>5MB 文件；Conventional Commits；保护 main/develop（禁 force、删除、非快进） |
| PreToolUse（Codex + Claude Code） | shell 命令 | `rm -rf`、`git reset --hard`、`git clean -f`、`git push --force`、`git branch -D` 等 |

紧急放行（不推荐）：`GIT_FLOW_ALLOW_FORCE=1`（git 层）、`GIT_FLOW_ALLOW_DANGEROUS=1`（shell 层）、`GIT_FLOW_SKIP_PRE_COMMIT=1` / `GIT_FLOW_SKIP_COMMIT_MSG=1`（单次跳过）。

## 技能清单（27）

工程（18）：ask-matt、code-review、codebase-design、diagnosing-bugs、domain-modeling、grill-with-docs、implement、improve-codebase-architecture、prototype、research、resolving-merge-conflicts、setup-matt-pocock-skills、tdd、to-spec、to-tickets、triage、wayfinder、wizard

效率（8）：grill-me、grilling、handoff、teach、to-questionnaire、wait-what、writing-for-agents、writing-great-skills

其他（1）：find-skills

## 设计决策（ADR）

- [0001 套件布局与符号链接策略](.agents/docs/adr/0001-kit-layout-and-symlink-strategy.md)
- [0002 中文翻译策略](.agents/docs/adr/0002-chinese-translation-policy.md)
- [0003 轻量 Git Flow 与双钩子架构](.agents/docs/adr/0003-lightweight-gitflow-and-dual-hooks.md)

## 术语

见 [.agents/CONTEXT.md](.agents/CONTEXT.md)。
