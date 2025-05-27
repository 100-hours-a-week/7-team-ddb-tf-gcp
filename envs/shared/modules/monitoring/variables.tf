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
  description = "인스턴스 타입"
  type        = string
}

variable "instance_monitoring" {
  description = "모니터링 ingress firewall 정의. key: 서비스 이름, value: 서비스 cidrs 및 허용할 포트"
  type = map(object({
    cidrs = list(string)
    ports = list(string)
  }))
}

variable "public_key" {
  description = "모니터링에 접속 가능한 public key"
  type        = string
}

variable "ssh_users" {
  type        = list(string)
  description = "접근 가능한 ssh cidr 리스트"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "service_name" {
  type = string
  description = "monitoring 서비스 이름"
}