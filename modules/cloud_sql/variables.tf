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

  validation {
    condition     = contains(["db-f1-micro", "db-g1-small", "db-standard-1"], var.tier)
    error_message = "tier 값은 유효한 Cloud SQL 인스턴스 타입이어야 합니다."
  }
}

variable "vpc_network_id" {
  description = "VPC network resource ID for private IP connectivity to Cloud SQL"
  type        = string
}

variable "resource_type" {
  description = "resource type"
  type        = string
}

variable "deletion_protection" {
  description = "Whether to protect the Cloud SQL instance from deletion"
  type        = bool
  default     = true
}

variable "db_user" {
  description = "Username for the Cloud SQL database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the Cloud SQL database user"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name to create"
  type        = string
}

variable "db_user_host" {
  description = "Host from which the DB user is allowed to connect"
  type        = string
}