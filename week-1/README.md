# Week 1: Compliant S3 Bucket

Terraform that provisions an S3 bucket satisfying five NIST 800-53 controls and emits machine-readable proof of each one.

## Controls enforced

| Control | Requirement | Implementation |
|---|---|---|
| SC-28 | Protection of information at rest | `aws_s3_bucket_server_side_encryption_configuration` on both buckets, AES-256 server-side encryption applied by default |
| AC-3 | Access enforcement | `aws_s3_bucket_public_access_block` on both buckets, all four flags set to `true` |
| CM-6 (a) | Configuration settings | `aws_s3_bucket_versioning` enabled on the primary bucket, so prior object states remain recoverable |
| CM-6 (b) | Configuration settings | Four required tags (`Project`, `Environment`, `ManagedBy`, `ComplianceScope`) applied via the provider `default_tags` block |
| AU-3 / AU-6 | Audit record content and review | `aws_s3_bucket_logging` on the primary bucket writing to a dedicated log bucket, with ownership controls and a `log-delivery-write` ACL sequenced ahead of it |

## Architecture

Two buckets. The primary bucket holds data. A separate log bucket receives its access logs. Both carry the same encryption and public-access baseline; only the primary is versioned and logged.

Logs are segregated deliberately. Writing access logs into the bucket being logged would generate recursive entries, and anyone able to modify data in the primary bucket could then edit the record of having done so.

## Evidence

`evidence/plan.json` is the output of `terraform show -json`, containing all five controls as structured data. No screenshots.

The `sc28_encryption_algorithm` output surfaces the encryption algorithm in effect as a named top-level value, read from the live resource configuration rather than hardcoded, so the attestation cannot drift from what it attests to.

## Verify