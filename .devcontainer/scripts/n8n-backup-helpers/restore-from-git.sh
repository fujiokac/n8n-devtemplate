#!/bin/sh

# Extract n8n backup from git branch
# Usage: restore-from-git.sh [-i|--interactive] [backup_name]
# If no backup_name provided, uses latest backup
# -i, --interactive: Show interactive selection menu

set -e
BACKUP_BRANCH="${N8N_BACKUP_BRANCH:-backups}"
BACKUPS_DIR="${N8N_BACKUPS_PATH:-secrets/backups}"

echo "=== n8n Manual Restore from Git ==="

get_backups() {
    RESULT=$(git log $1 "$BACKUP_BRANCH" --pretty="" --name-only -- "$BACKUPS_DIR/" | grep -E "\.tar\.gz$") || {
        echo "Error: No backups found in branch '$BACKUP_BRANCH'"
        exit 1
    }

    echo "$RESULT"
}

select_backup() {
    BACKUP_LIST=$(get_backups)

    echo ""
    echo "Available backups:"
    echo "$BACKUP_LIST" | nl -w2 -s'. '
    echo ""
    BACKUP_COUNT=$(echo "$BACKUP_LIST" | wc -l)

    while true; do
        printf "Select backup (1-%d) or press Enter for latest: " "$BACKUP_COUNT"
        read -r SELECTION

        # Default to 1 (latest) if empty
        SELECTION=${SELECTION:-1}

        BACKUP_PATH=$(echo "$BACKUP_LIST" | sed -n "${SELECTION}p")
        if [ -n "$BACKUP_PATH" ]; then
            return
        fi

        echo "Invalid selection. Please try again."
    done
}

# Parse arguments and determine backup
case "$1" in
    -i|--interactive)
        select_backup
        ;;
    "")
        BACKUP_PATH=$(get_backups "-1")
        ;;
    *)
        BACKUP_PATH="$BACKUPS_DIR/$1"
        ;;
esac

echo "Using backup: $BACKUP_PATH"

# Fetch backup from git to local backups folder
mkdir -p "$(dirname "$BACKUP_PATH")"
echo "Fetching backup from git..."
git show "$BACKUP_BRANCH:$BACKUP_PATH" > "$BACKUP_PATH" || {
    echo "Error: Backup '$BACKUP_PATH' not found in branch '$BACKUP_BRANCH'"
    exit 1
}

# Return backup file path for orchestrator
echo "BACKUP_FILE:$BACKUP_PATH"