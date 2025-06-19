variable "env" {
  description = "envs"
  type        = string
}

variable "subnets" {
  description = "Subnet 정의 (GKE용은 secondary_ranges 포함)"
  type = map(object({
    cidr             = string
    secondary_ranges = optional(map(string), {})  
  }))
}