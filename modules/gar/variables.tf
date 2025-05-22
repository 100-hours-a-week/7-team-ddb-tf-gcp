variable "location" {
  type        = string
  description = "Artifact Registry 저장소의 리전"
  default     = "asia-northeast3"
}

variable "env" {
  type        = string
  description = "env"
}

variable "format" {
  type        = string
  description = "저장소 형식 (예: DOCKER, MAVEN, NPM)"
  default     = "DOCKER"
}

variable "immutable_tags" {
  type        = bool
  description = "DOCKER 저장소에서 태그 불변성 설정"
  default     = false
}

variable "cleanup_policies" {
  type = list(object({
    id     = string
    action = string
    condition = optional(object({
      tag_state    = optional(string)
      tag_prefixes = optional(list(string))
      older_than   = optional(string)
      newer_than   = optional(string)
    }))
  }))
  description = "자동 삭제 정책 목록"
  default     = []
}

variable "labels" {
  type        = map(string)
  description = "저장소에 붙일 라벨"
  default     = {}
}
