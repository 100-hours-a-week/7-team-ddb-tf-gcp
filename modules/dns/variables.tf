variable "env" {
  type = string
}

variable "domains" {
  description = "도메인 리스트"
  type        = list(string)
}

variable "dns_managed_zone" {
  description = "Cloud DNS 관리 영역 이름"
  type        = string
}

variable "network" {
  description = "VPC 네트워크 self_link"
  type        = string
}

# services 맵을 아래 구조로 변경
variable "services" {
  description = "key : service 태그, value: 서비스별 도메인 및 백엔드 정보"
  type = map(object({
    domain         = string # ex: "be.dev.dolpin.site"
    instance_group = string # module.be.instance_group
    health_check   = string # module.be.health_check_id
    port_name      = string # module.be.port_name
  }))
}

variable "cdn_backend_bucket_self_link" {
  description = "cloud_storage 모듈에서 전달받은 backend_bucket self link (cdn용)"
  type        = string
}

variable "fallback_service_key" {
  description = "host 미매칭 시 기본 라우팅 대상 서비스 키"
  type        = string

  validation {
    condition     = contains(keys(var.services), var.fallback_service_key)
    error_message = "fallback_service_key 값은 services 변수 내의 키 중 하나여야 합니다."
  }
}