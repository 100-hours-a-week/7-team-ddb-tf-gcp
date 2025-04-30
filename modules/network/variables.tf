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
  description = "subnet setting"
  type        = map(object({
    cidr = string
    type = string # public or private
  }))
}
