#!/bin/sh
set -eu

# If GITHUB_REPOSITORY is set (e.g., "owner/repo"), use the repo name
if [ -n "${GITHUB_REPOSITORY:-}" ]; then
    REPO_NAME="${GITHUB_REPOSITORY##*/}"
    PROJECT_DIR="/workspaces/${REPO_NAME}"
else
    # Fallback: infer from current working directory
    PROJECT_DIR="$(pwd)"
    REPO_NAME="$(basename "$PROJECT_DIR")"
fi

SCRIPTS_DIR="${PROJECT_DIR}/.devcontainer/scripts"

echo "Setting up development environment for ${REPO_NAME}..."

cd "$PROJECT_DIR"

echo "Preparing corepack and installing dependencies for n8n..."
corepack prepare --activate
pnpm install

echo "Installing required system packages..."
sudo apk add --no-cache ripgrep

echo "✅ Development environment setup complete for ${REPO_NAME}!"