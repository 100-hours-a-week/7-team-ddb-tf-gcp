variable "env" {
  description = "envs (dev, prod)"
  type        = string
}

variable "network" {
  description = "VPC의 self_link"
  type        = string
}

variable "subnetwork" {
  description = "Subnet의 self_link"
  type        = string
}

variable "zone" {
  description = "Bastion Instance가 위치할 zone"
  type        = string
}

variable "machine_type" {
  description = "instance machine type"
  type        = string
}

variable "private_route_tag" {
  description = "NAT와 연결된 tag"
  type = string
}

variable "ssh_users" {
  description = "bastion에 접근가능 한 유저 이름"
  type    = list(string)
}

variable "ig_port_name" {
  description = "backend ig 포트 이름"
  type = string
}

variable "be_port" {
  description = "backend ig 포트"
  type = number
}

variable "be_health_check_path" {
  description = "헬스체크에 사용할 HTTP 경로"
  type = string
}

variable "cloudsql_ip_address" {
  description = "cloudsql의 public ip"
  type = string
}
variable "shared_vpc_cidr" {
  description = "Shared VPC CIDR block (Bastion, Jenkins가 속한 네트워크 대역)"
  type        = string
}

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
  default     = "dolpin-2nd"
}