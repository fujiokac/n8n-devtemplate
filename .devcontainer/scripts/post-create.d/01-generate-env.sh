#!/bin/sh

# Setup script for new Codespace instances

echo "Setting up n8n development environment..."

# Create data directory
mkdir -p n8n_data
echo "✅ n8n data directory created"

# Create .env from template with non-secret configs
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    cp .env.template .env
    
    # Get Codespace URL if available
    if [ -n "$CODESPACE_NAME" ]; then
        CODESPACE_URL="https://$CODESPACE_NAME-5678.app.github.dev"
        sed -i "s|<YOUR_CODESPACE_URL>|$CODESPACE_URL|g" .env
        echo "✅ Codespace URL configured: $CODESPACE_URL"
    else
        echo "ℹ️  CODESPACE_NAME not set - update N8N_HOST and WEBHOOK_URL in .env manually"
    fi
    
    # Replace workspace folder placeholder with actual workspace name
    WORKSPACE_NAME="$(basename "$(pwd)")"
    sed -i "s|n8n-devtemplate|$WORKSPACE_NAME|g" .env
    
    echo "✅ .env file created with non-secret configuration"
else
    echo "✅ .env file already exists"
fi

# Log secret status (non-interactive)
if [ -z "$DB_PASSWORD" ]; then
    echo "ℹ️  DB_PASSWORD secret not configured"
fi

if [ -z "$N8N_ENCRYPTION_KEY" ]; then
    echo "ℹ️  N8N_ENCRYPTION_KEY secret not configured"
fi

if [ -n "$DB_PASSWORD" ] && [ -n "$N8N_ENCRYPTION_KEY" ]; then
    echo "✅ Required secrets configured"
else
    echo "ℹ️  Some secrets missing - will be prompted to set up on first attach"
fi

echo "✅ n8n environment setup complete"