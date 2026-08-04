package compliance.cm6_aws

import rego.v1

# Compliant: all four required tags present in tags_all.
compliant_input := {"planned_values": {"root_module": {"resources": [{
	"address": "aws_s3_bucket.primary",
	"type": "aws_s3_bucket",
	"values": {"tags_all": {
		"Project": "grc-challenge",
		"Environment": "dev",
		"ManagedBy": "terraform",
		"ComplianceScope": "grc-challenge",
	}},
}]}}}

# Non-compliant: only one tag present.
broken_input := {"planned_values": {"root_module": {"resources": [{
	"address": "aws_s3_bucket.primary",
	"type": "aws_s3_bucket",
	"values": {"tags_all": {"Project": "grc-challenge"}},
}]}}}

test_all_tags_present_passes if {
	count(deny) == 0 with input as compliant_input
}

test_missing_tags_denied if {
	count(deny) >= 1 with input as broken_input
}
