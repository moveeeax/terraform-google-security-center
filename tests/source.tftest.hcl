# Test-only requirement: `mock_provider` needs Terraform >= 1.7 (OpenTofu >= 1.7).
# The module itself still supports >= 1.5 -- do not raise required_version in versions.tf
# just to run these tests.

mock_provider "google" {}

variables {
  organization = "123456789012"
  display_name = "custom-scanner"
}

run "creates_source_with_defaults" {
  assert {
    condition     = google_scc_source.this.organization == "123456789012"
    error_message = "The source must be created under the organization that was passed in."
  }

  assert {
    condition     = google_scc_source.this.display_name == "custom-scanner"
    error_message = "The source display name must be the one that was passed in."
  }

  assert {
    condition     = google_scc_source.this.description == "Managed by Terraform"
    error_message = "The default description must be \"Managed by Terraform\"."
  }
}

run "grants_no_iam_by_default" {
  assert {
    condition     = length(google_scc_source_iam_member.findings_editor) == 0
    error_message = "No findings editor may be granted unless findings_editors is set."
  }

  assert {
    condition     = length(google_scc_source_iam_member.findings_viewer) == 0
    error_message = "No findings viewer may be granted unless findings_viewers is set."
  }
}

run "grants_findings_editor_on_the_source_itself" {
  variables {
    findings_editors = ["serviceAccount:scanner@example.iam.gserviceaccount.com"]
    findings_viewers = ["group:secops@example.com"]
  }

  # Without this binding the source is created successfully and then stays empty
  # forever, because the reporting integration is denied by IAM.
  assert {
    condition     = google_scc_source_iam_member.findings_editor["serviceAccount:scanner@example.iam.gserviceaccount.com"].role == "roles/securitycenter.findingsEditor"
    error_message = "findings_editors must be granted exactly roles/securitycenter.findingsEditor."
  }

  # The binding has to land on the source, not on the organization: a binding scoped
  # anywhere else leaves the source itself unwritable.
  assert {
    condition     = google_scc_source_iam_member.findings_editor["serviceAccount:scanner@example.iam.gserviceaccount.com"].source == google_scc_source.this.name
    error_message = "The IAM member must be attached to the source created by this module."
  }

  assert {
    condition     = google_scc_source_iam_member.findings_viewer["group:secops@example.com"].role == "roles/securitycenter.findingsViewer"
    error_message = "findings_viewers must be granted exactly roles/securitycenter.findingsViewer."
  }
}

run "rejects_organization_resource_path" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    organization = "organizations/123456789012"
  }

  expect_failures = [var.organization]
}

run "rejects_non_numeric_organization" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    organization = "example.com"
  }

  expect_failures = [var.organization]
}

run "rejects_overlong_display_name" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    display_name = "this-display-name-is-deliberately-far-longer-than-the-sixty-four-character-api-limit"
  }

  expect_failures = [var.display_name]
}

run "rejects_public_findings_editor" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    findings_editors = ["allUsers"]
  }

  expect_failures = [var.findings_editors]
}

run "rejects_public_findings_viewer" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    findings_viewers = ["allAuthenticatedUsers"]
  }

  expect_failures = [var.findings_viewers]
}

run "rejects_unqualified_iam_member" {
  # Variable validation fails during planning, so this run must not try to apply.
  command = plan

  variables {
    findings_editors = ["scanner@example.iam.gserviceaccount.com"]
  }

  expect_failures = [var.findings_editors]
}
