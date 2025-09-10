#!/bin/sh

# n8n Restore Orchestrator
# Restores n8n data from encrypted backups (local or git)

set -e

SCRIPT_DIR="$(dirname "$0")"

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
    "$SCRIPT_DIR/n8n-backup/restore-backup.sh" "$BACKUP_FILE"
else
    # Restore from git
    echo "Fetching latest backup from git..."
    "$SCRIPT_DIR/n8n-backup/restore-from-git.sh" "$@"
fi

echo ""
echo "✅ Restore complete!"
echo ""
echo "Remember to:"
echo "   - Re-enter credentials manually"
echo "   - Review and activate workflows as needed"