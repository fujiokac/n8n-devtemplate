#!/bin/sh

# Setup script for new Codespace instances

echo "Setting up n8n development environment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    cp .env.template .env
    
    # Generate strong password
    if command -v openssl >/dev/null 2>&1; then
        PASSWORD=$(openssl rand -base64 32)
    else
        PASSWORD=$(python3 -c "import secrets, base64; print(base64.b64encode(secrets.token_bytes(24)).decode())")
    fi
    
    # Get Codespace URL if available
    if [ -n "$CODESPACE_NAME" ]; then
        CODESPACE_URL="https://$CODESPACE_NAME-5678.app.github.dev"
        sed -i "s|<YOUR_CODESPACE_URL>|$CODESPACE_URL|g" .env
        echo "Codespace URL configured: $CODESPACE_URL"
    else
        echo "WARNING: Update N8N_HOST and WEBHOOK_URL in .env manually"
    fi
    
    # Replace workspace folder placeholder with actual workspace name
    WORKSPACE_NAME="$(basename "$(pwd)")"
    sed -i "s|n8n-devtemplate|$WORKSPACE_NAME|g" .env
    
    # Replace password placeholder
    sed -i "s|<GENERATE_STRONG_PASSWORD>|$PASSWORD|g" .env
    
    echo "✅ .env file created with secure credentials"
else
    echo "✅ .env file already exists"
fi

echo "🚀 Ready to run: n8n start"