package compliance.sc28_aws

import rego.v1

# A compliant plan: bucket plus an encryption configuration that references it.
compliant_input := {"configuration": {"root_module": {"resources": [
	{"type": "aws_s3_bucket", "name": "primary", "expressions": {}},
	{
		"type": "aws_s3_bucket_server_side_encryption_configuration",
		"name": "primary",
		"expressions": {"bucket": {"references": ["aws_s3_bucket.primary.id", "aws_s3_bucket.primary"]}},
	},
]}}}

# A non-compliant plan: bucket with no encryption configuration.
broken_input := {"configuration": {"root_module": {"resources": [
	{"type": "aws_s3_bucket", "name": "primary", "expressions": {}},
]}}}

test_compliant_bucket_passes if {
	count(deny) == 0 with input as compliant_input
}

test_unencrypted_bucket_denied if {
	count(deny) == 1 with input as broken_input
}
