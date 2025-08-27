#!/usr/bin/env bash
set -euo pipefail

DCONFIG="$(dirname "${BASH_SOURCE[0]}")/../devcontainer.json"
BACKUP="${DCONFIG}.bak"

[[ -f "$DCONFIG" ]] || { echo "Error: $DCONFIG not found."; exit 1; }

cp "$DCONFIG" "$BACKUP"
echo "Backup saved to $BACKUP"

CURRENT=$(grep -Po '"BASE_IMAGE_TAG"\s*:\s*"\K[^"]+' "$DCONFIG" || true)

if [[ "$CURRENT" == "18-alpine" ]]; then
    NEW="18"
elif [[ "$CURRENT" == "18" ]]; then
    NEW="18-alpine"
else
    echo "Unknown or missing BASE_IMAGE_TAG, defaulting to 18-alpine"
    NEW="18-alpine"
fi

perl -i -pe "s/(\"BASE_IMAGE_TAG\"\\s*:\\s*\")$CURRENT(\")/\1$NEW\2/" "$DCONFIG"

echo "Switched BASE_IMAGE_TAG: $CURRENT → $NEW"
echo "Now rebuild the container to apply:"
echo "  In Codespaces: Ctrl+Shift+P → 'Rebuild Container'"