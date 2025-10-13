#!/bin/sh

# n8n Restore Orchestrator
# Restores n8n data from encrypted backups (local or git)
# Usage: n8n-restore.sh <scripts_dir> [OPTIONS] [backup-file]

set -e

# First parameter is the scripts directory
SCRIPT_DIR="$1"
BACKUP_HELPERS_DIR="$SCRIPT_DIR/n8n-backup-helpers"
shift

# Setup logging
LOG_FILE="${LOGS_DIR:-logs}/n8n-backup-restore.log"
exec > >(tee "$LOG_FILE") 2>&1

# Check for help and list arguments
case "${1:-}" in
    -h|--help|help)
        cat "$SCRIPT_DIR/help/n8n-restore.help"
        exit 0
        ;;
    --list)
        exec "$BACKUP_HELPERS_DIR/restore-from-git.sh" "$@"
        ;;
esac

echo "=== n8n Restore ==="

# Stop n8n before restoring
echo "Stopping n8n before restore..."
"$SCRIPT_DIR/stop-n8n.sh"

# Determine backup source
if [ $# -eq 0 ] || [ ! -f "$1" ]; then
    # Restore from git
    echo "Fetching latest backup from git..."
    GIT_OUTPUT=$("$BACKUP_HELPERS_DIR/restore-from-git.sh" "$@")
    BACKUP_FILE=$(echo "$GIT_OUTPUT" | tail -1 | cut -d: -f2-)

    if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ ERROR: Could not determine backup file location from git"
        exit 1
    fi
else
    # Local file provided
    BACKUP_FILE="$1"
fi

echo "Using backup: $BACKUP_FILE"

# Perform the actual restore
echo "Restoring backup data..."
"$BACKUP_HELPERS_DIR/restore-backup.sh" "$BACKUP_FILE"

echo ""
echo "✅ Restore complete!"
echo ""
echo "Remember to:"
echo "   - Review and activate workflows as needed"