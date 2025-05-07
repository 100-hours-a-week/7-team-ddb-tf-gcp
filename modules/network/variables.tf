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

variable "public_route_tag" {
  description = "public route tags"
  type = string
}
