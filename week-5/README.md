# Week 5: Native Cloud Controls

Terraform that stands up an account-level audit trail, captures what it produces as evidence, and tears the whole thing down the same day.

Applied and destroyed on 2026-08-12. Nothing from this week is still running.

## Controls

| Control | Requirement | Implementation |
|---|---|---|
| AU-2 | Event logging | A CloudTrail trail recording management events across the account |
| AU-12 | Audit record generation | `is_multi_region_trail = true`, so records are generated in every region rather than one |
| AU-10 | Non-repudiation | `enable_log_file_validation = true`, which produces signed hourly digest files covering the delivered logs |
| RA-5 | Vulnerability and configuration scanning | Not implemented. See below |
| SI-4 | System monitoring | Not implemented. See below |

## Why log file validation is the control

A log that can be edited after the fact is a record of what someone was willing to leave behind.

With validation enabled, CloudTrail writes a digest file every hour listing the delivered log files and their hashes, signed with a private key AWS holds. `aws cloudtrail validate-logs` checks the digest chain and reports any log file that was modified or deleted after delivery. The account owner cannot alter a log and have it still validate.

This is the same property built by hand in Week 4 with Cosign, applied to the account's own audit trail: the proof of integrity lives outside the control of the party being audited.

## Validation exercised, not just enabled

Digest files were delivered to 17 regions within 20 minutes of the trail starting. `aws cloudtrail validate-logs` returned `1/1 digest files valid` against the delivered logs.

`evidence/validate-logs.txt` holds the result. `evidence/digest-inventory.txt` lists the digests across all 17 regions, which is the AU-12 evidence: records are being generated account-wide rather than in the trail's home region only.

Configuration proves the control was turned on. Validation proves it works. The two are not the same claim, and the second is the one an assessor can act on.

## Multi-region is not a detail

A single-region trail records activity in one region. Creating resources in an unmonitored region is a standard evasion, and it defeats a single-region trail completely. `is_multi_region_trail = true` is what makes AU-12 an account-wide assertion rather than a regional one.

## Data events are deliberately off

CloudTrail management events are free. Data events — object-level S3 reads and writes, Lambda invocations — bill per event and can accumulate quickly. This build records management events only.

Not a cost-cutting compromise. Scope is a control decision: recording everything is not the same as recording the right things, and an audit trail nobody can afford to keep is not an audit trail.

## The bucket policy

CloudTrail writes to the log bucket as a service principal, so the bucket policy has to permit it. Two statements: one allowing `s3:GetBucketAcl` so the service can confirm it may write, one allowing `s3:PutObject` scoped to the account's log prefix.

Both statements carry an `aws:SourceArn` condition pinned to this trail's ARN. Without it the policy grants write access to the CloudTrail service generally, which means a trail in any AWS account could target this bucket. AWS now requires the condition rather than recommending it.

The trail ARN is constructed in `locals` from the account ID and the trail name rather than read from the trail resource. Referencing the resource directly would create a cycle: the policy needs the trail's ARN, and the trail will not create until the policy exists.

## RA-5 and SI-4 were not implemented

Security Hub could not be enabled on this account. Both Terraform and the AWS CLI return the same error:

```
SubscriptionRequiredException: The AWS Access Key Id needs a subscription for the service
```

`describe-hub` returns it as well, so the account cannot subscribe rather than the request being malformed. This is an account registration or billing state issue, not an IAM permission and not a Terraform defect. The resources are left in `main.tf`, commented, so the gap is visible in the code rather than silently absent.

The gap is recorded rather than worked around. Two controls in the intended scope are unimplemented, and the account's configuration posture is therefore unassessed. A control mapping that omitted RA-5 and SI-4 without comment would read as a smaller scope rather than an open finding, and the difference between those two is the entire value of the mapping.

## Verify

```
aws cloudtrail get-trail-status --name grc-challenge-trail --region us-east-1
aws cloudtrail describe-trails --trail-name-list grc-challenge-trail --region us-east-1
```

`evidence/cloudtrail-status.json` shows `IsLogging: true` with a successful delivery timestamp. `evidence/cloudtrail-config.json` shows `LogFileValidationEnabled: true`, `IsMultiRegionTrail: true`, and no data event selectors.

Raw CloudTrail log files are not committed. They contain source IP addresses and IAM principal identities, and this repository is public. The status and configuration files carry no request data.

## Teardown

`teardown.sh` captures evidence and then runs `terraform destroy`. The log bucket carries `force_destroy = true` so destroy succeeds against a bucket holding delivered log files.

Correct for a resource that exists for one afternoon, wrong for anything intended to persist: `force_destroy` removes the protection that stops a versioned bucket being deleted with its contents. The setting is defensible here because the bucket's lifetime is measured in hours and is stated as such.
