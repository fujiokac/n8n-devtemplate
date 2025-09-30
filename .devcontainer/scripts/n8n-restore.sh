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

# Check for help argument
case "${1:-}" in
    -h|--help|help)
        cat "$SCRIPT_DIR/help/n8n-restore.help"
        exit 0
        ;;
esac

echo "=== n8n Restore ==="

# Stop n8n before restoring
echo "Stopping n8n before restore..."
"$SCRIPT_DIR/stop-n8n.sh"

# Check if backup file is provided
if [ $# -eq 0 ] || [ ! -f "$1" ]; then
    # Restore from git
    echo "Fetching latest backup from git..."
    GIT_OUTPUT=$("$BACKUP_HELPERS_DIR/restore-from-git.sh" "$@")

    # Extract backup filename from the output
    BACKUP_FILE=$(echo "$GIT_OUTPUT" | grep "BACKUP_FILE:" | cut -d: -f2)

    if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
        echo "Error: Could not determine backup file location from git"
        exit 1
    fi
    echo "Extracted backup file: $BACKUP_FILE"
else
    # Local file restore
    BACKUP_FILE="$1"
    echo "Restoring from local file: $BACKUP_FILE"
fi

# Perform the actual restore
echo "Restoring backup data..."
"$BACKUP_HELPERS_DIR/restore-backup.sh" "$BACKUP_FILE"

# Cleanup temporary files if created during git extraction
if echo "$BACKUP_FILE" | grep -q "${TMPDIR:-/tmp}"; then
    echo "Cleaning up temporary backup file..."
    rm -f "$BACKUP_FILE"
fi

echo ""
echo "✅ Restore complete!"
echo ""
echo "Remember to:"
echo "   - Re-enter credentials manually"
echo "   - Review and activate workflows as needed"