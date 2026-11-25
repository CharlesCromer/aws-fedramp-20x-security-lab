package terraform.aws.ec2

import rego.v1

# ============================================================
# Cross-Framework Continuous Security Assurance Project
# Phase 3.1 - EC2 Security Validation Baseline
#
# Input: Terraform plan JSON
# Output: Structured policy evaluation results
#
# Policy identifiers are framework-independent and will
# support subsequent cross-framework control mapping.
# ============================================================

# ------------------------------------------------------------
# Security and governance requirements
# ------------------------------------------------------------

checks := [
	{
		"id": "EC2-001",
		"attribute": "associate_public_ip_address",
		"path": ["associate_public_ip_address"],
		"expected": false,
		"category": "network_security",
		"description": "EC2 public IPv4 assignment must be disabled.",
	},
	{
		"id": "EC2-002",
		"attribute": "metadata_options.http_tokens",
		"path": ["metadata_options", 0, "http_tokens"],
		"expected": "required",
		"category": "metadata_security",
		"description": "EC2 instances must enforce IMDSv2.",
	},
	{
		"id": "EC2-003",
		"attribute": "root_block_device.encrypted",
		"path": ["root_block_device", 0, "encrypted"],
		"expected": true,
		"category": "data_protection",
		"description": "Root EBS volumes must be encrypted.",
	},
	{
		"id": "EC2-004",
		"attribute": "root_block_device.delete_on_termination",
		"path": ["root_block_device", 0, "delete_on_termination"],
		"expected": true,
		"category": "resource_lifecycle",
		"description": "Root EBS volumes must be deleted on termination.",
	},
	{
		"id": "EC2-005",
		"attribute": "credit_specification.cpu_credits",
		"path": ["credit_specification", 0, "cpu_credits"],
		"expected": "standard",
		"category": "cost_governance",
		"description": "T3 and T3a instances must use standard CPU credits.",
	},
]

# ------------------------------------------------------------
# Basic Terraform plan input validation
# ------------------------------------------------------------

valid_plan if {
	is_object(input)
	is_string(input.format_version)
	startswith(input.format_version, "1.")
	is_array(input.resource_changes)

	object.get(input, "errored", false) == false
	object.get(input, "complete", true) == true

	every resource in input.resource_changes {
		is_string(resource.address)
		is_string(resource.mode)
		is_string(resource.type)
		is_array(resource.change.actions)
		count(resource.change.actions) > 0
	}
}

# ------------------------------------------------------------
# Identify applicable managed EC2 resources
# ------------------------------------------------------------

eligible(resource) if {
	resource.mode == "managed"
	resource.type == "aws_instance"

	some action in resource.change.actions
	action in {"create", "update", "no-op"}
}

# ------------------------------------------------------------
# Safely retrieve proposed configuration values
# ------------------------------------------------------------

actual_value(resource, path) := value if {
	is_object(resource.change.after)
	value := object.get(resource.change.after, path, null)
} else := null

# ------------------------------------------------------------
# Identify unknown values, including unknown parent attributes
# ------------------------------------------------------------

unknown_at(resource, _) if {
	resource.change.after_unknown == true
}

unknown_at(resource, path) if {
	unknown := object.get(resource.change, "after_unknown", {})
	is_object(unknown)

	some index, _ in path
	prefix := array.slice(path, 0, index + 1)

	object.get(unknown, prefix, false) == true
}

# ------------------------------------------------------------
# Determine instance type and CPU credit applicability
# ------------------------------------------------------------

known_instance_type(resource) if {
	instance_type := actual_value(resource, ["instance_type"])
	is_string(instance_type)
	instance_type != ""
	not unknown_at(resource, ["instance_type"])
}

applicable(_, check) if {
	check.id != "EC2-005"
}

applicable(resource, check) if {
	check.id == "EC2-005"
	known_instance_type(resource)

	instance_type := actual_value(resource, ["instance_type"])

	some family in ["t3.", "t3a."]
	startswith(instance_type, family)
}

# Do not silently skip the CPU credit check if instance type
# cannot be determined.

applicable(resource, check) if {
	check.id == "EC2-005"
	not known_instance_type(resource)
}

# ------------------------------------------------------------
# Identify indeterminate security requirements
# ------------------------------------------------------------

check_unknown(resource, check) if {
	unknown_at(resource, check.path)
}

check_unknown(resource, check) if {
	check.id == "EC2-005"
	not known_instance_type(resource)
}

# ------------------------------------------------------------
# Evaluate individual requirements
# ------------------------------------------------------------

check_status(resource, check) := "INDETERMINATE" if {
	check_unknown(resource, check)
} else := "INDETERMINATE" if {
	actual_value(resource, check.path) == null
} else := "PASS" if {
	actual_value(resource, check.path) == check.expected
} else := "FAIL"

# ------------------------------------------------------------
# Generate structured results for each applicable requirement
# ------------------------------------------------------------

results := [result |
	valid_plan

	some resource in input.resource_changes
	eligible(resource)

	some check in checks
	applicable(resource, check)

	result := {
		"policy_id": check.id,
		"resource": resource.address,
		"attribute": check.attribute,
		"category": check.category,
		"expected": check.expected,
		"actual": actual_value(resource, check.path),
		"status": check_status(resource, check),
		"description": check.description,
	}
]

# ------------------------------------------------------------
# Summarize evaluation results
# ------------------------------------------------------------

passed := count([result |
	some result in results
	result.status == "PASS"
])

failed := count([result |
	some result in results
	result.status == "FAIL"
])

indeterminate := count([result |
	some result in results
	result.status == "INDETERMINATE"
])

# ------------------------------------------------------------
# Overall validation decision
# ------------------------------------------------------------

overall_status := "INVALID_INPUT" if {
	not valid_plan
} else := "NOT_APPLICABLE" if {
	count(results) == 0
} else := "FAIL" if {
	failed > 0
} else := "FAIL" if {
	indeterminate > 0
} else := "PASS"

default allow := false

allow if {
	overall_status == "PASS"
}

# ------------------------------------------------------------
# Machine-readable security assurance output
# ------------------------------------------------------------

report := {
	"policy": "terraform.aws.ec2",
	"evaluation_scope": "terraform_proposed_state",
	"status": overall_status,
	"allow": allow,
	"summary": {
		"total": count(results),
		"passed": passed,
		"failed": failed,
		"indeterminate": indeterminate,
	},
	"results": results,
}
