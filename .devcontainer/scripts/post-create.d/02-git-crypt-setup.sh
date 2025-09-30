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

echo "✅ Git-crypt setup complete"
echo ""
echo "🔑 IMPORTANT: Backup your git-crypt keys!"
echo "   • Run: .devcontainer/scripts/git-crypt-utility.sh export-key"