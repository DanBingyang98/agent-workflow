# dev 中心分支模型

Status: accepted（部分取代 0003 的分支模型部分）

采用 dev 中心分支模型：`main`（生产镜像）与 `develop`（远程集成分支）均为 PR-only 保护分支——禁直推/强推/删除，合并只在托管平台 PR 服务端发生；工单分支（`feature/fix/docs/chore`）从 `origin/develop` 切出，`hotfix` 从 `origin/main` 切出并须回合 `develop`；发布唯一通道为 `develop→main` 发布 PR（人工审合，PR 必填工单列表与测试记录），合并后打 `release/<日期>` tag。本地不再做整合合并，`flow` 脚本改为校验 + 汇报即停，显式 `--push` 才推送分支（PR 创建交给项目托管流程）。选择远程集成而非本地整合池，是因为整合状态必须在远程可见、可测，且 `main` = 生产镜像可机器验证；代价是套件默认假定项目有远程托管（GitHub/Gitee/GitLab 任一），纯本地仓库的 `flow finish` 停在汇报一步。范围边界：风险分级、跨端契约、平台寻址等业务/平台特定机制一律不纳入套件；多 CLI（Qoder/ZCode）与 worktree 物化推迟，不作为本次交付。

背景：从 sweet-agent-coding（ADR-0016 dev 中心分支模型）提炼的通用形态。完整流程见 `docs/dev-integration-workflow.md`。
