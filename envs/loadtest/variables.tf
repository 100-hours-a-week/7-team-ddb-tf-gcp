variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast3"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP credentials JSON file"
  default     = "../../secrets/account2nd.json"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "dolpin-2nd"
}

variable "env" {
  type        = string
  description = "env 환경"
  default     = "loadtest"
}

variable "public_service_name" {
  type        = string
  description = "public 서브넷에 위치할 서비스 이름"
  default     = "public-k6"
}

variable "public_cidr" {
  type        = string
  description = "public 서브넷의 cidr"
  default     = "10.40.10.0/24"
}

variable "public_tag" {
  type        = string
  description = "public 환경 tag"
  default     = "public-k6"
}

variable "zone" {
  type        = string
  description = "k6가 위치할 zone"
  default     = "asia-northeast3-a"
}

variable "machine_type" {
  description = "k6 인스턴스 머신 타입"
  type        = string
  default     = "n2-standard-4"
}

variable "ssh_users" {
  type        = list(string)
  description = "k6 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily"]
}