variable "env" {
  description = "Deployment environment name"
  type        = string
}

variable "component" {
  description = "Component or service name to differentiate multiple DBs per environment"
  type        = string
}

variable "tier" {
  description = "Cloud SQL instance tier"
  type        = string
}

variable "vpc_network_id" {
  description = "VPC network resource ID for private IP connectivity to Cloud SQL"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to protect the Cloud SQL instance from deletion"
  type        = bool
  default     = false
}