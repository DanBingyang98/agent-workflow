# 轻量 Git Flow 与双钩子架构

Status: accepted

采用轻量 Git Flow：`main`（受保护，仅发布）与 `develop`（集成分支）为常驻分支，`feature/*`、`hotfix/*` 为短命分支，不设 `release/*`。危险操作拦截分两层：git hooks（`core.hooksPath` 指向 `.agents/hooks`，覆盖 pre-commit/commit-msg/pre-push，对所有 git 客户端生效）与 agent PreToolUse 钩子（Codex `.codex/hooks.json` 与 Claude Code `.claude/settings.json` 共用 `hooks/block-dangerous.sh`，拦截 shell 级危险命令）。git 层拦 git 操作、agent 层拦 shell 操作，两层互补；共用策略脚本避免双份规则漂移。
