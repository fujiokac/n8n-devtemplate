#!/bin/sh

# Commit backup file to git orphan branch
# Usage: commit-backup-to-git.sh <backup_file>

set -e

# Setup logging
LOG_FILE="${LOGS_DIR:-logs}/n8n-backup-commit-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee "$LOG_FILE") 2>&1

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 \${TMPDIR:-/tmp}/n8n-backups/n8n-backup-20250901-143022.tar.gz.enc"
    exit 1
fi

BACKUP_FILE="$1"
BACKUP_NAME="$(basename "$BACKUP_FILE")"

# Check if backup branch is configured
if [ -z "$N8N_BACKUP_BRANCH" ]; then
    echo "Error: N8N_BACKUP_BRANCH environment variable not set"
    echo "Check that .env file is properly configured"
    exit 1
fi

BACKUP_BRANCH="$N8N_BACKUP_BRANCH"

echo "Committing backup to git: $BACKUP_NAME"

# Verify backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Stash any uncommitted changes
STASH_CREATED=false
if ! git diff-index --quiet HEAD --; then
    echo "Stashing uncommitted changes..."
    git stash push -m "Auto-stash before backup commit"
    STASH_CREATED=true
fi

# Create or switch to orphan backup branch
git checkout --orphan "$BACKUP_BRANCH" 2>/dev/null || git checkout "$BACKUP_BRANCH"

# Clean working directory if switching to existing orphan branch
git rm -rf . 2>/dev/null || true

# Copy and add the backup file
cp "$BACKUP_FILE" "$BACKUP_NAME"
git add "$BACKUP_NAME"

# Keep only the last N backups (default: 5)
MAX_BACKUPS="${N8N_BACKUP_RETENTION:-5}"

# Get list of existing backup files and remove oldest ones
EXISTING_BACKUPS=$(git ls-files "*.tar.gz.enc" 2>/dev/null | sort -r || true)
BACKUP_COUNT=$(echo "$EXISTING_BACKUPS" | wc -l)

if [ "$BACKUP_COUNT" -ge "$MAX_BACKUPS" ]; then
    echo "Cleaning up old backups (keeping $MAX_BACKUPS most recent)..."
    BACKUPS_TO_REMOVE=$(echo "$EXISTING_BACKUPS" | tail -n +$MAX_BACKUPS)
    for old_backup in $BACKUPS_TO_REMOVE; do
        if [ -f "$old_backup" ]; then
            rm -f "$old_backup"
            echo "Removed old backup: $old_backup"
        fi
    done
fi

# Commit the backup
git commit -m "Add n8n backup: $BACKUP_NAME"

BACKUP_SIZE=$(du -h "$BACKUP_NAME" | cut -f1)

# Switch back to original branch
git checkout "$CURRENT_BRANCH"

# Restore stashed changes if any
if [ "$STASH_CREATED" = true ]; then
    echo "Restoring stashed changes..."
    git stash pop
fi

echo "✅ Backup committed to '$BACKUP_BRANCH' branch"
echo "   File: $BACKUP_NAME"
echo "   Size: $BACKUP_SIZE"
echo ""
echo "To push backup to remote:"
echo "git push origin $BACKUP_BRANCH"