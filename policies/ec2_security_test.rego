package terraform.aws.ec2_test

import data.terraform.aws.ec2.report
import rego.v1

# ============================================================
# Cross-Framework Continuous Security Assurance Project
# Phase 3.1 - EC2 Security Policy Automated Tests
#
# All test inputs are synthetic Terraform plan fixtures.
# No AWS infrastructure is created or modified.
# ============================================================

# ------------------------------------------------------------
# Compliant EC2 configuration fixture
# ------------------------------------------------------------

baseline_after := {
	"instance_type": "t3a.micro",
	"associate_public_ip_address": false,
	"metadata_options": [
		{
			"http_endpoint": "enabled",
			"http_tokens": "required",
			"http_put_response_hop_limit": 1,
			"instance_metadata_tags": "disabled",
		},
	],
	"root_block_device": [
		{
			"encrypted": true,
			"delete_on_termination": true,
			"volume_type": "gp3",
			"volume_size": 8,
		},
	],
	"credit_specification": [
		{
			"cpu_credits": "standard",
		},
	],
}

# ------------------------------------------------------------
# Reusable Terraform resource and plan fixtures
# ------------------------------------------------------------

make_resource(address, actions, after, unknown) := {
	"address": address,
	"mode": "managed",
	"type": "aws_instance",
	"change": {
		"actions": actions,
		"before": null,
		"after": after,
		"after_unknown": unknown,
	},
}

make_plan(resources) := {
	"format_version": "1.2",
	"terraform_version": "1.16.4",
	"errored": false,
	"complete": true,
	"resource_changes": resources,
}

plan_with_after(after) := make_plan([
	make_resource(
		"aws_instance.private_workload",
		["create"],
		after,
		{},
	),
])

plan_with_unknown(unknown) := make_plan([
	make_resource(
		"aws_instance.private_workload",
		["create"],
		baseline_after,
		unknown,
	),
])

baseline_plan := plan_with_after(baseline_after)

# ------------------------------------------------------------
# Reusable test assertions
# ------------------------------------------------------------

single_violation(plan, policy_id) if {
	result := report with input as plan

	result.status == "FAIL"
	result.allow == false
	result.summary.total == 5
	result.summary.failed == 1
	result.summary.passed == 4
	result.summary.indeterminate == 0

	failed_ids := {finding.policy_id |
		some finding in result.results
		finding.status == "FAIL"
	}

	failed_ids == {policy_id}
}

single_indeterminate(plan, policy_id) if {
	result := report with input as plan

	result.status == "FAIL"
	result.allow == false
	result.summary.total == 5
	result.summary.indeterminate == 1
	result.summary.failed == 0
	result.summary.passed == 4

	unknown_ids := {finding.policy_id |
		some finding in result.results
		finding.status == "INDETERMINATE"
	}

	unknown_ids == {policy_id}
}

# ------------------------------------------------------------
# Positive baseline test
# ------------------------------------------------------------

test_compliant_ec2 if {
	result := report with input as baseline_plan

	result.status == "PASS"
	result.allow == true
	result.summary.total == 5
	result.summary.passed == 5
	result.summary.failed == 0
	result.summary.indeterminate == 0

	passed_ids := {finding.policy_id |
		some finding in result.results
		finding.status == "PASS"
	}

	passed_ids == {
		"EC2-001",
		"EC2-002",
		"EC2-003",
		"EC2-004",
		"EC2-005",
	}
}

# ------------------------------------------------------------
# Independent negative security and governance tests
# ------------------------------------------------------------

test_ec2_001_public_ipv4_enabled if {
	after := object.union(baseline_after, {
		"associate_public_ip_address": true,
	})

	single_violation(
		plan_with_after(after),
		"EC2-001",
	)
}

test_ec2_002_imdsv1_permitted if {
	metadata := object.union(
		baseline_after.metadata_options[0],
		{"http_tokens": "optional"},
	)

	after := object.union(baseline_after, {
		"metadata_options": [metadata],
	})

	single_violation(
		plan_with_after(after),
		"EC2-002",
	)
}

test_ec2_003_root_ebs_unencrypted if {
	root_volume := object.union(
		baseline_after.root_block_device[0],
		{"encrypted": false},
	)

	after := object.union(baseline_after, {
		"root_block_device": [root_volume],
	})

	single_violation(
		plan_with_after(after),
		"EC2-003",
	)
}

test_ec2_004_delete_on_termination_disabled if {
	root_volume := object.union(
		baseline_after.root_block_device[0],
		{"delete_on_termination": false},
	)

	after := object.union(baseline_after, {
		"root_block_device": [root_volume],
	})

	single_violation(
		plan_with_after(after),
		"EC2-004",
	)
}

test_ec2_005_unlimited_cpu_credits if {
	after := object.union(baseline_after, {
		"credit_specification": [
			{"cpu_credits": "unlimited"},
		],
	})

	single_violation(
		plan_with_after(after),
		"EC2-005",
	)
}

# ------------------------------------------------------------
# Combined negative test
# ------------------------------------------------------------

test_all_five_requirements_violated if {
	after := object.union(baseline_after, {
		"associate_public_ip_address": true,
		"metadata_options": [
			{"http_tokens": "optional"},
		],
		"root_block_device": [
			{
				"encrypted": false,
				"delete_on_termination": false,
			},
		],
		"credit_specification": [
			{"cpu_credits": "unlimited"},
		],
	})

	plan := plan_with_after(after)

	result := report with input as plan

	result.status == "FAIL"
	result.allow == false
	result.summary.total == 5
	result.summary.failed == 5
	result.summary.passed == 0
	result.summary.indeterminate == 0
}

# ------------------------------------------------------------
# Missing and unknown attribute tests
# ------------------------------------------------------------

test_missing_required_attribute if {
	after := object.remove(
		baseline_after,
		["associate_public_ip_address"],
	)

	single_indeterminate(
		plan_with_after(after),
		"EC2-001",
	)
}

test_unknown_required_attribute if {
	plan := plan_with_unknown({
		"associate_public_ip_address": true,
	})

	single_indeterminate(plan, "EC2-001")
}

test_unknown_nested_attribute if {
	plan := plan_with_unknown({
		"metadata_options": [
			{"http_tokens": true},
		],
	})

	single_indeterminate(plan, "EC2-002")
}

test_unknown_parent_configuration_block if {
	plan := plan_with_unknown({
		"metadata_options": true,
	})

	single_indeterminate(plan, "EC2-002")
}

test_unknown_entire_resource_configuration if {
	plan := make_plan([
		make_resource(
			"aws_instance.private_workload",
			["create"],
			null,
			true,
		),
	])

	result := report with input as plan

	result.status == "FAIL"
	result.allow == false
	result.summary.indeterminate == 5
	result.summary.passed == 0
}

# ------------------------------------------------------------
# Input validation tests
# ------------------------------------------------------------

test_invalid_plan_input if {
	result := report with input as {}

	result.status == "INVALID_INPUT"
	result.allow == false
	result.summary.total == 0
}

test_incomplete_plan if {
	plan := object.union(baseline_plan, {
		"complete": false,
	})

	result := report with input as plan

	result.status == "INVALID_INPUT"
	result.allow == false
}

test_errored_plan if {
	plan := object.union(baseline_plan, {
		"errored": true,
	})

	result := report with input as plan

	result.status == "INVALID_INPUT"
	result.allow == false
}

test_no_applicable_ec2_resources if {
	plan := make_plan([])

	result := report with input as plan

	result.status == "NOT_APPLICABLE"
	result.allow == false
	result.summary.total == 0
}

# ------------------------------------------------------------
# Instance type applicability tests
# ------------------------------------------------------------

test_non_t3_instance_excludes_cpu_credit_check if {
	updated := object.union(baseline_after, {
		"instance_type": "m5.large",
	})

	after := object.remove(
		updated,
		["credit_specification"],
	)

	plan := plan_with_after(after)

	result := report with input as plan

	result.status == "PASS"
	result.allow == true
	result.summary.total == 4
	result.summary.passed == 4

	not "EC2-005" in {finding.policy_id |
		some finding in result.results
	}
}

test_t3_instance_requires_standard_credits if {
	after := object.union(baseline_after, {
		"instance_type": "t3.micro",
		"credit_specification": [
			{"cpu_credits": "unlimited"},
		],
	})

	single_violation(
		plan_with_after(after),
		"EC2-005",
	)
}

test_unknown_instance_type if {
	plan := plan_with_unknown({
		"instance_type": true,
	})

	single_indeterminate(plan, "EC2-005")
}

# ------------------------------------------------------------
# Multiple resource validation
# ------------------------------------------------------------

test_multiple_ec2_resources if {
	insecure_after := object.union(baseline_after, {
		"associate_public_ip_address": true,
	})

	plan := make_plan([
		make_resource(
			"aws_instance.secure",
			["create"],
			baseline_after,
			{},
		),
		make_resource(
			"aws_instance.insecure",
			["create"],
			insecure_after,
			{},
		),
	])

	result := report with input as plan

	result.status == "FAIL"
	result.allow == false
	result.summary.total == 10
	result.summary.passed == 9
	result.summary.failed == 1

	some finding in result.results

	finding.resource == "aws_instance.insecure"
	finding.policy_id == "EC2-001"
	finding.status == "FAIL"
}

# ------------------------------------------------------------
# Resource lifecycle tests
# ------------------------------------------------------------

test_delete_only_resource_excluded if {
	plan := make_plan([
		make_resource(
			"aws_instance.private_workload",
			["delete"],
			null,
			{},
		),
	])

	result := report with input as plan

	result.status == "NOT_APPLICABLE"
	result.allow == false
	result.summary.total == 0
}

test_replacement_resource_evaluated if {
	plan := make_plan([
		make_resource(
			"aws_instance.private_workload",
			["delete", "create"],
			baseline_after,
			{},
		),
	])

	result := report with input as plan

	result.status == "PASS"
	result.allow == true
	result.summary.passed == 5
}

test_unchanged_resource_evaluated if {
	plan := make_plan([
		make_resource(
			"aws_instance.private_workload",
			["no-op"],
			baseline_after,
			{},
		),
	])

	result := report with input as plan

	result.status == "PASS"
	result.allow == true
	result.summary.passed == 5
}
