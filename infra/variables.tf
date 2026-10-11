variable "project_id" {
  type    = string
  default = "portfolio-data-vr"
}

variable "location" {
  type    = string
  default = "EU"
}

variable "owner_email" {
  description = "Propriétaire humain des datasets (dans terraform.tfvars, non versionné)."
  type        = string
}
