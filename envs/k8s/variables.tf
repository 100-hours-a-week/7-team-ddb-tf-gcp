variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast3"
}

variable "credentials_file" {
  type        = string
  description = "Path to the GCP credentials JSON file"
  default     = "../../secrets/accountk8s.json"
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "cryptic-bolt-460214-n3"
}

variable "env" {
  type        = string
  description = "env 환경"
  default     = "k8s"
}

variable "gke_cidr" {
  type        = string
  description = "GKE 서브넷의 기본 CIDR 블록"
  default     = "10.10.0.0/20"
}

variable "gke_pods_range" {
  type        = string
  description = "GKE 파드에 할당될 Secondary IP 범위"
  default     = "10.20.0.0/14"
}

variable "gke_services_range" {
  type        = string
  description = "GKE 서비스에 할당될 Secondary IP 범위"
  default     = "10.24.0.0/20"
}

variable "jenkins_cidr" {
  type    = string
  default = "10.30.10.0/24"
}

variable "db_name" {
  description = "Cloud SQL DB 이름"
  type        = string
  default     = "dolpin"
}

variable "db_user" {
  description = "Cloud SQL 사용자 이름"
  type        = string
  default     = "dolpinuser"
}

variable "component" {
  description = "DB 컴포넌트 이름 (예: primary)"
  type        = string
  default     = "primary"
}

variable "tier" {
  description = "Cloud SQL 인스턴스 티어"
  type        = string
  default     = "db-f1-micro"
}

variable "resource_type" {
  description = "리소스 유형 태그 (예: db)"
  type        = string
  default     = "db"
}

variable "deletion_protection" {
  description = "Cloud SQL 인스턴스 삭제 방지 여부"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Cloud Storage 버킷 이름"
  type        = string
  default     = "dolpin-image"
}

variable "cors_origin" {
  description = "CORS 허용 origin (예: Frontend 도메인)"
  type        = string
  default     = "https://fe.dev.dolpin.site"
}

variable "be_service_account_email" {
  type    = string
  default = "backend@cryptic-bolt-460214-n3.iam.gserviceaccount.com"
}

variable "location" {
  type        = string
  default     = "asia-northeast3"
}

variable "gar_format" {
  description = "Artifact Registry 형식"
  type        = string
  default     = "DOCKER"
}

variable "immutable_tags" {
  description = "이미지 태그를 immutable하게 유지할지 여부"
  type        = bool
  default     = true
}

variable "cleanup_policies" {
  description = "Artifact Registry 이미지 정리 정책 목록"
  type = list(object({
    id        = string
    action    = string
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

variable "zone" {
  type        = string
  description = "jenkins 위치할 zone"
  default     = "asia-northeast3-a"
}

variable "jenkins_instance_type" {
  type        = string
  description = "jenkins instance 종류"
  default     = "n1-standard-1"
}