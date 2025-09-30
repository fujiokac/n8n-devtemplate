#!/bin/sh

# Extract n8n backup from git branch
# Usage: restore-from-git.sh [backup_name]
# If no backup_name provided, uses latest backup

set -e
BACKUP_BRANCH="${N8N_BACKUP_BRANCH:-backups}"

echo "=== n8n Manual Restore from Git ==="

# Check if backup key is configured
if [ -z "$N8N_BACKUP_KEY" ]; then
    echo "Error: N8N_BACKUP_KEY environment variable not set"
    echo "Configure the backup key in GitHub Codespace secrets"
    exit 1
fi

# Determine which backup to restore
if [ -n "$1" ]; then
    SELECTED_BACKUP="$1"
    echo "Restoring specific backup: $SELECTED_BACKUP"
else
    # Get latest backup
    echo "Finding latest backup in '$BACKUP_BRANCH' branch..."
    SELECTED_BACKUP=$(git show "$BACKUP_BRANCH:" 2>/dev/null | grep -E "\.tar\.gz\.enc$" | head -1) || {
        echo "Error: No backups found in branch '$BACKUP_BRANCH'"
        exit 1
    }
    echo "Using latest backup: $SELECTED_BACKUP"
fi

# Extract backup from git
TEMP_BACKUP="${TMPDIR:-/tmp}/$SELECTED_BACKUP"
echo "Extracting backup from git..."
git show "$BACKUP_BRANCH:$SELECTED_BACKUP" > "$TEMP_BACKUP" || {
    echo "Error: Backup '$SELECTED_BACKUP' not found in branch '$BACKUP_BRANCH'"
    exit 1
}

# Return backup file path for orchestrator
echo "BACKUP_FILE:$TEMP_BACKUP"