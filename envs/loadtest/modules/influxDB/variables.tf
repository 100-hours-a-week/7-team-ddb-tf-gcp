variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "dolpin-2nd"
}

variable "machine_type" {
  description = "인스턴스 머신 타입"
  type        = string
  default     = "e2-micro"
}

variable "zone" {
  description = "인스턴스가 위치할 GCP zone"
  type        = string
}

variable "network" {
  description = "VPC 네트워크 self_link"
  type        = string
}

variable "subnetwork" {
  description = "subnetwork의 Self-link"
  type        = string
}

variable "env" {
  type        = string
  description = "Environment name (e.g. dev, prod, loadtest)"
}