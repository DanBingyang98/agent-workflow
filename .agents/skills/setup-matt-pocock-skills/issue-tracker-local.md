# Issue tracker: Local Markdown

本仓库的 issues 和 specs 以 `.scratch/` 下的 markdown 文件存在。

## 约定

- 每个 feature 一个目录：`.scratch/<feature-slug>/`
- spec 是 `.scratch/<feature-slug>/spec.md`
- 实现 issues 是 `.scratch/<feature-slug>/issues/<NN>-<slug>.md` 下每个 ticket 一个文件，从 `01` 编号——绝不用单个合并 tickets 文件
- triage 状态记录为每个 issue 文件顶部附近的 `Status:` 行（角色字符串见 `triage-labels.md`）
- 评论和对话历史追加到文件底部 `## Comments` 标题下

## 当技能说「publish to the issue tracker」

在 `.scratch/<feature-slug>/` 下创建新文件（需要时创建目录）。

## 当技能说「fetch the relevant ticket」

读引用路径处的文件。用户通常会直接传路径或 issue 编号。

## Wayfinding 操作

供 `/wayfinder` 使用。**map** 是一个文件，每个 ticket 一个**child** 文件。

- **Map**：`.scratch/<effort>/map.md` —— Notes / Decisions-so-far / Fog 正文。
- **Child ticket**：`.scratch/<effort>/issues/NN-<slug>.md`，从 `01` 编号，问题在正文里。`Type:` 行记录 ticket 类型（`research`/`prototype`/`grilling`/`task`）；`Status:` 行记录 `claimed`/`resolved`。
- **Blocking**：顶部附近的 `Blocked by: NN, NN` 行。它列出的每个文件都 `resolved` 时 ticket 未阻塞。
- **Frontier**：扫描 `.scratch/<effort>/issues/` 找开放、未阻塞、未认领的文件；按编号第一个赢。
- **认领**：任何工作前设 `Status: claimed` 并保存。
- **解决**：在 `## Answer` 标题下追加答案，设 `Status: resolved`，然后向 `map.md` 的 Decisions-so-far 追加上下文指针（要点 + 链接）。
