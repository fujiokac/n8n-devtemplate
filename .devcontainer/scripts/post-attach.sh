#!/bin/sh
set -eu

echo "=== Post-Attach Setup ==="

# Prefer GitHub-provided variable, fall back to current dir name
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    REPO_NAME="${GITHUB_REPOSITORY##*/}"
else
    REPO_NAME="$(basename "$(pwd)")"
fi

WORKSPACE_DIR="/workspaces/${REPO_NAME}"
SCRIPTS_DIR="$(dirname "$0")/post-attach.d"

# Run each executable task script in order
if [ -d "$SCRIPTS_DIR" ]; then
    for script in "$SCRIPTS_DIR"/*; do
        [ -x "$script" ] || continue
        echo "→ Running $(basename "$script")"
        "$script" "$WORKSPACE_DIR" "$REPO_NAME"
    done
else
    echo "⚠️ No post-attach scripts found in $SCRIPTS_DIR"
fi

echo "✅ Post-attach setup complete for ${REPO_NAME}!"