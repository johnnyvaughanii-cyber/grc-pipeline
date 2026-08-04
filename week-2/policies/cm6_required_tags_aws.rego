# METADATA
# title: CM-6 - Configuration Settings (AWS required tags)
# description: Taggable resources must carry the four required compliance tags.
# custom:
#   control_id: CM-6
#   framework: nist-800-53
#   severity: medium
#   remediation: Add the missing tags or rely on provider default_tags.
package compliance.cm6_aws

import rego.v1

required_tags := ["Project", "Environment", "ManagedBy", "ComplianceScope"]

deny contains msg if {
	some resource in input.planned_values.root_module.resources
	resource.values.tags_all
	some tag in required_tags
	not resource.values.tags_all[tag]
	msg := sprintf("CM-6: %s is missing required tag %q. Add it to the provider default_tags block.", [resource.address, tag])
}
