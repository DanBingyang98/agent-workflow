#!/usr/bin/env bash
#
# install.sh - 把 .agents/ 套件接入当前项目（Codex + Claude Code）
#
# 用法:
#   install.sh [--check]   # --check 只报告差异，不改任何东西；默认 --sync
#   install.sh --sync      # 创建符号链接、写入 hooks 配置、设置 core.hooksPath
#
# 做三件事（全部可重复执行，已有内容不覆盖，冲突只报告）:
#   1. 技能链接:  .claude/skills/<skill> -> .agents/skills/<skill>
#   2. 指令链接:  AGENTS.md -> .agents/AGENTS.md
#                CLAUDE.md -> .agents/AGENTS.md（Claude Code 记忆入口）
#                旧位置 .claude/CLAUDE.md 链接由脚本清理（仅限指向 .agents/AGENTS.md 的链接）
#   3. 钩子配置:  .codex/hooks.json 与 .claude/settings.json 写入 PreToolUse
#                指向 .agents/hooks/block-dangerous.sh
#   4. git 配置:  core.hooksPath = .agents/hooks

set -u

MODE=sync
[ "${1:-}" = "--check" ] && MODE=check

KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$KIT_DIR/skills"
HOOKS_DIR="$KIT_DIR/hooks"
AGENTS_FILE="$KIT_DIR/AGENTS.md"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "error: 不在 git 仓库中" >&2
  exit 2
}

DRIFT=0
ERRORS=0

say() {
  printf '[install] %s\n' "$1"
}

drift() {
  DRIFT=$((DRIFT + 1))
  printf '[install] 差异: %s\n' "$1"
}

conflict() {
  ERRORS=$((ERRORS + 1))
  printf '[install] 冲突: %s\n' "$1" >&2
}

ensure_link() {
  local link="$1" target="$2" label="$3"
  if [ -L "$link" ]; then
    local cur
    cur=$(readlink "$link")
    if [ "$cur" != "$target" ]; then
      drift "$label 链接指向 $cur（期望 $target）"
      if [ "$MODE" = sync ]; then
        rm -f -- "$link"
        ln -s -- "$target" "$link" && say "已修复 $label 链接"
      fi
    fi
  elif [ -e "$link" ] || [ -d "$link" ]; then
    conflict "$label 已存在且不是符号链接（$link），跳过"
  else
    drift "$label 缺失"
    if [ "$MODE" = sync ]; then
      ln -s -- "$target" "$link" && say "已创建 $label 链接"
    fi
  fi
}

ensure_dir() {
  [ -d "$1" ] || {
    drift "缺少目录 $1"
    if [ "$MODE" = sync ]; then
      mkdir -p -- "$1" && say "已创建目录 $1"
    fi
  }
}

# 1. 技能链接（Claude Code 不认 .agents/skills，逐技能链接）
ensure_dir "$REPO_ROOT/.claude"
ensure_dir "$REPO_ROOT/.claude/skills"
for skill_dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$skill_dir")
  ensure_link "$REPO_ROOT/.claude/skills/$name" "../../.agents/skills/$name" "技能 $name"
done

# 2. 指令链接（根 CLAUDE.md 是 Claude Code 的记忆入口）
ensure_link "$REPO_ROOT/AGENTS.md" ".agents/AGENTS.md" "根 AGENTS.md"
ensure_link "$REPO_ROOT/CLAUDE.md" ".agents/AGENTS.md" "根 CLAUDE.md"

# 清理旧位置 .claude/CLAUDE.md：只删本套件创建的链接（指向 .agents/AGENTS.md），其余一律跳过
LEGACY_CLAUDE_LINK="$REPO_ROOT/.claude/CLAUDE.md"
if [ -L "$LEGACY_CLAUDE_LINK" ]; then
  cur=$(readlink "$LEGACY_CLAUDE_LINK")
  if [ "$cur" = "../.agents/AGENTS.md" ]; then
    drift "旧位置 .claude/CLAUDE.md 链接指向 .agents/AGENTS.md"
    if [ "$MODE" = sync ]; then
      rm -f -- "$LEGACY_CLAUDE_LINK" && say "已移除旧 CLAUDE.md 链接"
    fi
  else
    conflict ".claude/CLAUDE.md 是指向 $cur 的链接，不是本套件创建，跳过"
  fi
elif [ -e "$LEGACY_CLAUDE_LINK" ]; then
  conflict ".claude/CLAUDE.md 是真实文件，跳过"
fi

# 3. hooks 配置
write_hook_json() {
  local file="$1" abs_hook="$2"
  local block
  block=$(printf '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"%s"}]}]}}' "$abs_hook")
  if [ -f "$file" ]; then
    if grep -q 'block-dangerous' "$file" 2>/dev/null; then
      say "$file 已包含 block-dangerous 钩子，跳过"
      return
    fi
    if command -v jq >/dev/null 2>&1; then
      drift "$file 缺少 block-dangerous 钩子"
      if [ "$MODE" = sync ]; then
        tmp="${file}.tmp.$$"
        if printf '%s' "$block" | jq -s '.[0] as $new | .[1] as $old | $old | .hooks.PreToolUse += $new.hooks.PreToolUse' - "$file" > "$tmp" \
          && mv -- "$tmp" "$file"; then
          say "已合并 $file"
        else
          conflict "无法合并 $file（写入失败）"
          rm -f -- "$tmp" 2>/dev/null || true
        fi
      fi
    else
      conflict "$file 已存在且缺少 jq，无法自动合并；请手动添加 block-dangerous 钩子"
    fi
  else
    drift "$file 缺失"
    if [ "$MODE" = sync ]; then
      if [ -w "$(dirname "$file")" ]; then
        printf '%s\n' "$block" > "$file" && say "已创建 $file"
      else
        conflict "无法写入 $file（目录只读或权限不足）"
      fi
    fi
  fi
}

write_hook_json "$REPO_ROOT/.codex/hooks.json" "$HOOKS_DIR/block-dangerous.sh"
write_hook_json "$REPO_ROOT/.claude/settings.json" "$HOOKS_DIR/block-dangerous.sh"

# 4. git hooks 路径
cur_hooks=$(git config --get core.hooksPath 2>/dev/null || true)
if [ "$cur_hooks" != ".agents/hooks" ]; then
  drift "core.hooksPath = ${cur_hooks:-（未设置）}（期望 .agents/hooks）"
  if [ "$MODE" = sync ]; then
    git config core.hooksPath .agents/hooks && say "已设置 core.hooksPath = .agents/hooks"
  fi
fi

# 可执行位
for f in "$HOOKS_DIR"/pre-commit "$HOOKS_DIR"/commit-msg "$HOOKS_DIR"/pre-push "$HOOKS_DIR"/block-dangerous.sh; do
  if [ ! -x "$f" ]; then
    drift "$f 缺少可执行位"
    if [ "$MODE" = sync ]; then
      chmod +x -- "$f" && say "已 chmod +x $f"
    fi
  fi
done

if [ "$MODE" = check ]; then
  if [ "$ERRORS" -gt 0 ]; then
    printf '[install] check: %d 处差异，%d 处冲突\n' "$DRIFT" "$ERRORS"
    exit 1
  fi
  if [ "$DRIFT" -eq 0 ]; then
    printf '[install] check: 无差异\n'
  else
    printf '[install] check: %d 处差异\n' "$DRIFT"
    exit 1
  fi
  exit 0
fi

if [ "$ERRORS" -gt 0 ]; then
  printf '[install] sync: %d 处已修复，%d 处冲突未处理\n' "$DRIFT" "$ERRORS"
  exit 1
fi
printf '[install] sync: 完成（%d 处已修复）。\n' "$DRIFT"
printf '[install] 提示: 重启 Codex / Claude Code 会话后生效；Codex 原生读取 .agents/skills，Claude 经 .claude/skills 链接。\n'
exit 0
