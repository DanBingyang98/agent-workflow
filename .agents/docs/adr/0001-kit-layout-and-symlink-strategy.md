# 套件布局与符号链接策略

Status: accepted

agent-workflow 作为可复用套件，权威内容全部放在仓库的 `.agents/` 目录（skills、AGENTS.md、scripts、hooks、docs），各 agent 通过 `scripts/install.sh` 以符号链接接入（`.claude/skills/`、根目录 `AGENTS.md`/`CLAUDE.md`），不复制内容。选择单一权威源 + 链接，是因为复制会造成双源漂移，且与既有 `~/.agents` + `sync-agent-links.sh` 模式一致；代价是每个目标项目首次使用需运行一次安装脚本。
