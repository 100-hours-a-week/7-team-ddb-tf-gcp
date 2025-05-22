variable "env" {
  description = "env 환경"
  type = string
}

variable "vpc_self_link" {
  description = "Cloud NAT을 연결할 VPC의 self_link"
  type = string
}