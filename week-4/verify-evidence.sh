#!/usr/bin/env bash
# verify-evidence.sh <bundle.tar.gz>
# Proves an evidence bundle is intact and authentic.
set -euo pipefail
BUNDLE="${1:?usage: verify-evidence.sh <bundle.tar.gz>}"

# 1. INTEGRITY
echo "Checking integrity..."
sha256sum -c "${BUNDLE}.sha256"

# 2. AUTHENTICITY
echo "Checking authenticity..."
cosign verify-blob \
  --bundle "${BUNDLE}.sig.bundle" \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  --certificate-identity-regexp '^https://github\.com/johnnyvaughanii-cyber/grc-pipeline/\.github/workflows/grc-gate\.yml@.*' \
  "${BUNDLE}"

echo "CHAIN INTACT"
