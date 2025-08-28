#!/bin/sh
# Source this script before running n8n: source source-n8n-env.sh

# Start logging from the beginning
exec > >(tee logs/start-n8n.log) 2>&1

# Source .env file if it exists
if [ -f .env ]; then
    set -a  # Export all variables
    . ./.env
    set +a
    echo "✅ .env configuration loaded"
else
    echo "❌ .env file not found"
    exit 1
fi

# Add secrets from Codespaces Secrets
if [ -n "$DB_PASSWORD" ]; then
    export DB_POSTGRESDB_PASSWORD="$DB_PASSWORD"
    echo "✅ DB_PASSWORD configured"
else
    echo "❌ DB_PASSWORD missing from Codespaces Secrets"
    exit 1
fi

if [ -n "$N8N_ENCRYPTION_KEY" ]; then
    export N8N_ENCRYPTION_KEY="$N8N_ENCRYPTION_KEY"
    echo "✅ N8N_ENCRYPTION_KEY configured"
else
    echo "❌ N8N_ENCRYPTION_KEY missing from Codespaces Secrets"
    exit 1
fi

echo "✅ n8n environment ready"
echo "Starting n8n..."

# Start n8n
n8n start