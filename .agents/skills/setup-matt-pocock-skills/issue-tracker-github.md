# Issue tracker: GitHub

本仓库的 issues 和 specs 以 GitHub issues 形式存在。所有操作使用 `gh` CLI。

## 约定

- **创建 issue**：`gh issue create --title "..." --body "..."`。多行正文用 heredoc。
- **读 issue**：`gh issue view <number> --comments`，用 `jq` 过滤评论并抓取标签。
- **列出 issues**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，配适当的 `--label` 和 `--state` 过滤。
- **评论 issue**：`gh issue comment <number> --body "..."`
- **应用 / 移除标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

从 `git remote -v` 推断仓库——在 clone 内运行时 `gh` 自动完成。

## Pull requests 作为 triage 面

**PRs as a request surface: no.** _(如果本仓库把外部 PR 当功能请求，设为 `yes`；`/triage` 读这个标志。)_

设为 `yes` 时，PR 走与 issues 相同的标签和状态，用 `gh pr` 对应命令：

- **读 PR**：`gh pr view <number> --comments`，diff 用 `gh pr diff <number>`。
- **列出供 triage 的外部 PR**：`gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，然后只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR` 或 `NONE` 的（丢弃 `OWNER`/`MEMBER`/`COLLABORATOR`）。
- **评论 / 标签 / 关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`。

GitHub 在 issues 和 PRs 之间共享一个编号空间，所以裸 `#42` 可能是其中任一个——用 `gh pr view 42` 解析，回退到 `gh issue view 42`。

## 当技能说「publish to the issue tracker」

创建 GitHub issue。

## 当技能说「fetch the relevant ticket」

运行 `gh issue view <number> --comments`。

## Wayfinding 操作

供 `/wayfinder` 使用。**map** 是单个 issue，**child** issues 作为 tickets。

- **Map**：一个标 `wayfinder:map` 的 issue，承载 Notes / Decisions-so-far / Fog 正文。`gh issue create --label wayfinder:map`。
- **Child ticket**：作为 GitHub sub-issue 链接到 map 的 issue（用 sub-issues 端点的 `gh api`）。sub-issues 不可用时，把 child 加进 map 正文的任务列表，并在 child 正文顶部放 `Part of #<map>`。标签：`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。认领后，ticket 分配给驱动开发者。
- **Blocking**：GitHub 的**原生 issue dependencies**——规范、UI 可见的表示。用 `gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>` 加边，其中 `<blocker-db-id>` 是阻塞者的数字**数据库 id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`，_不是_ `#number` 或 `node_id`）。GitHub 报告 `issue_dependencies_summary.blocked_by`（只开放阻塞者——实时门）。依赖不可用时，回退到 child 正文顶部的 `Blocked by: #<n>, #<n>` 行。每个阻塞者都关闭时 ticket 未阻塞。
- **Frontier 查询**：列出 map 的开放 children（`gh issue list --state open`，限定在 map 的 sub-issues / 任务列表），丢弃有开放阻塞者（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行里有开放 issue）或有 assignee 的；map 顺序中第一个赢。
- **认领**：`gh issue edit <n> --add-assignee @me` —— 会话的第一次写入。
- **解决**：`gh issue comment <n> --body "<answer>"`，然后 `gh issue close <n>`，然后向 map 的 Decisions-so-far 追加上下文指针（要点 + 链接）。
