#!/bin/sh

# Restore backup of n8n workflows and custom nodes
# Usage: restore-backup.sh <backup_file>

set -e

N8N_DATA_DIR="${N8N_USER_FOLDER:-.n8n}/.n8n"
TEMP_DIR="${TMPDIR:-/tmp}/n8n-restore-$$"

# Ensure cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 n8n-backup-20250901-143022.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"

echo "Restoring n8n backup from: $BACKUP_FILE"

# Verify backup file format
case "$BACKUP_FILE" in
    *.tar.gz)
        echo "Using backup archive..."
        ;;
    *)
        echo "❌ ERROR: Unsupported backup file format. Expected *.tar.gz"
        echo "Provided: $BACKUP_FILE"
        exit 1
        ;;
esac

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Extract archive
echo "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Verify backup structure
if [ ! -d "$TEMP_DIR/n8n-data" ]; then
    echo "❌ ERROR: Invalid backup structure - n8n-data directory not found"
    exit 1
fi

# Create n8n data directory if it doesn't exist
echo "Note: Ensure n8n is stopped before running this restore"
mkdir -p "$N8N_DATA_DIR"

# Restore workflows using n8n CLI
if [ -d "$TEMP_DIR/n8n-data/workflows" ]; then
    echo "Restoring workflows using n8n CLI..."
    # Import all workflow files from backup
    for workflow_file in "$TEMP_DIR/n8n-data/workflows"/*.json; do
        [ -f "$workflow_file" ] || continue
        echo "Importing $(basename "$workflow_file")..."
        npx n8n import:workflow --input "$workflow_file" || {
            echo "⚠️  WARNING: Failed to import $(basename "$workflow_file")"
        }
    done
    echo "Workflows imported successfully"
else
    echo "No workflow backups found in archive"
fi

# Restore credentials
if [ -d "$TEMP_DIR/n8n-data/credentials" ]; then
    echo "Restoring credentials using n8n CLI..."
    npx n8n import:credentials --separate --input="$TEMP_DIR/n8n-data/credentials/" || {
        echo "⚠️  WARNING: Failed to import credentials"
    }
fi

# Restore binary data
if [ -d "$TEMP_DIR/n8n-data/binaryData" ]; then
    echo "Restoring binary data..."
    cp -r "$TEMP_DIR/n8n-data/binaryData" "$N8N_DATA_DIR/"
    echo "Binary data restored"
fi

# Restore custom nodes
if [ -d "$TEMP_DIR/n8n-data/nodes" ]; then
    echo "Restoring custom nodes..."
    cp -r "$TEMP_DIR/n8n-data/nodes" "$N8N_DATA_DIR/"
    echo "Custom nodes restored"
fi

# Set proper permissions
chown -R node:node "$N8N_DATA_DIR" 2>/dev/null || true

echo ""
echo "✅ Backup restored successfully!"
echo ""
echo "Next steps:"
echo "1. Start n8n: n8n start"
echo "2. Test your workflows"