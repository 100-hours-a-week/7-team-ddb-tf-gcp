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
  default     = "prod"
}

variable "public_service_name" {
  type        = string
  description = "public 서브넷에 위치할 서비스 이름"
  default     = "public"
}

variable "public_cidr" {
  type        = string
  description = "public 서브넷의 cirdr"
  default     = "10.10.10.0/24"
}

variable "fe_cidr" {
    type        = string
  description = "value"
  default     = "10.10.20.0/24"
}

variable "be_cidr" {
  type        = string
  description = "value"
  default     = "10.10.30.0/24"
}

variable "ai_cidr" {
  type        = string
  description = "value"
  default     = "10.10.40.0/24"
}

variable "shared_vpc_cidr" {
  type        = string
  description = "value"
  default     = "10.30.10.0/24"    
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
//be 변수
variable "be_service_name" {
  type        = string
  description = "backend 서비스 이름"
  default     = "be"
}

variable "be_domain" {
  type        = string
  description = "backend domain name"
  default     = "be.dolpin.site"
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
  default     = "backend2@velvety-calling-458402-c1.iam.gserviceaccount.com"
}
variable "bucket_service_name" {
  type        = string
  description = "이미지 서비스 이름"
  default     = "cdn"
}
variable "bucket_domain" {
  type        = string
  description = "bucket domain"
  default     = "cdn.dolpin.site"
}
variable "cors_origin" {
  type        = string
  description = "cors_origin"
  default     = "https://dolpin.site"
}

// ai
variable "ai_domain" {
  type        = string
  description = "backend domain name"
  default     = "ai.dolpin.site"
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
  default     = "dolpin.site"
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
  type        = string
  description = "백업할 bucket 이름"
  default     = "static-backup-bucket"
}

// vpc peering
variable "shared_name_prefix" {
  description = "VPC 이름 prefix for shared"
  type        = string
  default     = "shared"
}

variable "allowed_ports" {
  description = "허용할 포트 목록"
  type        = list(string)
  default     = ["22"]
}

variable "create_firewall" {
  description = "firewall 리소스를 생성할지 여부"
  type        = bool
  default     = true
}

variable "export_custom_routes" {
  description = "peering에서 custom route를 export할지 여부"
  type        = bool
  default     = true
}

variable "import_custom_routes" {
  description = "peering에서 custom route를 import할지 여부"
  type        = bool
  default     = true
}

// gar
variable "gar_location" {
  description = "GAR 위치 (region)"
  type        = string
  default     = "asia-northeast3"
}

variable "gar_format" {
  description = "GAR 저장소 형식 (예: DOCKER, MAVEN)"
  type        = string
  default     = "DOCKER"
}

variable "immutable_tags" {
  description = "Docker tag를 immutable하게 설정할지 여부"
  type        = bool
  default     = true
}

variable "cleanup_policies" {
  description = "Artifact Registry의 이미지 정리 정책 목록"
  type = list(object({
    id       = string
    action   = string
    condition = any
  }))
  default = [
    {
      id     = "delete-untagged"
      action = "DELETE"
      condition = {
        tag_state = "UNTAGGED"
      }
    },
    {
      id     = "delete-old-tagged"
      action = "DELETE"
      condition = {
        tag_state  = "TAGGED"
        older_than = "30d"
      }
    }
  ]
}
