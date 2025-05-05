variable "bucket_name" {
  description = "이미지를 저장할 GCS 버킷 이름"
  type        = string
}

variable "location" {
  description = "GCS 버킷이 생성될 리전 (예: ASIA, US 등)"
  type        = string
  default     = "ASIA"
}

variable "force_destroy" {
  description = "버킷 삭제 시 내부 객체도 함께 삭제할지 여부 (운영 환경에서는 false 권장)"
  type        = bool
  default     = false
}

variable "cors_origins" {
  description = "브라우저에서 허용할 CORS 요청 origin"
  type        = list(string)
}

variable "env" {
  description = "배포 환경 구분 값 (dev, prod 등)"
  type        = string
}

variable "backend_service_account_email" {
  description = "이미지를 업로드할 백엔드 서비스 계정의 이메일 주소"
  type        = string
}