# METADATA
# title: AC-3 - Access Enforcement (AWS S3 public access block)
# description: Every aws_s3_bucket must have a public access block with all four flags true.
# custom:
#   control_id: AC-3
#   framework: nist-800-53
#   severity: critical
#   remediation: Add aws_s3_bucket_public_access_block referencing the bucket, all four flags true.
package compliance.ac3_aws

import rego.v1

# TODO (your build): deny any aws_s3_bucket that does not have a matching
# aws_s3_bucket_public_access_block with block_public_acls, block_public_policy,
# ignore_public_acls, and restrict_public_buckets all set to true.
#
# Match the bucket by reference the way sc28_encryption_aws.rego does, in
# input.configuration.root_module.resources[].expressions.bucket.references.
# Read the four flag values from input.planned_values.root_module.resources[]
# where .address is the public access block's address.
#
# The stub below keeps `deny` defined (empty) so the test file loads. Replace it.
deny contains msg if {
	some bucket in input.configuration.root_module.resources
	bucket.type == "aws_s3_bucket"
	not has_pab(bucket.name)
	msg := sprintf("AC-3: bucket %q has no public access block. Add an aws_s3_bucket_public_access_block resource referencing it with all four flags set to true.", [bucket.name])
}

deny contains msg if {
	some resource in input.planned_values.root_module.resources
	resource.type == "aws_s3_bucket_public_access_block"
	some flag in ["block_public_acls", "block_public_policy", "ignore_public_acls", "restrict_public_buckets"]
	resource.values[flag] != true
	msg := sprintf("AC-3: %s has %s set to false. All four public access flags must be true.", [resource.address, flag])
}

has_pab(bucket_name) if {
	some resource in input.configuration.root_module.resources
	resource.type == "aws_s3_bucket_public_access_block"
	sprintf("aws_s3_bucket.%s.id", [bucket_name]) in resource.expressions.bucket.references
}