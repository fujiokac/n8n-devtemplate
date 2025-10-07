#!/bin/sh

# Commit backup file to git orphan branch
# Usage: commit-backup-to-git.sh <backup_file>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_file>"
    echo "Example: $0 \${TMPDIR:-/tmp}/n8n-backups/n8n-backup-20250901-143022.tar.gz"
    exit 1
fi

TEMP_BACKUP="$1"
BACKUPS_PATH="${N8N_BACKUPS_PATH:-secrets/backups}"
BACKUP_DESTINATION="$BACKUPS_PATH/$(basename "$TEMP_BACKUP")"

# Check if backup branch is configured
if [ -z "$N8N_BACKUP_BRANCH" ]; then
    echo "❌ ERROR: N8N_BACKUP_BRANCH environment variable not set"
    echo "Check that .env file is properly configured"
    exit 1
fi

BACKUP_BRANCH="$N8N_BACKUP_BRANCH"

echo "Committing backup to git: $(basename "$TEMP_BACKUP")"

# Verify backup file exists
if [ ! -f "$TEMP_BACKUP" ]; then
    echo "❌ ERROR: Backup file '$TEMP_BACKUP' not found"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Stash any uncommitted changes
STASH_CREATED=false
if ! git diff-index --quiet HEAD --; then
    echo "Stashing uncommitted changes..."
    if git stash push -m "Auto-stash before backup commit"; then
        STASH_CREATED=true
    else
        echo "❌ ERROR: Failed to stash changes"
        exit 1
    fi
fi

# Create or switch to orphan backup branch
git checkout --orphan "$BACKUP_BRANCH" 2>/dev/null || git checkout "$BACKUP_BRANCH"

# Ensure backups directory exists
mkdir -p "$BACKUPS_PATH"

# Clean working directory if switching to existing orphan branch (except .gitattributes and secrets/)
git ls-files | grep -v "^\.gitattributes$" | grep -v "^secrets/" | xargs git rm -f 2>/dev/null || true

git add "$BACKUP_DESTINATION"

# Keep only the last N backups if retention is configured
if [ -n "$N8N_BACKUP_RETENTION" ]; then
    MAX_BACKUPS="$N8N_BACKUP_RETENTION"

    # Get list of existing backup files and remove oldest ones
    EXISTING_BACKUPS=$(git ls-files "$BACKUPS_PATH/*.tar.gz" 2>/dev/null | sort -r || true)
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
else
    echo "⚠️  WARNING: N8N_BACKUP_RETENTION not set - backups will not be automatically cleaned up"
fi

# Commit the backup
git commit -m "Add n8n backup: $(date +%Y-%m-%d)"

BACKUP_SIZE=$(du -h "$BACKUP_DESTINATION" | cut -f1)

# Switch back to original branch
git checkout "$CURRENT_BRANCH"

# Restore stashed changes if any
if [ "$STASH_CREATED" = true ]; then
    echo "Restoring stashed changes..."
    if ! git stash pop; then
        echo "⚠️  WARNING: Failed to restore stashed changes"
        echo "Your changes are still in the stash. Run 'git stash pop' manually."
    fi
fi

echo "✅ Backup committed to '$BACKUP_BRANCH' branch"
echo "   File: $(basename "$TEMP_BACKUP")"
echo "   Size: $BACKUP_SIZE"
echo ""
echo "To push backup to remote:"
echo "git push origin $BACKUP_BRANCH"