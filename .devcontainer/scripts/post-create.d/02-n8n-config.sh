#!/bin/sh
# Non-secret n8n configuration

# Database Configuration (non-secret)
export DB_NAME=n8n_prod_db
export DB_USER=n8n_service_user
export DB_TYPE=postgresdb
export DB_POSTGRESDB_HOST=localhost
export DB_POSTGRESDB_PORT=5432
export DB_POSTGRESDB_DATABASE="$DB_NAME"
export DB_POSTGRESDB_USER="$DB_USER"
export DB_POSTGRESDB_PASSWORD="$DB_PASSWORD"  # From Codespaces Secret
export DB_POSTGRESDB_SSL_MODE=disable

# n8n Configuration
export N8N_PORT=5678
export N8N_PROTOCOL=https
export N8N_SECURE_COOKIE=true
export N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Auto-configure Codespace URLs if available
if [ -n "$CODESPACE_NAME" ]; then
    export N8N_HOST="$CODESPACE_NAME-5678.app.github.dev"
    export WEBHOOK_URL="https://$CODESPACE_NAME-5678.app.github.dev"
else
    echo "WARNING: CODESPACE_NAME not set. Set N8N_HOST and WEBHOOK_URL manually."
fi

echo "✅ n8n configuration loaded"