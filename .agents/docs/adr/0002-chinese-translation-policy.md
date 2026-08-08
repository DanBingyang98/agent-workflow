# 中文翻译策略

Status: accepted

mattpocock skills 与用户级 AGENTS.md 翻译为中文权威版本，但 skill 的 frontmatter `name` 与目录名保持英文原样，`description` 与正文中文化，专业术语首次出现附英文注释（如 ADR、triage、hook），代码块与命令原样保留。因为 agent 靠 `name`/路径匹配调用技能，改动会破坏触发；正文中文则降低阅读成本。代价是中文正文与上游英文更新不同步，需手动维护。
