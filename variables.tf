variable "organization" {
  description = "Numeric organization id that owns the Security Command Center source, without the `organizations/` prefix (for example \"123456789012\")."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{1,20}$", var.organization))
    error_message = "organization must be the bare numeric organization id, for example \"123456789012\". A resource path such as \"organizations/123456789012\" or a domain name is not accepted: the provider interpolates this value into \"organizations/<organization>/sources\" and would build a malformed API path."
  }
}

variable "display_name" {
  description = "Display name of the Security Command Center source. Must be unique among the sources of the same organization."
  type        = string

  validation {
    condition     = length(var.display_name) >= 1 && length(var.display_name) <= 64
    error_message = "display_name must be between 1 and 64 characters, as required by the Security Command Center API."
  }
}

variable "description" {
  description = "Description of the source, shown in the Security Command Center console."
  type        = string
  default     = "Managed by Terraform"

  validation {
    condition     = length(var.description) <= 1024
    error_message = "description must be at most 1024 characters, as required by the Security Command Center API."
  }
}

variable "findings_editors" {
  description = <<-EOT
    IAM principals granted `roles/securitycenter.findingsEditor` on this source, i.e. the
    identities allowed to create and update findings under it.

    A source with no findings editor is inert: it is created successfully and then stays
    empty forever, because the integration that is meant to report into it is denied by
    IAM. Unless the reporting identity already holds an equivalent role inherited from the
    organization, list it here.

    Entries must be fully qualified IAM members, for example
    "serviceAccount:scanner@example.iam.gserviceaccount.com".
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for member in var.findings_editors :
      can(regex("^(user|serviceAccount|group|domain|principal|principalSet|principalHierarchy):.+$", member))
    ])
    error_message = "Each entry in findings_editors must be a fully qualified IAM member such as \"serviceAccount:scanner@example.iam.gserviceaccount.com\". The public principals \"allUsers\" and \"allAuthenticatedUsers\" are rejected on purpose: they would let anyone write findings into this source."
  }
}

variable "findings_viewers" {
  description = <<-EOT
    IAM principals granted `roles/securitycenter.findingsViewer` on this source, i.e. the
    identities allowed to read the findings reported under it. Entries must be fully
    qualified IAM members, for example "group:secops@example.com".
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for member in var.findings_viewers :
      can(regex("^(user|serviceAccount|group|domain|principal|principalSet|principalHierarchy):.+$", member))
    ])
    error_message = "Each entry in findings_viewers must be a fully qualified IAM member such as \"group:secops@example.com\". The public principals \"allUsers\" and \"allAuthenticatedUsers\" are rejected on purpose: security findings must not be world-readable."
  }
}
