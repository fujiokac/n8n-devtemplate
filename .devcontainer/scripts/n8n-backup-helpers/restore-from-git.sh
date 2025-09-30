#!/bin/sh

# Extract n8n backup from git branch
# Usage: restore-from-git.sh [backup_name]
# If no backup_name provided, uses latest backup

set -e
BACKUP_BRANCH="${N8N_BACKUP_BRANCH:-backups}"

echo "=== n8n Manual Restore from Git ==="

# Determine which backup to restore
if [ -n "$1" ]; then
    SELECTED_BACKUP="$1"
    echo "Restoring specific backup: $SELECTED_BACKUP"
else
    # Get latest backup
    BACKUPS_PATH="${N8N_BACKUPS_PATH:-secrets/backups}"
    echo "Finding latest backup in '$BACKUP_BRANCH' branch..."
    BACKUP_FILE=$(git show "$BACKUP_BRANCH:$BACKUPS_PATH" 2>/dev/null | grep -E "\.tar\.gz$" | tail -1) || {
        echo "Error: No backups found in branch '$BACKUP_BRANCH'"
        exit 1
    }
    SELECTED_BACKUP="$BACKUPS_PATH/$BACKUP_FILE"
    echo "Using latest backup: $SELECTED_BACKUP"
fi

# Extract backup from git to backups folder
BACKUP_DESTINATION="$SELECTED_BACKUP"
mkdir -p "$(dirname "$BACKUP_DESTINATION")"
echo "Extracting backup from git..."
git show "$BACKUP_BRANCH:$SELECTED_BACKUP" > "$BACKUP_DESTINATION" || {
    echo "Error: Backup '$SELECTED_BACKUP' not found in branch '$BACKUP_BRANCH'"
    exit 1
}

# Return backup file path for orchestrator
echo "BACKUP_FILE:$BACKUP_DESTINATION"