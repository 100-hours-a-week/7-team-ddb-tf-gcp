variable "env" {
  description = "envs (dev, prod)"
  type        = string
}

variable "subnets" {
  description = "subnet setting. key=name, value={ cidr}"
  type = map(object({
    cidr = string
  }))
}


variable "nat_link" {
  description = "nat instance의 self_link"
  type        = string
}

variable "private_route_tag" {
  description = "private route tags"
  type = string
}

variable "public_route_tag" {
  description = "public route tags"
  type = string
}
