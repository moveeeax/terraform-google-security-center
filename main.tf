resource "google_scc_source" "this" {
  organization = var.organization
  display_name = var.display_name
  description  = var.description
}
