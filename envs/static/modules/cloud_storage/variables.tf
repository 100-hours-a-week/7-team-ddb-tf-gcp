variable "bucket_name" {
  description = "GCS 버킷 이름"
  type        = string
}

variable "bucket_location" {
  description = "GCS 버킷이 생성될 리전 (예: ASIA, US 등)"
  type        = string
}

variable "env" {
  description = "배포 환경 구분 값 (dev, prod 등)"
  type        = string
}

