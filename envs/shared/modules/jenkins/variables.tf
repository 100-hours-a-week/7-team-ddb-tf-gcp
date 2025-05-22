variable "env" {
  description = "env 환경"
  type        = string
  default     = "shared"
}

variable "jenkins_instance_name" {
  description = "Jenkins 인스턴스 이름"
  type        = string
}

variable "machine_type" {
  description = "Jenkins 인스턴스 머신 타입"
  type        = string
  default     = "n1-standard-1"
}

variable "zone" {
  description = "Jenkins 인스턴스가 위치할 GCP zone"
  type        = string
}

variable "network" {
  description = "VPC 네트워크 self_link"
  type        = string
}

variable "subnetwork" {
  description = "Jenkins가 연결될 서브넷 self_link"
  type        = string
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "velvety-calling-458402-c1"
}

variable "ssh_users" {
  description = "Jenkins 인스턴스에 SSH로 접속할 사용자 계정 목록"
  type        = list(string)
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "젠킨스에 접근 가능한 ssh cidr 리스트"
  default     = ["0.0.0.0/0"]
}