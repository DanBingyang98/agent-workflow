# Agent 约定调研（AGENTS.md / CLAUDE.md / Skills / Hooks）

> 调研日期：2026-08-08。方法：以官方一手资料为准（OpenAI Codex 文档、Anthropic Claude Code 文档、agents.md 官网、agentskills.io 标准站），每条结论附来源。本文件服务于 agent-workflow 套件的 `.agents/AGENTS.md`、技能集与危险操作钩子设计。

## 1. AGENTS.md 开放标准（agents.md）

- 定位：AGENTS.md 是「README for agents」——给编码 agent 的专用指令文件，与面向人类的 README 分开，避免 README 被指令细节污染。无强制字段，就是标准 Markdown，任意标题均可。来源：<https://agents.md>
- 冲突规则：离被编辑文件最近的 AGENTS.md 优先；显式用户 prompt 覆盖一切。来源：<https://agents.md>
- 嵌套：monorepo 每个包可放自己的 AGENTS.md，agent 自动读目录树中最近的文件。来源：<https://agents.md>
- 生态：60k+ 开源项目使用；官方列出的支持方包括 OpenAI Codex、Google Jules、Factory、Aider、goose、opencode、Zed、Warp、VS Code、Devin、Cursor、Gemini CLI、GitHub Copilot coding agent、Windsurf、Amp、RooCode、Kilo Code、Semgrep 等。来源：<https://agents.md>
- 治理：由 OpenAI Codex 等生态协作发起，现由 Linux Foundation 旗下 Agentic AI Foundation（AAIF）托管。来源：<https://agents.md>
- 注意：Claude Code 不在 agents.md 支持列表——Anthropic 官方文档明确 Claude Code 读 `CLAUDE.md`、不读 `AGENTS.md`（见 §3.1）。来源：<https://docs.claude.com/en/docs/claude-code/memory>

## 2. Codex 官方约定（OpenAI 文档）

### 2.1 AGENTS.md 发现与优先级

- Codex 开始工作前读取 AGENTS.md，每次运行（TUI 通常每个会话一次）构建一次指令链，之后不重建、无缓存可清。来源：<https://developers.openai.com/codex/agent-configuration/agents-md>
- 全局层：在 `$CODEX_HOME`（默认 `~/.codex`，可用 `CODEX_HOME` 环境变量改）检查 `AGENTS.override.md`，存在则读它，否则读 `AGENTS.md`；该层只取第一个非空文件。来源：同上
- 项目层：从项目根（通常是 Git root）向当前目录逐层检查，每层按 `AGENTS.override.md`、`AGENTS.md`、`project_doc_fallback_filenames` 顺序，每层最多一个文件；找不到项目根时只检查当前目录。来源：同上
- 合并顺序：文件从根向 cwd 顺序拼接（空行分隔），越靠近 cwd 越靠后、覆盖前面的指导。来源：同上
- 限制：空文件跳过；累计达到 `project_doc_max_bytes`（默认 32 KiB）后停止继续添加。来源：同上
- 配置项（`~/.codex/config.toml`）：`project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]`、`project_doc_max_bytes = 65536`。来源：同上；<https://developers.openai.com/codex/config-file/config-advanced>
- 注意：Codex 默认不读 `.agents/AGENTS.md` 这类隐藏目录内文件——必须把文件名加入 fallback 列表，或用 symlink 指向，否则发现不到。
- 其他：`## Code Review Rules` 段落可被 GitHub 上的 Codex Code Review 使用（规则放离代码最近的 AGENTS.md 里）。来源：<https://developers.openai.com/codex/agent-configuration/agents-md>
- 验证手段：`codex --ask-for-approval never "Summarize the current instructions."`；审计加载了哪些文件可看 `codex -c log_dir=./.codex-log` 的 `codex-tui.log` 或最近的 `session-*.jsonl`。来源：同上

### 2.2 Codex Skills

- Skill = 一个目录含 `SKILL.md`（必须含 `name` 与 `description` frontmatter）+ 可选的 `scripts/`、`references/`、`assets/`、`agents/openai.yaml`。来源：<https://developers.openai.com/codex/build-skills>
- 激活方式：显式（Codex CLI 里 `/skills` 或 `$` 提及）或隐式（任务匹配 `description`）——description 要写得简洁、边界清晰、关键触发词前置（description 可能被截短）。来源：同上
- 加载位置（本地）：`$CWD/.agents/skills`、上层每级目录 `.agents/skills`、`$REPO_ROOT/.agents/skills`、`$HOME/.agents/skills`、`/etc/codex/skills`、系统内置。同名 skill 不合并，可能同时出现在选择器里；支持 symlink。来源：同上
- 套件注意：CONTEXT.md 规定中文技能权威位置为 `.agents/.skills/`，而 Codex 默认扫描 `.agents/skills`——两者不一致，构建时需要调整目录名、配置或 symlink。

## 3. Claude Code 官方约定（Anthropic 文档）

### 3.1 CLAUDE.md

- Claude Code 读 `CLAUDE.md`，不读 `AGENTS.md`。仓库已有 AGENTS.md 时，推荐建一个只含 `@AGENTS.md` 导入的 CLAUDE.md（可再追加 Claude 专属指令），两个工具读同一份内容、不重复维护；或 `ln -s AGENTS.md CLAUDE.md`（Windows 需管理员/开发者模式，改用 `@` 导入）。`/import` 命令可一次性把 AGENTS.md 等配置拷入 CLAUDE.md（需 Claude Code v2.1.213+）。来源：<https://docs.claude.com/en/docs/claude-code/memory>
- 加载顺序（由宽到窄）：managed policy（macOS `/Library/Application Support/ClaudeCode/CLAUDE.md`、Linux/WSL `/etc/claude-code/CLAUDE.md`、Windows `C:\Program Files\ClaudeCode\CLAUDE.md`）→ 用户 `~/.claude/CLAUDE.md` → 项目 `./CLAUDE.md` 或 `./.claude/CLAUDE.md` → 本地 `./CLAUDE.local.md`（应 gitignore）。来源：同上
- 目录树解析：从 cwd 向上找 `CLAUDE.md` 与 `CLAUDE.local.md`；全部文件拼接进上下文而非相互覆盖，顺序为 filesystem root → cwd（靠近启动目录的最后读）；每目录内 `CLAUDE.local.md` 追加在 `CLAUDE.md` 之后；当前目录之下的子目录文件按需加载（Claude 读到该目录文件时才载入）；monorepo 可用 `claudeMdExcludes` 排除他人文件。来源：同上
- 写作建议：每个文件 <200 行（过长消耗上下文并降低遵守率）；用标题/列表组织；指令要具体可验证（如「用 2 空格缩进」而非「格式规范点」）；定期检查冲突规则（冲突时 Claude 可能任意选一条）。来源：同上
- 导入语法：`@path/to/import`，相对路径相对所在文件而非工作目录；递归导入最深 4 跳；解析跳过行内 code span 与 fenced code block——不想导入就用反引号包住 `@README`；项目级 memory 文件里的外部导入（解析到工作目录外）首次触发审批对话框。来源：同上
- 规则（rules）：`.claude/rules/*.md` 可模块化组织；YAML frontmatter 的 `paths`（glob）可做路径条件加载，无 `paths` 的规则启动即加载；`<!-- 注释 -->` 注入前被剥离（代码块内保留）。来源：同上
- 验证：会话里 `/context` 可看 Memory files 是否加载。来源：同上

### 3.2 Hooks（危险操作拦截）

- 配置位置：`~/.claude/settings.json`（用户级）、`.claude/settings.json`（项目级，可提交仓库）、`.claude/settings.local.json`（本地，gitignored）；hooks 跨层级合并而非替换。来源：<https://docs.claude.com/en/docs/claude-code/hooks>
- `PreToolUse` 在工具调用执行前触发，可阻止调用；`PostToolUse` 在成功后触发。来源：同上
- 官方拦截 `rm -rf` 示例：`matcher: "Bash"` + `if: "Bash(rm *)"`，脚本放 `${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh` 并 `chmod +x`；脚本从 stdin 读 JSON，命中时返回 `hookSpecificOutput.permissionDecision: "deny"`（附 reason）。来源：同上
- 退出码语义：exit 0 = 无决策、放行；exit 2 = 阻断（对多数事件，这是唯一阻断码，exit 1 只是非阻断错误）；stdout 的 JSON 可携带决策。来源：同上

### 3.3 Claude Code Skills

- 遵循 Agent Skills（agentskills.io）开放标准，可在多种 AI 工具间复用；Claude Code 在此基础上扩展了直接调用等特性。来源：<https://docs.claude.com/en/docs/claude-code/skills>；<https://agentskills.io>
- 位置：personal `~/.claude/skills/<skill-name>/SKILL.md`、project `.claude/skills/<skill-name>/SKILL.md`、plugin `<plugin>/skills/`；嵌套 `.claude/skills/` 按需加载（读到/编辑该子目录文件后可用）；支持 symlink。来源：<https://docs.claude.com/en/docs/claude-code/skills>
- 目录名即命令名（`/skill-name`）；同名时 project skill 覆盖 bundled skill，skill 优先于 `.claude/commands/` 同名命令；`SKILL.md` 必须含 `name` 与 `description`。来源：同上
- 跨工具位置差异：Codex 默认扫 `.agents/skills`，Claude Code 默认扫 `.claude/skills`——同一个技能目录无法同时被两者默认发现，需 symlink 或各自安装。

## 4. Agent Skills 开放标准（agentskills.io）

- Skill = 一个目录含 `SKILL.md`（至少 `name` + `description` 元数据 + 指令），可选 `scripts/`、`references/`、`assets/` 等。来源：<https://agentskills.io>
- 渐进披露三阶段：Discovery（启动时只载入 name + description）→ Activation（任务匹配 description 时读完整 SKILL.md）→ Execution（执行指令、按需跑脚本/引用文件）。来源：<https://agentskills.io>
- 意义：技能可版本控制、随仓库共享、跨产品复用。来源：同上

## 5. 对 agent-workflow 套件的直接含义

以下是由上述一手事实推出的构建要点（非文档原文）：

1. **AGENTS.md 权威版放 `.agents/AGENTS.md` 可行，但需接入点**：Codex 默认只读项目根 `AGENTS.md`（及 fallback 名单），Claude Code 只读 `CLAUDE.md`。安装脚本应（a）在项目根建 `AGENTS.md` 到 `.agents/AGENTS.md` 的 symlink，或（b）写入 `project_doc_fallback_filenames`；Claude Code 侧生成/建议 `CLAUDE.md` 内容为 `@AGENTS.md`（或 symlink），与 CONTEXT.md「引用而非复制」的定位一致。
2. **技能目录名要校准**：CONTEXT.md 的 `.agents/.skills/` 不在 Codex（`.agents/skills`）或 Claude Code（`.claude/skills`）的默认扫描路径上。要么改目录名，要么在文档中明确需 symlink/配置。
3. **危险操作钩子分两层**：git hooks（pre-commit / commit-msg / pre-push）对所有 git 操作生效；Claude Code 额外需要 PreToolUse 钩子（`.claude/settings.json` + `.claude/hooks/` 脚本）拦截 `rm -rf`、force-push、`git reset --hard` 等 shell 级命令，阻断语义用 exit 2 / `permissionDecision: "deny"`。
4. **写作基准**：Codex 侧每目录最多一个文件、总量 32 KiB 上限；Claude Code 侧每文件 <200 行、指令具体可验证、避免冲突。两者都要求「靠近工作目录的指令最后读、优先覆盖」——套件 AGENTS.md 应把通用规则放前、项目特殊规则放后。

## 来源清单

- OpenAI 官方文档：Custom instructions with AGENTS.md — <https://developers.openai.com/codex/agent-configuration/agents-md>
- OpenAI 官方文档：Build skills — <https://developers.openai.com/codex/build-skills>
- OpenAI 官方文档：Config advanced（Project instructions discovery）— <https://developers.openai.com/codex/config-file/config-advanced>
- Anthropic 官方文档：Claude Code memory（CLAUDE.md）— <https://docs.claude.com/en/docs/claude-code/memory>
- Anthropic 官方文档：Hooks reference — <https://docs.claude.com/en/docs/claude-code/hooks>
- Anthropic 官方文档：Skills — <https://docs.claude.com/en/docs/claude-code/skills>
- AGENTS.md 开放标准官网 — <https://agents.md>
- Agent Skills 开放标准官网 — <https://agentskills.io>
