# Issue tracker: GitLab

本仓库的 issues 和 specs 以 GitLab issues 形式存在。所有操作使用 [`glab`](https://gitlab.com/gitlab-org/cli) CLI。

## 约定

- **创建 issue**：`glab issue create --title "..." --description "..."`。多行描述用 heredoc。传 `--description -` 打开编辑器。
- **读 issue**：`glab issue view <number> --comments`。机器可读输出用 `-F json`。
- **列出 issues**：`glab issue list -F json`，配适当的 `--label` 过滤。
- **评论 issue**：`glab issue note <number> --message "..."`。GitLab 把评论叫「notes」。
- **应用 / 移除标签**：`glab issue update <number> --label "..."` / `--unlabel "..."`。多个标签可用逗号分隔或重复标志。
- **关闭**：`glab issue close <number>`。`glab issue close` 不接受关闭评论，所以先用 `glab issue note <number> --message "..."` 发解释，再关闭。
- **Merge requests**：GitLab 把 PR 叫「merge requests」。用 `glab mr create`、`glab mr view`、`glab mr note` 等——与 `gh pr ...` 同形，把 `pr` 换成 `mr`、`comment`/`--body` 换成 `note`/`--message`。

从 `git remote -v` 推断仓库——在 clone 内运行时 `glab` 自动完成。

## Merge requests 作为 triage 面

**MRs as a request surface: no.** _(如果本仓库把外部 merge requests 当功能请求，设为 `yes`；`/triage` 读这个标志。)_

设为 `yes` 时，MR 走与 issues 相同的标签和状态，用 `glab mr` 对应命令：

- **读 MR**：`glab mr view <number> --comments`，diff 用 `glab mr diff <number>`。
- **列出供 triage 的外部 MR**：`glab mr list -F json`，然后只保留作者不是项目成员/owner 的 MR（贡献者的 MR，不是维护者进行中的活）。
- **评论 / 标签 / 关闭**：`glab mr note`、`glab mr update --label`/`--unlabel`、`glab mr close`。

与 GitHub 不同，GitLab 分开给 issues 和 MRs 编号，所以一旦知道维护者指哪个面，`#42` 就没有歧义。

## 当技能说「publish to the issue tracker」

创建 GitLab issue。

## 当技能说「fetch the relevant ticket」

运行 `glab issue view <number> --comments`。

## Wayfinding 操作

供 `/wayfinder` 使用。**map** 是单个 issue，**child** issues 作为 tickets。

- **Map**：一个标 `wayfinder:map` 的 issue，承载 Notes / Decisions-so-far / Fog 正文。`glab issue create --label wayfinder:map`。（在有原生 epics 的 GitLab 层级上，epic 可以承载 map；标标签的 issue 到处可用。）
- **Child ticket**：描述顶部带 `Part of #<map>`、标签为 `wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）的 issue。认领后，ticket 分配给驱动开发者。
- **Blocking**：GitLab 的**原生 blocking link**——规范、UI 可见的表示。用 `/blocked_by #<n>` quick action 添加，作为 note 发布（`glab issue note <child> --message "/blocked_by #<blocker>"`）。原生 blocking links 是 Premium/Ultimate 功能；免费层级（或不可用时）回退到描述顶部的 `Blocked by: #<n>, #<n>` 行。每个阻塞者都关闭时 ticket 未阻塞。
- **Frontier 查询**：`glab issue list -F json` 限定在 map 的 children，丢弃有开放阻塞者——指向开放 issue 的原生 `blocked_by` 链接（`glab api projects/:id/issues/:iid/links`），或 `Blocked by` 行里的开放 issue——或有 assignee 的；map 顺序中第一个赢。
- **认领**：`glab issue update <n> --assignee @me` —— 会话的第一次写入。
- **解决**：`glab issue note <n> --message "<answer>"`，然后 `glab issue close <n>`，然后向 map 的 Decisions-so-far 追加上下文指针（要点 + 链接）。
