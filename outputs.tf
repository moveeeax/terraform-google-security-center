output "id" {
  description = "Identifier of the Security Command Center source."
  value       = google_scc_source.this.id
}

output "name" {
  description = "Resource name of the source, formatted as organizations/<org>/sources/<id>."
  value       = google_scc_source.this.name
}
