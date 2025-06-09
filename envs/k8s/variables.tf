variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast3"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP credentials JSON file"
  default     = "../../secrets/accountk8s.json"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "cryptic-bolt-460214-n3"
}

variable "env" {
  type        = string
  description = "env 환경"
  default     = "k8s"
}

variable "gke_cidr" {
  type        = string
  description = "GKE 서브넷의 기본 CIDR 블록"
  default     = "10.10.0.0/20"
}

variable "gke_pods_range" {
  type        = string
  description = "GKE 파드에 할당될 Secondary IP 범위"
  default     = "10.20.0.0/14"
}

variable "gke_services_range" {
  type        = string
  description = "GKE 서비스에 할당될 Secondary IP 범위"
  default     = "10.24.0.0/20"
}