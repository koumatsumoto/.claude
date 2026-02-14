#!/usr/bin/env bash
set -euo pipefail

TARGET="all"
MODE="link"
FALLBACK_COPY=0

usage() {
  cat <<'EOF'
Usage:
  bash install.sh [--target claude|codex|all] [--mode link|copy] [--fallback-copy]

Options:
  --target          Install destination. Default: all
  --mode            Install mode. Default: link
  --fallback-copy   If mode=link and symlink fails, fallback to copy
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --fallback-copy)
      FALLBACK_COPY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ "$TARGET" != "claude" && "$TARGET" != "codex" && "$TARGET" != "all" ]]; then
  echo "Invalid --target: $TARGET" >&2
  exit 1
fi

if [[ "$MODE" != "link" && "$MODE" != "copy" ]]; then
  echo "Invalid --mode: $MODE" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
TS="$(date +%Y%m%d%H%M%S)"

backup_path() {
  local dest="$1"
  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="${dest}.bak.${TS}"
    mv "$dest" "$backup"
    echo "Backed up: $dest -> $backup"
  fi
}

ensure_parent_dir() {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
}

copy_item() {
  local src="$1"
  local dest="$2"

  ensure_parent_dir "$dest"
  backup_path "$dest"

  if [[ -d "$src" ]]; then
    cp -R "$src" "$dest"
  else
    cp "$src" "$dest"
  fi

  echo "Copied: $src -> $dest"
}

link_item() {
  local src="$1"
  local dest="$2"

  ensure_parent_dir "$dest"
  backup_path "$dest"

  if ln -s "$src" "$dest" 2>/dev/null; then
    echo "Linked: $dest -> $src"
    return 0
  fi

  if [[ "$FALLBACK_COPY" -eq 1 ]]; then
    echo "Symlink failed for $dest. Falling back to copy."
    if [[ -d "$src" ]]; then
      cp -R "$src" "$dest"
    else
      cp "$src" "$dest"
    fi
    echo "Copied: $src -> $dest"
    return 0
  fi

  echo "Failed to create symlink: $dest -> $src" >&2
  echo "Re-run with --fallback-copy if needed." >&2
  return 1
}

install_item() {
  local src="$1"
  local dest="$2"

  if [[ "$MODE" == "copy" ]]; then
    copy_item "$src" "$dest"
  else
    link_item "$src" "$dest"
  fi
}

install_claude() {
  echo "Installing Claude Code configuration..."
  install_item "$REPO_ROOT/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  install_item "$REPO_ROOT/agents" "$HOME/.claude/agents"
  install_item "$REPO_ROOT/commands" "$HOME/.claude/commands"
  install_item "$REPO_ROOT/rules" "$HOME/.claude/rules"
  install_item "$REPO_ROOT/skills" "$HOME/.claude/skills"
}

install_codex() {
  echo "Installing Codex CLI configuration..."
  install_item "$REPO_ROOT/CLAUDE.md" "$HOME/.codex/AGENTS.md"
  install_item "$REPO_ROOT/config.toml" "$HOME/.codex/config.toml"
  install_item "$REPO_ROOT/skills" "$HOME/.agents/skills"
}

if [[ "$TARGET" == "claude" || "$TARGET" == "all" ]]; then
  install_claude
fi

if [[ "$TARGET" == "codex" || "$TARGET" == "all" ]]; then
  install_codex
fi

echo "Done."
