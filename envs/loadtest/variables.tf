variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast3"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP credentials JSON file"
  default     = "../../secrets/account2nd.json"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "dolpin-2nd"
}