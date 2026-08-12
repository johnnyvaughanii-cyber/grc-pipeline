#!/usr/bin/env bash
# teardown.sh - capture evidence, then destroy everything from this week.
# This is the most important script of the week. Run it the same day you apply.
# Cost only stays in pennies if you tear down promptly.
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"

echo "1) Capturing Security Hub findings as evidence before destroying..."
mkdir -p evidence
aws securityhub get-findings --region "$REGION" --max-results 50 \
  > evidence/security-hub-findings.json || echo "  (no findings yet, or Security Hub not enabled)"

echo "2) Destroying the baseline (CloudTrail, S3 log bucket, Security Hub subscriptions)..."
terraform destroy -auto-approve

echo
echo "Done. Verify nothing bills:"
echo "  - Security Hub standards detached: aws securityhub get-enabled-standards --region $REGION"
echo "  - CloudTrail gone:                 aws cloudtrail describe-trails --region $REGION"
echo
echo "If you chose to KEEP Security Hub enabled, the high-cost item is the"
echo "subscribed standards. Unsubscribe them to stop the per-check billing."
