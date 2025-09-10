#!/bin/sh

# Create encrypted backup of n8n workflows and custom nodes
# Usage: create-backup.sh [backup_name] [--auto-commit]

set -e

# Setup logging
LOG_FILE="${LOGS_DIR:-logs}/n8n-backup.log"
exec > >(tee "$LOG_FILE") 2>&1

SCRIPT_DIR="$(dirname "$0")"
GIT_USER="$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
BACKUP_NAME="${1:-${GIT_USER}_n8n-backup-$(date +%Y%m%d-%H%M%S)}"
N8N_DATA_DIR="${N8N_USER_FOLDER:-.n8n}/.n8n"
TEMP_DIR="${TMPDIR:-/tmp}/n8n-backup-$$"

echo "Creating n8n backup: $BACKUP_NAME"

# Check if backup key is available
if [ -z "$N8N_BACKUP_KEY" ]; then
    echo "Error: N8N_BACKUP_KEY environment variable not set"
    echo "Run the post-attach script to generate and configure the backup key"
    exit 1
fi

# Create temporary directory
mkdir -p "$TEMP_DIR/n8n-data"

# Export workflows using n8n native CLI
echo "Exporting workflows using n8n CLI..."
if command -v npx >/dev/null 2>&1; then
    # Export workflows to temp directory
    npx n8n export:workflow --backup --output "$TEMP_DIR/n8n-data/workflows/" || {
        echo "Error: Failed to export workflows using n8n CLI"
        rm -rf "$TEMP_DIR"
        exit 1
    }
    echo "Workflows exported successfully"
else
    echo "Error: npx not found - cannot run n8n CLI commands"
    rm -rf "$TEMP_DIR"
    exit 1
fi

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

# Create archive
echo "Creating archive..."
ARCHIVE_FILE="$TEMP_DIR/$BACKUP_NAME.tar.gz"
tar -czf "$ARCHIVE_FILE" -C "$TEMP_DIR" n8n-data/

# Create backup directory
BACKUP_DIR="${TMPDIR:-/tmp}/n8n-backups"
mkdir -p "$BACKUP_DIR"

# Encrypt archive
echo "Encrypting backup..."
ENCRYPTED_FILE="$BACKUP_DIR/$BACKUP_NAME.tar.gz.enc"
"$SCRIPT_DIR/encrypt-backup.sh" "$ARCHIVE_FILE" "$ENCRYPTED_FILE"

# Cleanup temp extraction
rm -rf "$TEMP_DIR"

echo "Backup created successfully: $ENCRYPTED_FILE"
echo "Size: $(du -h "$ENCRYPTED_FILE" | cut -f1)"
echo ""

# Auto-commit if requested
if [ "$1" = "--auto-commit" ] || [ "$2" = "--auto-commit" ]; then
    echo "Auto-committing to git..."
    "$SCRIPT_DIR/commit-backup-to-git.sh" "$ENCRYPTED_FILE"
else
    echo "To commit backup to git:"
    echo "$SCRIPT_DIR/commit-backup-to-git.sh '$ENCRYPTED_FILE'"
fi