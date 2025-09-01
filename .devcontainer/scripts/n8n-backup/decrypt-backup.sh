#!/bin/sh

# Decrypt a file using OpenSSL with AES-256-CBC
# Usage: decrypt-backup.sh <encrypted_file> <output_file>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <encrypted_file> <output_file>"
    exit 1
fi

ENCRYPTED_FILE="$1"
OUTPUT_FILE="$2"

# Check if backup key is available
if [ -z "$N8N_BACKUP_KEY" ]; then
    echo "Error: N8N_BACKUP_KEY environment variable not set"
    echo "This should be configured as a GitHub Codespace secret"
    exit 1
fi

# Verify encrypted file exists
if [ ! -f "$ENCRYPTED_FILE" ]; then
    echo "Error: Encrypted file '$ENCRYPTED_FILE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# Decrypt the file
echo "Decrypting $ENCRYPTED_FILE..."
openssl enc -aes-256-cbc -d -salt -in "$ENCRYPTED_FILE" -out "$OUTPUT_FILE" -pass env:N8N_BACKUP_KEY

echo "File decrypted successfully: $OUTPUT_FILE"