#!/bin/sh

# Display important user notifications after container attach
# Usage: Called automatically by post-attach script

set -e

WORKSPACE_DIR="$1"
REPO_NAME="$2"

# Change to workspace directory
cd "$WORKSPACE_DIR"

# Git-crypt key backup reminder
check_git_crypt_backup_reminder() {
    # Only show reminder if git-crypt is initialized and key not backed up
    if [ -d .git/git-crypt ] && [ -f .env ]; then
        # Check if key backup flag is false
        if grep -q "GIT_CRYPT_KEY_BACKED_UP=false" .env 2>/dev/null; then
            echo ""
            echo "🔑 REMINDER: Backup your git-crypt encryption keys!"
            echo "   Without these keys, encrypted secrets will be permanently inaccessible."
            echo ""
            echo "   Quick backup: .devcontainer/scripts/git-crypt-utility.sh export-key"
            echo "   Full help:    .devcontainer/scripts/git-crypt-utility.sh help"
            echo ""
        fi
    fi
}

# Run all notification checks
check_git_crypt_backup_reminder

# Additional notifications can be added here as functions