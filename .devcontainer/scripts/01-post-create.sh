#!/bin/sh
set -eu

# Define log paths early
SCRIPT_NAME="$(basename "$0" .sh)"
MAIN_LOG="${LOGS_DIR:-logs}/${SCRIPT_NAME}.log"

# Start logging from the beginning
exec > >(tee "$MAIN_LOG") 2>&1

echo "=== Post-Create Setup ==="

# Prefer GitHub-provided variable, fall back to current dir name
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    REPO_NAME="${GITHUB_REPOSITORY##*/}"
else
    REPO_NAME="$(basename "$(pwd)")"
fi

WORKSPACE_DIR="/workspaces/${REPO_NAME}"
SCRIPTS_DIR="$(dirname "$0")/${SCRIPT_NAME}.d"
LOG_DIR="${LOGS_DIR:-logs}/${SCRIPT_NAME}"

echo "Scripts will be logged individually to $LOG_DIR/[script-name].log"

# Stop logging before running sub-scripts (they handle their own logging)
exec > /dev/tty 2>&1

# Run each executable task script in order
if [ -d "$SCRIPTS_DIR" ]; then
    for script in "$SCRIPTS_DIR"/*; do
        [ -x "$script" ] || continue
        script_name="$(basename "$script")"
        echo "→ Running $script_name" | tee -a "$MAIN_LOG"
        
        # Conditionally log script output based on .nolog naming convention
        "$script" "$WORKSPACE_DIR" "$REPO_NAME" \
        2>&1 | case "$script_name" in
            *.nolog.*) cat ;;  # Scripts with .nolog - display only, no log file
            *) tee "$LOG_DIR/$script_name.log" ;;  # Regular scripts - display and save to log
        esac
    done
else
    echo "⚠️ No post-create scripts found in $SCRIPTS_DIR"
fi

echo "✅ Post-create setup complete for ${REPO_NAME}!"