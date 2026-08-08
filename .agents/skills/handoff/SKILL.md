---
name: handoff
description: 把当前对话压缩成交接文档，供另一个 agent 接手。
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

写一份交接文档，总结当前对话，让全新 agent 能继续这项工作。保存到用户 OS 的临时目录——不是当前工作区。

在文档里包含「suggested skills」部分，建议 agent 应该调用的技能。

不要重复其它工件（specs、plans、ADRs、issues、commits、diffs）已捕获的内容。改为按路径或 URL 引用它们。

删掉任何敏感信息，例如 API keys、密码或个人可识别信息。

如果用户传了参数，把它们当作对下一会话将聚焦什么的描述，并相应调整文档。
