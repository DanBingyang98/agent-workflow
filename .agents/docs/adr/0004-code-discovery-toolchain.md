# 代码发现工具链（graphify + codebase-memory-mcp）

Status: accepted

AGENTS.md 的代码发现决策流把 codebase-memory-mcp（符号级查询）与 graphify（关系级查询）列为优先工具，缺失时回退 grep。两者都是用户级可选集成而非套件打包内容：codebase-memory-mcp 以 MCP server 形式接入并需先索引项目；graphify 由用户安装后以用户级 skill 提供，Codex、Claude Code 等任何按 skill 约定读取的 CLI 理论上均可用。选择图工具而非纯 grep，是因为符号级与关系级查询在大代码库中比文本搜索更准；保持可选而非硬依赖，是因为套件不打包也不配置它们，缺失时必须顺畅降级而不是卡住 agent。
