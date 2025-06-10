variable "env" {
  type        = string
  description = "Environment name (e.g. dev, prod, loadtest)"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "dolpin-2nd"
}

variable "machine_type" {
  description = "k6 인스턴스 머신 타입"
  type        = string
  default     = "n2-standard-4"
}

variable "zone" {
  description = "k6 인스턴스가 위치할 GCP zone"
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

variable "instance_tag" {
  description = "Network tag for firewall rules"
  type        = string
}

variable "ssh_users" {
  description = "Jenkins 인스턴스에 SSH로 접속할 사용자 계정 목록"
  type        = list(string)
}