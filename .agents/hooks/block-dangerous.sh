#!/usr/bin/env bash
#
# block-dangerous.sh - Codex 与 Claude Code 共用的 PreToolUse 策略
#
# 从 stdin 读取 PreToolUse 钩子的 JSON 输入，检测 shell 级危险命令；
# 命中时输出 deny 决策（两个 agent 都认 hookSpecificOutput.permissionDecision）。
# 未命中时输出为空、退出 0（放行）。
#
# 拦截清单（dev 中心分支模型）:
#   - rm -rf / rm -fr / rm -Rf / rm --recursive --force / sudo rm -rf
#   - git reset --hard / git clean -fd / git branch -D
#   - git checkout -- . / git restore .
#   - 裸 git push --force / -f（无 -with-lease）
#   - 对保护分支（master/main/develop）或非白名单分支的 --force-with-lease
#   - git merge --squash（合并方法 = merge，禁 squash/rebase）
#
# 放行: 对白名单工单分支（feature/fix/docs/chore/hotfix）的 --force-with-lease
#       （rebase 工作流必需；--force-with-lease 自带安全网，远程被他人动过会自动拒绝）
#
# 覆盖: GIT_FLOW_ALLOW_DANGEROUS=1 放行所有命令（不建议）
#
# Codex 接线:  .codex/hooks.json   { "hooks": { "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "<kit>/hooks/block-dangerous.sh" }] }] } }
# Claude 接线: .claude/settings.json { "hooks": { "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "<kit>/hooks/block-dangerous.sh" }] }] } }

set -u

[ "${GIT_FLOW_ALLOW_DANGEROUS:-0}" = "1" ] && exit 0

input=$(cat)

# 只在输入确实是 Bash 工具调用时检查命令字段
case "$input" in
  *'"tool_name"'*'Bash'*) : ;;
  *) exit 0 ;;
esac

reason=""
deny() {
  [ -n "$reason" ] || reason="$1"
}

# 提取 tool_input.command（PreToolUse JSON，零依赖 grep/sed 解析）
CMD=$(printf '%s' "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

# 危险命令模式（按语义分组，误报时可用环境变量覆盖）
case "$input" in
  *'rm -rf'*|*'rm -fr'*|*'rm -Rf'*|*'rm --recursive --force'*)
    deny "检测到 rm -rf（不可逆删除），已拦截。请先确认目标路径。" ;;
  *'git reset --hard'*)
    deny "检测到 git reset --hard（丢弃本地改动），已拦截。请确认或改用 git reset --soft。" ;;
  *'git clean -fd'*|*'git clean -fdx'*|*'git clean -ff'*)
    deny "检测到 git clean -f（删除未跟踪文件），已拦截。" ;;
  *'git branch -D'*)
    deny "检测到 git branch -D（强制删除分支），已拦截。请确认分支名。" ;;
  *'git checkout -- .'*|*'git restore .'*)
    deny "检测到整目录还原（git checkout -- .），已拦截。请指明具体文件。" ;;
  *'sudo rm -rf'*)
    deny "检测到 sudo rm -rf，已拦截。" ;;
esac

# push 精细化：裸 force 全拦；--force-with-lease 仅白名单工单分支放行
if [ -n "$CMD" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push'; then
  has_lease=0
  has_bare=0
  case "$CMD" in
    *--force-with-lease*) has_lease=1 ;;
  esac
  if [ "$has_lease" -eq 0 ]; then
    case "$CMD" in
      *--force*|*" -f "*|*" -f"*) has_bare=1 ;;
    esac
  fi

  if [ "$has_lease" -eq 1 ]; then
    # 兜底：push 目标含保护分支名（如 push origin main / develop）→ 拦
    if printf '%s' "$CMD" | grep -qE 'git[[:space:]]+push[^;&|]*[[:space:]](master|main|develop)([[:space:]:]|$)'; then
      deny "对保护分支（master/main/develop）的强推被拦截（PR-only，禁止任何强推）。"
    else
      # 目标分支：取 push 参数里的白名单分支名；无显式 refspec 回退当前分支
      target_ref=$(printf '%s' "$CMD" | sed -E 's/^.*git[[:space:]]+push//' | tr ' ' '\n' | grep -E '(feature|fix|docs|chore|hotfix)/|^[^[:space:]]+:[^[:space:]]+' | tail -n1 | sed -E 's/^.*://')
      if [ -z "$target_ref" ]; then
        target_ref=$(printf '%s' "$CMD" | sed -E 's/^.*git[[:space:]]+push//' | tr ' ' '\n' | grep -E '^[^[:space:]-][^[:space:]]*/[^[:space:]]+$' | tail -n1)
      fi
      if [ -z "$target_ref" ]; then
        target_ref=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
      fi
      case "$target_ref" in
        feature/*|fix/*|docs/*|chore/*|hotfix/*) : ;;
        *)
          deny "对分支 '$target_ref' 的 --force-with-lease 被拦截（仅放行白名单工单分支 feature/fix/docs/chore/hotfix）。"
          ;;
      esac
    fi
  elif [ "$has_bare" -eq 1 ]; then
    deny "检测到裸 --force / -f（无 -with-lease），已拦截。rebase 后用 --force-with-lease 重推。"
  fi
fi

# 合并方法 = merge：拦截本地 squash 合并
if [ -n "$CMD" ] && printf '%s' "$CMD" | grep -qE 'git[[:space:]]+merge[[:space:]]+--squash'; then
  deny "检测到 git merge --squash，已拦截。合并方法一律 merge（禁 squash/rebase，见 docs/adr/0006）。"
fi

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
fi

exit 0
