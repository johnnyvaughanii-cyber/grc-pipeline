package compliance.ac3_aws

import rego.v1

# Compliant: bucket plus a public access block with all four flags true.
compliant_input := {
	"configuration": {"root_module": {"resources": [
		{"type": "aws_s3_bucket", "name": "primary", "expressions": {}},
		{
			"type": "aws_s3_bucket_public_access_block",
			"name": "primary",
			"expressions": {"bucket": {"references": ["aws_s3_bucket.primary.id"]}},
		},
	]}},
	"planned_values": {"root_module": {"resources": [{
		"address": "aws_s3_bucket_public_access_block.primary",
		"type": "aws_s3_bucket_public_access_block",
		"values": {
			"block_public_acls": true,
			"block_public_policy": true,
			"ignore_public_acls": true,
			"restrict_public_buckets": true,
		},
	}]}},
}

# Non-compliant: a bucket with no public access block at all.
broken_input := {
	"configuration": {"root_module": {"resources": [
		{"type": "aws_s3_bucket", "name": "primary", "expressions": {}},
	]}},
	"planned_values": {"root_module": {"resources": []}},
}

test_complete_pab_passes if {
	count(deny) == 0 with input as compliant_input
}

test_missing_pab_denied if {
	count(deny) == 1 with input as broken_input
}
