#!/bin/sh

# Auto-restore n8n backup if available and n8n data is missing
# Runs during post-create (codespace creation)
# Args: $1=WORKSPACE_DIR $2=REPO_NAME (optional - will auto-detect if missing)
# Optional: --backup=filename to restore specific backup

set -e

# Handle arguments - use provided or auto-detect
if [ $# -ge 2 ]; then
    WORKSPACE_DIR="$1"
    REPO_NAME="$2"
else
    # Auto-detect when called manually
    if [ -n "${GITHUB_REPOSITORY:-}" ]; then
        REPO_NAME="${GITHUB_REPOSITORY##*/}"
    else
        REPO_NAME="$(basename "$(pwd)")"
    fi
    WORKSPACE_DIR="/workspaces/${REPO_NAME}"
fi

N8N_DATA_DIR="${N8N_USER_FOLDER:-.n8n}/.n8n"
BACKUP_SCRIPT_DIR="$WORKSPACE_DIR/.devcontainer/scripts/n8n-backup"

echo "=== n8n Backup Status ==="

# Check if backup key is configured
if [ -z "$N8N_BACKUP_KEY" ]; then
    echo "ℹ️  N8N_BACKUP_KEY not configured - cannot restore encrypted backups"
    echo "   Configure the backup key in GitHub Codespace secrets to enable restoration"
    exit 0
fi

# Check for available backups

# Change to workspace directory for git operations
cd "$WORKSPACE_DIR"

# Check for available backups
if git rev-parse --git-dir >/dev/null 2>&1; then
    BACKUP_BRANCH="${N8N_BACKUP_BRANCH:-backups}"
    
    # Try to get backups - exit quietly if none found
    if git fetch origin "$BACKUP_BRANCH:$BACKUP_BRANCH" 2>/dev/null && \
       AVAILABLE_BACKUPS=$(git show "$BACKUP_BRANCH:" 2>/dev/null | grep -E "\.tar\.gz\.enc$" | sort -r) && \
       [ -n "$AVAILABLE_BACKUPS" ]; then
        
        BACKUP_COUNT=$(echo "$AVAILABLE_BACKUPS" | wc -l)
        LATEST_BACKUP=$(echo "$AVAILABLE_BACKUPS" | head -1)
        echo "📦 Found $BACKUP_COUNT n8n backup(s) available"
        echo "   Latest: $LATEST_BACKUP"
        echo ""
        echo "To restore workflows, see README for restoration instructions"
    fi
fi