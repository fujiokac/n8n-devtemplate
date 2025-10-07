#!/bin/sh

# Create encrypted backup of n8n workflows and custom nodes
# Usage: create-backup.sh [backup_name]

set -e

GIT_USER="$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
BACKUP_NAME="${1:-${GIT_USER}_n8n-backup-$(date +%Y%m%d-%H%M%S)}"
N8N_DATA_DIR="${N8N_USER_FOLDER:-.n8n}/.n8n"
TEMP_DIR="${TMPDIR:-/tmp}/n8n-backup-$$"

# Ensure cleanup on exit
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

echo "Creating n8n backup: $BACKUP_NAME"

# Note: Encryption is now handled by git-crypt, no backup key needed

# Create temporary directory
mkdir -p "$TEMP_DIR/n8n-data"

echo "Exporting workflows and credentials using n8n CLI..."
npx n8n export:workflow --backup --output "$TEMP_DIR/n8n-data/workflows/" && \
npx n8n export:credentials --backup --output "$TEMP_DIR/n8n-data/credentials/" || {
    echo "❌ ERROR: Failed to export workflows or credentials"
    exit 1
}

echo "Copying binary data..."
if [ -d "$N8N_DATA_DIR/binaryData" ]; then
    cp -r "$N8N_DATA_DIR/binaryData" "$TEMP_DIR/n8n-data/"
else
    echo "Info: binaryData directory not found - no binary attachments to backup"
fi

echo "Copying custom nodes..."
if [ -d "$N8N_DATA_DIR/nodes" ]; then
    cp -r "$N8N_DATA_DIR/nodes" "$TEMP_DIR/n8n-data/"
else
    echo "Info: nodes directory not found - no custom nodes to backup"
fi

# Validate backup data completeness
echo "Validating backup data..."
if [ ! -d "$TEMP_DIR/n8n-data/workflows" ]; then
    echo "⚠️  WARNING: No workflows exported"
fi
if [ ! -d "$TEMP_DIR/n8n-data/credentials" ]; then
    echo "⚠️  WARNING: No credentials exported"
fi

# Create backup in configured directory (encrypted by git-crypt)
BACKUP_DIR="${N8N_BACKUPS_PATH:-secrets/backups}"
mkdir -p "$BACKUP_DIR"

# Create archive directly in final location
echo "Creating archive..."
BACKUP_FILE="$BACKUP_DIR/$BACKUP_NAME.tar.gz"
tar -czf "$BACKUP_FILE" -C "$TEMP_DIR" n8n-data/

# Verify archive integrity
echo "Verifying archive integrity..."
if ! tar -tzf "$BACKUP_FILE" >/dev/null; then
    echo "❌ ERROR: Archive verification failed - backup may be corrupted"
    exit 1
fi

echo "Backup created successfully: $BACKUP_FILE"
echo "Size: $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""

# Return backup file path for orchestrator scripts
echo "BACKUP_FILE:$BACKUP_FILE"