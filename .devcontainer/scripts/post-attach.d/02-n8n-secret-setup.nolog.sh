#!/bin/sh

# Interactive n8n secret setup

echo "=== n8n Secret Setup ==="

# Check if secrets are missing
missing_secrets=""
if [ -z "$DB_PASSWORD" ]; then
    missing_secrets="$missing_secrets DB_PASSWORD"
fi
if [ -z "$N8N_ENCRYPTION_KEY" ]; then
    missing_secrets="$missing_secrets N8N_ENCRYPTION_KEY"
fi

if [ -z "$missing_secrets" ]; then
    echo "✅ All required secrets configured"
    exit 0
fi

echo ""
echo "🔑 Missing Codespaces Secrets detected:$missing_secrets"
echo ""

# Function to generate strong secret
generate_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32
    else
        python3 -c "import secrets, base64; print(base64.b64encode(secrets.token_bytes(24)).decode())"
    fi
}

echo "Setting up secrets in GitHub:"
echo "1. Go to your repository → Settings → Security → Secrets and variables → Codespaces"
echo "2. Click 'New repository secret' for each missing secret below"
echo ""

for secret in $missing_secrets; do
    echo "━━━ $secret ━━━"
    generated_secret=$(generate_secret)
    echo "┌─ Name ──────────────────────────────────────────┐"
    echo "│ $secret"
    echo "├─ Value ─────────────────────────────────────────┤"
    echo "│ $generated_secret"
    echo "└─────────────────────────────────────────────────┘"
    echo ""
done

echo "🔄 After adding secrets, apply them using one of these methods:"
echo ""
echo "1. **Rebuild container** - Cmd/Ctrl+Shift+P → \"Codespaces: Rebuild Container\" (faster)"
echo "2. **Reload window** - Look for GitHub notification and click \"Reload to apply\""
echo "3. **Stop and restart Codespace** - Full restart from GitHub (slower)"
echo ""
echo "Then run: n8n start"