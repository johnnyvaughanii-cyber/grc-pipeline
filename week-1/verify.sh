#!/usr/bin/env bash
# Week 1 verification. Run after `terraform apply`.
# Confirms SC-28 (encryption), CM-6 (versioning), AC-3 (public access block).
set -euo pipefail

BUCKET=$(terraform output -raw bucket_name)
echo "Verifying bucket: $BUCKET"
echo

echo "SC-28 encryption at rest:"
aws s3api get-bucket-encryption --bucket "$BUCKET"
echo

echo "CM-6 versioning:"
aws s3api get-bucket-versioning --bucket "$BUCKET"
echo

echo "AC-3 public access block (all four must be true):"
aws s3api get-public-access-block --bucket "$BUCKET"
echo

echo "If encryption shows AES256, versioning shows Enabled, and all four"
echo "public-access flags are true, the bucket is compliant."
