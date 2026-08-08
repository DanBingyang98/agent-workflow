# 同步铁闸与合并策略

Status: accepted

同步采用「自动阻断」而非「自动同步」：pre-commit 每次静默 fetch 并软提醒落后基线，pre-push 对落后基线硬拦（工单分支对比 `origin/develop`，hotfix 对比 `origin/main`）——机器保证跳不过同步，但不替你解冲突（冲突是语义判断，自动合 = 静默选边）。另设发布闸：hotfix 未回合（develop 落后 main）时，指向 main 的推送被拦并提示先同步。合并方法一律 merge，禁 squash/rebase——改写 commit sha 会让本地 `git branch -d` 误判未合并，叠加 `branch -D` 拦截形成清理死锁；shell 层钩子拦截本地 `git merge --squash`，PR 平台级的 squash 由各项目在托管侧自行约束。force 策略：裸 `--force`/`-f` 全拦；`--force-with-lease` 仅放行白名单工单分支（自带安全网，远程被他人动过会自动拒绝），保护分支任何强推都拦。

背景：机制提炼自 sweet-agent-coding（ADR-0006 同步机制 = 自动阻断、ADR-0016 D5）。
