#!/bin/sh

# n8n Backup Orchestrator
# Creates encrypted n8n backups and commits them to git

set -e

# Get the real path of the script, following symlinks
SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
BACKUP_HELPERS_DIR="$SCRIPT_DIR/n8n-backup-helpers"

# Check for help and restore arguments
case "${1:-}" in
    -h|--help|help)
        cat "$SCRIPT_DIR/help/n8n-backup.help"
        exit 0
        ;;
    --restore)
        shift
        exec "$SCRIPT_DIR/n8n-restore.sh" "$SCRIPT_DIR" "$@"
        ;;
esac

# Setup logging (only for backup operations)
LOG_FILE="${LOGS_DIR:-logs}/n8n-backup.log"
exec > >(tee "$LOG_FILE") 2>&1

echo "=== n8n Backup ==="

# Run backup creation and capture output
echo "Creating backup..."
BACKUP_OUTPUT=$("$BACKUP_HELPERS_DIR/create-backup.sh" "$@")
echo "$BACKUP_OUTPUT"

# Extract backup filename from the output
BACKUP_FILE=$(echo "$BACKUP_OUTPUT" | grep "BACKUP_FILE:" | cut -d: -f2)

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Could not determine backup file location"
    exit 1
fi

echo "Committing backup to git..."
"$BACKUP_HELPERS_DIR/commit-backup-to-git.sh" "$BACKUP_FILE"

echo ""
echo "✅ Backup complete!"
echo "   Backup: $(basename "$BACKUP_FILE")"
echo ""
echo "To push backup to remote:"
echo "   git push origin backups"