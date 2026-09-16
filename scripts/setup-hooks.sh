#!/bin/bash
# Installs the git hooks; run once after cloning. Linked by hand rather than
# with `pre-commit install`, which would need pre-commit on the host.

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SCRIPTS_DIR="$REPO_ROOT/scripts"

echo "🔧 Setting up git hooks for muncher..."

mkdir -p "$HOOKS_DIR"

if [ -L "$HOOKS_DIR/pre-commit" ]; then
    echo "  Removing existing pre-commit symlink..."
    rm "$HOOKS_DIR/pre-commit"
elif [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo "  Backing up existing pre-commit hook to pre-commit.backup..."
    mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup"
fi

ln -s "$SCRIPTS_DIR/pre-commit.sh" "$HOOKS_DIR/pre-commit"
echo "  ✅ Linked pre-commit hook"

chmod +x "$SCRIPTS_DIR/pre-commit.sh"
echo "  ✅ Made pre-commit.sh executable"

echo ""
echo "🎉 Git hooks setup complete!"
