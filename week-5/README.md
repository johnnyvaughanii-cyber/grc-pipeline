# Week 5 starter: Turn On the Cameras

This is the one week that touches billable AWS services. The starter gives you a `teardown.sh` so you can shut it all down the same day. The Terraform is yours to write.

## Read this first: cost

- **CloudTrail** management events are free. Do not enable data events.
- **Security Hub** bills roughly $0.001 per check. The NIST 800-53 standard is a few hundred checks, so under about $1 per month, and pennies if you tear down within the hour.
- **AWS Config** costs more and is often blocked by an org policy. It is optional this week. Skip it unless you want it.

If you apply and destroy the same day, expect well under $1. If you walk away and leave it running, it adds up slowly. **Tear it down.**

## What you build (your Terraform)

1. A multi-region **CloudTrail** with `enable_log_file_validation = true`, writing to a private, encrypted S3 bucket with a correct bucket policy (it needs the `aws:SourceArn` condition scoped to your trail). Maps to AU-2, AU-12, AU-10.
2. **Security Hub** enabled with the NIST 800-53 Rev 5 standard subscribed. Maps to RA-5, SI-4.

Then wait 10 to 20 minutes for findings to populate, and capture them.

## Capture evidence, then tear down

```bash
./teardown.sh
```

`teardown.sh` captures `evidence/security-hub-findings.json` first, then runs `terraform destroy`. Sign that findings file with your week 4 pipeline so it joins your chain of custody.

## Done when

- `aws cloudtrail get-trail-status` shows `IsLogging: true` while it is up.
- `aws securityhub get-findings` returns at least one finding.
- `evidence/security-hub-findings.json` is captured and non-empty.
- `terraform destroy` completes and nothing is left billing.

## On GCP?

The equivalent baseline is organization policy constraints plus Data Access audit logs, and Security Command Center in place of Security Hub. Same idea: native services that watch the project and report against a standard. Capture the findings, then tear it down.

## Common snags

- **CloudTrail bucket policy rejected.** The policy needs the `aws:SourceArn` condition naming your trail. Scope it tightly.
- **Security Hub already enabled.** Import it into state instead of applying: `terraform import aws_securityhub_account.this <ACCOUNT_ID>`.
- **Config access denied.** Your org blocks Config centrally. Leave it out. The Security Hub finding that says Config is not enabled is itself valid evidence of the gap.
