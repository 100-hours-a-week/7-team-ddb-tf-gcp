variable "name_prefix" {
  description = "현재 VPC의 이름 또는 접두사 (예: shared)"
  type        = string
}

variable "peer_name" {
  description = "상대 VPC의 이름 또는 접두사 (예: dev, prod)"
  type        = string
}

variable "this_vpc_self_link" {
  description = "현재 VPC의 self_link"
  type        = string
}

variable "peer_vpc_self_link" {
  description = "상대 VPC의 self_link"
  type        = string
}

variable "export_custom_routes" {
  description = "현재 VPC에서 custom route export 여부"
  type        = bool
  default     = true
}

variable "import_custom_routes" {
  description = "현재 VPC에서 custom route import 여부"
  type        = bool
  default     = true
}

variable "create_firewall" {
  type    = bool
  default = true
}

variable "peer_cidr_blocks" {
  type = list(string)
}

variable "allowed_ports" {
  type    = list(string)
  default = ["22", "80", "443"]
}

variable "firewall_target_tags" {
  type = list(string)
}