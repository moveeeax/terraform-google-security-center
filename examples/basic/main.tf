terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "security_center" {
  source = "../.."

  organization = var.organization
  display_name = "example-source"
  description  = "Findings from the example integration"

  # Without a findings editor the source is created and then never receives anything,
  # because the reporting integration has no permission to write into it.
  findings_editors = var.findings_editors
}

variable "project_id" {
  description = "Project ID used to configure the google provider."
  type        = string
}

variable "organization" {
  description = "Organization id that owns the source."
  type        = string
}

variable "region" {
  description = "Region for the google provider."
  type        = string
  default     = "us-central1"
}

variable "findings_editors" {
  description = "IAM principals allowed to report findings into the source, for example [\"serviceAccount:scanner@example.iam.gserviceaccount.com\"]."
  type        = list(string)
  default     = []
}

output "source_name" {
  value = module.security_center.name
}
