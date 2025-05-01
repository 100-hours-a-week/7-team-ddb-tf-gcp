variable "env" {
  description = "Deployment environment name"
  type        = string
}

variable "component" {
  description = "같은 환경의 여러 DB를 구분하기 위한 컴포넌트 (i.e., primary)"
  type        = string
}

variable "tier" {
  description = "Cloud SQL instance tier"
  type        = string

  validation {
    condition     = contains(["db-f1-micro", "db-g1-small", "db-standard-1"], var.tier)
    error_message = "tier 값은 유효한 Cloud SQL 인스턴스 타입이어야 합니다."
  }
}

variable "vpc_network_id" {
  description = "Cloud SQL에 private ip로 연결하기 위한 vpc network resource id"
  type        = string
}

variable "resource_type" {
  description = "resource type, 필터링 용도"
  type        = string
}

variable "deletion_protection" {
  description = "Cloud SQL instance 삭제 방지 설정 여부"
  type        = bool
  default     = false
}

variable "db_user" {
  description = "Cloud SQL 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Cloud SQL 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "생성할 database 이름"
  type        = string
}

variable "db_user_host" {
  description = "사용자가 어느 호스트로부터 database에 접속할 수 있는지 정의"
  type        = string
}