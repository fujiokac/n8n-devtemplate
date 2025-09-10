#!/bin/sh

# n8n Backup Orchestrator
# Creates encrypted n8n backups and commits them to git

set -e

SCRIPT_DIR="$(dirname "$0")"

# Check for help argument
case "${1:-}" in
    -h|--help|help)
        cat "$SCRIPT_DIR/n8n-backup.help"
        exit 0
        ;;
esac

echo "=== n8n Backup ==="

# Run backup creation and capture output
echo "Creating backup..."
BACKUP_OUTPUT=$("$SCRIPT_DIR/n8n-backup/create-backup.sh" "$@")
echo "$BACKUP_OUTPUT"

# Extract backup filename from the output
BACKUP_FILE=$(echo "$BACKUP_OUTPUT" | grep "BACKUP_FILE:" | cut -d: -f2)

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Could not determine backup file location"
    exit 1
fi

echo "Committing backup to git..."
"$SCRIPT_DIR/n8n-backup/commit-backup-to-git.sh" "$BACKUP_FILE"

echo ""
echo "✅ Backup complete!"
echo "   Backup: $(basename "$BACKUP_FILE")"
echo ""
echo "To push backup to remote:"
echo "   git push origin backups"