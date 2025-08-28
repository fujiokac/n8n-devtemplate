#!/bin/sh
set -eu

WORKSPACE_DIR="$1"
REPO_NAME="$2"

CLAUDE_INSTALL_LOG="$WORKSPACE_DIR/logs/claude-install.log"

echo "Installing Claude Code for ${REPO_NAME}... (logging to $CLAUDE_INSTALL_LOG)"

if curl -fsSL https://claude.ai/install.sh | bash >"$CLAUDE_INSTALL_LOG" 2>&1; then
    {
        echo "✅ Claude Code installed successfully"
        CLAUDE_BIN="$(grep -oE '(/|~)/[^ ]*/claude$' "$CLAUDE_INSTALL_LOG" | head -n1)"
        CLAUDE_BIN="${CLAUDE_BIN/\~/$HOME}"
        sudo ln -sf "$(readlink -f "$CLAUDE_BIN")" /usr/local/bin/claude
        echo "🔗 Symlinked $CLAUDE_BIN → /usr/local/bin/claude"
    } 2>&1 | tee -a "$CLAUDE_INSTALL_LOG"
else
    echo "⚠️ Claude Code installation failed, but continuing..."
fi