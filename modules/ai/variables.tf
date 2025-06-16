variable "env" {
  description = "배포 환경 이름 (예: dev, prod)"
  type        = string
}

variable "ssh_users" {
  description = "SSH 접속을 허용할 사용자 계정 목록"
  type        = list(string)
}

variable "machine_type" {
  description = "AI 인스턴스에 사용할 GCE 머신 타입"
  type        = string
  default     = "n1-standard-1"
}

variable "zone" {
  description = "GCP zone (예: asia-northeast3-a)"
  type        = string
}

variable "private_route_tag" {
  description = "NAT 라우팅 대상 식별에 사용할 네트워크 태그"
  type        = string
}

variable "network" {
  description = "VPC 네트워크 이름"
  type        = string
}

variable "subnetwork" {
  description = "subnetwork 이름"
  type        = string
}

variable "ai_port" {
  description = "AI 애플리케이션이 수신할 포트 번호 (예: 8000)"
  type        = number
}

variable "ai_port_name" {
  description = "인스턴스 그룹의 named port 이름 (예: http)"
  type        = string
}

variable "health_check_path" {
  description = "헬스체크를 위한 요청 경로"
  type        = string
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