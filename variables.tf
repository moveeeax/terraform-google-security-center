variable "organization" {
  description = "Numeric organization id that owns the Security Command Center source."
  type        = string
}

variable "display_name" {
  description = "Display name of the Security Command Center source."
  type        = string
}

variable "description" {
  description = "Description of the source, shown in the Security Command Center console."
  type        = string
  default     = "Managed by Terraform"
}
