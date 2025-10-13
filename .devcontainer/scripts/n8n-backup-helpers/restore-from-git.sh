#!/bin/sh

# Extract n8n backup from git branch
# Usage: restore-from-git.sh [--list] [-n|--number <num>] [backup_name]
# If no backup_name provided, uses latest backup
# --list: Show numbered list of available backups and exit
# -n, --number: Select backup by number from list

set -e
BACKUP_BRANCH="${N8N_BACKUP_BRANCH:-backups}"
BACKUPS_DIR="${N8N_BACKUPS_PATH:-secrets/backups}"

echo "=== n8n Manual Restore from Git ==="

get_backups() {
    # $1: optional git log limit (e.g., "-1" for latest only)
    RESULT=$(git log $1 "$BACKUP_BRANCH" --pretty="" --name-only -- "$BACKUPS_DIR/" | grep -E "\.tar\.gz$") || {
        echo "Error: No backups found in branch '$BACKUP_BRANCH'"
        exit 1
    }

    echo "$RESULT"
}

# Parse arguments and determine backup
case "$1" in
    --list)
        echo ""
        echo "Available backups:"
        get_backups | nl -w2 -s'. '
        exit 0
        ;;
    -n|--number)
        BACKUP_LIST=$(get_backups)
        BACKUP_PATH=$(echo "$BACKUP_LIST" | sed -n "${2}p")
        if [ -z "$BACKUP_PATH" ]; then
            echo "❌ ERROR: Invalid backup number: $2"
            echo "Run with --list to see available backups"
            exit 1
        fi
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