# dev 中心分支模型工作流

> 套件默认工作流。AGENTS.md 只保留高频红线，本文为完整细节；决策背景见 `docs/adr/0005-dev-centric-branch-model.md` 与 `docs/adr/0006-sync-gate-and-merge-only.md`。

## 核心语义

- **`main` = 生产镜像**：只接受发布 PR 与 tag，与生产逐字节一致。
- **`develop` = 远程集成分支**：工单 PR 合入 dev；发版前在 develop 上本地测试。
- **合并只在托管平台 PR 服务端发生**：本地不做整合合并；`flow` 脚本不本地 merge。

## 分支拓扑

| 分支 | 切自 | 合入 | 备注 |
|---|---|---|---|
| `feature/*` `fix/*` `docs/*` `chore/*` | `origin/develop` | PR → develop | 工单分支 |
| `hotfix/*` | `origin/main` | PR → main，当天回合 develop | 生产紧急修复 |
| `develop` | — | 发布 PR → main | 禁直推/强推/删除 |
| `main` | — | 只收发布 PR + tag | 禁直推/强推/删除 |

## 标准流程

### 1. 开始任务前

```bash
git fetch origin
.agents/scripts/flow feature start <名称>    # 从 origin/develop 切出（hotfix 用 main）
```

### 2. 工单分支完成后暂停

agent 必须暂停，汇报：改动摘要、关键文件、验证命令与结果、commit 列表。未经用户明确授权，不得推送工单分支或创建 PR。

### 3. 推送与 PR（授权后）

```bash
.agents/scripts/flow feature finish --push <名称>   # 显式授权后推送
# 在托管平台建 PR：<工单分支> → develop
```

- 工单分支落后 `origin/develop`（hotfix 落后 `origin/main`）时先 `git rebase origin/<基线>`，再 `--force-with-lease` 重推（pre-push 出口铁闸兜底）。
- PR 描述按 `.agents/docs/pr-template.md` 填写。

### 4. 发版（develop → main）

1. develop 上本地测试通过。
2. 确认发布闸：develop 不落后 main（有 hotfix 未回合先回合）。
3. 创建发布 PR：`develop → main`，一律人工审合；PR 必填本次工单列表与测试记录。
4. 合并后打 tag：`git tag release/<YYYY-MM-DD> origin/main`（同日多次加 `-2`）并推送。

### 5. hotfix

```bash
git fetch origin
.agents/scripts/flow hotfix start <简述>            # 从 origin/main 切
# 修复 → 提交 → flow hotfix finish --push <简述>     # 授权推送
# PR：hotfix/<简述> → main（人工审合，合并即部署）
```

合入 main 后当天必须回合 develop：从 `origin/develop` 切 `chore/回合hotfix<简述>`，合并 `origin/main` 后 PR 回 develop。发布闸兜底：develop 落后 main 时，任何指向 main 的 push 都被拦并提示。

### 6. 清理

- 已发布工单分支：托管平台勾「删除源分支」或远端删除；本地 `git branch -d` + `git fetch --prune`。
- 本地 `main` 快进到 `origin/main`（仅镜像）。

## 禁止事项

- 禁止直推 `main` / `develop`（PR-only，pre-push 硬拦，无放行口）。
- 禁止强推 / 删除 `main` / `develop`。
- 禁止发布 PR 由 AI 自合（一律人工审合）。
- 禁止 hotfix 合 main 后不回合 develop（发布闸兜底）。
- 禁止未经用户授权推送工单分支或开 PR。
- 禁止 PR 合并用 squash/rebase（合并方法 = merge）。

> 例外：远端初始化时，首次创建 `main` / `develop` 的推送放行（远端 oid 全零）；此后任何更新一律走 PR。

## 与 flow 脚本的关系

- `flow <prefix> start <name>`：校验 + 从 `origin/develop`（hotfix 从 `origin/main`）切出；无远程基线时回退本地分支。
- `flow <prefix> finish <name>`：校验 + 汇报，默认不碰远程。
- `flow <prefix> finish --push <name>`：显式授权后推送；PR 创建交给项目托管流程。
