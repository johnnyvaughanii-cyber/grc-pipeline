# METADATA
# title: SC-28 - Encryption at Rest (AWS S3)
# description: Every aws_s3_bucket must have a matching server-side encryption configuration.
# custom:
#   control_id: SC-28
#   framework: nist-800-53
#   severity: high
#   remediation: Add aws_s3_bucket_server_side_encryption_configuration referencing the bucket.
package compliance.sc28_aws

import rego.v1

# YOUR BUILD: deny any aws_s3_bucket that has no matching
# aws_s3_bucket_server_side_encryption_configuration.
#
# Technique: at plan time the bucket name is unknown, so match by reference, not
# value. Bucket addresses live in input.configuration.root_module.resources[]
# (type == "aws_s3_bucket"). The encryption resource references its bucket in
# .expressions.bucket.references (strings like "aws_s3_bucket.primary.id").
#
# Make the two tests in sc28_encryption_aws_test.rego pass. The stub below keeps
# `deny` defined so the tests load. Replace it.
deny contains msg if {
	some bucket in input.configuration.root_module.resources
	bucket.type == "aws_s3_bucket"
	not has_encryption(bucket.name)
	msg := sprintf("SC-28: bucket %q has no server-side encryption configuration. Add an aws_s3_bucket_server_side_encryption_configuration resource referencing it.", [bucket.name])
}
approved_algorithms := {"AES256", "aws:kms"}

deny contains msg if {
	some resource in input.planned_values.root_module.resources
	resource.type == "aws_s3_bucket_server_side_encryption_configuration"
	some rule in resource.values.rule
	some setting in rule.apply_server_side_encryption_by_default
	not setting.sse_algorithm in approved_algorithms
	msg := sprintf("SC-28: %s specifies encryption algorithm %q, which is not an approved algorithm. Use AES256 or aws:kms.", [resource.address, setting.sse_algorithm])
}
has_encryption(bucket_name) if {
	some resource in input.configuration.root_module.resources
	resource.type == "aws_s3_bucket_server_side_encryption_configuration"
	sprintf("aws_s3_bucket.%s", [bucket_name]) in resource.expressions.bucket.references
}