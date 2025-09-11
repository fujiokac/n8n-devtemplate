#!/bin/sh

# n8n Restore Orchestrator
# Restores n8n data from encrypted backups (local or git)
# Usage: n8n-restore.sh <scripts_dir> [OPTIONS] [backup-file]

set -e

# First parameter is the scripts directory
SCRIPT_DIR="$1"
shift

# Check for help argument
case "${1:-}" in
    -h|--help|help)
        cat "$SCRIPT_DIR/n8n-restore.help"
        exit 0
        ;;
esac

echo "=== n8n Restore ==="

# Check if backup file is provided
if [ $# -gt 0 ] && [ -f "$1" ]; then
    # Local file restore
    BACKUP_FILE="$1"
    echo "Restoring from local file: $BACKUP_FILE"
    "$SCRIPT_DIR/n8n-backup/restore-backup.sh" "$SCRIPT_DIR" "$BACKUP_FILE"
else
    # Restore from git
    echo "Fetching latest backup from git..."
    "$SCRIPT_DIR/n8n-backup/restore-from-git.sh" "$SCRIPT_DIR" "$@"
fi

echo ""
echo "✅ Restore complete!"
echo ""
echo "Remember to:"
echo "   - Re-enter credentials manually"
echo "   - Review and activate workflows as needed"