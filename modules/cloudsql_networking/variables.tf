variable "env" {
  description = "Deployment environment name (e.g. dev, prod)"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC to peer with Cloud SQL"
  type        = string
}

variable "component" {
  description = "The logical component name (e.g., 'primary', 'replica') to distinguish multiple DBs within the same environment."
  type        = string
}

variable "prefix_length" {
  description = "The prefix length of the IP range to reserve for VPC peering (e.g., 24 for /24)."
  type        = number
  default     = 24
}