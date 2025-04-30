variable "env" {
  description = "envs (dev, prod)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast3"
}

variable "subnets" {
  description = "subnet setting. key=name, value={ cidr, type }"
  type        = map(object({
    cidr = string
    type = string # public or private
  }))
}
