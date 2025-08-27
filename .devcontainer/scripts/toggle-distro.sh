#!/usr/bin/env bash
set -euo pipefail

# Paths
DCONFIG="$(dirname "${BASH_SOURCE[0]}")/../devcontainer.json"
BACKUP="${DCONFIG}.bak"

if [[ ! -f "$DCONFIG" ]]; then
    echo "Error: $DCONFIG not found."
    exit 1
fi

# Backup current file (always overwrites the same .bak)
cp "$DCONFIG" "$BACKUP"
echo "Backup saved to $BACKUP"

# Get current value
CURRENT=$(grep -Po '"BASE_VARIANT"\s*:\s*"\K[^"]+' "$DCONFIG" || true)

if [[ "$CURRENT" == "alpine" ]]; then
    NEW="debian"
elif [[ "$CURRENT" == "debian" ]]; then
    NEW="alpine"
else
    echo "No BASE_VARIANT found; defaulting to alpine"
    NEW="alpine"
fi

# Replace in place
perl -i -pe "s/(\"BASE_VARIANT\"\\s*:\\s*\")$CURRENT(\")/\1$NEW\2/" "$DCONFIG"

echo "Switched BASE_VARIANT: $CURRENT → $NEW"
echo "Rebuild your container to apply the change:"
echo "  In Codespaces: Ctrl+Shift+P → 'Rebuild Container'"