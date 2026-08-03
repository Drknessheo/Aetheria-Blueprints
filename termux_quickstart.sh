#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/Drknessheo/Aetheria-Blueprints.git}"
TARGET_DIR="${2:-\$HOME/aetheria-blueprints}"
BRANCH="${3:-main}"

echo
echo "Aetheria Termux Quickstart"
echo "Repository: $REPO_URL"
echo "Target dir: $TARGET_DIR"
echo

if command -v termux-setup-storage >/dev/null 2>&1; then
  echo "Requesting Android storage permission (termux-setup-storage)..."
  termux-setup-storage || true
  sleep 1
else
  echo "termux-setup-storage not found; if running in Termux, please install termux-api or run termux-setup-storage manually."
fi

echo "Updating packages and installing git, openssh, curl, and python..."
if command -v pkg >/dev/null 2>&1; then
  pkg update -y
  pkg install -y git openssh curl wget python nodejs
else
  if command -v apt >/dev/null 2>&1; then
    apt update && apt install -y git openssh-client curl wget python3 nodejs
  fi
fi

mkdir -p "$(dirname "$TARGET_DIR")"
if [ -d "$TARGET_DIR/.git" ]; then
  echo "Repository already cloned. Fetching latest from $BRANCH..."
  cd "$TARGET_DIR"
  git fetch origin "$BRANCH"
  git checkout "$BRANCH"
  git pull --ff-only origin "$BRANCH"
else
  echo "Cloning repository into $TARGET_DIR..."
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
fi

echo
echo "Setup complete. Quick next steps:"
echo "  1) cd \"$TARGET_DIR\""
echo "  2) List blueprints: ls *.md"
echo "  3) To run a blueprint locally, open the .md, copy the prompt matrix into your LLM client or follow the README_Getting_Started.md in the repo."
echo
exit 0
