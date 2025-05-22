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
  default     = "shared"
}

variable "public_service_name" {
  type        = string
  description = "public 서브넷에 위치할 서비스 이름"
  default     = "public-shared"
}

variable "public_cidr" {
  type        = string
  description = "public 서브넷의 cirdr"
  default     = "10.30.10.0/24"
}

variable "public_tag" {
  type        = string
  description = "public 환경 tag"
  default     = "public-shared"
}

variable "jenkins_instance_type" {
  type        = string
  description = "bastion instance 종류"
  default     = "n1-standard-1"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "젠킨스에 접근 가능한 ssh cidr 리스트"
  default     = ["0.0.0.0/0"]
}

variable "ssh_users" {
  type        = list(string)
  description = "nat_bastion에 접근가능한 ssh 유저 리스트"
  default     = ["peter", "lily", "eric", "suzy", "juny", "jensen"]
}

variable "jenkins_zone" {
  type        = string
  description = "bastion이 위치할 zone"
  default     = "asia-northeast3-a"
}