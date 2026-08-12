#!/usr/bin/env bash
# verify-evidence.sh <bundle.tar.gz>
# Proves an evidence bundle is intact and authentic. This is a skeleton.
# Fill in the three checks. Each one should exit non-zero on failure.
set -euo pipefail

BUNDLE="${1:?usage: verify-evidence.sh <bundle.tar.gz>}"

# 1. INTEGRITY (your build)
#    Recompute the SHA-256 of the bundle and compare it to the .sha256 sidecar
#    that was written when the bundle was created. Mismatch means tampering.
#    macOS: shasum -a 256   Linux: sha256sum

# 2. AUTHENTICITY (your build)
#    Run `cosign verify-blob` against the bundle using the .sig.bundle file.
#    Pin the OIDC issuer to GitHub Actions if you signed in CI:
#    --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'

# 3. PRESERVATION (stretch)
#    If you uploaded to an S3 Object Lock vault, check the object's retention
#    date is still in the future with `aws s3api get-object-retention`.

echo "TODO: implement the three checks above, then print CHAIN INTACT"
