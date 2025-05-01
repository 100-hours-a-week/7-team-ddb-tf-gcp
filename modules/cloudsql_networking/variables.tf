variable "env" {
  description = "Deployment environment name"
  type        = string
}

variable "vpc_self_link" {
  description = "Cloud SQL과 VPC Peering 연결을 구성할 때 필요한 vpc의 self_link 값"
  type        = string
}

variable "component" {
  description = "같은 환경의 여러 DB를 구분하기 위한 컴포넌트 (i.e., primary)"
  type        = string
}

variable "prefix_length" {
  description = "VPC Peering을 위해 예약할 IP 주소 범위의 크기 (i.e., 24 (for /24))"
  type        = number
  default     = 24
}