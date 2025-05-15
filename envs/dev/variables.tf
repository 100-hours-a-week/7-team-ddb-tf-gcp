variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast3"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP credentials JSON file"
  default     = "../../secrets/account.json"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "velvety-calling-458402-c1"
}

variable "env" {
  type        = string
  description = "env 환경"
  default     = "dev"
}

variable "public_service_name" {
  type        = string
  description = "public 서브넷에 위치할 서비스 이름"
  default     = "public"
}

variable "public_cidr" {
  type        = string
  description = "public 서브넷의 cirdr"
  default     = "10.20.10.0/24"
}

variable "fe_cidr" {
    type        = string
  description = "value"
  default     = "10.20.20.0/24"
}

variable "be_cidr" {
  type        = string
  description = "value"
  default     = "10.20.30.0/24"
}

variable "ai_cidr" {
  type        = string
  description = "value"
  default     = "10.20.40.0/24"
}

variable "public_tag" {
  type        = string
  description = "public 환경 tag"
  default     = "public"
}

variable "private_tag" {
  type        = string
  description = "private 환경 tag"
  default     = "private"
}

variable "dns_zone_name" {
  type        = string
  description = "dns managed zone 이름"
  default     = "dolpin"
}

//nat_bastion 변수
variable "nat_bastion_instance_type" {
  type        = string
  description = "nat_bastion instance 종류"
  default     = "g1-small"
}

variable "nat_bastion_allowed_ssh_cidrs" {
  type        = list(string)
  description = "nat_bastion에 접근가능한 ssh cidr 리스트"
  default     = ["0.0.0.0/0"]
}

variable "nat_bastion_ssh_users" {
  type        = list(string)
  description = "nat_bastion에 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily", "eric", "suzy", "juny", "jensen"]
}

variable "nat_bastion_zone" {
  type        = string
  description = "nat_bastion이 위치할 zone"
  default     = "asia-northeast3-a"
}

//be 변수
variable "be_service_name" {
  type        = string
  description = "backend 서비스 이름"
  default     = "be"
}

variable "be_domain" {
  type        = string
  description = "backend domain name"
  default     = "be.dev.dolpin.site"
}

variable "be_zone" {
  type        = string
  description = "backend가 위치할 zone"
  default     = "asia-northeast3-a"
}

variable "be_ssh_users" {
  type        = list(string)
  description = "backend에 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily", "eric"]
}

variable "be_port" {
  type        = string
  description = "backend service port"
  default     = "8080"
}
variable "be_instance_type" {
  type        = string
  description = "backend가 사용할 instance type"
  default     = "n1-standard-1"
}
variable "be_health_check_path" {
  type        = string
  description = "backend instance의 health check 주소"
  default     = "/api/v1/health"
}

//cloudsql
variable "db_user" {
  type        = string
  description = "backend service port"
  default     = "dolpinuser"
}
variable "db_password" {
  type        = string
  description = "backend가 사용할 instance type"
  default     = "0205"
}
variable "db_name" {
  type        = string
  description = "backend instance의 health check 주소"
  default     = "dolpin"
}

// bucket
variable "bucket_name" {
  type        = string
  description = "이미지 저장소 이름"
  default     = "dolpin-image"
}
variable "backend_service_account_email" {
  type        = string
  description = "backend 서비스 계정 이메일"
  default     = "backend@velvety-calling-458402-c1.iam.gserviceaccount.com"
}
variable "bucket_service_name" {
  type        = string
  description = "이미지 서비스 이름"
  default     = "cdn"
}
variable "bucket_domain" {
  type        = string
  description = "bucket domain"
  default     = "cdn.dev.dolpin.site"
}
variable "cors_origin" {
  type        = string
  description = "cors_origin"
  default     = "https://fe.dev.dolpin.site"
}

// ai
variable "ai_domain" {
  type        = string
  description = "backend domain name"
  default     = "ai.dev.dolpin.site"
}
variable "ai_zone" {
  type        = string
  description = "ai가 위치할 zone"
  default     = "asia-northeast3-a"
}

variable "ai_ssh_users" {
  type        = list(string)
  description = "ai에 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily", "juny", "jensen"]
}

variable "ai_port" {
  type        = string
  description = "ai service port"
  default     = "8000"
}

variable "ai_service_name" {
  type        = string
  description = "backend 서비스 이름"
  default     = "ai"
}

variable "ai_health_check_path" {
  type        = string
  description = "backend instance의 health check 주소"
  default     = "/health"
}

variable "ai_instance_type" {
  type        = string
  description = "backend가 사용할 instance type"
  default     = "n1-standard-1"
}

//fe
variable "fe_service_name" {
  type        = string
  description = "backend 서비스 이름"
  default     = "fe"
}

variable "fe_domain" {
  type        = string
  description = "backend domain name"
  default     = "fe.dev.dolpin.site"
}

variable "fe_zone" {
  type        = string
  description = "backend가 위치할 zone"
  default     = "asia-northeast3-a"
}

variable "fe_ssh_users" {
  type        = list(string)
  description = "frontend에 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily", "suzy"]
}

variable "fe_port" {
  type        = string
  description = "frontend service port"
  default     = "3000"
}
variable "fe_instance_type" {
  type        = string
  description = "frontend가 사용할 instance type"
  default     = "n1-standard-1"
}
variable "fe_health_check_path" {
  type        = string
  description = "frontend instance의 health check 주소"
  default     = "/api/health"
}

variable "backup_bucket_name" {
  type = string
  description = "백업할 bucket 이름"
  default = "static-backup-bucket"
}