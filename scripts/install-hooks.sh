#!/usr/bin/env sh
set -e

ROOT="$(pwd)"
HOOK_SRC_DIR="$ROOT/.githooks"
HOOK_TARGET_DIR="$ROOT/.git/hooks"

if [ ! -d "$HOOK_SRC_DIR" ]; then
    echo "No .githooks directory found in repo root. Exiting."
    exit 1
fi

if [ ! -d "$HOOK_TARGET_DIR" ]; then
    echo ".git/hooks directory not found; are you in a git repository?"
    exit 1
fi

cp -v "$HOOK_SRC_DIR/pre-commit" "$HOOK_TARGET_DIR/pre-commit"
chmod +x "$HOOK_TARGET_DIR/pre-commit"
echo "Pre-commit hook installed to .git/hooks/pre-commit"
