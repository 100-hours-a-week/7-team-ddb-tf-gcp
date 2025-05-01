variable "name" {
  description = "Name of the SSL certificate resource"
  type        = string
}

variable "domains" {
  description = "SSL certificate인증을 받을 도메인 리스트"
  type        = list(string)
}
