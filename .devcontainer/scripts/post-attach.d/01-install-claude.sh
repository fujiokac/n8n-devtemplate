#!/bin/sh
set -eu

WORKSPACE_DIR="$1"
REPO_NAME="$2"

echo "Installing Claude Code for ${REPO_NAME}..."

# Create temporary log for parsing curl output
TEMP_LOG="$(mktemp)"
trap 'rm -f "$TEMP_LOG"' EXIT

if curl -fsSL https://claude.ai/install.sh | bash >"$TEMP_LOG" 2>&1; then
    cat "$TEMP_LOG"
    echo "✅ Claude Code installed successfully"
    CLAUDE_BIN="$(grep -oE '(/|~)/[^ ]*/claude$' "$TEMP_LOG" | head -n1)"
    CLAUDE_BIN="${CLAUDE_BIN/\~/$HOME}"
    sudo ln -sf "$(readlink -f "$CLAUDE_BIN")" /usr/local/bin/claude
    echo "🔗 Symlinked $CLAUDE_BIN → /usr/local/bin/claude"
else
    echo "⚠️ Claude Code installation failed, but continuing..."
fi