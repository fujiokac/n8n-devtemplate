#!/bin/sh

# Initialize git-crypt for secrets encryption
# Usage: Called automatically by post-attach script

set -e

WORKSPACE_DIR="$1"
REPO_NAME="$2"

echo "=== Git-Crypt Setup ==="

# Change to workspace directory
cd "$WORKSPACE_DIR"

# Install git-crypt if not available
if ! command -v git-crypt >/dev/null 2>&1; then
    echo "Installing git-crypt..."
    sudo apk add --no-cache git-crypt >/dev/null 2>&1 || {
        echo "⚠️ Failed to install git-crypt"
        exit 1
    }
fi

# Initialize git-crypt if not already initialized
if [ ! -d .git/git-crypt ]; then
    echo "Initializing git-crypt..."
    git-crypt init >/dev/null 2>&1 || {
        echo "⚠️ Failed to initialize git-crypt"
        exit 1
    }
    echo "✅ Git-crypt initialized"
else
    echo "ℹ️ Git-crypt already initialized"
fi

# Always verify filter configuration exists
if ! git config --get filter.git-crypt.clean >/dev/null 2>&1; then
    echo "⚠️ Git-crypt filters missing from .git/config, restoring..."
    git config filter.git-crypt.smudge '"git-crypt" smudge'
    git config filter.git-crypt.clean '"git-crypt" clean'
    git config filter.git-crypt.required true
    git config diff.git-crypt.textconv '"git-crypt" diff'
    git config merge.git-crypt.name 'git-crypt merge driver'
    git config merge.git-crypt.driver '"git-crypt" merge %A %O %B %L'
    echo "✅ Git-crypt filters restored"
fi

echo "✅ Git-crypt setup complete"
echo ""
echo "🔑 IMPORTANT: Backup your git-crypt keys!"
echo "   • Run: .devcontainer/scripts/git-crypt-utility.sh export-key"