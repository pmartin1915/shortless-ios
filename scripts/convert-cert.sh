#!/bin/bash
# Converts Apple Distribution certificate (.cer) to .p12 for GitHub Actions
#
# Usage:
#   bash scripts/convert-cert.sh path/to/distribution.cer
#
# Prerequisites:
#   - distribution.key must exist at C:/tmp/apple-signing/distribution.key
#     (generated during CSR creation)
#
# Output:
#   - C:/tmp/apple-signing/distribution.p12
#   - Prints base64 string to paste into GitHub Secrets

set -e

CER_FILE="$1"
KEY_FILE="C:/tmp/apple-signing/distribution.key"
P12_FILE="C:/tmp/apple-signing/distribution.p12"

if [ -z "$CER_FILE" ]; then
  echo "Usage: bash scripts/convert-cert.sh path/to/distribution.cer"
  exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
  echo "Error: Private key not found at $KEY_FILE"
  echo "This was generated during CSR creation. If lost, generate a new CSR."
  exit 1
fi

echo "Enter a password for the .p12 file (remember this for GitHub Secrets):"
read -s P12_PASSWORD
echo ""

# Convert DER-encoded .cer to PEM
openssl x509 -inform DER -in "$CER_FILE" -out "$CER_FILE.pem" 2>/dev/null || \
  cp "$CER_FILE" "$CER_FILE.pem"  # Already PEM format

# Combine certificate + private key into .p12
MSYS_NO_PATHCONV=1 openssl pkcs12 -export \
  -inkey "$KEY_FILE" \
  -in "$CER_FILE.pem" \
  -out "$P12_FILE" \
  -passout "pass:$P12_PASSWORD"

echo ""
echo "=== SUCCESS ==="
echo "P12 file: $P12_FILE"
echo ""
echo "=== GITHUB SECRETS ==="
echo ""
echo "1. APPLE_CERTIFICATE_PASSWORD:"
echo "   $P12_PASSWORD"
echo ""
echo "2. APPLE_CERTIFICATE_P12 (base64):"
echo "   Copy everything between the dashes:"
echo "---"
base64 -w 0 "$P12_FILE" 2>/dev/null || base64 -i "$P12_FILE"  # Linux vs macOS
echo ""
echo "---"

# Clean up temp PEM
rm -f "$CER_FILE.pem"
