#!/bin/bash

# Setup script for git hooks in muncher monorepo
# Run this once after cloning the repository

set -e

# Get the root directory of the git repository
REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SCRIPTS_DIR="$REPO_ROOT/scripts"

echo "🔧 Setting up git hooks for muncher..."

# Ensure the hooks directory exists
mkdir -p "$HOOKS_DIR"

# Create symlink for pre-commit hook
if [ -L "$HOOKS_DIR/pre-commit" ]; then
    echo "  Removing existing pre-commit symlink..."
    rm "$HOOKS_DIR/pre-commit"
elif [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo "  Backing up existing pre-commit hook to pre-commit.backup..."
    mv "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-commit.backup"
fi

# Create the symlink
ln -s "$SCRIPTS_DIR/pre-commit.sh" "$HOOKS_DIR/pre-commit"
echo "  ✅ Linked pre-commit hook"

# Ensure the script is executable
chmod +x "$SCRIPTS_DIR/pre-commit.sh"
echo "  ✅ Made pre-commit.sh executable"

echo ""
echo "🎉 Git hooks setup complete!"
