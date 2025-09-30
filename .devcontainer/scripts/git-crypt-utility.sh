#!/bin/sh

# Git-crypt management utility
# Usage: git-crypt-utility.sh <command> [options]

set -e

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(dirname "$0")"
KEYS_DIR="${TMPDIR:-/tmp}/git-crypt-keys"

show_usage() {
    if [ -f "$SCRIPT_DIR/$SCRIPT_NAME.help" ]; then
        cat "$SCRIPT_DIR/$SCRIPT_NAME.help"
    else
        echo "Usage: $SCRIPT_NAME <command> [options]"
        echo "Commands: export-key, import-key, unlock, status, help"
    fi
}

check_git_crypt() {
    if ! command -v git-crypt >/dev/null 2>&1; then
        echo "Error: git-crypt not found. Please install git-crypt first."
        exit 1
    fi

    if [ ! -d .git ]; then
        echo "Error: Not in a git repository"
        exit 1
    fi
}

export_key() {
    local key_file="${1:-git-crypt-key.bin}"

    echo "Exporting git-crypt key..."

    # Create keys directory
    mkdir -p "$KEYS_DIR"
    local full_path="$KEYS_DIR/$key_file"

    # Export the key
    git-crypt export-key "$full_path"

    # Mark key as backed up in .env
    sed -i 's/GIT_CRYPT_KEY_BACKED_UP=.*/GIT_CRYPT_KEY_BACKED_UP=true/' .env

    echo "✅ Key exported successfully!"
    echo "🔕 Key backup reminders disabled"
    echo "📁 Location: $full_path"
    echo "📏 Size: $(du -h "$full_path" | cut -f1)"
    echo ""
    echo "⚠️  IMPORTANT:"
    echo "   • This key can decrypt ALL encrypted files in this repository"
    echo "   • Store it securely (password manager, encrypted drive)"
    echo "   • Do NOT commit this key to any git repository"
    echo "   • Share only via secure channels"
    echo ""
    echo "🔗 To use this key on another machine:"
    echo "   $SCRIPT_NAME import-key $key_file"
}

import_key() {
    local key_file="$1"

    if [ -z "$key_file" ]; then
        echo "Error: Key file required"
        echo "Usage: $SCRIPT_NAME import-key <filename>"
        exit 1
    fi

    # Check if file exists in keys directory or as absolute path
    if [ -f "$KEYS_DIR/$key_file" ]; then
        key_file="$KEYS_DIR/$key_file"
    elif [ ! -f "$key_file" ]; then
        echo "Error: Key file '$key_file' not found"
        echo "Checked: $key_file and $KEYS_DIR/$key_file"
        exit 1
    fi

    echo "Importing git-crypt key from: $key_file"

    # Unlock repository with the key
    git-crypt unlock "$key_file"

    echo "✅ Repository unlocked successfully!"
    echo "🔓 Encrypted files are now accessible"
}

unlock_repo() {
    echo "Unlocking git-crypt repository..."

    # Try to unlock (assumes key is already available)
    if git-crypt unlock 2>/dev/null; then
        echo "✅ Repository unlocked successfully!"
    else
        echo "❌ Failed to unlock repository"
        echo ""
        echo "Possible solutions:"
        echo "1. Import a key: $SCRIPT_NAME import-key <keyfile>"
        echo "2. Add your GPG key (if configured): git-crypt add-gpg-user <email>"
        echo "3. Get key from team member who has access"
        exit 1
    fi
}

show_status() {
    echo "Git-crypt Repository Status:"
    echo "=========================="

    # Check if git-crypt is initialized
    if [ -d .git/git-crypt ]; then
        echo "🔧 Git-crypt: Initialized"

        # Check if repository is unlocked
        if git-crypt status >/dev/null 2>&1; then
            echo "🔓 Status: Unlocked"
            echo ""
            echo "Encrypted files in repository:"
            git-crypt status
        else
            echo "🔒 Status: Locked"
            echo ""
            echo "To unlock:"
            echo "• Import key: $SCRIPT_NAME import-key <keyfile>"
            echo "• Export key: $SCRIPT_NAME export-key [filename]"
        fi
    else
        echo "❌ Git-crypt: Not initialized"
        echo ""
        echo "To initialize: git-crypt init"
    fi
}


# Main script logic
case "${1:-help}" in
    export-key)
        check_git_crypt
        export_key "$2"
        ;;
    import-key)
        check_git_crypt
        import_key "$2"
        ;;
    unlock)
        check_git_crypt
        unlock_repo
        ;;
    status)
        check_git_crypt
        show_status
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_usage
        exit 1
        ;;
esac