resource "google_scc_source" "this" {
  organization = var.organization
  display_name = var.display_name
  description  = var.description
}

# A Security Command Center source is only a container. Creating it grants nobody the
# right to write into it, so a source without a findings editor is created successfully
# and then never receives a single finding: the reporting integration is denied by IAM.
# `source` is given the full resource name ("organizations/<org>/sources/<id>"); the
# provider's IAM updater parses the organization and source id back out of it.
resource "google_scc_source_iam_member" "findings_editor" {
  for_each = toset(var.findings_editors)

  organization = var.organization
  source       = google_scc_source.this.name
  role         = "roles/securitycenter.findingsEditor"
  member       = each.value
}

resource "google_scc_source_iam_member" "findings_viewer" {
  for_each = toset(var.findings_viewers)

  organization = var.organization
  source       = google_scc_source.this.name
  role         = "roles/securitycenter.findingsViewer"
  member       = each.value
}
