#!/bin/sh

# Fix n8n_data directory permissions
# Docker volumes are created as root, but n8n runs as node user

N8N_DATA_DIR="/workspaces/n8n_data"

if [ -d "$N8N_DATA_DIR" ]; then
    echo "Fixing n8n_data directory permissions..."
    sudo chown -R node:node "$N8N_DATA_DIR"
    echo "✅ Permissions fixed"
else
    echo "⚠️ n8n_data directory not found"
fi