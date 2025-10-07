#!/bin/sh

# Encrypt a file using OpenSSL with AES-256-CBC
# NOTE: This script is preserved for flexibility but not used by default
# Current backup system uses git-crypt for automatic encryption
# Usage: encrypt-backup.sh <input_file> <output_file>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if backup key is available
if [ -z "$N8N_BACKUP_KEY" ]; then
    echo "❌ ERROR: N8N_BACKUP_KEY environment variable not set"
    echo "This should be configured as a GitHub Codespace secret"
    exit 1
fi

# Verify input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ ERROR: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
mkdir -p "$OUTPUT_DIR"

# Encrypt the file
echo "Encrypting $INPUT_FILE..."
openssl enc -aes-256-cbc -salt -pbkdf2 -in "$INPUT_FILE" -out "$OUTPUT_FILE" -pass env:N8N_BACKUP_KEY

echo "File encrypted successfully: $OUTPUT_FILE"