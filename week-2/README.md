# Week 2: Executable Controls

Three Rego policies that read a Terraform plan and return a verdict on each control. Compliance expressed as code that runs, not prose that someone has to interpret.

## Controls enforced

| Control | Rule | Namespace |
|---|---|---|
| SC-28 | Deny any S3 bucket with no matching server-side encryption configuration | `compliance.sc28_aws` |
| AC-3 | Deny any S3 bucket with no public access block, or a block with any of its four flags not set to `true` | `compliance.ac3_aws` |
| CM-6 | Deny any taggable resource missing one of the four required tags | `compliance.cm6_aws` |

Each policy has two unit tests: a compliant fixture that must produce zero denials, and a violating fixture that must produce at least one. All six pass.

```
opa test policies/
PASS: 6/6
```

## Match by reference, not by value

The non-obvious technique in this build. At plan time a bucket's name is unknown, because the `random_id` suffix has not been generated — the plan JSON shows `(known after apply)`. So a policy cannot match an encryption configuration to its bucket by comparing names.

It matches by reference instead. The plan's `configuration` section records that the encryption resource's `bucket` argument references `aws_s3_bucket.primary.id`. The policy constructs that address from the bucket's declared name and checks whether it appears in the referencing resource's `references` list. Declared relationships are known at plan time even when concrete values are not.

This is why the SC-28 and AC-3 policies read `configuration.root_module.resources` while CM-6 reads `planned_values.root_module.resources`. Tags are literal values available at plan time; resource relationships are not.

## A defect found on first contact with real data

The three policies passed all six unit tests, then flagged 36 CM-6 violations against the actual Week 1 plan. Every one was a false positive.

The rule checked every resource in the plan for the four required tags. But most resources in the plan are not taggable — `aws_s3_bucket_versioning`, `aws_s3_bucket_public_access_block`, `aws_s3_bucket_acl`, and `random_id` have no tag attribute at all. The two resources that are taggable, both S3 buckets, passed. The infrastructure was correct; the control's scope was wrong.

The fix was one line asserting that a `tags_all` attribute exists before evaluating its contents. Terraform emits that attribute only on resources that support tagging, so it functions as the taggability filter the control implies.

Worth stating plainly: a control that fires on resources outside its scope is not a strict control, it is a broken one. Thirty-six findings requiring individual disposition, none of them real, is how automated compliance loses the trust of the engineers subject to it. The unit tests could not catch this because the fixtures contained only taggable resources. Real plan data did.

## Verify

Unit tests:

```
opa test policies/ -v
```

Against a real Terraform plan:

```
opa eval --format pretty --data policies/ --input ../week-1/evidence/plan.json "data.compliance.sc28_aws.deny"
```

Returns an empty list against the compliant Week 1 plan. Regenerating that plan with the encryption resources removed returns two findings, one per bucket, each naming the resource and the remediation.
