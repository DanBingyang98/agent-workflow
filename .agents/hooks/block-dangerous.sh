#!/usr/bin/env bash
#
# block-dangerous.sh - Codex 与 Claude Code 共用的 PreToolUse 策略
#
# 从 stdin 读取 PreToolUse 钩子的 JSON 输入，检测 shell 级危险命令；
# 命中时输出 deny 决策（两个 agent 都认 hookSpecificOutput.permissionDecision）。
# 未命中时输出为空、退出 0（放行）。
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

# 危险命令模式（按语义分组，误报时可用环境变量覆盖）
case "$input" in
  *'rm -rf'*|*'rm -fr'*|*'rm -Rf'*|*'rm -rf'*|*'rm --recursive --force'*)
    deny "检测到 rm -rf（不可逆删除），已拦截。请先确认目标路径。" ;;
  *'git reset --hard'*)
    deny "检测到 git reset --hard（丢弃本地改动），已拦截。请确认或改用 git reset --soft。" ;;
  *'git clean -fd'*|*'git clean -fdx'*|*'git clean -ff'*)
    deny "检测到 git clean -f（删除未跟踪文件），已拦截。" ;;
  *'git push --force'*|*'git push -f'*|*'git push -F'*)
    deny "检测到 git push --force，已拦截。pre-push 钩子会保护 main/develop，请确认分支后再试。" ;;
  *'git branch -D'*)
    deny "检测到 git branch -D（强制删除分支），已拦截。请确认分支名。" ;;
  *'git checkout -- .'*|*'git restore .'*)
    deny "检测到整目录还原（git checkout -- .），已拦截。请指明具体文件。" ;;
  *'sudo rm -rf'*)
    deny "检测到 sudo rm -rf，已拦截。" ;;
esac

if [ -n "$reason" ]; then
  printf '{"hookSpecificOutput":{"permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
fi

exit 0
